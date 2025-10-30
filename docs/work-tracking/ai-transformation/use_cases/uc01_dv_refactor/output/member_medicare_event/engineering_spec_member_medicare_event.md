# Engineering Specification: member_medicare_event

## Overview

This specification provides guidance for refactoring the member_medicare_event entity from 3NF to Data Vault 2.0 structure. The source data comes from `dbo.cmc_memd_mecr_detl` in both legacy_facets and gemstone_facets systems.

## Data Vault Structure

### Hubs
- **h_member** (existing hub) - Business key: `meme_ck`
- **h_medicare_event** (new hub) - Business key: `memd_event_cd`

### Links
- **l_member_medicare_event** - Connects member and medicare_event hubs

### Satellites
- **s_member_medicare_event_legacy_facets** (effectivity satellite)
- **s_member_medicare_event_gemstone_facets** (effectivity satellite)

## Source Systems

- `legacy_facets`
- `gemstone_facets`

## Business Keys

```sql
-- Member business key
member_bk: meme_ck

-- Medicare Event business key
medicare_event_bk: memd_event_cd

-- Link business key (composite)
member_medicare_event_bk:
  - meme_ck
  - memd_event_cd
```

## Hash Keys

```sql
-- Hub hash keys
member_hk: md5(concat(meme_ck))
medicare_event_hk: md5(concat(memd_event_cd))

-- Link hash key
member_medicare_event_lk: md5(concat(member_hk, medicare_event_hk))
```

## Column Mappings

### Source to Renamed Columns

```sql
-- Business Keys
meme_ck -> member_ck
memd_event_cd -> medicare_event_cd

-- Effectivity Dates
memd_hcfa_eff_dt -> hcfa_eff_dt (src_eff, src_start_date)
memd_hcfa_term_dt -> hcfa_term_dt (src_end_date)

-- Group Keys
grgr_ck -> group_ck

-- Date Fields
memd_input_dt -> input_dt
memd_event_eff_dt -> event_eff_dt
memd_event_term_dt -> event_term_dt
memd_sig_dt -> signature_dt

-- Medicare Codes
memd_mctr_mcst -> medicare_state
memd_mctr_mcct -> medicare_county
memd_mctr_pbp -> medicare_plan_benefit_pkg
memd_mctr_rx_group -> medicare_rx_group_id
memd_mctr_rxbin -> medicare_rxbin
memd_mctr_rxpcn -> medicare_rxpcn
memd_mctr_srsn_nvl -> medicare_sep_reason
memd_mctr_erel_nvl -> medicare_enrollee_relation

-- HICN
meme_hicn -> health_ins_claim_number

-- Benefit Group
bgbg_ck -> benefit_group_ck

-- Risk Adjustment
mrac_cat -> pipdcg_category
memd_ra_prta_fctr -> risk_adj_part_a_factor
memd_ra_prtb_fctr -> risk_adj_part_b_factor
memd_ra_prtd_fctr -> risk_adj_part_d_factor
memd_ra_fctr_type -> risk_adj_factor_type
memd_rad_fctr_type -> risk_adj_part_d_fctr_type

-- Election and Enrollment
memd_elect_type -> election_type
memd_segment_id -> segment_id
memd_enrl_source -> enrollment_source
memd_prem_wh_opt -> premium_withhold_option
memd_prior_com_ovr -> prior_commercial_override

-- Premiums
memd_prtc_prem -> part_c_premium
memd_prtd_prem -> part_d_premium

-- Part D Information
memd_uncov_mos -> uncovered_months
memd_rx_id -> part_d_id

-- COB (Coordination of Benefits)
memd_cob_ind -> secondary_drug_ins_flag
memd_cob_rx_id -> secondary_drug_ins_id
memd_cob_rx_group -> secondary_drug_ins_group
memd_cob_rxbin -> secondary_drug_ins_bin
memd_cob_rxpcn -> secondary_drug_ins_pcn

-- Subsidies and Penalties
memd_partd_sbsdy -> part_d_subsidy
memd_copay_cat -> copay_category
memd_lics_sbsdy -> low_income_premium_subsidy
memd_late_penalty -> late_enrollment_penalty
memd_late_waiv_amt -> late_enrollment_penalty_waived
memd_late_sbsdy -> late_enrollment_penalty_subsidy

-- MSP
memd_msp_cd -> aged_disabled_msp_status

-- System Fields
memd_lock_token -> lock_token
atxr_source_id -> attachment_source_id

-- IC Model Fields
memd_ic_flag_nvl -> ic_model_flag
memd_ic_sts_nvl -> ic_model_benefit_status_cd
memd_ic_trsn_nvl -> ic_model_end_date_reason

-- Accessibility
memd_pref_lang_nvl -> preferred_language
memd_access_fmt_nvl -> accessible_format

-- NPN
memd_npn_nvl -> national_producer_number
```

## File Naming Convention

### Rename Views
- `stg_member_medicare_event_legacy_facets_rename.sql`
- `stg_member_medicare_event_gemstone_facets_rename.sql`

### Staging Views
- `stg_member_medicare_event_legacy_facets.sql`
- `stg_member_medicare_event_gemstone_facets.sql`

### Hub Models
- `h_medicare_event.sql`

### Link Models
- `l_member_medicare_event.sql`

### Satellite Models
- `s_member_medicare_event_legacy_facets.sql`
- `s_member_medicare_event_gemstone_facets.sql`

### Current View
- `current_member_medicare_event.sql`

## Staging View Hash Expressions

### For stg_member_medicare_event_<source>.sql

```yaml
derived_columns:
  source: '<source_name>'  # e.g., 'legacy_facets'
  load_datetime: '{{ dbt.current_timestamp() }}'
  edp_start_dt: hcfa_eff_dt
  edp_end_dt: hcfa_term_dt
  edp_record_status:
    CASE
      WHEN hcfa_term_dt IS NULL THEN 'ACTIVE'
      WHEN hcfa_term_dt >= CURRENT_DATE THEN 'ACTIVE'
      ELSE 'INACTIVE'
    END

hashed_columns:
  member_hk:
    - member_ck

  medicare_event_hk:
    - medicare_event_cd

  member_medicare_event_lk:
    - member_hk
    - medicare_event_hk

  member_medicare_event_hashdiff:
    is_hashdiff: true
    columns:
      - hcfa_eff_dt
      - hcfa_term_dt
      - group_ck
      - input_dt
      - event_eff_dt
      - event_term_dt
      - medicare_state
      - medicare_county
      - health_ins_claim_number
      - benefit_group_ck
      - pipdcg_category
      - risk_adj_part_a_factor
      - risk_adj_part_b_factor
      - risk_adj_part_d_factor
      - risk_adj_factor_type
      - election_type
      - medicare_plan_benefit_pkg
      - segment_id
      - premium_withhold_option
      - part_c_premium
      - part_d_premium
      - prior_commercial_override
      - enrollment_source
      - uncovered_months
      - part_d_id
      - medicare_rx_group_id
      - medicare_rxbin
      - medicare_rxpcn
      - secondary_drug_ins_flag
      - secondary_drug_ins_id
      - secondary_drug_ins_group
      - secondary_drug_ins_bin
      - secondary_drug_ins_pcn
      - part_d_subsidy
      - copay_category
      - low_income_premium_subsidy
      - late_enrollment_penalty
      - late_enrollment_penalty_waived
      - late_enrollment_penalty_subsidy
      - aged_disabled_msp_status
      - risk_adj_part_d_fctr_type
      - lock_token
      - attachment_source_id
      - ic_model_flag
      - ic_model_benefit_status_cd
      - ic_model_end_date_reason
      - preferred_language
      - accessible_format
      - medicare_sep_reason
      - medicare_enrollee_relation
      - national_producer_number
```

## Effectivity Satellite Configuration

```yaml
# For s_member_medicare_event_<source>.sql

sat_v0:
  source_model: stg_member_medicare_event_<source>
  src_pk: member_medicare_event_lk
  src_hashdiff: member_medicare_event_hashdiff
  src_payload:
    - hcfa_eff_dt
    - hcfa_term_dt
    - group_ck
    - input_dt
    - event_eff_dt
    - event_term_dt
    - medicare_state
    - medicare_county
    - health_ins_claim_number
    - benefit_group_ck
    - pipdcg_category
    - risk_adj_part_a_factor
    - risk_adj_part_b_factor
    - risk_adj_part_d_factor
    - risk_adj_factor_type
    - election_type
    - medicare_plan_benefit_pkg
    - segment_id
    - premium_withhold_option
    - part_c_premium
    - part_d_premium
    - prior_commercial_override
    - enrollment_source
    - uncovered_months
    - part_d_id
    - medicare_rx_group_id
    - medicare_rxbin
    - medicare_rxpcn
    - secondary_drug_ins_flag
    - secondary_drug_ins_id
    - secondary_drug_ins_group
    - secondary_drug_ins_bin
    - secondary_drug_ins_pcn
    - part_d_subsidy
    - copay_category
    - low_income_premium_subsidy
    - late_enrollment_penalty
    - late_enrollment_penalty_waived
    - late_enrollment_penalty_subsidy
    - aged_disabled_msp_status
    - risk_adj_part_d_fctr_type
    - lock_token
    - attachment_source_id
    - ic_model_flag
    - ic_model_benefit_status_cd
    - ic_model_end_date_reason
    - preferred_language
    - accessible_format
    - medicare_sep_reason
    - medicare_enrollee_relation
    - national_producer_number
    - edp_start_dt
    - edp_end_dt
    - edp_record_status
  src_eff: hcfa_eff_dt
  src_ldts: load_datetime
  src_source: source

# Effectivity configuration
is_effectivity: true
src_start_date: hcfa_eff_dt
src_end_date: hcfa_term_dt
```

## Testing Recommendations

### Hub Tests (h_medicare_event)
```yaml
- unique:
    column_name: medicare_event_hk
- not_null:
    column_name: medicare_event_hk
- not_null:
    column_name: medicare_event_bk
```

### Link Tests (l_member_medicare_event)
```yaml
- unique:
    column_name: member_medicare_event_lk
- not_null:
    column_name: member_medicare_event_lk
- not_null:
    column_name: member_hk
- not_null:
    column_name: medicare_event_hk
- relationships:
    to: ref('h_member')
    field: member_hk
- relationships:
    to: ref('h_medicare_event')
    field: medicare_event_hk
```

### Satellite Tests
```yaml
- not_null:
    column_name: member_medicare_event_lk
- not_null:
    column_name: hashdiff
- not_null:
    column_name: load_datetime
- not_null:
    column_name: effective_from
```

## Implementation Notes

1. **h_member already exists** - Only need to create h_medicare_event hub
2. **Effectivity satellites** - Use `is_effectivity: true` with src_start_date and src_end_date
3. **Multi-source** - Create separate rename, staging, and satellite models for each source system
4. **Current view** - Union across both sources, filtering to active/current records only
5. **Date handling** - memd_hcfa_eff_dt serves as both src_eff and src_start_date in effectivity satellite
