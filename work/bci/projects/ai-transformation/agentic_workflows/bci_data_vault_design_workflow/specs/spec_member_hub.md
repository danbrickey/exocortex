## Member 360: Build Raw Vault Member Hub and Satellites

**Title:**

**Member 360: Build Raw Vault Member Hub and Satellites**

**Description:**

As a data engineer,  
I want to refactor the member hub and satellites in the raw vault,  
So that we can track member demographic changes over time and support member months and PCP attribution analytics.

**Acceptance Criteria:**

Given source data is loaded to staging views,  
when the hub model executes,  
then all unique member business keys are loaded with valid hash keys and load timestamps.

Given multiple source records exist for the same member,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the hub is loaded,  
when the hub is compared to source member records,  
then the key counts in the hub match the source records.

Given the same-as link is populated,  
when the link is compared to the source data,
then all member records are linked across source systems with valid hub references.

### Technical Details

#### Business Key

**Type:** Business Key

```sql
subscriber_id,
member_suffix
```

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_meme_member` - Member data from Gemstone Facets system
- `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc` - Subscriber data from Gemstone Facets system
- `stg_legacy_bcifacets_hist__dbo_cmc_meme_member` - Member data from Legacy FACETS system
- `stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc` - Subscriber data from Legacy FACETS system
- `stg_gemstone_bcifacets_hist__dbo_cmc_meda_me_data` - Member data attributes from Legacy FACETS system
- `stg_legacy_bcifacets_hist__dbo_cmc_meda_me_data` - Member data attributes from Legacy FACETS system

**Note:** List all source models referenced in the staging join example or mentioned elsewhere in this specification.

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_member_gemstone_facets_rename - Rename columns for gemstone facets
- stg_member_legacy_facets_rename - Rename columns for legacy facets

**Staging Join Example (for Rename views)**:

```sql
-- Example gemstone join to get prior member business key for same as link
source as (
    select
        sbsb.sbsb_id subscriber_id,
        mem.*,
        coalesce(meda.meda_confid_ind, 'N') confidential_ind,
        p_mem.meme_sfx sal_member_suffix,
        p_sub.subscriber_id sal_subscriber_id
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sub
        on mem.sbsb_ck = sub.sbsb_ck
    left join {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_meme_member') }} p_mem
        on mem.meme_record_no = p_mem.meme_ck
    left join {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc') }} p_sub
        on p_mem.sbsb_ck = p_sub.sbsb_ck
    left join {{ ref('enterprise_data_platform', 'stg_gemstone_bcifacets_hist__dbo_cmc_meda_me_data') }} meda
        on mem.meme_ck = meda.meme_ck
)

-- Example legacy join to get prior member business key for same as link
source as (
    select
        sbsb.sbsb_id subscriber_id,
        mem.*,
        coalesce(meda.meda_confid_ind, 'N') confidential_ind,
        p_mem.meme_sfx sal_member_suffix,
        p_sub.subscriber_id sal_subscriber_id
    from {{ ref('enterprise_data_platform', 'stg_legacy_facets_hist__dbo_cmc_meme_member') }} mem
    inner join {{ ref('enterprise_data_platform', 'stg_legacy_facets_hist__dbo_cmc_sbsb_subsc') }} sub
        on mem.sbsb_ck = sub.sbsb_ck
    left join {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_meda_me_data') }} meda
        on mem.meme_ck = meda.meme_ck
)
```

**Staging Views**:

- stg_member_gemstone_facets - Stage data from cmc_meme_member and cmc_sbsb_subsc for gemstone facets
- stg_member_legacy_facets - Stage data from cmc_meme_member and cmc_sbsb_subsc for legacy facets
- stg_member_gemstone_bcifacets - Stage data from cmc_meda_me_data for gemstone facets
- stg_member_legacy_bcifacets - Stage data from cmc_meda_me_data for legacy facets

**Hubs** (using automate_dv hub macro):

- h_member - Hub for member business key

**Satellites** (using automate_dv sat macro):

- s_member_gemstone_facets - Descriptive attributes from Gemstone Facets system
- s_member_legacy_facets - Descriptive attributes from Legacy Facets system

**Same-As Links** (using automate_dv link macro):

- sal_member_facets - Same-as link for member identity resolution using the sal_subscriber_id and sal_member_suffix columns in the staging view. For Gemstone members, use the meme_record_no to the legacy meme_ck from the source to left join back to the legacy member record and get the subscriber_id and member_suffix they were converted from. **Note**: the staging view should have a hash expression for the sal_member_facets_hk column.

**Source Column Mapping / Payload**

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber identifier - part of member business key |
| cmc_meme_member | meme_sfx | member_suffix | Member suffix - part of member business key |
| N/A | '1' | tenant_id | Tenant identifier constant |
| N/A | gemstone_facets/legacy_facets | source | Source system identifier |
| cmc_meme_member | meme_ck | member_bk | Member control key |
| cmc_meme_member | sbsb_ck | subscriber_bk | Subscriber control key |
| cmc_meme_member | grgr_ck | employer_group_bk | Employer group control key |
| cmc_meme_member | meme_medcd_no | medicaid_no | Medicaid number |
| cmc_meme_member | meme_hicn | member_hicn | Member Health Insurance Claim Number |
| cmc_meme_member | meme_title | member_title | Member title (Mr., Mrs., etc.) |
| cmc_meme_member | meme_first_name | member_first_name | Member first name |
| cmc_meme_member | meme_last_name | member_last_name | Member last name |
| cmc_meme_member | meme_mid_init | member_mid_init | Member middle initial |
| cmc_meme_member | meme_birth_dt | member_birth_dt | Member date of birth |
| cmc_meme_member | meme_rel | member_relationship | Member relationship to subscriber |
| cmc_meme_member | meme_marital_status | member_marital_status | Member marital status |
| cmc_meme_member | meme_sex | member_sex | Member sex |
| cmc_meme_member | meme_mctr_genp_nvl | member_gender_identity | Member gender identity |
| cmc_meme_member | memm_row_id | person_bk | Person business key |
| cmc_meme_member | meme_ssn | member_ssn | Member Social Security Number |
| cmc_meme_member | meme_health_id | member_health_id | Member health identifier |
| cmc_meme_member | meme_mctr_lang | member_language_cd | Member language code |
| cmc_meme_member | meme_ccc_start_dt | creditable_coverage_eff_dt | Creditable coverage effective date |
| cmc_meme_member | meme_ccc_end_dt | creditable_coverage_term_dt | Creditable coverage termination date |
| cmc_meme_member | meme_orig_eff_dt | member_original_eff_dt | Member original effective date |
| cmc_meme_member | meme_prex_eff_dt | pre_existing_eff_dt | Pre-existing condition effective date |
| cmc_meme_member | meme_prx_cred_days | pre_existing_credit_days | Pre-existing condition credit days |
| cmc_meme_member | sbad_type_home | member_address_type_home | Member home address type |
| cmc_meme_member | sbad_type_mail | member_address_type_mail | Member mailing address type |
| cmc_meme_member | sbad_type_work | member_address_type_work | Member work address type |
| cmc_meme_member | sal_subscriber_id | sal_subscriber_id | Same-as link subscriber identifier |
| cmc_meme_member | sal_member_suffix | sal_member_suffix | Same-as link member suffix |
| cmc_meda_me_data | meda_confid_ind | confidential_ind | Confidentiality indicator |
| cmc_meme_member | edp_start_dt | edp_start_dt | EDP start date |
| cmc_meme_member | edp_record_status | edp_record_status | EDP record status |

**Metadata:**

- Deliverables: Member Months, PCP Attribution
- Dependencies: None
