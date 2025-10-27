# Member Person Business Rules

## Overview

This document describes the business rules implemented in the member_person refactored models. These rules were extracted from the legacy `v_FacetsMemberUMI_current` view and reimplemented in the EDW3 data vault architecture.

## Legacy Source

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
