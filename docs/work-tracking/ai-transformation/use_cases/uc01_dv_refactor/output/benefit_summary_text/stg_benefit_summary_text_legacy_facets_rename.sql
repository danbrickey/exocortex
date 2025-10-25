{{
    config(
        materialized='view',
        tags=['staging', 'rename', 'benefit_summary_text', 'legacy_facets']
    )
}}

with source as (
    select * from {{ source('legacy_facets', 'cmc_bstx_sum_text') }}
),

renamed as (
    select
        -- business keys
        pdbc_pfx as product_prefix,
        bsbs_type as benefit_summary_type,
        bstx_seq_no as benefit_summary_text_seq_no,

        -- descriptive attributes
        bstx_text as benefit_summary_text,
        bstx_lock_token as lock_token,

        -- system columns
        atxr_source_id as attachment_source_id,

        -- metadata columns (hardcoded for now)
        'legacy_facets' as source,
        'BCI' as tenant_id,
        current_timestamp() as load_datetime

    from source
)

select * from renamed
