{%- set yaml_metadata -%}
source_model: "prep_network_set"
derived_columns:
  dss_create_time: "dss_create_time"
  dss_update_time: "dss_update_time"
  tenant_id: to_varchar(trunc(tenant_id))
  network_set_pk: "{{ dbt_utils.generate_surrogate_key(['network_set', 'network_id']) }}"
hashed_columns:
  hk_network_set: ["network_set_pk"]
  network_set_hashdiff:
    is_hashdiff: true
    columns:
        - "tenant_id"
        - "source"
        - "network_code"
        - "network_name"
        - "network_id"
        - "network_set"
        - "mdm_captured"
        - "dss_record_source"

{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }} 