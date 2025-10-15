# Class Type Dimension - Business Rules Documentation

**Document Purpose**: This document describes the business rules and transformations applied in the Class Type dimensional model for review by business data stewards and domain experts.

**Entity**: Class Type (Group + Class Combination)
**Source Systems**: Legacy FACETS, Gemstone FACETS
**EDW3 Layer**: Curation Layer (Business Vault + Dimensional)
**Date**: 2025-10-12

---

## Executive Summary

The Class Type dimension represents combinations of Groups and Classes within the health plan administration system. This dimension supports analytics around member eligibility, dual eligibility status, and exchange participation. The dimension tracks changes over time using Type 2 Slowly Changing Dimension methodology.

---

## Source Data

### Primary Source Tables

| EDW2 Table | EDW3 Table | Description |
|------------|------------|-------------|
| v_group_combined_current | current_group | Current view of group master data |
| v_groupclass_combined_current | current_class_group | Current view of class assignments to groups |
| v_r_SourceBKCCLookup | r_source_system | Reference table for source system descriptions |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | Class type assignments with effective dates |
| v_s_classtypedescription_mroc_bcidaho_current | r_class_type_assignment | Class type descriptions (joined with assignments) |

### Source Column Mappings

**Group Data**:
- `group_id` - Group identifier (e.g., "10030052")
- `group_bk` - Group business key for joins
- `source` - Source system code

**Class Data**:
- `class_bk` - Class identifier/code (e.g., "X001", "M123")
- `class_description` - Description of the class
- `group_bk` - Links class to parent group
- `source` - Source system code

**Class Type Assignment Data**:
- `group_id` - Group identifier for the assignment
- `class_bk` - Class identifier for the assignment
- `effective_from` - Start date of assignment validity
- `effective_to` - End date of assignment validity
- `description_key` - Foreign key to description table
- `description` - Full description of the class type

---

## Business Key Construction

### Class Type Business Key

The Class Type business key is a **composite identifier** formed by concatenating the Group ID with the Class ID:

**Formula**: `RTRIM(group_id) || LTRIM(class_bk)`

**Examples**:
- Group "10030052" + Class "X001" = "10030052X001"
- Group "10030052" + Class "M123" = "10030052M123"

**Rationale**: Neither Group ID nor Class ID alone uniquely identifies a Class Type. The combination represents the unique classification used for member eligibility and plan administration.

---

## Business Rules

### Rule 1: Dual Eligible Flag

**Business Purpose**: Identify members who are eligible for both Medicare and Medicaid benefits (dual eligibility).

**Rule Logic**:
- Set to **"Yes"** if the Class ID (class_bk) starts with the letter 'M'
- Set to **"No"** if:
  - Class ID is null
  - Class ID is empty string
  - Class ID does not start with 'M'

**SQL Implementation**:
```sql
CASE
    WHEN class_bk IS NULL THEN 'No'
    WHEN class_bk = '' THEN 'No'
    WHEN SUBSTRING(class_bk, 1, 1) = 'M' THEN 'Yes'
    ELSE 'No'
END AS dual_eligible
```

**Examples**:
- Class "M123" → dual_eligible = "Yes"
- Class "X001" → dual_eligible = "No"
- Class NULL → dual_eligible = "No"

**Business Context**: The 'M' prefix in the class code is a coding convention indicating Medicare dual eligibility. This flag is critical for reporting to CMS and for eligibility verification.

---

### Rule 2: On Exchange Flag

**Business Purpose**: Identify whether a Group+Class combination represents coverage sold through the healthcare exchange (Affordable Care Act marketplace).

**Rule Logic** (evaluated in order):
1. Set to **"No"** if:
   - Class ID is null
   - Class ID is empty string
   - Group ID equals '10030052' (specific exclusion)
2. Set to **"Yes"** if:
   - Class ID starts with 'X' (position 1)
   - OR Class ID contains 'X' at position 4
3. Otherwise set to **"No"**

**SQL Implementation**:
```sql
CASE
    WHEN class_bk IS NULL THEN 'No'
    WHEN class_bk = '' THEN 'No'
    WHEN group_id = '10030052' THEN 'No'
    WHEN SUBSTRING(class_bk, 1, 1) = 'X' THEN 'Yes'
    WHEN SUBSTRING(class_bk, 4, 1) = 'X' THEN 'Yes'
    ELSE 'No'
END AS on_exchange
```

**Examples**:
- Group "10030053" + Class "X001" → on_exchange = "Yes" (starts with X)
- Group "10030053" + Class "001X" → on_exchange = "Yes" (X at position 4)
- Group "10030052" + Class "X001" → on_exchange = "No" (explicit exclusion)
- Group "10030053" + Class "M123" → on_exchange = "No" (no X pattern)

**Business Context**: The 'X' character in the class code indicates exchange participation. Group '10030052' is explicitly excluded because it represents a legacy administrative grouping that predates the ACA exchanges but may have incidentally used 'X' in coding.

---

### Rule 3: Class Type Description Lookup

**Business Purpose**: Provide a full descriptive name for the Class Type combination from the reference data.

**Rule Logic**:
1. Join to Class Type Assignment reference table on:
   - group_id
   - class_bk
   - source system
2. For records with multiple effective periods, select the one with the **maximum effective_to date** (most recent assignment)
3. Retrieve the description from the joined assignment record
4. Default to **empty string** if no matching description found

**SQL Implementation**:
```sql
-- Get assignment with max effective_to date
SELECT description
FROM r_class_type_assignment
WHERE group_id = [group_id]
  AND class_bk = [class_bk]
  AND source = [source]
ORDER BY effective_to DESC
LIMIT 1

-- Apply default
COALESCE(description, '') AS class_type_description
```

**Examples**:
- Group "10030052" + Class "X001" → "Individual Exchange Silver Plan"
- Group "10030052" + Class "M123" → "Medicare Dual Eligible Standard"
- Group "99999999" + Class "ZZZ" → "" (no match in reference)

**Business Context**: Class Type descriptions are managed by the business and may change over time. Using the assignment with the latest effective_to date ensures we capture the most current business understanding of what each class type represents.

---

### Rule 4: Effective Date Defaulting

**Business Purpose**: Ensure all Class Type records have valid effective date ranges for temporal reporting.

**Rule Logic - Effective From Date**:
- Use the `effective_from` date from Class Type Assignment reference if available
- Default to **2002-01-01** if null or not found
- Rationale: 2002 represents the earliest date in the source system history

**Rule Logic - Effective To Date**:
- Use the `effective_to` date from Class Type Assignment reference if available
- Default to **2199-12-31** if null or not found
- Rationale: Far future date indicates indefinite/current assignment

**SQL Implementation**:
```sql
COALESCE(effective_from, '2002-01-01'::DATE) AS effective_from_date,
COALESCE(effective_to, '2199-12-31'::DATE) AS effective_to_date
```

**Business Context**: The effective date range indicates when a particular Group+Class combination was valid for member assignment. This supports historical reporting and ensures compliance with regulatory requirements for coverage period tracking.

---

## Dimension Structure

### Type 2 Slowly Changing Dimension

The Class Type dimension uses **Type 2 SCD** methodology to track changes over time. When any of the descriptive attributes change, a new version of the dimension record is created.

**Tracked Attributes** (Type 2):
- class_type_description
- class_description
- dual_eligible
- on_exchange
- source_description

**Type 2 SCD Columns**:
- `dss_start_date` - When this version became effective
- `dss_end_date` - When this version was superseded (or 2999-12-31 for current)
- `dss_current_flag` - 'Y' for current version, 'N' for historical
- `dss_version` - Version number (increments with each change)

### Unknown Member Handling

The dimension includes a special **"Unknown" record** with key = 0 to handle:
- Fact records with missing Class Type references
- Data quality issues in source systems
- Referential integrity maintenance

**Unknown Record Values**:
- class_type_key = 0
- All descriptive fields = "Unknown"
- dss_start_date = 1900-01-01
- dss_end_date = 2999-12-31
- dss_current_flag = 'Y'

---

## Change Detection

### Hash-Based Change Detection

The business vault satellite uses SHA-1 hashing to detect when records have changed:

**Hash Diff Calculation**:
```
SHA1(
    class_type_description ||
    class_bk ||
    class_description ||
    dual_eligible ||
    on_exchange ||
    source_description ||
    effective_from_date ||
    effective_to_date
)
```

**Change Detection Logic**:
- When a new record arrives with the same business key but different hashdiff, it indicates a change
- The old satellite record's `load_end_datetime` is set to the current timestamp
- A new satellite record is inserted with `load_end_datetime` = NULL (current)
- This triggers a new version in the dimension table

---

## Data Quality Considerations

### Validation Rules

1. **Business Key Completeness**:
   - Both group_id and class_bk must be present to form a valid Class Type
   - Records with missing group_id or class_bk are excluded

2. **Source System Consistency**:
   - Group and Class must come from the same source system
   - Cross-source joins are not permitted

3. **Effective Date Validity**:
   - effective_from_date must be <= effective_to_date
   - Default dates are applied when source data is incomplete

4. **Flag Value Validation**:
   - dual_eligible must be 'Yes' or 'No'
   - on_exchange must be 'Yes' or 'No'

### Known Data Quality Issues

1. **Historical Descriptions**:
   - Some older Class Types may have missing descriptions in the reference table
   - These default to empty string and should be reviewed with business

2. **Group 10030052 Special Handling**:
   - This group predates current coding standards
   - Always marked on_exchange = 'No' regardless of class code pattern
   - Business has confirmed this is correct behavior

---

## Usage Guidelines

### For Business Analysts

- Use `dss_current_flag = 'Y'` to get only current versions of Class Types
- Join facts using `class_type_id` and appropriate effective date logic
- The Unknown record (key = 0) indicates data quality issues that may need investigation

### For Reporting

- Filter by `dual_eligible = 'Yes'` to analyze dual eligible population
- Filter by `on_exchange = 'Yes'` to analyze exchange marketplace business
- Use `dss_start_date` and `dss_end_date` for historical trend analysis

### For Data Stewards

- Review Class Types with empty `class_type_description` to ensure reference data completeness
- Monitor the Unknown record usage to identify upstream data quality issues
- Validate that new Class codes follow the 'M' (dual eligible) and 'X' (exchange) conventions

---

## Revision History

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-10-12 | 1.0 | System Generated | Initial documentation from EDW2 to EDW3 refactoring |

---

**Questions or Clarifications**: Contact the EDP Data Architecture team for any questions about these business rules or to request changes to the transformation logic.
