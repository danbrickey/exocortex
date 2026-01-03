# Class Type - EDW2 to EDW3 Refactoring Output

**Entity**: Class Type (Group + Class Combination)
**Refactoring Date**: 2025-10-12
**Status**: Generated - Pending Review

---

## Overview

This folder contains the refactored dbt models and documentation for the Class Type dimension, migrated from legacy EDW2 (Wherescape SQL Server) to EDW3 (dbt + Snowflake + Data Vault 2.0).

The legacy implementation used 4 stored procedures executing sequentially:
1. **ClassType_NonDV_01**: Initial raw vault data integration
2. **ClassType_NonDV_02**: Business rule application (DualEligible, OnExchange flags)
3. **dimClassType_NonDV**: Hash key generation and change detection
4. **dimClassType_Base**: Type 2 SCD dimension maintenance

The new EDW3 implementation consolidates this into 3 dbt models organized by architectural layer:
1. **Business Vault Hub**: bv_h_class_type
2. **Business Vault Computed Satellite**: bv_s_class_type_business
3. **Dimensional Model**: dim_class_type

---

## Files Generated

### dbt Models

| File | Type | Layer | Description |
|------|------|-------|-------------|
| [bv_h_class_type.sql](bv_h_class_type.sql) | Hub | Business Vault | Hub for Class Type business entity with composite business key |
| [bv_s_class_type_business.sql](bv_s_class_type_business.sql) | Satellite | Business Vault | Computed satellite applying all business rules |
| [dim_class_type.sql](dim_class_type.sql) | Dimension | Dimensional | Type 2 SCD dimension for analytics |

### Documentation

| File | Purpose |
|------|---------|
| [class_type_models.yml](class_type_models.yml) | dbt model documentation with column descriptions and tests |
| [class_type_business_rules.md](class_type_business_rules.md) | Business rule documentation for data stewards |
| [class_type_specification.md](class_type_specification.md) | Technical specification and architecture notes |
| [README.md](README.md) | This file - project overview |

---

## Architecture Pattern

### Data Flow

```
Raw Vault (Integration Layer)
    ↓
    ├─ current_group (view of group hub + satellites)
    ├─ current_class_group (view of class hub + satellites)
    ├─ r_source_system (reference)
    └─ r_class_type_assignment (reference)
    ↓
Business Vault (Curation Layer)
    ↓
    ├─ bv_h_class_type (hub)
    └─ bv_s_class_type_business (computed satellite)
    ↓
Dimensional Model (Curation Layer)
    ↓
    └─ dim_class_type (Type 2 SCD dimension)
    ↓
Consumption Layer
    └─ Used by fact tables and analytics
```

### Business Vault Pattern

The Business Vault implements a **computed satellite pattern**:
- **Parent Hub**: bv_h_class_type with composite business key (group_id + class_bk)
- **Computed Satellite**: bv_s_class_type_business applies business rules:
  - DualEligible flag calculation
  - OnExchange flag determination
  - Description lookup with effectivity logic
  - Default date handling

### Dimensional Pattern

The dimension implements **Type 2 Slowly Changing Dimension**:
- Full history maintained with version numbers
- `dss_current_flag` identifies active versions
- `dss_start_date` and `dss_end_date` track validity periods
- Unknown record (key=0) for referential integrity

---

## Business Rules Applied

### 1. Dual Eligible Flag
- **Logic**: 'Yes' if class_bk starts with 'M', else 'No'
- **Purpose**: Identify Medicare dual eligibility
- **Source**: Coding convention in class identifier

### 2. On Exchange Flag
- **Logic**: Complex pattern matching on class_bk and group_id
- **Purpose**: Identify ACA marketplace coverage
- **Special Cases**: Group 10030052 always 'No'

### 3. Class Type Description
- **Logic**: Lookup from reference with max(effective_to) selection
- **Purpose**: Provide business description
- **Default**: Empty string if not found

### 4. Effective Date Defaulting
- **From Date**: Defaults to 2002-01-01
- **To Date**: Defaults to 2199-12-31
- **Purpose**: Ensure valid temporal ranges

---

## Source Data Mapping

### Legacy EDW2 → EDW3 Mappings

| EDW2 Table | EDW3 Table | Join Condition |
|------------|------------|----------------|
| v_group_combined_current | current_group | Direct replacement |
| v_groupclass_combined_current | current_class_group | Direct replacement |
| v_r_SourceBKCCLookup | r_source_system | Direct replacement |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | Consolidated view |
| v_s_classtypedescription_mroc_bcidaho_current | r_class_type_assignment | Merged with assignments |

**Key Change**: The separate description table has been consolidated into the assignment reference table in EDW3 for simpler joins.

---

## Testing Strategy

### Unit Tests (in class_type_models.yml)

**Business Vault Hub (bv_h_class_type)**:
- Primary key uniqueness (class_type_hk)
- Business key not null
- Load timestamp not null

**Business Vault Satellite (bv_s_class_type_business)**:
- Foreign key to parent hub
- Hashdiff not null
- Flag accepted values (dual_eligible, on_exchange)
- Effective date not null

**Dimension (dim_class_type)**:
- Surrogate key uniqueness (class_type_key)
- Current flag values ('Y' or 'N')
- SCD date logic (start <= end)
- Row count reconciliation with satellite

### Integration Tests (Recommended)

1. **Business Rule Validation**:
   - Verify 'M' prefix → dual_eligible = 'Yes'
   - Verify 'X' patterns → on_exchange = 'Yes'
   - Verify group 10030052 → on_exchange = 'No'

2. **Historical Accuracy**:
   - Compare row counts: EDW2 dimClassType_base vs. EDW3 dim_class_type
   - Validate version increments match change history
   - Verify Unknown record (key=0) exists

3. **Data Quality**:
   - Check for null business keys
   - Validate effective date ranges
   - Identify records with missing descriptions

---

## Deployment Checklist

- [ ] Review business rule logic with domain experts
- [ ] Validate source table mappings are correct
- [ ] Confirm r_class_type_assignment structure matches assumptions
- [ ] Run dbt compile to check for syntax errors
- [ ] Execute in dev environment with sample data
- [ ] Compare row counts with legacy EDW2 tables
- [ ] Validate business rule calculations with spot checks
- [ ] Review test results from dbt test
- [ ] Get sign-off from data steward
- [ ] Deploy to test environment
- [ ] Run user acceptance testing
- [ ] Deploy to production

---

## Dependencies

### Upstream Models (must exist)
- `current_group` - Raw vault current view for groups
- `current_class_group` - Raw vault current view for classes
- `r_source_system` - Reference table for source systems
- `r_class_type_assignment` - Reference for class type assignments

### dbt Packages Required
- `dbt-utils` (for generate_surrogate_key macro)
- Standard dbt-snowflake adapter

---

## Known Issues / Considerations

1. **Description Consolidation**: The EDW3 design assumes descriptions are in the assignment reference. Verify this matches actual implementation.

2. **Incremental Strategy**: Models use incremental materialization with load_datetime filtering. Initial full refresh required.

3. **Group 10030052**: Hard-coded exclusion in on_exchange logic. Confirm with business this remains valid.

4. **Effective Date Defaults**: 2002-01-01 and 2199-12-31 defaults may need adjustment based on business requirements.

5. **Hash Key Generation**: Using SHA1 binary for hash keys. Verify this aligns with platform standards.

---

## Rollback Plan

If issues are discovered post-deployment:

1. **Immediate**: Switch downstream consumers back to legacy EDW2 views
2. **Investigation**: Analyze discrepancies between EDW2 and EDW3 results
3. **Fix**: Update dbt models and re-test
4. **Re-deploy**: Follow deployment checklist again

---

## Support Contacts

- **Data Architecture**: Dan Brickey
- **EDW2 Subject Matter Expert**: [TBD]
- **Business Data Steward**: [TBD]

---

## Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-10-12 | 1.0 | AI-Generated | Initial refactoring from EDW2 to EDW3 |

---

**Next Steps**: Review all generated files, validate business rules with domain experts, and begin testing in dev environment.
