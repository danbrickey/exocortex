{{
    config(
        materialized='incremental',
        unique_key='member_medicare_event_lk'
    )
}}

{%- set yaml_metadata -%}
source_model: stg_member_medicare_event_gemstone_facets
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
  - signature_dt
  - edp_start_dt
  - edp_end_dt
  - edp_record_status
  - edp_record_source
src_eff: hcfa_eff_dt
src_ldts: load_datetime
src_source: source
is_effectivity: true
src_start_date: hcfa_eff_dt
src_end_date: hcfa_term_dt
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat_v0(src_pk=metadata_dict['src_pk'],
                       src_hashdiff=metadata_dict['src_hashdiff'],
                       src_payload=metadata_dict['src_payload'],
                       src_eff=metadata_dict['src_eff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
