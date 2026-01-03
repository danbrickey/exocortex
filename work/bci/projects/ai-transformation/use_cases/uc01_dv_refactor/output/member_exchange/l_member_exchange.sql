{{
    config(
        materialized='incremental',
        unique_key='member_exchange_lk',
        tags=['raw_vault', 'link', 'member_exchange']
    )
}}

/*
    Link: l_member_exchange
    Relationship: Member to Product Category enrollment channel association
    Business Keys: meme_ck (member) + cspd_cat (product category)

    Parent Hubs:
    - h_member
    - h_product_category

    Source Systems:
    - legacy_facets
    - gemstone_facets
*/

{%- set yaml_metadata -%}
source_model:
  stg_member_exchange_legacy_facets:
    src_pk: "member_exchange_lk"
    src_fk:
      - "member_hk"
      - "product_category_hk"
    src_ldts: "load_datetime"
    src_source: "source"
  stg_member_exchange_gemstone_facets:
    src_pk: "member_exchange_lk"
    src_fk:
      - "member_hk"
      - "product_category_hk"
    src_ldts: "load_datetime"
    src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(
    src_pk=metadata_dict["source_model"]["stg_member_exchange_legacy_facets"]["src_pk"],
    src_fk=metadata_dict["source_model"]["stg_member_exchange_legacy_facets"]["src_fk"],
    src_ldts=metadata_dict["source_model"]["stg_member_exchange_legacy_facets"]["src_ldts"],
    src_source=metadata_dict["source_model"]["stg_member_exchange_legacy_facets"]["src_source"],
    source_model=metadata_dict["source_model"]
) }}
