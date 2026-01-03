{%- set yaml_metadata -%}
source_model: "stg_network_set"
src_pk: "network_set_pk"
src_hashdiff: 
  source_column: "network_set_hashdiff"
  alias: "hashdiff"
src_payload:
    - "tenant_id"
    - "source"
    - "network_code"
    - "network_name"
    - "network_id"
    - "network_set"
    - "mdm_captured"
    - "dss_record_source"
    - "dss_create_time"
    - "dss_update_time"
    - "hk_network_set"
src_ldts: "dss_create_time"
src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"]) }}