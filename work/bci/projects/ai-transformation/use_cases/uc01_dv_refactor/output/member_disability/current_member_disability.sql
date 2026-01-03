{{ config(materialized='view') }}

{% set source_systems = ["legacy_facets", "gemstone_facets"] %}
{% set hub_model_member = "h_member" %}

{% for source_system in source_systems %}
  {% if source_system == "legacy_facets" %}
    {% set sat_model = "s_member_disability_legacy_facets" %}
  {% else %}
    {% set sat_model = "s_member_disability_gemstone_facets" %}
  {% endif %}

  select
    1 as tenant_id,
    hub_member.source,
    hub_member.member_bk,
    sat.disability_eff_dt,
    sat.disability_term_dt,
    sat.termination_reason_cd,
    sat.group_bk,
    sat.disability_desc,
    sat.disability_type_cd,
    sat.last_verification_dt,
    sat.last_verification_name,
    sat.verification_method_cd,
    sat.lock_token_nbr,
    sat.attachment_source_id,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
  from {{ ref(hub_model_member) }} as hub_member
  join {{ ref(sat_model) }} as sat
    on hub_member.member_hk = sat.member_hk
  join (
    select member_hk, disability_eff_dt, max(load_datetime) as max_load_datetime
    from {{ ref(sat_model) }}
    group by member_hk, disability_eff_dt
  ) as latest
    on sat.member_hk = latest.member_hk
   and sat.disability_eff_dt = latest.disability_eff_dt
   and sat.load_datetime = latest.max_load_datetime

  {% if not loop.last %}
    union all
  {% endif %}
{% endfor %}
