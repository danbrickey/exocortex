{{
    config(
        materialized='incremental',
        unique_key=['product_prefix_product_component_type_lk', 'load_datetime'],
        tags=['raw_vault', 'satellite', 'link_satellite', 'product_prefix', 'legacy_facets']
    )
}}

/*
    Link Satellite: product_prefix_product_component_type (Legacy Facets)
    Parent Link: l_product_prefix_product_component_type
    Source System: legacy_facets
    Source Table: dbo.cmc_pdpx_desc

    Purpose: Stores descriptive attributes for the product prefix and component
    type relationship from the legacy_facets source system. Tracks changes over
    time using hash diff for change detection.

    Descriptive Attributes:
    - prefix_description: Component Prefix Description
    - lock_token: Lock Token
    - attachment_source_id: Attachment Source Id
    - system_row_id: System Row Id
*/

{%- set yaml_metadata -%}
source_model: "stg_product_prefix_legacy_facets"
src_pk: "product_prefix_product_component_type_lk"
src_hashdiff:
  source_column: "product_prefix_product_component_type_hashdiff"
  alias: "hashdiff"
src_payload:
  - "prefix_description"
  - "lock_token"
  - "attachment_source_id"
  - "system_row_id"
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"]) }}
