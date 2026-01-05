## Story EDPXXX: Raw Vault Member Student Status: Build Member Student Status Satellites on Member Hub

**Title:**

**Raw Vault Member Student Status: Build Member Student Status Satellites on Member Hub**

**Description:**

As a data engineer,  
I want to create member student status satellites attached to the member hub in the raw vault,  
So that we can track student eligibility verification information changes over time including school enrollment, student type, and verification history.

**Technical Details:**

- **Entity Name**: member_student_status
- **Parent Hub**: h_member (existing)
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_gemstone_facets_hist__dbo_cmc_mest_student`
    - `stg_legacy_bcifacets_hist__dbo_cmc_mest_student`
- **Staging Views**:
  - Join cmc_mest_student to cmc_meme_member on meme_ck, then to cmc_sbsb_subsc on sbsb_ck to inherit the member hub key
- **Business Key** (inherited from parent hub):
  - subscriber_id
  - member_suffix
- **Satellites** (using automate_dv sat macro):
  - s_member_student_status_gemstone_facets - Member student eligibility attributes from Gemstone system
  - s_member_student_status_legacy_facets - Member student eligibility attributes from legacy system

- **Staging Join Example (for Rename view)**

```sql
-- Example join to get member hub key for member student status satellites
source as (
    select
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        mest.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_mest_student') }} mest
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on mest.meme_ck = mem.meme_ck
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on mem.sbsb_ck = sbsb.sbsb_ck
)
```

**Source Column Mapping / Payload**

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|-------------------|
| ...cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| ...cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| ...cmc_mest_student | meme_ck | member_bk | Member Contrived Key |
| ...cmc_mest_student | grgr_ck | employer_group_bk | Group Contrived Key |
| ...cmc_mest_student | mest_eff_dt | student_status_eff_dt | Student Effective Date |
| ...cmc_mest_student | mest_term_dt | student_status_term_dt | Student Termination Date |
| ...cmc_mest_student | mest_mctr_trsn | student_status_termination_reason | Student Termination Reason |
| ...cmc_mest_student | mest_school_name | school_name | School Name |
| ...cmc_mest_student | mest_type | student_type | Student Type |
| ...cmc_mest_student | mest_last_ver_dt | student_status_last_verification_dt | Last Verification Date |
| ...cmc_mest_student | mest_last_ver_name | student_status_last_verification_name | Last Verification Name |
| ...cmc_mest_student | mest_mctr_vmth | student_status_verification_method | Verification Method |
| ...cmc_mest_student | mest_lock_token | student_status_lock_token | Lock Token |
| ...cmc_mest_student | atxr_source_id | attachment_source_id | Attachment Source ID |
| ...cmc_mest_student | sys_last_upd_dtm | source_last_update_dtm | Last Update Datetime |
| ...cmc_mest_student | sys_usus_id | source_last_update_user_id | Last Update User ID |
| ...cmc_mest_student | sys_dbuser_id | source_db_user_id | Last Update DBMS User ID |
| ...cmc_mest_student | edp_start_dt | edp_start_dt | EDP Start Date |
| ...cmc_mest_student | edp_record_status | edp_record_status | EDP Record Status |

**Acceptance Criteria:**

**Given** the member hub (h_member) exists with loaded member records,  
**when** the member student status satellite models execute,  
**then** all member student status records are loaded with valid member hub hash keys and load timestamps.

**Given** multiple source records exist for the same member over time,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the member student status satellites are loaded,  
**when** the satellites are compared to the source staging models,  
**then** the record counts match.

**Given** the member student status satellites reference the member hub,  
**when** referential integrity checks run,  
**then** all member_hk values in the satellites exist in h_member.

**Metadata:**

- Story ID: TBD
- Architect Estimate: 2 days
- Deliverables: Member student eligibility history, school enrollment tracking, verification audit trail
- Dependencies: h_member hub must exist
