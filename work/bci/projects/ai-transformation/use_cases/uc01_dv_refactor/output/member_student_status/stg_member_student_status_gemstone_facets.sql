{% set yaml_metadata %}
source_model: "stg_member_student_status_gemstone_facets_rename"

derived_columns:
  source: "'{{ var('gemstone_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"

hashed_columns:
  member_hk:
    - source
    - member_bk
  member_student_status_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - member_bk
      - student_eff_dt
      - student_term_dt
      - termination_reason_cd
      - group_bk
      - school_name
      - student_type
      - last_verification_dt
      - last_verification_name
      - verification_method_cd
      - lock_token_nbr
      - attachment_source_id
      - edp_record_status
      - edp_record_source
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    null_columns=none,
    hashed_columns=metadata_dict['hashed_columns'],
    ranked_columns=none
) }}
