{{
    config(
        materialized='incremental',
        unique_key=['source', 'member_bk', 'provider_bk', 'current_eval_date'],
        cluster_by=['source', 'member_bk', 'current_eval_date'],
        incremental_strategy='merge',
        on_schema_change='fail',
        tags=['pcp_attribution', 'claims', 'computed_satellite']
    )
}}

/*
Purpose: Aggregates claim visit patterns between members and providers to calculate attribution
Grain: One row per member-provider-evaluation date combination
Dependencies: current_claim_medical_header, current_claim_medical_line, current_claim_medical_procedure, cs_provider_pcp_eligibility, cs_member_pcp_attribution_eligibility, seed references
Replaces: PCPAttribution_02_NonDV_06_Claims, PCPAttribution_02_NonDV_07_Procedures, PCPAttribution_02_NonDV_08_ClaimSet, PCPAttribution_02_NonDV_09_ProviderRankByMember
*/

with

-- Import CTEs
current_claim_header as (
    select * from {{ ref('current_claim_medical_header') }}
),

current_claim_line as (
    select * from {{ ref('current_claim_medical_line') }}
),

current_claim_procedure as (
    select * from {{ ref('current_claim_medical_procedure') }}
),

eligible_providers as (
    select * from {{ ref('cs_provider_pcp_eligibility') }}
),

eligible_members as (
    select * from {{ ref('cs_member_pcp_attribution_eligibility') }}
),

cms_rvu_ref as (
    select * from {{ ref('seed_pcp_attribution_cms_rvu') }}
),

bihc_codes_ref as (
    select * from {{ ref('seed_pcp_attribution_bihc_codes') }}
),

evaluation_dates as (
    select * from {{ ref('seed_pcp_attribution_evaluation_dates') }}
),

-- Logical CTEs

-- Step 1: Get eligible claims for evaluation period
-- Business Rule: Only paid/adjudicated claims within evaluation window, for eligible members
eligible_claims as (
    select
        ch.source,
        ch.claim_id,
        ch.member_bk,
        ch.provider_bk,
        ch.service_from_date,
        ch.claim_status,
        ed.current_eval_date,
        ed.low_date,
        ed.high_date

    from current_claim_header ch

    -- Cross join to evaluation dates
    cross join evaluation_dates ed

    -- Inner join to eligible members - only count claims for attribution-eligible members
    inner join eligible_members em
        on em.source = ch.source
        and em.member_bk = ch.member_bk
        and em.current_eval_date = ed.current_eval_date

    where 1=1
        -- Only paid or adjudicated claims
        and ch.claim_status in ('02', '91')  -- 02=Paid, 91=Adjudicated
        -- Service date must fall within evaluation window (18-month lookback)
        and ch.service_from_date between ed.low_date and ed.high_date

    {% if is_incremental() %}
        -- Only process new evaluation dates
        and ed.current_eval_date > (select max(current_eval_date) from {{ this }})
    {% endif %}
),

-- Step 2: Join claim lines to get procedure codes
-- Business Rule: Only include lines that are not denied
claim_lines_with_procedures as (
    select
        ec.source,
        ec.claim_id,
        ec.member_bk,
        ec.provider_bk,
        ec.service_from_date,
        ec.current_eval_date,
        cl.procedure_code as line_procedure_code,
        cl.place_of_service_id

    from eligible_claims ec

    inner join current_claim_line cl
        on cl.source = ec.source
        and cl.claim_id = ec.claim_id
        -- Exclude denied procedures
        and cl.place_of_service_id != '20'  -- 20=Denied
),

-- Step 3: Get header-level procedures (diagnosis/procedure codes)
claim_header_procedures as (
    select
        ec.source,
        ec.claim_id,
        ec.member_bk,
        ec.provider_bk,
        ec.service_from_date,
        ec.current_eval_date,
        cp.procedure_code as header_procedure_code,
        cp.procedure_order

    from eligible_claims ec

    inner join current_claim_procedure cp
        on cp.source = ec.source
        and cp.claim_id = ec.claim_id
),

-- Step 4: Identify E&M visits via CMS RVU or BIHC codes
-- Business Rule: Visit counts as E&M if procedure has RVU value OR is BIHC code
em_visits_identified as (
    select distinct
        cl.source,
        cl.claim_id,
        cl.member_bk,
        cl.provider_bk,
        cl.service_from_date,
        cl.current_eval_date,
        cl.line_procedure_code as procedure_code,
        case
            when rvu.hcpcs is not null then true
            when bihc.cpt_code is not null then true
            else false
        end as is_em_visit

    from claim_lines_with_procedures cl

    -- Left join to CMS RVU reference (if procedure has RVU, it's E&M)
    left join cms_rvu_ref rvu
        on rvu.hcpcs = cl.line_procedure_code

    -- Left join to BIHC codes (behavioral integrated health care)
    left join bihc_codes_ref bihc
        on bihc.cpt_code = cl.line_procedure_code

    -- Also check header procedures
    union

    select distinct
        cp.source,
        cp.claim_id,
        cp.member_bk,
        cp.provider_bk,
        cp.service_from_date,
        cp.current_eval_date,
        cp.header_procedure_code as procedure_code,
        case
            when rvu.hcpcs is not null then true
            when bihc.cpt_code is not null then true
            else false
        end as is_em_visit

    from claim_header_procedures cp

    -- Left join to CMS RVU reference
    left join cms_rvu_ref rvu
        on rvu.hcpcs = cp.header_procedure_code

    -- Left join to BIHC codes
    left join bihc_codes_ref bihc
        on bihc.cpt_code = cp.header_procedure_code
),

-- Step 5: Filter to only E&M visits and join to eligible providers
-- Business Rule: Only count visits to eligible providers with E&M codes
em_visits_to_eligible_providers as (
    select
        emv.source,
        emv.claim_id,
        emv.member_bk,
        emv.provider_bk,
        emv.service_from_date,
        emv.current_eval_date,
        emv.procedure_code,
        ep.provider_npi,
        ep.tax_id_group_then_individual,
        ep.pcp_indicator,
        rvu.work_rvu,
        rvu.pe_rvu,
        rvu.mp_rvu,
        coalesce(rvu.work_rvu, 0) + coalesce(rvu.pe_rvu, 0) + coalesce(rvu.mp_rvu, 0) as total_rvu

    from em_visits_identified emv

    -- Inner join to eligible providers - only count visits to attribution-eligible providers
    inner join eligible_providers ep
        on ep.source = emv.source
        and ep.provider_bk = emv.provider_bk
        and ep.current_eval_date = emv.current_eval_date

    -- Left join to CMS RVU for RVU values
    left join cms_rvu_ref rvu
        on rvu.hcpcs = emv.procedure_code

    where emv.is_em_visit = true
),

-- Step 6: Aggregate visits by member-provider-eval date
-- Business Rule: Count unique visits (distinct provider + service date + member), sum RVUs, track last visit
member_provider_visit_summary as (
    select
        source,
        member_bk,
        provider_bk,
        current_eval_date,
        provider_npi,
        tax_id_group_then_individual,
        pcp_indicator,

        -- Unique visit count: distinct combination of provider + service date + member
        count(distinct concat(provider_bk, '|', service_from_date::varchar, '|', member_bk)) as unique_visit_count,

        -- Last visit date
        max(service_from_date) as last_visit_date,

        -- Total RVU
        sum(total_rvu) as rvu_total

    from em_visits_to_eligible_providers

    group by
        source,
        member_bk,
        provider_bk,
        current_eval_date,
        provider_npi,
        tax_id_group_then_individual,
        pcp_indicator
),

-- Step 7: Add hub/link keys and metadata
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['mv.source', 'mv.member_bk']) }} as member_hk,
        {{ dbt_utils.generate_surrogate_key(['mv.source', 'mv.provider_bk']) }} as provider_hk,
        mv.source,
        mv.member_bk,
        mv.provider_bk,
        mv.current_eval_date,
        mv.provider_npi,
        mv.tax_id_group_then_individual,
        mv.pcp_indicator,
        mv.unique_visit_count,
        mv.last_visit_date,
        mv.rvu_total,

        -- Metadata
        current_timestamp() as load_date,
        'cs_member_provider_visit_aggregation' as record_source

    from member_provider_visit_summary mv

    -- Only include members with at least one visit
    where mv.unique_visit_count > 0
)

select * from final
