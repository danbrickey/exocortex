{{ config(materialized='view') }}

{% set source_systems = ["legacy_facets", "gemstone_facets"] %}
{% set hub_model_subscriber = "h_subscriber" %}

{% for source_system in source_systems %}
  {% if source_system == "legacy_facets" %}
    {% set sat_model = "s_subscriber_rating_legacy_facets" %}
  {% else %}
    {% set sat_model = "s_subscriber_rating_gemstone_facets" %}
  {% endif %}

  select
    1 as tenant_id,
    hub_subscriber.source,
    hub_subscriber.subscriber_bk,
    sat.rating_eff_dt,
    sat.rating_term_dt,
    sat.group_bk,
    sat.subscriber_billing_ind,
    sat.smoker_ind,
    sat.rating_state_cd,
    sat.rating_county_cd,
    sat.rating_area_cd,
    sat.rating_sic_cd,
    sat.lock_token_nbr,
    sat.attachment_source_id,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
  from {{ ref(hub_model_subscriber) }} as hub_subscriber
  join {{ ref(sat_model) }} as sat
    on hub_subscriber.subscriber_hk = sat.subscriber_hk
  join (
    select subscriber_hk, rating_eff_dt, max(load_datetime) as max_load_datetime
    from {{ ref(sat_model) }}
    group by subscriber_hk, rating_eff_dt
  ) as latest
    on sat.subscriber_hk = latest.subscriber_hk
   and sat.rating_eff_dt = latest.rating_eff_dt
   and sat.load_datetime = latest.max_load_datetime

  {% if not loop.last %}
    union all
  {% endif %}
{% endfor %}
