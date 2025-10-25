-- stg_product_billing_legacy_facets_rename.sql
-- Purpose: Rename and standardize source columns from legacy_facets for product_billing entity
-- Source: dbo.cmc_pdbl_prod_bill

with source as (
    select * from {{ source('legacy_facets', 'cmc_pdbl_prod_bill') }}
),

renamed as (
    select
        -- Business Keys
        pdbc_pfx as billing_component_pfx,
        pdbl_type as product_type,

        -- Descriptive Attributes
        pdbl_id as billing_component_id,
        pdbl_eff_dt as effective_date,
        pdbl_term_dt as termination_date,
        bgbg_ck as billing_group_ck,
        pdbl_exp_cat as experience_category,
        pdbl_acct_cat as accounting_category,
        pdbl_lobd_pct as line_of_business_pct,
        pdbl_mctr_ctyp as billing_component_type,
        mcre_crcr_id as carrier_id,
        pdrt_pfx_conv_rate as conv_rate_table_pfx,
        pdrt_pfx_mpp_rate as mpp_rate_table_pfx,
        pdrt_pfx_mpp_liab as mpp_liab_table_pfx,
        pdvl_pfx as volume_table_pfx,
        pmft_pfx_area_fctr as area_factor_pfx,
        pdbl_area_defn as area_definition,
        pdbl_area_mod_type as area_mod_type,
        pmft_pfx_sic_fctr as sic_factor_pfx,
        pdbl_sic_mod_type as sic_mod_type,
        pmtr_pfx as trend_factor_pfx,
        pdbl_trnd_mod_type as trend_mod_type,
        pdbl_load_type as load_type,
        pdbl_load_pct as load_pct,
        pdbl_load_amt as load_amt,
        pdbl_comm_incl_ind as commission_incl_ind,
        pdrt_pfx_hcfa as medicare_rate_table_pfx,
        pdrt_pfx_hcfa_esrd as medicare_esrd_table_pfx,
        mrfd_pfx as medicare_factor_table_pfx,
        pdbl_splt_bill_ind as split_billing_ind,
        pdbl_split_pct as split_pct,
        pdbl_conv_rate_mod as conv_rate_mod,
        pdbl_mpp_rate_mod as mpp_rate_mod,
        pdbl_mpp_liab_mod as mpp_liab_mod,
        pmar_pfx as volume_reduction_pfx,
        pdbl_cap_pop_pct as capitation_premium_pct,
        pdrt_pfx_smkr as smoker_factor_pfx,
        pdrt_pfx_gndr as gender_factor_pfx,
        pdrt_pfx_uncl1 as und_class_1_pfx,
        pdrt_pfx_uncl2 as und_class_2_pfx,
        pdrt_pfx_uncl3 as und_class_3_pfx,
        pdbl_round_lev as rounding_level,
        pdbl_lock_token as lock_token,
        atxr_source_id as attachment_source_id,

        -- System Audit Columns
        sys_last_upd_dtm,
        sys_usus_id,
        sys_dbuser_id,

        -- Standard Metadata
        'legacy_facets' as record_source,
        current_timestamp() as load_datetime,
        'edp' as tenant_id

    from source
)

select * from renamed
