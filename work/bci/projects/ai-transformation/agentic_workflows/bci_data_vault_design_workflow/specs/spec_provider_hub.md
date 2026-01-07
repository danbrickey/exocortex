## Provider 360: Build Raw Vault Provider Hub and Satellites

**Title:**

**Provider 360: Build Raw Vault Provider Hub and Satellites**

**Description:**

As a data engineer,  
I want to refactor the provider hub and associated satellites in the raw vault,  
So that we can track provider changes over time and support provider catalog and PCP attribution analytics.

**Acceptance Criteria:**

Given source data is loaded to staging views,  
when the hub model executes,  
then all unique provider business keys are loaded with valid hash keys and load timestamps.

Given multiple source records exist for the same provider,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the hub is loaded,  
when the hub is compared to source provider records,  
then the key counts in the hub match the source records.

Given the same-as link is populated,  
when the link is compared to the source data,
then all provider records are linked across source systems with valid hub references.

### Technical Details

#### Business Key
 - plan_code
 - prov_npi
 - org_npi
 - org_tin
 - provider_state

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_prpr_prov` - Provider data from Gemstone Facets system
- `stg_gemstone_facets_hist__dbo_cmc_prer_relation` - Provider entity relationship data from Gemstone Facets system
- `stg_gemstone_facets_hist__dbo_cmc_prad_address` - Provider address data from Gemstone Facets system
- `stg_legacy_bcifacets_hist__dbo_cmc_prpr_prov` - Provider data from Legacy FACETS system
- `stg_legacy_bcifacets_hist__dbo_cmc_prer_relation` - Provider entity relationship data from Legacy FACETS system
- `stg_legacy_bcifacets_hist__dbo_cmc_prad_address` - Provider address data from Legacy FACETS system

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_provider_gemstone_facets_rename - Rename columns for gemstone facets
- stg_provider_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example gemstone join
source as (
    select
      -- Business Key columns
    '110' plan_code,
    prov.prpr_npi prov_npi,
    case
        when prov.prpr_entity IN ('G','P','F') and nullif(org.prpr_npi,'') is null
            then prov.prpr_npi
        else org.prpr_npi
    end org_npi,
    case
        when prov.prpr_entity IN ('G','P','F') and nullif(org.mctn_id,'') is null
            then prov.mctn_id
        else org.mctn_id
    end org_tin,
    prov.*, -- see payload metadata for specific columns
    rel.*, -- see payload metadata for specific columns
    org.*, -- see payload metadata for specific columns
    p_geo.* -- see payload metadata for specific columns
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} prov
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prer_relation') }} rel
            on prov.prpr_id = rel.prpr_id
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} org
            on org.prpr_id = rel.prer_prpr_id
              and org.prpr_entity = rel.prer_prpr_entity
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prad_address') }} p_geo
            on prov.prad_type_prim = p_geo.prad_type
              and prov.prad_id = p_geo.prad_id
)
```

**Staging Views**:

- stg_provider_gemstone_facets - Stage data from cmc_prpr_prov, cmc_prer_relation, and cmc_prad_address for gemstone facets
- stg_provider_legacy_facets - Stage data from cmc_prpr_prov, cmc_prer_relation, and cmc_prad_address for legacy facets

**Hubs** (using automate_dv hub macro):

- h_provider - Hub for provider business key

**Satellites** (using automate_dv sat macro):

- s_provider_gemstone_facets - Descriptive attributes from Gemstone system
- s_provider_legacy_facets - Descriptive attributes from legacy system

**Same-As Links** (using automate_dv link macro):

- sal_provider_facets - Same-as link for provider identity resolution using the crosswalk between Gemstone and Legacy providers. **Note**: the staging view should have a hash expression for the sal_provider_facets_hk column.

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_prpr_prov (prov) | prpr_id | provider_id | Provider Identifier |
| cmc_prpr_prov (prov) | prpr_entity | provider_entity | Provider Entity |
| cmc_prpr_prov (prov) | prcr_id | credentialing_id | Credentialing ID |
| cmc_prpr_prov (prov) | tpct_mctr_tcat | service_conversion_category | Service Conversion Category |
| cmc_prpr_prov (prov) | prpr_pay_cl_meth | provider_pay_cl_meth | Provider Claim Payment Combined Check Indicator |
| cmc_prpr_prov (prov) | prpr_mctr_type | provider_type | Provider Type |
| cmc_prpr_prov (prov) | prpr_mctr_prty | provider_practice_type | Provider Practice Type |
| cmc_prpr_prov (prov) | prcf_mctr_spec | provider_specialty | Provider Specialty |
| cmc_prpr_prov (prov) | prpr_name | provider_name | Provider Name |
| cmc_prpr_prov (prov) | prpr_npi | provider_npi | National Practitioner Identifier |
| cmc_prpr_prov (prov) | prcp_id | common_practitioner_id | Common Practitioner ID |
| cmc_prpr_prov (prov) | prad_id | provider_address_id | Provider Address ID |
| cmc_prpr_prov (prov) | prad_type_check | provider_remit_addr_type | Provider Remittance Address Type |
| cmc_prpr_prov (prov) | prad_type_prim | provider_primary_addr_type | Provider Primary Address Type |
| cmc_prpr_prov (prov) | mctn_id | provider_tin | Provider Tax Identification Number for search and reporting purposes |
| cmc_prpr_prov (prov) | prpr_sts | provider_status | Provider Status |
| cmc_prpr_prov (prov) | prpr_mctr_rev | provider_review_type | Provider Review Type |
| cmc_prpr_prov (prov) | prpr_preauth_ind | provider_preauth_ind | Provider Pre-authorization Indicator |
| cmc_prpr_prov (prov) | prpr_pay_hold_dt | provider_pay_hold_dt | Provider Payment Hold Date |
| cmc_prpr_prov (prov) | prpr_opts | provider_options | Provider Options |
| cmc_prpr_prov (prov) | prpr_cl_eft_ind | provider_cl_eft_ind | Provider Claims EFT Check Box |
| cmc_prpr_prov (prov) | prpr_cap_eft_ind | provider_cap_eft_ind | Provider Capitation EFT Check Box |
| cmc_prpr_prov (prov) | prpr_name_xlow | provider_name_xlow | Provider Name Case Insensitivity Field |
| cmc_prpr_prov (prov) | prpr_last_chan_dtm | provider_last_chan_dtm | Provider Last Channel Date |
| cmc_prpr_prov (prov) | prpr_mctr_lang | provider_language_ind | Provider Language Indicator |
| cmc_prpr_prov (prov) | prpr_extn_addr_ind | provider_extn_addr_ind | Provider External Address Indicator |
| cmc_prpr_prov (prov) | mcbr_ck | provider_bank_rel_ck | Provider Bank Relationship contrived key |
| cmc_prpr_prov (prov) | usus_id | user_id | User Identifier |
| cmc_prpr_prov (prov) | crcy_id | capitation_cycle_id | Provider Capitation Cycle ID |
| cmc_prpr_prov (prov) | prpr_term_dt | provider_term_dt | Provider Termination Date |
| cmc_prpr_prov (prov) | prpr_mctr_trsn | provider_term_reason | Provider Termination Reason |
| cmc_prpr_prov (prov) | prpr_taxonomy_cd | provider_taxonomy_cd | Taxonomy Code |
| cmc_prpr_prov (prov) | prpr_edi_dest_id | provider_edi_dest_id | Destination ID |
| cmc_prpr_prov (prov) | prpr_edi_dest_qual | provider_edi_dest_qual | Destination Qualifier |
| cmc_prpr_prov (prov) | prpr_ra_dest_ind | provider_ra_dest_ind | Advice Destination |
| cmc_prpr_prov (prov) | prpr_clrnghouse_id | provider_clearinghouse_id | Clearinghouse ID |
| cmc_prpr_prov (prov) | prpr_last_mcpa_dtm | provider_last_mcpa_dtm | N/A |
| cmc_prpr_prov (prov) | prpr_pr_red_cd | provider_overpayment_recovery_ind | Provider overpyament recovery indicator |
| cmc_prpr_prov (prov) | prcf_mctr_spec2 | provider_secondary_specialty | Secondary Specialty |
| cmc_prpr_prov (prov) | prpr_mctr_val1 | provider_value_code_1 | Provider Value Code 1 |
| cmc_prpr_prov (prov) | prpr_mctr_val2 | provider_value_code_2 | Provider Value Code 2 |
| cmc_prpr_prov (prov) | prpr_rmt_trans_cd | provider_rmt_trans_cd | Report Transmission Code |
| cmc_prpr_prov (prov) | prpr_rmt_del_name | provider_rmt_del_name | Remittance Delivery Name |
| cmc_prpr_prov (prov) | prpr_rmt_comm_no | provider_rmt_comm_no | Remittance Delivery Communication Number |
| cmc_prpr_prov (prov) | prpr_lock_token | lock_token | Lock Token |
| cmc_prpr_prov (prov) | atxr_source_id | attachment_source_id | Attachment Source Id |
| cmc_prpr_prov (prov) | sys_last_upd_dtm | system_last_update_dtm | Last Update Datetime |
| cmc_prpr_prov (prov) | sys_usus_id | system_user_id | Last Update User ID |
| cmc_prpr_prov (prov) | sys_dbuser_id | system_dbuser_id | Last Update DBMS User ID |
| cmc_prpr_prov (prov) | prpr_pa_ra_end_dt_nvl | provider_pa_ra_end_dt | Dual Remit Delivery End Date |
| cmc_prpr_prov (prov) | sys_bitmap_nvl | system_bitmap_ind | Bitmap Indicator |
| cmc_prpr_prov (prov) | sys_last_offset_nvl | system_last_offset | Last Offset Location |
| cmc_prpr_prov (prov) | prpr_its_tier_dsgn_nvl | provider_its_tier_dsgn_ind | ITS Tier Designation Indicator |
| cmc_prpr_prov (prov) | prpr_rec_lag_ind_nvl | provider_rec_lag_ind | Provider Overpayment Lag Recovery Indicator |
| cmc_prpr_prov (prov) | prpr_rec_lag_days_nvl | provider_rec_lag_days | Provider Overpayment Recovery Lag Days |
| cmc_prpr_prov (prov) | prpr_medcd_ind_nvl | provider_medicaid_ind | Medicaid Agency Indicator |
| cmc_prpr_prov (org) | prpr_id | organization_id | Organizational Provider Identifier |
| cmc_prpr_prov (org) | prpr_entity | organization_entity | Organizational Provider Entity |
| cmc_prpr_prov (org) | prcr_id | organization_credentialing_id | Organizational Credentialing ID |
| cmc_prpr_prov (org) | tpct_mctr_tcat | organization_service_conversion_category | Organizational Service Conversion Category |
| cmc_prpr_prov (org) | prpr_pay_cl_meth | organization_pay_cl_meth | Organizational Provider Claim Payment Combined Check Indicator |
| cmc_prpr_prov (org) | prpr_mctr_type | organization_type | Organizational Provider Type |
| cmc_prpr_prov (org) | prpr_mctr_prty | organization_practice_type | Organizational Provider Practice Type |
| cmc_prpr_prov (org) | prcf_mctr_spec | organization_specialty | Organizational Provider Specialty |
| cmc_prpr_prov (org) | prpr_name | organization_name | Organizational Provider Name |
| cmc_prpr_prov (org) | prpr_npi | organization_npi | Organizational National Practitioner Identifier |
| cmc_prpr_prov (org) | prcp_id | organization_common_practitioner_id | Organizational Common Practitioner ID |
| cmc_prpr_prov (org) | prad_id | organization_address_id | Organizational Provider Address ID |
| cmc_prpr_prov (org) | prad_type_check | organization_remit_addr_type | Organizational Provider Remittance Address Type |
| cmc_prpr_prov (org) | prad_type_prim | organization_primary_addr_type | Organizational Provider Primary Address Type |
| cmc_prpr_prov (org) | mctn_id | organization_tin | Organizational Provider Tax Identification Number for search and reporting purposes |
| cmc_prpr_prov (org) | prpr_sts | organization_status | Organizational Provider Status |
| cmc_prpr_prov (org) | prpr_mctr_rev | organization_review_type | Organizational Provider Review Type |
| cmc_prpr_prov (org) | prpr_preauth_ind | organization_preauth_ind | Organizational Provider Pre-authorization Indicator |
| cmc_prpr_prov (org) | prpr_pay_hold_dt | organization_pay_hold_dt | Organizational Provider Payment Hold Date |
| cmc_prpr_prov (org) | prpr_opts | organization_options | Organizational Provider Options |
| cmc_prpr_prov (org) | prpr_cl_eft_ind | organization_cl_eft_ind | Organizational Provider Claims EFT Check Box |
| cmc_prpr_prov (org) | prpr_cap_eft_ind | organization_cap_eft_ind | Organizational Provider Capitation EFT Check Box |
| cmc_prpr_prov (org) | prpr_name_xlow | organization_name_xlow | Organizational Provider Name Case Insensitivity Field |
| cmc_prpr_prov (org) | prpr_last_chan_dtm | organization_last_chan_dtm | Organizational Provider Last Channel Date |
| cmc_prpr_prov (org) | prpr_mctr_lang | organization_language_ind | Organizational Provider Language Indicator |
| cmc_prpr_prov (org) | prpr_extn_addr_ind | organization_extn_addr_ind | Organizational Provider External Address Indicator |
| cmc_prpr_prov (org) | mcbr_ck | organization_bank_rel_ck | Organizational Provider Bank Relationship contrived key |
| cmc_prpr_prov (org) | usus_id | organization_user_id | Organizational User Identifier |
| cmc_prpr_prov (org) | crcy_id | organization_capitation_cycle_id | Organizational Provider Capitation Cycle ID |
| cmc_prpr_prov (org) | prpr_term_dt | organization_term_dt | Organizational Provider Termination Date |
| cmc_prpr_prov (org) | prpr_mctr_trsn | organization_term_reason | Organizational Provider Termination Reason |
| cmc_prpr_prov (org) | prpr_taxonomy_cd | organization_taxonomy_cd | Organizational Taxonomy Code |
| cmc_prpr_prov (org) | prpr_edi_dest_id | organization_edi_dest_id | Organizational Destination ID |
| cmc_prpr_prov (org) | prpr_edi_dest_qual | organization_edi_dest_qual | Organizational Destination Qualifier |
| cmc_prpr_prov (org) | prpr_ra_dest_ind | organization_ra_dest_ind | Organizational Advice Destination |
| cmc_prpr_prov (org) | prpr_clrnghouse_id | organization_clearinghouse_id | Organizational Clearinghouse ID |
| cmc_prpr_prov (org) | prpr_last_mcpa_dtm | organization_last_mcpa_dtm | N/A |
| cmc_prpr_prov (org) | prpr_pr_red_cd | organization_overpayment_recovery_ind | Organizational Provider overpyament recovery indicator |
| cmc_prpr_prov (org) | prcf_mctr_spec2 | organization_secondary_specialty | Organizational Secondary Specialty |
| cmc_prpr_prov (org) | prpr_mctr_val1 | organization_value_code_1 | Organizational Provider Value Code 1 |
| cmc_prpr_prov (org) | prpr_mctr_val2 | organization_value_code_2 | Organizational Provider Value Code 2 |
| cmc_prpr_prov (org) | prpr_rmt_trans_cd | organization_rmt_trans_cd | Organizational Report Transmission Code |
| cmc_prpr_prov (org) | prpr_rmt_del_name | organization_rmt_del_name | Organizational Remittance Delivery Name |
| cmc_prpr_prov (org) | prpr_rmt_comm_no | organization_rmt_comm_no | Organizational Remittance Delivery Communication Number |
| cmc_prpr_prov (org) | prpr_lock_token | organization_lock_token | Organizational Lock Token |
| cmc_prpr_prov (org) | atxr_source_id | organization_attachment_source_id | Organizational Attachment Source Id |
| cmc_prpr_prov (org) | sys_last_upd_dtm | organization_system_last_update_dtm | Organizational Last Update Datetime |
| cmc_prpr_prov (org) | sys_usus_id | organization_system_user_id | Organizational Last Update User ID |
| cmc_prpr_prov (org) | sys_dbuser_id | organization_system_dbuser_id | Organizational Last Update DBMS User ID |
| cmc_prpr_prov (org) | prpr_pa_ra_end_dt_nvl | organization_pa_ra_end_dt | Organizational Dual Remit Delivery End Date |
| cmc_prpr_prov (org) | sys_bitmap_nvl | organization_system_bitmap_ind | Organizational Bitmap Indicator |
| cmc_prpr_prov (org) | sys_last_offset_nvl | organization_system_last_offset | Organizational Last Offset Location |
| cmc_prpr_prov (org) | prpr_its_tier_dsgn_nvl | organization_its_tier_dsgn_ind | Organizational ITS Tier Designation Indicator |
| cmc_prpr_prov (org) | prpr_rec_lag_ind_nvl | organization_rec_lag_ind | Organizational Provider Overpayment Lag Recovery Indicator |
| cmc_prpr_prov (org) | prpr_rec_lag_days_nvl | organization_rec_lag_days | Organizational Provider Overpayment Recovery Lag Days |
| cmc_prpr_prov (org) | prpr_medcd_ind_nvl | organization_medicaid_ind | Organizational Medicaid Agency Indicator |
| cmc_prer_relation | prer_eff_dt | provider_rel_eff_dt | Provider Entity Relationship Effective Date |
| cmc_prer_relation | prer_term_dt | provider_rel_term_dt | Provider Entity Relationship Termination Date |
| cmc_prad_address | prad_state | provider_address_state | Provider Address (Type) State |
| N/A | '110' | plan_code | Plan code constant |
| N/A | '1' | tenant_id | Tenant identifier constant |
| N/A | gemstone_facets/legacy_facets | source | Source system identifier |

**Metadata:**

- Deliverables: Provider Months, PCP Attribution
- Dependencies: None

---

## Specification Evaluation Report (Updated)

### Evaluation Date: 2025-01-27
### Previous Score: 100%
### Current Score: 95%

**Changes Since Last Evaluation:**
- ✅ **Improvement**: Added organizational provider columns (cmc_prpr_prov (org)) to Source Column Mapping table - now includes all 56 columns from both provider and organizational provider instances
- ✅ **Correct**: Only Gemstone staging join example included (appropriate since joins are identical between Gemstone and Legacy)
- ⚠️ **Issue Identified**: Staging join example uses `rel.*` and `p_geo.*` wildcards, but Source Column Mapping table only includes 2 columns from cmc_prer_relation and 1 column from cmc_prad_address. All columns from these tables should be included in the mapping table.

### Recommendations

1. **Add Missing Columns from cmc_prer_relation**: The join example uses `rel.*` which includes all columns from cmc_prer_relation, but the Source Column Mapping table only includes 2 columns (prer_eff_dt, prer_term_dt). Add the remaining 12 columns from cmc_prer_relation (e.g., prer_prpr_id, prer_mctr_trsn, prer_lock_token, etc.).

2. **Add Missing Columns from cmc_prad_address**: The join example uses `p_geo.*` which includes all columns from cmc_prad_address, but the Source Column Mapping table only includes 1 column (prad_state). Add the remaining columns from cmc_prad_address (e.g., prad_id, prad_type, prad_addr1, prad_city, prad_zip, etc.).

3. **Business Logic Verification**: Confirm that `prov.prpr_entity = rel.prer_prpr_entity` is the correct join condition on line 93, as `prer_prpr_entity` may represent the relationship type rather than matching the provider entity type.

### Overall Completeness Score: 95%

**Status:** Needs Minor Revision

### Completeness Checks

**Passed:** 9 / 10
- Title & Description: Title includes Domain (Provider) and Entity (Provider Hub and Satellites). Description accurately reflects objects being built (hub, satellites, and same-as link).
- Business Key: Individual business key columns/expressions listed in the format expected by automate_dv macros. All 5 components included (plan_code, prov_npi, org_npi, org_tin, provider_state). CASE statements for org_npi and org_tin are provided in staging join example.
- Source Models: All 6 source models listed with full project and model names. Source project (`enterprise_data_platform`) specified.
- Rename Views: All rename views listed. Only Gemstone staging join example provided (correct per new rules since joins are identical). Legacy follows same pattern with `stg_legacy_bcifacets_hist__dbo_*` models.
- Staging Views: All staging views listed with source table references.
- Hubs/Links/Satellites: All objects match description. Naming conventions followed (h_, s_, sal_).
- Same-As Links: Resolution logic described. Note about hash expression included.
- Acceptance Criteria: All criteria are specific, testable, and reference actual objects being built.
- Metadata: Deliverables listed. Dependencies identified.

**Failed:** 1 / 10
- **Column Mapping**: Source Column Mapping table includes all columns from cmc_prpr_prov for both (prov) and (org) aliases (112 columns total), which is excellent. However, the join example uses `rel.*` and `p_geo.*` wildcards, but the mapping table only includes 2 columns from cmc_prer_relation and 1 column from cmc_prad_address. All columns referenced via wildcards in the join example should be explicitly listed in the Source Column Mapping table.

### Quality Checks

**Passed:** 5 / 6
- Join Logic Documentation: Complete staging join example provided (Gemstone only, which is correct). Example shows complex multi-table joins with proper join conditions. Business key expressions include CASE statements for org_npi and org_tin.
- No Placeholders: All placeholders have been replaced with actual values. No template instructional notes remain.
- Consistency: Description objects match Technical Details objects. Entity name used consistently throughout.
- Naming Conventions: All model names follow BCI conventions (stg_, h_, s_, sal_ prefixes).
- Actionability: An engineer can implement without additional clarification - source models are identifiable, business key logic is executable (individual columns/expressions as expected by automate_dv), join logic is documented.

**Failed:** 1 / 6
- **Column Mapping Completeness**: The staging join example uses `rel.*` (line 85) and `p_geo.*` (line 87) wildcards, indicating all columns from these tables are selected. However, the Source Column Mapping table only includes 2 columns from cmc_prer_relation and 1 column from cmc_prad_address. All columns from these tables should be explicitly listed in the mapping table with appropriate target column names and descriptions.

### Data Vault 2.0 Pattern Validation

**Passed:** 8 / 8
- Hub Appropriateness: Provider hub represents a significant business entity - appropriate.
- Satellite vs Reference Table: Satellites are used for descriptive attributes that change over time and need historization - appropriate. No static lookup data incorrectly modeled as satellites.
- Link Appropriateness: Same-as link represents identity resolution across systems - appropriate.
- Business Key Granularity: Business key represents correct level of detail for provider entity, handling cases where provider NPI, organization NPI, TIN, and state combinations identify providers. CASE statements handle polymorphic logic appropriately.
- Satellite Rate of Change: No indication of high rate of change issues requiring split.
- Same-As Link Logic: Same-as link logic is appropriate for identity resolution across Gemstone and Legacy systems - appropriate use case.
- Hub Scope: Provider hub represents a business concept that exists across multiple source systems (Gemstone and Legacy FACETS) - appropriate.
- No Over-Engineering: Appropriate complexity for provider entity with demographic and relationship tracking.

**Anti-Patterns Identified:**
- None identified. All artifacts follow Data Vault 2.0 best practices.

### Red Flags (Critical Issues)

⚠️ **Incomplete Column Mapping**: The staging join example uses `rel.*` and `p_geo.*` wildcards (lines 85 and 87), which means all columns from cmc_prer_relation and cmc_prad_address are selected. However, the Source Column Mapping table only includes 2 columns from cmc_prer_relation and 1 column from cmc_prad_address. All columns from these tables must be explicitly listed in the mapping table to ensure complete column mapping documentation.

**Data Vault 2.0 Pattern Violations:**
- None identified.

### Implementation Blockers

These issues would prevent a data engineer or AI from implementing this specification:

1. **Missing Column Mappings**: The join example selects all columns from cmc_prer_relation (`rel.*`) and cmc_prad_address (`p_geo.*`), but the Source Column Mapping table doesn't include all columns from these tables. An engineer would need to determine which columns are needed and how to map them, which creates ambiguity.

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All 6 source models are listed in the Source Models section with full paths.

2. **Can an engineer write the business key expression?** Yes - The Business Key section shows individual business key columns/expressions in the format expected by automate_dv macros. CASE statements for org_npi and org_tin are provided in the staging join example. The format is correct for passing to automate_dv hub macro as a list of business key columns.

3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided (Gemstone only, which is correct). Join logic is clear with proper join conditions. However, the wildcard selections (`rel.*`, `p_geo.*`) mean all columns are selected, but not all are mapped in the Source Column Mapping table.

4. **Can an engineer map all columns from the mapping table?** Partially - The Source Column Mapping table is comprehensive for cmc_prpr_prov (both prov and org aliases), but incomplete for cmc_prer_relation and cmc_prad_address. An engineer would need to determine which additional columns from these tables should be included and how to map them.

5. **Can an engineer implement all objects without questions?** Mostly - The specification is comprehensive for provider data, but the incomplete column mapping for cmc_prer_relation and cmc_prad_address creates ambiguity. Once all columns are added to the mapping table, an engineer can implement without questions.

6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable, and reference actual objects being built.

### Next Steps

**Specification needs minor revision before handoff:**

1. ✅ Only Gemstone staging join example included (correct per new rules)
2. ✅ Organizational provider columns added to Source Column Mapping table
3. ⚠️ Add all remaining columns from cmc_prer_relation to Source Column Mapping table
4. ⚠️ Add all remaining columns from cmc_prad_address to Source Column Mapping table

Once these column mappings are added, the specification will be ready for handoff to the data engineering team.
