{{
    config(
        materialized='ephemeral',
        tags=['cob', 'member', 'business_vault', 'staging']
    )
}}

/*
    Staging model for Member COB Profile Business Vault

    Purpose: Generate hash keys and hashdiff for loading into business vault
    computed effectivity satellite.

    This model prepares the prepared COB profile data for vault loading by:
    - Generating member_hk (parent hash key)
    - Generating hashdiff for change detection
    - Adding vault metadata columns
*/

{%- set yaml_metadata -%}
source_model: prep_member_cob_profile
derived_columns:
  member_hk:
    - source
    - member_bk
  hashdiff:
    MEDICAL_COVERAGE: medical_coverage
    DENTAL_COVERAGE: dental_coverage
    DRUG_COVERAGE: drug_coverage
    HAS_MEDICAL_COB: has_medical_cob
    MEDICAL_COB_ORDER: medical_cob_order
    COVERAGE_ID_MEDICAL: coverage_id_medical
    MEDICAL_2BLUES: medical_2blues
    HAS_DENTAL_COB: has_dental_cob
    DENTAL_COB_ORDER: dental_cob_order
    COVERAGE_ID_DENTAL: coverage_id_dental
    DENTAL_2BLUES: dental_2blues
    HAS_DRUG_COB: has_drug_cob
    DRUG_COB_ORDER: drug_cob_order
    DRUG_2BLUES: drug_2blues
    GROUP_ID: group_id
    SUBSCRIBER_ID: subscriber_id
    MEMBER_SUFFIX: member_suffix
    GROUP_BK: group_bk
    SUBSCRIBER_BK: subscriber_bk
    MEMBER_FIRST_NAME: member_first_name
hashed_columns:
  - member_hk
  - hashdiff
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                      source_model=metadata_dict['source_model'],
                      derived_columns=metadata_dict['derived_columns'],
                      hashed_columns=metadata_dict['hashed_columns']) }}
