{% set yaml_metadata %}
source_model: "stg_subscriber_employment_gemstone_facets_rename"

derived_columns:
  source: "'{{ var('gemstone_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"

hashed_columns:
  subscriber_hk:
    - source
    - subscriber_bk
  subscriber_employment_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - subscriber_bk
      - employment_eff_dt
      - employment_term_dt
      - employment_term_reason_cd
      - group_bk
      - occupation_cd
      - department_cd
      - location_cd
      - employment_type_cd
      - non_discrimination_type_cd
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
