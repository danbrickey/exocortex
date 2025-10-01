{% set yaml_metadata %}
source_model: "stg_member_cob_gemstone_facets"

src_pk: "member_cob_hk"

src_dfk: "member_hk"

src_sfk: "cob_indicator_hk"

src_eff: "cob_eff_dt"

src_start_date: "cob_eff_dt"

src_end_date: "cob_term_dt"

src_hashdiff:
  source_column: "member_cob_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - member_bk
  - cob_ins_type_bk
  - cob_ins_order_bk
  - cob_supp_drug_type_bk
  - cob_eff_dt
  - cob_term_dt
  - cob_term_reason
  - group_bk
  - cob_carrier_id
  - cob_policy_id
  - cob_msp_type
  - cob_rx_coverage_type
  - cob_rx_bin
  - cob_rx_pcn
  - cob_rx_group
  - cob_rx_id
  - cob_last_ver_dt
  - cob_last_ver_name
  - cob_ver_method
  - cob_loi_start_dt
  - cob_prim_last_nm
  - cob_prim_first_nm
  - cob_prim_id
  - lock_token
  - attachment_source_id
  - last_update_dtm
  - last_update_user_id
  - last_update_db_user_id
  - edp_record_status
  - edp_record_source
  - member_hk
  - cob_indicator_hk
  - member_cob_ik

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

    src_extra_columns=metadata_dict["src_extra_columns"],
    src_ldts=metadata_dict["src_ldts"],
    src_source=metadata_dict["src_source"],
    source_model=metadata_dict["source_model"]
) }}
