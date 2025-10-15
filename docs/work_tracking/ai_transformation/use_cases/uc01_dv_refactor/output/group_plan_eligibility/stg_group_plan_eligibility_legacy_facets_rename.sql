-- stg_group_plan_eligibility_legacy_facets_rename.sql
-- Rename view for group plan eligibility from legacy FACETS system

with

source as (
    select * from {{ source('legacy_facets', 'cmc_cspi_cs_plan') }}
),

renamed as (
    select
        -- business keys
        grgr_ck as group_bk,
        cscs_id as class_bk,
        cspd_cat as product_category_bk,
        cspi_id as plan_bk,

        -- effectivity dates
        cspi_eff_dt as plan_effective_dt,
        cspi_term_dt as plan_termination_dt,

        -- product information
        pdpd_id as product_id,

        -- plan attributes
        cspi_sel_ind as plan_selectable_ind,
        cspi_fi as plan_family_ind,

        -- rate guarantee
        cspi_guar_dt as rate_guarantee_dt,
        cspi_guar_per_mos as rate_guarantee_period_months,
        cspi_guar_ind as rate_guarantee_ind,

        -- prefixes and references
        pmar_pfx as age_vol_reduction_tbl_pfx,
        wmds_seq_no as warning_message_seq_no,

        -- open enrollment
        cspi_open_beg_mmdd as open_enroll_begin_mmdd,
        cspi_open_end_mmdd as open_enroll_end_mmdd,

        -- administration
        gpai_id as group_admin_rules_id,
        cspi_its_prefix as its_prefix,
        cspi_age_calc_meth as premium_age_calc_method,

        -- card and id information
        cspi_card_stock as member_id_card_stock,
        cspi_mctr_ctyp as member_id_card_type,

        -- hedis
        cspi_hedis_cebreak as hedis_cont_enroll_break,
        cspi_hedis_days as hedis_cont_enroll_days,

        -- plan year
        cspi_pdpd_beg_mmdd as plan_year_begin_mmdd,
        cspi_pdpd_co_mnth as plan_co_month,

        -- network and coverage
        nwst_pfx as network_set_pfx,
        cvst_pfx as covering_provider_set_pfx,

        -- hra and postponement
        hsai_id as hra_admin_info_id,
        cspi_postpone_ind as postponement_ind,

        -- additional prefixes
        grdc_pfx as debit_card_bank_rel_pfx,
        uted_pfx as dental_util_edits_pfx,

        -- value based and billing
        vbbr_id as value_based_benefits_id,
        svbl_id as billing_strategy_id,

        -- system fields
        cspi_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_dtm,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_dbuser_id,

        -- nvl fields (nullable variants)
        cspi_sec_plan_cd_nvl as secondary_plan_cd,
        mcre_id_nvl as auth_cert_entity_id,
        cspi_its_acct_excp_nvl as its_account_exception,
        cspi_ren_beg_mmdd_nvl as renewal_begin_mmdd,
        cspi_hios_id_nvl as hios_id,
        cspi_itspfx_acctid_nvl as its_pfx_account_id,

        -- patient care
        pgps_pfx as patient_care_program_set_pfx,

        -- metadata
        'legacy_facets' as source,
        'BCI' as tenant_id

    from source
)

select * from renamed
