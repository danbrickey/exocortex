{% set yaml_metadata %}
source_model: "stg_member_exchange_legacy_facets"

src_pk: "member_exchange_lk"

src_dfk: "member_hk"

src_sfk: "product_category_hk"

src_eff: "exchange_effective_dt"

src_start_date: "exchange_effective_dt"

src_end_date: "exchange_termination_dt"

src_hashdiff:
  source_column: "member_exchange_hashdiff"
  alias: "hashdiff"

src_extra_columns:
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
  - member_hk
  - product_category_hk
  - member_exchange_lk

src_ldts: "load_datetime"

src_source: "source"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict["src_pk"],
    src_dfk=metadata_dict["src_dfk"],
    src_sfk=metadata_dict["src_sfk"],
    src_eff=metadata_dict["src_eff"],
    src_start_date=metadata_dict["src_start_date"],
    src_end_date=metadata_dict["src_end_date"],
    src_hashdiff=metadata_dict["src_hashdiff"],
    src_extra_columns=metadata_dict["src_extra_columns"],
    src_ldts=metadata_dict["src_ldts"],
    src_source=metadata_dict["src_source"],
    source_model=metadata_dict["source_model"]
) }}
