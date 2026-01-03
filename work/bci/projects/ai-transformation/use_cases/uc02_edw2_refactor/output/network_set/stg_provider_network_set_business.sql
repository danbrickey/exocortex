{%- set yaml_metadata -%}
source_model: "prep_provider_network_set_business"
derived_columns:
  dss_create_time: "dss_create_time"
  dss_update_time: "dss_update_time"
  src_eff: "dss_start_date"
  tenant_id: to_varchar(trunc(tenant_id))
  provider_network_set_business_pk: "{{ dbt_utils.generate_surrogate_key(['source', 'provider_id', 'network_id', 'network_prefix', 'network_effective_date']) }}"
  hk_provider: provider_hk
hashed_columns:
  hk_provider_network_set_business: ["provider_network_set_business_pk"]
  provider_network_set_business_hashdiff:
    is_hashdiff: true
    columns:
        - "tenant_id"
        - "source"
        - "provider_id"
        - "network_id"
        - "network_description"
        - "network_prefix"
        - "network_prefix_description"
        - "network_type"
        - "network_type_description"
        - "network_effective_date"
        - "network_term_date"
        - "network_participation_status"
        - "dss_record_source"
        - "dss_start_date"
        - "dss_end_date"
        - "is_current"
        - "hk_provider"
        - "hk_network_set"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict['source_model'],
                     derived_columns=metadata_dict['derived_columns'],
                     null_columns=none,
                     hashed_columns=metadata_dict['hashed_columns'],
                     ranked_columns=none) }} 