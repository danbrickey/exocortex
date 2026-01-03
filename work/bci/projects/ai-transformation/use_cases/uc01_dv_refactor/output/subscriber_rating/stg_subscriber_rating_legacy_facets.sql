{% set yaml_metadata %}
source_model: "stg_subscriber_rating_legacy_facets_rename"

derived_columns:
  source: "'{{ var('legacy_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"

hashed_columns:
  subscriber_hk:
    - source
    - subscriber_bk
  subscriber_rating_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - subscriber_bk
      - rating_eff_dt
      - rating_term_dt
      - group_bk
      - subscriber_billing_ind
      - smoker_ind
      - rating_state_cd
      - rating_county_cd
      - rating_area_cd
      - rating_sic_cd
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
