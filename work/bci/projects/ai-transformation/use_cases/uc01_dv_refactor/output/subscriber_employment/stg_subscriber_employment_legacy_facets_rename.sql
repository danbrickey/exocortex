with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_facets_hist__dbo_cmc_sbem_employ') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        sbsb_ck as subscriber_bk,
        sbem_eff_dt as employment_eff_dt,
        sbem_term_dt as employment_term_dt,
        sbem_mctr_trsn as employment_term_reason_cd,
        grgr_ck as group_bk,
        sbem_occ_cd as occupation_cd,
        sbem_dept as department_cd,
        sbem_loc as location_cd,
        sbem_type as employment_type_cd,
        sbem_mctr_dtyp as non_discrimination_type_cd,
        sbem_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
