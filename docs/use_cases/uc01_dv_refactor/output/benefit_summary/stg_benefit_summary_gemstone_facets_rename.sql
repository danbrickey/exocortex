{{
    config(
        materialized='view',
        tags=['staging', 'rename', 'gemstone_facets']
    )
}}

with source as (

    select * from {{ source('gemstone_facets', 'cmc_bsbs_sum') }}

),

renamed as (

    select
        -- business keys
        pdbc_pfx as product_prefix_bk,
        bsbs_type as benefit_summary_type_bk,

        -- descriptive attributes
        bsbs_desc as benefit_summary_desc,

        -- system columns
        bsbs_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_dtm,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_db_user_id,

        -- metadata
        'gemstone_facets' as record_source,
        'BCI' as tenant_id,
        current_timestamp()::timestamp_ntz as load_datetime

    from source

)

select * from renamed
