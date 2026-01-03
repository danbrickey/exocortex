{% set yaml_metadata %}
source_model: "stg_subscriber_rating_gemstone_facets"

src_pk: "subscriber_hk"

src_dfk: null

src_sfk: null

src_eff: "rating_eff_dt"

src_start_date: "rating_eff_dt"

src_end_date: "rating_term_dt"

src_hashdiff:
  source_column: "subscriber_rating_hashdiff"
  alias: "hashdiff"

src_extra_columns:
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
