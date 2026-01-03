{{
    config(
        materialized='incremental',
        unique_key='benefit_summary_text_sequence_hk',
        tags=['hub', 'benefit_summary_text']
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
src_pk: 'benefit_summary_text_sequence_hk'
src_nk: 'benefit_summary_text_seq_no'
src_ldts: 'load_datetime'
src_source: 'source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
