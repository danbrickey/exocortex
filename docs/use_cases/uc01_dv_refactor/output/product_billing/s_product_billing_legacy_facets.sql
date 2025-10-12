-- s_product_billing_legacy_facets.sql
-- Purpose: Effectivity satellite for product billing from legacy_facets source
-- Attached to: l_product_billing_product_prefix (link)
-- Contains: All descriptive attributes with temporal validity tracking

{{
    config(
        materialized='incremental',
        unique_key='product_billing_product_prefix_lk',
        tags=['raw_vault', 'satellite', 'effectivity', 'product_billing', 'legacy_facets']
    )
}}

{%- set yaml_metadata -%}
source_model: stg_product_billing_legacy_facets
src_pk: product_billing_product_prefix_lk
src_dfk:
  - product_billing_hk
  - product_prefix_hk
src_sfk: product_billing_hk
src_start_date: effective_date
src_end_date: termination_date
src_eff: effective_date
src_ldts: load_datetime
src_source: record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{%- set source_columns -%}
[
    'billing_component_id',
    'billing_group_ck',
    'experience_category',
    'accounting_category',
    'line_of_business_pct',
    'billing_component_type',
    'carrier_id',
    'conv_rate_table_pfx',
    'mpp_rate_table_pfx',
    'mpp_liab_table_pfx',
    'volume_table_pfx',
    'area_factor_pfx',
    'area_definition',
    'area_mod_type',
    'sic_factor_pfx',
    'sic_mod_type',
    'trend_factor_pfx',
    'trend_mod_type',
    'load_type',
    'load_pct',
    'load_amt',
    'commission_incl_ind',
    'medicare_rate_table_pfx',
    'medicare_esrd_table_pfx',
    'medicare_factor_table_pfx',
    'split_billing_ind',
    'split_pct',
    'conv_rate_mod',
    'mpp_rate_mod',
    'mpp_liab_mod',
    'volume_reduction_pfx',
    'capitation_premium_pct',
    'smoker_factor_pfx',
    'gender_factor_pfx',
    'und_class_1_pfx',
    'und_class_2_pfx',
    'und_class_3_pfx',
    'rounding_level',
    'lock_token',
    'attachment_source_id',
    'sys_last_upd_dtm',
    'sys_usus_id',
    'sys_dbuser_id'
]
{%- endset -%}

{{ automate_dv.eff_sat(src_pk=metadata_dict['src_pk'],
                       src_dfk=metadata_dict['src_dfk'],
                       src_sfk=metadata_dict['src_sfk'],
                       src_start_date=metadata_dict['src_start_date'],
                       src_end_date=metadata_dict['src_end_date'],
                       src_eff=metadata_dict['src_eff'],
                       src_ldts=metadata_dict['src_ldts'],
                       src_source=metadata_dict['src_source'],
                       source_model=metadata_dict['source_model']) }}
