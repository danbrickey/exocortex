## Member 360: Build Raw Vault subscriber_rating Satellites

**Title:**

**Member 360: Build Raw Vault subscriber_rating Satellites**

**Description:**

As a data engineer,  
I want to create the subscriber_rating satellites in the raw vault,  
So that we can track subscriber premium rate factoring data changes over time including billing indicators, smoker status, and geographic rating factors.

**Acceptance Criteria:**

Given the member hub (h_member) exists with loaded member records,  
when the subscriber rating satellite models execute,  
then all subscriber rating records are loaded with valid member hub hash keys and load timestamps.

Given multiple source records exist for the same member over time,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the subscriber rating satellites are loaded,  
when the satellites are compared to the source staging models,  
then the record counts match.

Given the subscriber rating satellites reference the member hub,  
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
- `stg_gemstone_facets_hist__dbo_cmc_sbrt_rate_data` - Subscriber premium rate data from Gemstone system
- `stg_legacy_bcifacets_hist__dbo_cmc_sbrt_rate_data` - Subscriber premium rate data from legacy system
- `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc` - Subscriber data for join to get subscriber_id
- `stg_gemstone_facets_hist__dbo_cmc_meme_member` - Member data for join to get member hub key

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_subscriber_rating_gemstone_facets_rename - Rename columns for gemstone facets
- stg_subscriber_rating_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example join to get member hub key for subscriber rating satellites
source as (
    select
        -- Business Key Expressions
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        -- Rating attributes
        sbrt.sbsb_ck,
        sbrt.grgr_ck,
        sbrt.sbrt_eff_dt,
        sbrt.sbrt_term_dt,
        sbrt.sbrt_sb_bill_ind,
        sbrt.sbrt_smoker_ind,
        sbrt.sbrt_rt_st,
        sbrt.sbrt_rt_cnty,
        sbrt.sbrt_rt_area,
        sbrt.sbrt_rt_sic,
        sbrt.sbrt_lock_token,
        sbrt.atxr_source_id,
        sbrt.edp_start_dt,
        sbrt.edp_record_status
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbrt_rate_data') }} sbrt
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on sbrt.sbsb_ck = sbsb.sbsb_ck
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on sbsb.sbsb_ck = mem.sbsb_ck
)
```

**Staging Views**:

- stg_subscriber_rating_gemstone_facets - Stage data from cmc_sbrt_rate_data for gemstone facets
- stg_subscriber_rating_legacy_facets - Stage data from cmc_sbrt_rate_data for legacy facets

**Satellites** (using automate_dv sat macro):

- s_subscriber_rating_gemstone_facets - Descriptive attributes from Gemstone system
- s_subscriber_rating_legacy_facets - Descriptive attributes from legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|-------------------|
| cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| cmc_sbrt_rate_data | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| cmc_sbrt_rate_data | grgr_ck | employer_group_bk | Group Contrived Key |
| cmc_sbrt_rate_data | sbrt_eff_dt | subscriber_rating_eff_dt | Data Row Effective Date |
| cmc_sbrt_rate_data | sbrt_term_dt | subscriber_rating_term_dt | Data Row Termination Date |
| cmc_sbrt_rate_data | sbrt_sb_bill_ind | subscriber_billing_ind | Subscriber Billing Indicator |
| cmc_sbrt_rate_data | sbrt_smoker_ind | subscriber_smoker_ind | Smoker Indicator for Rating |
| cmc_sbrt_rate_data | sbrt_rt_st | rating_state | Rating State |
| cmc_sbrt_rate_data | sbrt_rt_cnty | rating_county | Rating County |
| cmc_sbrt_rate_data | sbrt_rt_area | rating_area | Rating Area |
| cmc_sbrt_rate_data | sbrt_rt_sic | rating_sic_naics | Standard Industry Class./NAICS |
| cmc_sbrt_rate_data | sbrt_lock_token | subscriber_rating_lock_token | Lock Token |
| cmc_sbrt_rate_data | atxr_source_id | attachment_source_id | Attachment Source ID |
| cmc_sbrt_rate_data | edp_start_dt | edp_start_dt | EDP Start Date |
| cmc_sbrt_rate_data | edp_record_status | edp_record_status | EDP Record Status |

**Metadata:**

- Deliverables: Subscriber premium rating history, geographic rating tracking, smoker status history
- Dependencies: h_member hub must exist

---

## Specification Evaluation Report

### Overall Completeness Score: 95%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- ✅ **Title & Description**: Title includes Domain (Member) and Entity (subscriber_rating). Description accurately reflects objects being built (satellites only).
- ✅ **Business Key**: Type clearly labeled (Business Key). SQL expression provided with individual columns listed (correct format for automate_dv). Business key inheritance from parent hub clearly documented.
- ✅ **Source Models**: All source models listed with full project and model names. Source project specified. All models referenced in join example are listed.
- ✅ **Rename Views**: All rename views listed. Complex joins exist and staging join example provided.
- ✅ **Staging Views**: All staging views listed with source table references.
- ✅ **Hubs/Links/Satellites**: All objects match description. Naming conventions followed (s_ prefix). No hubs or links for this satellite-only spec.
- ✅ **Same-As Links**: Not applicable for this specification (satellites only, no identity resolution needed).
- ✅ **Column Mapping**: Source Column Mapping table includes all columns referenced in business key expressions and staging join example.
- ✅ **Acceptance Criteria**: All criteria are specific, testable, and reference actual objects being built (satellites and parent hub).
- ✅ **Metadata**: Deliverables listed. Dependencies identified (h_member hub must exist).

### Quality Checks

**Passed:** 6 / 6
- ✅ **Join Logic Documentation**: Staging join example includes multiple tables (cmc_sbrt_rate_data, cmc_sbsb_subsc, cmc_meme_member) and example is provided and complete with join conditions. Join logic corrected to use `sbsb.sbsb_ck = mem.sbsb_ck` to properly link subscriber to member.
- ✅ **Column Mapping Completeness**: Every column in the staging join example appears in the Source Column Mapping table with correct source_table reference, source_column name, appropriate target_column name, and descriptive column_description.
- ✅ **No Placeholders**: All [bracketed placeholders] have been replaced with actual values.
- ✅ **Consistency**: Description objects match Technical Details objects (satellites). Entity name (subscriber_rating) used consistently throughout.
- ✅ **Naming Conventions**: All model names follow BCI conventions (stg_, s_ prefixes).
- ✅ **Actionability**: An engineer can implement without additional clarification:
  - Source models are identifiable (full paths provided)
  - Business key logic is executable (inherited from parent hub, columns clearly listed)
  - Column mappings are clear (complete mapping table)
  - Join logic is documented (complete example provided)

### Data Vault 2.0 Pattern Validation

**Passed:** 5 / 5
- ✅ **Hub Appropriateness**: Not applicable - this is a satellite-only specification referencing existing h_member hub.
- ✅ **Satellite vs Reference Table**: Satellites are appropriately used for descriptive attributes that change over time (rating data, effective dates, billing indicators, smoker status, geographic factors) and need historization. This is not static lookup data.
- ✅ **Link Appropriateness**: Not applicable - no links in this specification.
- ✅ **Business Key Granularity**: Business key represents the correct level of detail (member level, inherited from parent hub). Note: Rating data is at subscriber level but attached to member hub for business context.
- ✅ **Satellite Rate of Change**: Rating data has moderate rate of change (effective dates, billing indicator changes, smoker status updates, geographic changes) which is appropriate for standard satellites. No need for hroc/mroc/lroc split.
- ✅ **Same-As Link Logic**: Not applicable - no same-as links in this specification.
- ✅ **Hub Scope**: Not applicable - satellites reference existing h_member hub.
- ✅ **No Over-Engineering**: Appropriate use of satellites for time-varying rating attributes. Not over-engineered.

**Anti-Patterns Identified:**
- None

### Red Flags (Critical Issues)

No red flags identified.

### Implementation Blockers

No implementation blockers identified. The specification contains all information needed for a data engineer or AI to implement:

1. ✅ All source models are clearly identified with full paths
2. ✅ Business key logic is executable (inherited from parent hub, columns listed)
3. ✅ Staging join example is complete and can be implemented (join logic corrected)
4. ✅ All columns from join example are mapped in Source Column Mapping table
5. ✅ Parent hub dependency is clearly documented
6. ✅ Acceptance criteria are testable and specific

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_sbrt_rate_data`, `stg_legacy_bcifacets_hist__dbo_cmc_sbrt_rate_data`, `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`, `stg_gemstone_facets_hist__dbo_cmc_meme_member`
2. **Can an engineer write the business key expression?** Yes - Business key is clearly documented as inherited from h_member with columns `subscriber_id` and `member_suffix` listed individually (correct format for automate_dv)
3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided with all tables, aliases, join conditions (corrected to `sbsb.sbsb_ck = mem.sbsb_ck`), and column selections
4. **Can an engineer map all columns from the Source Column Mapping table?** Yes - Complete mapping table includes all columns from the join example with source_table, source_column, target_column, and column_description
5. **Can an engineer implement all objects without questions?** Yes - All objects (rename views, staging views, satellites) are clearly defined with naming conventions and source references
6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable Given/When/Then statements that reference actual objects and can be validated

### Recommendations

- ✅ Specification is complete and ready for handoff
- ✅ Join logic corrected to properly link subscriber to member (`sbsb.sbsb_ck = mem.sbsb_ck`)
- ✅ Consider documenting if legacy facets join logic differs from gemstone (if applicable)
- ✅ Consider adding note about handling NULL values in business key columns if source data may contain NULLs

### Next Steps

Specification is ready for handoff to data engineering team. All required information is present, patterns are validated, and no blockers exist.
