---
title: "Member COB Profile Business Rules"
document_type: "business_rules"
business_domain: ["membership", "claims"]
edp_layer: "business_vault"
technical_topics: ["coordination-of-benefits", "effectivity-satellite", "data-vault-2.0"]
audience: ["claims-operations", "provider-network", "business-analysts", "data-stewards"]
status: "draft"
last_updated: "2025-10-21"
version: "1.0"
author: "Dan Brickey"
description: "Business rules for Member Coordination of Benefits Profile - determines insurance payer order (Primary/Secondary/Tertiary) for Medical, Dental, and Drug coverage including Two Blues and Medicare Part D scenarios"
related_docs:
  - "../../../engineering-knowledge-base/data-vault-2.0-guide.md"
  - "../../edp_platform_architecture.md"
model_name: "ces_member_cob_profile"
legacy_source: "HDSVault.biz.spCOBProfileLookup"
---

# Member COB Profile Business Rules

## Document Overview

This document describes the business logic for the Member Coordination of Benefits (COB) Profile in plain language for business stakeholders, data stewards, and domain experts.

---

## What is the COB Profile?

The COB Profile determines **which insurance company pays first, second, or third** when a BCI member has coverage from multiple insurance carriers. This is critical for:

- **Claims processing**: Knowing which carrier to bill first
- **Provider attribution**: Determining which PCP is responsible for quality measures
- **Financial reporting**: Accurate calculation of BCI's liability
- **HEDIS measures**: Quality reporting requirements

---

## Key Business Concepts

### Coverage Types
Members can have three types of coverage:
1. **Medical Coverage**: Doctor visits, hospital stays, procedures
2. **Dental Coverage**: Dental services
3. **Drug/Pharmacy Coverage**: Prescription medications

Each coverage type can have **different COB rules**. For example, a member might be:
- **Primary** for Medical (BCI pays first)
- **Secondary** for Drug (Medicare Part D pays first, BCI pays second)

### COB Order (Payer Sequence)
- **Primary**: BCI is the first payer
- **Secondary**: Another insurance pays first, BCI pays second
- **Tertiary**: BCI pays third (rare, but happens)
- **No COB**: Member has only BCI coverage (no coordination needed)

### Special Scenarios

#### Two Blues
When a member has **two Blue Cross Blue Shield plans** (for example, BCI plus a spouse's BCBS plan from another state), special coordination rules apply. The profile flags these scenarios.

#### Medicare Part D
When a member has **Medicare Part D** (prescription drug coverage), specific federal rules determine whether BCI or Medicare pays first for pharmacy claims.

---

## Data Sources

The COB Profile combines data from three sources:

1. **Member Eligibility Records** (`current_member_eligibility`)
   - Member demographics (name, group, subscriber ID)
   - Eligibility date ranges (when coverage started and ended)
   - Coverage category codes (M=Medical, D=Dental, R=Pharmacy)

2. **Member COB Records** (`current_member_cob`)
   - Other insurance carrier information
   - COB sequence codes (1=Primary, 2=Secondary, etc.)
   - Effective and termination dates for COB arrangements

3. **Reference Data (Seed Files)**
   - List of 82 Blue Cross Blue Shield carrier codes
   - Medicare Part D rules (5 primary scenarios, 12 secondary scenarios)

---

## How the Profile is Built

### Step 1: Identify All Date Boundaries

The profile creates **discrete time periods** where a member's COB status remains constant.

**Why?** Because eligibility and COB arrangements change over time. A member might be:
- Primary from Jan 1 - Mar 31
- Secondary from Apr 1 - Dec 31

**How it works:**
- Collect all dates where eligibility starts or ends
- Collect all dates where COB arrangements start or end
- Create non-overlapping date ranges from these boundaries

**Business rule**: No gaps allowed once a member appears. If a member had coverage yesterday and has coverage tomorrow, they must have a record for today.

---

### Step 2: Determine Coverage Types for Each Period

For each date range, determine if the member has Medical, Dental, and/or Drug coverage.

**Medical Coverage** = 'Yes' when:
- Member has eligibility category 'M' (Medical) during the period

**Dental Coverage** = 'Yes' when:
- Member has eligibility category 'D' (Dental) during the period

**Drug Coverage** = 'Yes' when:
- Member has eligibility category 'M' (Medical) **OR**
- Member has eligibility category 'R' (Pharmacy) during the period

**Business rule**: Every record must have at least one coverage type = 'Yes'. Records with no coverage are filtered out.

---

### Step 3: Apply COB Rules (Cascading Logic)

The profile applies COB rules **in sequence** for each coverage type. This is the most complex part of the logic.

#### Medical COB Rules

**Primary Medical**:
- Member has Medical coverage = 'Yes'
- **AND** one of:
  - No COB record exists (member has only BCI)
  - COB record shows BCI as sequence 1 (Primary)
  - COB carrier is in the "Medicare Part D Primary" list (drug-only scenario, BCI is primary for medical)

**Secondary Medical**:
- Member has Medical coverage = 'Yes'
- Not already marked as Primary
- **AND** COB record shows BCI as sequence 2 (Secondary)
- **AND** COB carrier is NOT in the "Medicare Part D Secondary" list (excludes drug-only scenarios)

**Tertiary Medical**:
- Member has Medical coverage = 'Yes'
- Not already marked as Primary or Secondary
- **AND** COB record shows BCI as sequence 3 (Tertiary)

**Result**: Every medical coverage period gets assigned Primary, Secondary, Tertiary, or No COB.

#### Dental COB Rules

Same cascading logic as Medical, but applied to Dental coverage category.

#### Drug COB Rules

**Special Medicare Part D Handling**:

**Primary Drug**:
- Member has Drug coverage = 'Yes'
- **AND** one of:
  - No COB record exists
  - COB carrier is in the "Medicare Part D Primary" seed file
  - COB record shows BCI as sequence 1

**Secondary Drug**:
- Member has Drug coverage = 'Yes'
- Not already marked as Primary
- **AND** one of:
  - COB carrier is in the "Medicare Part D Secondary" seed file
  - COB record shows BCI as sequence 2

**Why this matters**: When a member has Medicare Part D, federal rules override normal COB sequencing. The seed files encode these federal regulations.

---

### Step 4: Detect "Two Blues" Scenarios

For each coverage type (Medical, Dental, Drug), the profile checks:

**Is the other insurance carrier a Blue Cross Blue Shield plan?**

**How it's determined**:
- Look up the COB carrier code (`MCRE_ID`) in the `seed_cob_two_blues_carriers` seed file
- If found → Set "Two Blues" flag = 'Yes'
- If not found → Set "Two Blues" flag = 'No'

**Why this matters**:
- Two Blues scenarios have special billing agreements
- Claims may need special handling
- Provider networks may differ

**Example**: Member has BCI (Idaho) and also has spouse's BCBS of Texas coverage. The carrier code for BCBS Texas is in the seed file, so `medical_two_blues` = 'Yes'.

---

### Step 5: Create Derived Indicator Flags

To simplify downstream reporting, the profile creates "Yes/No" indicator flags:

**Medical Indicators**:
- `medical_is_bci_primary` = 'Yes' when `medical_cob_order` = 'Primary'
- `medical_is_bci_secondary` = 'Yes' when `medical_cob_order` = 'Secondary'
- `medical_is_bci_tertiary` = 'Yes' when `medical_cob_order` = 'Tertiary'

*(Same pattern repeats for Dental and Drug)*

**Why?** Some downstream reports need simple Yes/No flags rather than text values.

---

### Step 6: Mark Current Records

For each member, the **most recent** COB record is flagged as "current":

- `is_current` = TRUE when `end_date` = '9999-12-31'
- `is_current` = FALSE for all historical records

**Business rule**: Each member can have at most one current record.

---

## Column Definitions (Business View)

### Identification Columns

| Column | Business Meaning | Example |
|--------|------------------|---------|
| `member_hk` | Unique member identifier (system-generated hash key) | `ABC123XYZ...` |
| `source` | Source system (gemstone_facets or legacy_facets) | `gemstone_facets` |
| `member_bk` | Member business key from source system (MEME_CK) | `12345678` |
| `group_id` | Employer/sponsor group | `ACME001` |
| `subscriber_id` | Policy holder ID | `987654321` |
| `member_suffix` | Family position on policy (00=subscriber, 01=spouse, 02=child, etc.) | `01` |
| `member_first_name` | Member's first name | `John` |

### Date Effectivity Columns

| Column | Business Meaning | Example |
|--------|------------------|---------|
| `effective_date` | Start of this COB period (inclusive) | `2024-01-01` |
| `end_date` | End of this COB period (inclusive) | `2024-03-31` |
| `is_current` | Is this the active/current record? | `TRUE` |

**How to read**: This member had this specific COB arrangement from `effective_date` through `end_date`. If you need to know COB status "as of" any date, find the record where your date falls between these two dates.

### Medical Coverage Columns

| Column | Business Meaning | Values |
|--------|------------------|--------|
| `medical_coverage` | Does member have medical benefits? | Yes / No |
| `has_medical_cob` | Does member coordinate medical benefits with another carrier? | Yes / No |
| `medical_cob_order` | Who pays first for medical claims? | Primary / Secondary / Tertiary / No |
| `medical_is_bci_primary` | Is BCI the first payer for medical? | Yes / No |
| `medical_is_bci_secondary` | Is BCI the second payer for medical? | Yes / No |
| `medical_is_bci_tertiary` | Is BCI the third payer for medical? | Yes / No |
| `medical_carrier_id` | Other insurance carrier code for medical | `0948` |
| `medical_two_blues` | Does member have two Blues plans for medical? | Yes / No |

### Dental Coverage Columns

*(Same structure as Medical, but for dental benefits)*

| Column | Business Meaning | Values |
|--------|------------------|--------|
| `dental_coverage` | Does member have dental benefits? | Yes / No |
| `has_dental_cob` | Does member coordinate dental benefits? | Yes / No |
| `dental_cob_order` | Who pays first for dental claims? | Primary / Secondary / Tertiary / No |
| *(additional dental indicator columns)* | | |

### Drug Coverage Columns

*(Same structure, but includes Medicare Part D special handling)*

| Column | Business Meaning | Values |
|--------|------------------|--------|
| `drug_coverage` | Does member have pharmacy benefits? | Yes / No |
| `has_drug_cob` | Does member coordinate drug benefits? | Yes / No |
| `drug_cob_order` | Who pays first for pharmacy claims? (Medicare Part D rules apply) | Primary / Secondary / Tertiary / No |
| *(additional drug indicator columns)* | | |

### Metadata Columns

| Column | Business Meaning |
|--------|------------------|
| `load_date` | When was this record created/updated in the data warehouse? |
| `record_source` | Source system metadata from raw vault |
| `hash_diff` | Technical field for change detection (ignore for business use) |

---

## Business Rules Summary

### Critical Rules (Must Never Violate)

1. **No Overlapping Dates**: A member cannot have two COB records that overlap in time
2. **Valid Date Ranges**: `effective_date` must always be ≤ `end_date`
3. **At Least One Coverage**: Every record must have Medical=Yes, Dental=Yes, or Drug=Yes (or multiple)
4. **COB Requires Coverage**: Cannot have COB coordination without active coverage
   - If `has_medical_cob` = 'Yes', then `medical_coverage` must = 'Yes'
5. **Only One Current**: Each member can have at most one record where `is_current` = TRUE
6. **Indicator Consistency**: The `*_is_bci_primary/secondary/tertiary` flags must match the `*_cob_order` value

### Important Rules (Should Follow)

7. **Two Blues Validation**: If `*_two_blues` = 'Yes', the carrier code should exist in the seed file
8. **Tertiary Cascading**: A member should only have Tertiary status if they previously had Secondary status in their history

---

## Common Business Questions Answered

### "How do I find a member's current COB status?"

```sql
SELECT *
FROM ces_member_cob_profile
WHERE source = 'gemstone_facets'
  AND member_bk = '12345678'
  AND is_current = TRUE
```

### "Which members had Secondary Medical COB in March 2024?"

```sql
SELECT DISTINCT source, member_bk, member_first_name
FROM ces_member_cob_profile
WHERE medical_cob_order = 'Secondary'
  AND '2024-03-15' BETWEEN effective_date AND end_date
```

### "Which members have Two Blues scenarios for pharmacy?"

```sql
SELECT source, member_bk, member_first_name, drug_carrier_id
FROM ces_member_cob_profile
WHERE drug_two_blues = 'Yes'
  AND is_current = TRUE
```

### "What was this member's COB status on a specific date?"

```sql
SELECT *
FROM ces_member_cob_profile
WHERE source = 'gemstone_facets'
  AND member_bk = '12345678'
  AND '2023-06-15' BETWEEN effective_date AND end_date
```

### "How many members have Medicare Part D coordination?"

Look for members where:
- `drug_cob_order` = 'Secondary'
- `drug_carrier_id` in the Medicare Part D seed file

---

## Data Quality Expectations

### What Gets Tested Automatically

The data model includes automated tests that run daily to ensure:

1. **Completeness**: No missing values in required fields
2. **Validity**: All indicator fields contain only 'Yes' or 'No'
3. **Consistency**: Indicator flags match the COB order values
4. **Integrity**: All members exist in the member hub
5. **Uniqueness**: No duplicate records for same member/date
6. **Recency**: Data is refreshed daily

### What to Watch For

- **New carrier codes**: If a new insurance carrier appears, it may need to be added to the Two Blues seed file
- **COB sequence gaps**: If a member jumps from Primary to Tertiary without Secondary, it may indicate a data issue
- **Unexpected No COB**: If a member suddenly has No COB after years of coordination, investigate
- **Coverage gaps**: If a member has a gap in coverage dates, this may indicate an enrollment issue

---

## Update Frequency and Incremental Logic

**How often does this update?**
- Daily, processing only members who had eligibility or COB changes

**What triggers a new record?**
- Member's coverage type changes (adds/drops Medical, Dental, or Drug)
- Member's COB arrangement changes (Primary → Secondary)
- Member's other insurance carrier changes
- Member's Two Blues status changes
- Member's coverage dates change

**What doesn't trigger a new record?**
- Name changes (not tracked in this profile)
- Address changes (not relevant to COB)
- Changes to unrelated coverage details

**Historical records**:
- All historical COB records are preserved
- You can query "as of" any date in the past
- End dates are set to the day before the next period starts

---

## Dependencies and Downstream Usage

### This Profile Depends On:
1. **Member Hub** (`h_member`) - Member master list
2. **Current Member Eligibility** (`current_member_eligibility`) - Coverage dates and categories
3. **Current Member COB** (`current_member_cob`) - Other insurance information
4. **Seed Files**:
   - `seed_cob_two_blues_carriers` - List of Blues carrier codes
   - `seed_cob_medicare_part_d_primary` - Medicare Part D primary rules
   - `seed_cob_medicare_part_d_secondary` - Medicare Part D secondary rules

### Downstream Uses:
1. **PCP Attribution** - Needs to know if member is Primary Medical to attribute quality measures
2. **Claims Adjudication** - Determines which carrier to bill first
3. **Financial Reporting** - Calculates BCI's liability vs other payers
4. **HEDIS Measures** - Quality reporting requires Primary Medical members
5. **Provider Network Analysis** - Two Blues scenarios affect network access

---

## Maintenance and Stewardship

### Business Owners
- **Claims Operations**: COB determination rules
- **Provider Network Team**: Two Blues carrier list
- **Compliance**: Medicare Part D rules

### When to Review
- **Annually**: Review all seed files for accuracy
- **When new contracts signed**: Add new Blues carriers to seed file
- **When Medicare rules change**: Update Part D seed files
- **When COB policies change**: Update business logic in dbt model

### Who to Contact
- **Data Questions**: Data Engineering team
- **Business Rule Questions**: Claims Operations manager
- **Medicare Part D Questions**: Compliance team
- **Two Blues Questions**: Provider Network Contracts team

---

## Glossary

| Term | Definition |
|------|------------|
| **BCI** | Blue Cross of Idaho |
| **COB** | Coordination of Benefits - determining which insurance pays first |
| **MCRE_ID** | Medical Carrier ID - code for other insurance companies |
| **MEME_CK** | Member Check - unique member identifier from source system |
| **Two Blues** | Scenario where member has multiple Blue Cross Blue Shield plans |
| **Medicare Part D** | Federal prescription drug coverage for Medicare beneficiaries |
| **Effectivity Satellite** | Technical term for time-based tracking of changing attributes |
| **Date Spine** | Technical term for non-overlapping date ranges |
| **SCD Type 2** | Slowly Changing Dimension - method of tracking historical changes |
| **Cascade Logic** | Sequential application of rules where later rules depend on earlier ones |

---

## Document Version History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-10-21 | 1.0 | AI Expert Team | Initial business rules documentation for EDW3 refactoring |

---

**Questions or Corrections?**
Please contact the Data Architecture team or submit feedback through the data governance process.
