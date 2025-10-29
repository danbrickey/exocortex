{% set yaml_metadata %}
source_model: "stg_member_rating_legacy_facets"

src_pk: "member_rating_lk"

src_dfk: "member_hk"

src_sfk: null

src_eff: "rating_eff_dt"

src_start_date: "rating_eff_dt"

src_end_date: "rating_term_dt"

src_hashdiff:
  source_column: "member_rating_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - member_bk
  - rating_eff_dt
  - rating_term_dt
  - group_bk
  - smoker_ind
  - underwriting_class_1_cd
  - underwriting_class_2_cd
  - underwriting_class_3_cd
  - lock_token_nbr
  - attachment_source_id
  - edp_record_status
  - edp_record_source
  - member_hk
  - member_rating_ik

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
