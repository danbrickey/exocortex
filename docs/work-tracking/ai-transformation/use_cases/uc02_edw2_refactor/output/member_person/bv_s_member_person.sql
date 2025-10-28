{{
    config(
        materialized='incremental',
        unique_key='member_hk',
        tags=['business_vault', 'satellite', 'member_person', 'computed']
    )
}}

{#
    Business Vault Computed Satellite: Member Person

    Purpose: Enriched member person data with external constituent ID and business rules applied

    Parent Hub: h_member (via member_hk)

    Type: Computed Satellite (derives data from raw vault + business logic)

    Business Logic:
    - Combines member demographics with external person identifier
    - Uses standardized source codes from raw vault
    - Filters for valid subscribers and groups
    - Excludes proxy subscribers

    History: Type 2 SCD - tracks all changes to member person attributes over time
#}

{% set yaml_metadata %}
parent_hashkey: 'member_hk'
src_hashdiff: 'member_person_hashdiff'
src_payload:
    - person_id
    - member_bk
    - person_bk
    - group_bk
    - subscriber_bk
    - member_suffix
    - member_first_name
    - member_last_name
    - member_sex
    - member_birth_dt
    - member_ssn
    - group_id
    - subscriber_identifier
    - source
    - member_source
src_eff: 'effective_from'
src_ldts: 'load_datetime'
src_source: 'source'
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(
    src_pk=metadata_dict['parent_hashkey'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model='stg_member_person_business'
) }}
