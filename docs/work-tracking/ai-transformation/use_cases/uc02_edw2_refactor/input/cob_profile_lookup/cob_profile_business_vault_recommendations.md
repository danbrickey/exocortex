# COB Profile Business Vault Recommendations

## Executive Summary

The COB Profile Lookup creates a temporally accurate bridge table that determines insurance coordination of benefits (COB) for members across Medical, Dental, and Drug coverage types. This is a **business vault effectivity satellite** that resolves complex date overlaps and applies hierarchical COB business rules.

**Recommendation**: Create **1 primary business vault artifact** - a computed effectivity satellite that materializes discrete date ranges with all COB attributes.

---

## Recommended Business Vault Artifact

### **Computed Effectivity Satellite: `ces_member_cob_profile`**

**Type**: Computed Effectivity Satellite (Time-series business vault object)

**Purpose**: Provides a temporally accurate lookup of member insurance coordination status across all coverage types

**Grain**: One row per member per discrete date range where COB status remains constant

**Materialization**: **Must be materialized** - complex date spine logic and cascading business rules make this expensive to compute on-the-fly

---

## Artifact Details

### Business Keys (Hub References)
```sql
hub_member_key              -- FK to hub_member
source                      -- Source system (GEM/FCT)
member_bk                   -- Member business key (MEME_CK)
```

### Effectivity Dates (SCD2 Pattern)
```sql
effective_date              -- Start of this COB period
end_date                    -- End of this COB period (inclusive)
is_current                  -- Boolean: is this the current/active record?
```

### Member Demographics (Denormalized for convenience)
```sql
group_id                    -- GRGR_ID (for joins to other artifacts)
subscriber_id               -- SBSB_ID (for joins to other artifacts)
member_suffix               -- MEME_SFX (family position)
member_first_name           -- MEME_FIRST_NAME (for display)
```

### Medical Coverage Attributes
```sql
medical_coverage            -- 'Yes'/'No' - Has active medical eligibility
has_medical_cob             -- 'Yes'/'No' - Has COB coordination for medical
medical_cob_order           -- 'Primary'/'Secondary'/'Tertiary'/'No'
medical_is_bci_primary      -- 'Yes'/'No' - BCI is primary medical payer
medical_is_bci_secondary    -- 'Yes'/'No' - BCI is secondary medical payer
medical_is_bci_tertiary     -- 'Yes'/'No' - BCI is tertiary medical payer
medical_carrier_id          -- MCRE_ID for medical COB carrier
medical_two_blues           -- 'Yes'/'No' - Two Blues scenario detected
```

### Dental Coverage Attributes
```sql
dental_coverage             -- 'Yes'/'No' - Has active dental eligibility
has_dental_cob              -- 'Yes'/'No' - Has COB coordination for dental
dental_cob_order            -- 'Primary'/'Secondary'/'Tertiary'/'No'
dental_is_bci_primary       -- 'Yes'/'No' - BCI is primary dental payer
dental_is_bci_secondary     -- 'Yes'/'No' - BCI is secondary dental payer
dental_is_bci_tertiary      -- 'Yes'/'No' - BCI is tertiary dental payer
dental_carrier_id           -- MCRE_ID for dental COB carrier
dental_two_blues            -- 'Yes'/'No' - Two Blues scenario detected
```

### Drug/Pharmacy Coverage Attributes
```sql
drug_coverage               -- 'Yes'/'No' - Has active pharmacy eligibility
has_drug_cob                -- 'Yes'/'No' - Has COB coordination for drug
drug_cob_order              -- 'Primary'/'Secondary'/'Tertiary'/'No'
drug_is_bci_primary         -- 'Yes'/'No' - BCI is primary drug payer
drug_is_bci_secondary       -- 'Yes'/'No' - BCI is secondary drug payer
drug_is_bci_tertiary        -- 'Yes'/'No' - BCI is tertiary drug payer
drug_two_blues              -- 'Yes'/'No' - Two Blues scenario detected
```

### Metadata
```sql
load_date                   -- dbt run timestamp
record_source               -- 'COB_PROFILE_CALCULATION'
hash_diff                   -- Hash of all descriptive attributes (for change detection)
```

---

## Business Logic Flow

The dbt model should implement the logic in this sequence:

### 1. **Date Spine Construction** (CTE: `date_spine`)
Create all possible discrete date ranges by:
- Collecting all "FromDates" (elig eff dates, COB eff dates, day-after term dates)
- Collecting all "ThruDates" (elig term dates, COB term dates, day-before eff dates)
- Cross-joining FromDates to ThruDates where FromDate <= ThruDate
- De-duplicating to shortest valid interval using `ROW_NUMBER()` partitioned by member + FromDate

**Purpose**: Creates non-overlapping time periods where COB status can change

### 2. **Initialize Coverage Flags** (CTE: `coverage_base`)
For each date range:
- Default all coverage flags to 'No'
- Default all COB order to 'No'
- Default all Two Blues flags to 'No'
- Set `medical_coverage = 'Yes'` if member has Medical ('M') eligibility during this period
- Set `dental_coverage = 'Yes'` if member has Dental ('D') eligibility during this period
- Set `drug_coverage = 'Yes'` if member has Medical ('M') or Pharmacy ('R') eligibility during this period

### 3. **Join Member Demographics** (CTE: `with_demographics`)
Join to `current_member`, `current_subscriber`, `current_group` to get:
- group_id, subscriber_id, member_suffix, member_first_name
- record_source

### 4. **Apply Primary COB Rules** (CTE: `primary_cob`)
For members with active coverage, join to `current_member_cob` where:
- COB effective/term dates overlap with date range
- `insurance_order <> 'U'` (not Unknown)
- Exclude dental-type COB for medical: `insurance_type <> 'D'`
- Exclude Medicare Part D codes for medical (join to `seed_cob_medicare_part_d_primary`)

Set:
- `has_medical_cob = 'Yes'`, `medical_cob_order = 'Primary'`
- `has_drug_cob = 'Yes'`, `drug_cob_order = 'Primary'`
- `medical_carrier_id = coverage_id`
- `medical_two_blues = 'Yes'` if coverage_id in `seed_cob_two_blues_carriers`

Repeat for Dental where `insurance_type = 'D'`

### 5. **Override to Secondary COB** (CTE: `secondary_cob`)
For members where COB exists with `insurance_order = 'P'` (BCI is secondary):
- Override `medical_cob_order = 'Secondary'` (if was 'Primary')
- Override `drug_cob_order = 'Secondary'`
- Override `dental_cob_order = 'Secondary'`
- Update Two Blues flags
- Update carrier_id

### 6. **Override to Tertiary COB** (CTE: `tertiary_cob`)
For members where COB exists with `insurance_order = 'S'` (BCI is tertiary):
- Override `medical_cob_order = 'Tertiary'` (only if currently 'Secondary')
- Override `drug_cob_order = 'Tertiary'`
- Override `dental_cob_order = 'Tertiary'`
- Update Two Blues flags

### 7. **Apply Drug Coverage Exclusion** (CTE: `drug_exclusion`)
For members without Medical ('M') or Pharmacy ('R') eligibility:
- Set `drug_coverage = 'No'`
- Set `has_drug_cob = 'No'`
- Set `drug_cob_order = 'No'`

### 8. **Calculate Indicator Flags** (CTE: `with_indicators`)
Based on final COB order values, set the BCI position flags:
```sql
medical_is_bci_primary = CASE WHEN medical_cob_order = 'Primary' THEN 'Yes' ELSE 'No' END
medical_is_bci_secondary = CASE WHEN medical_cob_order = 'Secondary' THEN 'Yes' ELSE 'No' END
medical_is_bci_tertiary = CASE WHEN medical_cob_order = 'Tertiary' THEN 'Yes' ELSE 'No' END
-- Repeat for dental and drug
```

### 9. **Filter Invalid Records** (CTE: `filtered`)
Remove date ranges where:
- `medical_coverage = 'No'` AND `dental_coverage = 'No'` AND `drug_coverage = 'No'` (no coverage at all)
- `effective_date IN ('9999-12-31', '2200-01-01')` (invalid future dates)

### 10. **Final Output** (CTE: `final`)
Add:
- `is_current = (end_date = '9999-12-31')` flag
- `hash_diff` calculation for change detection
- `load_date` metadata

---

## Data Vault Pattern: Computed Effectivity Satellite

### Why This Pattern?

1. **Time-Variant Business Rules**: COB status changes over time based on eligibility periods and COB record dates
2. **Complex Date Logic**: The date spine creates discrete, non-overlapping periods
3. **Cascading Logic**: COB order determined through sequential rule application (Primary → Secondary → Tertiary)
4. **Multi-Attribute Changes**: Medical, Dental, and Drug COB can change independently
5. **Reusability**: Many downstream processes need "What was this member's COB status on date X?"

### Effectivity Pattern Benefits

- **Point-in-Time Queries**: Easy to find COB status for any date
- **No Gaps or Overlaps**: Every day in a member's history has exactly one row
- **Change Tracking**: Can see when COB status changed and why
- **Performance**: Pre-computed rather than computed at query time

---

## Usage Examples

### 1. Current COB Status for a Member
```sql
SELECT *
FROM {{ ref('ces_member_cob_profile') }}
WHERE source = 'GEM'
  AND member_bk = 12345678
  AND is_current = TRUE
```

### 2. COB Status as of Specific Date (Point-in-Time)
```sql
SELECT *
FROM {{ ref('ces_member_cob_profile') }}
WHERE source = 'GEM'
  AND member_bk = 12345678
  AND '2024-03-15' BETWEEN effective_date AND end_date
```

### 3. Join from Claims to Get COB Status at Service Date
```sql
SELECT
    c.claim_id,
    c.service_date,
    c.member_bk,
    cob.medical_cob_order,
    cob.medical_is_bci_primary,
    cob.medical_carrier_id
FROM {{ ref('current_claim_medical_header') }} c
LEFT JOIN {{ ref('ces_member_cob_profile') }} cob
    ON c.source = cob.source
    AND c.member_bk = cob.member_bk
    AND c.service_date BETWEEN cob.effective_date AND cob.end_date
WHERE c.source = 'GEM'
```

### 4. Members with Two Blues Coverage
```sql
SELECT
    source,
    member_bk,
    effective_date,
    end_date,
    medical_two_blues,
    dental_two_blues,
    drug_two_blues
FROM {{ ref('ces_member_cob_profile') }}
WHERE (medical_two_blues = 'Yes'
    OR dental_two_blues = 'Yes'
    OR drug_two_blues = 'Yes')
  AND is_current = TRUE
```

---

## Incremental Loading Strategy

### Initial Load
Full refresh to build entire history from raw vault

### Incremental Pattern
```sql
{{ config(
    materialized='incremental',
    unique_key=['source', 'member_bk', 'effective_date'],
    incremental_strategy='merge'
) }}

WITH new_or_changed_members AS (
    -- Identify members with eligibility or COB changes since last run
    SELECT DISTINCT source, member_bk
    FROM {{ ref('current_member_eligibility') }}
    WHERE load_date >= (SELECT MAX(load_date) FROM {{ this }})

    UNION

    SELECT DISTINCT source, member_bk
    FROM {{ ref('current_member_cob') }}
    WHERE load_date >= (SELECT MAX(load_date) FROM {{ this }})
)
-- Then only process date ranges for these members
```

### Performance Optimization
- Partition by `source` and cluster by `member_bk`, `effective_date`
- Index on `(source, member_bk, effective_date, end_date)` for date range queries
- Consider separate materialized views for `is_current = TRUE` for fast current-state queries

---

## Downstream Usage

This artifact is a **blocking dependency** for:

1. **PCP Attribution** (`bridge_member_pcp_attribution`)
   - Filters to members with `medical_is_bci_primary = 'Yes'`
   - Uses date range for temporal joins

2. **Claims Processing** (various fact tables)
   - Determines billing order for claim adjudication
   - Identifies Two Blues scenarios requiring special handling

3. **Member Eligibility Snapshots** (dimensions/facts)
   - Provides COB status for eligibility reporting
   - Tracks COB changes over time

4. **Quality Measures & HEDIS**
   - Identifies attribution period for quality metrics
   - Filters to primary coverage for measure denominators

5. **Financial Reporting**
   - Calculates primary vs secondary claim volumes
   - Tracks Two Blues financial impact

---

## Testing Recommendations

### Data Quality Tests

1. **No Gaps in Coverage**
```sql
-- Every member should have continuous date coverage once they appear
-- (next period's effective_date = prior period's end_date + 1 day)
```

2. **No Overlaps**
```sql
-- No member should have overlapping date ranges
SELECT source, member_bk, COUNT(*)
FROM {{ ref('ces_member_cob_profile') }}
WHERE effective_date <= '2024-12-31'
  AND end_date >= '2024-01-01'
GROUP BY source, member_bk
HAVING COUNT(*) > 1
```

3. **Valid Date Ranges**
```sql
-- effective_date should always be <= end_date
-- end_date = '9999-12-31' only for current records
```

4. **COB Order Consistency**
```sql
-- If medical_cob_order = 'Primary', then medical_is_bci_primary = 'Yes'
-- If has_medical_cob = 'No', then medical_cob_order = 'No'
```

5. **Two Blues Logic**
```sql
-- If medical_two_blues = 'Yes', then medical_carrier_id should exist in seed_cob_two_blues_carriers
```

### Business Rule Tests

1. **Medicare Part D Exclusions**
   - Members with MEDPARTD in medical should have drug logic applied correctly

2. **Cascading COB Order**
   - Tertiary only appears when Secondary existed first

3. **Coverage Type Independence**
   - Member can have different COB order for Medical vs Dental vs Drug

---

## Materialization Recommendation

```yaml
# models/business_vault/member/ces_member_cob_profile.sql
{{
  config(
    materialized='incremental',
    unique_key=['source', 'member_bk', 'effective_date'],
    cluster_by=['source', 'member_bk'],
    incremental_strategy='merge',
    on_schema_change='fail',
    tags=['business_vault', 'cob', 'member']
  )
}}
```

**Rationale**:
- **Incremental**: Large member population, only some change daily
- **Merge Strategy**: Allows for late-arriving COB changes to update existing periods
- **Clustering**: Optimizes for member-level queries and date range scans
- **Fail on Schema Change**: COB attributes are critical; changes require careful review

---

## Summary

**Artifact**: `ces_member_cob_profile` (Computed Effectivity Satellite)

**Complexity**: High (date spine + cascading rules)

**Dependencies**:
- Raw vault: `current_member_eligibility`, `current_member_cob`, `current_member`, `current_subscriber`, `current_group`
- Seeds: `seed_cob_two_blues_carriers`, `seed_cob_medicare_part_d_primary`, `seed_cob_medicare_part_d_secondary`

**Dependents**: PCP Attribution, Claims Processing, Eligibility Reporting, Quality Measures

**Refresh Frequency**: Daily (incremental)

**Row Count Estimate**: ~500K-2M rows (one row per member per COB change period)

---

## Next Steps

1. Review and approve this business vault design
2. Generate dbt model SQL implementing the 10-step logic flow
3. Create dbt schema.yml with tests
4. Document business rules in plain language for business stakeholders
