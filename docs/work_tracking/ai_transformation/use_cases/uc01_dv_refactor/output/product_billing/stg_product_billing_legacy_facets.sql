-- stg_product_billing_legacy_facets.sql
-- Purpose: Prepare data from legacy_facets with hash keys and hashdiffs for vault loading
-- Source: stg_product_billing_legacy_facets_rename

{%- set yaml_metadata -%}
source_model: stg_product_billing_legacy_facets_rename
derived_columns:
  record_source: '!legacy_facets'
  load_datetime: current_timestamp()
  tenant_id: '!edp'
  edp_start_dt: effective_date
  edp_end_dt: termination_date
  edp_record_status: |
    case
        when termination_date is null or termination_date > current_timestamp()
        then 'A'
        else 'I'
    end
hashed_columns:
  product_billing_hk:
    - billing_component_pfx
  product_prefix_hk:
    - product_type
  product_billing_product_prefix_lk:
    - billing_component_pfx
    - product_type
  product_billing_hashdiff:
    is_hashdiff: true
    columns:
      - billing_component_id
      - billing_group_ck
      - experience_category
      - accounting_category
      - line_of_business_pct
      - billing_component_type
      - carrier_id
      - conv_rate_table_pfx
      - mpp_rate_table_pfx
      - mpp_liab_table_pfx
      - volume_table_pfx
      - area_factor_pfx
      - area_definition
      - area_mod_type
      - sic_factor_pfx
      - sic_mod_type
      - trend_factor_pfx
      - trend_mod_type
      - load_type
      - load_pct
      - load_amt
      - commission_incl_ind
      - medicare_rate_table_pfx
      - medicare_esrd_table_pfx
      - medicare_factor_table_pfx
      - split_billing_ind
      - split_pct
      - conv_rate_mod
      - mpp_rate_mod
      - mpp_liab_mod
      - volume_reduction_pfx
      - capitation_premium_pct
      - smoker_factor_pfx
      - gender_factor_pfx
      - und_class_1_pfx
      - und_class_2_pfx
      - und_class_3_pfx
      - rounding_level
      - lock_token
      - attachment_source_id
      - sys_last_upd_dtm
      - sys_usus_id
      - sys_dbuser_id
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     hashed_columns=metadata_dict['hashed_columns']) }}
