---
technical_topics: ["pcp-attribution", "primary-care-provider", "effectivity-satellite", "data-vault-2.0", "claims-analysis"]
audience: ["claims-operations", "network-management", "quality-analytics", "care-management", "data-stewards"]
status: "draft"
last_updated: "2025-10-21"
version: "1.0"
author: "Dan Brickey"
description: "Business rules for Primary Care Provider (PCP) attribution logic using claims-based utilization patterns"
related_docs:
  - "../cob_profile/member_cob_profile_business_rules.md"
  - "../member_person/member_person_business_rules.md"
model_name: "ces_member_pcp_attribution"
legacy_source: "HDSVault.biz.PCPAttribution_02_* (12 staging tables + views)"
---

# PCP Attribution Business Rules

## Executive Summary

**Purpose**: Assign each BCI member to a Primary Care Provider (PCP) based on their claim utilization patterns over an 18-month evaluation window. This attribution supports quality measure reporting, care management assignment, and network adequacy analysis.

**Attribution Approach**: Clinic-level attribution using visit frequency and recency to determine the provider most actively managing the member's care.

**Temporal Design**: Effectivity satellite that tracks PCP assignments over time, allowing point-in-time and historical analysis.

---

## Business Context

### Why PCP Attribution Matters

1. **Quality Measures**: CMS and state quality programs require attribution for HEDIS and Star ratings
2. **Care Coordination**: Identify which provider is managing member's primary care
3. **Network Adequacy**: Demonstrate members have access to and utilize PCPs
4. **Value-Based Care**: Assign accountability for cost and quality outcomes
5. **Member Communication**: Direct members to their most frequently visited provider

### Attribution Philosophy

- **Claims-Based**: Uses actual utilization patterns, not member enrollment designation
- **Clinic-Level**: Attributes to the practice/clinic (Tax ID) not individual provider
- **Retrospective**: Based on historical claims in lookback window
- **Periodic Evaluation**: Re-evaluated at defined intervals (monthly or quarterly)

---

## Core Business Rules

### Rule 1: Evaluation Period and Lookback Window

**Rule**: PCP attribution is calculated at defined evaluation dates using an 18-month rolling lookback window of claims.

**Details**:
- **Evaluation Date** (`current_eval_date`): The date on which attribution is calculated
- **Lookback Window**: 18 months prior to evaluation date
  - Example: Eval date = 2024-01-01, lookback = 2022-07-01 to 2024-01-01
- **Evaluation Frequency**: Configurable (monthly, quarterly, or ad-hoc)

**Rationale**:
- 18 months provides sufficient claim history to identify utilization patterns
- Balances recency (recent care matters more) with stability (avoid volatility from single visits)
- Aligns with CMS attribution methodologies

**Implementation**:
- Defined in `seed_pcp_attribution_evaluation_dates.csv`
- Each row specifies: `current_eval_date`, `low_date`, `high_date`

---

### Rule 2: Member Eligibility

**Rule**: Only members meeting ALL of the following criteria are eligible for PCP attribution:

#### 2.1 Active Medical Eligibility
- Member must have medical eligibility (`eligibility_ind = 'Y'`) for at least one day during the evaluation window
- Product category must be medical-related: 'M' (Medical) or 'MR' (Medical + Rx)

#### 2.2 Primary Medical Coverage
- BCI must be the member's **primary** medical insurance during the evaluation period
- Determined via `ces_member_cob_profile.medical_is_bci_primary = true`
- Excludes members with other primary insurance (COB)

#### 2.3 Valid Member Demographics
- Member must have valid subscriber and group relationships
- No "PROXY" subscriber IDs

**Rationale**:
- Attribution only meaningful for members BCI is responsible for (primary coverage)
- Medical eligibility required since PCP attribution is based on medical claims
- Stable demographics required for accurate reporting

**Edge Cases**:
- **Intermittent Eligibility**: Member with gaps in eligibility still eligible if any overlap with lookback window
- **No Visits**: Eligible members with zero E&M visits receive null attribution
- **Product Changes**: Member counted if eligible in ANY medical product during window

---

### Rule 3: Provider Eligibility

**Rule**: Providers must meet specific criteria to be eligible for PCP attribution.

#### 3.1 Primary Care Providers (PCPs)

A provider is classified as **PCP** if:
- Has active network relationship with `pcp_indicator = 'Y'`
- Network effective date ≤ evaluation date
- Network term date ≥ start of lookback window (or null)
- No additional restrictions on specialty or entity type

#### 3.2 Eligible Specialists

A provider is classified as **Specialist** if:
- Has an approved specialty code (from `seed_pcp_attribution_provider_specialty`)
- Entity type = 'P' (Person, not Organization)
- Provider type NOT in institutional list: 'GOVH', 'HOSP', 'INDH', 'PUBH', 'TPLH'

**Ranking Priority**: When a provider qualifies as both PCP and Specialist, **PCP classification wins**.

**Rationale**:
- Specialists can be attributed if they act as de facto PCP for members (e.g., oncologist for cancer patient)
- Institutional providers excluded as they represent facilities, not care managers
- Network PCP designation prioritized over specialty-based classification

---

### Rule 4: Tax ID (Clinic) Logic

**Rule**: Attribution occurs at the **clinic level** using Tax ID, not individual provider level.

#### 4.1 Tax ID Assignment
- **Preference**: Use group-level Tax ID if provider is affiliated with a group entity
- **Fallback**: Use individual provider's Tax ID if no group affiliation
- **Source**: From `current_provider_affiliation` where `affiliation_entity_bk = 'G'`

#### 4.2 Clinic Aggregation
- All providers with the same Tax ID are considered the same clinic
- Visits to any provider in the clinic count toward that clinic's total
- One representative provider per clinic is selected for reporting

**Rationale**:
- Members see multiple providers within same practice/clinic
- Clinic-level attribution more stable and meaningful for care management
- Aligns with how practices are organized and compensated

**Example**:
```
Dr. Smith (NPI 1234, Tax ID 99-9999999)
Dr. Jones (NPI 5678, Tax ID 99-9999999)
↓
Both count toward "Clinic 99-9999999"
Representative provider selected based on ranking rules
```

---

### Rule 5: Qualifying Visit Identification

**Rule**: Only specific types of claims and procedures count toward PCP attribution.

#### 5.1 Claim Status
- **Paid**: Claim status = '02'
- **Adjudicated**: Claim status = '91'
- **Excluded**: Denied, pended, or other statuses

#### 5.2 Procedure Type Filter
- **Denied Procedures**: Exclude line items where `place_of_service_id = '20'`

#### 5.3 Evaluation & Management (E&M) Identification

A procedure qualifies as E&M if it meets **either** condition:
- **CMS RVU**: Procedure code exists in `seed_pcp_attribution_cms_rvu` (has RVU value)
- **BIHC Code**: Procedure code exists in `seed_pcp_attribution_bihc_codes` (behavioral integrated health)

**Rationale**:
- E&M visits represent face-to-face encounters for care management
- RVU presence indicates CMS recognizes as evaluation/management service
- BIHC codes capture behavioral health integration visits

---

### Rule 6: Visit Counting Logic

**Rule**: Visits are counted as **unique** occurrences, not by line items or procedures.

#### 6.1 Unique Visit Definition
A unique visit is a distinct combination of:
- Provider (`provider_bk`)
- Service Date (`service_from_date`)
- Member (`member_bk`)

#### 6.2 Counting Approach
- **Multiple procedures**: Same-day visit with multiple E&M procedures = 1 visit
- **Multiple claims**: Same provider + date across multiple claims = 1 visit
- **Line vs Header**: Procedures from line items and header-level combined, deduplicated

**Example**:
```
Claim 123: Member A → Dr. Smith → 2024-03-15 → 3 E&M procedures → Counts as 1 visit
Claim 456: Member A → Dr. Smith → 2024-03-15 → 1 E&M procedure → Same visit (not double-counted)
Claim 789: Member A → Dr. Jones → 2024-03-15 → 1 E&M procedure → Different visit (different provider)
```

---

### Rule 7: Attribution Ranking Logic

**Rule**: When a member has visits to multiple clinics, the attributed PCP is determined by ranking clinics using the following criteria in order:

#### 7.1 Ranking Hierarchy (Most Important to Least)

1. **PCP Indicator**
   - Clinics with PCP designation ranked higher than Specialist-only clinics
   - Sort: 'PCP' → 'Specialist'

2. **Unique Visit Count**
   - Clinic with more visits ranked higher
   - Sort: Descending (most visits wins)

3. **Last Visit Date**
   - Clinic with most recent visit ranked higher
   - Sort: Descending (most recent wins)

4. **Total RVU**
   - Clinic with higher RVU sum ranked higher
   - Sort: Descending (highest RVU wins)

5. **Tax ID (Tie-breaker)**
   - Alphabetical or numeric ordering
   - Sort: Ascending

#### 7.2 Ranking Steps

**Step 1**: Rank providers within each clinic
- Among providers in same clinic, select representative using same ranking criteria

**Step 2**: Aggregate visits to clinic level
- Sum visit counts, RVUs across all providers in clinic
- Take max last visit date

**Step 3**: Rank clinics by member
- Apply ranking hierarchy to select #1 clinic

**Step 4**: Assign attribution
- Member attributed to #1 ranked clinic's representative provider

**Example Scenario**:
```
Member X visits:
- Clinic A (PCP): 5 visits, last visit 2024-06-01, 12.5 RVU
- Clinic B (Specialist): 8 visits, last visit 2024-08-01, 18.0 RVU

Result: Attributed to Clinic A
Reason: PCP indicator wins even with fewer visits
```

---

### Rule 8: Effectivity Period Calculation

**Rule**: Attribution results are stored as effectivity periods, not point-in-time snapshots.

#### 8.1 Effective Date
- **Value**: Current evaluation date (`current_eval_date`)
- **Meaning**: Attribution becomes effective on this date

#### 8.2 End Date
- **Value**: Next evaluation date minus 1 day
- **Special Case**: If no next evaluation, use '9999-12-31' (open-ended)
- **Meaning**: Attribution remains valid through this date

#### 8.3 Current Flag
- **is_current = true**: When `end_date = '9999-12-31'`
- **is_current = false**: Historical attribution periods

**Example**:
```
Evaluation Dates: 2024-01-01, 2024-04-01, 2024-07-01

Attribution for Member A:
- Row 1: effective_date = 2024-01-01, end_date = 2024-03-31, is_current = false
- Row 2: effective_date = 2024-04-01, end_date = 2024-06-30, is_current = false
- Row 3: effective_date = 2024-07-01, end_date = 9999-12-31, is_current = true
```

**Rationale**:
- Supports point-in-time queries ("Who was attributed on 2024-05-15?")
- Enables trending analysis ("How many members switched PCPs?")
- Aligns with Data Vault 2.0 effectivity satellite pattern

---

### Rule 9: Members Without Attribution

**Rule**: Members eligible for attribution but with **zero E&M visits** receive explicit null attribution.

#### 9.1 Null Attribution Record
- Member included in `ces_member_pcp_attribution`
- Attribution fields set to null:
  - `attributed_provider_bk = null`
  - `attributed_provider_npi = null`
  - `attributed_tax_id = null`
  - `attributed_pcp_indicator = null`
- Metrics set to zero:
  - `attribution_visit_count = 0`
  - `attribution_rvu_total = 0.0`
  - `attribution_last_visit_date = null`

#### 9.2 Effectivity Periods
- Null attribution follows same effectivity rules
- Allows tracking when member becomes active (gets first visit)

**Rationale**:
- Complete population view (all eligible members, not just those with visits)
- Supports reporting on unattributed/non-utilizing members
- Enables care outreach for members without recent PCP contact

**Use Cases**:
- **Network Adequacy**: "How many members have no PCP relationship?"
- **Care Gaps**: "Members eligible but not seeing a PCP"
- **Outreach**: "Members to target for wellness visit campaigns"

---

## Data Quality Rules

### DQ1: No Overlapping Periods
- Each member can have only ONE attribution record per source for any given date
- Effectivity periods must not overlap
- Enforced by unique key: `(source, member_bk, effective_date)`

### DQ2: Valid Date Ranges
- `effective_date` must be ≤ `end_date`
- No gaps allowed in effectivity periods (if member remains eligible)

### DQ3: Current Flag Consistency
- If `end_date = '9999-12-31'`, then `is_current = true`
- If `end_date != '9999-12-31'`, then `is_current = false`
- Each member should have at most ONE current record

### DQ4: Referential Integrity
- All `member_hk` values must exist in `h_member`
- All `provider_hk` values must exist in `h_provider` (when not null)
- All evaluation dates must exist in seed file

---

## Boundary Conditions

### BC1: Member Eligibility Changes Mid-Window
**Scenario**: Member loses BCI primary coverage halfway through lookback window

**Rule**: Member is **included** in attribution if they meet eligibility criteria for ANY period during the lookback window. Attribution based on visits during eligible periods only.

**Example**: Member has BCI primary Jan-Jun, secondary Jul-Dec. Visits in Jan-Jun count; Jul-Dec excluded.

---

### BC2: Provider Network Status Changes
**Scenario**: Provider's PCP indicator changes during lookback window

**Rule**: Provider's eligibility determined at **evaluation date**, not service date. If provider is PCP on eval date, all their historical visits count toward PCP attribution.

**Example**: Dr. Smith added as in-network PCP on 2024-01-01. Evaluation on 2024-01-01 includes visits back to 2022-07-01 (even though not in network then).

---

### BC3: Multiple Specialties
**Scenario**: Provider has multiple specialty codes in source system

**Rule**: Use **primary** specialty code as recorded in `current_provider.provider_specialty`. If provider's primary specialty is in eligible list, they qualify.

---

### BC4: Tied Rankings
**Scenario**: Two clinics have identical visit counts, last visit dates, and RVUs

**Rule**: Tie broken by Tax ID (alphabetical/numeric ordering). Deterministic but arbitrary.

**Mitigation**: Document that tie-breaker is not clinically meaningful; recommend review if ties are common.

---

### BC5: Same-Day Visits to Multiple Providers
**Scenario**: Member sees Dr. Smith and Dr. Jones at different clinics on same day

**Rule**: Each counts as a separate unique visit (different providers). Both clinics get credit for one visit each.

---

### BC6: Claims Spanning Evaluation Date
**Scenario**: Claim processed after evaluation date but service date before evaluation date

**Rule**: Inclusion based on **service date**, not claim processing date. Claims processed late will be included in **next** evaluation run (incremental processing).

---

## Seed Data Requirements

### Seed 1: Evaluation Dates
**File**: `seed_pcp_attribution_evaluation_dates.csv`

**Columns**:
- `current_eval_date`: Date attribution is calculated
- `low_date`: Start of 18-month lookback
- `high_date`: End of lookback (usually same as eval date)

**Governance**:
- Maintained by data engineering team
- Updated monthly/quarterly per business cadence
- Must be sequential (no gaps in eval dates for same member)

---

### Seed 2: Provider Specialty Codes
**File**: `seed_pcp_attribution_provider_specialty.csv`

**Columns**:
- `specialty_code`: Specialty code from provider data
- `specialty_desc`: Human-readable description

**Governance**:
- Maintained by network management team
- Reviewed annually or when specialty taxonomy changes
- Includes primary care specialties: Family Practice, Internal Medicine, Pediatrics, Geriatrics, etc.

---

### Seed 3: CMS RVU Reference
**File**: `seed_pcp_attribution_cms_rvu.csv`

**Columns**:
- `hcpcs`: Procedure code
- `work_rvu`: Work RVU component
- `pe_rvu`: Practice expense RVU
- `mp_rvu`: Malpractice RVU

**Governance**:
- Sourced from CMS annual RVU file
- Updated annually when CMS publishes new fee schedule
- Maintained by claims operations team

---

### Seed 4: BIHC Codes
**File**: `seed_pcp_attribution_bihc_codes.csv`

**Columns**:
- `cpt_code`: CPT procedure code
- `cpt_desc`: Description

**Governance**:
- Maintained by behavioral health and quality teams
- Reviewed annually or when HEDIS specifications change
- Captures behavioral integrated health visit codes

---

### Seed 5: Idaho Adjacent Counties
**File**: `seed_pcp_attribution_idaho_county.csv`

**Columns**:
- `fips_county_code`: FIPS county code
- `county_name`: County name

**Governance**:
- Maintained by network management
- Defines service area for regional reporting
- Updated if service area expansion occurs

---

### Seed 6: Zip Code Reference
**File**: `seed_zip_code_melissa.csv`

**Columns**:
- `zip_code`: 5-digit zip code
- `state_id`: State abbreviation
- `fips_county_code`: County FIPS code
- `fips_code`: Full FIPS code

**Governance**:
- Sourced from Melissa Data (vendor)
- Updated quarterly or annually
- Used for member address geocoding

---

## Use Cases and Examples

### Use Case 1: Quality Measure Attribution
**Scenario**: HEDIS comprehensive diabetes care measure requires attributing diabetic members to a PCP.

**Query Approach**:
```sql
-- Get current PCP attribution for diabetic members
SELECT
    dm.member_bk,
    dm.diabetes_diagnosis,
    pcp.attributed_provider_npi,
    pcp.attributed_tax_id,
    pcp.attribution_visit_count
FROM diabetic_members dm
LEFT JOIN ces_member_pcp_attribution pcp
    ON pcp.source = dm.source
    AND pcp.member_bk = dm.member_bk
    AND pcp.is_current = true
```

**Business Rule Applied**: Current attribution (`is_current = true`) determines which provider/clinic is accountable for quality measures.

---

### Use Case 2: Member Portal Display
**Scenario**: Member logs into portal and wants to see "Your Primary Care Provider"

**Query Approach**:
```sql
-- Get member's current attributed PCP
SELECT
    pcp.attributed_provider_npi,
    pcp.attribution_last_visit_date,
    p.provider_name,
    p.provider_phone
FROM ces_member_pcp_attribution pcp
JOIN dim_provider p
    ON p.provider_npi = pcp.attributed_provider_npi
WHERE pcp.source = 'gemstone_facets'
  AND pcp.member_bk = :member_id
  AND pcp.is_current = true
```

**Business Rule Applied**: Most recent evaluation determines displayed PCP. Last visit date helps member confirm accuracy.

---

### Use Case 3: PCP Switching Analysis
**Scenario**: Analyze how many members switched PCPs between Q1 and Q2 2024.

**Query Approach**:
```sql
-- Compare Q1 vs Q2 attribution
WITH q1_attribution AS (
    SELECT member_bk, attributed_provider_npi
    FROM ces_member_pcp_attribution
    WHERE '2024-03-31' BETWEEN effective_date AND end_date
),
q2_attribution AS (
    SELECT member_bk, attributed_provider_npi
    FROM ces_member_pcp_attribution
    WHERE '2024-06-30' BETWEEN effective_date AND end_date
)
SELECT
    COUNT(*) as members_switched
FROM q1_attribution q1
JOIN q2_attribution q2
    ON q2.member_bk = q1.member_bk
WHERE q1.attributed_provider_npi != q2.attributed_provider_npi
```

**Business Rule Applied**: Effectivity periods enable point-in-time queries for historical comparison.

---

### Use Case 4: Network Adequacy Reporting
**Scenario**: Regulatory report requires showing % of members with active PCP relationship.

**Query Approach**:
```sql
-- Calculate PCP attribution rate
SELECT
    COUNT(*) as total_eligible_members,
    SUM(CASE WHEN attributed_provider_npi IS NOT NULL THEN 1 ELSE 0 END) as members_with_pcp,
    ROUND(100.0 * SUM(CASE WHEN attributed_provider_npi IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 2) as attribution_rate
FROM ces_member_pcp_attribution
WHERE is_current = true
```

**Business Rule Applied**: Null attribution explicitly tracked allows measuring attribution rate vs non-attribution rate.

---

## Questions for Review

### Policy Questions
1. **Evaluation Frequency**: Should attribution be recalculated monthly, quarterly, or on a different cadence?
2. **Lookback Window**: Is 18 months the right window, or should it be adjusted (12, 24 months)?
3. **Specialist Attribution**: Should specialists be eligible for attribution, or only designated PCPs?
4. **No Visit Members**: Should members without visits be included in reporting, or filtered out?

### Technical Questions
5. **Product Categories**: Confirm 'M' and 'MR' are the correct product categories for medical eligibility.
6. **Specialty Codes**: Validate the list of eligible specialty codes for specialists.
7. **BIHC Codes**: Confirm behavioral integrated health codes are current and complete.
8. **Idaho Service Area**: Is Idaho county list current for service area definition?

### Operational Questions
9. **Provider Notification**: Should providers receive notification when members are attributed to them?
10. **Member Communication**: Should members be informed of their attributed PCP?
11. **Disputes**: What process handles provider disputes of attribution?
12. **Manual Overrides**: Are there cases where manual attribution overrides are needed?

---

## Change Log

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-21 | Dan Brickey | Initial draft for stakeholder review |

---

## Approval

**Status**: Draft - Pending Review

**Reviewers**:
- [ ] Network Management
- [ ] Quality Analytics
- [ ] Claims Operations
- [ ] Care Management
- [ ] Data Governance

**Approval Date**: _________________

**Approved By**: _________________
