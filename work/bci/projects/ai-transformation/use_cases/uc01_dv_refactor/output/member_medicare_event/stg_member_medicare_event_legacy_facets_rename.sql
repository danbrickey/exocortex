with

source as (

    select * from {{ source('legacy_facets', 'cmc_memd_mecr_detl') }}

),

renamed as (

    select
        -- business keys
        meme_ck as member_ck,
        memd_event_cd as medicare_event_cd,

        -- foreign keys
        grgr_ck as group_ck,
        bgbg_ck as benefit_group_ck,

        -- effectivity dates
        memd_hcfa_eff_dt as hcfa_eff_dt,
        memd_hcfa_term_dt as hcfa_term_dt,

        -- date fields
        memd_input_dt as input_dt,
        memd_event_eff_dt as event_eff_dt,
        memd_event_term_dt as event_term_dt,
        memd_sig_dt as signature_dt,

        -- medicare codes
        memd_mctr_mcst as medicare_state,
        memd_mctr_mcct as medicare_county,
        memd_mctr_pbp as medicare_plan_benefit_pkg,
        memd_mctr_rx_group as medicare_rx_group_id,
        memd_mctr_rxbin as medicare_rxbin,
        memd_mctr_rxpcn as medicare_rxpcn,
        memd_mctr_srsn_nvl as medicare_sep_reason,
        memd_mctr_erel_nvl as medicare_enrollee_relation,

        -- health insurance claim number
        meme_hicn as health_ins_claim_number,

        -- risk adjustment
        mrac_cat as pipdcg_category,
        memd_ra_prta_fctr as risk_adj_part_a_factor,
        memd_ra_prtb_fctr as risk_adj_part_b_factor,
        memd_ra_prtd_fctr as risk_adj_part_d_factor,
        memd_ra_fctr_type as risk_adj_factor_type,
        memd_rad_fctr_type as risk_adj_part_d_fctr_type,

        -- election and enrollment
        memd_elect_type as election_type,
        memd_segment_id as segment_id,
        memd_enrl_source as enrollment_source,
        memd_prem_wh_opt as premium_withhold_option,
        memd_prior_com_ovr as prior_commercial_override,

        -- premiums
        memd_prtc_prem as part_c_premium,
        memd_prtd_prem as part_d_premium,

        -- part d information
        memd_uncov_mos as uncovered_months,
        memd_rx_id as part_d_id,

        -- coordination of benefits
        memd_cob_ind as secondary_drug_ins_flag,
        memd_cob_rx_id as secondary_drug_ins_id,
        memd_cob_rx_group as secondary_drug_ins_group,
        memd_cob_rxbin as secondary_drug_ins_bin,
        memd_cob_rxpcn as secondary_drug_ins_pcn,

        -- subsidies and penalties
        memd_partd_sbsdy as part_d_subsidy,
        memd_copay_cat as copay_category,
        memd_lics_sbsdy as low_income_premium_subsidy,
        memd_late_penalty as late_enrollment_penalty,
        memd_late_waiv_amt as late_enrollment_penalty_waived,
        memd_late_sbsdy as late_enrollment_penalty_subsidy,

        -- msp
        memd_msp_cd as aged_disabled_msp_status,

        -- system fields
        memd_lock_token as lock_token,
        atxr_source_id as attachment_source_id,

        -- ic model fields
        memd_ic_flag_nvl as ic_model_flag,
        memd_ic_sts_nvl as ic_model_benefit_status_cd,
        memd_ic_trsn_nvl as ic_model_end_date_reason,

        -- accessibility
        memd_pref_lang_nvl as preferred_language,
        memd_access_fmt_nvl as accessible_format,

        -- npn
        memd_npn_nvl as national_producer_number,

        -- metadata
        'legacy_facets' as source,
        'tenant_1' as tenant_id

    from source

)

select * from renamed
