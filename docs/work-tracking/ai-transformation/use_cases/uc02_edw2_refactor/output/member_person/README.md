# Member Person Refactor

## Overview

This directory contains the refactored member_person entity models for the EDW3 (Enterprise Data Warehouse 3) migration. The legacy `v_FacetsMemberUMI_current` view has been decomposed into a modern data vault architecture with business vault and dimensional models.

## Legacy Source

- **Database**: HDSVault
- **Schema**: biz
- **View**: v_FacetsMemberUMI_current
- **Purpose**: Member person demographics with external constituent ID and relationship data

## Refactored Architecture

### Data Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                         Raw Vault Layer                          │
│  - rv_sat_member_current                                         │
│  - rv_sat_person_current                                         │
│  - rv_sat_subscriber_current                                     │
│  - rv_sat_group_current                                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Prep Layer (Business Rules)                   │
│  prep_member_person.sql                                          │
│  - Applies joins and filters                                     │
│  - Implements source code mapping                                │
│  - Excludes proxy subscribers                                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Staging Layer (Hash Generation)               │
│  stg_member_person_business.sql                                  │
│  - Generates hash keys (member_person_hk)                        │
│  - Generates hashdiff for change detection                       │
│  - Prepares metadata columns                                     │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│              Business Vault Layer (Computed Satellite)           │
│  bv_s_member_person.sql                                          │
│  - Type 2 SCD satellite                                          │
│  - Tracks historical changes                                     │
│  - Incremental loading with automate_dv                          │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Dimensional Layer (Reporting)                 │
│  dim_member_person.sql                                           │
│  - Type 2 SCD dimension                                          │
│  - Denormalized for reporting                                    │
│  - Includes derived attributes (age, full name)                  │
│  - Temporal tracking with effective_from/to                      │
└─────────────────────────────────────────────────────────────────┘
```

## Files in This Directory

### SQL Models

1. **[prep_member_person.sql](prep_member_person.sql)**
   - **Type**: View
   - **Layer**: Prep
   - **Purpose**: Applies business rules and joins from legacy view
   - **Key Functions**:
     - Joins member, person, subscriber, and group tables
     - Maps source codes (GEM/FCT)
     - Filters proxy subscribers
     - Validates source consistency

2. **[stg_member_person_business.sql](stg_member_person_business.sql)**
   - **Type**: View
   - **Layer**: Staging
   - **Purpose**: Generates hash keys and hashdiff for business vault
   - **Key Functions**:
     - Creates `member_person_hk` (parent hash key)
     - Creates `member_person_hashdiff` (change detection)
     - Uses automate_dv macros

3. **[bv_s_member_person.sql](bv_s_member_person.sql)**
   - **Type**: Incremental Table
   - **Layer**: Business Vault
   - **Purpose**: Computed satellite with enriched member person data
   - **Key Functions**:
     - Incremental loading with hash-based change detection
     - Type 2 SCD tracking
     - Stores all payload attributes

4. **[dim_member_person.sql](dim_member_person.sql)**
   - **Type**: Table
   - **Layer**: Dimensional
   - **Purpose**: Reporting dimension with member person demographics
   - **Key Functions**:
     - Type 2 SCD with effective_from/to dates
     - Derived attributes (age, full name)
     - Default values for NULLs
     - Surrogate key generation

### Configuration Files

5. **[member_person.yml](member_person.yml)**
   - dbt model configuration
   - Column descriptions
   - Data quality tests
   - Relationships and constraints

### Documentation

6. **[member_person_business_rules.md](member_person_business_rules.md)**
   - Detailed business rules documentation
   - Rule implementation references
   - Data quality specifications
   - Change history

7. **[README.md](README.md)** (this file)
   - Project overview
   - Architecture documentation
   - Usage instructions

## Key Business Rules

### BR-MP-001: Source Code Mapping
- `source_id = 1` → `source_code = 'GEM'`
- All other source_ids → `source_code = 'FCT'`

### BR-MP-002: External Person ID Filtering
- Only include person records where `person_id_type = 'EXRM'`

### BR-MP-003: Proxy Subscriber Exclusion
- Exclude records where `subscriber_id LIKE 'PROXY%'`

### BR-MP-004: Source Consistency Validation
- Member source must match person source (via source_id mapping)
- Member source must match subscriber source
- Member source must match group source

### BR-MP-005: Required Relationships
- Members MUST have a subscriber (INNER JOIN)
- Members MUST have a group (INNER JOIN)
- Members MAY have an external person ID (LEFT JOIN)

See [member_person_business_rules.md](member_person_business_rules.md) for complete documentation.

## Data Quality Tests

### Prep Layer Tests
- ✓ member_bk is NOT NULL and UNIQUE
- ✓ member_first_name is NOT NULL
- ✓ member_last_name is NOT NULL
- ✓ member_birth_dt is NOT NULL
- ✓ member_sex is valid code ('M', 'F', 'U', 'O')
- ✓ source_code is valid ('GEM', 'FCT')

### Business Vault Tests
- ✓ member_person_hk is NOT NULL
- ✓ member_person_hashdiff is NOT NULL
- ✓ No duplicate records (hk + load_datetime unique)

### Dimensional Layer Tests
- ✓ member_person_sk is UNIQUE
- ✓ Only one current record per member
- ✓ No overlapping effective date ranges
- ✓ All required fields have valid defaults

## Usage

### Building the Models

```bash
# Build all member_person models
dbt build --select member_person

# Build specific layers
dbt build --select tag:prep
dbt build --select tag:business_vault
dbt build --select tag:dimensional

# Run tests only
dbt test --select member_person
```

### Querying Current Member Person Data

```sql
-- Get current member person records
SELECT *
FROM dim_member_person
WHERE is_current = true;
```

### Point-in-Time Query

```sql
-- Get member person data as of specific date
SELECT *
FROM dim_member_person
WHERE member_bk = '<member_key>'
  AND effective_from <= '2024-01-01'
  AND effective_to > '2024-01-01';
```

### Historical Changes

```sql
-- View all historical versions for a member
SELECT
    member_bk,
    member_first_name,
    member_last_name,
    effective_from,
    effective_to,
    is_current
FROM dim_member_person
WHERE member_bk = '<member_key>'
ORDER BY effective_from;
```

## Migration Notes

### Changes from Legacy

1. **Architecture**:
   - Legacy: Single view with joins
   - New: Layered architecture (prep → staging → business vault → dimensional)

2. **History Tracking**:
   - Legacy: Current records only (snapshot)
   - New: Full Type 2 SCD history in satellite and dimension

3. **Data Quality**:
   - Legacy: Limited validation
   - New: Comprehensive dbt tests at all layers

4. **Performance**:
   - Legacy: View with joins executed at query time
   - New: Materialized tables with incremental loading

### Breaking Changes

- Column names updated to standardized naming convention (see mapping CSV)
- dss_* columns renamed to edp_* prefix
- dss_version column removed (version tracking now handled by satellite)
- NULL handling improved with default values in dimensional layer

### Backward Compatibility

For backward compatibility, you can create a view that mimics the legacy structure:

```sql
CREATE VIEW biz.v_FacetsMemberUMI_current AS
SELECT
    constituent_id AS ConstituentID,
    member_bk AS meme_ck,
    group_id AS grgr_id,
    subscriber_id AS sbsb_id,
    member_suffix AS meme_sfx,
    member_first_name AS FirstName,
    member_last_name AS LastName,
    member_sex AS Gender,
    member_birth_dt AS BirthDate,
    member_ssn AS SSN,
    source_code AS SourceCode,
    record_source AS dss_record_source,
    load_datetime AS dss_load_date,
    effective_from AS dss_start_date,
    -- dss_version not available in new architecture
    load_datetime AS dss_create_time
FROM dim_member_person
WHERE is_current = true;
```

## Dependencies

### dbt Packages Required
- `dbt-labs/dbt_utils`
- `Datavault-UK/automate_dv`
- `calogica/dbt_expectations` (optional, for advanced tests)

### Upstream Dependencies
- `rv_sat_member_current` (raw vault satellite)
- `rv_sat_person_current` (raw vault satellite)
- `rv_sat_subscriber_current` (raw vault satellite)
- `rv_sat_group_current` (raw vault satellite)

### Downstream Consumers
- Reporting dashboards
- Analytics applications
- Data exports
- API services

## Related Documentation

- [Project Guidance](../../edw2_refactor_project_guidance.md)
- [Input Mapping](../../input/member_person/member_person_mapping.csv)
- [Business Rules](member_person_business_rules.md)

## Support

For questions or issues with this refactor:
1. Review the business rules documentation
2. Check dbt test results for data quality issues
3. Consult the project guidance document
4. Contact the data engineering team

## Version History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-27 | AI Refactor | Initial EDW3 refactor of member_person entity |

---

**Generated by**: EDW2 → EDW3 Refactor Process
**Legacy Source**: HDSVault.biz.v_FacetsMemberUMI_current
**Target Architecture**: Data Vault 2.0 with dbt + automate_dv
