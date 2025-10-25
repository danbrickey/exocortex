{{
    config(
        materialized='incremental',
        unique_key='class_type_hk',
        schema='business_vault'
    )
}}

-- Business Vault Hub: Class Type
-- Represents the business entity for Group + Class combinations
-- Business Key: Composite of group_id and class_bk

with source_group as (
    select
        group_id,
        group_bk,
        source,
        load_datetime
    from {{ ref('current_group') }}
    {% if is_incremental() %}
    where load_datetime >= dateadd(hour, {{ var('load_offset', -1) }},
                                    (select max(load_datetime) from {{ this }}))
    {% endif %}
),

source_class as (
    select
        class_bk,
        group_bk,
        source,
        load_datetime
    from {{ ref('current_class_group') }}
    {% if is_incremental() %}
    where load_datetime >= dateadd(hour, {{ var('load_offset', -1) }},
                                    (select max(load_datetime) from {{ this }}))
    {% endif %}
),

-- Join group and class to create composite business key
composite_keys as (
    select
        sg.group_id,
        sc.class_bk,
        rtrim(sg.group_id) || ltrim(sc.class_bk) as class_type_bk,
        sg.source as record_source,
        greatest(sg.load_datetime, sc.load_datetime) as load_datetime
    from source_group sg
    inner join source_class sc
        on sg.group_bk = sc.group_bk
        and sg.source = sc.source
),

-- Generate hash key for the business key
hashed as (
    select
        sha1_binary(
            concat(
                coalesce(upper(trim(class_type_bk)), 'null'), '||',
                coalesce(upper(trim(record_source)), 'null')
            )
        ) as class_type_hk,
        class_type_bk,
        record_source,
        load_datetime
    from composite_keys
),

final as (
    select
        class_type_hk,
        class_type_bk,
        record_source,
        load_datetime
    from hashed
    {% if is_incremental() %}
    where class_type_hk not in (select class_type_hk from {{ this }})
    {% endif %}
)

select * from final
