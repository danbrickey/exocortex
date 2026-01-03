{{
    config(
        materialized='incremental',
        unique_key=['class_type_hk', 'load_datetime'],
        schema='business_vault'
    )
}}

-- Business Vault Computed Satellite: Class Type Business Rules
-- Applies business rules for DualEligible, OnExchange flags, and description lookups
-- Consolidates logic from legacy ClassType_NonDV_01, ClassType_NonDV_02, and dimClassType_NonDV

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
        class_description,
        group_bk,
        source,
        load_datetime
    from {{ ref('current_class_group') }}
    {% if is_incremental() %}
    where load_datetime >= dateadd(hour, {{ var('load_offset', -1) }},
                                    (select max(load_datetime) from {{ this }}))
    {% endif %}
),

source_system_lookup as (
    select
        source,
        source_description
    from {{ ref('r_source_system') }}
),

-- Get class type assignment with max effective_to date for each group/class/source combination
class_type_assignment as (
    select
        group_id,
        class_bk,
        source,
        effective_from,
        effective_to,
        description_key
    from {{ ref('r_class_type_assignment') }}
    qualify row_number() over (
        partition by group_id, class_bk, source
        order by effective_to desc
    ) = 1
),

-- Get description from assignment
class_type_description as (
    select
        cta.group_id,
        cta.class_bk,
        cta.source,
        cta.effective_from,
        cta.effective_to,
        cta.description_key,
        cta.description
    from {{ ref('r_class_type_assignment') }} cta
),

-- Join all sources together
integrated as (
    select
        sg.group_id,
        sc.class_bk,
        sc.class_description,
        rtrim(sg.group_id) || ltrim(sc.class_bk) as class_type_bk,
        sg.source,
        ssl.source_description,
        greatest(sg.load_datetime, sc.load_datetime) as load_datetime
    from source_group sg
    inner join source_class sc
        on sg.group_bk = sc.group_bk
        and sg.source = sc.source
    left join source_system_lookup ssl
        on sg.source = ssl.source
),

-- Apply business rules for computed fields
business_rules_applied as (
    select
        i.class_type_bk,
        i.group_id,
        i.class_bk,
        i.class_description,
        i.source,
        i.source_description,

        -- Business Rule: DualEligible flag
        -- "Yes" if class_bk starts with 'M', else "No"
        case
            when i.class_bk is null then 'No'
            when i.class_bk = '' then 'No'
            when substring(i.class_bk, 1, 1) = 'M' then 'Yes'
            else 'No'
        end as dual_eligible,

        -- Business Rule: OnExchange flag
        -- Complex logic based on group_id and class_bk patterns
        case
            when i.class_bk is null then 'No'
            when i.class_bk = '' then 'No'
            when i.group_id = '10030052' then 'No'
            when substring(i.class_bk, 1, 1) = 'X' then 'Yes'
            when substring(i.class_bk, 4, 1) = 'X' then 'Yes'
            else 'No'
        end as on_exchange,

        -- Description lookup with null handling
        coalesce(ctd.description, '') as class_type_description,

        -- Effective dates with default values
        coalesce(ctd.effective_from, '2002-01-01'::date) as effective_from_date,
        coalesce(ctd.effective_to, '2199-12-31'::date) as effective_to_date,

        i.load_datetime

    from integrated i
    left join class_type_description ctd
        on i.group_id = ctd.group_id
        and i.class_bk = ctd.class_bk
        and i.source = ctd.source
),

-- Generate hash key and hashdiff for change detection
hashed as (
    select
        sha1_binary(
            concat(
                coalesce(upper(trim(class_type_bk)), 'null'), '||',
                coalesce(upper(trim(source)), 'null')
            )
        ) as class_type_hk,

        sha1_binary(
            concat(
                coalesce(trim(class_type_description), 'null'), '||',
                coalesce(trim(class_bk), 'null'), '||',
                coalesce(trim(class_description), 'null'), '||',
                coalesce(trim(dual_eligible), 'null'), '||',
                coalesce(trim(on_exchange), 'null'), '||',
                coalesce(trim(source_description), 'null'), '||',
                coalesce(to_char(effective_from_date, 'YYYY-MM-DD'), 'null'), '||',
                coalesce(to_char(effective_to_date, 'YYYY-MM-DD'), 'null')
            )
        ) as hashdiff,

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
        load_datetime

    from business_rules_applied
),

final as (
    select
        class_type_hk,
        load_datetime,
        null::timestamp_ntz as load_end_datetime,
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
    from hashed
    {% if is_incremental() %}
    where (class_type_hk, hashdiff) not in (
        select class_type_hk, hashdiff
        from {{ this }}
        where load_end_datetime is null
    )
    {% endif %}
)

select * from final
