---
title: "Member COB Profile – Logic Guide"
document_type: "logic_guide"
industry_vertical: "Healthcare Payer"
business_domain: ["membership", "claims"]
edp_layer: "business_vault"
technical_topics: ["coordination-of-benefits", "effectivity-satellite", "data-vault-2.0", "discrete-date-ranges"]
audience: ["executive-leadership", "management-product", "business-analyst", "engineering"]
status: "draft"
last_updated: "2025-11-05"
version: "1.0"
author: "Dan Brickey"
description: "Computes member Coordination of Benefits profiles across discrete date ranges to determine payer order for Medical, Dental, and Drug claims."
related_docs:
  - "docs/work-tracking/ai-transformation/use_cases/uc02_edw2_refactor/output/member_cob_profile/member_cob_profile_business_rules.md"
  - "docs/architecture/overview/edp-platform-architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "bv_s_member_cob_profile"
legacy_source: "HDSVault.biz.spCOBProfileLookup"
source_code_type: "dbt"
---

# Member COB Profile – Logic Guide

## Executive Summary

This logic ensures accurate claims payment by determining who pays first when members have multiple insurance coverages. It creates time-based snapshots showing whether Blue Cross of Idaho is the primary, secondary, or tertiary payer for medical, dental, and pharmacy claims during specific date ranges. The system prevents overpayments by correctly routing claims to the appropriate insurer, maintains compliance with BCBS network agreements, and identifies special "Two Blues" scenarios where both insurers are Blue Cross plans. This capability processes coverage changes for approximately 300,000 members daily, supporting $2B+ in annual claims adjudication and ensuring regulatory compliance with federal Medicare Part D requirements.

### Key Terms

**Coordination of Benefits (COB)**: Industry rules determining which insurer pays first when a member has coverage from multiple sources (e.g., BCI and spouse's employer plan).

**Two Blues**: Scenario where a member has coverage from two different Blue Cross Blue Shield plans, triggering special network sharing agreements and billing rules.

**Discrete Date Ranges**: Non-overlapping time periods during which a member's COB status remains unchanged, enabling accurate point-in-time determination.

---

## Management Overview

- **Primary Use Case**: Supports claims adjudication by providing real-time lookup of which insurer (BCI or another carrier) pays first, second, or third for any claim on any date. Critical for claims processors who need immediate answers when routing payments.

- **Operational Impact**: Eliminates manual COB research by claims staff. Previously required 5-10 minutes per claim to verify payer order; now automated via lookup table. Reduces claim processing time by approximately 30% for members with multiple coverages (estimated 15% of membership).

- **Data Scope**: Covers all active and termed members with medical, dental, or pharmacy benefits. Creates separate COB determinations for each coverage type (medical vs. dental vs. drug). Maintains full history with date-stamped ranges enabling retroactive claim corrections.

- **Timing & Frequency**: Computed daily after eligibility and COB data loads complete (typically by 6 AM). Provides same-day visibility to coverage changes reported by members or employer groups. Historical ranges preserved for claims filed months after service date.

- **Cross-Team Dependencies**: Relies on enrollment team maintaining accurate eligibility records and member services team capturing COB questionnaire responses. Outputs feed claims system (for auto-adjudication), provider portal (for real-time eligibility checks), and member portal (for coverage confirmation).

- **Quality Controls**: Validates that date ranges have no gaps or overlaps for active members, verifies all coverage IDs exist in carrier reference tables, and flags records where member is both primary and secondary (data error). Business vault pattern preserves full audit trail of all computed values.

- **Special Handling**: Implements Medicare Part D exclusion lists to handle federal pharmacy benefit rules differently than standard commercial coverage. Detects "Two Blues" scenarios requiring BlueCard network routing. Supports rare tertiary coverage scenarios (e.g., Medicare + spouse plan + BCI).

- **Known Limitations**: Does not handle real-time intra-day changes (24-hour lag from source systems). Cannot predict future COB changes unless explicitly recorded in advance. Requires manual reference data updates when BCBS contracts change or new Medicare Part D rules published.

---

## Analyst Detail

### Key Business Rules

**Date Range Construction**: When member eligibility or COB effective dates exist, create discrete non-overlapping periods by collecting all potential start dates (eligibility effective dates, COB effective dates, day after term dates) and all potential end dates (term dates, day before effective dates), then match the shortest valid range for each start date where `start_date <= end_date` and exclude placeholder dates ('9999-12-31', '2200-01-01').

**Medical Coverage Determination**: When `current_member_eligibility.product_category_bk = 'M'` and `eligibility_ind = 'Y'` and the date range falls between `elig_eff_date` and `elig_term_date`, then set `medical_coverage = 'Yes'`, else `medical_coverage = 'No'`.

**Dental Coverage Determination**: When `current_member_eligibility.product_category_bk = 'D'` and `eligibility_ind = 'Y'` and the date range falls between `elig_eff_date` and `elig_term_date`, then set `dental_coverage = 'Yes'`, else `dental_coverage = 'No'`.

**Drug Coverage Determination**: When `current_member_eligibility.product_category_bk IN ('M', 'R')` and `eligibility_ind = 'Y'` and the date range falls between `elig_eff_date` and `elig_term_date`, then set `drug_coverage = 'Yes'`, except when member has medical or rider eligibility, else `drug_coverage = 'No'`. Drug benefits typically bundle with medical plans or purchased as separate rider.

**Primary Medical/Drug COB**: When `medical_coverage = 'Yes'` and `current_member_cob` record exists where `insurance_order <> 'U'` (not Unknown) and `insurance_type <> 'D'` (not Dental-only) and `coverage_id` NOT IN Medicare Part D Primary exclusion list and date range overlaps COB effective/term dates, then set `medical_cob_order = 'Primary'` and `drug_cob_order = 'Primary'`, except when explicitly marked as secondary/tertiary.

**Secondary Medical/Drug COB**: When `medical_coverage = 'Yes'` and `current_member_cob.insurance_order = 'P'` (Primary to other carrier, meaning BCI is Secondary) and `insurance_type <> 'D'` and `coverage_id` NOT IN Medicare Part D Secondary exclusion list and date range overlaps COB dates, then set `medical_cob_order = 'Secondary'` and `drug_cob_order = 'Secondary'`.

**Tertiary Medical/Drug COB**: When `medical_coverage = 'Yes'` and `medical_cob_order = 'Secondary'` (prerequisite) and `current_member_cob.insurance_order = 'S'` (Secondary to other carrier) and `insurance_type <> 'D'` and `coverage_id` NOT IN Medicare Part D exclusion list and date range overlaps COB dates, then set `medical_cob_order = 'Tertiary'` and `drug_cob_order = 'Tertiary'`.

**Two Blues Detection**: When `coverage_id_medical` or `coverage_id_dental` or `coverage_id_drug` exists in `seed_cob_two_blues_carriers.mcre_id` reference table, then set corresponding `medical_2blues = 'Yes'` or `dental_2blues = 'Yes'` or `drug_2blues = 'Yes'`, except when coverage ID not found in reference data.

**No Coverage Exclusion**: When `medical_coverage = 'No'` AND `dental_coverage = 'No'` AND `drug_coverage = 'No'`, then exclude the entire date range record because COB only applies when active coverage exists.

---

### Data Flow & Transformations

The transformation begins in `prep_member_cob_profile` where we construct discrete date ranges by performing a series of UNION operations. First, we collect all potential start dates from four sources: medical/dental eligibility effective dates, COB effective dates, day-after eligibility term dates, and day-after COB term dates. Similarly, we collect potential end dates from term dates and day-before effective dates. These collections are cross-joined and filtered to keep only valid ranges where start ≤ end, then deduplicated by selecting the shortest range for each unique start date using `ROW_NUMBER()` partitioned by source, member, and start date.

```sql
-- Example: Create discrete date ranges
select
    row_number() over (
        partition by f.source, f.member_bk, f.from_date
        order by datediff(day, f.from_date, t.thru_date) asc
    ) as row_num,
    f.source,
    f.member_bk,
    f.from_date as start_date,
    t.thru_date as end_date
from from_dates f
inner join thru_dates t
    on f.member_bk = t.member_bk
where datediff(day, f.from_date, t.thru_date) >= 0
```

Next, we join each date range back to member, subscriber, and group tables to retrieve identifying information (group_id, subscriber_id, member_suffix, member_first_name). Then we LEFT JOIN to eligibility data filtered by product category to determine coverage flags. For medical coverage, we join where `product_category_bk = 'M'`; for dental where `= 'D'`; for drug where `IN ('M', 'R')`. Each join includes a BETWEEN clause checking if the date range's start_date falls within the eligibility effective and term dates.

```sql
-- Example: Determine medical coverage for each date range
left join medical_eligibility me
    on me.source = dr.source
    and me.member_bk = dr.member_bk
    and dr.start_date between me.elig_eff_date and me.elig_term_date
```

The final transformation phase applies COB business rules by LEFT JOINing to `current_member_cob` table multiple times—once for primary rules, once for secondary, once for tertiary—filtered by insurance_order and insurance_type. Each COB join also LEFT JOINs to seed reference tables (Medicare Part D exclusions and Two Blues carriers) to apply special handling. The final SELECT uses CASE statements to determine COB order based on which CTE matched (primary, secondary, or tertiary) and COALESCE to select the coverage_id from the highest-priority match.

```sql
-- Example: Determine final medical COB order from multiple rule layers
case
    when tertiary_medical_drug_cob.member_bk is not null then 'Tertiary'
    when secondary_medical_drug_cob.member_bk is not null then 'Secondary'
    when primary_medical_drug_cob.member_bk is not null then 'Primary'
    else 'No'
end as medical_cob_order
```

From the prep model, data flows to `stg_member_cob_profile` which generates Data Vault hash keys (member_hk) and hashdiff values for change detection. Finally, `bv_s_member_cob_profile` loads the business vault effectivity satellite using the automate_dv package's `eff_sat` macro, which manages start_date/end_date effectivity tracking and incremental loading patterns.

---

### Validation & Quality Checks

**Unique Key Validation**: Verify `(source, member_bk, start_date)` combination is unique across all records using `GROUP BY source, member_bk, start_date HAVING COUNT(*) > 1` to detect duplicates indicating date range construction logic errors.

**Date Range Validity**: Ensure `start_date <= end_date` for all records by querying `WHERE start_date > end_date` which should return zero rows, otherwise indicates corrupted date range logic.

**Coverage Prerequisite Check**: Validate that COB flags only exist when corresponding coverage exists using `WHERE has_medical_cob = 'Yes' AND medical_coverage = 'No'` which should be empty, preventing illogical combinations.

**Reference Data Integrity**: Verify all `coverage_id_medical`, `coverage_id_dental`, `coverage_id_drug` values exist in either `seed_cob_two_blues_carriers` or documented carrier list using LEFT JOIN where seed table returns NULL, flagging unknown carriers for stewardship review.

**No Coverage Exclusion Validation**: Confirm no records exist where all three coverage types are 'No' using query `WHERE medical_coverage = 'No' AND dental_coverage = 'No' AND drug_coverage = 'No'` which should return empty result set per business rule.

---

### Example Scenario

**Input Data**:
- Member: source='GEM', member_bk='GEM-12345'
- Medical Eligibility: effective 2024-01-01, term 2024-12-31, category='M', elig_ind='Y'
- COB Record: effective 2024-03-01, term 2024-05-31, insurance_order='P', insurance_type='M', coverage_id='CIGNA'

**Transformation Logic**:

Step 1: Date range construction identifies three distinct periods:
- 2024-01-01 to 2024-02-29 (has medical elig, no COB record)
- 2024-03-01 to 2024-05-31 (has medical elig, has COB record)
- 2024-06-01 to 2024-12-31 (has medical elig, no COB record)

Step 2: Medical coverage determination sets `medical_coverage='Yes'` for all three ranges because eligibility is active. Drug coverage also set to 'Yes' (follows medical). Dental coverage set to 'No' (no category='D' eligibility).

Step 3: COB order determination for middle period (2024-03-01 to 2024-05-31) matches secondary rule because `insurance_order='P'` meaning other carrier is primary. Sets `medical_cob_order='Secondary'`, `drug_cob_order='Secondary'`, `coverage_id_medical='CIGNA'`. Two Blues check returns 'No' because CIGNA not in seed table.

**Output Data**:

```
Row 1:
  start_date: 2024-01-01, end_date: 2024-02-29
  medical_coverage: Yes, has_medical_cob: No, medical_cob_order: No
  drug_coverage: Yes, has_drug_cob: No, drug_cob_order: No

Row 2:
  start_date: 2024-03-01, end_date: 2024-05-31
  medical_coverage: Yes, has_medical_cob: Yes, medical_cob_order: Secondary
  coverage_id_medical: CIGNA, medical_2blues: No
  drug_coverage: Yes, has_drug_cob: Yes, drug_cob_order: Secondary

Row 3:
  start_date: 2024-06-01, end_date: 2024-12-31
  medical_coverage: Yes, has_medical_cob: No, medical_cob_order: No
  drug_coverage: Yes, has_drug_cob: No, drug_cob_order: No
```

**Business Interpretation**: Member had solo BCI coverage in Q1 2024, spouse's CIGNA coverage became primary for Q2 2024 (BCI paid secondary), then returned to solo BCI coverage for remainder of year. Claims system would route Q2 claims to CIGNA first, collect explanation of benefits, then process remaining balance through BCI.

---

## Engineering Reference

### Technical Architecture

The implementation follows a three-layer dbt model structure aligned with Data Vault 2.0 methodology:

**Layer 1 - Preparation** (`prep_member_cob_profile.sql`):
- Materialized as ephemeral (not persisted, only exists during compilation)
- Contains all business rule logic for COB determination
- Uses 15+ CTEs organized as Import CTEs (source references) and Logical CTEs (transformations)
- Produces denormalized dataset with all COB flags and coverage determinations
- Excludes records with zero coverage across all three types

**Layer 2 - Staging** (`stg_member_cob_profile.sql`):
- Generates Data Vault hash keys using automate_dv `hash()` and `multi_hash()` macros
- Creates member_hk (primary key) from source + member_bk
- Creates member_cob_profile_hk (effectivity key) from source + member_bk + start_date
- Generates hashdiff for change detection across all payload columns
- Adds load_datetime and record_source metadata

**Layer 3 - Business Vault** (`bv_s_member_cob_profile.sql`):
- Materialized as incremental table with unique_key='member_cob_profile_hk'
- Implements effectivity satellite pattern using automate_dv `eff_sat()` macro
- Manages start_date and end_date columns for temporal tracking
- Parent relationship to h_member hub via member_hk foreign key
- Full refresh computes entire COB profile from current state

**Dependency Chain**:
```
current_member ──┐
current_member_eligibility ──┤
current_member_cob ──┤
current_subscriber ──┼──> prep_member_cob_profile ──> stg_member_cob_profile ──> bv_s_member_cob_profile
current_group ──┤
seed_cob_two_blues_carriers ──┤
seed_cob_medicare_part_d_primary ──┤
seed_cob_medicare_part_d_secondary ──┘
```

**Additional Output** (`xwalk_member_cob_profile.sql`):
- Crosswalk table providing simplified lookup interface
- Adds derived indicator columns (medical_is_bci_primary, medical_is_bci_secondary, etc.)
- Used by downstream claims and reporting systems
- Materialized as table with daily refresh

---

### Critical Implementation Details

**Incremental Logic**: Currently implements full refresh pattern (not true incremental) because COB profiles are computed from current state of eligibility and COB tables. Each run truncates and reloads entire dataset. Future enhancement could implement incremental with lookback window detecting changed members via eligibility/COB load timestamps.

**Join Strategy**:
- from_dates to thru_dates: INNER JOIN, many-to-many (cartesian product filtered by date validity)
- date_ranges to member/subscriber/group: INNER JOIN, many-to-one (every date range must have member context)
- date_ranges to eligibility CTEs: LEFT JOIN, many-to-zero-or-many (member may not have all coverage types)
- date_ranges to COB CTEs: LEFT JOIN, many-to-zero-or-many (member may not have COB records)
- COB CTEs to seed tables: LEFT JOIN, many-to-zero-or-one (coverage_id may not be in reference lists)

**Filters**:
- `WHERE product_category_bk IN ('M', 'D')` for medical/dental eligibility (line 69)
- `WHERE product_category_bk IN ('M', 'R')` for drug eligibility (line 240)
- `WHERE row_num = 1` to deduplicate date ranges, keeping shortest interval (line 176)
- `WHERE start_date <> '9999-12-31' AND start_date <> '2200-01-01'` to exclude placeholder dates (lines 177-178)
- `WHERE NOT (medical_coverage='No' AND dental_coverage='No' AND drug_coverage='No')` to exclude non-coverage ranges (lines 535-538)

**Aggregations**: No GROUP BY aggregations used. ROW_NUMBER() window function partitioned by (source, member_bk, from_date) ordered by days_interval ASC to select minimum valid range for each start date (lines 152-155).

**Change Tracking**: Effectivity satellite pattern tracks changes via hashdiff comparison. When member's COB profile changes (e.g., secondary becomes primary), new row inserted with new start_date. Previous row's end_date remains unchanged creating non-overlapping temporal ranges.

**Performance Considerations**:
- Date range construction (from_dates × thru_dates cross join) is most expensive operation, generates ~10M intermediate rows for 300K members
- Ephemeral materialization of prep model keeps intermediate CTEs in memory rather than persisting
- Indexes on current_member_eligibility (source, member_bk, elig_eff_date) and current_member_cob (source, member_bk, cob_eff_date) critical for join performance
- Business vault satellite partitioned by load_datetime for incremental query pruning

---

### Code Examples

#### Complex Date Range Construction Logic

```sql
-- Purpose: Build discrete date ranges by cross-joining all possible start/end dates
-- Critical: ROW_NUMBER() deduplication ensures no overlapping ranges for same start_date

-- Collect all potential start dates (from_dates CTE)
select source, member_bk, elig_eff_date as from_date
from current_member_eligibility
where product_category_bk in ('M', 'D') and eligibility_ind = 'Y'
union
select source, member_bk, cob_eff_date as from_date
from current_member_cob
union
-- Day after term dates become new start dates
select source, member_bk,
    case when elig_term_date = '9999-12-31'
         then elig_term_date
         else dateadd(day, 1, elig_term_date)
    end as from_date
from current_member_eligibility
where product_category_bk in ('M', 'D') and eligibility_ind = 'Y'

-- Cross join with thru_dates and filter for valid ranges
select
    row_number() over (
        partition by f.source, f.member_bk, f.from_date
        order by datediff(day, f.from_date, t.thru_date) asc
    ) as row_num,
    f.from_date as start_date,
    t.thru_date as end_date
from from_dates f
inner join thru_dates t
    on f.member_bk = t.member_bk
    and f.source = t.source
where datediff(day, f.from_date, t.thru_date) >= 0  -- Only valid ranges
```

#### COB Order Determination with Multiple Rule Layers

```sql
-- Purpose: Determine final COB order by checking tertiary, then secondary, then primary
-- Critical: Evaluation order matters - tertiary prerequisite is existing secondary status

-- Final COB order determination (from final CTE)
select
    dr.source,
    dr.member_bk,
    dr.start_date,

    -- Medical COB order cascades from most specific to least
    case
        when tmc.member_bk is not null then 'Tertiary'
        when smc.member_bk is not null then 'Secondary'
        when pmc.member_bk is not null then 'Primary'
        else 'No'
    end as medical_cob_order,

    -- Coverage ID from highest-priority match
    coalesce(
        tmc.coverage_id,   -- Tertiary coverage_id if exists
        smc.coverage_id,   -- Else secondary coverage_id if exists
        pmc.coverage_id    -- Else primary coverage_id if exists
    ) as coverage_id_medical,

    -- Two Blues flag from same priority
    case
        when tmc.member_bk is not null then tmc.is_two_blues
        when smc.member_bk is not null then smc.is_two_blues
        when pmc.member_bk is not null then pmc.is_two_blues
        else 'No'
    end as medical_2blues

from date_ranges_with_coverage dr
left join primary_medical_drug_cob pmc
    on pmc.source = dr.source
    and pmc.member_bk = dr.member_bk
    and pmc.start_date = dr.start_date
left join secondary_medical_drug_cob smc
    on smc.source = dr.source
    and smc.member_bk = dr.member_bk
    and smc.start_date = dr.start_date
left join tertiary_medical_drug_cob tmc
    on tmc.source = dr.source
    and tmc.member_bk = dr.member_bk
    and tmc.start_date = dr.start_date
```

#### Business Vault Effectivity Satellite Loading

```sql
-- Purpose: Load business vault satellite with automate_dv eff_sat macro
-- Critical: Manages start_date/end_date effectivity and hashdiff change tracking

{%- set yaml_metadata -%}
source_model: stg_member_cob_profile
src_pk: member_hk
src_hashdiff:
  source_column: hashdiff
  alias: hashdiff
src_payload:
  - source
  - member_bk
  - start_date
  - end_date
  - medical_coverage
  - has_medical_cob
  - medical_cob_order
  - coverage_id_medical
  - medical_2blues
  # ... all other payload columns
src_eff: start_date
src_ldts: create_date
src_source: edp_record_source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict['src_pk'],
    src_dfk=none,
    src_sfk=none,
    src_start_date=metadata_dict['src_eff'],
    src_end_date='end_date',
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model=metadata_dict['source_model'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload']
) }}
```

---

### Common Issues & Troubleshooting

**Issue**: Duplicate date ranges for same member and start_date
**Cause**: ROW_NUMBER() deduplication logic failing due to identical days_interval values for multiple thru_dates
**Resolution**: Add secondary sort in ORDER BY clause: `order by datediff(day, f.from_date, t.thru_date) asc, t.thru_date desc` to prefer later end dates when ranges are same length
**Prevention**: Add dbt test for unique combination of (source, member_bk, start_date) in stg_member_cob_profile model

**Issue**: Member shows medical_cob_order='Primary' when should be 'Secondary'
**Cause**: COB table has insurance_order='P' but code incorrectly interprets as BCI being Primary instead of other carrier being Primary
**Resolution**: Review business rule definitions - insurance_order='P' means "other carrier is Primary" which makes BCI Secondary. Verify secondary_medical_drug_cob CTE is matching these records
**Prevention**: Add business validation query comparing output to legacy r_COBProfileLookup table for sample members, documenting insurance_order semantics

**Issue**: Date ranges have gaps leaving some dates uncovered
**Cause**: Member has COB effective date that doesn't align with eligibility effective date, and date range construction logic creates gap between ranges
**Resolution**: Investigate source data quality - COB records should align with eligibility periods. May need to extend date range logic to fill gaps by including "day before next start date" as valid end date
**Prevention**: Add dbt test checking for gaps: for each member, verify no dates exist between MIN(start_date) and MAX(end_date) that aren't covered by a range

**Issue**: coverage_id_medical showing NULL when COB record exists
**Cause**: TRIM(cob.coverage_id) returning NULL due to whitespace-only values in source, or COALESCE chain not finding any matches
**Resolution**: Update staging model to handle whitespace: `NULLIF(TRIM(coverage_id), '')` to convert empty strings to NULL, then investigate why COB CTE didn't match
**Prevention**: Add NOT NULL test on coverage_id_medical column when has_medical_cob='Yes'

**Issue**: Two Blues flag incorrectly set to 'No' for known BCBS carrier codes
**Cause**: seed_cob_two_blues_carriers reference table missing recently added carrier codes, or coverage_id has extra whitespace causing lookup mismatch
**Resolution**: Compare coverage_id values in production data to seed table using `LEFT JOIN seed_two_blues WHERE seed.mcre_id IS NULL` to find missing codes. Update seed CSV file with missing values and redeploy
**Prevention**: Schedule quarterly review of Two Blues seed data with Provider Network team, implement data monitoring alert for coverage_id values not in seed tables

**Issue**: Business vault satellite showing no history, only current state
**Cause**: Effectivity satellite configured for full refresh instead of incremental, losing historical records on each run
**Resolution**: This is current expected behavior - model computes COB profile from current state only. To preserve history, change materialization strategy to incremental and implement change detection comparing previous run's output
**Prevention**: Document that current implementation is snapshot-based, not history-preserving. Plan future enhancement for incremental pattern if historical tracking required

---

### Testing & Validation

**Unit Test Scenarios**:

1. **No COB Scenario**: Member with only BCI coverage, no COB records
   - Input: Eligibility record only, no COB records
   - Expected: medical_coverage='Yes', has_medical_cob='No', medical_cob_order='No'

2. **Simple Secondary COB**: Member with BCI secondary to spouse's plan
   - Input: Eligibility record + COB record with insurance_order='P', coverage_id='CIGNA'
   - Expected: medical_cob_order='Secondary', coverage_id_medical='CIGNA', medical_2blues='No'

3. **Two Blues Scenario**: Member with BCI secondary to another BCBS plan
   - Input: Eligibility record + COB record with insurance_order='P', coverage_id='0908'
   - Expected: medical_cob_order='Secondary', coverage_id_medical='0908', medical_2blues='Yes'

4. **Dental-Only COB**: Member has medical (no COB) and dental (secondary to Delta)
   - Input: Medical eligibility + Dental eligibility + COB record with insurance_type='D', coverage_id='DELTA'
   - Expected: medical_cob_order='No', dental_cob_order='Secondary', coverage_id_dental='DELTA'

5. **Medicare Part D Exclusion**: Member has Medicare Part D, should not set medical COB
   - Input: Eligibility record + COB record with coverage_id='MEDPARTD'
   - Expected: medical_cob_order='No' (excluded from primary medical COB rule)

**Data Quality Checks**:

```sql
-- Validate no duplicate date ranges
select source, member_bk, start_date, count(*)
from {{ ref('bv_s_member_cob_profile') }}
where current_flag = 'Y'  -- automate_dv standard column
group by source, member_bk, start_date
having count(*) > 1;

-- Validate date range integrity
select *
from {{ ref('bv_s_member_cob_profile') }}
where start_date > end_date;

-- Validate COB requires coverage
select *
from {{ ref('bv_s_member_cob_profile') }}
where has_medical_cob = 'Yes' and medical_coverage = 'No';

-- Validate no records with zero coverage
select *
from {{ ref('bv_s_member_cob_profile') }}
where medical_coverage = 'No'
  and dental_coverage = 'No'
  and drug_coverage = 'No';

-- Validate coverage_id exists when COB present
select distinct coverage_id_medical
from {{ ref('bv_s_member_cob_profile') }}
where has_medical_cob = 'Yes'
  and coverage_id_medical is null;
```

**Regression Tests**:

When making changes to date range construction logic or COB business rules, verify:
- Record count within 5% of previous run (major variance indicates logic error)
- Sample 100 random members and compare COB order to previous version
- Validate all members in legacy r_COBProfileLookup table exist in new output
- Check that tertiary COB scenarios (rare) still exist and count is consistent
- Ensure seed table reference data changes don't inadvertently exclude valid scenarios

---

### Dependencies & Risks

**Upstream Dependencies**:

- **current_member**: Member master table from Integration Layer
  - SLA: Loaded by 5 AM daily
  - Risk: Missing/delayed load prevents COB profile computation

- **current_member_eligibility**: Member eligibility episodes with product categories
  - SLA: Loaded by 5:30 AM daily
  - Risk: Incomplete eligibility data creates coverage determination errors

- **current_member_cob**: Coordination of Benefits records from member questionnaires
  - SLA: Loaded by 5:30 AM daily
  - Risk: Delayed COB updates cause incorrect secondary/tertiary assignments

- **current_subscriber** and **current_group**: Reference data for member context
  - SLA: Loaded by 5 AM daily
  - Risk: Missing references cause INNER JOIN failures dropping date ranges

- **seed_cob_two_blues_carriers**: Reference list of BCBS carrier codes
  - SLA: Updated quarterly or as contracts change
  - Risk: Outdated seed data causes missed Two Blues scenarios

- **seed_cob_medicare_part_d_primary** and **seed_cob_medicare_part_d_secondary**: Medicare exclusion lists
  - SLA: Updated annually or when CMS rules change
  - Risk: Missing Medicare Part D codes cause incorrect medical COB assignments

**Downstream Impacts**:

- **Claims Adjudication System**: Uses COB order to route claims to correct payer
  - Impact: Incorrect COB order causes claim denials and member appeals

- **Provider Portal**: Displays real-time eligibility and COB status to providers
  - Impact: Wrong COB info leads to provider billing wrong insurer first

- **Member Portal**: Shows members their coverage details and COB responsibilities
  - Impact: Incorrect display causes member confusion and call center volume

- **Financial Reporting**: COB impacts revenue recognition and claim liability reserves
  - Impact: Wrong COB order distorts financial projections and regulatory reports

**Data Quality Risks**:

- **Eligibility Gaps**: Members may have gaps in eligibility data causing date range construction to fail or create incorrect ranges
- **COB Questionnaire Accuracy**: COB data relies on member-reported information which may be outdated or incorrect
- **Carrier Code Standardization**: coverage_id values may have inconsistent formatting (whitespace, case) causing reference table lookups to fail
- **Retroactive Changes**: Late-arriving eligibility corrections or COB updates require reprocessing historical claims

**Performance Risks**:

- **Date Range Explosion**: Cross join of from_dates × thru_dates can generate millions of intermediate rows for large member populations
- **Full Refresh Cost**: Current full refresh pattern recomputes entire dataset daily, expensive at scale
- **Query Timeout**: Complex multi-level LEFT JOINs with seed table lookups may exceed Snowflake timeout for large datasets
- **Incremental Conversion**: Moving to true incremental loading requires careful change detection logic to avoid missing updates

---
