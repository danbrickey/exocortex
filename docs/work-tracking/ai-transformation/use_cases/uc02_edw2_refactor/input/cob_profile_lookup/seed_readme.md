# COB Profile Seed Files

## Overview

These seed files contain reference data for Coordination of Benefits (COB) business rules. They replace hardcoded lists in the legacy SQL code.

## Files

### 1. `seed_cob_two_blues_carriers.csv`

**Purpose**: Identifies insurance carriers that are Blue Cross Blue Shield plans (including BCI, FEP, BlueCard, Medicare Advantage Blues)

**Usage**: Used to detect "Two Blues" scenarios where a member has multiple Blues coverages. This affects billing and coordination rules.

**Columns**:
- `mcre_id` (string): The insurance carrier code from the member COB records
- `carrier_name` (string): Human-readable carrier name
- `carrier_type` (string): Classification of carrier type (BCBS, BCI, FEP, BlueCard, Medicare Advantage)
- `notes` (string): Additional context or usage notes

**Row Count**: 82 carriers

**Business Rule**: If a member's COB `MCRE_ID` appears in this list, the `*2Blues` flags are set to 'Yes'

---

### 2. `seed_cob_medicare_part_d_primary.csv`

**Purpose**: Lists MCRE_ID codes that indicate BCI should be PRIMARY payer for drug/pharmacy claims

**Usage**: When member has one of these codes, BCI is the primary drug coverage (no other drug insurance, or Medicare Part D where BCI is primary)

**Columns**:
- `mcre_id` (string): The insurance carrier code
- `description` (string): Human-readable description
- `cob_rule` (string): The COB rule this code triggers
- `notes` (string): Explanation of business context

**Row Count**: 5 codes

**Business Rule**:
```sql
-- Exclude these from medical COB determination
-- (These are drug-only scenarios)
AND PATINDEX('%^' + MCRE_ID + '^%', @MedicarePartD_Primary) = 0
```

---

### 3. `seed_cob_medicare_part_d_secondary.csv`

**Purpose**: Lists MCRE_ID codes that indicate BCI should be SECONDARY payer for drug/pharmacy claims

**Usage**: When member has one of these codes, another insurer is primary for drug coverage, BCI is secondary

**Columns**:
- `mcre_id` (string): The insurance carrier code
- `description` (string): Human-readable description
- `cob_rule` (string): The COB rule this code triggers
- `notes` (string): Explanation of business context

**Row Count**: 12 codes

**Business Rule**:
```sql
-- Exclude these from secondary medical COB logic
AND PATINDEX('%^' + MCRE_ID + '^%', @MedicarePartD_Secondary) = 0
```

---

## Usage in dbt Models

These seeds should be referenced in the COB Profile business vault model as lookup tables:

```sql
-- Example: Check if carrier is a Blues plan
LEFT JOIN {{ ref('seed_cob_two_blues_carriers') }} as two_blues
    ON TRIM(member_cob.mcre_id) = two_blues.mcre_id

-- Example: Check Medicare Part D primary rules
LEFT JOIN {{ ref('seed_cob_medicare_part_d_primary') }} as medicare_part_d_primary
    ON TRIM(member_cob.mcre_id) = medicare_part_d_primary.mcre_id
```

---

## Maintenance Notes

- **Source of Truth**: These lists come from contractual agreements, Medicare rules, and BCI's participation in BCBS networks
- **Update Frequency**: Review annually or when new BCBS/FEP/Medicare contracts are established
- **Business Owner**: Provider Network/Contracts team and Claims Operations
- **Special Codes**:
  - `BCI1/BCI2/BCI3`: Internal BCI codes for primary/secondary/tertiary
  - `MA1/MA2/MA3`: Medicare Advantage with Blues
  - `FEP1/FEP2/FEP3`: Federal Employee Program
  - `Host1/Host2/Host3`: BlueCard host coverage
  - `COBLTRSNT/COBLTRSND`: Special COB investigation codes
  - `NO COB`: No other coverage found
  - `COBINV`: COB under active investigation

---

## Data Quality Checks

Recommended dbt tests:

1. **Uniqueness**: `mcre_id` should be unique within each seed file
2. **Not Null**: `mcre_id` and `cob_rule` should never be null
3. **Referential Integrity**: All `mcre_id` values in COB data should exist in at least one seed file (with exception handling for new/unknown codes)

```yaml
# Example schema.yml tests
models:
  - name: seed_cob_two_blues_carriers
    columns:
      - name: mcre_id
        tests:
          - unique
          - not_null
```
