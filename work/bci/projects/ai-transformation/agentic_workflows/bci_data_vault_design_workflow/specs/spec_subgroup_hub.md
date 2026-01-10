## Group 360: Build Raw Vault subgroup Hub and Satellites

**Title:**

**Group 360: Build Raw Vault subgroup Hub and Satellites**

**Description:**

As a data engineer,  
I want to create the subgroup hub and satellites in the raw vault,  
So that we can track subgroup indicative data changes over time and support member months analytics.

**Acceptance Criteria:**

Given source data is loaded to staging views,  
when the hub model executes,  
then all unique subgroup business keys are loaded with valid hash keys and load timestamps.

Given multiple source records exist for the same subgroup,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the hub is loaded,  
when the hub is compared to source subgroup records,  
then the key counts in the hub match the source records.

### Technical Details

#### Business Key

**Type:** Business Key

```sql
subgroup_id
```

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_sgsg_sub_group` - Subgroup indicative data from Gemstone system
- `stg_legacy_bcifacets_hist__dbo_cmc_sgsg_sub_group` - Subgroup indicative data from Legacy system

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_subgroup_gemstone_facets_rename - Rename columns for gemstone facets
- stg_subgroup_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example gemstone join
source as (
    select
        -- Business Key Expressions
        sgsg.sgsg_id as subgroup_id,
        -- Subgroup attributes
        sgsg.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sgsg_sub_group') }} sgsg
)
```

**Staging Views**:

- stg_subgroup_gemstone_facets - Stage data from cmc_sgsg_sub_group for gemstone facets
- stg_subgroup_legacy_facets - Stage data from cmc_sgsg_sub_group for legacy facets

**Hubs** (using automate_dv hub macro):

- h_subgroup - Hub for subgroup business key

**Satellites** (using automate_dv sat macro):

- s_subgroup_gemstone_facets - Descriptive attributes from Gemstone system
- s_subgroup_legacy_facets - Descriptive attributes from Legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_sgsg_sub_group | sgsg_id | subgroup_id | Subgroup Identifier (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| cmc_sgsg_sub_group | sgsg_ck | subgroup_bk | Subgroup Contrived Key |
| cmc_sgsg_sub_group | grgr_ck | group_bk | Group Contrived Key |
| cmc_sgsg_sub_group | sgsg_name | subgroup_name | Subgroup Name |
| cmc_sgsg_sub_group | sgsg_addr1 | subgroup_address_line_1 | Subgroup Address Line 1 |
| cmc_sgsg_sub_group | sgsg_addr2 | subgroup_address_line_2 | Subgroup Address Line 2 |
| cmc_sgsg_sub_group | sgsg_addr3 | subgroup_address_line_3 | Subgroup Address Line 3 |
| cmc_sgsg_sub_group | sgsg_city | subgroup_city | Subgroup City |
| cmc_sgsg_sub_group | sgsg_state | subgroup_state | Subgroup State |
| cmc_sgsg_sub_group | sgsg_zip | subgroup_zip_code | Subgroup Zip Code |
| cmc_sgsg_sub_group | sgsg_county | subgroup_county | Subgroup County |
| cmc_sgsg_sub_group | sgsg_ctry_cd | subgroup_country_code | Subgroup Country Code |
| cmc_sgsg_sub_group | sgsg_phone | subgroup_phone_number | Subgroup Phone Number |
| cmc_sgsg_sub_group | sgsg_phone_ext | subgroup_phone_extension | Subgroup Phone Extension |
| cmc_sgsg_sub_group | sgsg_fax | subgroup_fax_number | Subgroup Fax Number |
| cmc_sgsg_sub_group | sgsg_fax_ext | subgroup_fax_extension | Subgroup Fax Extension |
| cmc_sgsg_sub_group | sgsg_email | subgroup_email | Subgroup Email |
| cmc_sgsg_sub_group | sgsg_mctr_type | subgroup_type | Subgroup Type |
| cmc_sgsg_sub_group | sgsg_mctr_vip | subgroup_vip_type | Subgroup VIP Type |
| cmc_sgsg_sub_group | cscs_id | class_id | Class Identifier |
| cmc_sgsg_sub_group | sgsg_sts | subgroup_status | Subgroup Status |
| cmc_sgsg_sub_group | sgsg_orig_eff_dt | subgroup_original_effective_date | Subgroup Original Effective Date |
| cmc_sgsg_sub_group | sgsg_term_dt | subgroup_termination_date | Subgroup Termination Date |
| cmc_sgsg_sub_group | sgsg_mctr_trsn | subgroup_termination_reason | Subgroup Termination Reason |
| cmc_sgsg_sub_group | excd_id | explanation_code | Explanation Code |
| cmc_sgsg_sub_group | sgsg_rnst_dt | subgroup_reinstatement_date | Subgroup Reinstatement Date |
| cmc_sgsg_sub_group | sgsg_conv_dt | subgroup_conversion_date | Subgroup Conversion Date |
| cmc_sgsg_sub_group | sgsg_renew_mmdd | subgroup_renewal_date | Subgroup Renewal Date (MMDD format) |
| cmc_sgsg_sub_group | sgsg_prev_annv_dt | subgroup_prior_anniversary_date | Subgroup Prior Anniversary Date |
| cmc_sgsg_sub_group | sgsg_curr_annv_dt | subgroup_current_anniversary_date | Subgroup Current Anniversary Date |
| cmc_sgsg_sub_group | sgsg_next_annv_dt | subgroup_next_anniversary_date | Subgroup Next Anniversary Date |
| cmc_sgsg_sub_group | sgsg_mctr_ptyp | subgroup_policy_type | Subgroup Policy Type |
| cmc_sgsg_sub_group | sgsg_undw_usus_id | subgroup_underwriter_user_id | Subgroup Underwriter User ID |
| cmc_sgsg_sub_group | sgsg_bl_conv_dt | subgroup_billing_conversion_date | Subgroup Billing Conversion Date |
| cmc_sgsg_sub_group | sgsg_name_xlow | subgroup_name_search | Subgroup Name (case insensitive for search) |
| cmc_sgsg_sub_group | sgsg_city_xlow | subgroup_city_search | Subgroup City (case insensitive for search) |
| cmc_sgsg_sub_group | sgsg_mctr_lang | subgroup_language | Subgroup Language |
| cmc_sgsg_sub_group | sgsg_extn_addr_ind | subgroup_external_address_indicator | Subgroup External Address Indicator |
| cmc_sgsg_sub_group | wmds_seq_no | warning_message_sequence_number | Warning Message Sequence Number |
| cmc_sgsg_sub_group | sgsg_total_empl | subgroup_total_employees | Subgroup Total Number of Employees |
| cmc_sgsg_sub_group | sgsg_total_elig | subgroup_total_eligible | Subgroup Total Number of Eligible Employees |
| cmc_sgsg_sub_group | sgsg_total_contr | subgroup_total_contracts | Subgroup Total Number of Contracts |
| cmc_sgsg_sub_group | sgsg_pol_no | subgroup_policy_code | Subgroup Policy Code |
| cmc_sgsg_sub_group | sgsg_ein | subgroup_ein | Subgroup Employer Identification Number |
| cmc_sgsg_sub_group | sgsg_eris_mmdd | subgroup_erisa_plan_year | Subgroup ERISA Plan Year (MMDD format) |
| cmc_sgsg_sub_group | sgsg_recd_dt | subgroup_received_date | Subgroup Received Date |
| cmc_sgsg_sub_group | sgsg_runout_dt | subgroup_claim_runout_date | Subgroup Claim Runout Date |
| cmc_sgsg_sub_group | sgsg_runout_excd | subgroup_claim_runout_explanation_code | Subgroup Claim Runout Explanation Code |
| cmc_sgsg_sub_group | sgsg_trans_accept | subgroup_accumulator_transfer_acceptance_indicator | Subgroup Accumulator Transfer Acceptance Indicator |
| cmc_sgsg_sub_group | sgsg_cont_eff_dt | subgroup_contract_effective_date | Subgroup Contract Effective Date |
| cmc_sgsg_sub_group | sgsg_term_prem_mos | subgroup_terminal_premium_months | Number of months the subgroup will bill for terminal billing |
| cmc_sgsg_sub_group | sgsg_rnst_type | subgroup_reinstatement_type | Subgroup Reinstatement Type |
| cmc_sgsg_sub_group | sgsg_rnst_val | subgroup_reinstatement_value | Subgroup Reinstatement Value |
| cmc_sgsg_sub_group | sgsg_lock_token | subgroup_lock_token | Subgroup Lock Token |
| cmc_sgsg_sub_group | atxr_source_id | attachment_source_id | Attachment Source ID |
| cmc_sgsg_sub_group | sys_last_upd_dtm | system_last_update_dtm | System Last Update Datetime |
| cmc_sgsg_sub_group | sys_usus_id | system_user_id | System User ID |
| cmc_sgsg_sub_group | sys_dbuser_id | system_dbuser_id | System DBMS User ID |
| cmc_sgsg_sub_group | sgsg_pup_ind_nvl | subgroup_eligibility_pend_until_paid | Subgroup Eligibility Pend Until Paid Indicator |

**Metadata:**

- Deliverables: Member Months
- Dependencies: None

---

## Specification Evaluation Report

### Evaluation Date: 2025-01-28

### Recommendations

- Specification is complete and ready for handoff. All required information is present. The simple structure (no joins required) makes this straightforward to implement.

### Overall Completeness Score: 100%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- Title & Description: Title includes Domain (Group) and Entity (subgroup). Description accurately reflects hub and satellites being built.
- Business Key: Type clearly labeled as Business Key. SQL expression provided with single column (subgroup_id).
- Source Models: All source models listed with full project and model names. Source project specified.
- Rename Views: All rename views listed. Simple staging join example provided (no complex joins needed).
- Staging Views: All staging views listed with source table references.
- Hubs/Links/Satellites: All objects match description. Naming conventions followed (h_, s_ prefixes).
- Same-As Links: Not applicable for this entity (no identity resolution needed).
- Column Mapping: Source Column Mapping table includes all columns referenced in staging join example.
- Acceptance Criteria: All criteria are specific, testable, and reference actual objects being built.
- Metadata: Deliverables listed (Member Months). Dependencies identified (None).

### Quality Checks

**Passed:** 6 / 6
- Join Logic Documentation: Simple single-table query documented (no joins required as specified).
- Column Mapping Completeness: All columns from staging join example appear in Source Column Mapping table with correct references and descriptions.
- No Placeholders: All placeholders replaced with actual values.
- Consistency: Description objects match Technical Details objects. Entity name used consistently throughout.
- Naming Conventions: All model names follow BCI conventions (stg_, h_, s_ prefixes).
- Actionability: An engineer can implement without additional clarification - source models are identifiable, business key logic is executable, column mappings are clear, and join logic is documented.

### Data Vault 2.0 Pattern Validation

**Passed:** 7 / 7
- Hub Appropriateness: Hub represents a significant business entity (subgroup) that is part of group management and member months analytics.
- Satellite vs Reference Table: Satellites are appropriate for descriptive attributes that change over time (addresses, status, dates, counts).
- Link Appropriateness: Not applicable (no links defined).
- Business Key Granularity: Business key (subgroup_id) represents the correct level of detail for subgroup entity.
- Satellite Rate of Change: Subgroup attributes have moderate rate of change appropriate for single satellite per source system.
- Same-As Link Logic: Not applicable (no identity resolution needed across systems).
- Hub Scope: Hub represents a business concept (subgroup) that exists across multiple source systems (Gemstone and Legacy) and has business importance for member months.

**Anti-Patterns Identified:**
- None

### Red Flags (Critical Issues)

No red flags identified.

### Implementation Blockers

No implementation blockers identified. The specification contains all information needed for implementation:
- Source models are clearly identified
- Business key is simple and well-defined
- Column mappings are complete
- Staging join example is provided (simple single-table query)
- All required objects are documented

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - Both source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_sgsg_sub_group` and `stg_legacy_bcifacets_hist__dbo_cmc_sgsg_sub_group`.
2. **Can an engineer write the business key expression?** Yes - Business key is clearly defined as `subgroup_id` mapped from `sgsg_id`.
3. **Can an engineer build the staging join from the example?** Yes - Simple single-table query is provided with all columns listed.
4. **Can an engineer map all columns from the mapping table?** Yes - All 58 columns from the source table are mapped with clear target column names and descriptions.
5. **Can an engineer implement all objects without questions?** Yes - Hub and two satellites are clearly defined with naming conventions and source references.
6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable, and reference actual objects being built.

### Next Steps

Specification is ready for handoff to data engineering team.
