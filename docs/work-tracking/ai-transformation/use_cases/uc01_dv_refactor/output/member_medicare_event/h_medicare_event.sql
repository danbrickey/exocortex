{{
    config(
        materialized='incremental',
        unique_key='medicare_event_hk'
    )
}}

{%- set source_models = [
    'stg_member_medicare_event_legacy_facets',
    'stg_member_medicare_event_gemstone_facets'
] -%}

{%- set yaml_metadata -%}
source_model:
  legacy_facets: stg_member_medicare_event_legacy_facets
  gemstone_facets: stg_member_medicare_event_gemstone_facets
src_pk: medicare_event_hk
src_nk: medicare_event_cd
src_ldts: load_datetime
src_source: source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict['src_pk'],
                    src_nk=metadata_dict['src_nk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
