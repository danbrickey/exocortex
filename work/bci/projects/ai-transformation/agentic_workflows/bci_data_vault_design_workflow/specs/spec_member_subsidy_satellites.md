## Member 360: Build Raw Vault member_subsidy Satellites

**Title:**

**Member 360: Build Raw Vault member_subsidy Satellites**

**Description:**

As a data engineer,  
I want to create the member_subsidy satellites in the raw vault,  
So that we can track member exchange enrollment and subsidy information changes over time including APTC indicators, exchange IDs, and enrollment methods for Member Months analytics.

**Acceptance Criteria:**

Given the member hub (h_member) exists with loaded member records,  
when the member subsidy satellite models execute,  
then all member subsidy records are loaded with valid member hub hash keys and load timestamps.

Given multiple source records exist for the same member over time,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the member subsidy satellites are loaded,  
when the satellites are compared to the source staging models,  
then the record counts match.

Given the member subsidy satellites reference the member hub,  
when referential integrity checks run,  
then all member_hk values in the satellites exist in h_member.

### Technical Details

#### Business Key

**Type:** Business Key

Business key inherited from parent hub h_member:

```sql
-- Business key columns (inherited from h_member)
subscriber_id,
member_suffix
```

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_mees_exchange` - Member enrollment source/exchange data from Gemstone system
- `stg_legacy_bcifacets_hist__dbo_cmc_mees_exchange` - Member enrollment source/exchange data from Legacy system
- `stg_gemstone_facets_hist__dbo_cmc_meme_member` - Member data for join to get member hub key
- `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc` - Subscriber data for join to get member hub key

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_member_subsidy_gemstone_facets_rename - Rename columns for gemstone facets
- stg_member_subsidy_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example join to get member hub key for member subsidy satellites
source as (
    select
        -- Business Key Expressions
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        -- Subsidy attributes
        mees.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_mees_exchange') }} mees
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on mees.meme_ck = mem.meme_ck
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on mem.sbsb_ck = sbsb.sbsb_ck
)
```

**Staging Views**:

- stg_member_subsidy_gemstone_facets - Stage data from cmc_mees_exchange for gemstone facets
- stg_member_subsidy_legacy_facets - Stage data from cmc_mees_exchange for legacy facets

**Satellites** (using automate_dv sat macro):

- s_member_subsidy_gemstone_facets - Descriptive attributes from Gemstone system
- s_member_subsidy_legacy_facets - Descriptive attributes from legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| cmc_mees_exchange | meme_ck | member_bk | Member Contrived Key |
| cmc_mees_exchange | cspd_cat | product_category | Class Product Category |
| cmc_mees_exchange | mees_eff_dt | exchange_eff_dt | Exchange Enrollment Effective Date |
| cmc_mees_exchange | mees_term_dt | exchange_term_dt | Exchange Enrollment Termination Date |
| cmc_mees_exchange | grgr_ck | employer_group_bk | Group Contrived Key |
| cmc_mees_exchange | mees_channel | exchange_channel | Exchange Channel ID |
| cmc_mees_exchange | mees_exchange | exchange_id | Exchange ID |
| cmc_mees_exchange | mees_mctr_meth | enrollment_method | Enrollment Method |
| cmc_mees_exchange | mees_aptc_ind | aptc_indicator | Advanced Premium Tax Credit Indicator |
| cmc_mees_exchange | mees_lock_token | lock_token | Lock Token |
| cmc_mees_exchange | atxr_source_id | attachment_source_id | Attachment Source ID |
| cmc_mees_exchange | sys_last_upd_dtm | system_last_update_dtm | System Last Update Datetime |
| cmc_mees_exchange | sys_usus_id | system_user_id | System User ID |
| cmc_mees_exchange | sys_dbuser_id | system_dbuser_id | System DBMS User ID |
| cmc_mees_exchange | mees_qhp_id_nvl | qualified_health_plan_id | Qualified Health Plan ID |
| cmc_mees_exchange | mees_mem_id_nvl | exchange_member_id | Exchange Assigned Member ID |
| cmc_mees_exchange | mees_policy_id_nvl | exchange_policy_id | Exchange Policy ID |

**Metadata:**

- Deliverables: Member Months
- Dependencies: h_member hub must exist

---

## Specification Evaluation Report

### Evaluation Date: 2025-01-28

### Recommendations

- Specification is complete and ready for handoff. All required information is present.

### Overall Completeness Score: 100%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- Title & Description: Title includes Domain (Member) and Entity (member_subsidy). Description accurately reflects objects being built (satellites only).
- Business Key: Type clearly labeled (Business Key). SQL expression provided with individual columns listed (correct format for automate_dv). Business key inheritance from parent hub clearly documented.
- Source Models: All source models listed with full project and model names. Source project specified. All models referenced in join example are listed.
- Rename Views: All rename views listed. Complex joins exist and staging join example provided.
- Staging Views: All staging views listed with source table references.
- Hubs/Links/Satellites: All objects match description. Naming conventions followed (s_ prefix). No hubs or links for this satellite-only spec.
- Same-As Links: Not applicable for this specification (satellites only, no identity resolution needed).
- Column Mapping: Source Column Mapping table includes all columns referenced in business key expressions and staging join example. All 17 columns from cmc_mees_exchange are mapped.
- Acceptance Criteria: All criteria are specific, testable, and reference actual objects being built (satellites and parent hub).
- Metadata: Deliverables listed. Dependencies identified (h_member hub must exist).

**Failed:** 0 / 10
- None

### Quality Checks

**Passed:** 6 / 6
- Join Logic Documentation: Staging join example includes multiple tables (cmc_mees_exchange, cmc_meme_member, cmc_sbsb_subsc) and example is provided and complete with join conditions.
- Column Mapping Completeness: Every column in the staging join example appears in the Source Column Mapping table with correct source_table reference, source_column name, appropriate target_column name, and descriptive column_description.
- No Placeholders: All [bracketed placeholders] have been replaced with actual values.
- Consistency: Description objects match Technical Details objects (satellites). Entity name (member_subsidy) used consistently throughout.
- Naming Conventions: All model names follow BCI conventions (stg_, s_ prefixes).
- Actionability: An engineer can implement without additional clarification:
  - Source models are identifiable (full paths provided)
  - Business key logic is executable (inherited from parent hub, columns clearly listed)
  - Column mappings are clear (complete mapping table)
  - Join logic is documented (complete example provided)

**Failed:** 0 / 6
- None

### Data Vault 2.0 Pattern Validation

**Passed:** 8 / 8
- Hub Appropriateness: Not applicable - this is a satellite-only specification referencing existing h_member hub.
- Satellite vs Reference Table: Satellites are appropriately used for descriptive attributes that change over time (exchange enrollment data, effective dates, APTC indicators, enrollment methods) and need historization. This is not static lookup data.
- Link Appropriateness: Not applicable - no links in this specification.
- Business Key Granularity: Business key represents the correct level of detail (member level, inherited from parent hub).
- Satellite Rate of Change: Exchange enrollment data has moderate rate of change (effective dates, enrollment method changes, APTC indicator updates) which is appropriate for standard satellites. No need for hroc/mroc/lroc split.
- Same-As Link Logic: Not applicable - no same-as links in this specification.
- Hub Scope: Not applicable - satellites reference existing h_member hub.
- No Over-Engineering: Appropriate use of satellites for time-varying exchange enrollment and subsidy attributes. Not over-engineered.

**Anti-Patterns Identified:**
- None identified. All artifacts follow Data Vault 2.0 best practices.

### Red Flags (Critical Issues)

- None identified.

**Data Vault 2.0 Pattern Violations:**
- None identified.

### Implementation Blockers

These issues would prevent a data engineer or AI from implementing this specification:

- None identified. Specification is complete and actionable.

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_mees_exchange`, `stg_legacy_bcifacets_hist__dbo_cmc_mees_exchange`, `stg_gemstone_facets_hist__dbo_cmc_meme_member`, `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`

2. **Can an engineer write the business key expression?** Yes - Business key is clearly documented as inherited from h_member with columns `subscriber_id` and `member_suffix` listed individually (correct format for automate_dv)

3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided with all tables, aliases, join conditions, and column selections

4. **Can an engineer map all columns from the Source Column Mapping table?** Yes - Complete mapping table includes all columns from the join example with source_table, source_column, target_column, and column_description. All 17 columns from cmc_mees_exchange are mapped.

5. **Can an engineer implement all objects without questions?** Yes - All objects (rename views, staging views, satellites) are clearly defined with naming conventions and source references

6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable Given/When/Then statements that reference actual objects and can be validated

### Next Steps

**Specification is ready for handoff to data engineering team.**

All critical issues have been resolved:
- ✅ Source model names are consistent and complete
- ✅ All columns from cmc_mees_exchange are included in mapping table
- ✅ Join logic is documented with complete example
- ✅ Business key inheritance from parent hub is clearly documented
- ✅ Acceptance criteria are testable and specific
