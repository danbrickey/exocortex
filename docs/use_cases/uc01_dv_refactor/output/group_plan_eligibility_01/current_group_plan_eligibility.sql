-- current_group_plan_eligibility.sql
-- Current view reconstructing the group_plan_eligibility entity from Data Vault structures
-- Provides backward compatibility with 3NF structure for business consumption

{{
    config(
        materialized='view',
        schema='integration'
    )
}}

with link_base as (
    select
        group_product_category_class_plan_lk,
        group_hk,
        product_category_hk,
        class_hk,
        plan_hk,
        load_datetime as link_load_datetime
    from {{ ref('l_group_product_category_class_plan') }}
),

-- Get current legacy facets
legacy_sat_current as (
    select
        s.*
    from {{ ref('s_group_plan_eligibility_legacy_facets') }} s
    inner join (
        select
            group_product_category_class_plan_lk,
            max(load_datetime) as max_load_datetime
        from {{ ref('s_group_plan_eligibility_legacy_facets') }}
        group by group_product_category_class_plan_lk
    ) latest
        on s.group_product_category_class_plan_lk = latest.group_product_category_class_plan_lk
        and s.load_datetime = latest.max_load_datetime
),

-- Get current gemstone facets
gemstone_sat_current as (
    select
        s.*
    from {{ ref('s_group_plan_eligibility_gemstone_facets') }} s
    inner join (
        select
            group_product_category_class_plan_lk,
            max(load_datetime) as max_load_datetime
        from {{ ref('s_group_plan_eligibility_gemstone_facets') }}
        group by group_product_category_class_plan_lk
    ) latest
        on s.group_product_category_class_plan_lk = latest.group_product_category_class_plan_lk
        and s.load_datetime = latest.max_load_datetime
),

-- Combine all current state
final as (
    select
        -- Business Keys (from link)
        l.group_hk,
        l.product_category_hk,
        l.class_hk,
        l.plan_hk,

        -- Effectivity dates (prioritize legacy, fallback to gemstone)
        coalesce(leg.src_eff, gem.src_eff) as effective_date,
        coalesce(leg.src_start_date, gem.src_start_date) as start_date,
        coalesce(leg.src_end_date, gem.src_end_date) as end_date,

        -- Descriptive attributes from legacy satellite
        leg.product_id,
        leg.selectable_indicator,
        leg.family_indicator,
        leg.rate_guarantee_date,
        leg.rate_guarantee_period_months,
        leg.rate_guarantee_indicator,
        leg.age_volume_reduction_table_prefix,
        leg.user_warning_message,
        leg.open_enrollment_begin_period,
        leg.open_enrollment_end_period,
        leg.group_admin_rules_id,
        leg.its_prefix,
        leg.premium_age_calc_method,
        leg.member_id_card_stock,
        leg.member_id_card_type,
        leg.hedis_continuous_enrollment_break,
        leg.hedis_continuous_enrollment_days,
        leg.plan_year_begin_date,
        leg.network_set_prefix,
        leg.plan_year_month,
        leg.covering_provider_set_prefix,
        leg.hra_admin_info_id,
        leg.postponement_indicator,
        leg.debit_card_bank_relationship_prefix,
        leg.dental_utilization_edits_prefix,
        leg.value_based_benefits_parms_id,
        leg.billing_strategy_vision,
        leg.lock_token,
        leg.attachment_source_id,

        -- System metadata
        leg.last_update_datetime,
        leg.last_update_user_id,
        leg.last_update_dbms_user_id,

        -- NVL fields
        leg.secondary_plan_processing_code,
        leg.auth_cert_related_entity_id,
        leg.its_account_exception,
        leg.policy_renewal_begins_date,
        leg.health_insurance_oversight_system_id,
        leg.its_prefix_account_id,
        leg.patient_care_program_set,

        -- Data Vault metadata
        coalesce(leg.record_source, gem.record_source) as record_source,
        l.link_load_datetime as record_created_date,
        coalesce(leg.load_datetime, gem.load_datetime) as last_modified_date

    from link_base l
    left join legacy_sat_current leg
        on l.group_product_category_class_plan_lk = leg.group_product_category_class_plan_lk
    left join gemstone_sat_current gem
        on l.group_product_category_class_plan_lk = gem.group_product_category_class_plan_lk
)

select * from final
