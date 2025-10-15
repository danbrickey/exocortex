{% set yaml_metadata %}
source_model: "stg_member_cob_legacy_facets_rename"

derived_columns:
  source: "'{{ var('legacy_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"
  member_cob_ik: "{{ dbt_utils.generate_surrogate_key(['tenant_id', 'source', 'member_bk', 'cob_ins_type_bk', 'cob_ins_order_bk', 'cob_supp_drug_type_bk', 'cob_eff_dt']) }}"

hashed_columns:
  member_hk: ["source", "member_bk"]
  cob_indicator_hk: ["source", "cob_ins_type_bk", "cob_ins_order_bk", "cob_supp_drug_type_bk"]
  member_cob_hk: ["source", "member_bk", "cob_ins_type_bk", "cob_ins_order_bk", "cob_supp_drug_type_bk"]
  entity_address_group_hk : ["source", "group_bk", "cob_carrier_id"]
  group_hk : ["source", "group_bk"]
  entity_address_hk : ["source", "cob_carrier_id"]
  member_cob_hashdiff:
    is_hashdiff: true
    columns:
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