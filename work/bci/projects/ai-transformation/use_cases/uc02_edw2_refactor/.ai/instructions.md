# UC02: EDW2 Refactor - Legacy WhereScape Migration Context

## Use Case Overview

**Objective**: Migrate legacy EDW2 WhereScape stored procedures from SQL Server to dbt models on Snowflake, integrating with the new Data Vault 2.0 architecture.

## Background Context

### Legacy System Profile
- **Source Platform**: WhereScape RED on SQL Server
- **Generated Code**: Stored procedures for ETL processing
- **Data Patterns**: Traditional dimensional modeling with some 3NF structures
- **Business Logic**: Complex transformations embedded in stored procedure logic
- **Timeline**: 7+ quarters of development with various team changes

### Migration Challenges
- **Code Generation Dependencies**: WhereScape-generated stored procedures require manual translation
- **Business Logic Extraction**: Complex transformations need to be understood and recreated
- **Performance Patterns**: SQL Server optimization techniques may not transfer directly to Snowflake
- **Data Volume**: Historical data must be preserved and integrated with ongoing operations

## Technical Migration Strategy

### WhereScape to dbt Translation Pattern

#### 1. Stored Procedure Analysis
```sql
-- WhereScape Pattern (SQL Server)
CREATE PROCEDURE dw_load_member_dim
AS
BEGIN
    -- Complex transformation logic
    -- Multiple temp tables and cursors
    -- Error handling and logging
END
```

#### 2. dbt Model Equivalent
```sql
-- dbt Pattern (Snowflake)
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='member_key'
) }}

with source_data as (
    select * from {{ ref('stg_member_legacy_facets') }}
),

transformed as (
    -- Business logic extraction
    -- CTE-based transformations
    -- Macro usage for reusable patterns
)

select * from transformed
```

### Business Logic Migration Approach

#### Extract Transformation Patterns
- **Data Cleansing**: Standardize address formatting, phone number parsing
- **Business Rules**: Member eligibility calculations, provider network assignments
- **Dimensional Logic**: SCD Type 2 handling, surrogate key generation
- **Aggregations**: Pre-calculated metrics and KPIs

#### Modernize for Data Vault Integration
- **Hub Integration**: Connect dimensional models to Data Vault hubs for master data
- **Historical Alignment**: Leverage Data Vault historization instead of SCD patterns
- **Business Vault**: Move complex business rules to Business Vault layer
- **Current Views**: Use Data Vault current views as dimensional model sources

## Healthcare Domain Migration Priorities

### Member Dimension Migration
- **Legacy Pattern**: Single member dimension with SCD Type 2
- **Target Pattern**: Data Vault hub with current view feeding simplified dimension
- **Business Logic**: Member status calculations, age banding, risk scoring
- **Integration Points**: Eligibility system feeds, demographic updates

### Provider Dimension Migration
- **Legacy Pattern**: Provider hierarchy with network assignments
- **Target Pattern**: Provider hub with network link relationships
- **Business Logic**: Credentialing status, specialty groupings, performance metrics
- **Integration Points**: Contracting system feeds, credentialing updates

### Claims Fact Migration
- **Legacy Pattern**: Fact table with pre-joined dimensional attributes
- **Target Pattern**: Streamlined fact with Data Vault current view lookups
- **Business Logic**: Claim adjudication rules, payment calculations, medical coding
- **Integration Points**: Claims processing system, payment system feeds

## Data Quality and Validation Framework

### Legacy Data Comparison
```sql
-- Validation pattern: Compare legacy vs new results
with legacy_summary as (
    select
        count(*) as legacy_row_count,
        sum(claim_amount) as legacy_total_amount
    from legacy_claims_fact
    where claim_date >= '2023-01-01'
),

new_summary as (
    select
        count(*) as new_row_count,
        sum(claim_amount) as new_total_amount
    from {{ ref('fact_claims') }}
    where claim_date >= '2023-01-01'
)

select
    l.legacy_row_count,
    n.new_row_count,
    l.legacy_total_amount,
    n.new_total_amount,
    abs(l.legacy_row_count - n.new_row_count) as row_count_diff,
    abs(l.legacy_total_amount - n.new_total_amount) as amount_diff
from legacy_summary l
cross join new_summary n
```

### Business Logic Validation
- **Calculation Accuracy**: Validate complex business rule implementations
- **Historical Consistency**: Ensure temporal calculations match legacy results
- **Performance Comparison**: Benchmark query performance against WhereScape jobs
- **Data Lineage**: Document transformation logic for audit and troubleshooting

## Integration with Data Vault Architecture

### Staging Layer Integration
```sql
-- Pattern: Use Data Vault staging as source for dimensional models
with member_current as (
    select * from {{ ref('current_member') }}
),

member_dimension as (
    select
        {{ dbt_utils.surrogate_key(['member_business_key']) }} as member_key,
        member_business_key as member_id,
        first_name,
        last_name,
        date_of_birth,
        -- Additional dimensional attributes
        effective_from_datetime,
        effective_to_datetime
    from member_current
)

select * from member_dimension
```

### Business Vault Dependencies
- **Calculated Fields**: Leverage Business Vault for complex member/provider metrics
- **Business Rules**: Use Business Vault satellites for eligibility and benefit logic
- **Derived Relationships**: Access Business Vault bridges for complex associations
- **Temporal Logic**: Utilize Point-in-Time tables for historical context

## Migration Workflow and Timeline

### Phase 1: Discovery and Analysis (2-3 weeks)
- **WhereScape Export**: Extract stored procedure definitions and job metadata
- **Business Logic Documentation**: Map transformation logic to business requirements
- **Data Lineage Analysis**: Understand source-to-target mappings
- **Performance Baseline**: Document current job run times and resource usage

### Phase 2: Foundation Implementation (4-6 weeks)
- **Staging Models**: Create dbt staging layer for legacy source systems
- **Core Transformations**: Implement critical business logic transformations
- **Dimensional Models**: Build key dimensions and fact tables
- **Validation Framework**: Implement automated comparison testing

### Phase 3: Integration and Optimization (3-4 weeks)
- **Data Vault Integration**: Connect dimensional models to Data Vault current views
- **Performance Tuning**: Optimize for Snowflake platform capabilities
- **Business Rule Migration**: Move complex logic to Business Vault layer
- **End-to-End Testing**: Validate complete data flow from source to consumption

### Phase 4: Cutover and Monitoring (2-3 weeks)
- **Parallel Processing**: Run both legacy and new systems during validation
- **Stakeholder Training**: Prepare business users for new model structure
- **Monitoring Setup**: Implement ongoing data quality and performance monitoring
- **Legacy Decommission**: Retire WhereScape jobs once validation is complete

## Risk Management and Contingency

### Technical Risks
- **Business Logic Gaps**: Complex WhereScape logic difficult to recreate in dbt
- **Performance Issues**: Snowflake optimization differs from SQL Server patterns
- **Data Quality**: Legacy data quality issues may surface during migration
- **Integration Complexity**: Data Vault integration adds architectural complexity

### Mitigation Strategies
- **Incremental Migration**: Migrate subject areas one at a time
- **Business User Involvement**: Validate business logic with domain experts
- **Performance Testing**: Benchmark all critical queries and reports
- **Rollback Capability**: Maintain legacy system ability for emergency fallback

## Reference Files and Integration Points

### Legacy Context
- **WhereScape Exports**: `../../legacy/wherescape_exports/` - Original stored procedures
- **Legacy Dictionary**: `../../../../../code/repositories/legacy_data_dictionary.csv` - Business context for source data
- **Migration Analysis**: `../../analysis/source_analysis/` - Transformation mapping

### Target Integration
- **Data Vault Foundation**: `../../../../../code/repositories/edp-data-domains/models/integration/` - Source data structures
- **Business Vault**: `../../../../../code/repositories/edp-data-domains/models/curation/biz_vault/` - Business logic layer
- **Architecture Patterns**: `../../../../../docs/architecture/patterns/` - Raw Vault and Business Vault patterns
- **Platform Standards**: `../../../../../docs/architecture/edp_platform_architecture.md` - Technical conventions

### Related Use Cases
- **UC01 DV Refactor**: `../uc01_dv_refactor/` - Parallel 3NF to Data Vault migration
- **Consumption Models**: `../../../../../code/repositories/edp-data-domains/models/consumption/` - Final reporting layer

## Success Criteria
- **Functional Equivalence**: All legacy reports and extracts function identically
- **Performance Standards**: New models meet or exceed legacy system performance
- **Business Logic Accuracy**: Complex calculations produce identical results
- **Data Quality**: No degradation in data accuracy or completeness
- **Maintainability**: dbt models are easier to maintain than WhereScape procedures
