## Story EDPXXX: Raw Vault Subscriber Rating: Build Subscriber Rating Satellites on Member Hub

**Title:**

**Raw Vault Subscriber Rating: Build Subscriber Rating Satellites on Member Hub**

**Description:**

As a data engineer,  
I want to create subscriber rating satellites attached to the member hub in the raw vault,  
So that we can track subscriber premium rate factoring data changes over time including billing indicators, smoker status, and geographic rating factors.

**Technical Details:**

- **Entity Name**: subscriber_rating
- **Parent Hub**: h_member (existing)
- **Source Data**:
  - Source Project: `enterprise_data_platform`
  - Source Models:
    - `stg_gemstone_facets_hist__dbo_cmc_sbrt_rate_data`
    - `stg_legacy_bcifacets_hist__dbo_cmc_sbrt_rate_data`
- **Staging Views**:
  - Join cmc_sbrt_rate_data to cmc_sbsb_subsc on sbsb_ck, then to cmc_meme_member on sbsb_ck to inherit the member hub key
- **Business Key** (inherited from parent hub):
  - subscriber_id
  - member_suffix
- **Satellites** (using automate_dv sat macro):
  - s_subscriber_rating_gemstone_facets - Subscriber premium rate attributes from Gemstone system
  - s_subscriber_rating_legacy_facets - Subscriber premium rate attributes from legacy system

- **Staging Join Example (for Rename view)**

```sql
-- Example join to get member hub key for subscriber rating satellites
source as (
    select
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        sbrt.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbrt_rate_data') }} sbrt
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on sbrt.sbsb_ck = sbsb.sbsb_ck
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
| ...cmc_sbrt_rate_data | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| ...cmc_sbrt_rate_data | grgr_ck | employer_group_bk | Group Contrived Key |
| ...cmc_sbrt_rate_data | sbrt_eff_dt | subscriber_rating_eff_dt | Data Row Effective Date |
| ...cmc_sbrt_rate_data | sbrt_term_dt | subscriber_rating_term_dt | Data Row Termination Date |
| ...cmc_sbrt_rate_data | sbrt_sb_bill_ind | subscriber_billing_ind | Subscriber Billing Indicator |
| ...cmc_sbrt_rate_data | sbrt_smoker_ind | subscriber_smoker_ind | Smoker Indicator for Rating |
| ...cmc_sbrt_rate_data | sbrt_rt_st | rating_state | Rating State |
| ...cmc_sbrt_rate_data | sbrt_rt_cnty | rating_county | Rating County |
| ...cmc_sbrt_rate_data | sbrt_rt_area | rating_area | Rating Area |
| ...cmc_sbrt_rate_data | sbrt_rt_sic | rating_sic_naics | Standard Industry Class./NAICS |
| ...cmc_sbrt_rate_data | sbrt_lock_token | subscriber_rating_lock_token | Lock Token |
| ...cmc_sbrt_rate_data | atxr_source_id | attachment_source_id | Attachment Source ID |
| ...cmc_sbrt_rate_data | edp_start_dt | edp_start_dt | EDP Start Date |
| ...cmc_sbrt_rate_data | edp_record_status | edp_record_status | EDP Record Status |

**Acceptance Criteria:**

**Given** the member hub (h_member) exists with loaded member records,  
**when** the subscriber rating satellite models execute,  
**then** all subscriber rating records are loaded with valid member hub hash keys and load timestamps.

**Given** multiple source records exist for the same member over time,  
**when** the satellite models execute,  
**then** only records with changed attributes create new satellite records with proper effective dating.

**Given** gemstone and legacy facets are loaded,  
**when** data quality checks run,  
**then** no null values exist in required business key columns and all hash keys are valid.

**Given** the subscriber rating satellites are loaded,  
**when** the satellites are compared to the source staging models,  
**then** the record counts match.

**Given** the subscriber rating satellites reference the member hub,  
**when** referential integrity checks run,  
**then** all member_hk values in the satellites exist in h_member.

**Metadata:**

- Story ID: TBD
- Architect Estimate: 2 days
- Deliverables: Subscriber premium rating history, geographic rating tracking, smoker status history
- Dependencies: h_member hub must exist
