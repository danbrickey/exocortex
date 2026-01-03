{%- set yaml_metadata -%}
source_model: stg_member_medicare_event_gemstone_facets_rename
derived_columns:
  source: '!gemstone_facets'
  load_datetime: '{{ dbt.current_timestamp() }}'
  edp_start_dt: hcfa_eff_dt
  edp_end_dt: hcfa_term_dt
  edp_record_status:
    CASE
      WHEN hcfa_term_dt IS NULL THEN 'ACTIVE'
      WHEN hcfa_term_dt >= CURRENT_DATE THEN 'ACTIVE'
      ELSE 'INACTIVE'
    END
  edp_record_source: '!gemstone_facets'
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
      - signature_dt
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      derived_columns=metadata_dict['derived_columns'],
                      hashed_columns=metadata_dict['hashed_columns'],
                      ranked_columns=none) }}
