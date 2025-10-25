# COB Profile Mapping Validation

## ✅ Validation Results: **COMPLETE & VALID**

All raw vault source tables and columns have been successfully mapped to EDW3 equivalents.

---

## Mapping Summary

### Total Mappings
- **5 raw vault tables** mapped
- **26 columns** mapped across all tables
- **0 missing mappings** ✅

### Table-by-Table Validation

#### 1. ✅ `v_membereligibilityextended_combined_current` → `current_member_eligibility`
| EDW2 Column | EDW3 Column | Status | Usage |
|-------------|-------------|--------|-------|
| bkcc_member | source | ✅ | Source system identifier (GEM/FCT) |
| meme_ck | member_bk | ✅ | Member business key |
| mepe_eff_dt | elig_eff_date | ✅ | Eligibility effective date (date spine) |
| mepe_term_dt | elig_term_date | ✅ | Eligibility termination date (date spine) |
| cspd_cat | product_category_bk | ✅ | Coverage category ('M'=Medical, 'D'=Dental, 'R'=Pharmacy) |
| mepe_elig_ind | eligibility_ind | ✅ | Eligibility indicator ('Y'/'N') |

**6 of 6 columns mapped** ✅

---

#### 2. ✅ `v_membercobextended_combined_current` → `current_member_cob`
| EDW2 Column | EDW3 Column | Status | Usage |
|-------------|-------------|--------|-------|
| bkcc_member | source | ✅ | Source system identifier |
| meme_ck | member_bk | ✅ | Member business key |
| mecb_eff_dt | cob_eff_date | ✅ | COB effective date (date spine) |
| mecb_term_dt | cob_term_date | ✅ | COB termination date (date spine) |
| mcre_id | coverage_id | ✅ | Insurance carrier code (joins to seed files) |
| mecb_insur_order | insurance_order | ✅ | COB order indicator ('P'=Primary elsewhere, 'S'=Secondary, 'U'=Unknown) |
| mecb_insur_type | insurance_type | ✅ | Coverage type ('D'=Dental, other=Medical/Drug) |

**7 of 7 columns mapped** ✅

---

#### 3. ✅ `v_member_combined_current` → `current_member`
| EDW2 Column | EDW3 Column | Status | Usage |
|-------------|-------------|--------|-------|
| bkcc_member | source | ✅ | Source system identifier |
| meme_ck | member_bk | ✅ | Member business key |
| sbsb_ck | subscriber_bk | ✅ | Subscriber business key |
| grgr_ck | group_bk | ✅ | Group business key |
| meme_sfx | member_suffix | ✅ | Member suffix (family position) |
| meme_first_name | member_first_name | ✅ | Member first name (for output) |
| dss_record_source | edp_record_source | ✅ | Record source metadata |

**7 of 7 columns mapped** ✅

---

#### 4. ✅ `v_subscriber_combined_current` → `current_subscriber`
| EDW2 Column | EDW3 Column | Status | Usage |
|-------------|-------------|--------|-------|
| bkcc_subscriber | source | ✅ | Source system identifier |
| sbsb_ck | subscriber_bk | ✅ | Subscriber business key |
| sbsb_id | subscriber_id | ✅ | Subscriber ID (natural key component) |

**3 of 3 columns mapped** ✅

---

#### 5. ✅ `v_group_combined_current` → `current_group`
| EDW2 Column | EDW3 Column | Status | Usage |
|-------------|-------------|--------|-------|
| bkcc_group | source | ✅ | Source system identifier |
| grgr_ck | group_bk | ✅ | Group business key |
| grgr_id | group_id | ✅ | Group ID (natural key component) |

**3 of 3 columns mapped** ✅

---

## EDW3 Table Analysis

### Naming Consistency ✅
All EDW3 table names follow the `current_<entity>` pattern consistently:
- `current_member_eligibility`
- `current_member_cob`
- `current_member`
- `current_subscriber`
- `current_group`

### Column Naming Consistency ✅
Column names follow clear patterns:
- Business keys: `*_bk` (e.g., `member_bk`, `subscriber_bk`, `group_bk`)
- Source identifiers: `source`
- Date fields: `*_eff_date`, `*_term_date`
- Descriptive attributes: snake_case (e.g., `member_first_name`, `eligibility_ind`)

---

## Data Lineage Verification

### Date Spine Components ✅
All four date sources are mapped:
1. **Eligibility Effective Dates**: `current_member_eligibility.elig_eff_date`
2. **Eligibility Term Dates**: `current_member_eligibility.elig_term_date`
3. **COB Effective Dates**: `current_member_cob.cob_eff_date`
4. **COB Term Dates**: `current_member_cob.cob_term_date`

### COB Business Logic Fields ✅
All critical fields for COB determination are mapped:
- **Coverage Type**: `product_category_bk` ('M', 'D', 'R')
- **Insurance Carrier**: `coverage_id` (MCRE_ID - joins to seed files)
- **Insurance Order**: `insurance_order` ('P', 'S', 'U')
- **Insurance Type**: `insurance_type` ('D' for dental)
- **Eligibility Indicator**: `eligibility_ind`

### Join Keys ✅
All necessary join keys are present:
- Member joins: `source` + `member_bk`
- Subscriber joins: `source` + `subscriber_bk`
- Group joins: `source` + `group_bk`

---

## Validation Checks Performed

### ✅ Completeness Check
- All 26 columns from legacy SQL have EDW3 mappings
- No `NULL` or blank values in `new_table_name` or `new_column_name`

### ✅ Semantic Validation
- Column purposes align with legacy usage
- Date fields map to date fields
- Keys map to keys
- Indicators map to indicators

### ✅ Business Rule Support
All columns required for COB logic are present:
- ✅ Date spine construction (4 date columns)
- ✅ Coverage type determination (CSPD_CAT → product_category_bk)
- ✅ COB order logic (MECB_INSUR_ORDER → insurance_order)
- ✅ Insurance type filtering (MECB_INSUR_TYPE → insurance_type)
- ✅ Carrier identification (MCRE_ID → coverage_id)
- ✅ Member/Subscriber/Group relationships (all _bk columns)

---

## Recommendations

### ✅ Ready to Proceed
The mappings are **complete and validated**. You can proceed with:
1. Business vault artifact recommendations
2. dbt model generation
3. Testing strategy

### Notes for Implementation

#### Join Pattern Example
```sql
-- Standard join pattern for EDW3
FROM {{ ref('current_member_eligibility') }} as elig
JOIN {{ ref('current_member') }} as mem
    ON elig.source = mem.source
    AND elig.member_bk = mem.member_bk
JOIN {{ ref('current_subscriber') }} as sub
    ON mem.source = sub.source
    AND mem.subscriber_bk = sub.subscriber_bk
```

#### Date Spine Query Pattern
```sql
-- FromDates: all possible period start dates
SELECT source, member_bk, elig_eff_date as from_date
FROM {{ ref('current_member_eligibility') }}
WHERE product_category_bk IN ('M', 'D')
  AND eligibility_ind = 'Y'
UNION
SELECT source, member_bk, cob_eff_date as from_date
FROM {{ ref('current_member_cob') }}
-- ... etc
```

---

## Conclusion

**Status**: ✅ **VALIDATED - READY TO PROCEED**

All raw vault mappings are complete, semantically correct, and support the full COB Profile business logic. No issues found.
