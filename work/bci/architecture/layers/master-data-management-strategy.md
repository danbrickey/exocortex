---
title: "EDP Master Data Management (MDM) Strategy"
document_type: "architecture"
ai_workflow_tags: ["mdm", "data-matching", "golden-records", "member-matching", "provider-matching"]
code_evaluation_scope: "mdm-processes"
business_context: "Enterprise master data strategy for member, provider, and product domains"
technical_audience: "architects|data-engineers|data-governance"
last_updated: "2025-10-01"
related_components: ["integration-layer", "hubs", "satellites", "matching-algorithms"]
related_docs: ["edp-layer-architecture-detailed.md"]
status: "strategy-in-development"
---

# EDP Master Data Management (MDM) Strategy

## Executive Summary

The EDP platform is rebooting its Master Data Management approach after previous initiatives proved unsuccessful. The current state includes rudimentary deterministic matching algorithms for members and providers without golden records. The new MDM initiative prioritizes three domains (Member, Provider, Product) with plans for more sophisticated matching algorithms, confidence scoring, household identification, and true golden record creation.

## AI Workflow Guidance

**Key Patterns**: Deterministic matching → Probabilistic matching → Golden record creation
**Implementation Hints**: Composite business keys, multi-source satellites, bridge tables for uncertain matches
**Validation Points**: Match confidence scores, golden record selection rules, Data Vault hub design

---

## Current State Assessment

### Existing Capabilities

#### Member/Person Matching Algorithm

**Status**: Operational but rudimentary

**Matching Logic** (Deterministic Rules):
```
Input: New member record from source system
Process:
  1. Extract matching attributes:
     - Name (first, last)
     - Birth date
     - Gender
     - Social Security Number (SSN)

  2. Search existing members for matches using combinations:
     - Exact match on SSN + birth date
     - Exact match on full name + birth date + gender
     - Exact match on SSN only (if others differ)
     - Other deterministic combinations

  3. Decision:
     IF match found THEN
         Assign existing Person ID
     ELSE
         Create new Person ID
     END IF

Output: Person ID assigned to member record
```

**Characteristics**:
- **Deterministic**: Hard rules, no fuzzy matching
- **No Confidence Scoring**: Match or no match (binary decision)
- **No Golden Record**: No "best" values selected across sources
- **No Household Logic**: Members matched individually, not grouped into households
- **Single-Source Truth**: Each source maintains own attribute values

**Example**:
```sql
-- Simplified current matching logic
WITH new_member AS (
    SELECT 'John' AS first_name, 'Smith' AS last_name,
           '1980-01-15' AS birth_date, 'M' AS gender,
           '123-45-6789' AS ssn
),
existing_persons AS (
    SELECT person_id, first_name, last_name, birth_date, gender, ssn
    FROM member_person_index
)
SELECT
    CASE
        WHEN EXISTS (
            SELECT 1 FROM existing_persons
            WHERE ssn = new_member.ssn
              AND birth_date = new_member.birth_date
        ) THEN (SELECT person_id FROM existing_persons
                WHERE ssn = new_member.ssn LIMIT 1)
        WHEN EXISTS (
            SELECT 1 FROM existing_persons
            WHERE first_name = new_member.first_name
              AND last_name = new_member.last_name
              AND birth_date = new_member.birth_date
              AND gender = new_member.gender
        ) THEN (SELECT person_id FROM existing_persons
                WHERE first_name = new_member.first_name
                  AND last_name = new_member.last_name
                  AND birth_date = new_member.birth_date LIMIT 1)
        ELSE NEXTVAL('person_id_sequence')  -- New person
    END AS assigned_person_id
FROM new_member;
```

#### Provider Matching Algorithm

**Status**: Operational but rudimentary

**Matching Logic**: Similar deterministic approach
- National Provider Identifier (NPI) matching
- Tax ID + Provider Name matching
- Address-based matching (for group practices)

**Output**: Provider ID crosswalk table
```
┌───────────────┬─────────────────┬──────────────┐
│ Source System │ Source Prov ID  │ Enterprise   │
│               │                 │ Provider ID  │
├───────────────┼─────────────────┼──────────────┤
│ legacy_facets │ 12345           │ PROV_00001   │
│ gemstone_...  │ ABC-789         │ PROV_00001   │ ← Same provider
│ valenz        │ NPI1234567890   │ PROV_00001   │
└───────────────┴─────────────────┴──────────────┘
```

**Limitations**:
- No confidence scores for uncertain matches
- No handling of provider relationship changes (mergers, acquisitions)
- No provider-to-provider relationships (hospital systems, affiliations)
- No temporal tracking of NPI reassignments

### Gaps in Current Approach

**1. No Golden Records**
- Each source system maintains own version of truth
- No "best" or "most current" values selected
- Conflicting data across sources not reconciled
- Downstream consumers must choose which source to trust

**2. Limited Matching Sophistication**
- Only deterministic rules (no fuzzy/probabilistic matching)
- No confidence scoring for uncertain matches
- No machine learning for match improvement over time
- Manual intervention required for edge cases

**3. No Household Management**
- Members matched individually, not as family units
- No household ID assignment
- No family relationship tracking
- Missed opportunities for family-level analytics

**4. No Match Quality Metrics**
- No tracking of match accuracy
- No false positive/negative detection
- No continuous improvement process
- No steward review workflows for uncertain matches

---

## Target State Vision

### MDM Initiative Reboot

**Background**: Previous MDM initiatives failed
**Approach**: Fresh start with lessons learned
**Prioritization**: Focus on three critical domains initially

### Priority Domains

#### 1. Member (Person) Domain
**Strategic Importance**: Foundation for all member analytics

**Goals**:
- Sophisticated matching algorithms (deterministic + probabilistic)
- Confidence scoring for all matches
- Golden record creation with attribute selection rules
- Household identification and family relationships
- Cross-source identity resolution

**Deliverables**:
- Enhanced matching algorithm with ML components
- Golden Member master records
- Household entity with relationships
- Match confidence dashboard for stewards

#### 2. Provider Domain
**Strategic Importance**: Critical for network analytics and contracting

**Goals**:
- Multi-source provider identity resolution
- Provider-to-provider relationships (hospital systems, clinics)
- Temporal tracking of provider changes (mergers, relocations)
- Golden provider records with best values
- NPI history and reassignment tracking

**Deliverables**:
- Enhanced provider matching algorithm
- Provider relationship graph (affiliations, ownership)
- Golden Provider master records
- Provider 360 data model foundation

#### 3. Product Domain
**Strategic Importance**: Foundation for plan analytics and member assignment

**Goals**:
- Product identity across systems (benefit plan matching)
- Product hierarchy (plan families, riders, add-ons)
- Golden product records with complete benefit definitions
- Product change history (benefit modifications)

**Deliverables**:
- Product matching and crosswalk
- Product hierarchy model
- Golden Product master records
- Product change tracking

---

## Data Vault 2.0 MDM Integration

### Hub Design Implications

**Composite Business Key Strategy**:
```sql
-- Hub with composite business key to handle multi-source identity
CREATE TABLE h_member (
    member_hk           BINARY(16) PRIMARY KEY,  -- Hash of composite BK
    member_bk           VARCHAR(500),            -- Composite: source||':::'||source_id
    person_id           VARCHAR(50),             -- Enterprise Person ID (MDM)
    record_source       VARCHAR(50),
    load_timestamp      TIMESTAMP_NTZ
);

-- Example business keys
-- 'legacy_facets:::CMC_123456'
-- 'gemstone_facets:::GMS_789012'
-- 'valenz:::VAL_345678'
```

**MDM Hub (Golden Records)**:
```sql
-- Separate hub for golden MDM person entity
CREATE TABLE h_person_mdm (
    person_mdm_hk       BINARY(16) PRIMARY KEY,
    person_id           VARCHAR(50),             -- Enterprise Person ID
    record_source       VARCHAR(50) DEFAULT 'MDM_PROCESS',
    load_timestamp      TIMESTAMP_NTZ
);
```

### Link Design for Identity Resolution

**Member-to-Person Link** (Many-to-One):
```sql
CREATE TABLE l_member_person (
    member_person_hk    BINARY(16) PRIMARY KEY,
    member_hk           BINARY(16),              -- FK to h_member
    person_mdm_hk       BINARY(16),              -- FK to h_person_mdm
    match_confidence    DECIMAL(5,4),            -- Confidence score
    match_method        VARCHAR(50),             -- Algorithm used
    record_source       VARCHAR(50),
    load_timestamp      TIMESTAMP_NTZ,

    -- Effectivity satellite pattern for changing matches
    effective_from      TIMESTAMP_NTZ,
    effective_to        TIMESTAMP_NTZ
);
```

**Provider-to-Provider Link** (Many-to-Many for relationships):
```sql
CREATE TABLE l_provider_provider (
    provider_provider_hk  BINARY(16) PRIMARY KEY,
    provider_hk_1         BINARY(16),            -- Parent (e.g., hospital system)
    provider_hk_2         BINARY(16),            -- Child (e.g., clinic)
    relationship_type     VARCHAR(50),           -- 'OWNS', 'EMPLOYS', 'AFFILIATED'
    record_source         VARCHAR(50),
    load_timestamp        TIMESTAMP_NTZ
);
```

### Satellite Design for Multi-Source Attributes

**Multi-Source Satellite Pattern** (One per source system):
```sql
-- Legacy FACETS member demographics
CREATE TABLE s_member_demographics_legacy_facets (
    member_hk           BINARY(16),
    load_timestamp      TIMESTAMP_NTZ,
    load_end_timestamp  TIMESTAMP_NTZ,
    hash_diff           BINARY(16),
    record_source       VARCHAR(50),

    -- Attributes from legacy FACETS
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    birth_date          DATE,
    gender              VARCHAR(10),
    ssn                 VARCHAR(11)
);

-- Gemstone FACETS member demographics (separate satellite)
CREATE TABLE s_member_demographics_gemstone_facets (
    member_hk           BINARY(16),
    load_timestamp      TIMESTAMP_NTZ,
    load_end_timestamp  TIMESTAMP_NTZ,
    hash_diff           BINARY(16),
    record_source       VARCHAR(50),

    -- Attributes from gemstone FACETS (may differ from legacy)
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    birth_date          DATE,
    gender              VARCHAR(10),
    ssn                 VARCHAR(11)
);
```

**Golden Record Satellite** (MDM-selected best values):
```sql
-- Golden person demographics (MDM-curated)
CREATE TABLE s_person_mdm_demographics (
    person_mdm_hk       BINARY(16),
    load_timestamp      TIMESTAMP_NTZ,
    load_end_timestamp  TIMESTAMP_NTZ,
    hash_diff           BINARY(16),
    record_source       VARCHAR(50) DEFAULT 'MDM_PROCESS',

    -- Best/most accurate values selected by MDM rules
    first_name          VARCHAR(100),
    last_name           VARCHAR(100),
    birth_date          DATE,
    gender              VARCHAR(10),
    ssn                 VARCHAR(11),

    -- MDM metadata
    first_name_source   VARCHAR(50),  -- Which source provided this value
    last_name_source    VARCHAR(50),
    birth_date_source   VARCHAR(50),
    gender_source       VARCHAR(50),
    ssn_source          VARCHAR(50),

    -- Data quality scores
    first_name_quality  DECIMAL(5,4),
    last_name_quality   DECIMAL(5,4),
    birth_date_quality  DECIMAL(5,4)
);
```

### Bridge Tables for Uncertain Relationships

**Match Confidence Bridge**:
```sql
-- Bridge for uncertain provider-to-provider matches
CREATE TABLE bridge_provider_match_candidates (
    bridge_hk           BINARY(16) PRIMARY KEY,
    provider_hk_1       BINARY(16),
    provider_hk_2       BINARY(16),
    match_confidence    DECIMAL(5,4),            -- 0.0 to 1.0
    match_method        VARCHAR(50),
    match_attributes    VARIANT,                 -- JSON: which attrs matched

    -- Steward workflow
    steward_reviewed    BOOLEAN DEFAULT FALSE,
    steward_decision    VARCHAR(20),             -- 'MATCH', 'NO_MATCH', 'UNCERTAIN'
    steward_user        VARCHAR(100),
    steward_timestamp   TIMESTAMP_NTZ,

    record_source       VARCHAR(50),
    load_timestamp      TIMESTAMP_NTZ
);
```

---

## Enhanced Matching Algorithms

### Proposed Approach: Hybrid Deterministic + Probabilistic

**Phase 1: Deterministic Rules** (High Confidence)
```
Rule 1: Exact SSN + Birth Date → Confidence = 0.99
Rule 2: Exact Full Name + Birth Date + Gender → Confidence = 0.95
Rule 3: Exact SSN only (other attrs differ) → Confidence = 0.85
```

**Phase 2: Fuzzy Matching** (Medium Confidence)
```
Rule 4: Fuzzy name match (Levenshtein distance < 2)
        + Exact Birth Date
        → Confidence = 0.75

Rule 5: Exact name + Birth Date within 1 day (typo correction)
        → Confidence = 0.70
```

**Phase 3: Probabilistic Matching** (Machine Learning)
```
Input Features:
  - Name similarity score (multiple algorithms)
  - Birth date proximity
  - Gender match
  - SSN partial match
  - Address similarity
  - Phone number match
  - Historical claims patterns

Model Output:
  - Match probability (0.0 to 1.0)
  - Feature importance scores

Training Data:
  - Historical steward-reviewed matches
  - Known true matches (family members)
  - Known false matches (flagged duplicates)
```

### Confidence Score Thresholds

| Confidence Range | Decision | Action |
|------------------|----------|--------|
| **0.95 - 1.00** | Auto-Match | System automatically links entities |
| **0.75 - 0.94** | Review Required | Queue for steward review |
| **0.50 - 0.74** | Possible Match | Flag for investigation |
| **< 0.50** | No Match | Create new entity |

### Household Identification

**Household Clustering Algorithm**:
```
Step 1: Link members with exact address match
Step 2: Link members with same last name + similar address
Step 3: Link members with explicit relationship codes (subscriber/dependent)
Step 4: Apply ML clustering on geographic + demographic features

Output: Household ID assigned to related members
```

**Household Entity**:
```sql
CREATE TABLE h_household (
    household_hk        BINARY(16) PRIMARY KEY,
    household_id        VARCHAR(50),
    record_source       VARCHAR(50),
    load_timestamp      TIMESTAMP_NTZ
);

CREATE TABLE l_person_household (
    person_household_hk BINARY(16) PRIMARY KEY,
    person_mdm_hk       BINARY(16),
    household_hk        BINARY(16),
    relationship_role   VARCHAR(50),  -- 'HEAD_OF_HOUSEHOLD', 'SPOUSE', 'DEPENDENT'
    record_source       VARCHAR(50),
    load_timestamp      TIMESTAMP_NTZ
);
```

---

## Golden Record Creation Strategy

### Attribute Selection Rules

**Rule Priority (Highest to Lowest)**:
1. **Most Recent**: Prefer most recently updated value
2. **Most Complete**: Prefer non-null over null
3. **Most Frequent**: Prefer value appearing in most sources
4. **Highest Quality Source**: Prefer trusted source (configured)
5. **Manual Override**: Steward-selected value takes precedence

**Example Rule Implementation**:
```sql
-- Golden record attribute selection logic
WITH source_values AS (
    SELECT
        person_id,
        'legacy_facets' AS source,
        first_name,
        load_timestamp,
        ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY load_timestamp DESC) AS recency_rank
    FROM s_member_demographics_legacy_facets
    WHERE load_end_timestamp IS NULL

    UNION ALL

    SELECT
        person_id,
        'gemstone_facets' AS source,
        first_name,
        load_timestamp,
        ROW_NUMBER() OVER (PARTITION BY person_id ORDER BY load_timestamp DESC) AS recency_rank
    FROM s_member_demographics_gemstone_facets
    WHERE load_end_timestamp IS NULL
),
ranked_values AS (
    SELECT
        person_id,
        first_name,
        source,
        CASE
            WHEN source = 'gemstone_facets' THEN 1  -- Preferred source
            WHEN source = 'legacy_facets' THEN 2
            ELSE 3
        END AS source_priority,
        CASE
            WHEN first_name IS NOT NULL THEN 1
            ELSE 2
        END AS completeness_priority,
        recency_rank
    FROM source_values
)
SELECT
    person_id,
    FIRST_VALUE(first_name) OVER (
        PARTITION BY person_id
        ORDER BY
            completeness_priority,    -- Non-null first
            source_priority,          -- Preferred source first
            recency_rank              -- Most recent first
    ) AS golden_first_name,
    FIRST_VALUE(source) OVER (...) AS first_name_source
FROM ranked_values;
```

### Conflict Resolution

**Conflicting Data Handling**:
```sql
-- Track conflicting values for review
CREATE TABLE mdm_attribute_conflicts (
    conflict_id         VARCHAR(50) PRIMARY KEY,
    person_id           VARCHAR(50),
    attribute_name      VARCHAR(100),
    source_1            VARCHAR(50),
    value_1             VARCHAR(500),
    source_2            VARCHAR(50),
    value_2             VARCHAR(500),
    confidence_1        DECIMAL(5,4),
    confidence_2        DECIMAL(5,4),

    -- Resolution
    resolved            BOOLEAN DEFAULT FALSE,
    selected_value      VARCHAR(500),
    resolution_method   VARCHAR(50),  -- 'AUTO', 'STEWARD', 'RULE'
    resolved_by         VARCHAR(100),
    resolved_timestamp  TIMESTAMP_NTZ
);
```

---

## Data Stewardship Workflow

### Steward Responsibilities

**Match Review**:
- Review uncertain matches (confidence 0.75-0.94)
- Approve or reject system-suggested matches
- Create manual matches for edge cases
- Split incorrectly merged entities

**Golden Record Curation**:
- Resolve attribute conflicts
- Select best values when rules insufficient
- Override system selections when needed
- Enrich records with additional research

**Quality Monitoring**:
- Review match quality dashboards
- Flag systematic matching errors
- Recommend algorithm improvements

### Steward UI Requirements (Future)

**Match Review Queue**:
```
┌─────────────────────────────────────────────────────────────┐
│ Potential Match Review                                      │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│ Person A (legacy_facets)    │ Person B (gemstone_facets)   │
│ ─────────────────────────   │ ──────────────────────────   │
│ Name: John A Smith          │ Name: Jon A. Smith           │
│ DOB: 1980-01-15             │ DOB: 1980-01-15              │
│ Gender: M                   │ Gender: M                    │
│ SSN: ***-**-6789            │ SSN: ***-**-6789             │
│                             │                              │
│ Match Confidence: 0.87 (Review Required)                   │
│ Matched On: Name (fuzzy), DOB (exact), SSN (partial)       │
│                                                             │
│ [Accept Match] [Reject Match] [Need More Info]             │
└─────────────────────────────────────────────────────────────┘
```

---

## Implementation Roadmap

### Phase 1: Foundation (Q1 2025)
- [ ] Design enhanced Data Vault hub/link/satellite structures for MDM
- [ ] Implement composite business key strategy
- [ ] Create MDM golden record hubs (person, provider, product)
- [ ] Build match confidence bridge tables
- [ ] Document attribute selection rules

### Phase 2: Enhanced Algorithms (Q2 2025)
- [ ] Implement fuzzy matching logic
- [ ] Add confidence scoring to existing deterministic rules
- [ ] Create match candidate generation process
- [ ] Build initial ML model for probabilistic matching
- [ ] Implement household clustering algorithm

### Phase 3: Golden Records (Q3 2025)
- [ ] Implement attribute selection rules engine
- [ ] Build conflict detection and tracking
- [ ] Create golden record generation process
- [ ] Implement steward review workflows
- [ ] Deploy initial golden records (member domain)

### Phase 4: Expansion (Q4 2025+)
- [ ] Extend to provider and product domains
- [ ] Implement provider relationship graphs
- [ ] Add temporal change tracking
- [ ] Continuous ML model improvement
- [ ] Full steward UI deployment

---

## AI Implementation Hints

### Code Generation Patterns

**MDM Hub Template**:
```yaml
hub:
  name: h_person_mdm
  type: mdm_golden
  business_key: person_id
  source: MDM_PROCESS
  related_source_hubs:
    - h_member (composite BK pattern)
```

**Match Link Template**:
```yaml
link:
  name: l_member_person
  type: identity_resolution
  hubs:
    - h_member
    - h_person_mdm
  attributes:
    - match_confidence (DECIMAL)
    - match_method (VARCHAR)
  effectivity: true
```

### Validation Criteria

**Must Have**:
- [ ] Composite business keys in source hubs
- [ ] Separate MDM hubs for golden records
- [ ] Identity resolution links with confidence scores
- [ ] Multi-source satellite pattern maintained
- [ ] Golden record satellites with attribute source tracking

**Should Have**:
- [ ] Bridge tables for match candidates
- [ ] Conflict tracking tables
- [ ] Steward review workflow tables
- [ ] Match quality metrics captured

---

**Document Version**: 1.0
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
**Status**: Strategy in development - implementation pending
