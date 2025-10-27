{{
    config(
        materialized='table',
        tags=['dimensional', 'member_person', 'type2_scd']
    )
}}

{#
    Dimensional Model: Member Person

    Purpose: Denormalized member person dimension for reporting and analytics

    Type: Type 2 Slowly Changing Dimension
    - Tracks historical changes to member person attributes
    - Uses effective_from/effective_to for temporal queries

    Grain: One row per member per effective period

    Source: bv_s_member_person (business vault computed satellite)

    Legacy Equivalent: v_FacetsMemberUMI_current
#}

with member_person_history as (
    select
        -- Natural Keys
        member_bk,
        person_bk,

        -- Business Keys
        constituent_id,
        subscriber_id,
        group_id,

        -- Member Demographics
        member_suffix,
        member_first_name,
        member_last_name,
        member_sex,
        member_birth_dt,
        member_ssn,

        -- Source Information
        source_code,
        member_source,

        -- Related Entity Keys
        group_bk,
        subscriber_bk,

        -- Temporal Attributes
        effective_from,

        -- Calculate effective_to using LEAD window function
        lead(effective_from) over (
            partition by member_bk
            order by effective_from
        ) as effective_to,

        -- Metadata
        load_datetime,
        record_source

    from {{ ref('bv_s_member_person') }}
),

member_person_current as (
    select
        *,
        -- Add current record flag
        case
            when effective_to is null then true
            else false
        end as is_current

    from member_person_history
)

select
    -- Generate surrogate key for dimension
    {{ dbt_utils.generate_surrogate_key([
        'member_bk',
        'effective_from'
    ]) }} as member_person_sk,

    -- Natural Keys
    member_bk,
    person_bk,

    -- Business Keys
    constituent_id,
    subscriber_id,
    group_id,

    -- Member Demographics
    coalesce(member_suffix, '') as member_suffix,
    coalesce(member_first_name, 'Unknown') as member_first_name,
    coalesce(member_last_name, 'Unknown') as member_last_name,
    coalesce(member_sex, 'U') as member_sex,
    member_birth_dt,
    member_ssn,

    -- Derived Attributes
    case
        when member_birth_dt is not null
        then datediff(year, member_birth_dt, current_date)
        else null
    end as member_age_years,

    concat_ws(' ',
        member_first_name,
        member_last_name
    ) as member_full_name,

    -- Source Information
    source_code,
    member_source as source,

    -- Related Entity Keys
    group_bk,
    subscriber_bk,

    -- Temporal Attributes
    effective_from,
    coalesce(effective_to, cast('9999-12-31' as date)) as effective_to,
    is_current,

    -- Metadata
    load_datetime,
    record_source

from member_person_current

-- Optional: Add WHERE clause to filter for current records only
-- where is_current = true
