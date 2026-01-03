with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_facets_hist__dbo_cmc_sbrt_rate_data') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        sbsb_ck as subscriber_bk,
        sbrt_eff_dt as rating_eff_dt,
        sbrt_term_dt as rating_term_dt,
        grgr_ck as group_bk,
        sbrt_sb_bill_ind as subscriber_billing_ind,
        sbrt_smoker_ind as smoker_ind,
        sbrt_rt_st as rating_state_cd,
        sbrt_rt_cnty as rating_county_cd,
        sbrt_rt_area as rating_area_cd,
        sbrt_rt_sic as rating_sic_cd,
        sbrt_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
