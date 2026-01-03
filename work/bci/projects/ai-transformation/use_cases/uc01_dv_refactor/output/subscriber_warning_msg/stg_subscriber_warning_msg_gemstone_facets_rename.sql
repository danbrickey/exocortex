with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbwm_sb_msg') }}
),

renamed as (
    select
        '{{ var("gemstone_source_system") }}' as source,
        '1' as tenant_id,
        sbsb_ck as subscriber_bk,
        sbwm_eff_dt as warning_msg_eff_dt,
        wmds_seq_no as message_id,
        sbwm_term_dt as warning_msg_term_dt,
        sbwm_mctr_trsn as termination_reason_cd,
        grgr_ck as group_bk,
        sbwm_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
