# Member Person Business Rules

## Executive Summary

This system tracks member demographics and personal information for healthcare plan enrollees. It combines member details (name, birth date, gender) with their external constituent ID, subscriber relationship, and group affiliation. The system ensures data accuracy by filtering out test records, validating that member data comes from the correct source systems (GEM or FCT), and tracking changes over time.

**Key Points for Leadership:**
- Members must have both a subscriber and a group to appear in reports
- System excludes test/placeholder records to ensure accurate member counts
- Historical changes are tracked, allowing us to see what a member's information looked like at any point in time
- Data comes from two main sources (GEM and FCT) and cannot be mixed for the same member

---

## Business Analyst Summary

This module keeps track of member demographic information and connects each member to their external person ID, subscriber account, and group plan. It replaces the old `v_FacetsMemberUMI_current` view with a modern system that tracks changes over time.

### Key Business Rules

- **Rule 1 (Source Identification):** When the system sees a source ID of 1, it labels the data as "GEM". All other source IDs are labeled as "FCT". This helps us know which source system the member data came from.

- **Rule 2 (External ID Filtering):** Only member IDs marked as "EXRM" (External Reference Member) are included. This filters out internal test IDs and temporary placeholders. Some members may not have an external ID yet, which is acceptable.

- **Rule 3 (Test Data Exclusion):** Any subscriber ID that starts with "PROXY" is automatically removed. These are fake test records used by the system and would give us wrong member counts if included in reports.

- **Rule 4 (Source Matching):** A member's data from different tables (member info, person ID, subscriber, group) must all come from the same source system. You cannot mix GEM data with FCT data for the same member.

- **Rule 5 (Required Connections):** Every member must be connected to both a subscriber (the account holder) and a group (the coverage plan). Members can exist without an external person ID, but they must have these two connections or they will not show up in reports.

- **Rule 6 (Current Data Only):** The system processes only the most recent version of each member's information when preparing data, but keeps historical versions for tracking changes over time.

- **Rule 7 (Handling Missing Information):** When a member's first name, last name, or gender is missing in reports, the system fills in "Unknown" for names or "U" (unspecified) for gender. This prevents blank fields in reports.

- **Rule 8 (Age Calculation):** The system automatically calculates each member's age in years based on their birth date. This age updates every time you run a report.

- **Rule 9 (Change Tracking):** Every time a member's information changes (name change, address update, etc.), the system saves both the old and new versions with start and end dates. This lets you see what information was valid at any point in time.

### Important Terms

- **Member:** A person enrolled in a healthcare plan (may be the subscriber or a dependent).
- **Subscriber:** The main account holder who has the insurance contract.
- **Group:** The health plan or network the member belongs to.
- **Constituent ID:** An external reference number used to identify the person in other systems.
- **Source Code:** The label (GEM or FCT) that tells us which computer system the member data came from.
- **Proxy Subscriber:** A fake test record used for system testing, not a real person.
- **Type 2 SCD (Slowly Changing Dimension):** A method for tracking historical changes by keeping old and new versions of data with start and end dates.

### Simple Example

**Scenario:** Jane Smith changes her last name to Jane Johnson after getting married.

1. **Before change:** Record shows "Jane Smith" with effective dates 2020-01-01 to 2024-06-15, marked as not current
2. **After change:** New record shows "Jane Johnson" with effective dates 2024-06-16 to 9999-12-31 (far future date), marked as current
3. **Result:** Reports using current data show "Jane Johnson". Historical reports for dates before June 2024 show "Jane Smith".

### What to Watch

- **Members without external IDs:** Some members may not have a constituent ID if they are newly enrolled or if data migration is incomplete. This is expected and the system handles it by leaving that field blank.

- **Source system consistency:** If a member's data appears in both GEM and FCT, only the records where all pieces (member, subscriber, group) come from the same source will show up. Mixed-source records are excluded to prevent data quality issues.

- **Test data filtering:** The system depends on proxy subscriber IDs starting with "PROXY" to filter them out. If naming conventions change, this filter may need updating or real member counts could be affected.

---

## Technical Documentation

### Overview

This document describes the business rules implemented in the member_person refactored models. These rules were extracted from the legacy `v_FacetsMemberUMI_current` view and reimplemented in the EDW3 data vault architecture.

### Legacy Source

- **Database**: HDSVault
- **Schema**: biz
- **View**: v_FacetsMemberUMI_current
- **Purpose**: Member person demographics with external constituent ID

## Business Rules

### BR-MP-001: Source Code Mapping

**Rule**: Map source_id values to standardized source codes

**Logic**:
- When `source_id = 1`, set `source_code = 'GEM'`
- For all other source_id values, set `source_code = 'FCT'`

**Implementation**: [prep_member_person.sql:74-77](prep_member_person.sql#L74-L77)

```sql
case
    when p.source_id = 1 then 'GEM'
    else 'FCT'
end as source_code
```

**Data Quality**:
- source_code must not be null
- source_code must be one of: 'GEM', 'FCT'

---

### BR-MP-002: External Person ID Filtering

**Rule**: Only include external person IDs with type 'EXRM' (External Reference Member)

**Logic**:
- Filter `person_id_type = 'EXRM'` when joining to person table
- This ensures only legitimate external member references are included

**Implementation**: [prep_member_person.sql:29-31](prep_member_person.sql#L29-L31)

```sql
from {{ ref('rv_sat_person_current') }}
where person_id_type = 'EXRM'  -- Only external reference member IDs
```

**Data Quality**:
- Excludes other ID types (internal, temporary, etc.)
- May result in NULL constituent_id for members without external references

---

### BR-MP-003: Proxy Subscriber Exclusion

**Rule**: Exclude all proxy subscriber records from the member person dataset

**Logic**:
- Filter out records where `subscriber_id` starts with 'PROXY'
- Proxy subscribers are system-generated placeholders, not real subscribers

**Implementation**: [prep_member_person.sql:38-40](prep_member_person.sql#L38-L40)

```sql
from {{ ref('rv_sat_subscriber_current') }}
where subscriber_id not like 'PROXY%'  -- Filter out proxy subscribers
```

**Rationale**:
- Proxy subscribers don't represent actual member relationships
- Including them would inflate member counts and distort analytics

---

### BR-MP-004: Source Consistency Validation

**Rule**: Ensure source codes match across member, person, subscriber, and group records

**Logic**:
- Member source must match the derived source code from person source_id
- Member source must equal subscriber source
- Member source must equal group source

**Implementation**: [prep_member_person.sql:60-71](prep_member_person.sql#L60-L71)

```sql
left join current_person p
    on m.person_bk = p.person_bk
    and m.member_source = case
        when p.source_id = 1 then 'GEM'
        else 'FCT'
    end

inner join current_subscriber s
    on m.subscriber_bk = s.subscriber_bk
    and m.member_source = s.subscriber_source

inner join current_group g
    on m.group_bk = g.group_bk
    and m.member_source = g.group_source
```

**Data Quality**:
- Prevents cross-source data contamination
- Ensures referential integrity across related entities
- Uses INNER JOIN for subscriber and group (must exist)
- Uses LEFT JOIN for person (may not have external ID)

---

### BR-MP-005: Required Relationships

**Rule**: Members must have both a subscriber and a group relationship

**Logic**:
- Member-to-subscriber relationship is mandatory (INNER JOIN)
- Member-to-group relationship is mandatory (INNER JOIN)
- Member-to-person relationship is optional (LEFT JOIN)

**Implementation**: [prep_member_person.sql:66-71](prep_member_person.sql#L66-L71)

**Rationale**:
- Subscriber defines the contract holder
- Group defines the coverage plan/network
- External person ID may not exist for all members (new enrollments, data migration gaps)

**Data Quality Impact**:
- Members without valid subscriber records are excluded
- Members without valid group records are excluded
- Members without external person IDs are included (constituent_id will be NULL)

---

### BR-MP-006: Current Records Only

**Rule**: Only process current/active records from satellite tables

**Logic**:
- Source from `_current` views/CTEs that filter for latest versions
- Ensures we're working with most recent data for each entity

**Implementation**: All source CTEs in [prep_member_person.sql:24-47](prep_member_person.sql#L24-L47)

**Data Quality**:
- No historical records in prep layer
- Historical tracking happens in business vault satellite
- Dimensional model provides Type 2 SCD temporal tracking

---

## Dimensional Model Enhancements

### BR-MP-007: Default Values for Null Attributes

**Rule**: Provide meaningful defaults for null demographic values in dimensional model

**Logic**:
```sql
coalesce(member_suffix, '') as member_suffix
coalesce(member_first_name, 'Unknown') as member_first_name
coalesce(member_last_name, 'Unknown') as member_last_name
coalesce(member_sex, 'U') as member_sex
```

**Implementation**: [dim_member_person.sql:59-62](dim_member_person.sql#L59-L62)

**Rationale**:
- Prevents null values in reporting layer
- Improves data quality for downstream consumers
- 'Unknown' is more descriptive than NULL
- 'U' (Unknown/Unspecified) is a valid sex code

---

### BR-MP-008: Age Calculation

**Rule**: Calculate member age in years based on birth date

**Logic**:
```sql
case
    when member_birth_dt is not null
    then datediff(year, member_birth_dt, current_date)
    else null
end as member_age_years
```

**Implementation**: [dim_member_person.sql:65-69](dim_member_person.sql#L65-L69)

**Note**: This is a point-in-time calculation. Age will vary based on query execution date.

---

### BR-MP-009: Type 2 SCD Temporal Tracking

**Rule**: Track all changes to member person attributes over time using Type 2 SCD

**Logic**:
- Use `LEAD()` window function to calculate effective_to dates
- Set effective_to to '9999-12-31' for current records
- Flag current records with `is_current = true`

**Implementation**: [dim_member_person.sql:33-40](dim_member_person.sql#L33-L40)

```sql
lead(effective_from) over (
    partition by member_bk
    order by effective_from
) as effective_to
```

**Query Pattern for Point-in-Time Analysis**:
```sql
SELECT * FROM dim_member_person
WHERE member_bk = '<member_key>'
  AND effective_from <= '2024-01-01'
  AND effective_to > '2024-01-01'
```

---

## Data Quality Rules

### Column-Level Rules

| Column | Rule | Enforcement |
|--------|------|-------------|
| member_bk | NOT NULL, UNIQUE | dbt test |
| constituent_id | Optional (can be NULL) | No test |
| member_first_name | NOT NULL | dbt test |
| member_last_name | NOT NULL | dbt test |
| member_birth_dt | NOT NULL | dbt test |
| member_sex | IN ('M', 'F', 'U', 'O') | dbt test |
| source_code | IN ('GEM', 'FCT') | dbt test |
| subscriber_id | NOT NULL, NOT LIKE 'PROXY%' | dbt test + filter |
| group_id | NOT NULL | dbt test |
| is_current | Only one TRUE per member | dbt test |

### Table-Level Rules

1. **Unique Combination in Satellite**:
   - `member_person_hk + load_datetime` must be unique
   - Prevents duplicate satellite records

2. **Unique Surrogate Key in Dimension**:
   - `member_person_sk` must be unique
   - Generated from member_bk + effective_from

3. **Single Current Record**:
   - Each member_bk can have only one record with `is_current = true`
   - Ensures proper SCD Type 2 implementation

---

## Change History

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0 | 2025-10-27 | AI Refactor | Initial business rules documentation for EDW3 refactor |

---

## References

- Legacy View: `HDSVault.biz.v_FacetsMemberUMI_current`
- Mapping Document: [member_person_mapping.csv](../input/member_person/member_person_mapping.csv)
- Refactored Models: [member_person/](.)
- Project Guidance: [edw2_refactor_project_guidance.md](../../edw2_refactor_project_guidance.md)
