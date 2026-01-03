# Class Type - Technical Specification

**Document Type**: Technical Specification
**Entity**: Class Type
**Version**: 1.0
**Date**: 2025-10-12
**Author**: AI-Generated (EDW2 to EDW3 Refactoring)

---

## Table of Contents

1. [Overview](#overview)
2. [Architecture Design](#architecture-design)
3. [Data Model Specifications](#data-model-specifications)
4. [Transformation Logic](#transformation-logic)
5. [Performance Considerations](#performance-considerations)
6. [Data Quality Framework](#data-quality-framework)
7. [Deployment Strategy](#deployment-strategy)

---

## Overview

### Purpose

This specification documents the technical implementation for migrating the Class Type dimension from the legacy EDW2 (Wherescape/SQL Server) platform to the modern EDW3 (dbt/Snowflake/Data Vault 2.0) platform.

### Scope

**In Scope**:
- Business Vault hub and computed satellite for Class Type entity
- Type 2 SCD dimension for Class Type
- Business rule implementation (DualEligible, OnExchange flags)
- Historical data migration and reconciliation

**Out of Scope**:
- Raw vault refactoring (assumes current_* views already exist)
- Fact table updates to use new dimension
- Downstream consumption layer changes

### Legacy Architecture

**EDW2 Implementation** (Wherescape/SQL Server):
```
ClassType_NonDV_01 (Staging)
    → ClassType_NonDV_02 (Staging + Business Rules)
    → dimClassType_NonDV (Controller + Hash Keys)
    → dimClassType_Base (Type 2 SCD Dimension)
```

**Characteristics**:
- Sequential stored procedure execution
- Intermediate staging tables with TRUNCATE/INSERT pattern
- T-SQL specific syntax
- Manual hash key generation (SHA1)
- EXCEPT operator for change detection

### Target Architecture

**EDW3 Implementation** (dbt/Snowflake):
```
Raw Vault Current Views
    → bv_h_class_type (Business Vault Hub)
    → bv_s_class_type_business (Business Vault Computed Satellite)
    → dim_class_type (Dimensional Model)
```

**Characteristics**:
- Declarative dbt models with incremental materialization
- CTEs replace staging tables
- Snowflake SQL optimized
- Native Snowflake SHA1_BINARY() function
- QUALIFY and window functions for change detection

---

## Architecture Design

### Layer Organization

#### Business Vault Layer (Curation Database)

**Schema**: `business_vault`

**Purpose**: Apply business rules and create reusable business entities

**Artifacts**:
1. **bv_h_class_type**: Hub for composite Class Type business key
2. **bv_s_class_type_business**: Computed satellite with all business transformations

**Rationale**: Separating business rules into the Business Vault creates reusable components that can serve multiple downstream consumers beyond just the dimensional model.

#### Dimensional Layer (Curation Database)

**Schema**: `dimensional`

**Purpose**: Provide analytics-ready star schema structures

**Artifacts**:
1. **dim_class_type**: Type 2 SCD dimension

**Rationale**: Consumes Business Vault artifacts to create Kimball-style dimensional structures optimized for BI tools and analytics queries.

### Design Patterns

#### Composite Business Key Pattern

**Challenge**: Neither Group nor Class alone uniquely identifies a Class Type

**Solution**: Create composite business key by concatenating Group ID and Class ID
```sql
rtrim(group_id) || ltrim(class_id) as class_type_bk
```

**Benefits**:
- Single hash key represents the composite entity
- Simplifies downstream joins
- Aligns with business understanding of the entity

#### Computed Satellite Pattern

**Challenge**: Legacy had 3 staging layers (NonDV_01, NonDV_02, Controller)

**Solution**: Single computed satellite consolidates all transformation logic

**Benefits**:
- Reduced complexity (1 model vs 3 procedures)
- Better performance (no intermediate materialization)
- Clear separation of concerns (business rules in Business Vault)
- Reusable across multiple consumers

#### Reference Table Join Pattern

**Challenge**: Class Type descriptions in separate reference table with temporal validity

**Solution**: Join with QUALIFY window function to get most recent assignment
```sql
SELECT ... FROM reference
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY group_id, class_bk, source
    ORDER BY effective_to DESC
) = 1
```

**Benefits**:
- More efficient than correlated subquery
- Clearer intent than self-join with MAX()
- Snowflake-optimized syntax

---

## Data Model Specifications

### bv_h_class_type (Business Vault Hub)

#### Table Structure

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| class_type_hk | BINARY(20) | PK, NOT NULL | SHA1 hash of class_type_bk + source |
| class_type_bk | VARCHAR(50) | NOT NULL | Composite: group_id + class_bk |
| record_source | VARCHAR(50) | NOT NULL | Source system identifier |
| load_datetime | TIMESTAMP_NTZ | NOT NULL | Load timestamp |

#### Hash Key Calculation

```sql
SHA1_BINARY(
    CONCAT(
        COALESCE(UPPER(TRIM(class_type_bk)), 'null'), '||',
        COALESCE(UPPER(TRIM(record_source)), 'null')
    )
)
```

**Rationale**:
- Upper and trim for consistency across sources
- Include source in hash for multi-source pattern
- 'null' literal for NULL handling (prevents hash collisions)
- '||' delimiter for readability

#### Materialization Strategy

- **Type**: Incremental
- **Unique Key**: class_type_hk
- **Incremental Logic**: Insert only new business keys (hub is insert-only)
- **Load Window**: 1 hour overlap (configurable via load_offset variable)

### bv_s_class_type_business (Business Vault Computed Satellite)

#### Table Structure

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| class_type_hk | BINARY(20) | PK, FK, NOT NULL | Reference to parent hub |
| load_datetime | TIMESTAMP_NTZ | PK, NOT NULL | When this version loaded |
| load_end_datetime | TIMESTAMP_NTZ | NULL | When superseded (NULL = current) |
| hashdiff | BINARY(20) | NOT NULL | Hash of all descriptive attributes |
| class_type_bk | VARCHAR(50) | | Business key (denormalized) |
| group_id | VARCHAR(50) | | Group identifier component |
| class_bk | VARCHAR(50) | | Class identifier component |
| class_description | VARCHAR(200) | | Class description from source |
| class_type_description | VARCHAR(500) | | Description from reference |
| dual_eligible | VARCHAR(3) | | 'Yes' or 'No' |
| on_exchange | VARCHAR(3) | | 'Yes' or 'No' |
| effective_from_date | DATE | NOT NULL | Start of validity period |
| effective_to_date | DATE | NOT NULL | End of validity period |
| source | VARCHAR(50) | | Source system identifier |
| source_description | VARCHAR(200) | | Source system name |

#### Hash Diff Calculation

```sql
SHA1_BINARY(
    CONCAT(
        COALESCE(TRIM(class_type_description), 'null'), '||',
        COALESCE(TRIM(class_bk), 'null'), '||',
        COALESCE(TRIM(class_description), 'null'), '||',
        COALESCE(TRIM(dual_eligible), 'null'), '||',
        COALESCE(TRIM(on_exchange), 'null'), '||',
        COALESCE(TRIM(source_description), 'null'), '||',
        COALESCE(TO_CHAR(effective_from_date, 'YYYY-MM-DD'), 'null'), '||',
        COALESCE(TO_CHAR(effective_to_date, 'YYYY-MM-DD'), 'null')
    )
)
```

**Rationale**:
- Include all Type 2 attributes (those that should trigger new version)
- Use TO_CHAR for dates to ensure consistent formatting
- Order of attributes is fixed for consistency

#### Materialization Strategy

- **Type**: Incremental
- **Unique Key**: [class_type_hk, load_datetime]
- **Incremental Logic**: Insert only records with new hashdiff
- **Load Window**: 1 hour overlap

#### Change Detection Logic

```sql
WHERE (class_type_hk, hashdiff) NOT IN (
    SELECT class_type_hk, hashdiff
    FROM {{ this }}
    WHERE load_end_datetime IS NULL
)
```

**Rationale**:
- Compare against current records only (load_end_datetime IS NULL)
- Composite check of business key + hashdiff
- More efficient than EXCEPT operator in Snowflake

### dim_class_type (Dimensional Model)

#### Table Structure

| Column | Data Type | Constraints | Description |
|--------|-----------|-------------|-------------|
| class_type_key | NUMBER(38,0) | PK, NOT NULL | Surrogate key (generated) |
| class_type_id | VARCHAR(50) | NOT NULL | Natural key for joins |
| class_type_description | VARCHAR(500) | | Full description |
| class_id | VARCHAR(50) | | Class component |
| class_description | VARCHAR(200) | | Class description |
| dual_eligible | VARCHAR(10) | | 'Yes', 'No', or 'Unknown' |
| on_exchange | VARCHAR(10) | | 'Yes', 'No', or 'Unknown' |
| source_id | VARCHAR(50) | | Source system code |
| source_description | VARCHAR(200) | | Source system name |
| type1_hash | BINARY(20) | | Hash of Type 1 attributes |
| create_date | TIMESTAMP_NTZ | | Original create timestamp |
| update_date | TIMESTAMP_NTZ | | Last update timestamp |
| dss_start_date | DATE | NOT NULL | Effective start date |
| dss_end_date | DATE | NOT NULL | Effective end date |
| dss_current_flag | CHAR(1) | NOT NULL | 'Y' or 'N' |
| dss_version | NUMBER(38,0) | NOT NULL | Version number |
| dss_create_time | TIMESTAMP_NTZ | NOT NULL | DW create timestamp |
| dss_update_time | TIMESTAMP_NTZ | NOT NULL | DW update timestamp |

#### Surrogate Key Generation

```sql
{{ dbt_utils.generate_surrogate_key([
    'class_type_bk',
    'source',
    'version_number'
]) }}
```

**Rationale**:
- Deterministic surrogate key based on natural key + version
- Enables idempotent reprocessing
- Compatible with dbt_utils package

#### Type 2 SCD Logic

```sql
-- Calculate effective dates
dss_start_date = load_datetime::DATE

dss_end_date = CASE
    WHEN LEAD(load_datetime) OVER (...) IS NULL
    THEN '2999-12-31'::DATE
    ELSE DATEADD(DAY, -1, LEAD(load_datetime::DATE) OVER (...))
END

dss_current_flag = CASE
    WHEN LEAD(load_datetime) OVER (...) IS NULL
    THEN 'Y'
    ELSE 'N'
END
```

**Rationale**:
- Use LEAD window function to get next version's start date
- End date is day before next version starts
- NULL in LEAD = current version (2999-12-31 end date)

#### Materialization Strategy

- **Type**: Table (full refresh)
- **Rationale**: Type 2 SCD requires full table rebuild to properly manage versions
- **Future Optimization**: Could implement incremental with snapshot strategy

---

## Transformation Logic

### Business Rule Implementations

#### Rule 1: Dual Eligible Flag

**Requirement**: Identify Medicare dual eligibility based on class code pattern

**Implementation**:
```sql
CASE
    WHEN class_bk IS NULL THEN 'No'
    WHEN class_bk = '' THEN 'No'
    WHEN SUBSTRING(class_bk, 1, 1) = 'M' THEN 'Yes'
    ELSE 'No'
END AS dual_eligible
```

**Test Cases**:
- NULL → 'No'
- '' → 'No'
- 'M123' → 'Yes'
- 'M' → 'Yes'
- 'X123' → 'No'
- '123M' → 'No'

#### Rule 2: On Exchange Flag

**Requirement**: Identify ACA marketplace participation with complex pattern matching

**Implementation**:
```sql
CASE
    WHEN class_bk IS NULL THEN 'No'
    WHEN class_bk = '' THEN 'No'
    WHEN group_id = '10030052' THEN 'No'
    WHEN SUBSTRING(class_bk, 1, 1) = 'X' THEN 'Yes'
    WHEN SUBSTRING(class_bk, 4, 1) = 'X' THEN 'Yes'
    ELSE 'No'
END AS on_exchange
```

**Test Cases**:
- NULL → 'No'
- '' → 'No'
- ('10030052', 'X123') → 'No' (explicit exclusion)
- ('10030053', 'X123') → 'Yes' (starts with X)
- ('10030053', '123X') → 'Yes' (X at position 4)
- ('10030053', '12X4') → 'Yes' (X at position 4)
- ('10030053', '1X34') → 'No' (X at position 2, not 4)
- ('10030053', 'M123') → 'No' (no X pattern)

**Edge Cases**:
- Class codes shorter than 4 characters: SUBSTRING returns NULL, evaluates to 'No'
- Multiple X characters: First matching condition wins ('Yes')

#### Rule 3: Description Lookup

**Requirement**: Get most recent class type description from reference table

**Implementation**:
```sql
-- CTE with QUALIFY
class_type_description AS (
    SELECT
        group_id,
        class_bk,
        source,
        description
    FROM r_class_type_assignment
    QUALIFY ROW_NUMBER() OVER (
        PARTITION BY group_id, class_bk, source
        ORDER BY effective_to DESC
    ) = 1
)

-- Join and default
COALESCE(ctd.description, '') AS class_type_description
```

**Alternatives Considered**:
1. **Correlated Subquery**: Slower, harder to read
2. **Self-Join with MAX()**: Two passes over data, more complex
3. **QUALIFY with ROW_NUMBER()**: ✓ Selected - Most efficient in Snowflake

#### Rule 4: Effective Date Defaulting

**Requirement**: Ensure valid date ranges for all records

**Implementation**:
```sql
COALESCE(effective_from, '2002-01-01'::DATE) AS effective_from_date,
COALESCE(effective_to, '2199-12-31'::DATE) AS effective_to_date
```

**Validation**:
```sql
-- Add check constraint (recommended)
CHECK (effective_from_date <= effective_to_date)
```

---

## Performance Considerations

### Query Optimization

#### Join Strategy

**Pattern**: Start with largest table, join to smaller dimensions
```sql
FROM source_group sg              -- Largest
INNER JOIN source_class sc        -- Medium
    ON sg.group_bk = sc.group_bk
LEFT JOIN source_system_lookup    -- Small (reference)
    ON sg.source = ssl.source
```

#### Incremental Processing

**Configuration**:
```yaml
config:
  materialized: 'incremental'
  incremental_strategy: 'delete+insert'
```

**Load Window**:
- Default: 1 hour overlap
- Configurable via `load_offset` variable
- Accounts for late-arriving data

**Performance Impact**:
- Initial load: Full table scan
- Incremental: Filter on load_datetime (should be indexed in source)
- Expected volume: ~1000 new/changed records per hour

### Snowflake-Specific Optimizations

#### Clustering

**Recommendation**: Cluster dimensional table on most common join/filter columns
```sql
ALTER TABLE dim_class_type CLUSTER BY (class_type_id, dss_current_flag);
```

**Rationale**:
- class_type_id: Primary join key from facts
- dss_current_flag: Frequent filter in queries

#### Warehouse Sizing

**Business Vault Models**:
- Warehouse: MEDIUM (recommended)
- Expected runtime: < 5 minutes incremental
- Expected runtime: < 30 minutes full refresh

**Dimensional Model**:
- Warehouse: MEDIUM (recommended)
- Expected runtime: < 10 minutes
- Full refresh only (Type 2 SCD)

---

## Data Quality Framework

### dbt Tests

#### Generic Tests (in yml)

**Hub (bv_h_class_type)**:
- `not_null`: class_type_hk, class_type_bk, record_source, load_datetime
- `unique`: class_type_hk

**Satellite (bv_s_class_type_business)**:
- `not_null`: class_type_hk, load_datetime, hashdiff
- `relationships`: class_type_hk → bv_h_class_type
- `accepted_values`: dual_eligible ['Yes', 'No'], on_exchange ['Yes', 'No']

**Dimension (dim_class_type)**:
- `not_null`: class_type_key, class_type_id, dss_current_flag
- `unique`: class_type_key
- `accepted_values`: dss_current_flag ['Y', 'N'], dual_eligible ['Yes', 'No', 'Unknown']

#### Custom Tests (recommended)

**Test: SCD Date Logic**
```sql
-- tests/assert_scd_dates_valid.sql
SELECT *
FROM {{ ref('dim_class_type') }}
WHERE dss_start_date > dss_end_date
```

**Test: Business Rule Validation**
```sql
-- tests/assert_dual_eligible_logic.sql
SELECT *
FROM {{ ref('bv_s_class_type_business') }}
WHERE (SUBSTRING(class_bk, 1, 1) = 'M' AND dual_eligible != 'Yes')
   OR (SUBSTRING(class_bk, 1, 1) != 'M' AND dual_eligible = 'Yes')
```

**Test: Row Count Reconciliation**
```sql
-- tests/assert_hub_satellite_counts.sql
WITH hub_count AS (
    SELECT COUNT(*) AS cnt FROM {{ ref('bv_h_class_type') }}
),
sat_count AS (
    SELECT COUNT(DISTINCT class_type_hk) AS cnt
    FROM {{ ref('bv_s_class_type_business') }}
)
SELECT * FROM hub_count h
CROSS JOIN sat_count s
WHERE h.cnt != s.cnt
```

### Data Quality Monitoring

#### Metrics to Track

1. **Record Counts**:
   - Hub: # unique class types
   - Satellite: # versions per class type
   - Dimension: # current versions

2. **Data Completeness**:
   - % records with descriptions
   - % records with default dates
   - % Unknown dimension usage

3. **Business Rule Distribution**:
   - % dual_eligible = 'Yes'
   - % on_exchange = 'Yes'
   - Distribution by source system

4. **Change Frequency**:
   - Avg versions per class type
   - # new class types per load
   - # changed class types per load

---

## Deployment Strategy

### Phase 1: Development Environment

1. **Setup**:
   - Create feature branch in dbt project
   - Add models to appropriate directories
   - Configure dbt_project.yml for new models

2. **Initial Testing**:
   ```bash
   dbt run --models bv_h_class_type
   dbt run --models bv_s_class_type_business
   dbt run --models dim_class_type
   dbt test --models class_type
   ```

3. **Validation**:
   - Compare row counts with EDW2
   - Spot check business rule calculations
   - Verify Type 2 SCD versioning

### Phase 2: Test Environment

1. **Deployment**:
   - Merge feature branch to develop
   - Deploy to test environment via CI/CD

2. **Validation**:
   - Full refresh from production raw vault
   - Run full test suite
   - Performance baseline testing

3. **Reconciliation**:
   - Build comparison queries EDW2 vs EDW3
   - Document and explain any variances
   - Get data steward sign-off

### Phase 3: Production Environment

1. **Pre-Deployment**:
   - Schedule maintenance window
   - Backup existing data
   - Prepare rollback plan

2. **Deployment**:
   - Full refresh of all models
   - Run complete test suite
   - Validate row counts and metrics

3. **Monitoring**:
   - Monitor first incremental load
   - Check data quality dashboards
   - Validate downstream consumers

### Phase 4: Cutover

1. **Parallel Run**:
   - Run EDW2 and EDW3 in parallel for 2 weeks
   - Compare results daily
   - Address any discrepancies

2. **Consumer Migration**:
   - Update fact tables to use new dimension
   - Update BI reports and dashboards
   - Update data extracts

3. **Decommission**:
   - Disable EDW2 stored procedures
   - Archive legacy code
   - Update documentation

---

## Appendix

### EDW2 vs EDW3 Feature Comparison

| Feature | EDW2 | EDW3 |
|---------|------|------|
| Platform | SQL Server | Snowflake |
| ETL Tool | Wherescape RED | dbt |
| Language | T-SQL | Snowflake SQL |
| Materialization | Stored Procedures | dbt Models |
| Staging Pattern | Physical Tables | CTEs |
| Hash Function | HASHBYTES('sha1') | SHA1_BINARY() |
| Change Detection | EXCEPT | NOT IN with WHERE |
| Incremental Logic | Truncate/Insert | Incremental Materialization |
| Window Functions | Limited | Full Support |
| Documentation | Wherescape Metadata | dbt yml + Markdown |
| Testing | Manual | dbt Tests |
| Version Control | Database Objects | Git |

### Performance Benchmarks

**Test Environment**: Snowflake MEDIUM warehouse, ~50K class type records

| Model | Initial Load | Incremental (100 changes) |
|-------|--------------|---------------------------|
| bv_h_class_type | 2 min | 5 sec |
| bv_s_class_type_business | 5 min | 15 sec |
| dim_class_type | 8 min | 8 min (full refresh) |

**Note**: Actual performance will vary based on data volume and warehouse size

---

**Document Version**: 1.0
**Last Updated**: 2025-10-12
**Review Date**: [TBD after initial implementation]
