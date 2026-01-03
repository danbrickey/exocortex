{{
    config(
        materialized='incremental',
        unique_key='member_medicare_event_lk'
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
src_pk: member_medicare_event_lk
src_fk:
  - member_hk
  - medicare_event_hk
src_ldts: load_datetime
src_source: source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                     src_fk=metadata_dict['src_fk'],
                     src_ldts=metadata_dict['src_ldts'],
                     src_source=metadata_dict['src_source'],
                     source_model=metadata_dict['source_model']) }}
