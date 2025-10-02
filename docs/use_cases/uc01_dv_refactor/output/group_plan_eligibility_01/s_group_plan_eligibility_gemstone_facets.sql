-- s_group_plan_eligibility_gemstone_facets.sql
-- Effectivity Satellite for group_plan_eligibility gemstone facets
-- Tracks descriptive attributes and their changes over time with effectivity dates

{{
    config(
        materialized='incremental',
        unique_key=['group_product_category_class_plan_lk', 'load_datetime'],
        schema='raw_vault'
    )
}}

with source as (
    select
        -- Hash Keys
        group_product_category_class_plan_lk,

        -- Effectivity Columns
        src_eff,
        src_start_date,
        src_end_date,

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
        record_source,
        load_datetime,
        last_seen_datetime

    from {{ ref('stg_group_plan_eligibility_gemstone_facets') }}
),

hashed_diff as (
    select
        *,
        {{ dbt_utils.generate_surrogate_key([
            'product_id',
            'selectable_indicator',
            'family_indicator',
            'group_admin_rules_id',
            'its_prefix',
            'network_set_prefix',
            'covering_provider_set_prefix',
            'postponement_indicator'
        ]) }} as hashdiff
    from source
),

records_to_insert as (
    select * from hashed_diff

    {% if is_incremental() %}
        where (group_product_category_class_plan_lk, load_datetime) not in (
            select group_product_category_class_plan_lk, load_datetime from {{ this }}
        )
    {% endif %}
)

select * from records_to_insert
