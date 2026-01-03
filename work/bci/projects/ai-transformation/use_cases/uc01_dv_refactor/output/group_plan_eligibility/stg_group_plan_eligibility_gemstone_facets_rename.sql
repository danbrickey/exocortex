with source as (

    select * from {{ source('gemstone_facets', 'cmc_cspi_cs_plan') }}

),

renamed as (

    select
        'gemstone_facets' as source,
        {{ dbt_utils.generate_surrogate_key(["'gemstone_facets'"]) }} as tenant_id,
        grgr_ck as group_ck,
        cscs_id as class_id,
        cspd_cat as product_category,
        cspi_id as plan_id,
        cspi_eff_dt as effective_date,
        cspi_term_dt as termination_date,
        pdpd_id as product_id,
        cspi_sel_ind as selectable_indicator,
        cspi_fi as family_indicator,
        cspi_guar_dt as rate_guarantee_date,
        cspi_guar_per_mos as rate_guarantee_period_months,
        cspi_guar_ind as rate_guarantee_indicator,
        pmar_pfx as age_volume_reduction_prefix,
        wmds_seq_no as warning_message_seq_no,
        cspi_open_beg_mmdd as open_enrollment_begin_period,
        cspi_open_end_mmdd as open_enrollment_end_period,
        gpai_id as group_admin_rules_id,
        cspi_its_prefix as its_prefix,
        cspi_age_calc_meth as premium_age_calc_method,
        cspi_card_stock as member_id_card_stock,
        cspi_mctr_ctyp as product_member_id_card_type,
        cspi_hedis_cebreak as hedis_ce_break,
        cspi_hedis_days as hedis_ce_days,
        cspi_pdpd_beg_mmdd as plan_year_begin_date,
        nwst_pfx as network_set_prefix,
        cspi_pdpd_co_mnth as plan_year_co_month,
        cvst_pfx as covering_provider_set_prefix,
        hsai_id as hra_admin_info_id,
        cspi_postpone_ind as postponement_indicator,
        grdc_pfx as debit_card_bank_rel_prefix,
        uted_pfx as dental_util_edits_prefix,
        vbbr_id as value_based_benefits_parms_id,
        svbl_id as billing_strategy_vision,
        cspi_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_datetime,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_dbms_user_id,
        cspi_sec_plan_cd_nvl as secondary_plan_proc_code,
        mcre_id_nvl as auth_cert_rel_entity_id,
        cspi_its_acct_excp_nvl as its_account_exception,
        cspi_ren_beg_mmdd_nvl as policy_issuance_renewal_begin_date,
        cspi_hios_id_nvl as hios_identifier,
        cspi_itspfx_acctid_nvl as its_prefix_account_id,
        pgps_pfx as patient_care_program_set

    from source

)

select * from renamed
