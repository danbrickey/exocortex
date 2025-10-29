with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_mehd_handicap') }}
),

renamed as (
    select
        '{{ var("gemstone_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        mehd_eff_dt as disability_eff_dt,
        mehd_term_dt as disability_term_dt,
        mehd_mctr_trsn as disability_term_reason_cd,
        grgr_ck as group_bk,
        mehd_desc as disability_desc,
        mehd_type as disability_type_cd,
        mehd_last_ver_dt as last_verification_dt,
        mehd_last_ver_name as last_verification_name,
        mehd_mctr_vmth as verification_method_cd,
        mehd_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
