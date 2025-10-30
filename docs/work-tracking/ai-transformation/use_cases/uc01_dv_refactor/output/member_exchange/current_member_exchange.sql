{{ config(materialized='view') }}

{% set source_map = [
    {
        "system": "legacy_facets",
        "sat": "s_member_exchange_legacy_facets"
    },
    {
        "system": "gemstone_facets",
        "sat": "s_member_exchange_gemstone_facets"
    }
] %}

{% for entry in source_map %}
select
    sat.tenant_id as tenant_id,
    sat.source as source_system,
    link.member_exchange_lk,
    link.member_hk,
    hub_member.member_bk as hub_member_bk,
    sat.member_bk as source_member_bk,
    link.product_category_hk,
    hub_product_category.product_category_bk as hub_product_category_bk,
    sat.product_category_bk as source_product_category_bk,
    sat.exchange_effective_dt,
    sat.exchange_termination_dt,
    sat.edp_start_dt,
    sat.group_bk,
    sat.exchange_channel_cd,
    sat.exchange_id,
    sat.enrollment_method_cd,
    sat.aptc_indicator,
    sat.lock_token_nbr,
    sat.attachment_source_id,
    sat.system_last_update_dtm,
    sat.system_update_user_id,
    sat.system_update_db_user_id,
    sat.qhp_identifier,
    sat.exchange_assigned_member_id,
    sat.exchange_policy_id,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
from {{ ref('l_member_exchange') }} as link
join {{ ref(entry.sat) }} as sat
  on link.member_exchange_lk = sat.member_exchange_lk
join {{ ref('h_member') }} as hub_member
  on link.member_hk = hub_member.member_hk
join {{ ref('h_product_category') }} as hub_product_category
  on link.product_category_hk = hub_product_category.product_category_hk
join (
    select
        member_exchange_lk,
        exchange_effective_dt,
        source,
        max(load_datetime) as max_load_datetime
    from {{ ref(entry.sat) }}
    where exchange_termination_dt is null
       or exchange_termination_dt > current_timestamp()
    group by member_exchange_lk, exchange_effective_dt, source
) as latest
  on sat.member_exchange_lk = latest.member_exchange_lk
 and sat.exchange_effective_dt = latest.exchange_effective_dt
 and sat.source = latest.source
 and sat.load_datetime = latest.max_load_datetime
where link.source = sat.source
  and (sat.exchange_termination_dt is null or sat.exchange_termination_dt > current_timestamp())
{% if not loop.last %}
union all
{% endif %}
{% endfor %}
