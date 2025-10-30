{% set yaml_metadata %}
source_model: "stg_member_exchange_gemstone_facets_rename"

derived_columns:
  source: "'{{ var('gemstone_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"

hashed_columns:
  member_hk:
    - source
    - member_bk
  product_category_hk:
    - source
    - product_category_bk
  member_exchange_lk:
    - member_hk
    - product_category_hk
  member_exchange_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - edp_end_dt
      - member_bk
      - product_category_bk
      - exchange_effective_dt
      - exchange_termination_dt
      - group_bk
      - exchange_channel_cd
      - exchange_id
      - enrollment_method_cd
      - aptc_indicator
      - lock_token_nbr
      - attachment_source_id
      - system_last_update_dtm
      - system_update_user_id
      - system_update_db_user_id
      - qhp_identifier
      - exchange_assigned_member_id
      - exchange_policy_id
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
