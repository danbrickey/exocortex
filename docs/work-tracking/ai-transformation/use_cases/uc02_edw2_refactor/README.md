# Use Case 02: EDW2 to EDW3 Refactoring

**Status**: Active Development
**Last Updated**: 2025-10-12

---

## Overview

This use case automates the refactoring of legacy SQL Server-based dimensional models (EDW2/Wherescape) into dbt models for Snowflake (EDW3) using Data Vault 2.0 methodology.

### Purpose

Migrate dimensional models from the legacy on-premises EDW2 environment to the modern cloud-based EDW3 platform while:
- Preserving business logic and rules
- Improving code maintainability
- Implementing Data Vault 2.0 best practices
- Creating reusable Business Vault components
- Generating comprehensive documentation

---

## Folder Structure

```
uc02_edw2_refactor/
├── README.md (this file)
├── edw2_refactor_project_guidance.md    # Complete process guide
├── examples/                             # Example inputs and outputs
│   ├── input_example_edw2_refacor_dim_class_type_old_code.md
│   └── input_example_edw2_refacor_dim_class_type mappings.csv
└── output/                               # Generated artifacts
    └── class_type/                       # Completed example
        ├── DELIVERABLES.md
        ├── README.md
        ├── bv_h_class_type.sql
        ├── bv_s_class_type_business.sql
        ├── dim_class_type.sql
        ├── class_type_models.yml
        ├── class_type_business_rules.md
        ├── class_type_specification.md
        └── source_to_target_mapping.md
```

---

## Quick Start

### Prerequisites

1. Legacy EDW2 stored procedure code for the dimensional artifact
2. Column mapping from old raw vault to new raw vault (CSV format)
3. Access to architecture documentation

### Refactoring Process

See **[edw2_refactor_project_guidance.md](edw2_refactor_project_guidance.md)** for complete workflow.

**Summary Steps**:
1. Extract source table/column list from legacy code
2. Engineer creates mapping CSV (old → new raw vault)
3. AI validates mapping completeness
4. AI recommends Business Vault artifacts
5. AI generates dbt models (hub, satellite, dimension)
6. AI generates tests and documentation
7. Engineer reviews, tests, and deploys

---

## Completed Examples

### Class Type Dimension

**Status**: ✅ Complete (2025-10-12)
**Location**: [output/class_type/](output/class_type/)

**Legacy Components**:
- 4 stored procedures (ClassType_NonDV_01, ClassType_NonDV_02, dimClassType_NonDV, dimClassType_Base)
- ~300 lines of T-SQL
- Sequential execution with staging tables

**EDW3 Components**:
- 1 Business Vault Hub: `bv_h_class_type`
- 1 Business Vault Computed Satellite: `bv_s_class_type_business`
- 1 Dimensional Model: `dim_class_type`
- ~250 lines of Snowflake SQL with CTEs
- Parallel execution, incremental materialization

**Business Rules Applied**:
- Dual Eligible flag calculation (Medicare eligibility)
- On Exchange flag determination (ACA marketplace)
- Class type description lookup with effectivity
- Effective date defaulting

**Documentation Generated**:
- Technical specification (20 KB)
- Business rules documentation (12 KB)
- Source-to-target mapping (16 KB)
- dbt tests and column descriptions (8 KB)

**See**: [output/class_type/DELIVERABLES.md](output/class_type/DELIVERABLES.md) for complete details

---

## Key Patterns & Learnings

### Business Vault Pattern

**Legacy Pattern** (EDW2):
```
Stage Table 1 → Stage Table 2 → Controller → Dimension
```

**New Pattern** (EDW3):
```
Raw Vault → Business Vault (Hub + Computed Satellite) → Dimension
```

**Benefits**:
- Reusable business logic (Business Vault satellite can serve multiple consumers)
- Clear separation of concerns (business rules vs dimensional structure)
- Better performance (no intermediate staging tables)
- Easier to test and maintain

### Composite Business Key Pattern

When neither component alone uniquely identifies the entity:
- Create composite business key in Business Vault Hub
- Example: `rtrim(group_id) || ltrim(class_bk)` for Class Type
- Single hash key for the composite entity

### Computed Satellite Pattern

Consolidate multiple staging layers into one computed satellite:
- All business rules applied in satellite
- Description lookups handled with window functions (QUALIFY)
- Hash diff for change detection
- Incremental load with load_end_datetime

### Type 2 SCD Pattern

Dimension consumes Business Vault satellite:
- LEAD window function for next version detection
- dss_start_date, dss_end_date, dss_current_flag, dss_version
- Unknown record (key=0) for referential integrity
- Full refresh materialization (vs incremental in Business Vault)

---

## Documentation Standards

Each refactored entity should produce:

### Code Artifacts
1. **Business Vault Hub** (.sql) - Composite or simple business key
2. **Business Vault Satellite(s)** (.sql) - Computed satellite with business rules
3. **Dimensional Model** (.sql) - Type 2 SCD consuming Business Vault
4. **dbt Configuration** (.yml) - Tests, descriptions, configurations

### Documentation Artifacts
5. **Business Rules** (.md) - Natural language for business review
6. **Technical Specification** (.md) - Architecture and implementation details
7. **Source-to-Target Mapping** (.md) - Column-level mappings and reconciliation
8. **README** (.md) - Overview, deployment checklist, known issues
9. **DELIVERABLES Index** (.md) - Package inventory and status

---

## Testing Strategy

### Unit Tests (dbt)
- not_null on key columns
- unique on primary keys
- relationships between hub and satellites
- accepted_values for flag columns

### Integration Tests
- Row count reconciliation (EDW2 vs EDW3)
- Business rule validation (spot checks)
- Historical version comparison
- Performance benchmarking

### User Acceptance Testing
- Business validation of business rules
- Description accuracy review
- Edge case handling verification

---

## Deployment Workflow

1. **Dev Environment**
   - Deploy models
   - Run dbt tests
   - Spot check data

2. **Test Environment**
   - Full data refresh
   - Complete reconciliation with EDW2
   - User acceptance testing
   - Performance validation

3. **Production**
   - Parallel run with EDW2 (2 weeks recommended)
   - Monitor and compare results
   - Cutover downstream consumers
   - Decommission EDW2 artifacts

---

## Common Challenges & Solutions

### Challenge: Missing Raw Vault Objects

**Problem**: New raw vault structure differs significantly from EDW2
**Solution**: Create mapping CSV early, validate dependencies exist

### Challenge: Complex Business Rules Embedded in Multiple Layers

**Problem**: Logic scattered across 3-4 stored procedures
**Solution**: Consolidate into computed satellite, document clearly

### Challenge: Hard-coded Values

**Problem**: Magic numbers, specific IDs hard-coded in legacy SQL
**Solution**: Document rationale, consider parameterizing where appropriate

### Challenge: Different Hash Algorithms

**Problem**: HASHBYTES (SQL Server) vs SHA1_BINARY (Snowflake)
**Solution**: Normalize inputs (UPPER, TRIM), validate hashes produce same result

### Challenge: Type 2 SCD Logic Differences

**Problem**: EDW2 used EXCEPT operator, different version tracking
**Solution**: Use window functions (LEAD), maintain same SCD semantics

---

## Performance Considerations

### Incremental Loading
- Use 1-hour load window with overlap
- Filter on load_datetime (ensure indexed in source)
- Expected volume: 100-1000 changes per hour

### Warehouse Sizing
- Business Vault: MEDIUM recommended
- Dimensional: MEDIUM recommended
- Full refresh: 15-30 minutes typical

### Optimization Opportunities
- Cluster dimensional tables on join/filter columns
- Consider PIT tables for complex satellite joins
- Use QUALIFY instead of subqueries for Snowflake

---

## Future Enhancements

### Automation Opportunities
1. **Mapping Generation**: Analyze legacy code to suggest mappings automatically
2. **Business Rule Extraction**: Parse T-SQL CASE statements into natural language
3. **Test Generation**: Create custom dbt tests based on business rules
4. **Reconciliation Reports**: Automated EDW2 vs EDW3 comparison

### Pattern Library
- Build reusable templates for common patterns
- Create dbt macros for Business Vault patterns
- Standardize computed satellite structure

---

## Related Documentation

- **Architecture**: [../../architecture/edp_platform_architecture.md](../../architecture/edp_platform_architecture.md)
- **Data Vault Guide**: [../../engineering-knowledge-base/data-vault-2.0-guide.md](../../engineering-knowledge-base/data-vault-2.0-guide.md)
- **Layer Architecture**: [../../architecture/edp-layer-architecture-detailed.md](../../architecture/edp-layer-architecture-detailed.md)

---

## Contact & Support

**Data Architecture**: Dan Brickey
**Use Case Owner**: Dan Brickey
**Status**: Active - Accepting new refactoring requests

---

**Last Updated**: 2025-10-12
**Version**: 1.0
