# Member Person Crosswalk - EDW2 to EDW3 Refactoring

## Overview
Refactored member-to-person constituent ID mapping from legacy SQL Server view to Snowflake dbt models following Data Vault 2.0 patterns.

**Legacy Source**: `HDSVault.biz.v_FacetsMemberUMI_current`
**EDW3 Models**: `br_member_person` (bridge), `v_member_person_lenient` (view)

## Architecture Pattern

### General-Purpose Bridge + Use Case-Specific Views

```
┌─────────────────────┐
│  current_member     │
│  current_person     │
│  current_subscriber │
│  current_group      │
└──────────┬──────────┘
           │
           ▼
┌─────────────────────────────┐
│  br_member_person           │  ◄─── General-purpose bridge
│  (Business Vault)           │       (No filtering, all person_id_types)
│  - Incremental load         │
│  - Includes person_id_type  │
└──────────┬──────────────────┘
           │
           ├─────────────────┬──────────────────┐
           ▼                 ▼                  ▼
  ┌──────────────────┐  ┌─────────────────┐  ┌──────────────────┐
  │ v_member_person_ │  │ v_member_person_│  │  Future use case │
  │ lenient          │  │ strict (future) │  │  specific views  │
  │                  │  │                 │  │                  │
  │ Filter: EXRM     │  │ Filter: TBD     │  │  Filter: TBD     │
  │ Use: Internal    │  │ Use: Portal     │  │                  │
  └──────────────────┘  └─────────────────┘  └──────────────────┘
```

## Files Generated

### Code
- **[br_member_person.sql](br_member_person.sql)** - Business vault bridge table (incremental)
- **[v_member_person_lenient.sql](v_member_person_lenient.sql)** - Lenient matching view for internal use

### Configuration
- **[br_member_person.yml](br_member_person.yml)** - dbt schema with tests and documentation

### Documentation
- **[member_person_business_rules.md](member_person_business_rules.md)** - Business rules documentation
- **[member_person_mapping.csv](../input/member_person/member_person_mapping.csv)** - Column mapping from EDW2 to EDW3

## Matching Strategies

### Lenient Matching (v_member_person_lenient)
- **person_id_type Filter**: EXRM (External Member) only
- **Use Cases**:
  - Internal reporting and analytics
  - Business partner data sharing
  - Cross-system constituent lookup for internal operations
  - Data quality and reconciliation processes

### Strict Matching (v_member_person_strict - future)
- **person_id_type Filter**: TBD based on operational requirements
- **Use Cases**:
  - Member portal person identification
  - External-facing applications
  - Operational systems requiring precise matching
  - Use cases where overmatching could expose incorrect data to members

## Key Business Rules

1. **Source Code Translation**:
   - Source '1' → 'gemstone_facets'
   - All others → 'legacy_facets'

2. **Proxy Subscriber Exclusion**:
   - Filter out subscriber_id LIKE 'PROXY%'

3. **Person ID Type Filtering**:
   - Bridge: No filtering (stores all types)
   - Lenient view: EXRM only
   - Strict view: TBD

4. **Join Conditions**:
   - Member ↔ Person: person_bk + source
   - Member ↔ Subscriber: subscriber_bk + source
   - Member ↔ Group: group_bk + source

## Migration Notes

### Removed from Legacy
- **dss_version**: Version numbers replaced by temporal ordering via timestamps

### Architecture Changes
1. **Single view** → **Bridge + multiple views** pattern
2. **Hardcoded filtering** → **Flexible, use case-specific filtering**
3. **Cross-database joins** → **Integrated raw vault**

## Testing

All tests defined in `br_member_person.yml`:
- Unique keys and surrogate keys
- Not null constraints on business keys
- Accepted values for source_code
- Referential integrity to current_person
- Warnings for missing person mappings

## Next Steps

1. **Business Review**: Review business rules documentation with membership operations and data stewards
2. **Define Strict Matching**: Determine filtering criteria for v_member_person_strict
3. **Approve Documentation**: Update status from "draft" to "active"
4. **File Documentation**: Move business rules to `docs/architecture/rules/membership/`
5. **Deploy**: Run dbt models in development environment
6. **Validate**: Compare output to legacy view
7. **Production**: Deploy to production after validation

## Questions for Stakeholders

See [member_person_business_rules.md](member_person_business_rules.md) "Questions for Review" section for specific questions requiring business input.
