# User Story: Member COB Profile Data Vault 2.0 Implementation

## Story Overview

**As a** Data Engineer
**I want to** refactor the member COB (Coordination of Benefits) profile data into Data Vault 2.0 structures
**So that** we can maintain a complete, auditable history of member COB relationships with proper source system tracking and effectivity periods

## Business Context

The member COB profile tracks coordination of benefits information for members, including insurance type, order, supplemental drug coverage, policy details, and verification information. This data comes from two source systems (legacy_facets and gemstone_facets) and requires proper temporal tracking through effectivity dates.

## Acceptance Criteria

### 1. Hub Creation

- [ ] Create `h_cob_indicator` hub with composite business key
  - Composite key components: `insurance_type_cd`, `insurance_order_cd`, `supp_drug_type_cd`
  - Generate `cob_indicator_hk` from composite business key
  - Track first source system that introduced each COB indicator configuration
  - Deduplicate across both source systems

### 2. Link Creation

- [ ] Create `l_member_cob` link to connect members with COB indicators
  - Link `h_member` and `h_cob_indicator` hubs
  - Generate `member_cob_hk` from `member_bk` + composite COB indicator key
  - Track first source system that introduced each relationship
  - Deduplicate across both source systems

### 3. Staging Layers

- [ ] Create rename staging models for both source systems
  - `stg_member_cob_gemstone_facets_rename.sql` - Gemstone source
  - `stg_member_cob_legacy_facets_rename.sql` - Legacy source
  - Map source column names to standardized names
  - Add source system identifier

- [ ] Create hash key staging models for both source systems
  - `stg_member_cob_gemstone_facets.sql` - Gemstone with hash keys
  - `stg_member_cob_legacy_facets.sql` - Legacy with hash keys
  - Generate `member_hk` from `member_bk`
  - Generate `cob_indicator_hk` from composite business key
  - Generate `member_cob_hk` from combined keys
  - NO deprecated `member_cob_ik` column

### 4. Effectivity Satellites

- [ ] Create effectivity satellites attached to `l_member_cob` link
  - `s_member_cob_gemstone_facets.sql` - Gemstone source attributes
  - `s_member_cob_legacy_facets.sql` - Legacy source attributes
  - Track effectivity periods using `effective_dt` and `termination_dt`
  - Include all descriptive attributes and system columns
  - Use `member_cob_hk` as `src_pk`
  - Set `src_eff` = `effective_dt`
  - Set `src_start_date` = `effective_dt`
  - Set `src_end_date` = `termination_dt`
  - NO `member_cob_ik` in `src_extra_columns`
  - Implement hash diff for change detection

### 5. Current View

- [ ] Create `current_member_cob.sql` view
  - Join link with both hubs and effectivity satellites
  - Apply effectivity logic: `CURRENT_DATE BETWEEN src_start_date AND COALESCE(src_end_date, '9999-12-31')`
  - Prioritize gemstone_facets over legacy_facets
  - Return most recent effective record per member_cob_hk
  - Include all business keys, attributes, and metadata

### 6. Data Quality

- [ ] Ensure no NULL values in business keys
- [ ] Validate hash key generation consistency
- [ ] Verify effectivity period logic
- [ ] Confirm deduplication across source systems
- [ ] Validate incremental load logic

## Technical Notes

### Source Tables
- **Gemstone**: `gemstone_facets.dbo.cmc_mecb_cob`
- **Legacy**: `legacy_facets.dbo.cmc_mecb_cob`

### Key Patterns

**Hub Pattern - h_cob_indicator:**
- NEW hub with composite business key
- Represents unique COB indicator configurations
- Business keys: `insurance_type_cd`, `insurance_order_cd`, `supp_drug_type_cd`

**Link Pattern - l_member_cob:**
- Links members to COB indicator configurations
- Parent hubs: `h_member`, `h_cob_indicator`
- Link hash key combines both parent hub business keys

**Effectivity Satellite Pattern:**
- Attached to link (not hub)
- Tracks time-bound attributes
- Uses `src_start_date` and `src_end_date` for effectivity
- Supports bi-temporal tracking (load time vs. business time)

### Column Mappings

| Source Column | Target Column | Notes |
|--------------|---------------|-------|
| meme_ck | member_bk | Member business key |
| mecb_insur_type | insurance_type_cd | Part of composite COB indicator key |
| mecb_insur_order | insurance_order_cd | Part of composite COB indicator key |
| mecb_mctr_styp | supp_drug_type_cd | Part of composite COB indicator key |
| mecb_eff_dt | effective_dt | Effectivity start date |
| mecb_term_dt | termination_dt | Effectivity end date |
| mecb_mctr_trsn | termination_reason_cd | Termination reason |
| grgr_ck | group_bk | Group business key |
| mcre_id | carrier_id | Carrier identifier |
| mecb_policy_id | policy_id | Policy identifier |
| mecb_mctr_msp | medicare_secondary_payer_type_cd | Medicare secondary payer type |
| mecb_mctr_ptyp | rx_coverage_type_cd | Prescription coverage type |
| mecb_rxbin | rx_bin_nbr | RX BIN number |
| mecb_rxpcn | rx_pcn_nbr | RX PCN number |
| mecb_rx_group | rx_group_nbr | RX group number |
| mecb_rx_id | rx_id | RX identifier |
| mecb_last_ver_dt | last_verification_dt | Last verification date |
| mecb_last_ver_name | last_verification_nm | Last verification name |
| mecb_mctr_vmth | verification_method_cd | Verification method |
| mecb_loi_start_dt | loi_start_dt | Letter of Intent start date |
| mecb_prim_last_nm | primary_holder_last_nm | Primary holder last name |
| mecb_prim_first_nm | primary_holder_first_nm | Primary holder first name |
| mecb_prim_id | primary_holder_id | Primary holder ID |
| mecb_lock_token | lock_token_nbr | Lock token number |
| atxr_source_id | attachment_source_id | Attachment source ID |
| sys_last_upd_dtm | last_update_dtm | Last update timestamp |
| sys_usus_id | last_update_user_id | Last update user ID |
| sys_dbuser_id | last_update_db_user_id | Last update database user ID |

### Deprecated Patterns to AVOID

- DO NOT create `member_cob_ik` columns
- DO NOT use surrogate keys from source systems
- DO NOT include `member_cob_ik` in staging or satellite models

## Dependencies

- `h_member` hub must exist
- dbt_utils package for hash key generation
- Both source systems must be accessible

## Definition of Done

- [ ] All SQL files created and validated
- [ ] Models build successfully in dbt
- [ ] Incremental loads tested
- [ ] Current view returns expected results
- [ ] Source system prioritization works correctly
- [ ] Effectivity logic validated
- [ ] No deprecated patterns present
- [ ] Code review completed
- [ ] Documentation updated

## Estimated Effort

**Story Points:** 8

**Breakdown:**
- Hub creation: 1 point
- Link creation: 1 point
- Staging models (4 files): 2 points
- Effectivity satellites (2 files): 2 points
- Current view: 1 point
- Testing and validation: 1 point

## Related Stories

- Member rating Data Vault 2.0 implementation
- Member disability Data Vault 2.0 implementation
- Member student status Data Vault 2.0 implementation
