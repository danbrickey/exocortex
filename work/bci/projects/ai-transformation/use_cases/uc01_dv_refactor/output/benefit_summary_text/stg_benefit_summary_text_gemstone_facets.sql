{{
    config(
        materialized='view',
        tags=['staging', 'benefit_summary_text', 'gemstone_facets']
    )
}}

{%- set yaml_metadata -%}
source_model: 'stg_benefit_summary_text_gemstone_facets_rename'
derived_columns:
  source: 'gemstone_facets'
  load_datetime: current_timestamp()
hashed_columns:
  benefit_summary_text_sequence_hk:
    - "benefit_summary_text_seq_no"
  product_prefix_hk:
    - "product_prefix"
  benefit_summary_type_hk:
    - "benefit_summary_type"
  benefit_summary_text_lk:
    - "product_prefix"
    - "benefit_summary_type"
    - "benefit_summary_text_seq_no"
  benefit_summary_text_hashdiff:
    is_hashdiff: true
    columns:
      - "benefit_summary_text"
      - "lock_token"
      - "attachment_source_id"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      derived_columns=metadata_dict['derived_columns'],
                      hashed_columns=metadata_dict['hashed_columns']) }}
