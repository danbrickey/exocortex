---
title: "PCP Attribution Logic Guide"
document_type: "logic_guide"
industry_vertical: "Healthcare Payer"
business_domain: ["membership", "provider", "quality-measures", "care-coordination"]
edp_layer: "curation"
technical_topics: ["pcp-attribution", "primary-care-provider", "effectivity-satellite", "data-vault-2.0", "claims-analysis"]
audience: ["executive-leadership", "management-product", "business-analyst", "engineering"]
status: "draft"
last_updated: "2025-10-30"
version: "1.0"
author: "Dan Brickey"
description: "Automated assignment of members to Primary Care Providers based on claims utilization patterns analyzed over 18-month evaluation windows."
related_docs:
  - "../cob_profile/member_cob_profile_business_rules.md"
  - "../member_person/member_person_business_rules.md"
model_name: "ces_member_pcp_attribution"
legacy_source: "HDSVault.biz.PCPAttribution_02_* (12 staging tables + views)"
source_code_type: "dbt"
---

# PCP Attribution – Logic Guide

## Executive Summary

The PCP Attribution system ensures members receive coordinated care by automatically assigning them to Primary Care Providers based on actual utilization rather than self-reported preferences. The system analyzes 18 months of medical claims to identify which clinic each member visits most frequently, creating attribution assignments that drive quality reporting for HEDIS and Star Ratings programs. These assignments ensure regulatory compliance for network adequacy requirements, enable care managers to coordinate with the correct providers, and support value-based care contracts by establishing clear accountability. The system recalculates assignments periodically to maintain accuracy as members' healthcare relationships evolve over time.

## Management Overview

- **Automated Provider Assignment**: Eliminates manual tracking by analyzing actual claims data to assign members to the clinic they visit most frequently, ensuring assignments reflect real care relationships rather than enrollment records that may be outdated or inaccurate.

- **Quality Program Enablement**: Attribution drives accountability for HEDIS measures, Star Ratings, and value-based care contracts by defining which provider is responsible for each member's preventive care, chronic disease management, and quality outcomes.

- **Care Coordination Support**: Care managers, case managers, and utilization review teams rely on these assignments to direct member outreach, coordinate transitions of care, and collaborate with the appropriate primary care practice for high-risk member interventions.

- **Network Adequacy Compliance**: State and federal regulators require proof that members have access to and established relationships with primary care providers, making this system critical for demonstrating network adequacy and identifying members who need outreach.

- **18-Month Evaluation Window**: The lookback period balances capturing enough utilization data to identify meaningful patterns while remaining current enough to reflect members' active care relationships, evaluated monthly or quarterly based on business needs.

- **Clinic-Level Attribution**: Members are attributed to practice groups (Tax ID) rather than individual physicians, recognizing that care coordination happens at the clinic level and members often see multiple providers within the same practice.

- **Historical Time Series**: The system maintains complete attribution history with effectivity periods, enabling point-in-time queries to understand which provider was attributed when specific services occurred, supporting retrospective quality reporting and utilization analysis.

- **Gap Identification**: Members eligible for attribution but with zero primary care visits receive explicit null attribution records, enabling targeted outreach campaigns for members who haven't established primary care relationships.

## Analyst Detail

### 5.1 Key Business Rules

**Evaluation Window**: When calculating attribution on any `current_eval_date`, the system examines claims from `current_eval_date - 18 months` (low_date) through `current_eval_date` (high_date), capturing sufficient utilization history while remaining current.

**Member Eligibility**: When `current_member_eligibility.eligibility_ind = 'Y'` AND `product_category_bk IN ('M', 'MR')` AND `ces_member_cob_profile.medical_is_bci_primary = true` AND eligibility period overlaps evaluation window, then member qualifies for attribution, except when no medical eligibility exists during the entire window.

**Provider Eligibility**: When `current_provider_network_relational.pcp_indicator = 'Y'` OR (`current_provider.provider_specialty` appears in specialty seed AND `provider_entity = 'P'` AND `provider_type NOT IN ('GOVH', 'HOSP', 'INDH', 'PUBH', 'TPLH')`), then provider qualifies for attribution, with PCP designation taking priority over specialist status if provider qualifies both ways.

**E&M Visit Identification**: When `current_claim_medical_header.claim_status IN ('02', '91')` AND `current_claim_medical_line.place_of_service_id != '20'` AND (procedure code exists in `seed_pcp_attribution_cms_rvu` OR procedure code exists in `seed_pcp_attribution_bihc_codes`), then claim line counts as Evaluation & Management visit toward attribution.

**Visit Counting**: When aggregating claims by member-provider-evaluation date, count distinct combinations of `CONCAT(provider_bk, '|', service_from_date, '|', member_bk)`, ensuring same-day visits to same provider count as one visit regardless of claim line items or procedures performed.

**Clinic-Level Aggregation**: When multiple providers share `current_provider_affiliation.tax_id` (group affiliation), aggregate visits at Tax ID level using `COALESCE(group_provider.tax_id, individual_provider.tax_id)`, selecting one representative provider per clinic based on highest visit counts within that group.

**Attribution Ranking**: When ranking clinics for attribution, sort by `CASE WHEN pcp_indicator = 'PCP' THEN 1 ELSE 2 END`, then `clinic_visit_count DESC`, then `clinic_last_visit_date DESC`, then `clinic_rvu_total DESC`, then `tax_id_group_then_individual ASC`, assigning member to #1 ranked clinic only.

**Effectivity Period Calculation**: When attribution is calculated, set `effective_date = current_eval_date` and `end_date = LEAD(current_eval_date) OVER (PARTITION BY member_bk ORDER BY current_eval_date)` defaulting to `9999-12-31` if no subsequent evaluation exists, except when attribution changes at next evaluation which closes current period.

### 5.2 Data Flow & Transformations

The attribution pipeline consists of four sequential transformations. First, **provider eligibility** (`cs_provider_pcp_eligibility`) identifies which providers can receive attribution by joining `current_provider` to `current_provider_network_relational` for PCP-designated providers and separately to `seed_pcp_attribution_provider_specialty` for eligible specialists. The model resolves group-level Tax IDs through `current_provider_affiliation` using a coalesce pattern, cross-joining to `seed_pcp_attribution_evaluation_dates` to generate eligibility snapshots at each evaluation period:

```sql
-- Provider eligibility example: Resolve clinic-level Tax ID
SELECT
    p.source,
    p.provider_bk,
    p.npi,
    ed.current_eval_date,
    -- Prioritize group Tax ID over individual Tax ID
    COALESCE(pg.tax_id, p.tax_id) AS tax_id_group_then_individual,
    CASE WHEN pn.pcp_indicator = 'Y' THEN 'PCP' ELSE 'Specialist' END AS pcp_indicator
FROM current_provider p
LEFT JOIN current_provider_affiliation aff
    ON aff.provider_bk = p.provider_bk AND aff.affiliation_entity_bk = 'G'
LEFT JOIN current_provider pg
    ON pg.provider_bk = aff.related_provider_bk
CROSS JOIN evaluation_dates ed
```

Second, **member eligibility** (`cs_member_pcp_attribution_eligibility`) filters to members with active medical eligibility by joining `current_member_eligibility` to evaluation dates where eligibility periods overlap the 18-month window, then inner-joining to `ces_member_cob_profile` to ensure BCI is primary payer. The model geocodes member addresses through `current_subscriber_address` joined to `seed_zip_code_melissa` for FIPS codes, enriching with constituent IDs from `v_member_person_lenient` for cross-system identification.

Third, **visit aggregation** (`cs_member_provider_visit_aggregation`) processes claims by joining `current_claim_medical_header` to eligible members and providers where service dates fall within evaluation windows. The transformation identifies E&M visits by checking if procedure codes from `current_claim_medical_line` or `current_claim_medical_procedure` exist in either `seed_pcp_attribution_cms_rvu` or `seed_pcp_attribution_bihc_codes`. Visit counting uses distinct concatenation of provider, date, and member:

```sql
-- Visit counting: Unique visits per member-provider-evaluation
SELECT
    member_bk,
    provider_bk,
    current_eval_date,
    -- Count unique visit dates (not claim lines)
    COUNT(DISTINCT CONCAT(provider_bk, '|', service_from_date, '|', member_bk)) AS unique_visit_count,
    MAX(service_from_date) AS last_visit_date,
    SUM(rvu.work_rvu + rvu.pe_rvu + rvu.mp_rvu) AS rvu_total
FROM claim_procedures
WHERE is_em_visit = TRUE
GROUP BY member_bk, provider_bk, current_eval_date
```

Finally, **attribution assignment** (`ces_member_pcp_attribution`) aggregates visit data at clinic level, ranks clinics using window functions, and calculates effectivity periods using LEAD to determine when the next attribution begins.

### 5.3 Validation & Quality Checks

**Eligibility Grain Check**: Verify `cs_member_pcp_attribution_eligibility` produces one row per member per evaluation date using `SELECT member_bk, current_eval_date, COUNT(*) FROM table GROUP BY member_bk, current_eval_date HAVING COUNT(*) > 1` – result should be empty.

**Provider Deduplication Check**: Confirm no provider appears as both PCP and Specialist for same evaluation in `cs_provider_pcp_eligibility` using `SELECT provider_bk, current_eval_date, COUNT(DISTINCT pcp_indicator) FROM table GROUP BY provider_bk, current_eval_date HAVING COUNT(DISTINCT pcp_indicator) > 1` – result should be empty.

**Visit Count Integrity**: Validate visit aggregation doesn't inflate counts by checking `cs_member_provider_visit_aggregation.unique_visit_count` equals distinct service dates per member-provider using direct claim query: `SELECT COUNT(DISTINCT service_from_date) FROM claims WHERE member_bk = X AND provider_bk = Y` must match aggregated value.

**Effectivity Gap Check**: Confirm no temporal gaps exist between attribution periods for active members using `SELECT member_bk FROM ces_member_pcp_attribution WHERE end_date + 1 != LEAD(effective_date) OVER (PARTITION BY member_bk ORDER BY effective_date)` – excludes members who became ineligible then re-eligible.

**Attribution Completeness**: Ensure every eligible member has exactly one attribution record (with visits) or one null attribution record (no visits) per evaluation period: `SELECT em.member_bk FROM cs_member_pcp_attribution_eligibility em LEFT JOIN ces_member_pcp_attribution a USING (member_bk, current_eval_date) WHERE a.member_bk IS NULL` should return zero rows.

### 5.4 Example Scenario

Consider member Sarah Johnson (member_bk = 'M123456') evaluated on 2024-05-01 with an 18-month lookback window (2022-11-01 to 2024-05-01). Sarah's eligibility record shows medical product category 'M' with continuous coverage, and her COB profile indicates BCI is primary payer, so she qualifies for attribution.

During the evaluation window, Sarah generated E&M claims with three provider organizations:

- **Canyon Family Clinic** (Tax ID 99-1111111): Dr. Martinez (NPI 1234567890, PCP-designated) had 6 distinct visit dates, most recent 2024-04-15, generating 15.2 total RVU
- **Boise Cardiology** (Tax ID 99-2222222): Dr. Patel (NPI 2345678901, Specialist) had 4 distinct visit dates, most recent 2024-03-10, generating 12.8 total RVU
- **Urgent Care Express** (Tax ID 99-3333333): Dr. Kim (NPI 3456789012, Specialist) had 2 distinct visit dates, most recent 2024-01-05, generating 6.0 total RVU

The `cs_member_provider_visit_aggregation` model produces three records for Sarah showing these aggregated visit patterns. The `ces_member_pcp_attribution` model then ranks these clinics:

```
Clinic Ranking for M123456:
1. Canyon Family (PCP indicator = 'PCP' [rank 1], 6 visits, last visit 2024-04-15, 15.2 RVU)
2. Boise Cardiology (PCP indicator = 'Specialist' [rank 2], 4 visits, last visit 2024-03-10, 12.8 RVU)
3. Urgent Care (PCP indicator = 'Specialist' [rank 2], 2 visits, last visit 2024-01-05, 6.0 RVU)
```

Canyon Family Clinic wins despite not having the highest RVU because PCP designation takes priority. The final output record for Sarah shows:
- `effective_date = 2024-05-01`
- `end_date = 2024-08-01` (next quarterly evaluation)
- `attributed_provider_bk = 'P123456'` (Dr. Martinez)
- `attributed_tax_id = '99-1111111'`
- `attributed_pcp_indicator = 'PCP'`
- `attribution_visit_count = 6`
- `is_current = false` (superseded by next evaluation)

## Engineering Reference

### 6.1 Technical Architecture

The PCP Attribution system implements a **four-stage dbt transformation pipeline** following Data Vault 2.0 computed satellite patterns. All models use incremental materialization with merge strategy, clustered on source and business keys for optimal query performance.

**Dependency chain**:
1. `seed_pcp_attribution_evaluation_dates` → defines evaluation periods
2. `cs_provider_pcp_eligibility` → depends on `current_provider`, `current_provider_affiliation`, `current_provider_network_relational`, `seed_pcp_attribution_provider_specialty`
3. `cs_member_pcp_attribution_eligibility` → depends on `current_member_eligibility`, `ces_member_cob_profile`, `seed_zip_code_melissa`, `seed_pcp_attribution_idaho_county`
4. `cs_member_provider_visit_aggregation` → depends on steps 2+3, plus `current_claim_medical_header`, `current_claim_medical_line`, `current_claim_medical_procedure`, `seed_pcp_attribution_cms_rvu`, `seed_pcp_attribution_bihc_codes`
5. `ces_member_pcp_attribution` → depends on steps 3+4, applies ranking and effectivity logic

**Reference data requirements**: Six seed files provide business-managed reference data refreshed quarterly or annually: evaluation dates, specialty codes, CMS RVU values, BIHC codes, Idaho service area counties, and zip code geocoding.

**Incremental processing**: All models filter to `current_eval_date > MAX(current_eval_date) FROM {{ this }}` when running incrementally, processing only new evaluation periods to minimize compute costs and runtime.

### 6.2 Critical Implementation Details

- **Incremental Logic**: Models use `materialized='incremental'` with `incremental_strategy='merge'` on unique keys combining source, business keys, and evaluation date. The `{% if is_incremental() %}` block filters evaluation dates to only process new periods beyond the existing maximum.

- **Join Strategy**: Provider-to-group affiliation uses LEFT JOIN (1:0..1 cardinality) with COALESCE fallback. Member-to-COB uses INNER JOIN (1:many filtered to 1:1 on date overlap). Claims-to-procedures uses INNER JOIN (1:many) with DISTINCT on concatenated keys for deduplication.

- **Filters**: Critical WHERE clauses include `claim_status IN ('02', '91')` excluding denied/pending claims, `place_of_service_id != '20'` excluding denied line items, `provider_type NOT IN ('GOVH', 'HOSP', ...)` excluding institutional providers, and date range checks ensuring service dates fall within `low_date` to `high_date` evaluation window.

- **Aggregations**: Visit counting uses `COUNT(DISTINCT CONCAT(...))` at provider level, then `SUM()` at clinic level after grouping by Tax ID. RVU totals use `SUM(work_rvu + pe_rvu + mp_rvu)` with COALESCE for nulls. Last visit uses `MAX(service_from_date)`.

- **Change Tracking**: Effectivity periods calculated using `LEAD(effective_date) OVER (PARTITION BY member_bk ORDER BY effective_date)` to identify next evaluation date. Hash diff column tracks attribution value changes: `hash_diff = hash(provider_npi, tax_id, pcp_indicator, visit_count, rvu_total)`.

- **Performance Considerations**: Models cluster on `source` and primary business key (`provider_bk` or `member_bk`) to optimize filtering and point-in-time lookups. Evaluation date cross joins can produce large intermediate results – mitigated by incremental processing filtering to new dates only.

### 6.3 Code Examples

**Complex Join Logic: Provider Group Affiliation with Tax ID Resolution**
```sql
-- Purpose: Resolve clinic-level Tax ID prioritizing group affiliation over individual
-- Critical: COALESCE ensures individual providers without groups still get attributed

SELECT
    p.source,
    p.provider_bk,
    p.npi,
    p.tax_id AS individual_tax_id,
    pg.tax_id AS group_tax_id,
    -- Use group Tax ID if provider is affiliated, otherwise individual Tax ID
    COALESCE(pg.tax_id, p.tax_id) AS tax_id_group_then_individual
FROM current_provider p

-- LEFT JOIN to affiliations (provider may not be in a group)
LEFT JOIN current_provider_affiliation aff
    ON aff.source = p.source
    AND aff.provider_bk = p.provider_bk
    AND aff.affiliation_entity_bk = 'G'  -- 'G' = Group entity type

-- LEFT JOIN to get the group provider's Tax ID
LEFT JOIN current_provider pg
    ON pg.source = aff.source
    AND pg.provider_bk = aff.related_provider_bk
```

**Critical Transformation: Clinic-Level Attribution Ranking**
```sql
-- Purpose: Apply multi-factor ranking logic to select attributed clinic per member
-- Critical: PCP designation wins over visit counts; must maintain deterministic sort

WITH highest_provider_per_clinic AS (
    -- First aggregate providers to clinic level by Tax ID
    SELECT
        member_bk,
        current_eval_date,
        tax_id_group_then_individual,
        SUM(unique_visit_count) AS clinic_visit_count,
        MAX(last_visit_date) AS clinic_last_visit_date,
        SUM(rvu_total) AS clinic_rvu_total,
        MAX(pcp_indicator) AS clinic_pcp_indicator,
        MAX(CASE WHEN provider_rank_within_clinic = 1 THEN provider_bk END) AS representative_provider_bk
    FROM provider_ranking_by_clinic
    GROUP BY member_bk, current_eval_date, tax_id_group_then_individual
)

SELECT
    member_bk,
    tax_id_group_then_individual,
    representative_provider_bk,
    -- Rank clinics for final attribution
    ROW_NUMBER() OVER (
        PARTITION BY member_bk, current_eval_date
        ORDER BY
            -- 1. PCP-designated clinics beat specialist clinics regardless of visit counts
            CASE WHEN clinic_pcp_indicator = 'PCP' THEN 1 ELSE 2 END,
            -- 2. Higher visit counts win
            clinic_visit_count DESC,
            -- 3. More recent last visit wins
            clinic_last_visit_date DESC,
            -- 4. Higher RVU total wins
            clinic_rvu_total DESC,
            -- 5. Alphabetical Tax ID for deterministic tie-breaking
            tax_id_group_then_individual
    ) AS clinic_rank
FROM highest_provider_per_clinic
```

**Incremental/Merge Logic: Effectivity Period Calculation**
```sql
-- Purpose: Calculate attribution effectivity periods with LEAD window function
-- Critical: Handles open-ended current periods and seamless transitions

SELECT
    source,
    member_bk,
    effective_date,
    -- End date is one day before next evaluation, or 9999-12-31 for current period
    COALESCE(
        LEAD(effective_date) OVER (
            PARTITION BY source, member_bk
            ORDER BY effective_date
        ),
        '9999-12-31'::DATE
    ) AS end_date,
    attributed_provider_bk,
    attribution_visit_count,
    -- Flag current attribution records
    CASE
        WHEN end_date = '9999-12-31'::DATE THEN TRUE
        ELSE FALSE
    END AS is_current
FROM attributed_pcp_per_eval
```

### 6.4 Common Issues & Troubleshooting

**Issue**: Duplicate member_bk values in `ces_member_pcp_attribution` for same effective_date
**Cause**: Multiple evaluation date records generated due to evaluation seed file having duplicate dates or timezone conversion creating date duplicates
**Resolution**: Query evaluation seed for duplicates: `SELECT current_eval_date, COUNT(*) FROM seed_pcp_attribution_evaluation_dates GROUP BY current_eval_date HAVING COUNT(*) > 1`. Remove duplicates and re-run affected evaluation dates with `dbt run --select ces_member_pcp_attribution --vars '{current_eval_date: "2024-05-01"}'`
**Prevention**: Add unique constraint on evaluation seed file and validate during seed refresh process

**Issue**: Visit counts appear inflated compared to claims system reports
**Cause**: CONCAT-based deduplication not handling claim line duplicates properly, or same claim processed multiple times in incremental load
**Resolution**: Validate claim grain using `SELECT claim_id, provider_bk, service_from_date, COUNT(*) FROM current_claim_medical_header GROUP BY 1,2,3 HAVING COUNT(*) > 1`. If duplicates exist, investigate upstream claim processing. Add additional deduplication in visit aggregation CTE.
**Prevention**: Implement data quality checks on claim header table ensuring one row per claim_id, or modify DISTINCT logic to use claim_id directly instead of concatenation

**Issue**: Members attributed to providers they never visited
**Cause**: Tax ID group affiliation incorrectly linking unrelated providers, or provider master data showing wrong Tax ID
**Resolution**: Query provider affiliation: `SELECT * FROM current_provider_affiliation WHERE provider_bk = 'P123'` and validate related_provider_bk points to correct group. Check `current_provider.tax_id` matches expected clinic. If incorrect, work with provider data team to correct master data and re-run attribution for affected evaluation dates.
**Prevention**: Implement provider master data validation checks ensuring Tax ID values are consistent within affiliation groups and match external network directory

**Issue**: Attribution effectivity periods have gaps (end_date + 1 != next effective_date)
**Cause**: Evaluation dates seed file missing expected monthly/quarterly entries, or member became ineligible then re-eligible
**Resolution**: Check evaluation seed: `SELECT current_eval_date, LEAD(current_eval_date) OVER (ORDER BY current_eval_date) AS next_eval FROM seed_pcp_attribution_evaluation_dates` and verify regular cadence. For member-specific gaps, query eligibility: `SELECT * FROM cs_member_pcp_attribution_eligibility WHERE member_bk = 'M123' ORDER BY current_eval_date` to confirm continuous eligibility.
**Prevention**: Document evaluation date schedule with business stakeholders and implement automated seed file generation based on calendar rules (e.g., first day of each quarter)

**Issue**: Members with known primary care visits showing null attribution
**Cause**: Claims not matching E&M criteria (procedure code not in CMS RVU or BIHC seed files), or provider not in eligible provider set due to missing PCP indicator or specialty code
**Resolution**: Query visit aggregation for member: `SELECT * FROM cs_member_provider_visit_aggregation WHERE member_bk = 'M123'`. If empty, check claim procedure codes: `SELECT DISTINCT procedure_code FROM current_claim_medical_line WHERE member_bk = 'M123'` and validate against `seed_pcp_attribution_cms_rvu`. Check provider eligibility: `SELECT * FROM cs_provider_pcp_eligibility WHERE provider_bk = 'P456'`.
**Prevention**: Quarterly review of CMS RVU seed file updates and annual review of specialty code seed with clinical operations to ensure all valid E&M codes and PCP specialties are included

**Issue**: Incremental runs not processing recent evaluation dates
**Cause**: Incremental filter `current_eval_date > MAX(current_eval_date)` using stale max value, or evaluation seed added dates out of chronological order
**Resolution**: Force full-refresh: `dbt run --select ces_member_pcp_attribution --full-refresh` or manually update existing table to remove future-dated records if they exist: `DELETE FROM ces_member_pcp_attribution WHERE effective_date > CURRENT_DATE`.
**Prevention**: Always add evaluation dates in chronological order to seed file, never backfill historical dates after processing newer dates. Consider adding data quality check to prevent out-of-order evaluation dates.

### 6.5 Testing & Validation

**Unit Test Scenarios**:

1. **Single provider, clear winner**: Member M123 with 10 visits to PCP provider P456, 2 visits to specialist P789. Expected: M123 attributed to P456 due to PCP designation and higher visit count.

2. **Specialist vs specialist, visit count matters**: Member M124 with 5 visits to specialist P111, 3 visits to specialist P222. Expected: M124 attributed to P111 due to higher visit count.

3. **Tie-breaking on last visit date**: Member M125 with 4 visits to PCP P333 (last visit 2024-03-01), 4 visits to PCP P444 (last visit 2024-04-01). Expected: M125 attributed to P444 due to more recent last visit.

4. **Group affiliation aggregation**: Member M126 with 3 visits to provider P555 (Tax ID 99-1111111), 2 visits to provider P556 (same Tax ID 99-1111111). Expected: M126 attributed to clinic 99-1111111 with 5 total visits, represented by P555 or P556.

5. **No qualifying visits**: Member M127 with medical eligibility and BCI primary, but zero E&M visits in window. Expected: M127 has record with null attributed_provider_bk, attribution_visit_count = 0.

**Data Quality Checks**:

```sql
-- Row counts: Attribution should not exceed eligibility
SELECT
    'Attribution records exceed eligible members' AS check_name,
    COUNT(DISTINCT member_bk) - (SELECT COUNT(*) FROM cs_member_pcp_attribution_eligibility WHERE current_eval_date = '2024-05-01') AS diff
FROM ces_member_pcp_attribution
WHERE effective_date = '2024-05-01';

-- Null checks: Current records should never have null effective_date
SELECT 'Null effective_date in current records' AS check_name, COUNT(*)
FROM ces_member_pcp_attribution
WHERE effective_date IS NULL OR end_date IS NULL;

-- Referential integrity: All attributed providers must exist in provider eligibility
SELECT 'Attributed to non-eligible provider' AS check_name, COUNT(*)
FROM ces_member_pcp_attribution a
LEFT JOIN cs_provider_pcp_eligibility p
    ON p.provider_bk = a.attributed_provider_bk
    AND p.current_eval_date = a.effective_date
WHERE a.attributed_provider_bk IS NOT NULL
  AND p.provider_bk IS NULL;

-- Business rule validation: PCP should never lose to specialist with fewer visits
SELECT 'PCP lost to specialist with fewer visits' AS check_name, COUNT(*)
FROM ces_member_pcp_attribution a
WHERE a.attributed_pcp_indicator = 'Specialist'
  AND EXISTS (
      SELECT 1 FROM cs_member_provider_visit_aggregation v
      WHERE v.member_bk = a.member_bk
        AND v.current_eval_date = a.effective_date
        AND v.pcp_indicator = 'PCP'
        AND v.unique_visit_count > a.attribution_visit_count
  );
```

**Regression Tests**: When modifying attribution logic, verify these scenarios maintain consistent results:
- Historical member M999 attributed to P1234 on 2023-01-01 should not change when re-running model for that evaluation date
- Member eligibility count for evaluation date 2024-01-01 should remain stable across re-runs
- Attribution distribution by PCP vs Specialist should not shift dramatically (>5%) without business rule changes

### 6.6 Dependencies & Risks

**Upstream Dependencies**:
- `ces_member_cob_profile` (SLA: Daily by 6 AM) – Critical for filtering to BCI primary members; if delayed/failed, member eligibility cannot calculate and entire pipeline blocks
- `current_claim_medical_header/line/procedure` (SLA: Daily by 5 AM) – Contains utilization data for visit aggregation; delays push attribution calculation start time
- `current_provider_network_relational` (SLA: Weekly Sunday 2 AM) – Provides PCP indicators; stale data causes incorrect provider eligibility (lags network changes)
- `seed_pcp_attribution_cms_rvu` (SLA: Annually January) – Defines E&M procedures; missing CMS annual updates causes valid visits to not count toward attribution
- `seed_pcp_attribution_evaluation_dates` (SLA: Manually managed) – Must be updated before each evaluation cycle; missing dates prevent new attribution calculations

**Downstream Impacts**:
- **Quality reporting dashboards** – HEDIS and Star Ratings reports join to `ces_member_pcp_attribution` using `is_current = true` flag; attribution failures cause blank provider assignments in quality scorecards
- **Care management workflows** – Case management system queries attribution daily to route member outreach; delays or errors cause outreach to go to wrong providers or fail to route
- **Provider performance reports** – Value-based care contract reporting aggregates quality measures by attributed provider; incorrect attribution shifts financial accountability to wrong clinics
- **Network adequacy reports** – Regulatory submissions count members by attributed provider; null attributions or errors cause network adequacy violations if thresholds not met

**Data Quality Risks**:
- **Tax ID changes mid-year** – Provider master data may show clinic Tax ID changes when practices are acquired or restructured; members could be attributed to old Tax ID no longer in network, appearing as unattributed
- **Claim reprocessing** – Claims with adjusted/corrected procedure codes after attribution runs can change visit counts; attribution becomes stale until next evaluation cycle
- **COB delays** – New members' COB profile may lag enrollment by 30-60 days; members eligible for attribution excluded until COB processes, causing temporary under-attribution
- **PCP indicator inconsistency** – Provider network contracts may designate provider as PCP in some products but not others; attribution uses cross-product indicator which may not match product-specific enrollment

**Performance Risks**:
- **Volume thresholds** – System tested with 500K members and 50K providers; scaling beyond 1M members may exceed memory limits during claim-to-member cross join without query optimization
- **Query timeout scenarios** – Full-refresh runs on `ces_member_pcp_attribution` scanning 18 months of claims for all members can exceed 60-minute timeout; requires incremental-only execution in production
- **Seed file growth** – CMS RVU seed file contains 10K+ procedure codes; annual additions could push join performance beyond acceptable limits without indexing strategy
- **Evaluation frequency increase** – Changing from quarterly to monthly evaluations triples record volume and compute cost; requires capacity planning and potential model optimization before implementation
