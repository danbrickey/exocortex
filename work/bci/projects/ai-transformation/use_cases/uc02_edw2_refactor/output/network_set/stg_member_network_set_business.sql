{%- set yaml_metadata -%}
source_model: "prep_member_network_set_business"
derived_columns:
  dss_create_time: "dss_create_time"
  dss_update_time: "dss_update_time"
  src_eff: "dss_start_date"
  tenant_id: to_varchar(trunc(tenant_id))
  member_network_set_pk: "{{ dbt_utils.generate_surrogate_key(['source', 'member_bk', 'dss_start_date', 'network_set_prefix', 'network_id']) }}"
hashed_columns:
  hk_member_network_set: ["member_network_set_pk"]
  member_network_set_hashdiff:
    is_hashdiff: true
    columns:
        - "tenant_id"
        - "source"
        - "member_bk"
        - "group_id"
        - "subscriber_id"
        - "member_suffix"
        - "network_set_prefix"
        - "network_id"
        - "dss_record_source"
        - "dss_start_date"
        - "dss_end_date"
        - "is_current"
        - "hk_member"
        - "hk_network_set"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }} 