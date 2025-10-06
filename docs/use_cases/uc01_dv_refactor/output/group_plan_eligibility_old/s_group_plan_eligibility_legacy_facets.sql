{% set yaml_metadata %}
source_model: "stg_group_plan_eligibility_legacy_facets"

src_pk: "group_product_category_class_plan_hk"

src_dfk: "group_hk"

src_sfk:
  - "product_category_hk"
  - "class_hk"
  - "plan_hk"

src_eff: "plan_eff_dt"

src_start_date: "plan_eff_dt"

src_end_date: "plan_term_dt"

src_hashdiff:
  source_column: "group_plan_eligibility_hashdiff"
  alias: "hashdiff"

src_extra_columns:
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
  - group_hk
  - product_category_hk
  - class_hk
  - plan_hk
  - group_plan_eligibility_ik

src_ldts: "load_datetime"

src_source: "source"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict["src_pk"],
    src_dfk=metadata_dict["src_dfk"],
    src_sfk=metadata_dict["src_sfk"],
    src_eff=metadata_dict["src_eff"],
    src_start_date=metadata_dict["src_start_date"],
    src_end_date=metadata_dict["src_end_date"],
    src_extra_columns=metadata_dict["src_extra_columns"],
    src_ldts=metadata_dict["src_ldts"],
    src_source=metadata_dict["src_source"],
    source_model=metadata_dict["source_model"]
) }}
