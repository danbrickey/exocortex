# COB Profile - EDW3 Refactoring Output

## Generated Artifacts

### 1. **ces_member_cob_profile.sql**

**Type**: Computed Effectivity Satellite (dbt model)

**Purpose**: Provides temporally accurate COB (Coordination of Benefits) status for members

**Complexity**: High - 17 CTEs implementing complex date spine and cascading business logic

---

## Model Structure

### CTE Breakdown (17 Steps)

| # | CTE Name | Purpose | Complexity |
|---|----------|---------|------------|
| 1 | `incremental_members` | Identify changed members for incremental processing | Low |
| 2 | `from_dates` | Collect all possible period start dates | Medium |
| 3 | `thru_dates` | Collect all possible period end dates | Medium |
| 4 | `date_spine` | Build discrete, non-overlapping date ranges | High |
| 5 | `date_spine_deduped` | Deduplicate to shortest valid interval | Medium |
| 6 | `coverage_base` | Initialize all flags to 'No' | Low |
| 7 | `with_eligibility` | Set coverage flags based on eligibility | Medium |
| 8 | `with_demographics` | Join member/subscriber/group demographics | Low |
| 9 | `primary_medical_cob` | Apply primary COB rules for medical/drug | High |
| 10 | `primary_dental_cob` | Apply primary COB rules for dental | Medium |
| 11 | `secondary_medical_cob` | Override to secondary for medical/drug | High |
| 12 | `secondary_dental_cob` | Override to secondary for dental | Medium |
| 13 | `tertiary_medical_cob` | Override to tertiary for medical/drug | High |
| 14 | `tertiary_dental_cob` | Override to tertiary for dental | Medium |
| 15 | `drug_exclusion` | Remove drug coverage if no M/R eligibility | Medium |
| 16 | `with_indicators` | Calculate BCI position indicator flags | Low |
| 17 | `filtered` | Remove invalid records (no coverage) | Low |
| 18 | `final` | Add hub key and metadata | Low |

---

## Key Features

### ✅ **Incremental Processing**
```sql
{% if is_incremental() %}
-- Only process members with changes since last run
-- Checks both eligibility and COB tables for changes
{% else %}
-- Full refresh: process all members
{% endif %}
```

### ✅ **Date Spine Logic**
Creates discrete, non-overlapping date ranges by:
1. Collecting all possible "from dates" (eff dates, day after term dates)
2. Collecting all possible "thru dates" (term dates, day before eff dates)
3. Cross-joining and selecting shortest valid interval per member

### ✅ **Cascading COB Order**
Applies rules in sequence:
1. **Primary**: Default if coverage exists, no COB or COB record shows BCI primary
2. **Secondary**: Override if `insurance_order = 'P'` (other insurer is primary)
3. **Tertiary**: Override if `insurance_order = 'S'` and currently secondary

### ✅ **Two Blues Detection**
Joins to `seed_cob_two_blues_carriers` to identify when member has multiple Blues coverages

### ✅ **Medicare Part D Handling**
Excludes specific MCRE_IDs using seed files:
- `seed_cob_medicare_part_d_primary`
- `seed_cob_medicare_part_d_secondary`

---

## Configuration

```yaml
materialized: incremental
unique_key: ['source', 'member_bk', 'effective_date']
cluster_by: ['source', 'member_bk']
incremental_strategy: merge
on_schema_change: fail
```

### Why These Settings?

- **Incremental + Merge**: Large member population, only some change daily
- **Clustering**: Optimizes for member-level queries and date range scans
- **Fail on schema change**: COB attributes are critical; changes require review

---

## Dependencies

### Raw Vault Tables
- `current_member_eligibility` - Eligibility periods (Medical, Dental, Pharmacy)
- `current_member_cob` - COB insurance records
- `current_member` - Member demographics
- `current_subscriber` - Subscriber info
- `current_group` - Group info

### Hubs
- `h_member` - Member hub (for `member_hk` surrogate key)

### Seed Files
- `seed_cob_two_blues_carriers` - List of Blues carrier codes
- `seed_cob_medicare_part_d_primary` - Medicare Part D primary rules
- `seed_cob_medicare_part_d_secondary` - Medicare Part D secondary rules

---

## Output Schema

### Hub Keys
- `member_hk` - FK to h_member (surrogate key)
- `source` - Source system (gemstone_facets/legacy_facets)
- `member_bk` - Member business key (MEME_CK)

### Effectivity Dates
- `effective_date` - Start of COB period
- `end_date` - End of COB period (inclusive)
- `is_current` - Boolean flag (true if end_date = '9999-12-31')

### Demographics (7 columns)
- `group_id`, `subscriber_id`, `member_suffix`, `member_first_name`

### Medical COB (8 columns)
- `medical_coverage`, `has_medical_cob`, `medical_cob_order`
- `medical_is_bci_primary`, `medical_is_bci_secondary`, `medical_is_bci_tertiary`
- `medical_carrier_id`, `medical_two_blues`

### Dental COB (8 columns)
- `dental_coverage`, `has_dental_cob`, `dental_cob_order`
- `dental_is_bci_primary`, `dental_is_bci_secondary`, `dental_is_bci_tertiary`
- `dental_carrier_id`, `dental_two_blues`

### Drug COB (7 columns)
- `drug_coverage`, `has_drug_cob`, `drug_cob_order`
- `drug_is_bci_primary`, `drug_is_bci_secondary`, `drug_is_bci_tertiary`
- `drug_two_blues`

### Metadata (3 columns)
- `load_date` - dbt run timestamp
- `record_source` - Source system metadata
- `hash_diff` - Hash of descriptive attributes

**Total Columns**: 36

---

## Usage Examples

### Get Current COB Status
```sql
SELECT *
FROM {{ ref('ces_member_cob_profile') }}
WHERE source = 'gemstone_facets'
  AND member_bk = 12345678
  AND is_current = TRUE
```

### Point-in-Time COB Status
```sql
SELECT *
FROM {{ ref('ces_member_cob_profile') }}
WHERE source = 'gemstone_facets'
  AND member_bk = 12345678
  AND '2024-03-15' BETWEEN effective_date AND end_date
```

### Join from Claims
```sql
SELECT
    c.claim_id,
    cob.medical_is_bci_primary,
    cob.medical_cob_order
FROM {{ ref('current_claim_medical_header') }} c
LEFT JOIN {{ ref('ces_member_cob_profile') }} cob
    ON c.source = cob.source
    AND c.member_bk = cob.member_bk
    AND c.service_date BETWEEN cob.effective_date AND cob.end_date
```

---

## Performance Considerations

### Expected Row Count
- **Estimate**: 500K - 2M rows
- **Grain**: One row per member per COB change period
- **Typical member**: 3-10 rows over member lifetime

### Query Optimization
- Clustered on `source` and `member_bk` for member-level queries
- Date range queries benefit from clustering
- Consider materialized view for `is_current = TRUE` subset

### Incremental Processing
- Only processes members with changes to eligibility or COB
- Uses `load_date >= MAX(load_date)` for change detection
- Merge strategy allows late-arriving data to update existing periods

---

## Testing Strategy

See `ces_member_cob_profile.yml` for full test suite (to be generated next).

Key tests:
- No gaps in member date coverage
- No overlapping date ranges per member
- Valid effectivity dates (effective_date <= end_date)
- COB order consistency with indicator flags
- Two Blues carrier IDs exist in seed file

---

## Next Steps

1. ✅ Review generated dbt model
2. ✅ Generate `ces_member_cob_profile.yml` with tests
3. ✅ Create business rules documentation for stakeholders
4. ✅ Review and approve business rules with stakeholders
5. ✅ File approved business rules: `member_cob_profile_business_rules.md` → `docs\architecture\rules\membership\`
6. ⏳ Run model in dev environment
7. ⏳ Validate output against legacy `r_COBProfileLookup`

---

## Notes

- **Naming Convention Update**: Changed `hub_member_key` → `member_hk` per engineer feedback
- **Legacy Source**: Replaces `HDSVault.biz.spCOBProfileLookup`
- **Complexity Level**: High - most complex artifact in COB Profile refactoring
- **Critical Path**: Blocking dependency for PCP Attribution pipeline
