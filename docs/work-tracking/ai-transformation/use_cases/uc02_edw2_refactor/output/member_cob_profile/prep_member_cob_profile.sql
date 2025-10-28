{{
    config(
        materialized='ephemeral',
        tags=['cob', 'member', 'business_vault']
    )
}}

/*
    Preparation model for Member COB Profile

    Purpose: Applies business rules to determine Coordination of Benefits (COB) status
    for Medical, Dental, and Drug coverage across discrete date ranges.

    Business Logic:
    - Creates discrete date ranges by combining eligibility and COB effective dates
    - Determines coverage status (Medical, Dental, Drug) for each date range
    - Identifies COB order (Primary, Secondary, Tertiary)
    - Flags "Two Blues" scenarios where member has multiple BCBS coverages
    - Handles Medicare Part D special rules

    Legacy Source: HDSVault.biz.spCOBProfileLookup
*/

with

-- Import CTEs - bring in source data
current_member as (
    select * from {{ ref('current_member') }}
),

current_member_eligibility as (
    select * from {{ ref('current_member_eligibility') }}
),

current_member_cob as (
    select * from {{ ref('current_member_cob') }}
),

current_subscriber as (
    select * from {{ ref('current_subscriber') }}
),

current_group as (
    select * from {{ ref('current_group') }}
),

seed_two_blues as (
    select * from {{ ref('seed_cob_two_blues_carriers') }}
),

seed_medicare_part_d_primary as (
    select * from {{ ref('seed_cob_medicare_part_d_primary') }}
),

seed_medicare_part_d_secondary as (
    select * from {{ ref('seed_cob_medicare_part_d_secondary') }}
),

-- Logical CTEs - build discrete date ranges and apply business rules

-- Collect all potential start dates from eligibility and COB
from_dates as (
    -- Eligibility effective dates for Medical/Dental
    select
        source,
        member_bk,
        elig_eff_date as from_date
    from current_member_eligibility
    where product_category_bk in ('M', 'D')
        and eligibility_ind = 'Y'

    union

    -- COB effective dates
    select
        source,
        member_bk,
        cob_eff_date as from_date
    from current_member_cob

    union

    -- Day after eligibility term dates (for Medical/Dental)
    select
        source,
        member_bk,
        case
            when elig_term_date = '9999-12-31' then elig_term_date
            else dateadd(day, 1, elig_term_date)
        end as from_date
    from current_member_eligibility
    where product_category_bk in ('M', 'D')
        and eligibility_ind = 'Y'

    union

    -- Day after COB term dates
    select
        source,
        member_bk,
        case
            when cob_term_date = '9999-12-31' then cob_term_date
            else dateadd(day, 1, cob_term_date)
        end as from_date
    from current_member_cob
),

-- Collect all potential end dates from eligibility and COB
thru_dates as (
    -- Eligibility term dates for Medical/Dental
    select
        source,
        member_bk,
        elig_term_date as thru_date
    from current_member_eligibility
    where product_category_bk in ('M', 'D')
        and eligibility_ind = 'Y'

    union

    -- COB term dates
    select
        source,
        member_bk,
        cob_term_date as thru_date
    from current_member_cob

    union

    -- Day before eligibility effective dates (for Medical/Dental)
    select
        source,
        member_bk,
        dateadd(day, -1, elig_eff_date) as thru_date
    from current_member_eligibility
    where product_category_bk in ('M', 'D')
        and eligibility_ind = 'Y'

    union

    -- Day before COB effective dates
    select
        source,
        member_bk,
        dateadd(day, -1, cob_eff_date) as thru_date
    from current_member_cob
),

-- Cross join from and thru dates to create all possible ranges, then filter for valid ranges
date_ranges_raw as (
    select
        row_number() over (
            partition by f.source, f.member_bk, f.from_date
            order by datediff(day, f.from_date, t.thru_date) asc
        ) as row_num,
        f.source,
        f.member_bk,
        f.from_date as start_date,
        t.thru_date as end_date,
        datediff(day, f.from_date, t.thru_date) as days_interval
    from from_dates f
    inner join thru_dates t
        on f.member_bk = t.member_bk
        and f.source = t.source
    where datediff(day, f.from_date, t.thru_date) >= 0
),

-- Keep only the shortest valid range for each start date (deduplication)
date_ranges as (
    select
        source,
        member_bk,
        start_date,
        end_date
    from date_ranges_raw
    where row_num = 1
        and start_date <> '9999-12-31'
        and start_date <> '2200-01-01'
),

-- Join back to member, subscriber, group to get identifying information
date_ranges_with_keys as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        dr.end_date,
        m.group_bk,
        m.subscriber_bk,
        m.member_suffix,
        m.member_first_name,
        m.edp_record_source,
        g.group_id,
        s.subscriber_id
    from date_ranges dr
    join current_member m
        on m.source = dr.source
        and m.member_bk = dr.member_bk
    join current_subscriber s
        on s.source = m.source
        and s.subscriber_bk = m.subscriber_bk
    join current_group g
        on g.source = m.source
        and g.group_bk = m.group_bk
),

-- Determine if member has medical eligibility for each date range
medical_eligibility as (
    select distinct
        me.source,
        me.member_bk,
        me.elig_eff_date,
        me.elig_term_date
    from current_member_eligibility me
    where me.product_category_bk in ('M')
        and me.eligibility_ind = 'Y'
),

-- Determine if member has dental eligibility for each date range
dental_eligibility as (
    select distinct
        me.source,
        me.member_bk,
        me.elig_eff_date,
        me.elig_term_date
    from current_member_eligibility me
    where me.product_category_bk in ('D')
        and me.eligibility_ind = 'Y'
),

-- Determine if member has drug eligibility for each date range
-- Drug eligibility comes from Medical ('M') or Rider ('R') product categories
drug_eligibility as (
    select distinct
        me.source,
        me.member_bk,
        me.elig_eff_date,
        me.elig_term_date
    from current_member_eligibility me
    where me.product_category_bk in ('M', 'R')
        and me.eligibility_ind = 'Y'
),

-- Add coverage flags to date ranges
date_ranges_with_coverage as (
    select
        dr.*,
        case when me.member_bk is not null then 'Yes' else 'No' end as medical_coverage,
        case when de.member_bk is not null then 'Yes' else 'No' end as dental_coverage,
        case when drug.member_bk is not null then 'Yes' else 'No' end as drug_coverage,
        -- Initialize COB flags to defaults
        'No' as has_medical_cob,
        'No' as medical_cob_order,
        'No' as has_dental_cob,
        'No' as dental_cob_order,
        'No' as has_drug_cob,
        'No' as drug_cob_order,
        cast(null as varchar) as coverage_id_medical,
        cast(null as varchar) as coverage_id_dental,
        'No' as medical_2blues,
        'No' as dental_2blues,
        'No' as drug_2blues
    from date_ranges_with_keys dr
    left join medical_eligibility me
        on me.source = dr.source
        and me.member_bk = dr.member_bk
        and dr.start_date between me.elig_eff_date and me.elig_term_date
    left join dental_eligibility de
        on de.source = dr.source
        and de.member_bk = dr.member_bk
        and dr.start_date between de.elig_eff_date and de.elig_term_date
    left join drug_eligibility drug
        on drug.source = dr.source
        and drug.member_bk = dr.member_bk
        and dr.start_date between drug.elig_eff_date and drug.elig_term_date
),

-- Apply Primary Medical and Drug COB rules
-- When member has non-dental COB that is not Unknown and not Medicare Part D primary
primary_medical_drug_cob as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        trim(cob.coverage_id) as coverage_id,
        case
            when tb.mcre_id is not null then 'Yes'
            else 'No'
        end as is_two_blues
    from date_ranges_with_coverage dr
    join current_member_cob cob
        on dr.source = cob.source
        and dr.member_bk = cob.member_bk
        and dr.medical_coverage = 'Yes'
        and cob.insurance_order <> 'U'  -- Not Unknown
        and cob.insurance_type <> 'D'   -- Not Dental
        and dr.start_date between cob.cob_eff_date and cob.cob_term_date
    left join seed_medicare_part_d_primary mpd
        on trim(cob.coverage_id) = mpd.mcre_id
    left join seed_two_blues tb
        on trim(cob.coverage_id) = tb.mcre_id
    where mpd.mcre_id is null  -- Exclude Medicare Part D primary codes
),

-- Apply Primary Dental COB rules
primary_dental_cob as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        trim(cob.coverage_id) as coverage_id,
        case
            when tb.mcre_id is not null then 'Yes'
            else 'No'
        end as is_two_blues
    from date_ranges_with_coverage dr
    join current_member_cob cob
        on dr.source = cob.source
        and dr.member_bk = cob.member_bk
        and dr.dental_coverage = 'Yes'
        and cob.insurance_order <> 'U'  -- Not Unknown
        and cob.insurance_type = 'D'    -- Dental only
        and dr.start_date between cob.cob_eff_date and cob.cob_term_date
    left join seed_medicare_part_d_primary mpd
        on trim(cob.coverage_id) = mpd.mcre_id
    left join seed_two_blues tb
        on trim(cob.coverage_id) = tb.mcre_id
    where mpd.mcre_id is null  -- Exclude Medicare Part D primary codes
),

-- Apply Secondary Medical and Drug COB rules
-- When insurance_order = 'P' (Primary to other carrier, Secondary to us)
secondary_medical_drug_cob as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        trim(cob.coverage_id) as coverage_id,
        case
            when tb.mcre_id is not null then 'Yes'
            else 'No'
        end as is_two_blues
    from date_ranges_with_coverage dr
    join current_member_cob cob
        on dr.source = cob.source
        and dr.member_bk = cob.member_bk
        and dr.medical_coverage = 'Yes'
        and cob.insurance_order = 'P'  -- Primary to other carrier
        and cob.insurance_type <> 'D'  -- Not Dental
        and dr.start_date between cob.cob_eff_date and cob.cob_term_date
    left join seed_medicare_part_d_secondary mpd
        on trim(cob.coverage_id) = mpd.mcre_id
    left join seed_two_blues tb
        on trim(cob.coverage_id) = tb.mcre_id
    where mpd.mcre_id is null  -- Exclude Medicare Part D secondary codes
),

-- Apply Secondary Dental COB rules
secondary_dental_cob as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        trim(cob.coverage_id) as coverage_id,
        case
            when tb.mcre_id is not null then 'Yes'
            else 'No'
        end as is_two_blues
    from date_ranges_with_coverage dr
    join current_member_cob cob
        on dr.source = cob.source
        and dr.member_bk = cob.member_bk
        and dr.dental_coverage = 'Yes'
        and cob.insurance_order = 'P'  -- Primary to other carrier
        and cob.insurance_type = 'D'   -- Dental only
        and dr.start_date between cob.cob_eff_date and cob.cob_term_date
    left join seed_medicare_part_d_secondary mpd
        on trim(cob.coverage_id) = mpd.mcre_id
    left join seed_two_blues tb
        on trim(cob.coverage_id) = tb.mcre_id
    where mpd.mcre_id is null  -- Exclude Medicare Part D secondary codes
),

-- Apply Tertiary Medical and Drug COB rules
-- When insurance_order = 'S' (Secondary to other carrier, Tertiary to us)
tertiary_medical_drug_cob as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        trim(cob.coverage_id) as coverage_id,
        case
            when tb.mcre_id is not null then 'Yes'
            else 'No'
        end as is_two_blues
    from date_ranges_with_coverage dr
    join current_member_cob cob
        on dr.source = cob.source
        and dr.member_bk = cob.member_bk
        and dr.medical_coverage = 'Yes'
        and cob.insurance_order = 'S'  -- Secondary to other carrier
        and cob.insurance_type <> 'D'  -- Not Dental
        and dr.start_date between cob.cob_eff_date and cob.cob_term_date
    left join seed_medicare_part_d_secondary mpd
        on trim(cob.coverage_id) = mpd.mcre_id
    left join seed_two_blues tb
        on trim(cob.coverage_id) = tb.mcre_id
    where mpd.mcre_id is null  -- Exclude Medicare Part D secondary codes
        and dr.medical_cob_order = 'Secondary'  -- Only apply if already secondary
),

-- Apply Tertiary Dental COB rules
tertiary_dental_cob as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        trim(cob.coverage_id) as coverage_id,
        case
            when tb.mcre_id is not null then 'Yes'
            else 'No'
        end as is_two_blues
    from date_ranges_with_coverage dr
    join current_member_cob cob
        on dr.source = cob.source
        and dr.member_bk = cob.member_bk
        and dr.dental_coverage = 'Yes'
        and cob.insurance_order = 'S'  -- Secondary to other carrier
        and cob.insurance_type = 'D'   -- Dental only
        and dr.start_date between cob.cob_eff_date and cob.cob_term_date
    left join seed_medicare_part_d_secondary mpd
        on trim(cob.coverage_id) = mpd.mcre_id
    left join seed_two_blues tb
        on trim(cob.coverage_id) = tb.mcre_id
    where mpd.mcre_id is null  -- Exclude Medicare Part D secondary codes
        and dr.dental_cob_order = 'Secondary'  -- Only apply if already secondary
),

-- Combine all COB rules and build final output
final as (
    select
        dr.source,
        dr.member_bk,
        dr.start_date,
        dr.end_date,
        dr.group_id,
        dr.subscriber_id,
        dr.member_suffix,
        dr.group_bk,
        dr.subscriber_bk,
        dr.member_first_name,
        dr.edp_record_source,

        -- Coverage flags
        dr.medical_coverage,
        dr.dental_coverage,
        dr.drug_coverage,

        -- Medical COB
        case when pmc.member_bk is not null then 'Yes' else 'No' end as has_medical_cob,
        case
            when tmc.member_bk is not null then 'Tertiary'
            when smc.member_bk is not null then 'Secondary'
            when pmc.member_bk is not null then 'Primary'
            else 'No'
        end as medical_cob_order,
        coalesce(tmc.coverage_id, smc.coverage_id, pmc.coverage_id) as coverage_id_medical,
        case
            when tmc.member_bk is not null then tmc.is_two_blues
            when smc.member_bk is not null then smc.is_two_blues
            when pmc.member_bk is not null then pmc.is_two_blues
            else 'No'
        end as medical_2blues,

        -- Dental COB
        case when pdc.member_bk is not null then 'Yes' else 'No' end as has_dental_cob,
        case
            when tdc.member_bk is not null then 'Tertiary'
            when sdc.member_bk is not null then 'Secondary'
            when pdc.member_bk is not null then 'Primary'
            else 'No'
        end as dental_cob_order,
        coalesce(tdc.coverage_id, sdc.coverage_id, pdc.coverage_id) as coverage_id_dental,
        case
            when tdc.member_bk is not null then tdc.is_two_blues
            when sdc.member_bk is not null then sdc.is_two_blues
            when pdc.member_bk is not null then pdc.is_two_blues
            else 'No'
        end as dental_2blues,

        -- Drug COB (follows medical)
        case when pmc.member_bk is not null then 'Yes' else 'No' end as has_drug_cob,
        case
            when tmc.member_bk is not null then 'Tertiary'
            when smc.member_bk is not null then 'Secondary'
            when pmc.member_bk is not null then 'Primary'
            else 'No'
        end as drug_cob_order,
        case
            when tmc.member_bk is not null then tmc.is_two_blues
            when smc.member_bk is not null then smc.is_two_blues
            when pmc.member_bk is not null then pmc.is_two_blues
            else 'No'
        end as drug_2blues,

        current_timestamp() as create_date

    from date_ranges_with_coverage dr
    left join primary_medical_drug_cob pmc
        on pmc.source = dr.source
        and pmc.member_bk = dr.member_bk
        and pmc.start_date = dr.start_date
    left join primary_dental_cob pdc
        on pdc.source = dr.source
        and pdc.member_bk = dr.member_bk
        and pdc.start_date = dr.start_date
    left join secondary_medical_drug_cob smc
        on smc.source = dr.source
        and smc.member_bk = dr.member_bk
        and smc.start_date = dr.start_date
    left join secondary_dental_cob sdc
        on sdc.source = dr.source
        and sdc.member_bk = dr.member_bk
        and sdc.start_date = dr.start_date
    left join tertiary_medical_drug_cob tmc
        on tmc.source = dr.source
        and tmc.member_bk = dr.member_bk
        and tmc.start_date = dr.start_date
    left join tertiary_dental_cob tdc
        on tdc.source = dr.source
        and tdc.member_bk = dr.member_bk
        and tdc.start_date = dr.start_date

    -- Exclude date ranges with no coverage at all
    where not (
        dr.medical_coverage = 'No'
        and dr.dental_coverage = 'No'
        and dr.drug_coverage = 'No'
    )
)

select * from final
