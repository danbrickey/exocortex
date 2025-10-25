{{
    config(
        materialized='incremental',
        unique_key='product_prefix_hk',
        tags=['raw_vault', 'hub', 'product_prefix']
    )
}}

/*
    Hub: product_prefix
    Business Entity: Product Component Prefix
    Business Key: pdbc_pfx (Component Prefix ID)

    Purpose: Stores unique product prefix identifiers across all source systems.
    This hub represents the core business concept of a product component prefix.

    Source Systems:
    - legacy_facets
    - gemstone_facets
*/

{%- set yaml_metadata -%}
source_model:
  stg_product_prefix_legacy_facets:
    src_pk: "product_prefix_hk"
    src_nk: "product_prefix_bk"
    src_ldts: "load_datetime"
    src_source: "source"
  stg_product_prefix_gemstone_facets:
    src_pk: "product_prefix_hk"
    src_nk: "product_prefix_bk"
    src_ldts: "load_datetime"
    src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_pk"],
                   src_nk=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_nk"],
                   src_ldts=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_ldts"],
                   src_source=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_source"],
                   source_model=metadata_dict["source_model"]) }}
