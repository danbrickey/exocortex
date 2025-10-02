-- stg_group_plan_eligibility_gemstone_facets.sql
-- Staging view for group_plan_eligibility gemstone facets with Data Vault metadata
-- Source: dbo.cmc_cspi_cs_plan via rename view

{{
    config(
        materialized='view',
        schema='staging'
    )
}}

with source as (
    select * from {{ ref('stg_group_plan_eligibility_gemstone_facets_rename') }}
),

hashed as (
    select
        -- Business Keys
        group_contrived_key,
        class_id,
        product_category,
        plan_id,

        -- Hash Keys
        {{ dbt_utils.generate_surrogate_key(['group_contrived_key']) }} as group_hk,
        {{ dbt_utils.generate_surrogate_key(['class_id']) }} as class_hk,
        {{ dbt_utils.generate_surrogate_key(['product_category']) }} as product_category_hk,
        {{ dbt_utils.generate_surrogate_key(['plan_id']) }} as plan_hk,
        {{ dbt_utils.generate_surrogate_key([
            'group_contrived_key',
            'product_category',
            'class_id',
            'plan_id'
        ]) }} as group_product_category_class_plan_lk,

        -- Effectivity Columns
        effective_date as src_eff,
        effective_date as src_start_date,
        termination_date as src_end_date,

        -- Descriptive Attributes (Gemstone-specific subset)
        product_id,
        selectable_indicator,
        family_indicator,
        group_admin_rules_id,
        its_prefix,
        network_set_prefix,
        covering_provider_set_prefix,
        postponement_indicator,

        -- System Metadata
        last_update_datetime,
        last_update_user_id,
        last_update_dbms_user_id,

        -- Data Vault Metadata
        'GEMSTONE' as record_source,
        current_timestamp() as load_datetime,
        last_update_datetime as last_seen_datetime

    from source
)

select * from hashed
