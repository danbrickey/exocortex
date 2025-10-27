{{
    config(
        materialized='view',
        tags=['staging', 'member_person', 'business_vault']
    )
}}

{#
    Staging model for member_person business vault computed satellite

    Purpose: Generate hash keys and hashdiff for bv_s_member_person computed satellite

    This model prepares the data from prep_member_person for loading into the
    business vault by adding:
    - Hash keys for the parent hub
    - Hash diff for change detection
    - Standard data vault metadata columns
#}

{% set yaml_metadata %}
source_model: 'prep_member_person'
hashed_columns:
    member_person_hk:
        - member_bk
    member_person_hashdiff:
        is_hashdiff: true
        columns:
            - constituent_id
            - member_suffix
            - member_first_name
            - member_last_name
            - member_sex
            - member_birth_dt
            - member_ssn
            - group_id
            - subscriber_id
            - source_code
            - member_source
derived_columns:
    source: "!member_source"
    load_datetime: "cdc_timestamp"
    effective_from: "start_date"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    hashed_columns=metadata_dict['hashed_columns'],
    derived_columns=metadata_dict['derived_columns']
) }}
