with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_mert_rate_data') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        mert_eff_dt as rating_eff_dt,
        mert_term_dt as rating_term_dt,
        grgr_ck as group_bk,
        mert_smoker_ind as smoker_ind,
        mert_mctr_fct1 as underwriting_class_1_cd,
        mert_mctr_fct2 as underwriting_class_2_cd,
        mert_mctr_fct3 as underwriting_class_3_cd,
        mert_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
