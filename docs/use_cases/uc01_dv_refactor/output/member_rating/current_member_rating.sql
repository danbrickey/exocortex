{{ config(materialized='view') }}

{% set source_systems = ["legacy_facets", "gemstone_facets"] %}
{% set hub_model_member = "h_member" %}
{% set link_model = "l_member_rating" %}
{% set link_key = "member_rating_lk" %}

{% for source_system in source_systems %}
  {% if source_system == "legacy_facets" %}
    {% set sat_model = "s_member_rating_legacy_facets" %}
  {% else %}
    {% set sat_model = "s_member_rating_gemstone_facets" %}
  {% endif %}

  select
    1 as tenant_id,
    hub_member.source,
    hub_member.member_bk,
    sat.rating_eff_dt,
    sat.rating_term_dt,
    sat.group_bk,
    sat.smoker_ind,
    sat.underwriting_class_1_cd,
    sat.underwriting_class_2_cd,
    sat.underwriting_class_3_cd,
    sat.lock_token_nbr,
    sat.attachment_source_id,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
  from {{ ref(link_model) }} as link
  join {{ ref(hub_model_member) }} as hub_member
    on link.member_hk = hub_member.member_hk
  join {{ ref(sat_model) }} as sat
    on link.member_rating_lk = sat.member_rating_lk
  join (
    select member_rating_lk, max(load_datetime) as max_load_datetime
    from {{ ref(sat_model) }}
    group by member_rating_lk
  ) as latest
    on sat.member_rating_lk = latest.member_rating_lk
   and sat.load_datetime = latest.max_load_datetime

  {% if not loop.last %}
    union all
  {% endif %}
{% endfor %}
