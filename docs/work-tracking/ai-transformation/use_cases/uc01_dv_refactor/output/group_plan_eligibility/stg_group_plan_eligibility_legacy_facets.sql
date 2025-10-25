-- stg_group_plan_eligibility_legacy_facets.sql
-- Staging view for group plan eligibility from legacy FACETS system with hash keys

{%- set yaml_metadata -%}
source_model: "stg_group_plan_eligibility_legacy_facets_rename"
derived_columns:
  source: "legacy_facets"
  load_datetime: "sys_last_upd_dtm"
  group_hk: "group_bk"
  class_hk: "class_bk"
  product_category_hk: "product_category_bk"
  plan_hk: "plan_bk"
  group_product_category_class_plan_hk:
    - "group_bk"
    - "product_category_bk"
    - "class_bk"
    - "plan_bk"
hashed_columns:
  group_hk: "group_bk"
  class_hk: "class_bk"
  product_category_hk: "product_category_bk"
  plan_hk: "plan_bk"
  group_product_category_class_plan_hk:
    - "group_bk"
    - "product_category_bk"
    - "class_bk"
    - "plan_bk"
  group_plan_eligibility_hashdiff:
    is_hashdiff: true
    columns:
      - "plan_effective_dt"
      - "plan_termination_dt"
      - "product_id"
      - "plan_selectable_ind"
      - "plan_family_ind"
      - "rate_guarantee_dt"
      - "rate_guarantee_period_months"
      - "rate_guarantee_ind"
      - "age_vol_reduction_tbl_pfx"
      - "warning_message_seq_no"
      - "open_enroll_begin_mmdd"
      - "open_enroll_end_mmdd"
      - "group_admin_rules_id"
      - "its_prefix"
      - "premium_age_calc_method"
      - "member_id_card_stock"
      - "member_id_card_type"
      - "hedis_cont_enroll_break"
      - "hedis_cont_enroll_days"
      - "plan_year_begin_mmdd"
      - "network_set_pfx"
      - "plan_co_month"
      - "covering_provider_set_pfx"
      - "hra_admin_info_id"
      - "postponement_ind"
      - "debit_card_bank_rel_pfx"
      - "dental_util_edits_pfx"
      - "value_based_benefits_id"
      - "billing_strategy_id"
      - "lock_token"
      - "attachment_source_id"
      - "last_update_dtm"
      - "last_update_user_id"
      - "last_update_dbuser_id"
      - "secondary_plan_cd"
      - "auth_cert_entity_id"
      - "its_account_exception"
      - "renewal_begin_mmdd"
      - "hios_id"
      - "its_pfx_account_id"
      - "patient_care_program_set_pfx"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns']) }}
