# UC01: Data Vault Refactor - Use Case Context

## Use Case Overview

**Objective**: Refactor existing 3NF models in the Integration layer to Data Vault 2.0 methodology while maintaining business continuity through current views.

## Auto-Import Context Files
@docs\architecture\edp_platform_architecture.md
@docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md
@docs\use_cases\uc01_dv_refactor\examples\combined_member_cob_refactoring_example.md
@docs\engineering-knowledge-base\data-vault-2.0-guide.md

## Background Context

### Current State Challenge
- **Existing Implementation**: 3NF methodology in Snowflake Integration layer
- **Business Dependency**: Active downstream systems and reports depend on current structure
- **Migration Requirement**: Transition to Data Vault 2.0 for scalability and auditability
- **Continuity Need**: Maintain backward compatibility during transition period

### Strategic Approach
1. **Parallel Implementation**: Build Data Vault structures alongside existing 3NF models
2. **Current Views**: Create interfaces that can be used by the business vault
3. **Phased Migration**: Gradually transition downstream dependencies to Data Vault patterns
4. **Quality Assurance**: Validate data consistency between old and new models

## Implementation Strategy

### Phase 1: Analysis and Design
- **3NF Model Analysis**: Document existing table structures, relationships, and business logic
- **Entity Mapping**: Map 3NF entities to Data Vault hubs, links, and satellites
- **Business Key Strategy**: Identify stable business keys from existing primary/foreign key patterns

### Phase 2: Data Vault Implementation
- **Hub Creation**: Implement core business entities (members, providers, claims)
- **Link Development**: Model relationships between business entities
- **Satellite Design**: Store all descriptive attributes with full historization
- **Current Views**: Create interfaces that show all satellite columns

### Phase 3: Migration and Validation
- **Data Comparison**: Validate consistency between 3NF and Data Vault models
- **Performance Testing**: Ensure current views meet existing SLA requirements
- **Dependency Migration**: Update downstream systems to use current views
- **3NF Deprecation**: Remove original 3NF models once migration is complete

## Technical Implementation

### Source Analysis Requirements
Document for each 3NF table:
- **Table Purpose**: Business function and usage patterns
- **Key Relationships**: Primary keys, foreign keys, unique constraints
- **Data Patterns**: Update frequency, data volume, business rules
- **Downstream Dependencies**: Reports, extracts, other tables that reference

### Data Vault Mapping Strategy
```
3NF Table → Data Vault Structure:
- Primary Key columns → Hub business keys
- Foreign Key relationships → Links between hubs
- Descriptive attributes → Satellite payloads
- Audit columns → Data Vault metadata columns
```

### Current View Design Pattern
```sql
-- Example: Transform Data Vault back to 3NF-like structure
create or replace view current_member_table as
select
    h.member_business_key as member_id,
    s_demo.first_name,
    s_demo.last_name,
    s_demo.date_of_birth,
    s_elig.coverage_start_date,
    s_elig.coverage_end_date,
    h.load_datetime as record_created_date
from {{ ref('h_member') }} h
left join {{ ref('s_member_demographics') }} s_demo
    on h.member_hk = s_demo.member_hk
    and s_demo.load_datetime = (select max(load_datetime) from {{ ref('s_member_demographics') }} s2 where s2.member_hk = h.member_hk)
left join {{ ref('s_member_eligibility') }} s_elig
    on h.member_hk = s_elig.member_hk
    and s_elig.load_datetime = (select max(load_datetime) from {{ ref('s_member_eligibility') }} s2 where s2.member_hk = h.member_hk)
```

## Healthcare Domain Considerations

### Member Entity Refactoring
- **3NF Challenge**: Member demographics and eligibility often stored in single table
- **Data Vault Solution**: Separate satellites for demographics (low change) and eligibility (high change)
- **Current View**: Reconstruct full member profile from multiple satellites

### Provider Entity Refactoring
- **3NF Challenge**: Provider information mixed with contract and payment details
- **Data Vault Solution**: Provider hub with separate satellites for demographics, contracts, credentials
- **Current View**: Business-friendly provider directory interface

### Claims Entity Refactoring
- **3NF Challenge**: Claims header and line details in related tables with complex joins
- **Data Vault Solution**: Claim hub with links to procedures, providers, members
- **Current View**: Flattened claim structure for reporting compatibility

## Quality Assurance Framework

### Data Consistency Validation
- **Row Count Reconciliation**: Ensure Data Vault current views match 3NF table counts
- **Key Value Comparison**: Validate business key integrity across models
- **Aggregation Testing**: Compare summary metrics between old and new models
- **Performance Benchmarking**: Ensure current views meet existing query performance requirements

### Business Logic Preservation
- **Calculation Verification**: Ensure derived fields calculate identically
- **Business Rule Testing**: Validate constraints and validation logic
- **Historical Accuracy**: Confirm temporal data handling matches original patterns
- **Referential Integrity**: Test relationship consistency between entities

## Migration Timeline and Dependencies

### Critical Success Factors
1. **Stakeholder Communication**: Healthcare Economics and other power users understand transition
2. **Performance Maintenance**: No degradation in report or dashboard performance
3. **Data Quality**: Zero tolerance for data loss or corruption during transition
4. **Rollback Plan**: Ability to revert to 3NF models if issues arise

### Risk Mitigation
- **Parallel Running**: Maintain both models during transition period
- **Incremental Cutover**: Migrate dependencies one by one rather than big bang
- **Automated Testing**: Comprehensive test suite for ongoing validation
- **Documentation**: Clear mapping between old and new structures for troubleshooting

## Reference Files and Context

### Platform Integration
- **Main Project**: `../edp-data-domains/` - Target Data Vault implementation
- **Architecture Standards**: `../../../../../docs/architecture/edp_platform_architecture.md` - Naming conventions and patterns
- **Architecture Patterns**: `../../../../../docs/architecture/patterns/` - Raw Vault and Business Vault patterns
- **Legacy Context**: `../../../../../code/repositories/legacy_data_dictionary.csv` - Original system documentation

### Related Use Cases
- **UC02 EDW2 Refactor**: `../uc02_edw2_refactor/` - Parallel legacy system migration
- **Business Vault**: `../../../../../code/repositories/edp-data-domains/models/curation/biz_vault/` - Downstream business logic

## Success Metrics
- **Data Consistency**: 100% match between 3NF and Data Vault current views
- **Performance**: Current views perform within 10% of original 3NF query times
- **Adoption**: All downstream dependencies successfully migrated within planned timeline
- **Scalability**: New Data Vault structure supports planned future enhancements
