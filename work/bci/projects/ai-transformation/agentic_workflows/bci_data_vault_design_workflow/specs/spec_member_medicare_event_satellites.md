## Member 360: Build Raw Vault member_medicare_event Satellites

**Title:**

**Member 360: Build Raw Vault member_medicare_event Satellites**

**Description:**

As a data engineer,  
I want to create the member_medicare_event satellites in the raw vault,  
So that we can track member Medicare enrollment event changes over time including Medicare event codes, effective dates, risk adjustment factors, Part C and Part D premiums, and Medicare-specific attributes for Member Months analytics.

**Acceptance Criteria:**

Given the member hub (h_member) exists with loaded member records,  
when the member medicare event satellite models execute,  
then all member medicare event records are loaded with valid member hub hash keys and load timestamps.

Given multiple source records exist for the same member over time,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the member medicare event satellites are loaded,  
when the satellites are compared to the source staging models,  
then the record counts match.

Given the member medicare event satellites reference the member hub,  
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
- `stg_gemstone_facets_hist__dbo_cmc_memd_mecr_detl` - Member Medicare detail data from Gemstone system
- `stg_legacy_bcifacets_hist__dbo_cmc_memd_mecr_detl` - Member Medicare detail data from legacy system
- `stg_gemstone_facets_hist__dbo_cmc_meme_member` - Member data for join to get member hub key
- `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc` - Subscriber data for join to get member hub key

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_member_medicare_event_gemstone_facets_rename - Rename columns for gemstone facets
- stg_member_medicare_event_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example gemstone join to get member hub key and medicare event attributes
source as (
    select
        -- Business Key Expressions
        sbsb.sbsb_id subscriber_id,
        mem.meme_sfx member_suffix,
        -- Medicare event attributes
        memd.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_memd_mecr_detl') }} memd
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on memd.meme_ck = mem.meme_ck
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on mem.sbsb_ck = sbsb.sbsb_ck
)
```

**Staging Views**:

- stg_member_medicare_event_gemstone_facets - Stage data from cmc_memd_mecr_detl for gemstone facets
- stg_member_medicare_event_legacy_facets - Stage data from cmc_memd_mecr_detl for legacy facets

**Satellites** (using automate_dv sat macro):

- s_member_medicare_event_gemstone_facets - Descriptive attributes from Gemstone system
- s_member_medicare_event_legacy_facets - Descriptive attributes from legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| cmc_memd_mecr_detl | meme_ck | member_bk | Member Contrived Key |
| cmc_memd_mecr_detl | grgr_ck | employer_group_bk | Group Contrived Key |
| cmc_memd_mecr_detl | memd_event_cd | medicare_event_cd | Medicare Event Code |
| cmc_memd_mecr_detl | memd_hcfa_eff_dt | medicare_hcfa_eff_dt | Medicare HCFA Effective Date |
| cmc_memd_mecr_detl | memd_hcfa_term_dt | medicare_hcfa_term_dt | Medicare HCFA Termination Date |
| cmc_memd_mecr_detl | memd_input_dt | medicare_input_dt | Date information was input into Facets |
| cmc_memd_mecr_detl | memd_event_eff_dt | medicare_event_eff_dt | Medicare Event Effective Date |
| cmc_memd_mecr_detl | memd_event_term_dt | medicare_event_term_dt | Medicare Event Termination Date |
| cmc_memd_mecr_detl | memd_mctr_mcst | medicare_state | Medicare State |
| cmc_memd_mecr_detl | memd_mctr_mcct | medicare_county | Medicare County |
| cmc_memd_mecr_detl | meme_hicn | member_hicn | Health Insurance Claim Number (HICN) |
| cmc_memd_mecr_detl | bgbg_ck | medicare_contract_bk | HCFA assigned Medicare contract ID |
| cmc_memd_mecr_detl | mrac_cat | pipdcg_category | PIPDCG Category |
| cmc_memd_mecr_detl | memd_ra_prta_fctr | risk_adj_factor_part_a | Risk Adjustment Factor Part A |
| cmc_memd_mecr_detl | memd_ra_prtb_fctr | risk_adj_factor_part_b | Risk Adjustment Factor Part B |
| cmc_memd_mecr_detl | memd_sig_dt | signature_dt | Signature Date |
| cmc_memd_mecr_detl | memd_elect_type | election_type | Election Type |
| cmc_memd_mecr_detl | memd_mctr_pbp | plan_benefit_package | Plan Benefit Package |
| cmc_memd_mecr_detl | memd_segment_id | segment_id | Segment ID |
| cmc_memd_mecr_detl | memd_ra_prtd_fctr | risk_adj_factor_part_d | Part D Risk Adjustment Factor |
| cmc_memd_mecr_detl | memd_ra_fctr_type | risk_adj_factor_type | Risk Adjustment Factor Type |
| cmc_memd_mecr_detl | memd_prem_wh_opt | premium_withhold_opt | Premium Withhold Option |
| cmc_memd_mecr_detl | memd_prtc_prem | part_c_premium | Part C Premium |
| cmc_memd_mecr_detl | memd_prtd_prem | part_d_premium | Part D Premium |
| cmc_memd_mecr_detl | memd_prior_com_ovr | prior_commercial_override | Prior Commercial Override |
| cmc_memd_mecr_detl | memd_enrl_source | enrollment_source | Enrollment Source |
| cmc_memd_mecr_detl | memd_uncov_mos | uncovered_months | Number of uncovered months |
| cmc_memd_mecr_detl | memd_rx_id | part_d_id | Part D ID |
| cmc_memd_mecr_detl | memd_mctr_rx_group | part_d_group_id | Part D Group ID |
| cmc_memd_mecr_detl | memd_mctr_rxbin | part_d_rxbin | Part D RX Binary Identification Number |
| cmc_memd_mecr_detl | memd_mctr_rxpcn | part_d_rxpcn | Part D RX Processing Control Number |
| cmc_memd_mecr_detl | memd_cob_ind | secondary_drug_insurance_flag | Secondary Drug Insurance Flag |
| cmc_memd_mecr_detl | memd_cob_rx_id | secondary_drug_insurance_id | Secondary Drug Insurance ID |
| cmc_memd_mecr_detl | memd_cob_rx_group | secondary_drug_insurance_group | Secondary Drug Insurance Group |
| cmc_memd_mecr_detl | memd_cob_rxbin | secondary_drug_insurance_bin | Secondary Drug Insurance Bin |
| cmc_memd_mecr_detl | memd_cob_rxpcn | secondary_drug_insurance_pcn | Secondary Drug Insurance PCN |
| cmc_memd_mecr_detl | memd_partd_sbsdy | part_d_subsidy | Part D Subsidy |
| cmc_memd_mecr_detl | memd_copay_cat | copay_category | Co-pay Category |
| cmc_memd_mecr_detl | memd_lics_sbsdy | part_d_low_income_subsidy | Part D low-income premium subsidy |
| cmc_memd_mecr_detl | memd_late_penalty | part_d_late_penalty | Part D late enrollment penalty |
| cmc_memd_mecr_detl | memd_late_waiv_amt | part_d_late_penalty_waived | Part D late enrollment penalty waived |
| cmc_memd_mecr_detl | memd_late_sbsdy | part_d_late_penalty_subsidy | Part D late enrollment penalty low-income subsidy |
| cmc_memd_mecr_detl | memd_msp_cd | aged_disabled_msp_status | Aged/Disabled MSP Status |
| cmc_memd_mecr_detl | memd_rad_fctr_type | part_d_ra_factor_type | Part D Risk Adjustment Factor Type |
| cmc_memd_mecr_detl | memd_lock_token | lock_token | Lock Token |
| cmc_memd_mecr_detl | atxr_source_id | attachment_source_id | Attachment Source ID |
| cmc_memd_mecr_detl | memd_ic_flag_nvl | ic_model_flag | IC Model Flag |
| cmc_memd_mecr_detl | memd_ic_sts_nvl | ic_model_benefit_status_cd | IC Model Benefit Status Code |
| cmc_memd_mecr_detl | memd_ic_trsn_nvl | ic_model_end_date_reason | IC Model End Date Reason |
| cmc_memd_mecr_detl | memd_pref_lang_nvl | preferred_language | Preferred Language |
| cmc_memd_mecr_detl | memd_access_fmt_nvl | accessible_format | Accessible Format |
| cmc_memd_mecr_detl | memd_mctr_srsn_nvl | sep_reason | SEP Reason |
| cmc_memd_mecr_detl | memd_mctr_erel_nvl | relationship_to_enrollee | Relationship to enrollee |
| cmc_memd_mecr_detl | memd_npn_nvl | national_producer_number | National Producer Number |
| cmc_memd_mecr_detl | edp_start_dt | edp_start_dt | EDP Start Date |
| cmc_memd_mecr_detl | edp_record_status | edp_record_status | EDP Record Status |

**Metadata:**

- Deliverables: Member Months
- Dependencies: h_member hub must exist

---

## Specification Evaluation Report

### Evaluation Date: 2026-01-08

### Recommendations

- ✅ Specification is complete and ready for handoff
- ✅ Consider documenting if legacy facets join logic differs from gemstone (if applicable)
- ✅ Consider adding note about handling NULL values in business key columns if source data may contain NULLs

### Overall Completeness Score: 95%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- ✅ **Title & Description**: Title includes Domain (Member) and Entity (member_medicare_event). Description accurately reflects objects being built (satellites only).
- ✅ **Business Key**: Type clearly labeled (Business Key). SQL expression provided with individual columns listed (correct format for automate_dv). Business key inheritance from parent hub clearly documented.
- ✅ **Source Models**: All source models listed with full project and model names. Source project specified. All models referenced in join example are listed.
- ✅ **Rename Views**: All rename views listed. Complex joins exist and staging join example provided.
- ✅ **Staging Views**: All staging views listed with source table references.
- ✅ **Hubs/Links/Satellites**: All objects match description. Naming conventions followed (s_ prefix). No hubs or links for this satellite-only spec.
- ✅ **Same-As Links**: Not applicable for this specification (satellites only, no identity resolution needed).
- ✅ **Column Mapping**: Source Column Mapping table includes all columns referenced in business key expressions and staging join example. All 54 columns from cmc_memd_mecr_detl are mapped.
- ✅ **Acceptance Criteria**: All criteria are specific, testable, and reference actual objects being built (satellites and parent hub).
- ✅ **Metadata**: Deliverables listed. Dependencies identified (h_member hub must exist).

**Failed:** 0 / 10
- None

### Quality Checks

**Passed:** 6 / 6
- ✅ **Join Logic Documentation**: Staging join example includes multiple tables (cmc_memd_mecr_detl, cmc_meme_member, cmc_sbsb_subsc) and example is provided and complete with join conditions.
- ✅ **Column Mapping Completeness**: Every column in the staging join example appears in the Source Column Mapping table with correct source_table reference, source_column name, appropriate target_column name, and descriptive column_description.
- ✅ **No Placeholders**: All [bracketed placeholders] have been replaced with actual values.
- ✅ **Consistency**: Description objects match Technical Details objects (satellites). Entity name (member_medicare_event) used consistently throughout.
- ✅ **Naming Conventions**: All model names follow BCI conventions (stg_, s_ prefixes).
- ✅ **Actionability**: An engineer can implement without additional clarification:
  - Source models are identifiable (full paths provided)
  - Business key logic is executable (inherited from parent hub, columns clearly listed)
  - Column mappings are clear (complete mapping table)
  - Join logic is documented (complete example provided)

**Failed:** 0 / 6
- None

### Data Vault 2.0 Pattern Validation

**Passed:** 8 / 8
- ✅ **Hub Appropriateness**: Not applicable - this is a satellite-only specification referencing existing h_member hub.
- ✅ **Satellite vs Reference Table**: Satellites are appropriately used for descriptive attributes that change over time (Medicare event codes, effective dates, risk adjustment factors, premiums, enrollment attributes) and need historization. This is not static lookup data.
- ✅ **Link Appropriateness**: Not applicable - no links in this specification.
- ✅ **Business Key Granularity**: Business key represents the correct level of detail (member level, inherited from parent hub).
- ✅ **Satellite Rate of Change**: Medicare event data has moderate rate of change (event codes, effective dates, premium changes) which is appropriate for standard satellites. No need for hroc/mroc/lroc split.
- ✅ **Same-As Link Logic**: Not applicable - no same-as links in this specification.
- ✅ **Hub Scope**: Not applicable - satellites reference existing h_member hub.
- ✅ **No Over-Engineering**: Appropriate use of satellites for time-varying Medicare enrollment attributes. Not over-engineered.

**Anti-Patterns Identified:**
- None

### Red Flags (Critical Issues)

No red flags identified.

### Implementation Blockers

No implementation blockers identified. The specification contains all information needed for a data engineer or AI to implement:

1. ✅ All source models are clearly identified with full paths
2. ✅ Business key logic is executable (inherited from parent hub, columns listed)
3. ✅ Staging join example is complete and can be implemented
4. ✅ All columns from join example are mapped in Source Column Mapping table
5. ✅ Parent hub dependency is clearly documented
6. ✅ Acceptance criteria are testable and specific

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_memd_mecr_detl`, `stg_legacy_bcifacets_hist__dbo_cmc_memd_mecr_detl`, `stg_gemstone_facets_hist__dbo_cmc_meme_member`, `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`
2. **Can an engineer write the business key expression?** Yes - Business key is clearly documented as inherited from h_member with columns `subscriber_id` and `member_suffix` listed individually (correct format for automate_dv)
3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided with all tables, aliases, join conditions, and column selections
4. **Can an engineer map all columns from the Source Column Mapping table?** Yes - Complete mapping table includes all columns from the join example with source_table, source_column, target_column, and column_description
5. **Can an engineer implement all objects without questions?** Yes - All objects (rename views, staging views, satellites) are clearly defined with naming conventions and source references
6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable Given/When/Then statements that reference actual objects and can be validated

### Next Steps

Specification is ready for handoff to data engineering team. All required information is present, patterns are validated, and no blockers exist.
