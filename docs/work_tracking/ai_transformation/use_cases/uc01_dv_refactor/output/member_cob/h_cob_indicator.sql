{%- set yaml_metadata -%}
source_model:
    - stg_member_cob_gemstone_facets
    - stg_member_cob_legacy_facets
src_pk:
    - cob_indicator_hk
src_nk:
    - source
    - cob_ins_type_bk
    - cob_ins_order_bk
    - cob_supp_drug_type_bk
src_ldts:
    - load_datetime
src_source:
    - source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict["src_pk"],
                   src_nk=metadata_dict["src_nk"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"]) }}