## Story EDPXXX: Raw Vault Subscriber: Build Subscriber Satellites on Member Hub

**Title:**

**Raw Vault Subscriber: Build Subscriber Satellites on Member Hub**

**Description:**

As a data engineer,  
I want to create subscriber satellites attached to the member hub in the raw vault,  
So that we can track subscriber-level demographic and indicative data changes over time while maintaining the member as the core grain.

**Technical Details:**

- **Entity Name**: subscriber
- **Parent Hub**: h_member (existing)
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`
    - `stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc`
- **Staging Views**:
  - Join cmc_sbsb_subsc to cmc_meme_member on sbsb_ck to inherit the member hub key
- **Business Key** (inherited from parent hub):
  - subscriber_id
  - member_suffix
- **Satellites** (using automate_dv sat macro):
  - s_subscriber_gemstone_facets - Subscriber indicative attributes from Gemstone system
  - s_subscriber_legacy_facets - Subscriber indicative attributes from legacy system

- **Staging Join Example (for Rename view)**

```sql
-- Example join to get member hub key for subscriber satellites
source as (
    select
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        sbsb.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on sbsb.sbsb_ck = mem.meme_ck
)
```

**Source Column Mapping / Payload**

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|-------------------|
| ...cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| ...cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| ...cmc_sbsb_subsc | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| ...cmc_sbsb_subsc | grgr_ck | employer_group_bk | Group Contrived Key |
| ...cmc_sbsb_subsc | sbsb_last_name | subscriber_last_name | Subscriber Last Name |
| ...cmc_sbsb_subsc | sbsb_first_name | subscriber_first_name | Subscriber First Name |
| ...cmc_sbsb_subsc | sbsb_mid_init | subscriber_mid_init | Subscriber Middle Initial |
| ...cmc_sbsb_subsc | sbsb_title | subscriber_title | Subscriber Title |
| ...cmc_sbsb_subsc | sbsb_orig_eff_dt | subscriber_original_eff_dt | Subscriber Original Effective Date |
| ...cmc_sbsb_subsc | sbsb_mctr_sts | subscriber_status | Subscriber Status |
| ...cmc_sbsb_subsc | sbsb_mctr_vip | subscriber_vip_type | Subscriber VIP Type |
| ...cmc_sbsb_subsc | sbsb_mctr_srsn | subscriber_status_reason | Status Reason Code |
| ...cmc_sbsb_subsc | sbsb_prcs_sts | subscriber_processing_status | Processing Status |
| ...cmc_sbsb_subsc | sbsb_employ_id | employee_id | Employee Identifier |
| ...cmc_sbsb_subsc | sbsb_hire_dt | subscriber_hire_dt | Subscriber Hire Date |
| ...cmc_sbsb_subsc | sbsb_retire_dt | subscriber_retire_dt | Subscriber Retire Date |
| ...cmc_sbsb_subsc | sbsb_conv_dt | subscriber_conversion_dt | Conversion Date |
| ...cmc_sbsb_subsc | sbsb_fi | subscriber_family_ind | Subscriber Family Indicator |
| ...cmc_sbsb_subsc | sbsb_pay_cl_meth | subscriber_claim_pay_method | Subscriber Claim Payment Method |
| ...cmc_sbsb_subsc | sbsb_eft_ind | subscriber_eft_ind | Electronic Fund Transfer Indicator |
| ...cmc_sbsb_subsc | sbad_type_home | subscriber_address_type_home | Subscriber Home Address Type |
| ...cmc_sbsb_subsc | sbad_type_mail | subscriber_address_type_mail | Subscriber Mailing Address Type |
| ...cmc_sbsb_subsc | sbad_type_work | subscriber_address_type_work | Subscriber Work Address Type |
| ...cmc_sbsb_subsc | sbsb_last_name_xlow | subscriber_last_name_search | Name Search (Case Insensitive) |
| ...cmc_sbsb_subsc | mcbr_ck | bank_relationship_bk | Bank Relationship Contrived Key |
| ...cmc_sbsb_subsc | sbsb_sig_dt | subscriber_signature_dt | Signature Date |
| ...cmc_sbsb_subsc | sbsb_recd_dt | subscriber_received_dt | Received Date |
| ...cmc_sbsb_subsc | sbsb_pay_fsac_meth | subscriber_fsa_pay_method | FSA Claim Payment Method |
| ...cmc_sbsb_subsc | sbsb_lock_token | subscriber_lock_token | Lock Token |
| ...cmc_sbsb_subsc | atxr_source_id | attachment_source_id | Attachment Source ID |
| ...cmc_sbsb_subsc | sbsb_mlr_eft_ind_nvl | subscriber_mlr_eft_ind | MLR Electronic Fund Transfer Indicator |
| ...cmc_sbsb_subsc | sys_last_upd_dtm | source_last_update_dtm | Source Last Update Datetime |
| ...cmc_sbsb_subsc | sys_usus_id | source_last_update_user_id | Source Last Update User ID |
| ...cmc_sbsb_subsc | sys_dbuser_id | source_db_user_id | Source DBMS User ID |
| ...cmc_sbsb_subsc | edp_start_dt | edp_start_dt |
| ...cmc_sbsb_subsc | edp_record_status | edp_record_status |

**Acceptance Criteria:**

**Given** the member hub (h_member) exists with loaded member records,  
**when** the subscriber satellite models execute,  
**then** all subscriber records are loaded with valid member hub hash keys and load timestamps.

**Given** multiple source records exist for the same subscriber over time,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the subscriber satellites reference the member hub,  
**when** referential integrity checks run,  
**then** all member_hk values in the satellites exist in h_member.

**Metadata:**

- Story ID: TBD
- Architect Estimate: 3 days
- Deliverables: Subscriber demographics, subscriber status tracking
- Dependencies: h_member hub must exist
