{{
    config(
        materialized='incremental',
        unique_key='benefit_summary_product_prefix_lk',
        tags=['raw_vault', 'link']
    )
}}

{%- set source_models = [
    ref('stg_benefit_summary_legacy_facets'),
    ref('stg_benefit_summary_gemstone_facets')
] -%}

{%- set yaml_metadata -%}
source_model:
  stg_benefit_summary_legacy_facets:
    src_pk: benefit_summary_product_prefix_lk
    src_fk:
      - benefit_summary_type_hk
      - product_prefix_hk
    src_ldts: load_datetime
    src_source: record_source
  stg_benefit_summary_gemstone_facets:
    src_pk: benefit_summary_product_prefix_lk
    src_fk:
      - benefit_summary_type_hk
      - product_prefix_hk
    src_ldts: load_datetime
    src_source: record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

with

{% for source_model in source_models %}
staging_{{ loop.index }} as (
    select
        benefit_summary_product_prefix_lk,
        benefit_summary_type_hk,
        product_prefix_hk,
        load_datetime,
        record_source
    from {{ source_model }}
    where benefit_summary_type_hk is not null
      and product_prefix_hk is not null
),
{% endfor %}

staging_union as (
    {% for source_model in source_models %}
    select * from staging_{{ loop.index }}
    {% if not loop.last %}union all{% endif %}
    {% endfor %}
),

records_to_insert as (
    select distinct
        benefit_summary_product_prefix_lk,
        benefit_summary_type_hk,
        product_prefix_hk,
        load_datetime,
        record_source
    from staging_union
    {% if is_incremental() %}
    where benefit_summary_product_prefix_lk not in (
        select benefit_summary_product_prefix_lk from {{ this }}
    )
    {% endif %}
)

select * from records_to_insert
