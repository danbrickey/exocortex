-- l_product_billing_product_prefix.sql
-- Purpose: Link between product billing component and product prefix/type
-- Relationship: product_billing (via billing_component_pfx) <-> product_prefix (via product_type)

{{
    config(
        materialized='incremental',
        unique_key='product_billing_product_prefix_lk',
        tags=['raw_vault', 'link', 'product_billing']
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
src_pk: product_billing_product_prefix_lk
src_fk:
  - product_billing_hk
  - product_prefix_hk
src_ldts: load_datetime
src_source: record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
