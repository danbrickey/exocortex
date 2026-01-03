-- h_product_billing.sql
-- Purpose: Hub for product billing component entity
-- Business Key: billing_component_pfx (pdbc_pfx)

{{
    config(
        materialized='incremental',
        unique_key='product_billing_hk',
        tags=['raw_vault', 'hub', 'product_billing']
    )
}}

{%- set source_models = [
    'stg_product_billing_legacy_facets',
    'stg_product_billing_gemstone_facets'
] -%}

{%- set yaml_metadata -%}
source_model:
  - stg_product_billing_legacy_facets
  - stg_product_billing_gemstone_facets
src_pk: product_billing_hk
src_nk: billing_component_pfx
src_ldts: load_datetime
src_source: record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                   src_nk=metadata_dict['src_nk'],
                   src_ldts=metadata_dict['src_ldts'],
                   src_source=metadata_dict['src_source'],
                   source_model=metadata_dict['source_model']) }}
