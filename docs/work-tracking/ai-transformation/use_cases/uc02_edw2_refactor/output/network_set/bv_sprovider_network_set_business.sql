{% set yaml_metadata %}
source_model: "stg_provider_network_set_business"
src_pk: "hk_provider_network_set_business"
src_dfk: "hk_network_set"
src_sfk: "hk_provider"
src_hashdiff:
  source_column: "provider_network_set_business_hashdiff"
  alias: "hashdiff"
src_eff: "src_eff"
src_start_date: "dss_start_date"
src_end_date: "dss_end_date"
src_ldts: "dss_create_time"
src_source: "source"
src_extra_columns:
  - tenant_id
  - source
  - provider_id
  - network_id
  - network_description
  - network_prefix
  - network_prefix_description
  - network_type
  - network_type_description
  - network_effective_date
  - network_term_date
  - network_participation_status
  - dss_record_source
  - is_current
  - provider_network_set_business_hashdiff
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(src_pk=metadata_dict["src_pk"],
                       src_dfk=metadata_dict["src_dfk"],
                       src_sfk=metadata_dict["src_sfk"],
                       src_start_date=metadata_dict["src_start_date"],
                       src_end_date=metadata_dict["src_end_date"],
                       src_extra_columns=metadata_dict["src_extra_columns"],
                       src_eff=metadata_dict["src_eff"],
                       src_ldts=metadata_dict["src_ldts"],
                       src_source=metadata_dict["src_source"],
                       source_model=metadata_dict["source_model"]) }}