with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_facets_hist__dbo_cmc_mest_student') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        mest_eff_dt as student_eff_dt,
        mest_term_dt as student_term_dt,
        mest_mctr_trsn as termination_reason_cd,
        grgr_ck as group_bk,
        mest_school_name as school_name,
        mest_type as student_type,
        mest_last_ver_dt as last_verification_dt,
        mest_last_ver_name as last_verification_name,
        mest_mctr_vmth as verification_method_cd,
        mest_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
