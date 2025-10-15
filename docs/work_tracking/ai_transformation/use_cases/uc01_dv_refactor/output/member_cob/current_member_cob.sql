{{ config(materialized='view') }}

{% set source_systems = ["legacy_facets", "gemstone_facets"] %}
{% set hub_model_member = "h_member" %}
{% set hub_model_cob = "h_member_cob" %}
{% set link_model = "l_member_cob" %}
{% set link_key = "member_cob_hk" %}

{% for source_system in source_systems %}
  {% if source_system == "legacy_facets" %}
    {% set sat_model = "s_member_cob_legacy_facets" %}
  {% else %}
    {% set sat_model = "s_member_cob_gemstone_facets" %}
  {% endif %}

  select
    1 as tenant_id,
    hub_member.source,
    hub_member.member_bk,
    hub_cob.cob_ins_type_bk,
    hub_cob.cob_ins_order_bk,
    hub_cob.cob_supp_drug_type_bk,
    sat.cob_eff_dt,
    sat.cob_term_dt,
    sat.cob_term_reason,
    sat.group_bk,
    sat.cob_carrier_id,
    sat.cob_policy_id,
    sat.cob_msp_type,
    sat.cob_rx_coverage_type,
    sat.cob_rx_bin,
    sat.cob_rx_pcn,
    sat.cob_rx_group,
    sat.cob_rx_id,
    sat.cob_last_ver_dt,
    sat.cob_last_ver_name,
    sat.cob_ver_method,
    sat.cob_loi_start_dt,
    sat.cob_prim_last_nm,
    sat.cob_prim_first_nm,
    sat.cob_prim_id,
    sat.lock_token,
    sat.attachment_source_id,
    sat.last_update_dtm,
    sat.last_update_user_id,
    sat.last_update_db_user_id,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
  from {{ ref(link_model) }} as link
  join {{ ref(hub_model_member) }} as hub_member
    on link.member_hk = hub_member.member_hk
  join {{ ref(hub_model_cob) }} as hub_cob
    on link.cob_indicator_hk = hub_cob.cob_indicator_hk
  join {{ ref(sat_model) }} as sat
    on link.member_cob_hk = sat.member_cob_hk
  join (
    select member_cob_hk, max(load_datetime) as max_load_datetime
    from {{ ref(sat_model) }}
    group by member_cob_hk
  ) as latest
    on sat.member_cob_hk = latest.member_cob_hk
   and sat.load_datetime = latest.max_load_datetime

  {% if not loop.last %}
    union all
  {% endif %}
{% endfor %}