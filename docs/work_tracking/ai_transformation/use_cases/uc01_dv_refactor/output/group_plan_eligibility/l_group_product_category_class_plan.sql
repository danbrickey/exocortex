-- l_group_product_category_class_plan.sql
-- Link table connecting group, product category, class, and plan

{%- set source_models = [
    "stg_group_plan_eligibility_legacy_facets",
    "stg_group_plan_eligibility_gemstone_facets"
] -%}

{%- set yaml_metadata -%}
source_model:
  - "stg_group_plan_eligibility_legacy_facets"
  - "stg_group_plan_eligibility_gemstone_facets"
src_pk: "group_product_category_class_plan_hk"
src_fk:
  - "group_hk"
  - "product_category_hk"
  - "class_hk"
  - "plan_hk"
src_ldts: "load_datetime"
src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict['src_pk'],
                    src_fk=metadata_dict['src_fk'],
                    src_ldts=metadata_dict['src_ldts'],
                    src_source=metadata_dict['src_source'],
                    source_model=metadata_dict['source_model']) }}
