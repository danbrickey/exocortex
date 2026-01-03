{{
    config(
        materialized='incremental',
        unique_key=['source', 'member_bk', 'current_eval_date'],
        cluster_by=['source', 'member_bk'],
        incremental_strategy='merge',
        on_schema_change='fail',
        tags=['pcp_attribution', 'member', 'computed_satellite']
    )
}}

/*
Purpose: Identifies members eligible for PCP attribution during the evaluation period
Grain: One row per member per evaluation date
Dependencies: current_member, current_member_eligibility, current_subscriber, current_subscriber_address, current_group, ces_member_cob_profile, v_member_person_lenient, seed references
Replaces: PCPAttribution_02_NonDV_03_EligibleMembers, PCPAttribution_02_NonDV_04_MemberInfo, PCPAttribution_02_NonDV_04a_MemberAddressHistory, PCPAttribution_02_NonDV_05_MemberSet
*/

with

-- Import CTEs
current_member as (
    select * from {{ ref('current_member') }}
),

current_member_eligibility as (
    select * from {{ ref('current_member_eligibility') }}
),

current_subscriber as (
    select * from {{ ref('current_subscriber') }}
),

current_subscriber_address as (
    select * from {{ ref('current_subscriber_address') }}
),

current_group as (
    select * from {{ ref('current_group') }}
),

member_cob_profile as (
    select * from {{ ref('ces_member_cob_profile') }}
),

member_person_xref as (
    select * from {{ ref('v_member_person_lenient') }}
),

zip_code_ref as (
    select * from {{ ref('seed_zip_code_melissa') }}
),

idaho_county_ref as (
    select * from {{ ref('seed_pcp_attribution_idaho_county') }}
),

evaluation_dates as (
    select * from {{ ref('seed_pcp_attribution_evaluation_dates') }}
),

h_member as (
    select * from {{ ref('h_member') }}
),

-- Logical CTEs

-- Step 1: Get members with active medical eligibility during evaluation window
-- Business Rule: Must have medical eligibility overlapping with evaluation window (low_date to high_date)
eligible_members_base as (
    select
        me.source,
        me.member_bk,
        me.product_category_bk,
        ed.current_eval_date,
        ed.low_date,
        ed.high_date

    from current_member_eligibility me

    -- Cross join to evaluation dates
    cross join evaluation_dates ed

    where 1=1
        -- Medical eligibility indicator must be 'Y'
        and me.eligibility_ind = 'Y'
        -- Product category must be medical-related (adjust as needed for your business rules)
        and me.product_category_bk in ('M', 'MR')  -- M=Medical, MR=Medical+Rx
        -- Eligibility period must overlap with evaluation window
        and me.elig_eff_date <= ed.high_date
        and (me.elig_term_date >= ed.low_date or me.elig_term_date is null)

    {% if is_incremental() %}
        -- Only process new evaluation dates
        and ed.current_eval_date > (select max(current_eval_date) from {{ this }})
    {% endif %}
),

-- Step 2: Filter to members with primary medical COB
-- Business Rule: Must have BCI as primary medical insurance during evaluation period
members_with_primary_cob as (
    select distinct
        em.source,
        em.member_bk,
        em.current_eval_date,
        em.low_date,
        em.high_date

    from eligible_members_base em

    -- Inner join to COB profile - must have primary medical coverage
    inner join member_cob_profile cob
        on cob.source = em.source
        and cob.member_bk = em.member_bk
        -- COB period must overlap with evaluation window
        and cob.effective_date <= em.high_date
        and cob.end_date >= em.low_date
        -- Must be BCI primary for medical
        and cob.medical_is_bci_primary = true
),

-- Step 3: Join member demographics
-- Business Rule: Capture member, subscriber, group identifiers for reporting
member_demographics as (
    select
        mp.source,
        mp.member_bk,
        mp.current_eval_date,
        mp.low_date,
        mp.high_date,
        m.subscriber_bk,
        m.group_bk,
        m.member_suffix,
        s.subscriber_id,
        g.group_id

    from members_with_primary_cob mp

    inner join current_member m
        on m.source = mp.source
        and m.member_bk = mp.member_bk

    inner join current_subscriber s
        on s.source = m.source
        and s.subscriber_bk = m.subscriber_bk

    inner join current_group g
        on g.source = m.source
        and g.group_bk = m.group_bk
),

-- Step 4: Add constituent ID (MDM identifier)
-- Business Rule: Map member to constituent ID for cross-system identification
member_with_constituent as (
    select
        md.*,
        mp.person_bk as constituent_id

    from member_demographics md

    left join member_person_xref mp
        on mp.source = md.source
        and mp.member_bk = md.member_bk
),

-- Step 5: Geocode member address to FIPS codes
-- Business Rule: Use most recent home address during evaluation period, geocode via zip code
member_address_geocoded as (
    select
        mc.source,
        mc.member_bk,
        mc.current_eval_date,
        mc.low_date,
        mc.high_date,
        mc.subscriber_bk,
        mc.group_bk,
        mc.member_suffix,
        mc.subscriber_id,
        mc.group_id,
        mc.constituent_id,
        sa.zip_code,
        zc.state_id,
        zc.fips_county_code,
        zc.fips_code,
        -- Flag if member is in Idaho service area
        case when ic.fips_county_code is not null then true else false end as is_idaho_service_area

    from member_with_constituent mc

    -- Left join to subscriber address (home address)
    left join current_subscriber_address sa
        on sa.source = mc.source
        and sa.subscriber_bk = mc.subscriber_bk
        and sa.address_type_bk = 'HOME'

    -- Left join to zip code reference for geocoding
    left join zip_code_ref zc
        on zc.zip_code = sa.zip_code

    -- Left join to Idaho county reference
    left join idaho_county_ref ic
        on ic.fips_county_code = zc.fips_county_code
),

-- Step 6: Deduplicate if multiple addresses exist (unlikely but defensive)
-- Business Rule: Take first record if duplicates exist
member_eligibility_deduped as (
    select
        source,
        member_bk,
        current_eval_date,
        max(constituent_id) as constituent_id,
        max(group_id) as group_id,
        max(subscriber_id) as subscriber_id,
        max(member_suffix) as member_suffix,
        max(zip_code) as zip_code,
        max(state_id) as state_id,
        max(fips_county_code) as fips_county_code,
        max(fips_code) as fips_code,
        max(is_idaho_service_area::int)::boolean as is_idaho_service_area

    from member_address_geocoded

    group by
        source,
        member_bk,
        current_eval_date
),

-- Step 7: Add hub key and metadata
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['me.source', 'me.member_bk']) }} as member_hk,
        me.source,
        me.member_bk,
        me.current_eval_date,
        me.constituent_id,
        me.group_id,
        me.subscriber_id,
        me.member_suffix,
        me.zip_code,
        me.state_id,
        me.fips_county_code,
        me.fips_code,
        me.is_idaho_service_area,

        -- Metadata
        current_timestamp() as load_date,
        'cs_member_pcp_attribution_eligibility' as record_source

    from member_eligibility_deduped me
)

select * from final
