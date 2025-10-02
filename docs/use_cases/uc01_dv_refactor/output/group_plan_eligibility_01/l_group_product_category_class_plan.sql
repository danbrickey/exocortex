-- l_group_product_category_class_plan.sql
-- Link table connecting Group, Product Category, Class, and Plan entities
-- Represents the many-to-many relationship between these business entities

{{
    config(
        materialized='incremental',
        unique_key='group_product_category_class_plan_lk',
        schema='raw_vault'
    )
}}

with legacy_source as (
    select
        group_product_category_class_plan_lk,
        group_hk,
        product_category_hk,
        class_hk,
        plan_hk,
        record_source,
        load_datetime
    from {{ ref('stg_group_plan_eligibility_legacy_facets') }}
),

gemstone_source as (
    select
        group_product_category_class_plan_lk,
        group_hk,
        product_category_hk,
        class_hk,
        plan_hk,
        record_source,
        load_datetime
    from {{ ref('stg_group_plan_eligibility_gemstone_facets') }}
),

all_sources as (
    select * from legacy_source
    union all
    select * from gemstone_source
),

records_to_insert as (
    select distinct
        group_product_category_class_plan_lk,
        group_hk,
        product_category_hk,
        class_hk,
        plan_hk,
        record_source,
        load_datetime
    from all_sources

    {% if is_incremental() %}
        where group_product_category_class_plan_lk not in (
            select group_product_category_class_plan_lk from {{ this }}
        )
    {% endif %}
)

select * from records_to_insert
