-- current_product_billing.sql
-- Purpose: Current view showing active product billing records across all source systems
-- Logic: Union all sources, filter to current/active records based on effectivity dates

{{
    config(
        materialized='view',
        tags=['business_vault', 'current_view', 'product_billing']
    )
}}

with hub as (
    select
        product_billing_hk,
        billing_component_pfx,
        load_datetime as hub_load_datetime,
        record_source as hub_record_source
    from {{ ref('h_product_billing') }}
),

link as (
    select
        product_billing_product_prefix_lk,
        product_billing_hk,
        product_prefix_hk,
        load_datetime as link_load_datetime,
        record_source as link_record_source
    from {{ ref('l_product_billing_product_prefix') }}
),

sat_legacy as (
    select
        product_billing_product_prefix_lk,
        effective_date,
        termination_date,
        load_datetime as sat_load_datetime,
        record_source as sat_record_source,

        -- Descriptive attributes
        billing_component_id,
        billing_group_ck,
        experience_category,
        accounting_category,
        line_of_business_pct,
        billing_component_type,
        carrier_id,
        conv_rate_table_pfx,
        mpp_rate_table_pfx,
        mpp_liab_table_pfx,
        volume_table_pfx,
        area_factor_pfx,
        area_definition,
        area_mod_type,
        sic_factor_pfx,
        sic_mod_type,
        trend_factor_pfx,
        trend_mod_type,
        load_type,
        load_pct,
        load_amt,
        commission_incl_ind,
        medicare_rate_table_pfx,
        medicare_esrd_table_pfx,
        medicare_factor_table_pfx,
        split_billing_ind,
        split_pct,
        conv_rate_mod,
        mpp_rate_mod,
        mpp_liab_mod,
        volume_reduction_pfx,
        capitation_premium_pct,
        smoker_factor_pfx,
        gender_factor_pfx,
        und_class_1_pfx,
        und_class_2_pfx,
        und_class_3_pfx,
        rounding_level,
        lock_token,
        attachment_source_id,
        sys_last_upd_dtm,
        sys_usus_id,
        sys_dbuser_id,

        -- Effectivity tracking
        case
            when termination_date is null or termination_date > current_timestamp()
            then 'A'
            else 'I'
        end as record_status,

        -- Row number for getting latest record per link key
        row_number() over (
            partition by product_billing_product_prefix_lk
            order by effective_date desc, load_datetime desc
        ) as rn

    from {{ ref('s_product_billing_legacy_facets') }}
),

sat_gemstone as (
    select
        product_billing_product_prefix_lk,
        effective_date,
        termination_date,
        load_datetime as sat_load_datetime,
        record_source as sat_record_source,

        -- Descriptive attributes
        billing_component_id,
        billing_group_ck,
        experience_category,
        accounting_category,
        line_of_business_pct,
        billing_component_type,
        carrier_id,
        conv_rate_table_pfx,
        mpp_rate_table_pfx,
        mpp_liab_table_pfx,
        volume_table_pfx,
        area_factor_pfx,
        area_definition,
        area_mod_type,
        sic_factor_pfx,
        sic_mod_type,
        trend_factor_pfx,
        trend_mod_type,
        load_type,
        load_pct,
        load_amt,
        commission_incl_ind,
        medicare_rate_table_pfx,
        medicare_esrd_table_pfx,
        medicare_factor_table_pfx,
        split_billing_ind,
        split_pct,
        conv_rate_mod,
        mpp_rate_mod,
        mpp_liab_mod,
        volume_reduction_pfx,
        capitation_premium_pct,
        smoker_factor_pfx,
        gender_factor_pfx,
        und_class_1_pfx,
        und_class_2_pfx,
        und_class_3_pfx,
        rounding_level,
        lock_token,
        attachment_source_id,
        sys_last_upd_dtm,
        sys_usus_id,
        sys_dbuser_id,

        -- Effectivity tracking
        case
            when termination_date is null or termination_date > current_timestamp()
            then 'A'
            else 'I'
        end as record_status,

        -- Row number for getting latest record per link key
        row_number() over (
            partition by product_billing_product_prefix_lk
            order by effective_date desc, load_datetime desc
        ) as rn

    from {{ ref('s_product_billing_gemstone_facets') }}
),

-- Union both source systems
all_satellites as (
    select * from sat_legacy where rn = 1
    union all
    select * from sat_gemstone where rn = 1
),

-- Get the most recent record across all sources
latest_satellite as (
    select
        *,
        row_number() over (
            partition by product_billing_product_prefix_lk
            order by effective_date desc, sat_load_datetime desc
        ) as source_rn
    from all_satellites
),

final as (
    select
        -- Hub attributes
        h.product_billing_hk,
        h.billing_component_pfx,
        h.hub_load_datetime,
        h.hub_record_source,

        -- Link attributes
        l.product_billing_product_prefix_lk,
        l.product_prefix_hk,
        l.link_load_datetime,
        l.link_record_source,

        -- Satellite temporal attributes
        s.effective_date,
        s.termination_date,
        s.record_status,
        s.sat_load_datetime,
        s.sat_record_source,

        -- All descriptive attributes
        s.billing_component_id,
        s.billing_group_ck,
        s.experience_category,
        s.accounting_category,
        s.line_of_business_pct,
        s.billing_component_type,
        s.carrier_id,
        s.conv_rate_table_pfx,
        s.mpp_rate_table_pfx,
        s.mpp_liab_table_pfx,
        s.volume_table_pfx,
        s.area_factor_pfx,
        s.area_definition,
        s.area_mod_type,
        s.sic_factor_pfx,
        s.sic_mod_type,
        s.trend_factor_pfx,
        s.trend_mod_type,
        s.load_type,
        s.load_pct,
        s.load_amt,
        s.commission_incl_ind,
        s.medicare_rate_table_pfx,
        s.medicare_esrd_table_pfx,
        s.medicare_factor_table_pfx,
        s.split_billing_ind,
        s.split_pct,
        s.conv_rate_mod,
        s.mpp_rate_mod,
        s.mpp_liab_mod,
        s.volume_reduction_pfx,
        s.capitation_premium_pct,
        s.smoker_factor_pfx,
        s.gender_factor_pfx,
        s.und_class_1_pfx,
        s.und_class_2_pfx,
        s.und_class_3_pfx,
        s.rounding_level,
        s.lock_token,
        s.attachment_source_id,
        s.sys_last_upd_dtm,
        s.sys_usus_id,
        s.sys_dbuser_id

    from hub h
    inner join link l
        on h.product_billing_hk = l.product_billing_hk
    inner join latest_satellite s
        on l.product_billing_product_prefix_lk = s.product_billing_product_prefix_lk
    where s.source_rn = 1
        and s.record_status = 'A'  -- Only active records
)

select * from final
