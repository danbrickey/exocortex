# PCP Attribution - EDW2 to EDW3 Refactoring

## Overview
Refactored Primary Care Provider (PCP) attribution pipeline from legacy SQL Server multi-stage tables to Snowflake dbt models following Data Vault 2.0 patterns.

**Legacy Source**: `HDSVault.biz.PCPAttribution_02_*` (12 staging tables + views)
**EDW3 Models**: 4 computed satellites leading to `ces_member_pcp_attribution`

## Architecture Pattern

### Progressive Attribution Pipeline

```
┌─────────────────────────────────────────────────────────┐
│  RAW VAULT (Integration Layer)                         │
├─────────────────────────────────────────────────────────┤
│ • current_provider                                      │
│ • current_provider_affiliation                          │
│ • current_provider_network_relational                   │
│ • current_member                                        │
│ • current_member_eligibility                            │
│ • current_subscriber                                    │
│ • current_subscriber_address                            │
│ • current_group                                         │
│ • current_claim_medical_header                          │
│ • current_claim_medical_line                            │
│ • current_claim_medical_procedure                       │
│                                                         │
│ DEPENDENCIES:                                           │
│ • ces_member_cob_profile                                │
│ • v_member_person_lenient                               │
│                                                         │
│ SEEDS:                                                  │
│ • seed_pcp_attribution_evaluation_dates                 │
│ • seed_pcp_attribution_provider_specialty               │
│ • seed_pcp_attribution_bihc_codes                       │
│ • seed_pcp_attribution_cms_rvu                          │
│ • seed_pcp_attribution_idaho_county                     │
│ • seed_zip_code_melissa                                 │
└──────────┬──────────────────────────────────────────────┘
           │
           ▼
┌─────────────────────────────────────────────────────────┐
│  BUSINESS VAULT (Curation Layer)                       │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  1. cs_provider_pcp_eligibility                        │
│     • Determines eligible PCPs and Specialists         │
│     • Grain: provider x eval_date                      │
│     • Replaces: NonDV_02, v_EligibleProvider           │
│                                                         │
│  2. cs_member_pcp_attribution_eligibility              │
│     • Identifies attribution-eligible members          │
│     • Grain: member x eval_date                        │
│     • Replaces: NonDV_03, 04, 04a, 05                  │
│                                                         │
│  3. cs_member_provider_visit_aggregation               │
│     • Aggregates E&M visit patterns                    │
│     • Grain: member x provider x eval_date             │
│     • Replaces: NonDV_06, 07, 08, 09                   │
│                                                         │
│  4. ces_member_pcp_attribution ⭐                       │
│     • Final attributed PCP with effectivity            │
│     • Grain: member x attribution_period               │
│     • Replaces: NonDV_10, 11, 12, views                │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

## Files Generated

### SQL Models
1. **[cs_provider_pcp_eligibility.sql](cs_provider_pcp_eligibility.sql)** - Provider eligibility (incremental)
2. **[cs_member_pcp_attribution_eligibility.sql](cs_member_pcp_attribution_eligibility.sql)** - Member eligibility (incremental)
3. **[cs_member_provider_visit_aggregation.sql](cs_member_provider_visit_aggregation.sql)** - Visit aggregation (incremental)
4. **[ces_member_pcp_attribution.sql](ces_member_pcp_attribution.sql)** - Final attribution CES (incremental)

### Configuration
- **[ces_member_pcp_attribution.yml](ces_member_pcp_attribution.yml)** - dbt schema with tests and documentation

### Documentation
- **[pcp_attribution_business_rules.md](pcp_attribution_business_rules.md)** - Business rules documentation
- **[pcp_attribution_mappings.csv](../input/pcp_attribution/pcp_attribution_mappings.csv)** - Column mapping from EDW2 to EDW3

## Key Business Rules

### 1. Provider Eligibility
- **PCPs**: Must have active network relationship with `pcp_indicator = 'Y'` during evaluation period
- **Specialists**: Must have approved specialty code, entity type 'P', exclude institutional types
- **Tax ID Logic**: Prioritize group-level Tax ID over individual provider Tax ID

### 2. Member Eligibility
- **Medical Eligibility**: Must have active medical eligibility during evaluation window
- **Primary COB**: Must have BCI as primary medical insurance (via `ces_member_cob_profile`)
- **Evaluation Window**: 18-month rolling lookback from `current_eval_date`

### 3. Visit Aggregation
- **Claim Status**: Only paid ('02') or adjudicated ('91') claims
- **E&M Identification**: Procedure has CMS RVU value OR is BIHC code
- **Visit Count**: Distinct combination of provider + service date + member
- **Exclude**: Denied procedures (`place_of_service_id = '20'`)

### 4. Attribution Logic (Clinic-Level)
- **Grouping**: Aggregate visits by Tax ID (clinic)
- **Ranking Criteria** (in order):
  1. PCP indicator (PCP wins over Specialist)
  2. Unique visit count (descending)
  3. Last visit date (most recent wins)
  4. RVU total (highest wins)
  5. Tax ID / NPI (tie-breaker)
- **Result**: Each member assigned to #1 ranked clinic

### 5. Effectivity Periods
- **Effective Date**: Current evaluation date
- **End Date**: Next evaluation date (or '9999-12-31' if most recent)
- **Is Current**: True if `end_date = '9999-12-31'`
- **No Attribution**: Members eligible but with no visits get null attribution

## Seed Files Required

The following seed files must be created before running these models:

### 1. seed_pcp_attribution_evaluation_dates.csv
```csv
current_eval_date,low_date,high_date
2024-01-01,2022-07-01,2024-01-01
2024-04-01,2022-10-01,2024-04-01
```
**Purpose**: Defines evaluation periods and 18-month lookback windows

### 2. seed_pcp_attribution_provider_specialty.csv
```csv
specialty_code,specialty_desc
001,General Practice
002,Family Practice
003,Internal Medicine
...
```
**Purpose**: Lists specialty codes eligible for PCP attribution

### 3. seed_pcp_attribution_bihc_codes.csv
```csv
cpt_code,cpt_desc
96150,Health and behavior assessment
96151,Health and behavior re-assessment
...
```
**Purpose**: Behavioral Integrated Health Care procedure codes

### 4. seed_pcp_attribution_cms_rvu.csv
```csv
hcpcs,work_rvu,pe_rvu,mp_rvu
99201,0.93,0.84,0.05
99202,1.60,1.35,0.09
...
```
**Purpose**: CMS RVU values for E&M identification

### 5. seed_pcp_attribution_idaho_county.csv
```csv
fips_county_code,county_name
16001,Ada County
16027,Canyon County
...
```
**Purpose**: Idaho service area definition

### 6. seed_zip_code_melissa.csv
```csv
zip_code,state_id,fips_county_code,fips_code
83702,ID,16001,16001
83646,ID,16027,16027
...
```
**Purpose**: Zip code to FIPS geocoding

## Model Dependencies

### External Dependencies (Must Exist First)
1. ✅ `ces_member_cob_profile` - COB status for primary insurance filtering
2. ✅ `v_member_person_lenient` - Member-to-constituent mapping
3. ✅ All seed files listed above

### Load Order
```
Seeds → COB Profile → Member Person → PCP Attribution Pipeline
                                      ├─ cs_provider_pcp_eligibility
                                      ├─ cs_member_pcp_attribution_eligibility
                                      ├─ cs_member_provider_visit_aggregation
                                      └─ ces_member_pcp_attribution
```

## Performance Considerations

### Expected Row Counts
- **cs_provider_pcp_eligibility**: ~50K providers x 12 eval periods = 600K rows
- **cs_member_pcp_attribution_eligibility**: ~300K members x 12 eval periods = 3.6M rows
- **cs_member_provider_visit_aggregation**: ~300K members x avg 3 providers = 900K rows per eval period
- **ces_member_pcp_attribution**: ~300K members x avg 5 attribution periods = 1.5M rows

### Optimization Strategy
- **Incremental Loading**: All models support incremental processing by evaluation date
- **Clustering**: All models clustered on `source` and `member_bk` or `provider_bk`
- **Merge Strategy**: Allows late-arriving data to update existing periods
- **Partition**: Consider partitioning by `current_eval_date` for visit aggregation

### Query Performance
- **Current Attribution Lookup**: Use `is_current = true` filter (very fast with clustering)
- **Point-in-Time Lookup**: Use date range `WHERE date BETWEEN effective_date AND end_date`
- **Historical Trending**: Use `effective_date` grouping for time-series analysis

## Testing Strategy

See `ces_member_pcp_attribution.yml` for full test suite. Key tests:

### Data Quality Tests
- No overlapping effectivity periods per member
- Valid effectivity dates (effective_date <= end_date)
- At most one current record per member
- is_current flag matches end_date logic

### Business Logic Tests
- Attribution visit count >= 0
- Attributed provider exists in h_provider
- Member exists in h_member
- Valid source codes and PCP indicators

### Referential Integrity
- All member_hk values exist in h_member
- All provider_hk values exist in h_provider (when not null)
- All constituent_id values exist in person table

## Migration Notes

### Consolidated from Legacy
The legacy pipeline used 12 sequential staging tables (`NonDV_01` through `NonDV_12`) plus 3 views. This has been consolidated into 4 well-structured dbt models.

**Removed**:
- Hardcoded date table (`NonDV_01_Dates`) → replaced with seed file
- Sequential staging tables → replaced with CTEs within logical models
- Cross-database joins → integrated within single Snowflake database

**Improved**:
- Incremental processing (was full refresh)
- Effectivity tracking (was point-in-time only)
- Testing framework (had no tests)
- Documentation (had minimal comments)

### Changed Business Logic
⚠️ **Important**: The following business rules changed from legacy:

1. **Date Spine**: Legacy used manually maintained date table; EDW3 uses seed file with defined evaluation periods
2. **Effectivity Periods**: EDW3 tracks attribution over time; legacy was current-state only
3. **No Attribution**: EDW3 explicitly includes members with no attribution; legacy excluded them

## Usage Examples

### Get Current PCP Attribution
```sql
SELECT
    source,
    member_bk,
    attributed_provider_npi,
    attributed_tax_id,
    attribution_visit_count
FROM {{ ref('ces_member_pcp_attribution') }}
WHERE source = 'gemstone_facets'
  AND member_bk = '12345678'
  AND is_current = true
```

### Point-in-Time PCP Attribution
```sql
SELECT
    source,
    member_bk,
    attributed_provider_npi,
    effective_date,
    end_date
FROM {{ ref('ces_member_pcp_attribution') }}
WHERE source = 'gemstone_facets'
  AND member_bk = '12345678'
  AND '2024-06-15' BETWEEN effective_date AND end_date
```

### Attribution Changes Over Time
```sql
SELECT
    member_bk,
    effective_date,
    attributed_provider_npi,
    lag(attributed_provider_npi) over (
        partition by source, member_bk
        order by effective_date
    ) as prior_provider_npi,
    case
        when attributed_provider_npi != lag(attributed_provider_npi) over (
            partition by source, member_bk
            order by effective_date
        ) then 'PCP Changed'
        else 'Same PCP'
    end as attribution_status
FROM {{ ref('ces_member_pcp_attribution') }}
WHERE source = 'gemstone_facets'
ORDER BY member_bk, effective_date
```

### Join from Claims for Attribution at Service
```sql
SELECT
    c.claim_id,
    c.service_from_date,
    a.attributed_provider_npi,
    a.attributed_pcp_indicator,
    a.attribution_visit_count
FROM {{ ref('current_claim_medical_header') }} c
LEFT JOIN {{ ref('ces_member_pcp_attribution') }} a
    ON a.source = c.source
    AND a.member_bk = c.member_bk
    AND c.service_from_date BETWEEN a.effective_date AND a.end_date
```

## Next Steps

1. ✅ Review generated dbt models
2. ⏳ Create seed files with reference data
3. ⏳ Generate `pcp_attribution_business_rules.md` for stakeholder review
4. ⏳ Run models in dev environment
5. ⏳ Validate output against legacy tables
6. ⏳ Performance testing with production volumes
7. ⏳ Stakeholder review and approval
8. ⏳ Deploy to production

## Questions for Stakeholders

1. **Evaluation Frequency**: How often should PCP attribution be recalculated? Monthly? Quarterly?
2. **Product Categories**: Confirm that product categories 'M' and 'MR' are correct for medical eligibility
3. **Specialty Codes**: Validate the list of eligible specialty codes
4. **No Attribution**: Should members without attribution be included in reporting, or filtered out?
5. **Historical Backfill**: How many historical evaluation periods should be backfilled?

## Notes

- **Naming Convention**: Following Data Vault naming: `ces_` prefix for Computed Effectivity Satellite
- **Legacy Source**: Replaces `HDSVault.biz.PCPAttribution_02_*` tables and views
- **Complexity Level**: High - most complex artifact in PCP Attribution refactoring
- **Dependencies**: Blocking on COB Profile and Member Person crosswalks (both complete)
