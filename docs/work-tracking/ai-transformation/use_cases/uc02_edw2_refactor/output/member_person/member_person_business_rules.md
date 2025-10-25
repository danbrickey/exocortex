---
title: "Member Person Business Rules"
document_type: "business_rules"
business_domain: ["membership"]
edp_layer: "business_vault"
technical_topics: ["member-person-crosswalk", "constituent-mapping", "data-vault-2.0", "bridge-table"]
audience: ["membership-operations", "business-analysts", "data-stewards"]
status: "draft"
last_updated: "2025-10-21"
version: "1.0"
author: "Dan Brickey"
description: "Business rules for mapping members to person constituent IDs with lenient matching strategy for internal use"
related_docs:
  - "docs/architecture/edp_platform_architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "br_member_person, v_member_person_lenient"
legacy_source: "HDSVault.biz.v_FacetsMemberUMI_current"
---

# Member Person Business Rules

## Purpose

This document describes the business rules applied when mapping member records to person (constituent) identifiers and creating the member demographic crosswalk view. This enables queries to pivot between member context and person context across different systems.

## Business Context

Members are identified by member business keys in the benefits administration systems (Gemstone Facets and Legacy Facets). However, for cross-system integration and constituent management, members must be linked to person constituent IDs that represent the individual across all enterprise systems.

### Matching Strategies

Different use cases require different levels of matching strictness:

- **Lenient Matching** (v_member_person_lenient): For internal reporting, business partner data sharing, and analytics where broader matching is acceptable. Uses EXRM person ID type.
- **Strict Matching** (v_member_person_strict): For external/member portal use cases requiring precise matching to avoid any possibility of overmatching. *To be implemented based on operational requirements.*

The member-person crosswalk provides:
- Translation from member identifiers to constituent IDs
- Current demographic information for members
- Source system attribution
- Filtering of non-standard member records (e.g., proxy subscribers)
- Flexible matching strategies via reusable bridge table

## Data Sources

### Primary Sources
- **current_member**: Member demographic and identification data from both Gemstone Facets and Legacy Facets systems
- **current_person**: Person constituent ID mapping from constituent master system
- **current_subscriber**: Subscriber identification data
- **current_group**: Group identification data

### Source System Codes
- **gemstone_facets**: Represented as source code '1' in legacy system, translated to 'gemstone_facets' in EDW3
- **legacy_facets**: All other source codes, translated to 'legacy_facets' in EDW3

## Business Vault Bridge: br_member_person

### Purpose
Creates a general-purpose, reusable mapping between member business keys and person constituent IDs. The bridge includes all person ID types without filtering, allowing downstream views to apply use case-specific criteria.

### Data Transformation Rules

#### 1. Source Code Translation
**Rule**: Convert numeric source identifiers to descriptive names
- Source code '1' → 'gemstone_facets'
- All other source codes → 'legacy_facets'

**Business Rationale**: Provides clear, human-readable source attribution for downstream reporting and analysis.

#### 2. Person ID Type Inclusion
**Rule**: Include all person ID types in the bridge (no filtering)

**Business Rationale**: The bridge is a general-purpose resource. Use case-specific views (lenient vs strict) apply appropriate person_id_type filters based on their matching strategy requirements.

#### 3. Member-Person Join Logic
**Rule**: Join member to person based on:
- person_bk (person business key) must match between member and person records
- source (source system code) must match between member and person records

**Join Type**: LEFT JOIN (not all members may have person constituent IDs)

**Business Rationale**:
- Ensures members are matched to the correct person record from the same source system
- Allows for members without person mappings (NULL person_id) rather than dropping them

#### 4. Effectivity Dating
**Rule**: Use edp_start_dt from member record as the effective start date for the mapping

**Business Rationale**: Tracks when the member-person relationship became effective in the data warehouse, enabling historical analysis.

### Output Columns

| Column | Source | Transformation | Business Meaning |
|--------|--------|----------------|------------------|
| member_person_bridge_key | Calculated | Surrogate key from member_bk + source_code + edp_start_dt | Unique identifier for bridge record |
| member_bk | current_member | Pass-through | Member business key from source system |
| person_bk | current_person | Pass-through | Person business key for hub reference |
| person_id | current_person | Pass-through | External constituent ID for cross-system lookup |
| person_id_type | current_person | Pass-through | Type of person ID (e.g., EXRM) - enables use case filtering |
| source_code | current_member | Translated (1→gemstone_facets, else→legacy_facets) | Human-readable source system name |
| edp_record_source | current_member | Pass-through | Original data vault record source |
| edp_start_dt | current_member | Pass-through | Effective date of mapping |
| edp_load_dt | System | current_timestamp() | Timestamp when bridge record was created |
| cdc_timestamp | current_member | Pass-through | Source system change data capture timestamp |

## Curation View: v_member_person_lenient

### Purpose
Provides current-state member demographic information with person constituent ID mapping using lenient matching strategy. Designed for internal reporting, business partner data sharing, and analytics use cases where broader matching is acceptable.

### Data Transformation Rules

#### 1. Member Dimension Joins
**Rule**: Join member to subscriber and group using:
- subscriber_bk and source must match
- group_bk and source must match

**Join Type**: INNER JOIN

**Business Rationale**: Only include members with valid subscriber and group relationships. Members without these relationships are considered incomplete/invalid.

#### 2. Proxy Subscriber Exclusion
**Rule**: Exclude all records where subscriber_id starts with 'PROXY'

**Business Rationale**: Proxy subscribers are system-generated placeholders and should not be included in member demographic reporting or constituent crosswalks.

#### 3. Person Constituent ID Lookup (Lenient Matching)
**Rule**: Join to br_member_person bridge using:
- member_bk must match
- source_code must match
- person_id_type = 'EXRM' (External Member type only)

**Join Type**: LEFT JOIN

**Business Rationale**:
- Include all valid members even if they don't have a person constituent ID mapping yet
- NULL person_id indicates member needs constituent assignment
- EXRM person ID type provides lenient matching suitable for internal use
- More restrictive matching would be applied in v_member_person_strict for external use cases

#### 4. Column Name Standardization
**Rule**: Rename columns to match legacy output expectations:
- member_first_name → first_name
- member_last_name → last_name
- member_sex → gender
- member_birth_dt → birth_date
- member_ssn → ssn
- edp_record_source → dss_record_source
- edp_start_dt → dss_load_date and dss_start_date
- cdc_timestamp → dss_create_time

**Business Rationale**: Maintains backward compatibility with legacy reporting systems and downstream consumers expecting these column names.

### Output Columns

| Column | Source | Transformation | Business Meaning |
|--------|--------|----------------|------------------|
| constituent_id | br_member_person.person_id | Pass-through (may be NULL) | External person/constituent ID for cross-system queries |
| member_bk | current_member | Pass-through | Member business key - primary identifier |
| group_id | current_group | Pass-through | Group identifier from source system |
| subscriber_id | current_subscriber | Pass-through, filtered (no PROXY%) | Subscriber identifier, proxy subscribers excluded |
| member_suffix | current_member | Pass-through | Member suffix (e.g., 01=subscriber, 02=spouse, 03=child) |
| first_name | current_member.member_first_name | Renamed | Member's first name |
| last_name | current_member.member_last_name | Renamed | Member's last name |
| gender | current_member.member_sex | Renamed | Member's gender/sex code |
| birth_date | current_member.member_birth_dt | Renamed | Member's date of birth |
| ssn | current_member.member_ssn | Renamed | Member's social security number (PII - handle per security policy) |
| source_code | current_member.source | Pass-through | Source system (gemstone_facets or legacy_facets) |
| dss_record_source | current_member.edp_record_source | Renamed | Data vault record source metadata |
| dss_load_date | current_member.edp_start_dt | Renamed | Date/time row was loaded into data vault |
| dss_start_date | current_member.edp_start_dt | Renamed (same as dss_load_date) | Date/time row became effective |
| dss_create_time | current_member.cdc_timestamp | Renamed | Source system CDC timestamp |

## Data Quality Rules

### Required Fields
- member_bk must not be NULL
- subscriber_id must not be NULL
- group_id must not be NULL
- source_code must be either 'gemstone_facets' or 'legacy_facets'
- edp_start_dt must not be NULL

### Optional Fields
- constituent_id may be NULL if no person mapping exists
- birth_date may be NULL (warn if missing)
- All demographic fields (first_name, last_name, gender, ssn) may be NULL

### Business Validation Rules
- subscriber_id must NOT start with 'PROXY'
- person_id_type must equal 'EXRM' when person mapping exists
- When constituent_id is populated, it should reference a valid person record

## Migration from Legacy

### Legacy Implementation
- **View**: HDSVault.biz.v_FacetsMemberUMI_current
- **Architecture**: Single view performing all joins and transformations
- **Source Database**: SQL Server with cross-database joins to HDSInformationMart

### EDW3 Implementation
- **Models**:
  - br_member_person (business vault bridge - incremental materialization, no filtering)
  - v_member_person_lenient (curation layer view with EXRM filtering for internal use)
  - v_member_person_strict (future: curation layer view with strict matching for external use)
- **Architecture**: Separated concerns - general-purpose bridge + use case-specific views
- **Source Database**: Snowflake with all data in integrated raw vault

### Key Differences
1. **Source identifiers**: 'GEM'/'FCT' → 'gemstone_facets'/'legacy_facets'
2. **dss_version removed**: Legacy tracked version numbers; EDW3 uses temporal ordering via timestamps
3. **Separation of concerns**: General-purpose bridge + use case-specific views (lenient/strict)
4. **Incremental loading**: Bridge table supports incremental updates for performance
5. **Matching strategies**: Bridge stores all person ID types; views apply use case-specific filtering

## Business Ownership

### Data Stewardship
- **Primary Owner**: Membership Operations
- **Constituent ID Mapping**: Enterprise Master Data Management team
- **Source System SMEs**:
  - Gemstone Facets: [Team/Contact TBD]
  - Legacy Facets: [Team/Contact TBD]

### Use Cases

**Lenient Matching (v_member_person_lenient):**
- Internal reporting and analytics
- Business partner data sharing
- Cross-system constituent lookup for internal operations
- Data quality and reconciliation processes

**Strict Matching (v_member_person_strict - future):**
- Member portal person identification
- External-facing applications
- Operational systems requiring precise matching
- Use cases where overmatching could expose incorrect data to members

## Questions for Review

1. **Proxy Subscriber Filter**: Should we document which specific subscriber ID patterns constitute "proxy" subscribers beyond the 'PROXY%' pattern?

2. **NULL Constituent IDs**: What is the expected percentage of members without constituent_id mappings? Should this trigger data quality alerts?

3. **Source Code '1' Only for Gemstone**: Is source code '1' exclusively for Gemstone Facets, or are there edge cases?

4. **Person ID Type 'EXRM'**: Are there other person_id_type values we should be aware of? Should we document what they represent?

5. **Historical Changes**: When a member's person_id changes (e.g., duplicate cleanup), should we track this history in the bridge, or is current-state sufficient?

6. **Strict Matching Criteria**: What specific matching rules should be applied for v_member_person_strict to ensure safe use in member portal and external-facing applications?

7. **Use Case Categorization**: Are there other use cases beyond internal/external that require different matching strategies?
