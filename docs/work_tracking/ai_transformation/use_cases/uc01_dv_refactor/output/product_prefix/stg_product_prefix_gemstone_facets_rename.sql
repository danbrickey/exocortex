{{
    config(
        materialized='view',
        tags=['staging', 'rename', 'product_prefix', 'gemstone_facets']
    )
}}

/*
    Rename View: product_prefix (Gemstone Facets)
    Source: dbo.cmc_pdpx_desc
    Purpose: Standardize column names from source CDC feed for vault ingestion

    This view renames source columns to follow EDP naming conventions:
    - snake_case formatting
    - Meaningful abbreviations (≤30 chars)
    - Consistent naming across models
*/

with source as (

    select * from {{ source('gemstone_facets_raw', 'cmc_pdpx_desc') }}

),

renamed as (

    select
        -- Business Keys
        pdbc_pfx as product_prefix_bk,
        pdbc_type as product_component_type_bk,

        -- Descriptive Attributes
        pdpx_desc as prefix_description,
        pdpx_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_row_id as system_row_id,

        -- Metadata (hardcoded for now)
        'gemstone_facets' as source,
        'BCI' as tenant_id

    from source

)

select * from renamed
