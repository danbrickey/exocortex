{%- set yaml_metadata -%}
source_model: stg_group_plan_eligibility_gemstone_facets
src_pk: "link_hk"
src_dfk:
  - "group_hk"
  - "product_category_hk"
  - "class_hk"
  - "plan_hk"
src_hashdiff: "hashdiff"
src_payload:
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
src_eff: "effective_from"
src_ldts: "load_datetime"
src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                   src_hashdiff=metadata_dict['src_hashdiff'],
                   src_payload=metadata_dict['src_payload'],
                   src_eff=metadata_dict['src_eff'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
