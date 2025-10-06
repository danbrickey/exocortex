{{ config(materialized='view') }}

{% set source_systems = ["legacy_facets", "gemstone_facets"] %}
{% set link_model = "l_group_product_category_class_plan" %}
{% set hub_model_group = "h_group" %}
{% set hub_model_product_category = "h_product_category" %}
{% set hub_model_class = "h_class" %}
{% set hub_model_plan = "h_plan" %}

{% for source_system in source_systems %}
  {% if source_system == "legacy_facets" %}
    {% set sat_model = "s_group_plan_eligibility_legacy_facets" %}
  {% else %}
    {% set sat_model = "s_group_plan_eligibility_gemstone_facets" %}
  {% endif %}

  select
    1 as tenant_id,
    hub_group.source,
    hub_group.group_bk,
    hub_product_category.product_category_bk,
    hub_class.class_bk,
    hub_plan.plan_bk,
    sat.plan_eff_dt,
    sat.plan_term_dt,
    sat.product_id,
    sat.selectable_ind,
    sat.family_ind,
    sat.rate_guarantee_dt,
    sat.rate_guarantee_period_mos,
    sat.rate_guarantee_ind,
    sat.age_volume_reduction_table_pfx,
    sat.warning_message_seq_no,
    sat.open_enrollment_begin_mmdd,
    sat.open_enrollment_end_mmdd,
    sat.group_admin_rules_id,
    sat.its_prefix,
    sat.premium_age_calc_method,
    sat.member_id_card_stock,
    sat.product_member_id_card_type,
    sat.hedis_continuous_enrollment_break,
    sat.hedis_continuous_enrollment_days,
    sat.plan_year_begin_mmdd,
    sat.network_set_pfx,
    sat.plan_product_co_month,
    sat.covering_provider_set_pfx,
    sat.hra_admin_info_id,
    sat.postponement_ind,
    sat.debit_card_bank_rel_pfx,
    sat.dental_util_edits_pfx,
    sat.value_based_benefits_parms_id,
    sat.billing_strategy_vision_id,
    sat.lock_token,
    sat.attachment_source_id,
    sat.last_update_dtm,
    sat.last_update_user_id,
    sat.last_update_db_user_id,
    sat.secondary_plan_processing_cd,
    sat.auth_cert_entity_id,
    sat.its_account_exception,
    sat.policy_renewal_begins_mmdd,
    sat.hios_id,
    sat.its_prefix_account_id,
    sat.patient_care_program_set_pfx,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
  from {{ ref(link_model) }} as link
  join {{ ref(hub_model_group) }} as hub_group
    on link.group_hk = hub_group.group_hk
  join {{ ref(hub_model_product_category) }} as hub_product_category
    on link.product_category_hk = hub_product_category.product_category_hk
  join {{ ref(hub_model_class) }} as hub_class
    on link.class_hk = hub_class.class_hk
  join {{ ref(hub_model_plan) }} as hub_plan
    on link.plan_hk = hub_plan.plan_hk
  join {{ ref(sat_model) }} as sat
    on link.group_product_category_class_plan_hk = sat.group_product_category_class_plan_hk
  join (
    select group_product_category_class_plan_hk, max(load_datetime) as max_load_datetime
    from {{ ref(sat_model) }}
    group by group_product_category_class_plan_hk
  ) as latest
    on sat.group_product_category_class_plan_hk = latest.group_product_category_class_plan_hk
   and sat.load_datetime = latest.max_load_datetime

  {% if not loop.last %}
    union all
  {% endif %}
{% endfor %}
