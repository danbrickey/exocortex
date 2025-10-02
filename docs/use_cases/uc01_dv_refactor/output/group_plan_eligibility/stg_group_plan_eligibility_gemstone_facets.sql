{% set yaml_metadata %}
source_model: "stg_group_plan_eligibility_gemstone_facets_rename"

derived_columns:
  source: "'{{ var('gemstone_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"
  group_plan_eligibility_ik: "{{ dbt_utils.generate_surrogate_key(['tenant_id', 'source', 'group_bk', 'product_category_bk', 'class_bk', 'plan_bk', 'plan_eff_dt']) }}"

hashed_columns:
  group_hk: ["source", "group_bk"]
  product_category_hk: ["source", "product_category_bk"]
  class_hk: ["source", "class_bk"]
  plan_hk: ["source", "plan_bk"]
  group_product_category_class_plan_hk: ["source", "group_bk", "product_category_bk", "class_bk", "plan_bk"]
  group_plan_eligibility_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - group_bk
      - class_bk
      - product_category_bk
      - plan_bk
      - plan_eff_dt
      - plan_term_dt
      - product_id
      - selectable_ind
      - family_ind
      - rate_guarantee_dt
      - rate_guarantee_period_mos
      - rate_guarantee_ind
      - age_volume_reduction_table_pfx
      - warning_message_seq_no
      - open_enrollment_begin_mmdd
      - open_enrollment_end_mmdd
      - group_admin_rules_id
      - its_prefix
      - premium_age_calc_method
      - member_id_card_stock
      - product_member_id_card_type
      - hedis_continuous_enrollment_break
      - hedis_continuous_enrollment_days
      - plan_year_begin_mmdd
      - network_set_pfx
      - plan_product_co_month
      - covering_provider_set_pfx
      - hra_admin_info_id
      - postponement_ind
      - debit_card_bank_rel_pfx
      - dental_util_edits_pfx
      - value_based_benefits_parms_id
      - billing_strategy_vision_id
      - lock_token
      - attachment_source_id
      - last_update_dtm
      - last_update_user_id
      - last_update_db_user_id
      - secondary_plan_processing_cd
      - auth_cert_entity_id
      - its_account_exception
      - policy_renewal_begins_mmdd
      - hios_id
      - its_prefix_account_id
      - patient_care_program_set_pfx
      - edp_record_status
      - edp_record_source
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    null_columns=none,
    hashed_columns=metadata_dict['hashed_columns'],
    ranked_columns=none
) }}
