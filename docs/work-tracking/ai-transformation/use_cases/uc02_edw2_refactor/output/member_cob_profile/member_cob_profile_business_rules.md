---
title: "Member COB Profile Business Rules"
document_type: "business_rules"
business_domain: ["membership", "claims"]
edp_layer: "business_vault"
technical_topics: ["coordination-of-benefits", "effectivity-satellite", "data-vault-2.0"]
audience: ["claims-operations", "business-analysts", "data-stewards"]
status: "draft"
last_updated: "2025-10-28"
version: "1.0"
author: "Dan Brickey"
description: "Business rules for determining member Coordination of Benefits (COB) profiles across discrete date ranges for Medical, Dental, and Drug coverage."
related_docs:
  - "docs/architecture/edp_platform_architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "xwalk_member_cob_profile"
legacy_source: "HDSVault.biz.spCOBProfileLookup"
---

# Member COB Profile Business Rules

## Overview

The Member COB Profile entity provides a comprehensive view of each member's Coordination of Benefits (COB) status across discrete date ranges. It determines when Blue Cross of Idaho (BCI) is the primary, secondary, or tertiary payer for Medical, Dental, and Drug/Pharmacy claims.

**Purpose**: Enable accurate claims adjudication by identifying who pays first when members have multiple insurance coverages.

**Grain**: One record per member per discrete date range where their COB status remains unchanged.

## Business Context

### What is Coordination of Benefits?

When a member has health insurance coverage from multiple sources (e.g., BCI and a spouse's employer plan), Coordination of Benefits (COB) rules determine which insurer pays first (primary), second (secondary), or third (tertiary).

**Why it matters**:
- Prevents duplicate payments and overpayments
- Ensures correct claim routing and processing
- Maintains compliance with BCBS network agreements
- Identifies "Two Blues" scenarios requiring special handling

### Key Business Entities

- **Member**: The insured individual
- **Coverage Type**: Medical, Dental, or Drug/Pharmacy benefits
- **COB Order**: Primary, Secondary, Tertiary (or None if no COB exists)
- **MCRE_ID**: Insurance carrier code identifying the other insurer
- **Two Blues**: When both coverages are BCBS plans (special network rules apply)

---

## Date Range Construction

### Business Rule: Discrete Date Ranges

**Rule**: Create non-overlapping date periods where a member's COB profile remains constant.

**Why**: Member eligibility and COB information change over time. We need discrete periods to accurately determine COB status for any given date.

**How it works**:

1. **Collect all potential start dates**:
   - Eligibility effective dates (for Medical and Dental coverage)
   - COB effective dates
   - Day after eligibility term dates
   - Day after COB term dates

2. **Collect all potential end dates**:
   - Eligibility term dates
   - COB term dates
   - Day before eligibility effective dates
   - Day before COB effective dates

3. **Create valid date ranges**:
   - Match each start date with the nearest end date
   - Keep only ranges where start ≤ end
   - Keep the shortest valid range for each start date (deduplication)

4. **Filter out invalid dates**:
   - Exclude far-future placeholder dates (9999-12-31, 2200-01-01)

**Example**:

```
Member has:
- Medical eligibility: 1/1/2024 - 3/31/2024
- COB record: 2/1/2024 - 2/29/2024

Resulting date ranges:
- 1/1/2024 - 1/31/2024 (has medical, no COB)
- 2/1/2024 - 2/29/2024 (has medical, has COB)
- 3/1/2024 - 3/31/2024 (has medical, no COB)
```

---

## Coverage Determination

### Business Rule: Medical Coverage

**Rule**: Member has medical coverage if they have active eligibility with product category 'M' (Medical) during the date range.

**Source Column**: `current_member_eligibility.product_category_bk`
**Valid Values**: 'M'
**Additional Filter**: `eligibility_ind = 'Y'`

**Output**: `medical_coverage` = 'Yes' or 'No'

---

### Business Rule: Dental Coverage

**Rule**: Member has dental coverage if they have active eligibility with product category 'D' (Dental) during the date range.

**Source Column**: `current_member_eligibility.product_category_bk`
**Valid Values**: 'D'
**Additional Filter**: `eligibility_ind = 'Y'`

**Output**: `dental_coverage` = 'Yes' or 'No'

---

### Business Rule: Drug Coverage

**Rule**: Member has drug/pharmacy coverage if they have active eligibility with product category 'M' (Medical) or 'R' (Rider) during the date range.

**Rationale**: Drug benefits are typically included with medical plans or purchased as a separate rider.

**Source Column**: `current_member_eligibility.product_category_bk`
**Valid Values**: 'M', 'R'
**Additional Filter**: `eligibility_ind = 'Y'`

**Output**: `drug_coverage` = 'Yes' or 'No'

---

## COB Order Determination

### Business Rule: Primary Medical and Drug COB

**Rule**: BCI is PRIMARY payer for medical and drug claims when:
1. Member has medical coverage, AND
2. Member has a COB record where:
   - `insurance_order` ≠ 'U' (not Unknown)
   - `insurance_type` ≠ 'D' (not Dental-only)
   - `coverage_id` is NOT in the Medicare Part D Primary exclusion list
   - The COB record is active during the date range

**Rationale**: Most COB records default to BCI being primary unless explicitly marked as 'P' (primary to another carrier) or 'S' (secondary to another carrier).

**Source Columns**:
- `current_member_cob.insurance_order`
- `current_member_cob.insurance_type`
- `current_member_cob.coverage_id`

**Output**:
- `has_medical_cob` = 'Yes'
- `medical_cob_order` = 'Primary'
- `has_drug_cob` = 'Yes'
- `drug_cob_order` = 'Primary'
- `coverage_id_medical` = the MCRE_ID code

**Special Exclusion**: Medicare Part D Primary codes (MEDPARTD, NO COB, COBINV, COBLTRSNT, COBLTRSND) are excluded because these represent scenarios where BCI does NOT have medical COB, only drug-specific handling.

---

### Business Rule: Primary Dental COB

**Rule**: BCI is PRIMARY payer for dental claims when:
1. Member has dental coverage, AND
2. Member has a COB record where:
   - `insurance_order` ≠ 'U' (not Unknown)
   - `insurance_type` = 'D' (Dental-only)
   - `coverage_id` is NOT in the Medicare Part D Primary exclusion list
   - The COB record is active during the date range

**Source Columns**:
- `current_member_cob.insurance_order`
- `current_member_cob.insurance_type`
- `current_member_cob.coverage_id`

**Output**:
- `has_dental_cob` = 'Yes'
- `dental_cob_order` = 'Primary'
- `coverage_id_dental` = the MCRE_ID code

---

### Business Rule: Secondary Medical and Drug COB

**Rule**: BCI is SECONDARY payer for medical and drug claims when:
1. Member has medical coverage, AND
2. Member has a COB record where:
   - `insurance_order` = 'P' (Primary to another carrier, meaning BCI is secondary)
   - `insurance_type` ≠ 'D' (not Dental-only)
   - `coverage_id` is NOT in the Medicare Part D Secondary exclusion list
   - The COB record is active during the date range

**Rationale**: 'P' means the other carrier is primary, so BCI pays second.

**Source Columns**:
- `current_member_cob.insurance_order`
- `current_member_cob.insurance_type`
- `current_member_cob.coverage_id`

**Output**:
- `medical_cob_order` = 'Secondary'
- `drug_cob_order` = 'Secondary'
- `coverage_id_medical` = the MCRE_ID code (or keep existing if already set)

**Special Exclusion**: Medicare Part D Secondary codes are excluded (see seed file `seed_cob_medicare_part_d_secondary`).

---

### Business Rule: Secondary Dental COB

**Rule**: BCI is SECONDARY payer for dental claims when:
1. Member has dental coverage, AND
2. Member has a COB record where:
   - `insurance_order` = 'P' (Primary to another carrier)
   - `insurance_type` = 'D' (Dental-only)
   - `coverage_id` is NOT in the Medicare Part D Secondary exclusion list
   - The COB record is active during the date range

**Source Columns**:
- `current_member_cob.insurance_order`
- `current_member_cob.insurance_type`
- `current_member_cob.coverage_id`

**Output**:
- `dental_cob_order` = 'Secondary'
- `coverage_id_dental` = the MCRE_ID code (or keep existing if already set)

---

### Business Rule: Tertiary Medical and Drug COB

**Rule**: BCI is TERTIARY (third) payer for medical and drug claims when:
1. Member has medical coverage, AND
2. BCI is already identified as SECONDARY payer, AND
3. Member has an additional COB record where:
   - `insurance_order` = 'S' (Secondary to another carrier, meaning there's a tertiary scenario)
   - `insurance_type` ≠ 'D' (not Dental-only)
   - `coverage_id` is NOT in the Medicare Part D Secondary exclusion list
   - The COB record is active during the date range

**Rationale**: Rare scenario where member has three layers of insurance (e.g., Medicare, spouse's employer plan, and BCI).

**Source Columns**:
- `current_member_cob.insurance_order`
- `current_member_cob.insurance_type`
- `current_member_cob.coverage_id`

**Prerequisite**: `medical_cob_order` must already be 'Secondary'

**Output**:
- `medical_cob_order` = 'Tertiary'
- `drug_cob_order` = 'Tertiary'
- `coverage_id_medical` = the MCRE_ID code (or keep existing if already set)

---

### Business Rule: Tertiary Dental COB

**Rule**: BCI is TERTIARY (third) payer for dental claims when:
1. Member has dental coverage, AND
2. BCI is already identified as SECONDARY payer for dental, AND
3. Member has an additional COB record where:
   - `insurance_order` = 'S' (Secondary to another carrier)
   - `insurance_type` = 'D' (Dental-only)
   - `coverage_id` is NOT in the Medicare Part D Secondary exclusion list
   - The COB record is active during the date range

**Source Columns**:
- `current_member_cob.insurance_order`
- `current_member_cob.insurance_type`
- `current_member_cob.coverage_id`

**Prerequisite**: `dental_cob_order` must already be 'Secondary'

**Output**:
- `dental_cob_order` = 'Tertiary'
- `coverage_id_dental` = the MCRE_ID code (or keep existing if already set)

---

## Two Blues Detection

### Business Rule: Two Blues Scenario

**Rule**: Flag when a member has COB with another Blue Cross Blue Shield plan.

**Why it matters**: BCBS plans have reciprocal network agreements. When both the member's primary and secondary coverage are BCBS plans, special billing and network rules apply (BlueCard, FEP, etc.).

**How it's determined**:
1. Look up the member's `coverage_id_medical` or `coverage_id_dental` in the `seed_cob_two_blues_carriers` reference table
2. If a match is found, set the corresponding `*_2blues` flag to 'Yes'

**Source Data**: `seed_cob_two_blues_carriers.mcre_id`

**Output**:
- `medical_2blues` = 'Yes' or 'No'
- `dental_2blues` = 'Yes' or 'No'
- `drug_2blues` = 'Yes' or 'No'

**Example MCRE_ID codes that trigger Two Blues**:
- `BCI1`, `BCI2`, `BCI3` - BCI primary/secondary/tertiary
- `FEP1`, `FEP2`, `FEP3` - Federal Employee Program
- `MA1`, `MA2`, `MA3` - Medicare Advantage Blues
- `0908`, `0948`, `1782` - Various BCBS plan codes
- `Host1`, `Host2`, `Host3` - BlueCard host coverage

---

## Medicare Part D Special Rules

### Business Rule: Medicare Part D Primary Exclusions

**Rule**: Certain MCRE_ID codes represent drug-only scenarios where BCI should NOT be considered for medical COB, only drug handling.

**Excluded Codes** (from `seed_cob_medicare_part_d_primary`):
- `MEDPARTD` - Medicare Part D coverage
- `NO COB` - No other coverage found
- `COBINV` - COB under active investigation
- `COBLTRSNT` - COB letter sent (no response yet)
- `COBLTRSND` - COB letter sent (dental)

**Impact**: These codes are excluded when determining Primary Medical/Drug COB but may still affect drug-specific processing.

---

### Business Rule: Medicare Part D Secondary Exclusions

**Rule**: Certain MCRE_ID codes should be excluded from Secondary Medical/Dental COB determination.

**Excluded Codes** (from `seed_cob_medicare_part_d_secondary`):
- All Primary exclusion codes, plus:
- `0948`, `0958` - Specific BCBS secondary arrangements
- `BCI2`, `BCI3` - BCI secondary/tertiary
- `FEP2`, `Host2`, `MA2` - BCBS program secondary codes

**Impact**: Prevents incorrect COB order assignment for Medicare Part D scenarios.

---

## No Coverage Exclusion

### Business Rule: Exclude Members Without Any Coverage

**Rule**: If a member has NO Medical, Dental, OR Drug coverage during a date range, exclude that record entirely.

**Rationale**: COB only matters when there's active coverage to coordinate. Records with zero coverage provide no business value.

**Filter Logic**:
```
WHERE NOT (
    medical_coverage = 'No' AND
    dental_coverage = 'No' AND
    drug_coverage = 'No'
)
```

---

## Derived Indicator Flags

The crosswalk table (`xwalk_member_cob_profile`) creates additional Yes/No flags for easier lookups:

### Medical Indicators

- **`medical_is_bci_primary`**: 'Yes' when `medical_cob_order = 'Primary'`, else 'No'
- **`medical_is_bci_secondary`**: 'Yes' when `medical_cob_order = 'Secondary'`, else 'No'
- **`medical_is_bci_tertiary`**: 'Yes' when `medical_cob_order = 'Tertiary'`, else 'No'

### Dental Indicators

- **`dental_is_bci_primary`**: 'Yes' when `dental_cob_order = 'Primary'`, else 'No'
- **`dental_is_bci_secondary`**: 'Yes' when `dental_cob_order = 'Secondary'`, else 'No'
- **`dental_is_bci_tertiary`**: 'Yes' when `dental_cob_order = 'Tertiary'`, else 'No'

### Drug Indicators

- **`drug_is_bci_primary`**: 'Yes' when `drug_cob_order = 'Primary'`, else 'No'
- **`drug_is_bci_secondary`**: 'Yes' when `drug_cob_order = 'Secondary'`, else 'No'
- **`drug_is_bci_tertiary`**: 'Yes' when `drug_cob_order = 'Tertiary'`, else 'No'

---

## Example Scenarios

### Scenario 1: No COB

**Situation**: Member has only BCI coverage, no other insurance.

**Input**:
- Medical eligibility: 1/1/2024 - 12/31/2024
- No COB records

**Output**:
```
start_date: 1/1/2024
end_date: 12/31/2024
medical_coverage: Yes
has_medical_cob: No
medical_cob_order: No
drug_coverage: Yes
has_drug_cob: No
drug_cob_order: No
```

**Interpretation**: BCI pays all claims as the only insurer.

---

### Scenario 2: BCI Secondary to Spouse's Plan

**Situation**: Member has coverage through spouse's employer (primary) and BCI (secondary).

**Input**:
- Medical eligibility: 1/1/2024 - 12/31/2024
- COB record: `insurance_order = 'P'`, `insurance_type = 'M'`, `coverage_id = 'CIGNA'`

**Output**:
```
start_date: 1/1/2024
end_date: 12/31/2024
medical_coverage: Yes
has_medical_cob: Yes
medical_cob_order: Secondary
coverage_id_medical: CIGNA
medical_2blues: No
drug_coverage: Yes
drug_cob_order: Secondary
```

**Interpretation**: Spouse's plan pays first, BCI pays second for both medical and drug claims.

---

### Scenario 3: Two Blues Scenario

**Situation**: Member has BCI and also Medicare Advantage through a Blues plan.

**Input**:
- Medical eligibility: 1/1/2024 - 12/31/2024
- COB record: `insurance_order = 'P'`, `coverage_id = 'MA1'`

**Output**:
```
start_date: 1/1/2024
end_date: 12/31/2024
medical_coverage: Yes
has_medical_cob: Yes
medical_cob_order: Secondary
coverage_id_medical: MA1
medical_2blues: Yes
drug_coverage: Yes
drug_cob_order: Secondary
drug_2blues: Yes
```

**Interpretation**: Medicare Advantage (MA1) pays first, BCI pays second, and special BCBS network rules apply.

---

### Scenario 4: Dental-Only COB

**Situation**: Member has BCI medical and dental, but spouse has separate dental insurance that's primary.

**Input**:
- Medical eligibility: 1/1/2024 - 12/31/2024
- Dental eligibility: 1/1/2024 - 12/31/2024
- COB record: `insurance_order = 'P'`, `insurance_type = 'D'`, `coverage_id = 'DELTA'`

**Output**:
```
start_date: 1/1/2024
end_date: 12/31/2024
medical_coverage: Yes
has_medical_cob: No
medical_cob_order: No
dental_coverage: Yes
has_dental_cob: Yes
dental_cob_order: Secondary
coverage_id_dental: DELTA
dental_2blues: No
drug_coverage: Yes
has_drug_cob: No
drug_cob_order: No
```

**Interpretation**: Delta Dental pays dental claims first, BCI pays second. BCI is primary for medical and drug.

---

## Business Validation Rules

### Data Quality Checks

1. **Unique Key**: Each combination of (`source_id`, `member_bk`, `start_date`) should be unique
2. **Date Validity**: `start_date` ≤ `end_date` for all records
3. **COB Consistency**: If `has_*_cob = 'Yes'`, then `*_cob_order` should be Primary/Secondary/Tertiary
4. **Coverage Prerequisite**: Can only have COB if corresponding coverage exists (e.g., can't have `has_medical_cob = 'Yes'` if `medical_coverage = 'No'`)
5. **Reference Data Integrity**: All `coverage_id_*` values should exist in seed reference tables or be documented as new/unknown carriers

### Business Logic Validation

1. **Mutual Exclusivity**: A member cannot be both Primary and Secondary for the same coverage type in the same date range
2. **Tertiary Prerequisite**: Cannot have Tertiary COB without first being Secondary
3. **No Coverage Exclusion**: Records with all three coverage types = 'No' should not exist
4. **Date Range Gaps**: Ideally no gaps in coverage periods for active members (may indicate data quality issues)

---

## Maintenance and Governance

### Reference Data Updates

The following seed files require periodic review and updates:

1. **`seed_cob_two_blues_carriers`**:
   - **Review Frequency**: Annually or when new BCBS contracts are signed
   - **Business Owner**: Provider Network/Contracts team
   - **Update Trigger**: New BlueCard agreements, FEP enrollment changes, Medicare Advantage contracts

2. **`seed_cob_medicare_part_d_primary`** and **`seed_cob_medicare_part_d_secondary`**:
   - **Review Frequency**: Annually or when Medicare rules change
   - **Business Owner**: Claims Operations and Compliance
   - **Update Trigger**: CMS regulatory updates, new Medicare Part D handling rules

### Stakeholder Responsibilities

- **Claims Operations**: Validate COB order logic aligns with payer agreements
- **Provider Network**: Maintain Two Blues carrier list
- **Data Stewards**: Monitor data quality and resolve member COB discrepancies
- **Compliance**: Ensure Medicare Part D handling meets federal requirements
- **Business Analysts**: Document new COB scenarios and edge cases

---

## Questions and Clarifications

For questions about this business rule documentation, contact:

- **Technical Questions**: Data Engineering Team
- **Business Logic Questions**: Claims Operations Manager
- **COB Policy Questions**: Contracts and Network Relations
- **Compliance Questions**: Regulatory Compliance Officer

---

## Revision History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-28 | Dan Brickey | Initial draft - refactored from legacy EDW2 stored procedure |

