{{
    config(
        materialized='incremental',
        unique_key=['benefit_summary_product_prefix_lk', 'load_datetime'],
        tags=['raw_vault', 'satellite', 'gemstone_facets']
    )
}}

{%- set yaml_metadata -%}
source_model: stg_benefit_summary_gemstone_facets
src_pk: benefit_summary_product_prefix_lk
src_hashdiff:
  source_column: benefit_summary_hashdiff
  alias: hashdiff
src_payload:
  - benefit_summary_desc
  - lock_token
  - attachment_source_id
  - last_update_dtm
  - last_update_user_id
  - last_update_db_user_id
src_eff: load_datetime
src_ldts: load_datetime
src_source: record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

with source as (

    select
        benefit_summary_product_prefix_lk,
        benefit_summary_hashdiff,
        benefit_summary_desc,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        load_datetime,
        record_source
    from {{ ref('stg_benefit_summary_gemstone_facets') }}

),

{% if is_incremental() %}

latest_records as (

    select
        benefit_summary_product_prefix_lk,
        hashdiff,
        load_datetime as load_end_datetime
    from {{ this }}
    qualify row_number() over (
        partition by benefit_summary_product_prefix_lk
        order by load_datetime desc
    ) = 1

),

filtered_source as (

    select
        s.benefit_summary_product_prefix_lk,
        s.benefit_summary_hashdiff as hashdiff,
        s.benefit_summary_desc,
        s.lock_token,
        s.attachment_source_id,
        s.last_update_dtm,
        s.last_update_user_id,
        s.last_update_db_user_id,
        s.load_datetime,
        null::timestamp_ntz as load_end_datetime,
        s.record_source
    from source as s
    left join latest_records as lr
        on s.benefit_summary_product_prefix_lk = lr.benefit_summary_product_prefix_lk
    where (
        lr.benefit_summary_product_prefix_lk is null
        or s.benefit_summary_hashdiff != lr.hashdiff
    )
    and s.load_datetime > (select max(load_datetime) from {{ this }})

),

{% else %}

filtered_source as (

    select
        benefit_summary_product_prefix_lk,
        benefit_summary_hashdiff as hashdiff,
        benefit_summary_desc,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        load_datetime,
        null::timestamp_ntz as load_end_datetime,
        record_source
    from source

),

{% endif %}

records_to_insert as (

    select
        benefit_summary_product_prefix_lk,
        hashdiff,
        benefit_summary_desc,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        load_datetime,
        load_end_datetime,
        record_source
    from filtered_source

)

select * from records_to_insert
