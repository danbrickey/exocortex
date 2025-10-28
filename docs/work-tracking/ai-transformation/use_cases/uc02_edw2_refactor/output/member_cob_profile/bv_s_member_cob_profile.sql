{{
    config(
        materialized='incremental',
        unique_key='member_cob_profile_hk',
        tags=['business_vault', 'satellite', 'cob', 'member']
    )
}}

/*
    Business Vault Computed Effectivity Satellite: Member COB Profile

    Purpose: Stores computed Coordination of Benefits (COB) profile information
    for members across discrete date ranges.

    Parent Hub: h_member
    Source: Computed from member eligibility and COB data

    Business Logic:
    - Combines eligibility and COB data to create discrete date ranges
    - Determines coverage status and COB order for Medical, Dental, Drug
    - Identifies "Two Blues" scenarios
    - Handles Medicare Part D special rules

    Legacy Source: HDSVault.biz.r_COBProfileLookup
    Load Pattern: Full refresh (computed from current state)
*/

{%- set yaml_metadata -%}
source_model: stg_member_cob_profile
src_pk: member_hk
src_hashdiff:
  source_column: hashdiff
  alias: hashdiff
src_payload:
  - source
  - member_bk
  - start_date
  - end_date
  - group_id
  - subscriber_id
  - member_suffix
  - group_bk
  - subscriber_bk
  - member_first_name
  - edp_record_source
  - medical_coverage
  - dental_coverage
  - drug_coverage
  - has_medical_cob
  - medical_cob_order
  - coverage_id_medical
  - medical_2blues
  - has_dental_cob
  - dental_cob_order
  - coverage_id_dental
  - dental_2blues
  - has_drug_cob
  - drug_cob_order
  - drug_2blues
  - create_date
src_eff: start_date
src_ldts: create_date
src_source: edp_record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(src_pk=metadata_dict['src_pk'],
                        src_dfk=none,
                        src_sfk=none,
                        src_start_date=metadata_dict['src_eff'],
                        src_end_date='end_date',
                        src_eff=metadata_dict['src_eff'],
                        src_ldts=metadata_dict['src_ldts'],
                        src_source=metadata_dict['src_source'],
                        source_model=metadata_dict['source_model'],
                        src_hashdiff=metadata_dict['src_hashdiff'],
                        src_payload=metadata_dict['src_payload']) }}
