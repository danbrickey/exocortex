-- s_group_plan_eligibility_legacy_facets.sql
-- Effectivity satellite for group plan eligibility from legacy FACETS system

{%- set yaml_metadata -%}
source_model: "stg_group_plan_eligibility_legacy_facets"
src_pk: "group_product_category_class_plan_hk"
src_dfk: "group_product_category_class_plan_hk"
src_sfk: "plan_hk"
src_start_date: "plan_effective_dt"
src_end_date: "plan_termination_dt"
src_eff: "plan_effective_dt"
src_ldts: "load_datetime"
src_source: "source"
src_payload:
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

{{ automate_dv.eff_sat(src_pk=metadata_dict['src_pk'],
                       src_dfk=metadata_dict['src_dfk'],
                       src_sfk=metadata_dict['src_sfk'],
                       src_start_date=metadata_dict['src_start_date'],
                       src_end_date=metadata_dict['src_end_date'],
                       src_eff=metadata_dict['src_eff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       src_payload=metadata_dict['src_payload'],
                       source_model=metadata_dict['source_model']) }}
