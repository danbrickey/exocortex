-- stg_group_plan_eligibility_legacy_facets.sql
-- Staging view for group_plan_eligibility legacy facets with Data Vault metadata
-- Source: dbo.cmc_cspi_cs_plan via rename view

{{
    config(
        materialized='view',
        schema='staging'
    )
}}

with source as (
    select * from {{ ref('stg_group_plan_eligibility_legacy_facets_rename') }}
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

        -- Descriptive Attributes
        product_id,
        selectable_indicator,
        family_indicator,
        rate_guarantee_date,
        rate_guarantee_period_months,
        rate_guarantee_indicator,
        age_volume_reduction_table_prefix,
        user_warning_message,
        open_enrollment_begin_period,
        open_enrollment_end_period,
        group_admin_rules_id,
        its_prefix,
        premium_age_calc_method,
        member_id_card_stock,
        member_id_card_type,
        hedis_continuous_enrollment_break,
        hedis_continuous_enrollment_days,
        plan_year_begin_date,
        network_set_prefix,
        plan_year_month,
        covering_provider_set_prefix,
        hra_admin_info_id,
        postponement_indicator,
        debit_card_bank_relationship_prefix,
        dental_utilization_edits_prefix,
        value_based_benefits_parms_id,
        billing_strategy_vision,
        lock_token,
        attachment_source_id,

        -- System Metadata
        last_update_datetime,
        last_update_user_id,
        last_update_dbms_user_id,

        -- NVL Fields
        secondary_plan_processing_code,
        auth_cert_related_entity_id,
        its_account_exception,
        policy_renewal_begins_date,
        health_insurance_oversight_system_id,
        its_prefix_account_id,
        patient_care_program_set,

        -- Data Vault Metadata
        'LEGACY' as record_source,
        current_timestamp() as load_datetime,
        last_update_datetime as last_seen_datetime

    from source
)

select * from hashed
