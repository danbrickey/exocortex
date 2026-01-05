## Story EDPXXX: Raw Vault Subscriber Employment: Build Subscriber Employment Satellites on Member Hub

**Title:**

**Raw Vault Subscriber Employment: Build Subscriber Employment Satellites on Member Hub**

**Description:**

As a data engineer,  
I want to create subscriber employment satellites attached to the member hub in the raw vault,  
So that we can track subscriber employment information changes over time including occupation, department, location, and employment type.

**Technical Details:**

- **Entity Name**: subscriber_employment
- **Parent Hub**: h_member (existing)
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_gemstone_facets_hist__dbo_cmc_sbem_employ`
    - `stg_legacy_bcifacets_hist__dbo_cmc_sbem_employ`
- **Staging Views**:
  - Join cmc_sbem_employ to cmc_sbsb_subsc on sbsb_ck, then to cmc_meme_member on sbsb_ck = meme_ck to inherit the member hub key
- **Business Key** (inherited from parent hub):
  - subscriber_id
  - member_suffix
- **Satellites** (using automate_dv sat macro):
  - s_subscriber_employment_gemstone_facets - Subscriber employment attributes from Gemstone system
  - s_subscriber_employment_legacy_facets - Subscriber employment attributes from legacy system

- **Staging Join Example (for Rename view)**

```sql
-- Example join to get member hub key for subscriber employment satellites
source as (
    select
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        sbem.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbem_employ') }} sbem
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on sbem.sbsb_ck = sbsb.sbsb_ck
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
| ...cmc_sbem_employ | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| ...cmc_sbem_employ | grgr_ck | employer_group_bk | Group Contrived Key |
| ...cmc_sbem_employ | sbem_eff_dt | employment_eff_dt | Subscriber Employment Effective Date |
| ...cmc_sbem_employ | sbem_term_dt | employment_term_dt | Subscriber Employment Termination Date |
| ...cmc_sbem_employ | sbem_mctr_trsn | employment_termination_reason | Subscriber Employment Termination Reason |
| ...cmc_sbem_employ | sbem_occ_cd | occupation_cd | Subscriber Occupation Code |
| ...cmc_sbem_employ | sbem_dept | department_cd | Subscriber Department Code |
| ...cmc_sbem_employ | sbem_loc | employment_location | Subscriber Location |
| ...cmc_sbem_employ | sbem_type | employment_type | Subscriber Employment Type |
| ...cmc_sbem_employ | sbem_mctr_dtyp | non_discrimination_type | Non Discrimination Type |
| ...cmc_sbem_employ | sbem_lock_token | employment_lock_token | Lock Token |
| ...cmc_sbem_employ | atxr_source_id | attachment_source_id | Attachment Source ID |
| ...cmc_sbem_employ | edp_start_dt | edp_start_dt | EDP Start Date |
| ...cmc_sbem_employ | edp_record_status | edp_record_status | EDP Record Status |

**Acceptance Criteria:**

**Given** the member hub (h_member) exists with loaded member records,  
**when** the subscriber employment satellite models execute,  
**then** all subscriber employment records are loaded with valid member hub hash keys and load timestamps.

**Given** multiple source records exist for the same member over time,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the subscriber employment satellites are loaded,  
**when** the satellites are compared to the source staging models,  
**then** the record counts match.

**Given** the subscriber employment satellites reference the member hub,  
**when** referential integrity checks run,  
**then** all member_hk values in the satellites exist in h_member.

**Metadata:**

- Story ID: TBD
- Architect Estimate: 2 days
- Deliverables: Subscriber employment history, occupation tracking, department and location history
- Dependencies: h_member hub must exist
