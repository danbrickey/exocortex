-- s_group_plan_eligibility_legacy_facets.sql
-- Effectivity Satellite for group_plan_eligibility legacy facets
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
        record_source,
        load_datetime,
        last_seen_datetime

    from {{ ref('stg_group_plan_eligibility_legacy_facets') }}
),

hashed_diff as (
    select
        *,
        {{ dbt_utils.generate_surrogate_key([
            'product_id',
            'selectable_indicator',
            'family_indicator',
            'rate_guarantee_date',
            'rate_guarantee_period_months',
            'rate_guarantee_indicator',
            'age_volume_reduction_table_prefix',
            'user_warning_message',
            'open_enrollment_begin_period',
            'open_enrollment_end_period',
            'group_admin_rules_id',
            'its_prefix',
            'premium_age_calc_method',
            'member_id_card_stock',
            'member_id_card_type',
            'hedis_continuous_enrollment_break',
            'hedis_continuous_enrollment_days',
            'plan_year_begin_date',
            'network_set_prefix',
            'plan_year_month',
            'covering_provider_set_prefix',
            'hra_admin_info_id',
            'postponement_indicator',
            'debit_card_bank_relationship_prefix',
            'dental_utilization_edits_prefix',
            'value_based_benefits_parms_id',
            'billing_strategy_vision',
            'lock_token',
            'attachment_source_id',
            'secondary_plan_processing_code',
            'auth_cert_related_entity_id',
            'its_account_exception',
            'policy_renewal_begins_date',
            'health_insurance_oversight_system_id',
            'its_prefix_account_id',
            'patient_care_program_set'
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
