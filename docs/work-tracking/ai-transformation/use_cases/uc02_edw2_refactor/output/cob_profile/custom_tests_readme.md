# Custom dbt Tests for COB Profile

This document provides SQL implementations for the custom data quality tests defined in `ces_member_cob_profile.yml`.

---

## Test 1: No Overlapping Date Ranges

**File**: `tests/custom/no_overlapping_date_ranges.sql`

**Purpose**: Ensures no member has overlapping COB periods

```sql
-- tests/custom/no_overlapping_date_ranges.sql
-- Validates no member has overlapping date ranges

SELECT
    source,
    member_bk,
    effective_date,
    end_date,
    COUNT(*) as overlapping_count
FROM {{ ref('ces_member_cob_profile') }}
GROUP BY source, member_bk, effective_date, end_date
HAVING overlapping_count > 1
```

---

## Test 2: Valid Effectivity Dates

**File**: `tests/custom/valid_effectivity_dates.sql`

**Purpose**: Ensures effective_date <= end_date

```sql
-- tests/custom/valid_effectivity_dates.sql
-- Validates that effective dates are on or before end dates

SELECT
    member_hk,
    source,
    member_bk,
    effective_date,
    end_date
FROM {{ ref('ces_member_cob_profile') }}
WHERE effective_date > end_date
```

---

## Test 3: COB Order Indicator Consistency

**File**: `tests/custom/cob_order_indicator_consistency.sql`

**Purpose**: Validates indicator flags match COB order values

```sql
-- tests/custom/cob_order_indicator_consistency.sql
-- Validates COB order flags are consistent with COB order values

WITH validation AS (
    SELECT
        member_hk,
        source,
        member_bk,
        effective_date,

        -- Medical validations
        CASE
            WHEN medical_cob_order = 'Primary' AND medical_is_bci_primary <> 'Yes' THEN 1
            WHEN medical_cob_order = 'Secondary' AND medical_is_bci_secondary <> 'Yes' THEN 1
            WHEN medical_cob_order = 'Tertiary' AND medical_is_bci_tertiary <> 'Yes' THEN 1
            WHEN medical_cob_order = 'No'
                AND (medical_is_bci_primary = 'Yes' OR medical_is_bci_secondary = 'Yes' OR medical_is_bci_tertiary = 'Yes') THEN 1
            ELSE 0
        END AS medical_inconsistent,

        -- Dental validations
        CASE
            WHEN dental_cob_order = 'Primary' AND dental_is_bci_primary <> 'Yes' THEN 1
            WHEN dental_cob_order = 'Secondary' AND dental_is_bci_secondary <> 'Yes' THEN 1
            WHEN dental_cob_order = 'Tertiary' AND dental_is_bci_tertiary <> 'Yes' THEN 1
            WHEN dental_cob_order = 'No'
                AND (dental_is_bci_primary = 'Yes' OR dental_is_bci_secondary = 'Yes' OR dental_is_bci_tertiary = 'Yes') THEN 1
            ELSE 0
        END AS dental_inconsistent,

        -- Drug validations
        CASE
            WHEN drug_cob_order = 'Primary' AND drug_is_bci_primary <> 'Yes' THEN 1
            WHEN drug_cob_order = 'Secondary' AND drug_is_bci_secondary <> 'Yes' THEN 1
            WHEN drug_cob_order = 'Tertiary' AND drug_is_bci_tertiary <> 'Yes' THEN 1
            WHEN drug_cob_order = 'No'
                AND (drug_is_bci_primary = 'Yes' OR drug_is_bci_secondary = 'Yes' OR drug_is_bci_tertiary = 'Yes') THEN 1
            ELSE 0
        END AS drug_inconsistent

    FROM {{ ref('ces_member_cob_profile') }}
)

SELECT *
FROM validation
WHERE medical_inconsistent = 1
   OR dental_inconsistent = 1
   OR drug_inconsistent = 1
```

---

## Test 4: Two Blues Carrier Validation

**File**: `tests/custom/two_blues_carrier_exists_in_seed.sql`

**Purpose**: Validates Two Blues carrier IDs exist in seed file

```sql
-- tests/custom/two_blues_carrier_exists_in_seed.sql
-- Validates that carriers marked as "Two Blues" exist in the seed file

WITH medical_check AS (
    SELECT
        cob.member_hk,
        cob.source,
        cob.member_bk,
        cob.effective_date,
        cob.medical_carrier_id,
        'medical' AS coverage_type
    FROM {{ ref('ces_member_cob_profile') }} cob
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} seed
        ON TRIM(cob.medical_carrier_id) = seed.mcre_id
    WHERE cob.medical_two_blues = 'Yes'
      AND seed.mcre_id IS NULL
),

dental_check AS (
    SELECT
        cob.member_hk,
        cob.source,
        cob.member_bk,
        cob.effective_date,
        cob.dental_carrier_id AS medical_carrier_id,
        'dental' AS coverage_type
    FROM {{ ref('ces_member_cob_profile') }} cob
    LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} seed
        ON TRIM(cob.dental_carrier_id) = seed.mcre_id
    WHERE cob.dental_two_blues = 'Yes'
      AND seed.mcre_id IS NULL
)

SELECT * FROM medical_check
UNION ALL
SELECT * FROM dental_check
```

---

## Test 5: At Least One Coverage Type

**File**: `tests/custom/at_least_one_coverage_type.sql`

**Purpose**: Ensures every record has at least one coverage type

```sql
-- tests/custom/at_least_one_coverage_type.sql
-- Validates that every record has at least one coverage type = 'Yes'

SELECT
    member_hk,
    source,
    member_bk,
    effective_date,
    medical_coverage,
    dental_coverage,
    drug_coverage
FROM {{ ref('ces_member_cob_profile') }}
WHERE medical_coverage = 'No'
  AND dental_coverage = 'No'
  AND drug_coverage = 'No'
```

---

## Test 6: COB Requires Coverage

**File**: `tests/custom/cob_requires_coverage.sql`

**Purpose**: Validates you cannot have COB without active coverage

```sql
-- tests/custom/cob_requires_coverage.sql
-- Validates that COB coordination requires active coverage

SELECT
    member_hk,
    source,
    member_bk,
    effective_date,

    -- Medical validation
    medical_coverage,
    has_medical_cob,

    -- Dental validation
    dental_coverage,
    has_dental_cob,

    -- Drug validation
    drug_coverage,
    has_drug_cob

FROM {{ ref('ces_member_cob_profile') }}
WHERE (has_medical_cob = 'Yes' AND medical_coverage = 'No')
   OR (has_dental_cob = 'Yes' AND dental_coverage = 'No')
   OR (has_drug_cob = 'Yes' AND drug_coverage = 'No')
```

---

## Test 7: Only One Current Per Member

**File**: `tests/custom/only_one_current_per_member.sql`

**Purpose**: Ensures each member has at most one current record

```sql
-- tests/custom/only_one_current_per_member.sql
-- Validates each member has at most one current (is_current = TRUE) record

SELECT
    source,
    member_bk,
    COUNT(*) AS current_record_count
FROM {{ ref('ces_member_cob_profile') }}
WHERE is_current = TRUE
GROUP BY source, member_bk
HAVING COUNT(*) > 1
```

---

## Test 8: Tertiary Requires Secondary History

**File**: `tests/custom/tertiary_requires_secondary_history.sql`

**Purpose**: Validates cascading COB logic (Tertiary only after Secondary)

```sql
-- tests/custom/tertiary_requires_secondary_history.sql
-- Validates that Tertiary COB order only appears after Secondary in member history

WITH tertiary_records AS (
    SELECT
        source,
        member_bk,
        effective_date,
        'medical' AS coverage_type
    FROM {{ ref('ces_member_cob_profile') }}
    WHERE medical_cob_order = 'Tertiary'

    UNION ALL

    SELECT
        source,
        member_bk,
        effective_date,
        'dental' AS coverage_type
    FROM {{ ref('ces_member_cob_profile') }}
    WHERE dental_cob_order = 'Tertiary'

    UNION ALL

    SELECT
        source,
        member_bk,
        effective_date,
        'drug' AS coverage_type
    FROM {{ ref('ces_member_cob_profile') }}
    WHERE drug_cob_order = 'Tertiary'
),

prior_secondary AS (
    SELECT DISTINCT
        tr.source,
        tr.member_bk,
        tr.coverage_type,
        tr.effective_date AS tertiary_date,
        CASE tr.coverage_type
            WHEN 'medical' THEN MAX(CASE WHEN cob.medical_cob_order = 'Secondary' AND cob.effective_date < tr.effective_date THEN 1 ELSE 0 END)
            WHEN 'dental' THEN MAX(CASE WHEN cob.dental_cob_order = 'Secondary' AND cob.effective_date < tr.effective_date THEN 1 ELSE 0 END)
            WHEN 'drug' THEN MAX(CASE WHEN cob.drug_cob_order = 'Secondary' AND cob.effective_date < tr.effective_date THEN 1 ELSE 0 END)
        END AS had_prior_secondary
    FROM tertiary_records tr
    LEFT JOIN {{ ref('ces_member_cob_profile') }} cob
        ON tr.source = cob.source
        AND tr.member_bk = cob.member_bk
        AND cob.effective_date < tr.effective_date
    GROUP BY tr.source, tr.member_bk, tr.coverage_type, tr.effective_date
)

-- Return records where Tertiary exists without prior Secondary
SELECT *
FROM prior_secondary
WHERE had_prior_secondary = 0
```

---

## Running the Tests

### Run all tests for the model:
```bash
dbt test --select ces_member_cob_profile
```

### Run specific test:
```bash
dbt test --select ces_member_cob_profile,test_name:no_overlapping_date_ranges
```

### Run only custom tests:
```bash
dbt test --select ces_member_cob_profile,test_type:custom
```

---

## Test Severity Levels

- **Error**: Test must pass for model to be considered valid (CI/CD blocker)
- **Warn**: Test failure generates warning but allows deployment (requires review)

---

## Maintenance Notes

These tests should be reviewed and updated when:
- COB business rules change
- New coverage types are added
- Medicare/Medicaid coordination rules change
- Two Blues carrier list is updated

---

## Performance Considerations

Some of these tests (especially #8 - Tertiary history check) can be slow on large datasets. Consider:
- Running full test suite nightly in production
- Running critical tests (errors only) in CI/CD
- Using `--store-failures` flag to save failed test results for analysis
