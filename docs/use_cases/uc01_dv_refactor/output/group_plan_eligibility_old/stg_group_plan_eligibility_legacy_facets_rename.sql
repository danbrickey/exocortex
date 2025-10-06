with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_cspi_cs_plan') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        grgr_ck as group_bk,
        cscs_id as class_bk,
        cspd_cat as product_category_bk,
        cspi_id as plan_bk,
        cspi_eff_dt as plan_eff_dt,
        cspi_term_dt as plan_term_dt,
        pdpd_id as product_id,
        cspi_sel_ind as selectable_ind,
        cspi_fi as family_ind,
        cspi_guar_dt as rate_guarantee_dt,
        cspi_guar_per_mos as rate_guarantee_period_mos,
        cspi_guar_ind as rate_guarantee_ind,
        pmar_pfx as age_volume_reduction_table_pfx,
        wmds_seq_no as warning_message_seq_no,
        cspi_open_beg_mmdd as open_enrollment_begin_mmdd,
        cspi_open_end_mmdd as open_enrollment_end_mmdd,
        gpai_id as group_admin_rules_id,
        cspi_its_prefix as its_prefix,
        cspi_age_calc_meth as premium_age_calc_method,
        cspi_card_stock as member_id_card_stock,
        cspi_mctr_ctyp as product_member_id_card_type,
        cspi_hedis_cebreak as hedis_continuous_enrollment_break,
        cspi_hedis_days as hedis_continuous_enrollment_days,
        cspi_pdpd_beg_mmdd as plan_year_begin_mmdd,
        nwst_pfx as network_set_pfx,
        cspi_pdpd_co_mnth as plan_product_co_month,
        cvst_pfx as covering_provider_set_pfx,
        hsai_id as hra_admin_info_id,
        cspi_postpone_ind as postponement_ind,
        grdc_pfx as debit_card_bank_rel_pfx,
        uted_pfx as dental_util_edits_pfx,
        vbbr_id as value_based_benefits_parms_id,
        svbl_id as billing_strategy_vision_id,
        cspi_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_dtm,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_db_user_id,
        cspi_sec_plan_cd_nvl as secondary_plan_processing_cd,
        mcre_id_nvl as auth_cert_entity_id,
        cspi_its_acct_excp_nvl as its_account_exception,
        cspi_ren_beg_mmdd_nvl as policy_renewal_begins_mmdd,
        cspi_hios_id_nvl as hios_id,
        cspi_itspfx_acctid_nvl as its_prefix_account_id,
        pgps_pfx as patient_care_program_set_pfx,

        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
