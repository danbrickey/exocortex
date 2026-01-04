## Story EDP035: Raw Vault Member Member: Build Core Member Hub and Satellites

**Title:**

**Raw Vault Member: Build Core Member Hub and Satellites**

**Description:**

As a data engineer,  
I want to refactor the member hub and associated satellites in the raw vault,  
so that we can track member demographic changes over time and support member months and PCP attribution analytics.

**Technical Details:**

- **Entity Name**: member
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_legacy_bcifacets_hist__dbo_cmc_meme_member`
    - `stg_gemstone_facets_hist__dbo_cmc_meme_member`
    - `stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc`
    - `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`
- **Staging Views**:
  - join cmc_meme_member to cmc_sbsb_subsc on sbsb_ck
- **Business Key**
  - subscriber_id
  - member_suffix
- **Hubs** (using automate_dv hub macro):
  - h_member - Hub for member business key
- **Satellites** (using automate_dv sat macro):
  - s_member_gemstone_facets - Descriptive attributes from Gemstone system
  - s_member_legacy_facets - Descriptive attributes from legacy system
- **Same-As Links** (using automate_dv link macro):
  For Gemstone members, use the meme_record_no to the legacy meme_ck from the source to left join back to the legacy member record and get the subscriber_id and member_suffix they were converted from. This will be used to populate the same as link sal_member_facets
  ```sql
  -- Example join to get prior member business key for same as link
  source as (
  select
      sbsb.sbsb_id subscriber_id,
      mem.*,
      p_mem.meme_sfx sal_member_suffix,
      p_sub.subscriber_id sal_subscriber_id
  from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
  inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sub
  on mem.sbsb_ck = sub.sbsb_ck
  left join {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_meme_member') }} p_mem
  on mem.meme_record_no = p_mem.meme_ck
  left join {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc') }} p_sub
  on p_mem.sbsb_ck = p_sub.sbsb_ck
  )
  ```
  - sal_member_facets - Same-as link for member identity resolution using the sal_subscriber_id and sal_member_suffix columns in the staging view.
  - The member staging view should have a hash expression for the sal_member_facets_hk column.

**Source Column Mapping / Payload**
| source_table | source_column | target_column |
|---------------|---------------|------------ |
| ...cmc_sbsb_subsc | sbsb_id | subscriber_id |
| ...cmc_meme_member | meme_sfx | member_suffix |
| N/A | '1' | tenant_id |
| N/A | gemstone_facets/legacy_facets | source |
| ...cmc_meme_member | meme_ck | member_bk |
| ...cmc_meme_member | sbsb_ck | subscriber_bk |
| ...cmc_meme_member | grgr_ck | employer_group_bk |
| ...cmc_meme_member | meme_medcd_no | medicaid_no |
| ...cmc_meme_member | meme_hicn | member_hicn |
| ...cmc_meme_member | meme_title | member_title |
| ...cmc_meme_member | meme_first_name | member_first_name |
| ...cmc_meme_member | meme_last_name | member_last_name |
| ...cmc_meme_member | meme_mid_init | member_mid_init |
| ...cmc_meme_member | meme_birth_dt | member_birth_dt |
| ...cmc_meme_member | meme_rel | member_relationship |
| ...cmc_meme_member | meme_marital_status | member_marital_status |
| ...cmc_meme_member | meme_sex | member_sex |
| ...cmc_meme_member | meme_mctr_genp_nvl | member_gender_identity |
| ...cmc_meme_member | memm_row_id | person_bk |
| ...cmc_meme_member | meme_ssn | member_ssn |
| ...cmc_meme_member | meme_health_id | member_health_id |
| ...cmc_meme_member | meme_mctr_lang | member_language_cd |
| ...cmc_meme_member | meme_ccc_start_dt | creditable_coverage_eff_dt |
| ...cmc_meme_member | meme_ccc_end_dt | creditable_coverage_term_dt |
| ...cmc_meme_member | meme_orig_eff_dt | member_original_eff_dt |
| ...cmc_meme_member | meme_prex_eff_dt | pre_existing_eff_dt |
| ...cmc_meme_member | meme_prx_cred_days | pre_existing_credit_days |
| ...cmc_meme_member | sbad_type_home | member_address_type_home |
| ...cmc_meme_member | sbad_type_mail | member_address_type_mail |
| ...cmc_meme_member | sbad_type_work | member_address_type_work |
| ...cmc_meme_member | sal_subscriber_id | sal_subscriber_id |
| ...cmc_meme_member | sal_member_suffix | sal_member_suffix |

**Acceptance Criteria:**

**Given** source data is loaded to staging views,  
**when** the hub model executes,  
**then** all unique member business keys are loaded with valid hash keys and load timestamps.

**Given** multiple source records exist for the same member,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the hub is loaded,  
**when** the hub is compared to **h_member_count**,  
**then** the key counts in the hub match the source records.
The test should look like this:

```yml
models:
  - name: h_member
    tests:
      - source_count_match:
          business_key_column: member_hk
          source_model: h_member_count
```

**Given** the same-as link is populated,  
**when** the link is compared to **sal_member_facets_count**,
**then** all member records are correctly linked across source systems with valid hub references.
The test should look like this:

```yml
models:
  - name: sal_member_facets
    tests:
      - source_count_match:
          business_key_column: sal_member_facets_hk
          source_model: sal_member_facets_count
```

**Metadata:**

- Architect Estimate: 6 days
- Deliverables: Member Months, PCP Attribution
