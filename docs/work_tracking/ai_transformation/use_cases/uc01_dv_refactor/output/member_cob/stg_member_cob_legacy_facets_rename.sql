with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_mecb_cob') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        mecb_insur_type as cob_ins_type_bk,
        mecb_insur_order as cob_ins_order_bk,
        mecb_mctr_styp as cob_supp_drug_type_bk,
        mecb_eff_dt as cob_eff_dt,
        mecb_term_dt as cob_term_dt,
        mecb_mctr_trsn as cob_term_reason,
        grgr_ck as group_bk,
        mcre_id as cob_carrier_id,
        mecb_policy_id as cob_policy_id,
        mecb_mctr_msp as cob_msp_type,
        mecb_mctr_ptyp as cob_rx_coverage_type,
        mecb_rxbin as cob_rx_bin,
        mecb_rxpcn as cob_rx_pcn,
        mecb_rx_group as cob_rx_group,
        mecb_rx_id as cob_rx_id,
        mecb_last_ver_dt as cob_last_ver_dt,
        mecb_last_ver_name as cob_last_ver_name,
        mecb_mctr_vmth as cob_ver_method,
        mecb_loi_start_dt as cob_loi_start_dt,
        mecb_prim_last_nm as cob_prim_last_nm,
        mecb_prim_first_nm as cob_prim_first_nm,
        mecb_prim_id as cob_prim_id,
        mecb_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_dtm,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_db_user_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)
select * from renamed