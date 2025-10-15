{{
    config(
        materialized='view',
        tags=['staging', 'product_prefix', 'legacy_facets']
    )
}}

/*
    Staging View: product_prefix (Legacy Facets)
    Source: stg_product_prefix_legacy_facets_rename
    Purpose: Prepare data for vault loading with hash keys and hashdiffs

    This view generates:
    - Hub hash keys (product_prefix_hk, product_component_type_hk)
    - Link hash key (product_prefix_product_component_type_lk)
    - Hash diff for change detection
    - Load metadata columns
*/

{%- set yaml_metadata -%}
source_model: "stg_product_prefix_legacy_facets_rename"
derived_columns:
  load_datetime: "current_timestamp()::timestamp_ntz"
  source: "source"
hashed_columns:
  product_prefix_hk:
    - "product_prefix_bk"
  product_component_type_hk:
    - "product_component_type_bk"
  product_prefix_product_component_type_lk:
    - "product_prefix_bk"
    - "product_component_type_bk"
  product_prefix_product_component_type_hashdiff:
    is_hashdiff: true
    columns:
      - "prefix_description"
      - "lock_token"
      - "attachment_source_id"
      - "system_row_id"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict["source_model"],
                     derived_columns=metadata_dict["derived_columns"],
                     hashed_columns=metadata_dict["hashed_columns"]) }}
