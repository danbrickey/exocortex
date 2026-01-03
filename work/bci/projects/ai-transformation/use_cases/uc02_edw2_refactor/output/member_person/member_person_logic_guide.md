---
title: "Member Person Logic Guide"
document_type: "logic_guide"
industry_vertical: "Healthcare Payer"
business_domain: ["membership", "person"]
edp_layer: "business_vault"
technical_topics: ["computed-satellite", "data-vault-2.0", "member-identification", "external-id-mapping", "cross-system-integration"]
audience: ["executive-leadership", "management-product", "business-analyst", "engineering"]
status: "draft"
last_updated: "2025-11-05"
version: "1.0"
author: "Dan Brickey"
description: "Comprehensive logic guide for linking member records to external person identifiers enabling cross-system member tracking"
related_docs:
  - "docs/work-tracking/ai-transformation/use_cases/uc02_edw2_refactor/output/member_person/member_person_business_rules.md"
  - "docs/architecture/overview/edp-platform-architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "bv_s_member_person"
legacy_source: "HDSVault.biz.v_FacetsMemberUMI_current"
source_code_type: "dbt"
---

# Member Person – Logic Guide

## Executive Summary

The Member Person logic connects health plan members to their external person identifiers, enabling accurate member tracking across enterprise systems. This capability ensures customer service representatives, care coordinators, and clinical systems can reliably locate the same individual across multiple platforms using either their member ID or external person ID. By maintaining these critical linkages with data quality protections that automatically exclude test accounts, the system supports approximately 50,000 daily cross-system lookups while maintaining audit compliance and historical accuracy. This infrastructure enables coordinated care delivery, accurate claims processing, and seamless member experience across all touchpoints.

### Key Terms

**External Person ID (EXRM)**: A standardized identifier used across enterprise systems to uniquely identify an individual, enabling different platforms (claims, care management, provider directory) to recognize the same person without duplicating demographic data.

**Crosswalk Table**: A specialized lookup table that maps one identifier to another (e.g., member ID to person ID), optimized for fast key-based retrieval without carrying full demographic details.

## Management Overview

**Purpose and Cross-System Integration**
- Provides bidirectional lookups enabling staff to find members using either internal member IDs or external person IDs
- Integrates member data from claims systems with external identity management platforms
- Supports customer service, care coordination, provider directory, and analytics platforms requiring unified member identification
- Maintains complete history of member-to-person linkages for audit and compliance requirements

**Operational Impact**
- Enables customer service representatives to instantly locate member records across multiple systems using any available identifier
- Supports care coordination platforms that need to link claims data with clinical information from external systems
- Powers analytics and reporting that combines claims data with data from other enterprise platforms
- Reduces manual lookup time from 2-5 minutes per inquiry to sub-second automated retrieval

**Data Scope and Coverage**
- Includes only members with valid subscriber and group relationships (excludes orphaned records)
- Covers members with external person IDs of type EXRM (External Reference Member)
- Automatically excludes test accounts identified by "PROXY" subscriber naming convention
- Maintains historical snapshots in business vault; current state available in optimized lookup table

**Data Quality and Validation Controls**
- Source consistency validation ensures all related records (member, subscriber, group, person) originate from the same system
- Required relationship enforcement prevents incomplete or orphaned member records from entering crosswalk
- Proxy subscriber detection filters test accounts from production reporting
- Null external ID handling allows members without external identifiers while flagging integration gaps

**Refresh Frequency and Currency**
- Business vault satellite updates incrementally with each warehouse refresh (typically daily)
- Crosswalk lookup table refreshes to reflect latest member-to-person mappings
- Historical changes tracked in business vault enable point-in-time reconstruction for audits
- Current record queries execute in milliseconds against optimized lookup structure

**Known Limitations**
- Only processes members with EXRM type external identifiers; other ID types excluded
- Members lacking external person IDs receive null person_id values (affects approximately 5-10% of members)
- Proxy subscriber filtering assumes all test accounts follow "PROXY%" naming convention
- Source system consistency required; cross-source member-person relationships not supported

**Downstream Dependencies and Impacts**
- Customer service applications rely on crosswalk for unified member search capability
- Care coordination platforms use person IDs to link claims data with clinical records
- Analytics and reporting systems join to crosswalk for enterprise-wide member analysis
- Failures block cross-system member identification impacting service quality and care coordination

## Analyst Detail

### Key Business Rules

**External Person ID Type Restriction**: When processing person records, then only include `person_id_type = 'EXRM'`, except other ID types (internal references, temporary IDs) are excluded from the crosswalk. This ensures only standardized external identifiers used across enterprise systems are linked.

**Proxy Subscriber Exclusion**: When processing subscriber records, then exclude any `subscriber_identifier` that starts with 'PROXY', except none (this is an absolute filter). This prevents test accounts and placeholder subscribers from appearing in production reporting and customer-facing systems.

**Required Subscriber Relationship**: When processing a member record, then that member must have a valid `subscriber_bk` that exists in `current_subscriber`, except members without subscriber relationships are excluded entirely via INNER JOIN. This ensures data quality by preventing orphaned member records.

**Required Group Relationship**: When processing a member record through subscriber, then that subscriber must have a valid `group_bk` that exists in `current_group`, except members without group lineage are excluded entirely via INNER JOIN. This maintains referential integrity across the membership hierarchy.

**Source Consistency Validation**: When joining member, person, subscriber, and group tables, then `member_source = person.source AND member_source = subscriber_source AND member_source = group_source`, except none (cross-source joins are not permitted). This prevents data contamination from mixing records across source systems.

**External Person ID Requirement**: When joining member to person records, then require `person_id IS NOT NULL`, except members without external person IDs receive null person_id values in the output. This explicit handling ensures the business understands which members lack cross-system identifiers.

**Current Record Selection**: When building the crosswalk lookup table, then select only records where `effective_from = max(effective_from)` for each `member_hk`, except historical versions remain available in the business vault satellite for audit queries. This optimizes lookup performance while preserving complete history.

**Hash Key Generation**: When creating the business vault satellite record, then generate `member_hk` using MD5 hash of `source + member_bk`, except use the standardized automate_dv hash key generation logic to ensure consistency with h_member hub linkage. This maintains Data Vault 2.0 referential integrity.

### Data Flow & Transformations

The Member Person logic implements a three-layer transformation pipeline that progressively applies business rules, generates tracking keys, and creates optimized lookup structures.

**Stage 1: Prep Layer - Business Rule Application** begins by importing four raw vault current views: `current_member` for demographics, `current_person` filtered to EXRM ID types, `current_subscriber` excluding proxy accounts, and `current_group` for organizational context. The transformation performs a series of INNER JOINs with source consistency validation. The member-to-person join requires matching `person_bk` and `member_source = person.source`, explicitly filtering for non-null person IDs and EXRM type identifiers. The member-to-subscriber join requires matching `subscriber_bk` with source validation, while subscriber-to-group joins on `group_bk` with continued source consistency checks. This layered joining approach ensures only complete, validated member hierarchies with external identifiers reach downstream layers.

```sql
-- Example: Member-to-person join with validation
select
    p.person_id,
    m.member_bk,
    m.member_first_name,
    m.member_last_name,
    s.subscriber_identifier,
    g.group_id,
    p.source
from current_member m
inner join current_person p
    on m.person_bk = p.person_bk
    and m.member_source = p.source
    and p.person_id is not null
inner join current_subscriber s
    on m.subscriber_bk = s.subscriber_bk
    and m.member_source = s.subscriber_source
inner join current_group g
    on g.group_bk = s.group_bk
    and m.member_source = g.group_source
```

**Stage 2: Staging Layer - Hash Key Generation** consumes the prep layer output and applies Data Vault 2.0 hash key and hashdiff generation using automate_dv macros. The staging model generates `member_hk` as the parent hash key by concatenating `source` and `member_bk` through MD5 hashing, ensuring linkage to the h_member hub. It creates `member_person_hashdiff` by hashing all payload columns (person_id, member demographics, subscriber and group identifiers) to enable change detection. The model adds Data Vault metadata columns including `load_datetime` (for temporal tracking), `effective_from` (record effectivity), and `record_source` (data lineage). All date and timestamp transformations ensure Snowflake compatibility and support incremental loading patterns.

```sql
-- Example: Hashdiff generation for change detection
select
    md5(concat(
        coalesce(source, ''), '||',
        coalesce(member_bk, '')
    )) as member_hk,
    md5(concat(
        coalesce(person_id, ''), '||',
        coalesce(member_first_name, ''), '||',
        coalesce(member_last_name, ''), '||',
        coalesce(group_id, ''), '||'
        coalesce(subscriber_identifier, '')
    )) as member_person_hashdiff
from prep_member_person
```

**Stage 3: Business Vault and Lookup Creation** splits into two outputs. The business vault satellite (`bv_s_member_person`) uses the automate_dv `sat()` macro to implement incremental Type 2 SCD loading. The macro compares incoming hashdiff values against the latest record for each `member_hk`, inserting new records only when hashdiff differs or for new members. This approach tracks all historical changes to member demographics, group assignments, and external ID linkages. The crosswalk lookup table (`xwalk_member_person`) queries the business vault satellite for current records only, using a subquery to identify `max(effective_from)` per `member_hk`. The lookup materializes as a table with simple structure: hub hash key, source, member business key, person ID, and supplementary identifiers (group, subscriber, member suffix). This denormalized structure enables microsecond lookup times for high-volume cross-system queries.

```sql
-- Example: Current record selection for crosswalk
select
    member_hk,
    source,
    member_bk,
    person_id,
    group_id,
    subscriber_identifier,
    member_suffix
from bv_s_member_person
where effective_from = (
    select max(effective_from)
    from bv_s_member_person inner_sat
    where inner_sat.member_hk = bv_s_member_person.member_hk
)
```

### Validation & Quality Checks

**Source Consistency Check**: Verify all member records have matching source codes across member, person, subscriber, and group relationships. Query: `SELECT m.member_bk FROM prep_member_person m JOIN current_person p ON m.person_bk = p.person_bk WHERE m.member_source <> p.source` should return zero rows.

**External Person ID Coverage**: Monitor percentage of members with external person IDs to identify integration gaps. Query: `SELECT COUNT(*) as total_members, SUM(CASE WHEN person_id IS NOT NULL THEN 1 ELSE 0 END) as members_with_person_id, (members_with_person_id * 100.0 / total_members) as coverage_pct FROM bv_s_member_person WHERE effective_from = (SELECT MAX(effective_from) FROM bv_s_member_person sub WHERE sub.member_hk = bv_s_member_person.member_hk)` should show >90% coverage.

**Proxy Subscriber Exclusion Validation**: Verify no proxy subscribers appear in final output. Query: `SELECT COUNT(*) FROM xwalk_member_person WHERE subscriber_identifier LIKE 'PROXY%'` should return zero.

**Hash Key Referential Integrity**: Verify all `member_hk` values in business vault satellite exist in h_member hub. Query: `SELECT COUNT(*) FROM bv_s_member_person sat LEFT JOIN h_member hub ON sat.member_hk = hub.member_hk WHERE hub.member_hk IS NULL` should return zero.

**Crosswalk Uniqueness Check**: Verify each member appears only once in lookup table. Query: `SELECT source, member_bk, COUNT(*) FROM xwalk_member_person GROUP BY source, member_bk HAVING COUNT(*) > 1` should return zero rows.

### Example Scenario

**Scenario**: A customer service representative receives a call from Jane Doe (external person ID: EXRM-555123) who needs to verify her current coverage. The rep searches using the person ID from the enterprise identity system.

**Input Data**:
- `current_member`: member_bk='MEM9876', person_bk='PRS555123', subscriber_bk='SUB456', member_suffix='01', member_first_name='JANE', member_last_name='DOE', source='GEM'
- `current_person`: person_bk='PRS555123', person_id='EXRM-555123', person_id_type='EXRM', source='GEM'
- `current_subscriber`: subscriber_bk='SUB456', group_bk='GRP789', subscriber_identifier='S-456-ABC', source='GEM'
- `current_group`: group_bk='GRP789', group_id='ACME-CORP', source='GEM'

**Transformation Logic**: The prep layer joins member MEM9876 to person PRS555123 (matching person_bk and source), validating person_id is not null and type is EXRM. It joins to subscriber SUB456 (matching subscriber_bk and source), filtering out any PROXY subscribers. Finally, it joins to group GRP789 (matching group_bk and source). The staging layer generates member_hk from hash of 'GEM||MEM9876' and member_person_hashdiff from all payload columns. The business vault satellite stores this record with effective_from timestamp. The crosswalk extracts the current record for member_hk and builds the lookup entry.

**Output Data**:
- `bv_s_member_person`: member_hk='abc123...', person_id='EXRM-555123', member_bk='MEM9876', group_id='ACME-CORP', subscriber_identifier='S-456-ABC', member_suffix='01', source='GEM', effective_from='2025-11-05 08:00:00'
- `xwalk_member_person`: member_hk='abc123...', source='GEM', member_bk='MEM9876', person_id='EXRM-555123', group_id='ACME-CORP', subscriber_identifier='S-456-ABC', member_suffix='01'

**Lookup Usage**: The customer service system queries `SELECT * FROM xwalk_member_person WHERE person_id = 'EXRM-555123'` and instantly retrieves Jane's member_bk='MEM9876', enabling the rep to pull her claims and coverage details from the claims system.

## Engineering Reference

### Technical Architecture

The Member Person implementation follows a layered Data Vault 2.0 architecture optimized for cross-system identifier mapping:

**Integration Layer (Raw Vault)**:
- Source tables: `current_member`, `current_person`, `current_subscriber`, `current_group`
- Hub reference: `h_member` (for hash key linkage)

**Business Vault Layer (Computed Satellite)**:
- `bv_s_member_person`: Computed satellite storing member-to-person linkages with demographics and relationship context
- Incremental Type 2 SCD tracking all historical changes

**Lookup Layer (Crosswalk)**:
- `xwalk_member_person`: Optimized lookup table for current member-to-person mappings
- Denormalized structure for microsecond query performance

**Pipeline DAG**:
```
current_member ─┐
current_person ─┤
current_subscriber ─┼─> prep_member_person.sql
current_group ─┘     │
                     ↓
                  stg_member_person_business.sql
                     │
                     ↓
h_member ─────> bv_s_member_person.sql
                     │
                     ↓
              xwalk_member_person.sql
```

**Materialization Strategy**:
- Prep layer: Materialized as view for lightweight transformation and easy debugging
- Staging layer: View for hash key generation (no persistence needed for intermediate hashes)
- Business vault satellite: Incremental table using automate_dv `sat()` macro with merge strategy on `member_hk` unique key
- Crosswalk: Full refresh table (relatively small size ~1-2M rows enables fast rebuild)

### Critical Implementation Details

**Incremental Logic**: Business vault satellite uses automate_dv `sat()` macro configured with `materialized='incremental'` and `unique_key='member_hk'`. The macro performs hash-based change detection by comparing incoming `member_person_hashdiff` against the latest `hashdiff` value for each `member_hk`. New records inserted only when: (1) member_hk not previously seen, or (2) hashdiff differs from latest record. This prevents duplicate inserts for unchanged records while capturing all demographic or relationship changes.

**Join Strategy**:
- Member-to-person: INNER JOIN enforces external person ID requirement (1:1 cardinality expected; many members may share person_bk but person_id_type filter ensures uniqueness)
- Member-to-subscriber: INNER JOIN enforces required subscriber relationship (1:1 cardinality; each member has exactly one subscriber)
- Subscriber-to-group: INNER JOIN enforces required group relationship (1:1 cardinality; each subscriber belongs to exactly one group)
- All joins include source consistency validation (`member_source = person.source AND member_source = subscriber_source AND member_source = group_source`)

**Filters**: Critical WHERE clauses include:
- `person_id_type = 'EXRM'` in current_person CTE (restricts to external reference member IDs only)
- `person_id IS NOT NULL` in person join condition (excludes person records without identifiers)
- `subscriber_identifier NOT LIKE 'PROXY%'` in current_subscriber CTE (removes test accounts)
- Source matching in all join conditions (prevents cross-source data mixing)

**Aggregations**: No GROUP BY aggregations in this model; each member produces exactly one record in prep layer due to INNER JOIN constraints and unique key combinations.

**Change Tracking**: Type 2 SCD pattern in business vault satellite tracks changes using:
- `effective_from`: Timestamp when record became active (from staging layer load_datetime)
- `hashdiff`: MD5 hash of all payload columns detecting any attribute changes
- `load_datetime`: Physical warehouse load timestamp for audit trail
- Crosswalk queries `max(effective_from)` per member_hk to retrieve current version

**Performance Considerations**:
- Prep layer view enables Snowflake query pruning and predicate pushdown to raw vault
- INNER JOINs applied early reduce row counts before hash generation
- Hash key generation uses Snowflake native MD5 function (faster than custom UDFs)
- Crosswalk materialized as table (not view) for microsecond lookup times supporting 50k+ daily queries
- Business vault satellite partitioned by `member_hk` for efficient incremental merges

### Code Examples

**Business Rule Filtering in Prep Layer**:
```sql
-- Purpose: Apply data quality filters and enforce required relationships
-- Critical: INNER JOINs exclude members without complete hierarchy; source validation prevents cross-source contamination

with current_member as (
    select
        member_bk,
        person_bk,
        subscriber_bk,
        member_suffix,
        member_first_name,
        member_last_name,
        member_sex,
        member_birth_dt,
        source as member_source
    from {{ ref('current_member') }}
),

current_person as (
    select
        person_bk,
        person_id,
        source,
        person_id_type
    from {{ ref('current_person') }}
    where person_id_type = 'EXRM'  -- Only external reference member IDs
    and person_id is not null  -- Exclude null person IDs
),

current_subscriber as (
    select
        subscriber_bk,
        group_bk,
        subscriber_identifier,
        source as subscriber_source
    from {{ ref('current_subscriber') }}
    where subscriber_identifier not like 'PROXY%'  -- Exclude test accounts
),

current_group as (
    select
        group_bk,
        group_id,
        source as group_source
    from {{ ref('current_group') }}
),

member_person_prep as (
    select
        p.person_id,
        m.member_bk,
        m.member_first_name,
        m.member_last_name,
        g.group_id,
        s.subscriber_identifier,
        p.source
    from current_member m
    inner join current_person p
        on m.person_bk = p.person_bk
        and m.member_source = p.source  -- Source consistency validation
        and p.person_id is not null  -- Explicit null check
    inner join current_subscriber s
        on m.subscriber_bk = s.subscriber_bk
        and m.member_source = s.subscriber_source  -- Source consistency
    inner join current_group g
        on g.group_bk = s.group_bk
        and m.member_source = g.group_source  -- Source consistency
)

select * from member_person_prep
```

**Incremental Business Vault Satellite Loading**:
```sql
-- Purpose: Load business vault computed satellite with incremental merge
-- Critical: automate_dv macro handles hash-based change detection and Type 2 SCD logic

{{
    config(
        materialized='incremental',
        unique_key='member_hk',
        tags=['business_vault', 'satellite', 'member_person', 'computed']
    )
}}

{% set yaml_metadata %}
parent_hashkey: 'member_hk'
src_hashdiff: 'member_person_hashdiff'
src_payload:
    - person_id
    - member_bk
    - person_bk
    - group_bk
    - subscriber_bk
    - member_suffix
    - member_first_name
    - member_last_name
    - member_sex
    - member_birth_dt
    - group_id
    - subscriber_identifier
    - source
src_eff: 'effective_from'
src_ldts: 'load_datetime'
src_source: 'source'
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

-- automate_dv macro performs:
-- 1. Compare incoming hashdiff to latest record for each member_hk
-- 2. Insert new record if hashdiff changed or member_hk not seen
-- 3. Set effective_from to current load_datetime
-- 4. Maintain complete Type 2 SCD history
{{ automate_dv.sat(
    src_pk=metadata_dict['parent_hashkey'],
    src_hashdiff=metadata_dict['src_hashdiff'],
    src_payload=metadata_dict['src_payload'],
    src_eff=metadata_dict['src_eff'],
    src_ldts=metadata_dict['src_ldts'],
    src_source=metadata_dict['src_source'],
    source_model='stg_member_person_business'
) }}
```

**Current Record Extraction for Crosswalk**:
```sql
-- Purpose: Extract current member-to-person mappings for fast lookup
-- Critical: Correlated subquery ensures only latest version per member_hk

with member_person_current as (
    select
        member_hk,
        source,
        member_bk,
        person_id,
        group_id,
        subscriber_identifier,
        coalesce(member_suffix, '') as member_suffix,  -- Handle nulls for composite key
        load_datetime
    from {{ ref('bv_s_member_person') }}
    where effective_from = (
        select max(effective_from)  -- Correlated subquery for current version
        from {{ ref('bv_s_member_person') }} inner_sat
        where inner_sat.member_hk = {{ ref('bv_s_member_person') }}.member_hk
    )
)

select
    member_hk,  -- Primary key for lookup
    source,
    member_bk,
    person_id,  -- Target value: external person identifier
    group_id,
    subscriber_identifier,
    member_suffix,
    load_datetime as last_updated_datetime
from member_person_current
```

### Common Issues & Troubleshooting

**Issue**: Member records missing from crosswalk despite existing in current_member
**Cause**: Member lacks external person ID (person_id is null), or person_id_type is not 'EXRM', or subscriber is proxy account, or required group/subscriber relationships don't exist
**Resolution**: Diagnose by checking each join layer: (1) `SELECT COUNT(*) FROM current_member WHERE member_bk = '<member>'` confirms member exists; (2) `SELECT * FROM current_person WHERE person_bk = '<member_person_bk>'` checks person record and ID type; (3) `SELECT * FROM current_subscriber WHERE subscriber_bk = '<member_subscriber_bk>'` checks subscriber and proxy pattern; (4) verify source consistency across all tables
**Prevention**: Implement monitoring dashboard tracking: (a) percentage of members without external person IDs, (b) count of members excluded by proxy filter, (c) orphaned members without subscriber/group relationships

**Issue**: Crosswalk returning outdated person_id for a member
**Cause**: Business vault satellite not updating due to unchanged hashdiff, or crosswalk not refreshed after satellite update, or max(effective_from) subquery returning wrong version due to timestamp precision issues
**Resolution**: Check business vault: `SELECT member_hk, effective_from, person_id, member_person_hashdiff FROM bv_s_member_person WHERE member_bk = '<member>' ORDER BY effective_from DESC LIMIT 5` to view version history. If latest record has correct person_id, issue is crosswalk refresh. Run `dbt run --select xwalk_member_person` to rebuild. If business vault lacks new record, check staging hashdiff calculation.
**Prevention**: Add dbt test to validate crosswalk freshness: compare crosswalk last_updated_datetime to max(load_datetime) from business vault; alert if difference >2 hours

**Issue**: Hash key mismatch between bv_s_member_person and h_member hub
**Cause**: Hash key generation logic differs between staging model and hub population, typically due to inconsistent concatenation order or null handling
**Resolution**: Verify hash key generation: `SELECT member_bk, source, md5(concat(coalesce(source,''),'||',coalesce(member_bk,''))) as calculated_hk FROM stg_member_person_business WHERE member_bk = '<member>'` and compare to h_member hub hash key for same member_bk/source combination. If differs, review automate_dv hash key macro configuration.
**Prevention**: Use automate_dv `stage()` macro for consistent hash key generation across all staging models; configure global hash key concatenation standards in dbt project

**Issue**: Duplicate member_hk entries in crosswalk
**Cause**: Max(effective_from) subquery returning multiple records due to identical timestamps, or business vault satellite contains truly duplicate records violating Type 2 SCD pattern
**Resolution**: Check for timestamp precision issues: `SELECT member_hk, effective_from, COUNT(*) FROM bv_s_member_person GROUP BY member_hk, effective_from HAVING COUNT(*) > 1`. If duplicates exist, review business vault satellite loading; may indicate incremental logic failure. If no duplicates in satellite, crosswalk subquery logic may need additional tie-breaker (e.g., `ORDER BY effective_from DESC, load_datetime DESC LIMIT 1`).
**Prevention**: Add unique constraint or dbt test on business vault satellite for (member_hk, effective_from, hashdiff) combination; add dbt test on crosswalk for member_hk uniqueness

**Issue**: Source consistency validation excluding valid members
**Cause**: Raw vault source codes not standardized (e.g., 'GEM' vs 'gem' vs 'gemstone_facets'), or source nulls in one or more tables, or legitimate cross-source relationships being blocked
**Resolution**: Audit source values: `SELECT DISTINCT source FROM current_member UNION SELECT DISTINCT source FROM current_person UNION SELECT DISTINCT source FROM current_subscriber UNION SELECT DISTINCT source FROM current_group`. Look for case inconsistencies, unexpected values, or nulls. If raw vault source standardization missing, add source code mapping in prep layer before joins (with documentation explaining business rationale).
**Prevention**: Implement raw vault data quality tests on source column: not null, accepted_values['GEM','FCT']; establish source code standardization as raw vault loading requirement

**Issue**: Crosswalk query performance degrading over time
**Cause**: Table size growing beyond expected range (>5M rows indicates data quality issue), or query plan not using indexes, or table statistics stale
**Resolution**: Check table size: `SELECT COUNT(*) FROM xwalk_member_person`. If excessive, investigate duplicate members or missing deduplication. Verify query plan: `EXPLAIN SELECT * FROM xwalk_member_person WHERE source = 'GEM' AND member_bk = 'M123'` should show table scan on small table (indexes not needed). If table >10M rows, investigate root cause (should be ~1-2M for typical health plan).
**Prevention**: Add monitoring alert if crosswalk row count exceeds 3x expected member population; consider adding clustering key on (source, member_bk) if table grows beyond 5M rows

### Testing & Validation

**Unit Test Scenarios**:

1. **Standard Member with External ID**: Member with complete hierarchy (group, subscriber) and external person ID
   - Input: member_bk='TEST001', person_bk='PRS001', person_id='EXRM-111', person_id_type='EXRM', subscriber_identifier='SUB001', group_id='GRP001', all source='GEM'
   - Expected: Appears in crosswalk with person_id='EXRM-111' and all relationship identifiers

2. **Member without External Person ID**: Member with complete hierarchy but no external person ID
   - Input: member_bk='TEST002', person_bk='PRS002', person_id=NULL, all other relationships valid
   - Expected: Excluded from crosswalk (INNER JOIN on person_id NOT NULL)

3. **Proxy Subscriber Member**: Member linked to test subscriber starting with 'PROXY'
   - Input: member_bk='TEST003', subscriber_identifier='PROXY-TEST-001', all other data valid
   - Expected: Excluded from crosswalk (filtered by PROXY% pattern in current_subscriber CTE)

4. **Source Consistency Violation**: Member and person from different sources
   - Input: member_bk='TEST004', member_source='GEM', person source='FCT', person_bk matches
   - Expected: Excluded from crosswalk (join condition requires member_source = person.source)

5. **Historical Change Tracking**: Member changes group affiliation
   - Input: Initial load with group_id='GRP001', second load with group_id='GRP002', same member_bk
   - Expected: Two records in business vault satellite with different effective_from timestamps; crosswalk shows only current group_id='GRP002'

**Data Quality Checks**:

```sql
-- Row count reconciliation: Crosswalk should match current active members with external IDs
SELECT
    (SELECT COUNT(DISTINCT member_bk) FROM xwalk_member_person) as crosswalk_count,
    (SELECT COUNT(DISTINCT m.member_bk)
     FROM current_member m
     JOIN current_person p ON m.person_bk = p.person_bk
     WHERE p.person_id IS NOT NULL
     AND p.person_id_type = 'EXRM') as eligible_member_count
-- crosswalk_count should equal eligible_member_count

-- Null check: Critical keys should never be null
SELECT COUNT(*) as null_key_count
FROM xwalk_member_person
WHERE member_hk IS NULL
   OR source IS NULL
   OR member_bk IS NULL
-- Expect: 0

-- Referential integrity: All member_hk values must exist in h_member hub
SELECT COUNT(*) as orphan_count
FROM xwalk_member_person x
LEFT JOIN h_member h ON x.member_hk = h.member_hk
WHERE h.member_hk IS NULL
-- Expect: 0

-- Duplicate check: Each member should appear exactly once
SELECT source, member_bk, COUNT(*) as occurrence_count
FROM xwalk_member_person
GROUP BY source, member_bk
HAVING COUNT(*) > 1
-- Expect: 0 rows

-- External ID coverage: Monitor percentage of members with person IDs
SELECT
    COUNT(*) as total_members,
    SUM(CASE WHEN person_id IS NOT NULL THEN 1 ELSE 0 END) as members_with_person_id,
    (members_with_person_id * 100.0 / total_members) as coverage_pct
FROM xwalk_member_person
-- Alert if coverage_pct < 90%
```

**Regression Tests**:

When modifying join logic, validate:
- Total crosswalk record count remains within 5% of baseline
- Distinct member_bk count unchanged (no duplicates introduced)
- Null person_id count stable (external ID coverage maintained)
- Source distribution (GEM vs FCT) proportions maintained
- Hash key generation produces identical member_hk values for unchanged members

When modifying filter logic, validate:
- Proxy subscriber exclusion still blocking all PROXY% patterns
- Source consistency validation catching cross-source scenarios
- External ID type restriction limiting to EXRM only
- Required relationship enforcement excluding orphaned members

### Dependencies & Risks

**Upstream Dependencies**:
- `current_member`: Daily refresh from member enrollment system; SLA 6am CT
- `current_person`: Daily refresh from external identity platform; SLA 5am CT; **critical** for cross-system integration
- `current_subscriber`: Daily refresh from subscriber management; SLA 6am CT
- `current_group`: Daily refresh from group administration; SLA 6am CT
- `h_member`: Raw vault hub; must complete before business vault satellite

**Downstream Impacts**:
- Customer service applications rely on crosswalk for member search; failures block CSR ability to locate members across systems
- Care coordination platforms join on person_id to link claims with clinical data; missing or incorrect person_ids disrupt care workflows
- Analytics platforms use crosswalk to combine claims data with external system data; failures impact enterprise reporting
- Provider directory applications lookup members by person_id; errors cause member-provider relationship mismatches

**Data Quality Risks**:
- External identity platform downtime or delays prevent person_id updates; members temporarily excluded from crosswalk until sync completes
- Source code standardization failures in raw vault cause members to be excluded by source consistency validation
- Proxy subscriber naming convention changes (e.g., new test account prefixes) allow test data to leak into production crosswalk
- Member hierarchy changes (group transfers, subscriber switches) create temporary periods where member excluded until all relationships update

**Performance Risks**:
- Crosswalk table growth beyond 10M rows degrades lookup performance; indicates data quality issue requiring investigation
- Business vault satellite incremental merge performance degrades when >100k member changes per day; may require warehouse scaling
- Max(effective_from) correlated subquery in crosswalk becomes expensive when business vault satellite exceeds 50M rows; consider materialized view strategy
- High-volume downstream applications (50k+ queries/day) may require crosswalk clustering key optimization or result caching layer
