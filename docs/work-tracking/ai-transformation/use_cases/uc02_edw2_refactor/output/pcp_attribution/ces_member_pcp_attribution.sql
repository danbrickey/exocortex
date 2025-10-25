{{
    config(
        materialized='incremental',
        unique_key=['source', 'member_bk', 'effective_date'],
        cluster_by=['source', 'member_bk'],
        incremental_strategy='merge',
        on_schema_change='fail',
        tags=['pcp_attribution', 'computed_effectivity_satellite']
    )
}}

/*
Purpose: Applies final attribution logic to assign each member to their attributed PCP with effectivity dates
Grain: One row per member per attribution period (from one evaluation date to the next)
Dependencies: cs_member_provider_visit_aggregation, cs_member_pcp_attribution_eligibility
Replaces: PCPAttribution_02_NonDV_10_ProviderIDByMember, PCPAttribution_02_NonDV_11_HighClinic, v_PCPAttribution_02_MemberClinicListing, v_PCPAttribution_02_ProviderRankByMemberRollup, PCPAttribution_02_NonDV_12_CalculatedPCP
*/

with

-- Import CTEs
visit_aggregation as (
    select * from {{ ref('cs_member_provider_visit_aggregation') }}
),

eligible_members as (
    select * from {{ ref('cs_member_pcp_attribution_eligibility') }}
),

evaluation_dates as (
    select * from {{ ref('seed_pcp_attribution_evaluation_dates') }}
),

h_member as (
    select * from {{ ref('h_member') }}
),

h_provider as (
    select * from {{ ref('h_provider') }}
),

-- Logical CTEs

-- Step 1: Rank providers by member using clinic-level attribution logic
-- Business Rule: Group by Tax ID (clinic) first, then rank by PCP indicator, visit count, last visit, RVU, NPI
provider_ranking_by_clinic as (
    select
        va.source,
        va.member_bk,
        va.provider_bk,
        va.current_eval_date,
        va.tax_id_group_then_individual,
        va.provider_npi,
        va.pcp_indicator,
        va.unique_visit_count,
        va.last_visit_date,
        va.rvu_total,

        -- Rank providers within each member-clinic combination
        row_number() over (
            partition by va.source, va.member_bk, va.current_eval_date, va.tax_id_group_then_individual
            order by
                -- 1. PCP indicator (PCP wins over Specialist)
                case when va.pcp_indicator = 'PCP' then 1 else 2 end,
                -- 2. Unique visit count (descending)
                va.unique_visit_count desc,
                -- 3. Last visit date (most recent wins)
                va.last_visit_date desc,
                -- 4. RVU total (highest wins)
                va.rvu_total desc,
                -- 5. Provider NPI (tie-breaker)
                va.provider_npi
        ) as provider_rank_within_clinic

    from visit_aggregation va
),

-- Step 2: Select highest-ranked provider per clinic (for clinic-level aggregation)
-- Business Rule: Each clinic gets one representative provider per member
highest_provider_per_clinic as (
    select
        source,
        member_bk,
        current_eval_date,
        tax_id_group_then_individual,
        max(case when provider_rank_within_clinic = 1 then provider_bk end) as representative_provider_bk,
        max(case when provider_rank_within_clinic = 1 then provider_npi end) as representative_provider_npi,
        max(case when provider_rank_within_clinic = 1 then pcp_indicator end) as clinic_pcp_indicator,
        sum(unique_visit_count) as clinic_visit_count,
        max(last_visit_date) as clinic_last_visit_date,
        sum(rvu_total) as clinic_rvu_total

    from provider_ranking_by_clinic

    group by
        source,
        member_bk,
        current_eval_date,
        tax_id_group_then_individual
),

-- Step 3: Rank clinics by member to select attributed clinic
-- Business Rule: Apply same ranking logic at clinic level
clinic_ranking_by_member as (
    select
        hc.source,
        hc.member_bk,
        hc.current_eval_date,
        hc.tax_id_group_then_individual,
        hc.representative_provider_bk,
        hc.representative_provider_npi,
        hc.clinic_pcp_indicator,
        hc.clinic_visit_count,
        hc.clinic_last_visit_date,
        hc.clinic_rvu_total,

        -- Rank clinics for attribution
        row_number() over (
            partition by hc.source, hc.member_bk, hc.current_eval_date
            order by
                -- 1. PCP indicator (clinic with PCP wins)
                case when hc.clinic_pcp_indicator = 'PCP' then 1 else 2 end,
                -- 2. Clinic visit count (descending)
                hc.clinic_visit_count desc,
                -- 3. Last visit date (most recent)
                hc.clinic_last_visit_date desc,
                -- 4. RVU total (highest)
                hc.clinic_rvu_total desc,
                -- 5. Tax ID (tie-breaker)
                hc.tax_id_group_then_individual
        ) as clinic_rank

    from highest_provider_per_clinic hc
),

-- Step 4: Select only #1 ranked clinic per member (the attributed PCP)
-- Business Rule: Only the top-ranked clinic becomes the attributed PCP
attributed_pcp_per_eval as (
    select
        source,
        member_bk,
        current_eval_date as effective_date,
        representative_provider_bk as attributed_provider_bk,
        representative_provider_npi as attributed_provider_npi,
        tax_id_group_then_individual as attributed_tax_id,
        clinic_pcp_indicator as attributed_pcp_indicator,
        clinic_visit_count as attribution_visit_count,
        clinic_last_visit_date as attribution_last_visit_date,
        clinic_rvu_total as attribution_rvu_total

    from clinic_ranking_by_member

    where clinic_rank = 1
),

-- Step 5: Calculate end dates for effectivity periods
-- Business Rule: Attribution is effective from current_eval_date until next eval date (or 9999-12-31)
attribution_with_end_dates as (
    select
        a.source,
        a.member_bk,
        a.effective_date,
        coalesce(
            lead(a.effective_date) over (
                partition by a.source, a.member_bk
                order by a.effective_date
            ),
            '9999-12-31'::date
        ) as end_date,
        a.attributed_provider_bk,
        a.attributed_provider_npi,
        a.attributed_tax_id,
        a.attributed_pcp_indicator,
        a.attribution_visit_count,
        a.attribution_last_visit_date,
        a.attribution_rvu_total

    from attributed_pcp_per_eval a
),

-- Step 6: Add is_current flag
-- Business Rule: is_current = true if end_date is 9999-12-31
attribution_with_current_flag as (
    select
        *,
        case when end_date = '9999-12-31'::date then true else false end as is_current

    from attribution_with_end_dates
),

-- Step 7: Also include members with no attribution (eligible but no visits)
-- Business Rule: Eligible members with no visits get null attribution
members_without_attribution as (
    select distinct
        em.source,
        em.member_bk,
        em.current_eval_date as effective_date

    from eligible_members em

    -- Left anti-join: members in eligibility but not in attribution
    left join attributed_pcp_per_eval a
        on a.source = em.source
        and a.member_bk = em.member_bk
        and a.effective_date = em.current_eval_date

    where a.member_bk is null

    {% if is_incremental() %}
        -- Only process new evaluation dates
        and em.current_eval_date > (select max(effective_date) from {{ this }})
    {% endif %}
),

-- Step 8: Calculate end dates for members without attribution
members_without_attribution_dated as (
    select
        noa.source,
        noa.member_bk,
        noa.effective_date,
        coalesce(
            lead(noa.effective_date) over (
                partition by noa.source, noa.member_bk
                order by noa.effective_date
            ),
            '9999-12-31'::date
        ) as end_date,
        null::varchar as attributed_provider_bk,
        null::varchar as attributed_provider_npi,
        null::varchar as attributed_tax_id,
        null::varchar as attributed_pcp_indicator,
        0 as attribution_visit_count,
        null::date as attribution_last_visit_date,
        0.0 as attribution_rvu_total,
        case when end_date = '9999-12-31'::date then true else false end as is_current

    from members_without_attribution noa
),

-- Step 9: Union members with and without attribution
all_member_attribution as (
    select * from attribution_with_current_flag

    union all

    select * from members_without_attribution_dated
),

-- Step 10: Add hub keys, constituent ID, and metadata
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['ama.source', 'ama.member_bk']) }} as member_hk,
        {{ dbt_utils.generate_surrogate_key(['ama.source', 'ama.attributed_provider_bk']) }} as provider_hk,
        ama.source,
        ama.member_bk,
        ama.effective_date,
        ama.end_date,
        ama.is_current,
        ama.attributed_provider_bk,
        ama.attributed_provider_npi,
        ama.attributed_tax_id,
        ama.attributed_pcp_indicator,
        ama.attribution_visit_count,
        ama.attribution_last_visit_date,
        ama.attribution_rvu_total,

        -- Join to get constituent_id for reporting
        em.constituent_id,
        em.group_id,
        em.subscriber_id,
        em.member_suffix,

        -- Metadata
        current_timestamp() as load_date,
        'ces_member_pcp_attribution' as record_source,
        {{ dbt_utils.generate_surrogate_key([
            'ama.attributed_provider_npi',
            'ama.attributed_tax_id',
            'ama.attributed_pcp_indicator',
            'ama.attribution_visit_count',
            'ama.attribution_rvu_total'
        ]) }} as hash_diff

    from all_member_attribution ama

    -- Left join to get member demographics
    left join eligible_members em
        on em.source = ama.source
        and em.member_bk = ama.member_bk
        and em.current_eval_date = ama.effective_date
)

select * from final
