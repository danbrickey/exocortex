{{
    config(
        materialized='incremental',
        unique_key='benefit_summary_text_lk',
        tags=['link', 'benefit_summary_text']
    )
}}

{%- set source_models = [
    'stg_benefit_summary_text_legacy_facets',
    'stg_benefit_summary_text_gemstone_facets'
] -%}

{%- set yaml_metadata -%}
source_model:
  - 'stg_benefit_summary_text_legacy_facets'
  - 'stg_benefit_summary_text_gemstone_facets'
src_pk: 'benefit_summary_text_lk'
src_fk:
  - 'product_prefix_hk'
  - 'benefit_summary_type_hk'
  - 'benefit_summary_text_sequence_hk'
src_ldts: 'load_datetime'
src_source: 'source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
