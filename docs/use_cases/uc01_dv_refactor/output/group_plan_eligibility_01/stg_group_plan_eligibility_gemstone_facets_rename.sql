-- stg_group_plan_eligibility_gemstone_facets_rename.sql
-- Rename view for group_plan_eligibility gemstone facets
-- Source: dbo.cmc_cspi_cs_plan

{{
    config(
        materialized='view',
        schema='staging'
    )
}}

select
    -- Business Keys
    grgr_ck as group_contrived_key,
    cscs_id as class_id,
    cspd_cat as product_category,
    cspi_id as plan_id,

    -- Effectivity Columns
    cspi_eff_dt as effective_date,
    cspi_term_dt as termination_date,

    -- Descriptive Attributes (Gemstone-specific subset)
    pdpd_id as product_id,
    cspi_sel_ind as selectable_indicator,
    cspi_fi as family_indicator,
    gpai_id as group_admin_rules_id,
    cspi_its_prefix as its_prefix,
    nwst_pfx as network_set_prefix,
    cvst_pfx as covering_provider_set_prefix,
    cspi_postpone_ind as postponement_indicator,

    -- System Metadata
    sys_last_upd_dtm as last_update_datetime,
    sys_usus_id as last_update_user_id,
    sys_dbuser_id as last_update_dbms_user_id

from {{ source('legacy', 'cmc_cspi_cs_plan') }}
