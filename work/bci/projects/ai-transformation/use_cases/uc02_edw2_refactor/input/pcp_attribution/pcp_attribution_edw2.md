---
title: "PCP Attribution Logic Guide"
document_type: "logic_guide"
industry_vertical: "Healthcare Payer"
business_domain: ["Provider Networks", "Care Management", "Quality Reporting"]
edp_layer: "business_vault"
technical_topics: ["Member Attribution", "Claims Analysis", "Provider Ranking", "RVU Weighting"]
audience: ["executive-leadership", "management-product", "business-analyst", "engineering"]
status: "draft"
last_updated: "2025-10-30"
version: "1.0"
author: "Dan Brickey"
description: "Claims-based PCP attribution logic that assigns members to primary care physicians using an 18-month evaluation window with visit frequency, RVU weighting, and specialty-based ranking."
related_docs:
  - "pcp_attribution_business_vault_recommendations.md"
model_name: "MemberPCPAttribution_02_Lookup"
legacy_source: "update_MemberPCPAttribution_02_Lookup and related procedures"
source_code_type: "SQL"
---

# PCP Attribution – Logic Guide

## Executive Summary

This logic determines which Primary Care Physician should be associated with each health plan member by analyzing their medical claims over an 18-month period. The system evaluates visit frequency, procedure complexity using CMS relative value units, and provider specialty to rank all physicians who treated the member. This attribution supports care coordination initiatives, enables accurate quality reporting to regulatory agencies, and helps identify gaps in primary care access across the Idaho service area. The final assignment prioritizes named PCP designations from enrollment records but falls back to claims-based attribution when those assignments are missing or invalid, ensuring every eligible member has an attributed provider for care management purposes.

### Key Terms

**RVU (Relative Value Unit)**: A CMS-assigned numeric weight representing the resources required for a medical procedure; higher RVU procedures indicate more complex care and factor more heavily into attribution rankings.

**Claims-Based Attribution**: A methodology that assigns members to providers based on actual utilization patterns rather than enrollment designations, using visit counts and procedure weights to determine the strongest provider relationship.

**Constituent ID**: An enterprise-wide unique identifier that links a member across multiple source systems and time periods for consistent attribution across system boundaries.

## Management Overview

- **Use Cases**: Supports care management team assignments, provider performance scorecards, quality measure attribution for HEDIS and Stars reporting, network adequacy analysis, and risk adjustment workflows that require member-provider relationships

- **Operational Impact**: Determines which providers receive care gap notifications for specific members, influences panel size calculations for capacity planning, and drives downstream analytics that measure provider effectiveness and member outcomes across care management programs

- **Data Scope**: Covers all medically eligible members with primary payer status in Idaho and adjacent counties, evaluating professional claims over a rolling 18-month window with refresh cycles aligned to quarterly quality reporting periods; excludes facility-only providers and non-primary specialties

- **Decision Support**: Enables care managers to identify which PCP should be contacted for member outreach, helps network teams assess provider panel composition, supports medical directors in evaluating specialty referral patterns, and provides actuarial teams with accurate provider linkages for trend analysis

- **Timing & Frequency**: Runs as part of quarterly business vault refresh cycle, with evaluation dates configured in the NonDV_01_Dates control table; the 18-month lookback ensures sufficient claim volume for stable attribution while remaining responsive to recent care patterns

- **Dependencies**: Requires completed Data Vault loads for provider networks, member eligibility, and claim headers; relies on current CMS RVU reference files, specialty designation tables, and geographic reference data for Idaho service area; delayed or incomplete upstream data will cause members to be excluded from attribution

- **Quality Controls**: Validates that all attributed members have primary medical coverage and reside within service area, ensures provider assignments only include active network participants with valid NPIs, detects duplicate attributions through business key uniqueness checks, and tracks row counts at each transformation stage for data lineage verification

- **Known Limitations**: Attribution logic does not account for telehealth-only relationships or out-of-area specialists, may not capture very recent enrollment changes due to 18-month historical window, excludes members with fewer than one eligible claim in the evaluation period, and does not differentiate between preventive and acute care visits when calculating provider rankings

## Analyst Detail

### Key Business Rules

**Provider Eligibility - PCP Designation**: When `NWPR_PCP_IND = 'Y'` in the provider network relationship table AND provider is active during the evaluation window (`NWPR_EFF_DT <= HighDate` AND `NWPR_TERM_DT >= LowDate`), then include provider as PCP type with `PCPIndicator = 'PCP'`, except when provider entity type excludes individual practitioners.

**Provider Eligibility - Specialist Designation**: When `PRCF_MCTR_SPEC` matches a code in `ref.PCPAttribution_02_ProviderSpecialty` AND `PRPR_MCTR_PRTY NOT IN ('GOVH','HOSP','INDH','PUBH','TPLH')` AND `PRPR_ENTITY = 'P'`, then include provider as specialist type with `PCPIndicator = 'Specialist'`, except when no matching specialty code exists.

**Member Eligibility - Active Medical Coverage**: When `cspd_cat = 'M'` AND `mepe_elig_ind = 'Y'` AND `mepe_eff_dt <= HighDate` AND `mepe_term_dt >= HighDate` AND `mepe_term_dt <> mepe_eff_dt`, then member qualifies for attribution evaluation, except when COB indicates member is not primary payer (`MedicalCOBOrder <> 'Primary'`).

**Geographic Service Area Filter**: When member's ZIP code (from current address or address history at evaluation date) geocodes to a FIPS county code that exists in `ref.PCPAttribution_02_IdahoAdjacentCounty`, then include member in attribution population, except when ZIP code cannot be geocoded or no county match exists.

**Claim Filtering - Attribution Eligible**: When `clcl_cur_sts IN ('02', '91')` AND `clcl_low_svc_dt BETWEEN LowDate AND HighDate` AND provider exists in eligible provider set AND member exists in eligible member set, then include claim in attribution analysis, except when claim status indicates denied, pending, or voided.

**PCP Type Ranking - High Engagement**: When `PCPIndicator = 'PCP'` AND `(RVUPCP / RVUmem) >= 0.10`, then assign `TypeRank = 1` (highest priority), except when RVU totals are null or zero.

**PCP Type Ranking - Low Engagement**: When `PCPIndicator = 'PCP'` AND `(RVUPCP / RVUmem) < 0.10`, then assign `TypeRank = 3` (lowest priority), except when specialist has higher visit count.

**Final PCP Selection - Named vs Calculated**: When member has valid named PCP in `r_MemberPCP_Lookup` effective 14 days after `CurrentEvalDt` AND named PCP is not 'unassigned' or 'BCNRQ', then use `NamedPCP` as `CombinedPCP`, except when named PCP is missing or invalid, in which case use `AttributedPCP` from claims-based calculation.

### Data Flow & Transformations

The attribution process begins by establishing an 18-month evaluation window in `PCPAttribution_02_NonDV_01_Dates`, which stores `CurrentEvalDt`, `LowDate`, and `HighDate` parameters. The system then builds a comprehensive provider universe by combining two provider populations: PCPs designated through network relationships (`NWPR_PCP_IND = 'Y'`) and specialists matched through specialty codes. For each provider, the logic resolves their Tax ID by preferring group TIN when available, falling back to individual TIN when no group relationship exists.

```sql
-- Example: Provider TIN resolution logic
SELECT
  ProviderID,
  CASE
    WHEN ISNULL(v_provider_combined_current2.mctn_id, '') = ''
      THEN v_provider_combined_current.mctn_id
    ELSE v_provider_combined_current2.mctn_id
  END AS TaxID_GroupThenIndividual
FROM v_provider_combined_current
LEFT JOIN v_providerentityrelationshipextended_combined_current
  ON bkcc_provider AND prpr_id AND prer_prpr_entity = 'G'
LEFT JOIN v_provider_combined_current AS v_provider_combined_current2
  ON group_provider_id
```

Member eligibility determination involves multiple validation steps. The process identifies members with active medical coverage, verifies primary payer status through COB lookups, and enriches member records with geographic data. Address history is reconstructed from audit tables using window functions to establish effective date ranges, allowing the system to determine member ZIP code at the evaluation date even when addresses changed during the lookback period.

```sql
-- Example: Member address at evaluation date
SELECT
  m.meme_ck,
  ISNULL(ah.ZipCode, LEFT(LTRIM(current.sbad_zip), 5)) AS ZipCode
FROM PCPAttribution_02_NonDV_04_MemberInfo m
LEFT JOIN PCPAttribution_02_NonDV_04a_MemberAddressHistory ah
  ON m.SourceCode = ah.SourceCode
  AND m.sbsb_ck = ah.SBSB_CK
  AND m.CurrentEvalDt BETWEEN ah.StartDate AND ah.EndDate
LEFT JOIN v_subscriberaddress_combined_current current
  ON m.sbsb_ck = current.sbsb_ck AND current.sbad_type = 'H'
```

Claims are filtered to include only finalized or adjusted claims (`clcl_cur_sts IN ('02','91')`) with service dates within the evaluation window. Each claim is joined to the CMS RVU reference file to weight procedures by complexity. The system aggregates these weighted procedures to calculate total RVUs per member-provider pair, counting unique visits and tracking the most recent service date.

```sql
-- Example: Procedure RVU weighting and aggregation
SELECT
  c.ConstituentID AS UniqueMemberID,
  ps.ProviderNPI,
  ps.TaxID_GroupThenIndividual,
  ps.PCPIndicator,
  COUNT(DISTINCT c.clcl_id) AS UniqueVisitCount,
  MAX(c.clcl_low_svc_dt) AS LastVisit,
  SUM(proc.nonfacilitytotal) AS RVUTotal
FROM PCPAttribution_02_NonDV_06_Claims c
INNER JOIN PCPAttribution_02_NonDV_07_Procedures proc
  ON c.clcl_id = proc.clcl_id
INNER JOIN PCPAttribution_02_NonDV_02_ProviderSet ps
  ON c.prpr_id = ps.ProviderID
GROUP BY c.ConstituentID, ps.ProviderNPI, ps.TaxID_GroupThenIndividual, ps.PCPIndicator
```

Provider ranking uses a multi-dimensional approach. First, providers are classified into type ranks: PCPs with at least 10% of the member's total RVUs receive highest priority (`TypeRank = 1`), specialists receive medium priority (`TypeRank = 2`), and PCPs with less than 10% RVU share receive lowest priority (`TypeRank = 3`). Within each type rank, providers are ranked by clinic-level metrics (TIN specialty percentage, visit count, RVU total) and then by provider-level metrics (NPI visit count, RVU total, visit recency).

The final attribution selects the top-ranked provider for each member using a composite ranking that considers clinic ranking first, then provider ranking as a tiebreaker. This attributed PCP is then compared against the member's named PCP from enrollment records, with the final combined PCP preferring the named assignment when valid but falling back to the calculated attribution when necessary.

### Validation & Quality Checks

**Orphan Member Check**: Verify all `ConstituentID` values in the member set exist in the claims table by joining `PCPAttribution_02_NonDV_05_MemberSet` to `PCPAttribution_02_NonDV_06_Claims` on `ConstituentID` and counting unmatched members.

**Provider NPI Validity**: Confirm all `ProviderNPI` values in the provider set are 10-digit numeric strings by checking `LEN(ProviderNPI) = 10` AND `ProviderNPI` matches pattern `[0-9]{10}`.

**Attribution Uniqueness**: Ensure each member has exactly one attributed PCP per evaluation date by verifying `COUNT(*) = 1` when grouping `PCPAttribution_02_NonDV_12_CalculatedPCP` by `UniqueMemberID` and `CurrentEvalDt`.

**RVU Completeness**: Validate that all procedures with HCPCS codes have matching RVU values by identifying rows in `PCPAttribution_02_NonDV_07_Procedures` where `nonfacilitytotal IS NULL` or `= 0`.

**Geographic Coverage**: Check that all attributed members have valid FIPS county codes by joining `PCPAttribution_02_NonDV_05_MemberSet` to `ref.PCPAttribution_02_IdahoAdjacentCounty` and identifying unmatched members.

### Example Scenario

**Input Data**: Member 12345-01 (Constituent ID: ABC123) has active medical coverage in Boise, Idaho (ZIP 83702, Ada County). During the 18-month evaluation period from 2023-01-01 to 2024-06-30, this member had the following claims:

- Dr. Smith (NPI 1234567890, TIN 12-3456789, PCP designation): 4 office visits with total RVU = 8.5
- Dr. Jones (NPI 9876543210, TIN 12-3456789, PCP designation): 2 office visits with total RVU = 3.2
- Dr. Brown (NPI 5555555555, TIN 98-7654321, Cardiologist): 3 specialist visits with total RVU = 15.0

**Transformation Logic**:
1. Member total RVU across all providers = 26.7
2. Dr. Smith's RVU percentage = 8.5 / 26.7 = 31.8% (TypeRank = 1)
3. Dr. Jones's RVU percentage = 3.2 / 26.7 = 12.0% (TypeRank = 1)
4. Dr. Brown's type = Specialist (TypeRank = 2)
5. Within TypeRank = 1, rank by visits: Dr. Smith (4) > Dr. Jones (2)
6. Dr. Smith becomes AttributedPCP

**Output Data**: `MemberPCPAttribution_02_Lookup` contains:
- UniqueMemberID: ABC123
- AttributedPCP: 1234567890 (Dr. Smith's provider ID after crosswalk)
- AttributedPCPNPI: 1234567890
- NamedPCP: NULL (no enrollment designation)
- CombinedPCP: 1234567890 (defaults to AttributedPCP since no NamedPCP)

## Engineering Reference

### Technical Architecture

The implementation uses a **procedurally-orchestrated ETL pattern** with 13 stored procedures that execute sequentially, each populating a staging table or final output table. The main orchestration procedure `update_MemberPCPAttribution_02_Lookup` calls subordinate procedures in dependency order, managing transaction boundaries and error handling at the orchestration level.

**Key Components**:
- **Control Table**: `PCPAttribution_02_NonDV_01_Dates` (single-row parameter table)
- **Staging Tables**: 12 tables (`NonDV_02` through `NonDV_12`) with `TRUNCATE` and full reload pattern
- **Reference Tables**: 4 tables in `ref` schema providing specialty codes, RVU values, county mappings, and BIHC codes
- **Business Views**: 7 views encapsulating reusable queries for provider eligibility, member eligibility, date ranges, and ranking logic
- **Final Target**: `MemberPCPAttribution_02_Lookup` using delete-by-date and upsert pattern

**Dependency Chain**:
```
01_Dates (parameter config)
  ↓
02_ProviderSet ← EligibleProvider view
  ↓
03_EligibleMembers ← v_membereligibilityextended, r_COBProfileLookup
  ↓
04_MemberInfo ← 03_EligibleMembers
  ↓
04a_MemberAddressHistory ← audit_CMC_SBAD_ADDR
  ↓
05_MemberSet ← 04_MemberInfo + 04a_MemberAddressHistory + USZipCode_Melissa + IdahoAdjacentCounty
  ↓
06_Claims ← v_claimheader + ClaimProviders view + ClaimMembers view
  ↓
07_Procedures ← 06_Claims + FeeSchCmsDataFileRVU
  ↓
08_ClaimSet ← 06_Claims + 07_Procedures + 02_ProviderSet
  ↓
09_ProviderRankByMember ← 08_ClaimSet
  ↓
10_ProviderIDByMember ← 09_ProviderRankByMember + 02_ProviderSet
  ↓
11_HighClinic ← 09_ProviderRankByMember (with complex windowing)
  ↓
12_CalculatedPCP ← MemberClinicListing view (AttributedRow = 1)
  ↓
MemberPCPAttribution_02_Lookup ← 12_CalculatedPCP + r_MemberPCP_Lookup + Crosswalks
```

### Critical Implementation Details

- **Incremental Logic**: Full refresh strategy for all staging tables using `TRUNCATE TABLE` followed by `INSERT`. Final lookup table uses delete-by-evaluation-date pattern: `DELETE FROM MemberPCPAttribution_02_Lookup WHERE StartDate IN (SELECT CurrentEvalDt FROM dates)`, followed by UPDATE for changed records and INSERT for new records identified via `EXCEPT` operator.

- **Join Strategy**:
  - 1:many Provider-to-ProviderEntity for group TIN resolution (expects multiple entities per provider)
  - 1:1 Member-to-Subscriber for demographic enrichment (unique sbsb_ck per member)
  - many:many Member-to-Claims-to-Provider (core attribution relationship requiring aggregation)
  - 1:1 Claim-to-Procedure aggregation (procedures grouped by claim before joining to claims)

- **Filters**: `WHERE clcl_cur_sts IN ('02','91')` excludes pending, denied, voided claims (rationale: only finalized claims represent actual care delivery). `WHERE mepe_term_dt <> mepe_eff_dt` excludes zero-duration eligibility spans (rationale: these are data errors, not real coverage). `WHERE PRPR_MCTR_PRTY NOT IN ('GOVH','HOSP','INDH','PUBH','TPLH')` excludes facility providers (rationale: members should be attributed to individual practitioners, not hospitals).

- **Aggregations**: `GROUP BY UniqueMemberID, ProviderNPI, TaxID_GroupThenIndividual, PCPIndicator, CurrentEvalDt` defines the grain of claims analysis (rationale: attribution evaluates each unique member-provider-clinic-type combination per evaluation period). Window function `SUM(RVUTotal) OVER (PARTITION BY UniqueMemberID, CurrentEvalDt)` calculates member's total RVU across all providers without requiring self-join.

- **Change Tracking**: No formal SCD logic. Attribution is recalculated for each evaluation period, creating new rows with distinct `StartDate` and `EndDate`. Historical attributions remain unchanged. Deletes occur only for re-runs of the same evaluation date.

- **Performance Considerations**:
  - `WITH (TABBLOCK)` hint on INSERT statements enables bulk loading with minimized locking
  - `WITH (NOLOCK)` hints on claim queries reduce contention on high-volume tables
  - Procedures use indexed views (`v_provider_combined_current`, `v_claimheader_combined_current`) that maintain materialized joins to avoid repeated Data Vault pit table resolution
  - Address history query limits scope to home addresses (`sbad_type = 'H'`) and applies window functions only after filtering to minimize data volume

### Code Examples

#### Complex Join Logic - Provider Group TIN Resolution

```sql
-- Purpose: Resolve provider Tax ID, preferring group TIN over individual TIN
-- Critical: LEFT JOINs ensure all providers included even without group relationship
--           CASE expression handles NULL group TIN by falling back to individual

SELECT
  v_provider_combined_current.bkcc_provider AS SourceCode,
  v_provider_combined_current.prpr_id AS ProviderID,
  v_provider_combined_current.prpr_npi AS ProviderNPI,
  CASE
    WHEN ISNULL(v_provider_combined_current2.mctn_id, '') = ''
      THEN v_provider_combined_current.mctn_id  -- Individual TIN fallback
    ELSE v_provider_combined_current2.mctn_id   -- Group TIN preferred
  END AS TaxID_GroupThenIndividual,
  dates.CurrentEvalDt
FROM
  HDSVault.biz.v_provider_combined_current v_provider_combined_current

  -- Join to find group entity relationships (prer_prpr_entity = 'G')
  LEFT JOIN HDSVault.biz.v_providerentityrelationshipextended_combined_current
    ON v_providerentityrelationshipextended_combined_current.bkcc_provider = v_provider_combined_current.bkcc_provider
    AND v_providerentityrelationshipextended_combined_current.prpr_id = v_provider_combined_current.prpr_id
    AND v_providerentityrelationshipextended_combined_current.prer_prpr_entity = 'G'

  -- Join to get group provider's TIN
  LEFT JOIN HDSVault.biz.v_provider_combined_current v_provider_combined_current2
    ON v_providerentityrelationshipextended_combined_current.bkcc_provider = v_provider_combined_current2.bkcc_provider
    AND v_providerentityrelationshipextended_combined_current.prer_prpr_id = v_provider_combined_current2.prpr_id
    AND v_providerentityrelationshipextended_combined_current.prer_prpr_entity = v_provider_combined_current2.prpr_entity

INNER JOIN HDSVault.biz.PCPAttribution_02_NonDV_01_Dates dates ON 1=1  -- Cross join to evaluation dates
```

#### Critical Transformation - Multi-Dimensional Provider Ranking

```sql
-- Purpose: Calculate clinic and provider rankings using composite metrics
-- Critical: TypeRank must be calculated before windowing; NULLIF prevents division by zero
--           Multiple RANK() windows allow tie-breaking across different dimensions

SELECT
  UniqueMemberID,
  CurrentEvalDt,
  ProviderNPI,
  TaxID_GroupThenIndividual AS GroupTaxID,
  PCPIndicator,

  -- Calculate PCP engagement tier (1 = high, 2 = specialist, 3 = low)
  CASE
    WHEN PCPIndicator = 'PCP'
      AND (RVUPCP / NULLIF(RVUmem, 0)) >= 0.10 THEN 1
    WHEN PCPIndicator = 'Specialist' THEN 2
    WHEN PCPIndicator = 'PCP'
      AND (RVUPCP / NULLIF(RVUmem, 0)) < 0.10 THEN 3
  END AS TypeRank,

  -- Clinic-level ranking: highest visit count and RVU at TIN level
  RANK() OVER (
    PARTITION BY CurrentEvalDt, UniqueMemberID
    ORDER BY
      VisitClinic DESC,      -- Most visits to this clinic
      RVUClinic DESC         -- Highest total RVU at this clinic
  ) AS HighClinicbyTIN,

  -- Provider-level ranking: highest individual provider engagement
  RANK() OVER (
    PARTITION BY CurrentEvalDt, UniqueMemberID
    ORDER BY
      VisitProviderNPI DESC,  -- Most visits to this provider
      RVUProvider DESC,        -- Highest RVU for this provider
      LastVisitProvider DESC   -- Most recent visit to this provider
  ) AS HighProviderbyNPI,

  -- Composite ranking for final attribution: combines clinic and provider ranks
  RANK() OVER (
    PARTITION BY CurrentEvalDt, UniqueMemberID
    ORDER BY
      TypeRank,                    -- PCP engagement tier first
      TINSpecialtyPct DESC,        -- Clinic's % of member's care
      VisitClinic DESC,            -- Clinic visit frequency
      RVUClinic DESC               -- Clinic RVU total
  ) AS NewHighClinicPct,

  -- Provider rank combines clinic and individual metrics
  RANK() OVER (
    PARTITION BY CurrentEvalDt, UniqueMemberID
    ORDER BY TypeRank, TINSpecialtyPct DESC, VisitClinic DESC, RVUClinic DESC
  )
  + RANK() OVER (
    PARTITION BY CurrentEvalDt, UniqueMemberID
    ORDER BY TypeRank, TINSpecialtyPct DESC, VisitProviderNPI DESC,
             RVUProvider DESC, LastVisitProvider DESC
  ) AS NewHighNPI

FROM HDSVault.biz.v_PCPAttribution_02_ProviderRankByMemberRollup
```

#### Incremental/Merge Logic - Final Lookup Table Update

```sql
-- Purpose: Update MemberPCPAttribution_02_Lookup with new attribution results
-- Critical: DELETE by evaluation date first, then EXCEPT pattern identifies changes
--           UPDATE only records that differ, INSERT only net-new records

-- Step 1: Remove existing records for this evaluation period
DELETE FROM HDSVault.biz.MemberPCPAttribution_02_Lookup
WHERE StartDate IN (
  SELECT CurrentEvalDt
  FROM HDSVault.biz.PCPAttribution_02_NonDV_01_Dates
)

-- Step 2: Identify and update changed records (existing member, different attribution)
UPDATE lookup
SET
  lookup.AttributedPCP = src.AttributedPCP,
  lookup.AttributedPCPNPI = src.AttributedPCPNPI,
  lookup.NamedPCP = src.NamedPCP,
  lookup.CombinedPCP = src.CombinedPCP,
  lookup.dss_update_time = GETDATE()
FROM HDSVault.biz.MemberPCPAttribution_02_Lookup lookup
INNER JOIN (
  -- New data from current run
  SELECT SourceID, SourceCode, meme_ck, CurrentEvalDt, AttributedPCP,
         AttributedPCPNPI, NamedPCP, CombinedPCP
  FROM #TempAttributionResults

  EXCEPT

  -- Existing data (unchanged records filtered out)
  SELECT SourceID, SourceCode, meme_ck, StartDate, AttributedPCP,
         AttributedPCPNPI, NamedPCP, CombinedPCP
  FROM HDSVault.biz.MemberPCPAttribution_02_Lookup
  WHERE StartDate = @CurrentEvalDt
) src
  ON lookup.SourceID = src.SourceID
  AND lookup.meme_ck = src.meme_ck
  AND lookup.StartDate = src.CurrentEvalDt

SELECT @v_update_count = @@ROWCOUNT

-- Step 3: Insert new records (members not in lookup OR new eval dates)
INSERT INTO HDSVault.biz.MemberPCPAttribution_02_Lookup
(
  SourceID, SourceCode, LocalPlanCode, AttributedPCP, AttributedPCPNPI,
  StartDate, EndDate, GroupID, EnrolleeID, MemberSuffix, meme_ck,
  UniqueMemberID, NamedPCP, CombinedPCP, dss_create_time, dss_update_time
)
SELECT
  src.SourceID, src.SourceCode, src.LocalPlanCode, src.AttributedPCP,
  src.AttributedPCPNPI, src.CurrentEvalDt AS StartDate,
  '9999-12-31' AS EndDate, -- Open-ended end date
  src.grgr_id, src.sbsb_id, src.meme_sfx, src.meme_ck, src.UniqueMemberID,
  src.NamedPCP, src.CombinedPCP, GETDATE(), GETDATE()
FROM #TempAttributionResults src
WHERE NOT EXISTS (
  SELECT 1
  FROM HDSVault.biz.MemberPCPAttribution_02_Lookup lookup
  WHERE lookup.SourceID = src.SourceID
    AND lookup.meme_ck = src.meme_ck
    AND lookup.StartDate = src.CurrentEvalDt
)

SELECT @v_insert_count = @@ROWCOUNT
```

### Common Issues & Troubleshooting

**Issue**: Member has no attributed PCP despite having multiple claims in evaluation period
**Cause**: All providers seen by member are specialists OR PCPs have RVU share below 10% threshold with no tie-breaking visits
**Resolution**: Review `PCPAttribution_02_NonDV_11_HighClinic` for this member to verify TypeRank assignments; check if specialist visits dominate member's care pattern; consider if PCP 10% threshold should be adjusted for low-utilization populations
**Prevention**: Add validation query to identify members with claims but no attribution, flagging for clinical review to determine if manual PCP assignment needed

**Issue**: Duplicate member_id values in `MemberPCPAttribution_02_Lookup` output
**Cause**: Multiple evaluation dates exist in `NonDV_01_Dates` control table OR business key uniqueness assumption violated (SourceID + meme_ck + StartDate not unique)
**Resolution**: Check `SELECT * FROM PCPAttribution_02_NonDV_01_Dates` to confirm single evaluation date; run `SELECT meme_ck, StartDate, COUNT(*) FROM MemberPCPAttribution_02_Lookup GROUP BY meme_ck, StartDate HAVING COUNT(*) > 1` to identify duplicates; if found, investigate upstream `v_PCPAttribution_02_MemberClinicListing` for multiple AttributedRow = 1 per member
**Prevention**: Add unique constraint on (SourceID, meme_ck, StartDate) to final table; implement pre-validation step that fails job if duplicates detected in CalculatedPCP stage

**Issue**: Attribution job fails at Step 300 with "String or binary data would be truncated"
**Cause**: ProviderNPI or TaxID values exceed column width in staging tables (NPI should be CHAR(10), TaxID should be CHAR(9))
**Resolution**: Query `SELECT MAX(LEN(prpr_npi)) FROM v_provider_combined_current` and `SELECT MAX(LEN(mctn_id)) FROM v_provider_combined_current` to identify oversized values; cleanse source data to enforce length constraints; update staging table schema if legitimate longer values exist
**Prevention**: Implement data quality checks in provider load processes to enforce NPI = 10 digits and TaxID = 9 digits before Data Vault load

**Issue**: Member attributed to provider who is not in their network
**Cause**: Provider network relationship (`NWPR_PCP_IND`) or specialty designation added after claims were processed, creating mismatch between historical claims and current provider eligibility
**Resolution**: Verify provider's network effective and term dates align with claim service dates; check if provider changed specialties during evaluation period; review `PCPAttribution_02_NonDV_02_ProviderSet` to confirm provider was eligible during claim dates
**Prevention**: Document that attribution reflects provider network status at time of service, not current status; consider adding provider network history tracking to enable point-in-time network validation

**Issue**: Named PCP overrides claims-based attribution even when member has zero visits to named PCP
**Cause**: Business rule prioritizes enrollment data over utilization: `CombinedPCP` uses `NamedPCP` when not null/unassigned, regardless of whether named provider appears in claims
**Resolution**: This is expected behavior per requirements; named PCP represents member/plan designation which takes precedence over claims patterns; if clinically problematic, work with business owners to modify CombinedPCP logic to require minimum visit threshold
**Prevention**: Add reporting to identify members where NamedPCP differs from AttributedPCP with no utilization of NamedPCP, flagging potential enrollment data errors

**Issue**: RVU values are NULL for most procedures, causing all providers to tie at zero RVU
**Cause**: CMS RVU reference file (`PCPAttribution_02_FeeSchCmsDataFileRVU`) is outdated or incomplete; procedure codes in claims do not match HCPCS codes in RVU file
**Resolution**: Refresh RVU reference file with current CMS fee schedule; run `SELECT DISTINCT cdml_proc_cd FROM claim_detail WHERE NOT EXISTS (SELECT 1 FROM FeeSchCmsDataFileRVU WHERE HCPCS_CD = cdml_proc_cd)` to identify unmatched procedure codes; supplement RVU file with organization-specific codes
**Prevention**: Schedule quarterly RVU reference file updates aligned with CMS publication calendar; implement data quality monitoring to alert when NULL RVU percentage exceeds threshold

### Testing & Validation

**Unit Test Scenarios**:

1. **Single PCP Scenario**: Member has 5 visits to one PCP (Dr. A, NPI 1111111111) and no other providers. Expected: AttributedPCP = 1111111111, TypeRank = 1, AttributedRow = 1.

2. **PCP vs Specialist Scenario**: Member has 2 visits to PCP (Dr. B, RVU = 4.0) and 8 visits to cardiologist (Dr. C, RVU = 20.0). Expected: Dr. B attributed if RVU >= 10% threshold (4.0/24.0 = 16.7%), otherwise Dr. C if specialist attribution allowed.

3. **Tied Providers Scenario**: Member has identical visit counts and RVU totals for two PCPs at same clinic (TIN 12-3456789). Expected: Tiebreaker uses most recent visit date; provider with later LastVisit wins.

4. **Named PCP Override Scenario**: Member has AttributedPCP = 2222222222 from claims but NamedPCP = 3333333333 from enrollment. Expected: CombinedPCP = 3333333333 (named PCP takes precedence).

5. **Geographic Exclusion Scenario**: Member resides in Utah (outside Idaho service area). Expected: Member excluded from `NonDV_05_MemberSet`, zero rows in final lookup.

**Data Quality Checks**:

```sql
-- Validate attribution uniqueness (each member should have exactly 1 row per eval date)
SELECT meme_ck, StartDate, COUNT(*) AS RowCount
FROM HDSVault.biz.MemberPCPAttribution_02_Lookup
GROUP BY meme_ck, StartDate
HAVING COUNT(*) > 1

-- Verify all attributed NPIs are valid 10-digit values
SELECT UniqueMemberID, AttributedPCPNPI
FROM HDSVault.biz.MemberPCPAttribution_02_Lookup
WHERE LEN(AttributedPCPNPI) <> 10
   OR AttributedPCPNPI NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]'

-- Check referential integrity: all attributed providers exist in provider table
SELECT lookup.AttributedPCP, lookup.SourceCode
FROM HDSVault.biz.MemberPCPAttribution_02_Lookup lookup
WHERE NOT EXISTS (
  SELECT 1
  FROM HDSVault.biz.v_provider_combined_current prov
  WHERE prov.prpr_id = lookup.AttributedPCP
    AND prov.bkcc_provider = lookup.SourceCode
)

-- Verify RVU completeness: procedures should have non-zero RVU values
SELECT
  COUNT(*) AS TotalProcedures,
  SUM(CASE WHEN nonfacilitytotal IS NULL OR nonfacilitytotal = 0 THEN 1 ELSE 0 END) AS MissingRVU,
  100.0 * SUM(CASE WHEN nonfacilitytotal IS NULL OR nonfacilitytotal = 0 THEN 1 ELSE 0 END) / COUNT(*) AS PctMissing
FROM HDSVault.biz.PCPAttribution_02_NonDV_07_Procedures

-- Validate member eligibility: all attributed members should have active coverage
SELECT lookup.UniqueMemberID, lookup.StartDate
FROM HDSVault.biz.MemberPCPAttribution_02_Lookup lookup
WHERE NOT EXISTS (
  SELECT 1
  FROM HDSVault.biz.PCPAttribution_02_NonDV_03_EligibleMembers elig
  WHERE elig.meme_ck = lookup.meme_ck
    AND elig.CurrentEvalDt = lookup.StartDate
)
```

**Regression Tests**:

When modifying attribution logic, verify:
1. Row counts at each staging table remain within 5% of baseline (unless known population changes)
2. % of members with AttributedPCP vs no attribution remains stable
3. Distribution of TypeRank (1/2/3) does not shift dramatically
4. Named vs Attributed PCP preference rate stays consistent
5. Re-run same evaluation date produces identical output (idempotency check)

### Dependencies & Risks

**Upstream Dependencies**:
- `HDSVault.biz.v_provider_combined_current` - Provider master data (SLA: daily refresh by 6am)
- `HDSVault.biz.v_membereligibilityextended_combined_current` - Member eligibility spans (SLA: daily refresh by 6am)
- `HDSVault.biz.v_claimheader_combined_current` - Professional claims (SLA: T+2 claim lag, daily refresh by 8am)
- `HDSVault.ref.PCPAttribution_02_FeeSchCmsDataFileRVU` - CMS RVU reference (SLA: quarterly manual update)
- `HDSInformationMart.xref.USZipCode_Melissa` - ZIP to county geocoding (SLA: annual update)

**Downstream Impacts**:
- Care management team assignment workflows depend on CombinedPCP; missing attributions cause manual assignment overhead
- Quality measure attribution (HEDIS/Stars) uses this lookup for provider performance scorecards; incorrect attribution impacts provider incentive payments
- Provider portal displays attributed member panels; errors create member access issues
- Risk adjustment analytics use PCP relationships for attribution; missing PCPs cause revenue forecasting errors

**Data Quality Risks**:
- Provider NPI changes not reflected in claims data cause attribution to wrong/inactive provider
- Member address changes mid-period may attribute based on wrong geography if address history incomplete
- Specialist procedures with missing RVU values underweight specialist encounters, biasing toward PCPs
- Delayed claim adjudication means recent visits not counted, favoring providers seen earlier in evaluation window

**Performance Risks**:
- Address history query scans large audit table; if audit retention extends beyond necessary period, query performance degrades (timeout threshold: 15 minutes)
- Claim volume exceeding 50M rows in evaluation period may exceed tempdb capacity during windowing operations
- Concurrent execution with other business vault processes may cause deadlocks on shared provider/member views
- Full refresh pattern on staging tables can cause blocking if downstream queries access tables mid-process
