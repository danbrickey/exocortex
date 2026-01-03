with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_facets_hist__dbo_cmc_mees_exchange') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        cspd_cat as product_category_bk,
        mees_eff_dt as exchange_effective_dt,
        mees_term_dt as exchange_termination_dt,
        grgr_ck as group_bk,
        mees_channel as exchange_channel_cd,
        mees_exchange as exchange_id,
        mees_mctr_meth as enrollment_method_cd,
        mees_aptc_ind as aptc_indicator,
        mees_lock_token as lock_token_nbr,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as system_last_update_dtm,
        sys_usus_id as system_update_user_id,
        sys_dbuser_id as system_update_db_user_id,
        mees_qhp_id_nvl as qhp_identifier,
        mees_mem_id_nvl as exchange_assigned_member_id,
        mees_policy_id_nvl as exchange_policy_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
