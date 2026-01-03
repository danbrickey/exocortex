{{
    config(
        materialized='table',
        schema='dimensional'
    )
}}

-- Dimension: Class Type
-- Type 2 SCD dimension for Group + Class combinations
-- Consumes business vault computed satellite

with source_hub as (
    select
        class_type_hk,
        class_type_bk,
        load_datetime
    from {{ ref('bv_h_class_type') }}
),

source_satellite as (
    select
        class_type_hk,
        load_datetime,
        load_end_datetime,
        hashdiff,
        class_type_bk,
        group_id,
        class_bk,
        class_description,
        class_type_description,
        dual_eligible,
        on_exchange,
        effective_from_date,
        effective_to_date,
        source,
        source_description
    from {{ ref('bv_s_class_type_business') }}
),

-- Get current records only (load_end_datetime is null)
current_records as (
    select
        class_type_hk,
        load_datetime,
        hashdiff,
        class_type_bk,
        group_id,
        class_bk,
        class_description,
        class_type_description,
        dual_eligible,
        on_exchange,
        effective_from_date,
        effective_to_date,
        source,
        source_description
    from source_satellite
    where load_end_datetime is null
),

-- Join hub and satellite
joined as (
    select
        h.class_type_hk,
        h.class_type_bk,
        s.group_id,
        s.class_bk,
        s.class_description,
        s.class_type_description,
        s.dual_eligible,
        s.on_exchange,
        s.effective_from_date,
        s.effective_to_date,
        s.source,
        s.source_description,
        s.hashdiff,
        s.load_datetime
    from source_hub h
    inner join current_records s
        on h.class_type_hk = s.class_type_hk
),

-- Detect changes and assign version numbers
versioned as (
    select
        class_type_hk,
        class_type_bk,
        group_id,
        class_bk,
        class_description,
        class_type_description,
        dual_eligible,
        on_exchange,
        effective_from_date,
        effective_to_date,
        source,
        source_description,
        hashdiff,
        load_datetime,
        row_number() over (
            partition by class_type_bk, source
            order by load_datetime
        ) as version_number,
        lag(hashdiff) over (
            partition by class_type_bk, source
            order by load_datetime
        ) as prev_hashdiff
    from joined
),

-- Build Type 2 SCD structure
scd_type2 as (
    select
        {{ dbt_utils.generate_surrogate_key(['class_type_bk', 'source', 'version_number']) }} as class_type_key,
        class_type_bk as class_type_id,
        class_type_description,
        class_bk as class_id,
        class_description,
        dual_eligible,
        on_exchange,
        source as source_id,
        source_description,
        hashdiff as type1_hash,
        load_datetime as create_date,
        load_datetime as update_date,

        -- Type 2 SCD fields
        load_datetime::date as dss_start_date,
        lead(load_datetime::date) over (
            partition by class_type_bk, source
            order by load_datetime
        ) as next_start_date,
        case
            when lead(load_datetime) over (
                partition by class_type_bk, source
                order by load_datetime
            ) is null then '2999-12-31'::date
            else dateadd(day, -1, lead(load_datetime::date) over (
                partition by class_type_bk, source
                order by load_datetime
            ))
        end as dss_end_date,
        case
            when lead(load_datetime) over (
                partition by class_type_bk, source
                order by load_datetime
            ) is null then 'Y'
            else 'N'
        end as dss_current_flag,
        version_number as dss_version,
        current_timestamp() as dss_create_time,
        current_timestamp() as dss_update_time

    from versioned
),

-- Add unknown record (key = 0)
unknown_record as (
    select
        0 as class_type_key,
        null::varchar as class_type_id,
        'Unknown' as class_type_description,
        'Unknown' as class_id,
        'Unknown' as class_description,
        'Unknown' as dual_eligible,
        'Unknown' as on_exchange,
        'Unknown' as source_id,
        'Unknown' as source_description,
        null::binary as type1_hash,
        null::timestamp_ntz as create_date,
        null::timestamp_ntz as update_date,
        '1900-01-01'::date as dss_start_date,
        '2999-12-31'::date as dss_end_date,
        'Y' as dss_current_flag,
        1 as dss_version,
        current_timestamp() as dss_create_time,
        current_timestamp() as dss_update_time
),

final as (
    select * from unknown_record
    union all
    select
        class_type_key,
        class_type_id,
        class_type_description,
        class_id,
        class_description,
        dual_eligible,
        on_exchange,
        source_id,
        source_description,
        type1_hash,
        create_date,
        update_date,
        dss_start_date,
        dss_end_date,
        dss_current_flag,
        dss_version,
        dss_create_time,
        dss_update_time
    from scd_type2
)

select * from final
