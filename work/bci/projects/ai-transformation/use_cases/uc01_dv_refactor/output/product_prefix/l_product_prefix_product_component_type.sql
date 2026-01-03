{{
    config(
        materialized='incremental',
        unique_key='product_prefix_product_component_type_lk',
        tags=['raw_vault', 'link', 'product_prefix', 'product_component_type']
    )
}}

/*
    Link: product_prefix_product_component_type
    Relationship: Product Component Type Link to Product Component Prefix
    Business Keys: pdbc_pfx (Component Prefix ID) + pdbc_type (Component Type)

    Purpose: Represents the many-to-many relationship between product prefixes
    and product component types. This link captures all unique combinations of
    prefix and type associations across all source systems.

    Parent Hubs:
    - h_product_prefix (pdbc_pfx)
    - h_product_component_type (pdbc_type)

    Source Systems:
    - legacy_facets
    - gemstone_facets
*/

{%- set yaml_metadata -%}
source_model:
  stg_product_prefix_legacy_facets:
    src_pk: "product_prefix_product_component_type_lk"
    src_fk:
      - "product_prefix_hk"
      - "product_component_type_hk"
    src_ldts: "load_datetime"
    src_source: "source"
  stg_product_prefix_gemstone_facets:
    src_pk: "product_prefix_product_component_type_lk"
    src_fk:
      - "product_prefix_hk"
      - "product_component_type_hk"
    src_ldts: "load_datetime"
    src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_pk"],
                    src_fk=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_fk"],
                    src_ldts=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_ldts"],
                    src_source=metadata_dict["source_model"]["stg_product_prefix_legacy_facets"]["src_source"],
                    source_model=metadata_dict["source_model"]) }}
