## Story EDPXXX: Raw Vault Member Rating: Build Member Rating Satellites on Member Hub

**Title:**

**Raw Vault Member Rating: Build Member Rating Satellites on Member Hub**

**Description:**

As a data engineer,  
I want to create member rating satellites attached to the member hub in the raw vault,  
So that we can track member-level rate data changes over time including underwriting classifications and smoker status.

**Technical Details:**

- **Entity Name**: member_rating
- **Parent Hub**: h_member (existing)
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_gemstone_facets_hist__dbo_cmc_mert_rate_data`
    - `stg_legacy_bcifacets_hist__dbo_cmc_mert_rate_data`
- **Staging Views**:
  - Join cmc_mert_rate_data to cmc_meme_member on meme_ck, then to cmc_sbsb_subsc on sbsb_ck to inherit the member hub key
- **Business Key** (inherited from parent hub):
  - subscriber_id
  - member_suffix
- **Satellites** (using automate_dv sat macro):
  - s_member_rating_gemstone_facets - Member rate data attributes from Gemstone system
  - s_member_rating_legacy_facets - Member rate data attributes from legacy system

- **Staging Join Example (for Rename view)**

```sql
-- Example join to get member hub key for member rating satellites
source as (
    select
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        mert.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_mert_rate_data') }} mert
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on mert.meme_ck = mem.meme_ck
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
| ...cmc_mert_rate_data | meme_ck | member_bk | Member Contrived Key |
| ...cmc_mert_rate_data | grgr_ck | employer_group_bk | Group Contrived Key |
| ...cmc_mert_rate_data | mert_eff_dt | member_rate_eff_dt | Member Rate Data Effective Date |
| ...cmc_mert_rate_data | mert_term_dt | member_rate_term_dt | Member Rate Data Termination Date |
| ...cmc_mert_rate_data | mert_smoker_ind | member_smoker_ind | Smoker Indicator |
| ...cmc_mert_rate_data | mert_mctr_fct1 | underwriting_class_1 | Underwriting Classification 1 |
| ...cmc_mert_rate_data | mert_mctr_fct2 | underwriting_class_2 | Underwriting Classification 2 |
| ...cmc_mert_rate_data | mert_mctr_fct3 | underwriting_class_3 | Underwriting Classification 3 |
| ...cmc_mert_rate_data | mert_lock_token | rate_lock_token | Lock Token |
| ...cmc_mert_rate_data | atxr_source_id | attachment_source_id | Attachment Source ID |
| ...cmc_mert_rate_data | edp_start_dt | edp_start_dt |
| ...cmc_mert_rate_data | edp_record_status | edp_record_status |

**Acceptance Criteria:**

**Given** the member hub (h_member) exists with loaded member records,  
**when** the member rating satellite models execute,  
**then** all member rating records are loaded with valid member hub hash keys and load timestamps.

**Given** multiple source records exist for the same member over time,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the member rating satellites are loaded,  
**when** the satellites are compared to the source staging models,  
**then** the record counts match.

**Given** the member rating satellites reference the member hub,  
**when** referential integrity checks run,  
**then** all member_hk values in the satellites exist in h_member.

**Metadata:**

- Story ID: TBD
- Architect Estimate: 2 days
- Deliverables: Member rating history, underwriting classification tracking
- Dependencies: h_member hub must exist
