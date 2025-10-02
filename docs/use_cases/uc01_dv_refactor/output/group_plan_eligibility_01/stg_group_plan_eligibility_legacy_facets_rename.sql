-- stg_group_plan_eligibility_legacy_facets_rename.sql
-- Rename view for group_plan_eligibility legacy facets
-- Source: dbo.cmc_cspi_cs_plan

{{
    config(
        materialized='view',
        schema='staging'
    )
}}

select
    -- Business Keys
    grgr_ck as group_contrived_key,
    cscs_id as class_id,
    cspd_cat as product_category,
    cspi_id as plan_id,

    -- Effectivity Columns
    cspi_eff_dt as effective_date,
    cspi_term_dt as termination_date,

    -- Descriptive Attributes
    pdpd_id as product_id,
    cspi_sel_ind as selectable_indicator,
    cspi_fi as family_indicator,
    cspi_guar_dt as rate_guarantee_date,
    cspi_guar_per_mos as rate_guarantee_period_months,
    cspi_guar_ind as rate_guarantee_indicator,
    pmar_pfx as age_volume_reduction_table_prefix,
    wmds_seq_no as user_warning_message,
    cspi_open_beg_mmdd as open_enrollment_begin_period,
    cspi_open_end_mmdd as open_enrollment_end_period,
    gpai_id as group_admin_rules_id,
    cspi_its_prefix as its_prefix,
    cspi_age_calc_meth as premium_age_calc_method,
    cspi_card_stock as member_id_card_stock,
    cspi_mctr_ctyp as member_id_card_type,
    cspi_hedis_cebreak as hedis_continuous_enrollment_break,
    cspi_hedis_days as hedis_continuous_enrollment_days,
    cspi_pdpd_beg_mmdd as plan_year_begin_date,
    nwst_pfx as network_set_prefix,
    cspi_pdpd_co_mnth as plan_year_month,
    cvst_pfx as covering_provider_set_prefix,
    hsai_id as hra_admin_info_id,
    cspi_postpone_ind as postponement_indicator,
    grdc_pfx as debit_card_bank_relationship_prefix,
    uted_pfx as dental_utilization_edits_prefix,
    vbbr_id as value_based_benefits_parms_id,
    svbl_id as billing_strategy_vision,
    cspi_lock_token as lock_token,
    atxr_source_id as attachment_source_id,

    -- System Metadata
    sys_last_upd_dtm as last_update_datetime,
    sys_usus_id as last_update_user_id,
    sys_dbuser_id as last_update_dbms_user_id,

    -- NVL Fields
    cspi_sec_plan_cd_nvl as secondary_plan_processing_code,
    mcre_id_nvl as auth_cert_related_entity_id,
    cspi_its_acct_excp_nvl as its_account_exception,
    cspi_ren_beg_mmdd_nvl as policy_renewal_begins_date,
    cspi_hios_id_nvl as health_insurance_oversight_system_id,
    cspi_itspfx_acctid_nvl as its_prefix_account_id,
    pgps_pfx as patient_care_program_set

from {{ source('legacy', 'cmc_cspi_cs_plan') }}
