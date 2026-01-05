## Story EDPXXX: Raw Vault Subscriber Warning Message: Build Subscriber Warning Message Satellites on Member Hub

**Title:**

**Raw Vault Subscriber Warning Message: Build Subscriber Warning Message Satellites on Member Hub**

**Description:**

As a data engineer,  
I want to create subscriber warning message satellites attached to the member hub in the raw vault,  
So that we can track subscriber-level warning messages over time including effective periods and termination reasons.

**Technical Details:**

- **Entity Name**: subscriber_warning_msg
- **Parent Hub**: h_member (existing)
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_gemstone_facets_hist__dbo_cmc_sbwm_sb_msg`
    - `stg_legacy_bcifacets_hist__dbo_cmc_sbwm_sb_msg`
- **Staging Views**:
  - Join cmc_sbwm_sb_msg to cmc_sbsb_subsc on sbsb_ck, then to cmc_meme_member on sbsb_ck = meme_ck to inherit the member hub key
- **Business Key** (inherited from parent hub):
  - subscriber_id
  - member_suffix
- **Satellites** (using automate_dv sat macro):
  - s_subscriber_warning_msg_gemstone_facets - Subscriber warning message attributes from Gemstone system
  - s_subscriber_warning_msg_legacy_facets - Subscriber warning message attributes from legacy system

- **Staging Join Example (for Rename view)**

```sql
-- Example join to get member hub key for subscriber warning message satellites
source as (
    select
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        sbwm.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbwm_sb_msg') }} sbwm
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on sbwm.sbsb_ck = sbsb.sbsb_ck
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
| ...cmc_sbwm_sb_msg | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| ...cmc_sbwm_sb_msg | grgr_ck | employer_group_bk | Group Contrived Key |
| ...cmc_sbwm_sb_msg | wmds_seq_no | warning_message_id | Message ID |
| ...cmc_sbwm_sb_msg | sbwm_eff_dt | warning_msg_eff_dt | Effective Date |
| ...cmc_sbwm_sb_msg | sbwm_term_dt | warning_msg_term_dt | Termination Date |
| ...cmc_sbwm_sb_msg | sbwm_mctr_trsn | warning_msg_termination_reason | Termination Reason |
| ...cmc_sbwm_sb_msg | sbwm_lock_token | warning_msg_lock_token | Lock Token |
| ...cmc_sbwm_sb_msg | atxr_source_id | attachment_source_id | Attachment Source ID |
| ...cmc_sbwm_sb_msg | sys_last_upd_dtm | source_last_update_dtm | Last Update Datetime |
| ...cmc_sbwm_sb_msg | sys_usus_id | source_last_update_user_id | Last Update User ID |
| ...cmc_sbwm_sb_msg | sys_dbuser_id | source_db_user_id | Last Update DBMS User ID |
| ...cmc_sbwm_sb_msg | edp_start_dt | edp_start_dt | EDP Start Date |
| ...cmc_sbwm_sb_msg | edp_record_status | edp_record_status | EDP Record Status |

**Acceptance Criteria:**

**Given** the member hub (h_member) exists with loaded member records,  
**when** the subscriber warning message satellite models execute,  
**then** all subscriber warning message records are loaded with valid member hub hash keys and load timestamps.

**Given** multiple source records exist for the same member over time,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the subscriber warning message satellites are loaded,  
**when** the satellites are compared to the source staging models,  
**then** the record counts match.

**Given** the subscriber warning message satellites reference the member hub,  
**when** referential integrity checks run,  
**then** all member_hk values in the satellites exist in h_member.

**Metadata:**

- Story ID: TBD
- Architect Estimate: 2 days
- Deliverables: Subscriber warning message history, message tracking
- Dependencies: h_member hub must exist
