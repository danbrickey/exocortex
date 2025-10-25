{{
    config(
        materialized='incremental',
        unique_key=['source', 'provider_bk', 'current_eval_date'],
        cluster_by=['source', 'provider_bk'],
        incremental_strategy='merge',
        on_schema_change='fail',
        tags=['pcp_attribution', 'provider', 'computed_satellite']
    )
}}

/*
Purpose: Determines which providers are eligible to be attributed as PCPs
Grain: One row per provider per evaluation date
Dependencies: current_provider, current_provider_affiliation, current_provider_network_relational, seed_pcp_attribution_provider_specialty
Replaces: PCPAttribution_02_NonDV_02_ProviderSet, v_PCPAttribution_02_EligibleProvider
*/

with

-- Import CTEs
current_provider as (
    select * from {{ ref('current_provider') }}
),

current_provider_affiliation as (
    select * from {{ ref('current_provider_affiliation') }}
),

current_provider_network_relational as (
    select * from {{ ref('current_provider_network_relational') }}
),

provider_specialty_seed as (
    select * from {{ ref('seed_pcp_attribution_provider_specialty') }}
),

evaluation_dates as (
    select * from {{ ref('seed_pcp_attribution_evaluation_dates') }}
),

h_provider as (
    select * from {{ ref('h_provider') }}
),

-- Logical CTEs

-- Step 1: Identify eligible specialist providers based on specialty code
-- Business Rule: Must have approved specialty code, entity type 'P', and exclude institutional types
eligible_specialists as (
    select
        p.source,
        p.provider_bk,
        p.npi,
        p.tax_id,
        p.provider_specialty,
        p.provider_type,
        p.provider_entity,
        ed.current_eval_date,
        'Specialist' as pcp_indicator,

        -- Calculate group-level tax ID (prioritize group over individual)
        coalesce(pg.tax_id, p.tax_id) as tax_id_group_then_individual

    from current_provider p

    -- Join to specialty seed to filter eligible specialties
    inner join provider_specialty_seed spec
        on spec.specialty_code = p.provider_specialty

    -- Left join to get group-level provider for Tax ID
    left join current_provider_affiliation aff
        on aff.source = p.source
        and aff.provider_bk = p.provider_bk
        and aff.affiliation_entity_bk = 'G'  -- Group entity

    left join current_provider pg
        on pg.source = aff.source
        and pg.provider_bk = aff.related_provider_bk

    -- Cross join to evaluation dates
    cross join evaluation_dates ed

    where 1=1
        -- Exclude institutional provider types
        and coalesce(p.provider_type, '') not in ('GOVH', 'HOSP', 'INDH', 'PUBH', 'TPLH')
        -- Must be person entity
        and p.provider_entity = 'P'

    {% if is_incremental() %}
        -- Only process new evaluation dates
        and ed.current_eval_date > (select max(current_eval_date) from {{ this }})
    {% endif %}
),

-- Step 2: Identify PCP providers based on network relationships
-- Business Rule: Must have active PCP indicator during evaluation window, be in network
eligible_pcps as (
    select
        p.source,
        p.provider_bk,
        p.npi,
        p.tax_id,
        p.provider_specialty,
        p.provider_type,
        p.provider_entity,
        ed.current_eval_date,
        'PCP' as pcp_indicator,

        -- Calculate group-level tax ID (prioritize group over individual)
        coalesce(pg.tax_id, p.tax_id) as tax_id_group_then_individual,

        -- Calculate term date (if network term date is beyond eval window, use window end)
        case
            when pn.provider_network_term_date > ed.high_date then ed.high_date
            else pn.provider_network_term_date
        end as term_date

    from current_provider p

    -- Join to network relationships
    inner join current_provider_network_relational pn
        on pn.source = p.source
        and pn.provider_bk = p.provider_bk
        and pn.pcp_indicator = 'Y'
        -- Network relationship must be active during evaluation window
        and pn.provider_network_eff_date <= ed.current_eval_date
        and (pn.provider_network_term_date >= ed.low_date or pn.provider_network_term_date is null)

    -- Left join to get group-level provider for Tax ID
    left join current_provider_affiliation aff
        on aff.source = p.source
        and aff.provider_bk = p.provider_bk
        and aff.affiliation_entity_bk = 'G'  -- Group entity

    left join current_provider pg
        on pg.source = aff.source
        and pg.provider_bk = aff.related_provider_bk

    -- Cross join to evaluation dates
    cross join evaluation_dates ed

    where 1=1
        {% if is_incremental() %}
            -- Only process new evaluation dates
            and ed.current_eval_date > (select max(current_eval_date) from {{ this }})
        {% endif %}
),

-- Step 3: Union specialists and PCPs, deduplicating where provider appears in both
-- Business Rule: PCP indicator wins over Specialist if provider is in both sets
combined_eligibility as (
    select * from eligible_pcps

    union

    select
        source,
        provider_bk,
        npi,
        tax_id,
        provider_specialty,
        provider_type,
        provider_entity,
        current_eval_date,
        pcp_indicator,
        tax_id_group_then_individual,
        '9999-12-31'::date as term_date
    from eligible_specialists

    -- Exclude specialists who are already in the PCP set for same eval date
    where not exists (
        select 1 from eligible_pcps pcp
        where pcp.source = eligible_specialists.source
          and pcp.provider_bk = eligible_specialists.provider_bk
          and pcp.current_eval_date = eligible_specialists.current_eval_date
    )
),

-- Step 4: Deduplicate and select final attributes per provider per eval date
-- Business Rule: If duplicate, select row with latest term_date
provider_eligibility_deduped as (
    select
        source,
        provider_bk,
        current_eval_date,
        max(npi) as provider_npi,
        max(tax_id_group_then_individual) as tax_id_group_then_individual,
        max(pcp_indicator) as pcp_indicator,
        max(term_date) as term_date
    from combined_eligibility
    group by
        source,
        provider_bk,
        current_eval_date
),

-- Step 5: Add hub key and metadata
final as (
    select
        {{ dbt_utils.generate_surrogate_key(['pe.source', 'pe.provider_bk']) }} as provider_hk,
        pe.source,
        pe.provider_bk,
        pe.current_eval_date,
        pe.provider_npi,
        pe.tax_id_group_then_individual,
        pe.pcp_indicator,
        pe.term_date,

        -- Metadata
        current_timestamp() as load_date,
        'cs_provider_pcp_eligibility' as record_source

    from provider_eligibility_deduped pe
)

select * from final
