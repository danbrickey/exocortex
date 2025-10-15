{{
    config(
        materialized='view',
        tags=['business_vault', 'current_view', 'product_prefix']
    )
}}

/*
    Current View: product_prefix
    Purpose: Provides backward compatibility and current state view for product prefix data

    This view shows the most recent record for each unique product prefix and
    component type combination across all source systems. It combines data from
    the link and all source-specific satellites.

    Business Logic:
    - Unions satellite data from all source systems (legacy_facets, gemstone_facets)
    - Selects the most recent record per link key per source using load_datetime
    - Joins with the link to provide complete context
    - Provides all descriptive attributes from satellites

    Use Case:
    - Backward compatibility for existing consumers of product prefix data
    - Simplified access to current state without complex vault queries
    - Single source of truth for current product prefix descriptions
*/

with link_current as (

    select
        product_prefix_product_component_type_lk,
        product_prefix_hk,
        product_component_type_hk,
        load_datetime,
        source
    from {{ ref('l_product_prefix_product_component_type') }}

),

-- Union all satellite sources to get complete attribute history
satellite_union as (

    select
        product_prefix_product_component_type_lk,
        hashdiff,
        prefix_description,
        lock_token,
        attachment_source_id,
        system_row_id,
        load_datetime,
        source
    from {{ ref('s_l_product_prefix_product_component_type_legacy_facets') }}

    union all

    select
        product_prefix_product_component_type_lk,
        hashdiff,
        prefix_description,
        lock_token,
        attachment_source_id,
        system_row_id,
        load_datetime,
        source
    from {{ ref('s_l_product_prefix_product_component_type_gemstone_facets') }}

),

-- Get the most recent record per link key per source
satellite_current as (

    select
        product_prefix_product_component_type_lk,
        hashdiff,
        prefix_description,
        lock_token,
        attachment_source_id,
        system_row_id,
        load_datetime,
        source
    from satellite_union
    qualify row_number() over (
        partition by product_prefix_product_component_type_lk, source
        order by load_datetime desc
    ) = 1

),

-- Join link with current satellite attributes
final as (

    select
        l.product_prefix_hk,
        l.product_component_type_hk,
        l.product_prefix_product_component_type_lk,
        s.prefix_description,
        s.lock_token,
        s.attachment_source_id,
        s.system_row_id,
        s.hashdiff,
        s.load_datetime,
        s.source
    from link_current l
    left join satellite_current s
        on l.product_prefix_product_component_type_lk = s.product_prefix_product_component_type_lk
        and l.source = s.source

)

select * from final
