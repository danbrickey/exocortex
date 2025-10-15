{{
    config(
        materialized='view',
        tags=['business_vault', 'current']
    )
}}

with hub as (

    select
        benefit_summary_type_hk,
        benefit_summary_type_bk,
        load_datetime as hub_load_datetime,
        record_source as hub_record_source
    from {{ ref('h_benefit_summary_type') }}

),

link as (

    select
        benefit_summary_product_prefix_lk,
        benefit_summary_type_hk,
        product_prefix_hk,
        load_datetime as link_load_datetime,
        record_source as link_record_source
    from {{ ref('l_benefit_summary_product_prefix') }}

),

sat_legacy as (

    select
        benefit_summary_product_prefix_lk,
        hashdiff,
        benefit_summary_desc,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        load_datetime,
        load_end_datetime,
        record_source
    from {{ ref('s_benefit_summary_legacy_facets') }}
    where load_end_datetime is null

),

sat_gemstone as (

    select
        benefit_summary_product_prefix_lk,
        hashdiff,
        benefit_summary_desc,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        load_datetime,
        load_end_datetime,
        record_source
    from {{ ref('s_benefit_summary_gemstone_facets') }}
    where load_end_datetime is null

),

sat_union as (

    select * from sat_legacy
    union all
    select * from sat_gemstone

),

-- get the most recent satellite record per link key across all sources
sat_current as (

    select
        benefit_summary_product_prefix_lk,
        hashdiff,
        benefit_summary_desc,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        load_datetime as sat_load_datetime,
        record_source as sat_record_source
    from sat_union
    qualify row_number() over (
        partition by benefit_summary_product_prefix_lk
        order by load_datetime desc
    ) = 1

),

final as (

    select
        -- hub columns
        hub.benefit_summary_type_hk,
        hub.benefit_summary_type_bk,
        hub.hub_load_datetime,
        hub.hub_record_source,

        -- link columns
        link.benefit_summary_product_prefix_lk,
        link.product_prefix_hk,
        link.link_load_datetime,
        link.link_record_source,

        -- satellite columns
        sat.hashdiff,
        sat.benefit_summary_desc,
        sat.lock_token,
        sat.attachment_source_id,
        sat.last_update_dtm,
        sat.last_update_user_id,
        sat.last_update_db_user_id,
        sat.sat_load_datetime,
        sat.sat_record_source

    from hub
    inner join link
        on hub.benefit_summary_type_hk = link.benefit_summary_type_hk
    left join sat_current as sat
        on link.benefit_summary_product_prefix_lk = sat.benefit_summary_product_prefix_lk

)

select * from final
