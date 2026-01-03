{%- set yaml_metadata -%}
source_model: stg_group_plan_eligibility_legacy_facets_rename
derived_columns:
  source: "!legacy_facets"
  load_datetime: "!2024-01-01"
  effective_from: "effective_date"
hashed_columns:
  group_hk: "group_ck"
  product_category_hk: "product_category"
  class_hk: "class_id"
  plan_hk: "plan_id"
  link_hk:
    - "group_ck"
    - "product_category"
    - "class_id"
    - "plan_id"
  hashdiff:
    is_hashdiff: true
    columns:
      - "product_id"
      - "selectable_indicator"
      - "family_indicator"
      - "rate_guarantee_date"
      - "rate_guarantee_period_months"
      - "rate_guarantee_indicator"
      - "age_volume_reduction_prefix"
      - "warning_message_seq_no"
      - "open_enrollment_begin_period"
      - "open_enrollment_end_period"
      - "group_admin_rules_id"
      - "its_prefix"
      - "premium_age_calc_method"
      - "member_id_card_stock"
      - "product_member_id_card_type"
      - "hedis_ce_break"
      - "hedis_ce_days"
      - "plan_year_begin_date"
      - "network_set_prefix"
      - "plan_year_co_month"
      - "covering_provider_set_prefix"
      - "hra_admin_info_id"
      - "postponement_indicator"
      - "debit_card_bank_rel_prefix"
      - "dental_util_edits_prefix"
      - "value_based_benefits_parms_id"
      - "billing_strategy_vision"
      - "lock_token"
      - "attachment_source_id"
      - "last_update_datetime"
      - "last_update_user_id"
      - "last_update_dbms_user_id"
      - "secondary_plan_proc_code"
      - "auth_cert_rel_entity_id"
      - "its_account_exception"
      - "policy_issuance_renewal_begin_date"
      - "hios_identifier"
      - "its_prefix_account_id"
      - "patient_care_program_set"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }}
