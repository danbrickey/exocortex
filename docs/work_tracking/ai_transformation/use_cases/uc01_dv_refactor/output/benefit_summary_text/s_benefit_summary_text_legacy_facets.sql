{{
    config(
        materialized='incremental',
        unique_key='benefit_summary_text_lk',
        tags=['satellite', 'benefit_summary_text', 'legacy_facets']
    )
}}

{%- set yaml_metadata -%}
source_model: 'stg_benefit_summary_text_legacy_facets'
src_pk: 'benefit_summary_text_lk'
src_hashdiff: 'benefit_summary_text_hashdiff'
src_payload:
  - 'product_prefix'
  - 'benefit_summary_type'
  - 'benefit_summary_text_seq_no'
  - 'benefit_summary_text'
  - 'lock_token'
  - 'attachment_source_id'
src_eff: 'load_datetime'
src_ldts: 'load_datetime'
src_source: 'source'
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict['src_pk'],
                    src_hashdiff=metadata_dict['src_hashdiff'],
                    src_payload=metadata_dict['src_payload'],
                    src_eff=metadata_dict['src_eff'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
