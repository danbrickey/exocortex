{{
  config(
    materialized='incremental',
    unique_key=['source', 'member_bk', 'effective_date'],
    cluster_by=['source', 'member_bk'],
    incremental_strategy='merge',
    on_schema_change='fail',
    tags=['business_vault', 'cob', 'member', 'effectivity_satellite']
  )
}}

/*
================================================================================
Model: ces_member_cob_profile
Type: Computed Effectivity Satellite
Purpose: Provides temporally accurate COB (Coordination of Benefits) status
         for members across Medical, Dental, and Drug coverage types

Business Rules:
- Creates discrete, non-overlapping date ranges for each member
- Determines BCI's position as Primary/Secondary/Tertiary payer
- Handles Two Blues scenarios and Medicare Part D special rules
- Applies cascading COB order logic (Primary → Secondary → Tertiary)

Grain: One row per member per discrete date range where COB status is constant

Dependencies:
- Raw Vault: current_member_eligibility, current_member_cob, current_member,
              current_subscriber, current_group
- Seeds: seed_cob_two_blues_carriers, seed_cob_medicare_part_d_primary,
         seed_cob_medicare_part_d_secondary
- Hubs: h_member

Author: Generated from EDW2 refactoring
Legacy Source: HDSVault.biz.spCOBProfileLookup
================================================================================
*/

-- ============================================================================
-- CTE 1: Identify changed members for incremental processing
-- ============================================================================
WITH incremental_members AS (
    {% if is_incremental() %}
    -- Only process members with eligibility or COB changes since last run
    SELECT DISTINCT
        source,
        member_bk
    FROM {{ ref('current_member_eligibility') }}
    WHERE load_date >= (SELECT MAX(load_date) FROM {{ this }})

    UNION

    SELECT DISTINCT
        source,
        member_bk
    FROM {{ ref('current_member_cob') }}
    WHERE load_date >= (SELECT MAX(load_date) FROM {{ this }})
    {% else %}
    -- Full refresh: process all members
    SELECT DISTINCT
        source,
        member_bk
    FROM {{ ref('current_member_eligibility') }}
    WHERE eligibility_ind = 'Y'
      AND product_category_bk IN ('M', 'D') -- Medical or Dental eligibility
    {% endif %}
),

-- ============================================================================
-- CTE 2: Collect all "FromDates" - possible period start dates
-- ============================================================================
from_dates AS (
    -- Eligibility effective dates
    SELECT
        elig.source,
        elig.member_bk,
        elig.elig_eff_date AS from_date
    FROM {{ ref('current_member_eligibility') }} elig
    INNER JOIN incremental_members incr
        ON elig.source = incr.source
        AND elig.member_bk = incr.member_bk
    WHERE elig.product_category_bk IN ('M', 'D')
      AND elig.eligibility_ind = 'Y'

    UNION

    -- COB effective dates
    SELECT
        cob.source,
        cob.member_bk,
        cob.cob_eff_date AS from_date
    FROM {{ ref('current_member_cob') }} cob
    INNER JOIN incremental_members incr
        ON cob.source = incr.source
        AND cob.member_bk = incr.member_bk

    UNION

    -- Day after eligibility term dates (new period can start)
    SELECT
        elig.source,
        elig.member_bk,
        CASE
            WHEN elig.elig_term_date = '9999-12-31' THEN elig.elig_term_date
            ELSE DATEADD(DAY, 1, elig.elig_term_date)
        END AS from_date
    FROM {{ ref('current_member_eligibility') }} elig
    INNER JOIN incremental_members incr
        ON elig.source = incr.source
        AND elig.member_bk = incr.member_bk
    WHERE elig.product_category_bk IN ('M', 'D')
      AND elig.eligibility_ind = 'Y'

    UNION

    -- Day after COB term dates
    SELECT
        cob.source,
        cob.member_bk,
        CASE
            WHEN cob.cob_term_date = '9999-12-31' THEN cob.cob_term_date
            ELSE DATEADD(DAY, 1, cob.cob_term_date)
        END AS from_date
    FROM {{ ref('current_member_cob') }} cob
    INNER JOIN incremental_members incr
        ON cob.source = incr.source
        AND cob.member_bk = incr.member_bk
),

-- ============================================================================
-- CTE 3: Collect all "ThruDates" - possible period end dates
-- ============================================================================
thru_dates AS (
    -- Eligibility term dates
    SELECT
        elig.source,
        elig.member_bk,
        elig.elig_term_date AS thru_date
    FROM {{ ref('current_member_eligibility') }} elig
    INNER JOIN incremental_members incr
        ON elig.source = incr.source
        AND elig.member_bk = incr.member_bk
    WHERE elig.product_category_bk IN ('M', 'D')
      AND elig.eligibility_ind = 'Y'

    UNION

    -- COB term dates
    SELECT
        cob.source,
        cob.member_bk,
        cob.cob_term_date AS thru_date
    FROM {{ ref('current_member_cob') }} cob
    INNER JOIN incremental_members incr
        ON cob.source = incr.source
        AND cob.member_bk = incr.member_bk

    UNION

    -- Day before eligibility effective dates (prior period can end)
    SELECT
        elig.source,
        elig.member_bk,
        DATEADD(DAY, -1, elig.elig_eff_date) AS thru_date
    FROM {{ ref('current_member_eligibility') }} elig
    INNER JOIN incremental_members incr
        ON elig.source = incr.source
        AND elig.member_bk = incr.member_bk
    WHERE elig.product_category_bk IN ('M', 'D')
      AND elig.eligibility_ind = 'Y'

    UNION

    -- Day before COB effective dates
    SELECT
        cob.source,
        cob.member_bk,
        DATEADD(DAY, -1, cob.cob_eff_date) AS thru_date
    FROM {{ ref('current_member_cob') }} cob
    INNER JOIN incremental_members incr
        ON cob.source = incr.source
        AND cob.member_bk = incr.member_bk
),

-- ============================================================================
-- CTE 4: Build Date Spine - discrete, non-overlapping date ranges
-- ============================================================================
date_spine AS (
    SELECT
        from_dates.source,
        from_dates.member_bk,
        from_dates.from_date AS effective_date,
        thru_dates.thru_date AS end_date,
        DATEDIFF(DAY, from_dates.from_date, thru_dates.thru_date) AS days_interval,
        ROW_NUMBER() OVER (
            PARTITION BY from_dates.source, from_dates.member_bk, from_dates.from_date
            ORDER BY DATEDIFF(DAY, from_dates.from_date, thru_dates.thru_date) ASC
        ) AS row_num
    FROM from_dates
    INNER JOIN thru_dates
        ON from_dates.source = thru_dates.source
        AND from_dates.member_bk = thru_dates.member_bk
    WHERE DATEDIFF(DAY, from_dates.from_date, thru_dates.thru_date) >= 0
),

-- Deduplicate to shortest valid interval
date_spine_deduped AS (
    SELECT
        source,
        member_bk,
        effective_date,
        end_date
    FROM date_spine
    WHERE row_num = 1
      AND effective_date <> '9999-12-31'  -- Exclude invalid future dates
      AND effective_date <> '2200-01-01'
),

-- ============================================================================
-- CTE 5: Initialize coverage flags with defaults
-- ============================================================================
coverage_base AS (
    SELECT
        ds.source,
        ds.member_bk,
        ds.effective_date,
        ds.end_date,

        -- Default all flags to 'No'
        'No' AS medical_coverage,
        'No' AS has_medical_cob,
        'No' AS medical_cob_order,
        'No' AS dental_coverage,
        'No' AS has_dental_cob,
        'No' AS dental_cob_order,
        'No' AS drug_coverage,
        'No' AS has_drug_cob,
        'No' AS drug_cob_order,
        'No' AS medical_two_blues,
        'No' AS dental_two_blues,
        'No' AS drug_two_blues,

        CAST(NULL AS VARCHAR(10)) AS medical_carrier_id,
        CAST(NULL AS VARCHAR(10)) AS dental_carrier_id

    FROM date_spine_deduped ds
),

-- ============================================================================
-- CTE 6: Set coverage flags based on eligibility
-- ============================================================================
with_eligibility AS (
    SELECT
        cb.source,
        cb.member_bk,
        cb.effective_date,
        cb.end_date,

        -- Medical coverage if Medical eligibility exists during this period
        CASE
            WHEN med_elig.member_bk IS NOT NULL THEN 'Yes'
            ELSE cb.medical_coverage
        END AS medical_coverage,

        -- Dental coverage if Dental eligibility exists during this period
        CASE
            WHEN den_elig.member_bk IS NOT NULL THEN 'Yes'
            ELSE cb.dental_coverage
        END AS dental_coverage,

        -- Drug coverage if Medical or Pharmacy eligibility exists
        CASE
            WHEN drug_elig.member_bk IS NOT NULL THEN 'Yes'
            ELSE cb.drug_coverage
        END AS drug_coverage,

        cb.has_medical_cob,
        cb.medical_cob_order,
        cb.has_dental_cob,
        cb.dental_cob_order,
        cb.has_drug_cob,
        cb.drug_cob_order,
        cb.medical_two_blues,
        cb.dental_two_blues,
        cb.drug_two_blues,
        cb.medical_carrier_id,
        cb.dental_carrier_id

    FROM coverage_base cb

    -- Check for Medical eligibility
    LEFT JOIN {{ ref('current_member_eligibility') }} med_elig
        ON cb.source = med_elig.source
        AND cb.member_bk = med_elig.member_bk
        AND med_elig.eligibility_ind = 'Y'
        AND med_elig.product_category_bk = 'M'
        AND cb.effective_date BETWEEN med_elig.elig_eff_date AND med_elig.elig_term_date

    -- Check for Dental eligibility
    LEFT JOIN {{ ref('current_member_eligibility') }} den_elig
        ON cb.source = den_elig.source
        AND cb.member_bk = den_elig.member_bk
        AND den_elig.eligibility_ind = 'Y'
        AND den_elig.product_category_bk = 'D'
        AND cb.effective_date BETWEEN den_elig.elig_eff_date AND den_elig.elig_term_date

    -- Check for Drug eligibility (Medical 'M' or Pharmacy 'R')
    LEFT JOIN {{ ref('current_member_eligibility') }} drug_elig
        ON cb.source = drug_elig.source
        AND cb.member_bk = drug_elig.member_bk
        AND drug_elig.eligibility_ind = 'Y'
        AND drug_elig.product_category_bk IN ('M', 'R')
        AND cb.effective_date BETWEEN drug_elig.elig_eff_date AND drug_elig.elig_term_date
),

-- ============================================================================
-- CTE 7: Join member demographics
-- ============================================================================
with_demographics AS (
    SELECT
        we.source,
        we.member_bk,
        we.effective_date,
        we.end_date,

        -- Demographics
        grp.group_id,
        sub.subscriber_id,
        mem.member_suffix,
        mem.member_first_name,
        mem.edp_record_source,

        -- Coverage flags
        we.medical_coverage,
        we.dental_coverage,
        we.drug_coverage,
        we.has_medical_cob,
        we.medical_cob_order,
        we.has_dental_cob,
        we.dental_cob_order,
        we.has_drug_cob,
        we.drug_cob_order,
        we.medical_two_blues,
        we.dental_two_blues,
        we.drug_two_blues,
        we.medical_carrier_id,
        we.dental_carrier_id

    FROM with_eligibility we

    INNER JOIN {{ ref('current_member') }} mem
        ON we.source = mem.source
        AND we.member_bk = mem.member_bk

    INNER JOIN {{ ref('current_subscriber') }} sub
        ON mem.source = sub.source
        AND mem.subscriber_bk = sub.subscriber_bk

    INNER JOIN {{ ref('current_group') }} grp
        ON mem.source = grp.source
        AND mem.group_bk = grp.group_bk
),

-- ============================================================================
-- CTE 8: Apply Primary COB Rules for Medical and Drug
-- ============================================================================
primary_medical_cob AS (
    SELECT
        wd.source,
        wd.member_bk,
        wd.effective_date,
        wd.end_date,
        wd.group_id,
        wd.subscriber_id,
        wd.member_suffix,
        wd.member_first_name,
        wd.edp_record_source,
        wd.medical_coverage,
        wd.dental_coverage,
        wd.drug_coverage,

        -- Medical COB: Set to Primary if COB record exists
        CASE
            WHEN cob.member_bk IS NOT NULL AND wd.medical_coverage = 'Yes' THEN 'Yes'
            ELSE wd.has_medical_cob
        END AS has_medical_cob,

        CASE
            WHEN cob.member_bk IS NOT NULL AND wd.medical_coverage = 'Yes' THEN 'Primary'
            ELSE wd.medical_cob_order
        END AS medical_cob_order,

        -- Drug COB: Set to Primary (medical COB affects drug)
        CASE
            WHEN cob.member_bk IS NOT NULL AND wd.drug_coverage = 'Yes' THEN 'Yes'
            ELSE wd.has_drug_cob
        END AS has_drug_cob,

        CASE
            WHEN cob.member_bk IS NOT NULL AND wd.drug_coverage = 'Yes' THEN 'Primary'
            ELSE wd.drug_cob_order
        END AS drug_cob_order,

        -- Two Blues detection for Medical
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE wd.medical_two_blues
        END AS medical_two_blues,

        -- Two Blues detection for Drug
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE wd.drug_two_blues
        END AS drug_two_blues,

        -- Carrier ID
        COALESCE(TRIM(cob.coverage_id), wd.medical_carrier_id) AS medical_carrier_id,

        -- Dental (unchanged in this step)
        wd.has_dental_cob,
        wd.dental_cob_order,
        wd.dental_two_blues,
        wd.dental_carrier_id

    FROM with_demographics wd

    LEFT JOIN {{ ref('current_member_cob') }} cob
        ON wd.source = cob.source
        AND wd.member_bk = cob.member_bk
        AND wd.medical_coverage = 'Yes'
        AND cob.insurance_order <> 'U'  -- Not Unknown
        AND cob.insurance_type <> 'D'   -- Not Dental-only
        AND wd.effective_date BETWEEN cob.cob_eff_date AND cob.cob_term_date

    -- Exclude Medicare Part D primary codes
    LEFT JOIN {{ ref('seed_cob_medicare_part_d_primary') }} medicare_primary
        ON TRIM(cob.coverage_id) = medicare_primary.mcre_id

    -- Two Blues detection
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} two_blues
        ON TRIM(cob.coverage_id) = two_blues.mcre_id

    WHERE medicare_primary.mcre_id IS NULL  -- Exclude Medicare Part D primary
),

-- ============================================================================
-- CTE 9: Apply Primary COB Rules for Dental
-- ============================================================================
primary_dental_cob AS (
    SELECT
        pmc.source,
        pmc.member_bk,
        pmc.effective_date,
        pmc.end_date,
        pmc.group_id,
        pmc.subscriber_id,
        pmc.member_suffix,
        pmc.member_first_name,
        pmc.edp_record_source,
        pmc.medical_coverage,
        pmc.dental_coverage,
        pmc.drug_coverage,
        pmc.has_medical_cob,
        pmc.medical_cob_order,
        pmc.has_drug_cob,
        pmc.drug_cob_order,
        pmc.medical_two_blues,
        pmc.drug_two_blues,
        pmc.medical_carrier_id,

        -- Dental COB: Set to Primary if dental COB record exists
        CASE
            WHEN cob.member_bk IS NOT NULL AND pmc.dental_coverage = 'Yes' THEN 'Yes'
            ELSE pmc.has_dental_cob
        END AS has_dental_cob,

        CASE
            WHEN cob.member_bk IS NOT NULL AND pmc.dental_coverage = 'Yes' THEN 'Primary'
            ELSE pmc.dental_cob_order
        END AS dental_cob_order,

        -- Two Blues detection for Dental
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE pmc.dental_two_blues
        END AS dental_two_blues,

        -- Dental Carrier ID
        COALESCE(TRIM(cob.coverage_id), pmc.dental_carrier_id) AS dental_carrier_id

    FROM primary_medical_cob pmc

    LEFT JOIN {{ ref('current_member_cob') }} cob
        ON pmc.source = cob.source
        AND pmc.member_bk = cob.member_bk
        AND pmc.dental_coverage = 'Yes'
        AND cob.insurance_order <> 'U'  -- Not Unknown
        AND cob.insurance_type = 'D'    -- Dental type
        AND pmc.effective_date BETWEEN cob.cob_eff_date AND cob.cob_term_date

    -- Exclude Medicare Part D codes (not relevant for dental but check anyway)
    LEFT JOIN {{ ref('seed_cob_medicare_part_d_primary') }} medicare_primary
        ON TRIM(cob.coverage_id) = medicare_primary.mcre_id

    -- Two Blues detection
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} two_blues
        ON TRIM(cob.coverage_id) = two_blues.mcre_id

    WHERE medicare_primary.mcre_id IS NULL
),

-- ============================================================================
-- CTE 10: Override to Secondary COB for Medical and Drug
-- ============================================================================
secondary_medical_cob AS (
    SELECT
        pdc.source,
        pdc.member_bk,
        pdc.effective_date,
        pdc.end_date,
        pdc.group_id,
        pdc.subscriber_id,
        pdc.member_suffix,
        pdc.member_first_name,
        pdc.edp_record_source,
        pdc.medical_coverage,
        pdc.dental_coverage,
        pdc.drug_coverage,
        pdc.has_dental_cob,
        pdc.dental_cob_order,
        pdc.dental_two_blues,
        pdc.dental_carrier_id,

        -- Medical COB: Override to Secondary if insurance_order = 'P'
        pdc.has_medical_cob, -- Keep as 'Yes'
        CASE
            WHEN cob.member_bk IS NOT NULL THEN 'Secondary'
            ELSE pdc.medical_cob_order
        END AS medical_cob_order,

        -- Drug COB: Override to Secondary
        pdc.has_drug_cob,
        CASE
            WHEN cob.member_bk IS NOT NULL THEN 'Secondary'
            ELSE pdc.drug_cob_order
        END AS drug_cob_order,

        -- Update Two Blues flags
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE pdc.medical_two_blues
        END AS medical_two_blues,

        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE pdc.drug_two_blues
        END AS drug_two_blues,

        -- Update carrier ID
        COALESCE(TRIM(cob.coverage_id), pdc.medical_carrier_id) AS medical_carrier_id

    FROM primary_dental_cob pdc

    LEFT JOIN {{ ref('current_member_cob') }} cob
        ON pdc.source = cob.source
        AND pdc.member_bk = cob.member_bk
        AND pdc.medical_coverage = 'Yes'
        AND cob.insurance_order = 'P'   -- BCI is secondary (other is primary)
        AND cob.insurance_type <> 'D'   -- Not Dental
        AND pdc.effective_date BETWEEN cob.cob_eff_date AND cob.cob_term_date

    -- Exclude Medicare Part D secondary codes
    LEFT JOIN {{ ref('seed_cob_medicare_part_d_secondary') }} medicare_secondary
        ON TRIM(cob.coverage_id) = medicare_secondary.mcre_id

    -- Two Blues detection
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} two_blues
        ON TRIM(cob.coverage_id) = two_blues.mcre_id

    WHERE medicare_secondary.mcre_id IS NULL
),

-- ============================================================================
-- CTE 11: Override to Secondary COB for Dental
-- ============================================================================
secondary_dental_cob AS (
    SELECT
        smc.source,
        smc.member_bk,
        smc.effective_date,
        smc.end_date,
        smc.group_id,
        smc.subscriber_id,
        smc.member_suffix,
        smc.member_first_name,
        smc.edp_record_source,
        smc.medical_coverage,
        smc.dental_coverage,
        smc.drug_coverage,
        smc.has_medical_cob,
        smc.medical_cob_order,
        smc.has_drug_cob,
        smc.drug_cob_order,
        smc.medical_two_blues,
        smc.drug_two_blues,
        smc.medical_carrier_id,

        -- Dental COB: Override to Secondary
        smc.has_dental_cob,
        CASE
            WHEN cob.member_bk IS NOT NULL THEN 'Secondary'
            ELSE smc.dental_cob_order
        END AS dental_cob_order,

        -- Update Two Blues flag for dental
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE smc.dental_two_blues
        END AS dental_two_blues,

        -- Update dental carrier ID
        COALESCE(TRIM(cob.coverage_id), smc.dental_carrier_id) AS dental_carrier_id

    FROM secondary_medical_cob smc

    LEFT JOIN {{ ref('current_member_cob') }} cob
        ON smc.source = cob.source
        AND smc.member_bk = cob.member_bk
        AND smc.dental_coverage = 'Yes'
        AND cob.insurance_order = 'P'   -- BCI is secondary
        AND cob.insurance_type = 'D'    -- Dental
        AND smc.effective_date BETWEEN cob.cob_eff_date AND cob.cob_term_date

    -- Exclude Medicare Part D codes
    LEFT JOIN {{ ref('seed_cob_medicare_part_d_secondary') }} medicare_secondary
        ON TRIM(cob.coverage_id) = medicare_secondary.mcre_id

    -- Two Blues detection
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} two_blues
        ON TRIM(cob.coverage_id) = two_blues.mcre_id

    WHERE medicare_secondary.mcre_id IS NULL
),

-- ============================================================================
-- CTE 12: Override to Tertiary COB for Medical and Drug
-- ============================================================================
tertiary_medical_cob AS (
    SELECT
        sdc.source,
        sdc.member_bk,
        sdc.effective_date,
        sdc.end_date,
        sdc.group_id,
        sdc.subscriber_id,
        sdc.member_suffix,
        sdc.member_first_name,
        sdc.edp_record_source,
        sdc.medical_coverage,
        sdc.dental_coverage,
        sdc.drug_coverage,
        sdc.has_dental_cob,
        sdc.dental_cob_order,
        sdc.dental_two_blues,
        sdc.dental_carrier_id,

        -- Medical COB: Override to Tertiary only if currently Secondary
        sdc.has_medical_cob,
        CASE
            WHEN cob.member_bk IS NOT NULL AND sdc.medical_cob_order = 'Secondary' THEN 'Tertiary'
            ELSE sdc.medical_cob_order
        END AS medical_cob_order,

        -- Drug COB: Override to Tertiary
        sdc.has_drug_cob,
        CASE
            WHEN cob.member_bk IS NOT NULL AND sdc.drug_cob_order = 'Secondary' THEN 'Tertiary'
            ELSE sdc.drug_cob_order
        END AS drug_cob_order,

        -- Update Two Blues flags
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE sdc.medical_two_blues
        END AS medical_two_blues,

        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE sdc.drug_two_blues
        END AS drug_two_blues,

        -- Update carrier ID
        COALESCE(TRIM(cob.coverage_id), sdc.medical_carrier_id) AS medical_carrier_id

    FROM secondary_dental_cob sdc

    LEFT JOIN {{ ref('current_member_cob') }} cob
        ON sdc.source = cob.source
        AND sdc.member_bk = cob.member_bk
        AND sdc.medical_coverage = 'Yes'
        AND cob.insurance_order = 'S'   -- BCI is tertiary
        AND cob.insurance_type <> 'D'   -- Not Dental
        AND sdc.effective_date BETWEEN cob.cob_eff_date AND cob.cob_term_date

    -- Exclude Medicare Part D codes
    LEFT JOIN {{ ref('seed_cob_medicare_part_d_secondary') }} medicare_secondary
        ON TRIM(cob.coverage_id) = medicare_secondary.mcre_id

    -- Two Blues detection
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} two_blues
        ON TRIM(cob.coverage_id) = two_blues.mcre_id

    WHERE medicare_secondary.mcre_id IS NULL
      AND sdc.medical_cob_order = 'Secondary' -- Only override if currently secondary
),

-- ============================================================================
-- CTE 13: Override to Tertiary COB for Dental
-- ============================================================================
tertiary_dental_cob AS (
    SELECT
        tmc.source,
        tmc.member_bk,
        tmc.effective_date,
        tmc.end_date,
        tmc.group_id,
        tmc.subscriber_id,
        tmc.member_suffix,
        tmc.member_first_name,
        tmc.edp_record_source,
        tmc.medical_coverage,
        tmc.dental_coverage,
        tmc.drug_coverage,
        tmc.has_medical_cob,
        tmc.medical_cob_order,
        tmc.has_drug_cob,
        tmc.drug_cob_order,
        tmc.medical_two_blues,
        tmc.drug_two_blues,
        tmc.medical_carrier_id,

        -- Dental COB: Override to Tertiary only if currently Secondary
        tmc.has_dental_cob,
        CASE
            WHEN cob.member_bk IS NOT NULL AND tmc.dental_cob_order = 'Secondary' THEN 'Tertiary'
            ELSE tmc.dental_cob_order
        END AS dental_cob_order,

        -- Update Two Blues flag
        CASE
            WHEN two_blues.mcre_id IS NOT NULL THEN 'Yes'
            ELSE tmc.dental_two_blues
        END AS dental_two_blues,

        -- Update carrier ID
        COALESCE(TRIM(cob.coverage_id), tmc.dental_carrier_id) AS dental_carrier_id

    FROM tertiary_medical_cob tmc

    LEFT JOIN {{ ref('current_member_cob') }} cob
        ON tmc.source = cob.source
        AND tmc.member_bk = cob.member_bk
        AND tmc.dental_coverage = 'Yes'
        AND cob.insurance_order = 'S'   -- BCI is tertiary
        AND cob.insurance_type = 'D'    -- Dental
        AND tmc.effective_date BETWEEN cob.cob_eff_date AND cob.cob_term_date

    -- Exclude Medicare Part D codes
    LEFT JOIN {{ ref('seed_cob_medicare_part_d_secondary') }} medicare_secondary
        ON TRIM(cob.coverage_id) = medicare_secondary.mcre_id

    -- Two Blues detection
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} two_blues
        ON TRIM(cob.coverage_id) = two_blues.mcre_id

    WHERE medicare_secondary.mcre_id IS NULL
      AND tmc.dental_cob_order = 'Secondary' -- Only override if currently secondary
),

-- ============================================================================
-- CTE 14: Apply drug coverage exclusion (no M or R eligibility)
-- ============================================================================
drug_exclusion AS (
    SELECT
        tdc.*,

        -- Override drug coverage if no M or R eligibility found
        CASE
            WHEN drug_elig.member_bk IS NULL THEN 'No'
            ELSE tdc.drug_coverage
        END AS drug_coverage_final,

        CASE
            WHEN drug_elig.member_bk IS NULL THEN 'No'
            ELSE tdc.has_drug_cob
        END AS has_drug_cob_final,

        CASE
            WHEN drug_elig.member_bk IS NULL THEN 'No'
            ELSE tdc.drug_cob_order
        END AS drug_cob_order_final

    FROM tertiary_dental_cob tdc

    -- Check if member has drug eligibility during this period
    LEFT JOIN (
        SELECT DISTINCT
            source,
            member_bk,
            elig_eff_date,
            elig_term_date
        FROM {{ ref('current_member_eligibility') }}
        WHERE product_category_bk IN ('M', 'R')
          AND eligibility_ind = 'Y'
    ) drug_elig
        ON tdc.source = drug_elig.source
        AND tdc.member_bk = drug_elig.member_bk
        AND tdc.effective_date BETWEEN drug_elig.elig_eff_date AND drug_elig.elig_term_date
),

-- ============================================================================
-- CTE 15: Calculate indicator flags based on final COB order
-- ============================================================================
with_indicators AS (
    SELECT
        de.source,
        de.member_bk,
        de.effective_date,
        de.end_date,
        de.group_id,
        de.subscriber_id,
        de.member_suffix,
        de.member_first_name,
        de.edp_record_source,

        -- Coverage flags
        de.medical_coverage,
        de.dental_coverage,
        de.drug_coverage_final AS drug_coverage,

        -- Medical COB
        de.has_medical_cob,
        de.medical_cob_order,
        CASE WHEN de.medical_cob_order = 'Primary' THEN 'Yes' ELSE 'No' END AS medical_is_bci_primary,
        CASE WHEN de.medical_cob_order = 'Secondary' THEN 'Yes' ELSE 'No' END AS medical_is_bci_secondary,
        CASE WHEN de.medical_cob_order = 'Tertiary' THEN 'Yes' ELSE 'No' END AS medical_is_bci_tertiary,
        de.medical_carrier_id,
        de.medical_two_blues,

        -- Dental COB
        de.has_dental_cob,
        de.dental_cob_order,
        CASE WHEN de.dental_cob_order = 'Primary' THEN 'Yes' ELSE 'No' END AS dental_is_bci_primary,
        CASE WHEN de.dental_cob_order = 'Secondary' THEN 'Yes' ELSE 'No' END AS dental_is_bci_secondary,
        CASE WHEN de.dental_cob_order = 'Tertiary' THEN 'Yes' ELSE 'No' END AS dental_is_bci_tertiary,
        de.dental_carrier_id,
        de.dental_two_blues,

        -- Drug COB
        de.has_drug_cob_final AS has_drug_cob,
        de.drug_cob_order_final AS drug_cob_order,
        CASE WHEN de.drug_cob_order_final = 'Primary' THEN 'Yes' ELSE 'No' END AS drug_is_bci_primary,
        CASE WHEN de.drug_cob_order_final = 'Secondary' THEN 'Yes' ELSE 'No' END AS drug_is_bci_secondary,
        CASE WHEN de.drug_cob_order_final = 'Tertiary' THEN 'Yes' ELSE 'No' END AS drug_is_bci_tertiary,
        de.drug_two_blues

    FROM drug_exclusion de
),

-- ============================================================================
-- CTE 16: Filter out invalid records
-- ============================================================================
filtered AS (
    SELECT *
    FROM with_indicators
    WHERE NOT (
        -- Remove records with no coverage at all
        medical_coverage = 'No'
        AND dental_coverage = 'No'
        AND drug_coverage = 'No'
    )
),

-- ============================================================================
-- CTE 17: Add member hub key and final metadata
-- ============================================================================
final AS (
    SELECT
        -- Hub key
        h_mem.member_hk,

        -- Business keys
        f.source,
        f.member_bk,

        -- Effectivity dates
        f.effective_date,
        f.end_date,
        CASE WHEN f.end_date = '9999-12-31' THEN TRUE ELSE FALSE END AS is_current,

        -- Member demographics
        f.group_id,
        f.subscriber_id,
        f.member_suffix,
        f.member_first_name,

        -- Medical COB attributes
        f.medical_coverage,
        f.has_medical_cob,
        f.medical_cob_order,
        f.medical_is_bci_primary,
        f.medical_is_bci_secondary,
        f.medical_is_bci_tertiary,
        f.medical_carrier_id,
        f.medical_two_blues,

        -- Dental COB attributes
        f.dental_coverage,
        f.has_dental_cob,
        f.dental_cob_order,
        f.dental_is_bci_primary,
        f.dental_is_bci_secondary,
        f.dental_is_bci_tertiary,
        f.dental_carrier_id,
        f.dental_two_blues,

        -- Drug COB attributes
        f.drug_coverage,
        f.has_drug_cob,
        f.drug_cob_order,
        f.drug_is_bci_primary,
        f.drug_is_bci_secondary,
        f.drug_is_bci_tertiary,
        f.drug_two_blues,

        -- Metadata
        CURRENT_TIMESTAMP() AS load_date,
        f.edp_record_source AS record_source,

        -- Hash diff for change detection
        {{ dbt_utils.generate_surrogate_key([
            'f.medical_coverage',
            'f.has_medical_cob',
            'f.medical_cob_order',
            'f.medical_carrier_id',
            'f.medical_two_blues',
            'f.dental_coverage',
            'f.has_dental_cob',
            'f.dental_cob_order',
            'f.dental_carrier_id',
            'f.dental_two_blues',
            'f.drug_coverage',
            'f.has_drug_cob',
            'f.drug_cob_order',
            'f.drug_two_blues'
        ]) }} AS hash_diff

    FROM filtered f

    -- Join to member hub to get surrogate key
    INNER JOIN {{ ref('h_member') }} h_mem
        ON f.source = h_mem.source
        AND f.member_bk = h_mem.member_bk
)

-- ============================================================================
-- Final SELECT
-- ============================================================================
SELECT * FROM final
