{% set yaml_metadata %}
source_model: "stg_subscriber_warning_msg_gemstone_facets"

src_pk: "subscriber_hk"

src_dfk: null

src_sfk: null

src_eff: "warning_msg_eff_dt"

src_start_date: "warning_msg_eff_dt"

src_end_date: "warning_msg_term_dt"

src_hashdiff:
  source_column: "subscriber_warning_msg_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - subscriber_bk
  - warning_msg_eff_dt
  - message_id
  - warning_msg_term_dt
  - termination_reason_cd
  - group_bk
  - lock_token_nbr
  - attachment_source_id
  - edp_record_status
  - edp_record_source
  - subscriber_hk

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
