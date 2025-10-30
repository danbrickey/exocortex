# Engineering Specification: Member COB Data Vault 2.0 Implementation

## Overview

This document provides the technical specification for implementing the Member COB (Coordination of Benefits) Profile entity in Data Vault 2.0 architecture. The implementation creates a new hub for COB indicators, a link connecting members to COB indicators, and effectivity satellites tracking time-variant attributes.

## Architecture Pattern

**Pattern Type:** Hub-Link-Satellite with Composite Business Key

**Components:**
1. **h_cob_indicator** - NEW hub with composite business key
2. **l_member_cob** - Link between h_member and h_cob_indicator
3. **s_member_cob_gemstone_facets** - Effectivity satellite (attached to link)
4. **s_member_cob_legacy_facets** - Effectivity satellite (attached to link)
5. **current_member_cob** - Current state view

## Data Flow

```
Source Systems
  |
  ├── gemstone_facets.dbo.cmc_mecb_cob
  └── legacy_facets.dbo.cmc_mecb_cob
        |
        v
Staging Layer (Rename)
  |
  ├── stg_member_cob_gemstone_facets_rename
  └── stg_member_cob_legacy_facets_rename
        |
        v
Staging Layer (Hash Keys)
  |
  ├── stg_member_cob_gemstone_facets
  └── stg_member_cob_legacy_facets
        |
        v
Raw Vault Layer
  |
  ├── h_cob_indicator (NEW HUB)
  ├── l_member_cob (LINK)
  ├── s_member_cob_gemstone_facets (EFFECTIVITY SAT)
  └── s_member_cob_legacy_facets (EFFECTIVITY SAT)
        |
        v
Business Vault Layer
  |
  └── current_member_cob (VIEW)
```

## Component Specifications

### 1. h_cob_indicator Hub

**Purpose:** Store unique COB indicator configurations

**Business Key:** Composite key from three components
- `insurance_type_cd`
- `insurance_order_cd`
- `supp_drug_type_cd`

**Hash Key Generation:**
```sql
{{ dbt_utils.generate_surrogate_key([
    'insurance_type_cd',
    'insurance_order_cd',
    'supp_drug_type_cd'
]) }} AS cob_indicator_hk
```

**Columns:**
| Column | Type | Description |
|--------|------|-------------|
| cob_indicator_hk | VARCHAR(32) | Hash of composite business key |
| insurance_type_cd | VARCHAR | Insurance type code |
| insurance_order_cd | VARCHAR | Insurance order code |
| supp_drug_type_cd | VARCHAR | Supplemental drug type code |
| src_source_system | VARCHAR | First source system |
| src_load_dtm | TIMESTAMP | First load timestamp |

**Materialization:** Incremental
**Unique Key:** `cob_indicator_hk`
**Deduplication:** ROW_NUMBER() by cob_indicator_hk, ordered by load_dtm ASC

### 2. l_member_cob Link

**Purpose:** Connect members to their COB indicator configurations

**Parent Hubs:**
- `h_member` (via member_hk)
- `h_cob_indicator` (via cob_indicator_hk)

**Hash Key Generation:**
```sql
{{ dbt_utils.generate_surrogate_key([
    'member_bk',
    'insurance_type_cd',
    'insurance_order_cd',
    'supp_drug_type_cd'
]) }} AS member_cob_hk
```

**Columns:**
| Column | Type | Description |
|--------|------|-------------|
| member_cob_hk | VARCHAR(32) | Hash of combined business keys |
| member_hk | VARCHAR(32) | Foreign key to h_member |
| cob_indicator_hk | VARCHAR(32) | Foreign key to h_cob_indicator |
| src_source_system | VARCHAR | First source system |
| src_load_dtm | TIMESTAMP | First load timestamp |

**Materialization:** Incremental
**Unique Key:** `member_cob_hk`
**Deduplication:** ROW_NUMBER() by member_cob_hk, ordered by load_dtm ASC

### 3. s_member_cob_gemstone_facets Effectivity Satellite

**Purpose:** Track time-variant COB attributes from Gemstone source

**Parent:** `l_member_cob` (attached to link, NOT hub)

**Effectivity Columns:**
| Column | Source | Description |
|--------|--------|-------------|
| src_pk | member_cob_hk | Link to l_member_cob |
| src_eff | effective_dt | Effectivity timestamp |
| src_start_date | effective_dt | Period start date |
| src_end_date | termination_dt | Period end date |

**Hash Diff Columns:**
- termination_dt
- termination_reason_cd
- group_bk
- carrier_id
- policy_id
- medicare_secondary_payer_type_cd
- rx_coverage_type_cd
- rx_bin_nbr
- rx_pcn_nbr
- rx_group_nbr
- rx_id
- last_verification_dt
- last_verification_nm
- verification_method_cd
- loi_start_dt
- primary_holder_last_nm
- primary_holder_first_nm
- primary_holder_id
- lock_token_nbr
- attachment_source_id
- last_update_dtm
- last_update_user_id
- last_update_db_user_id

**Descriptive Attributes:**
- termination_dt (DATE) - Termination date
- termination_reason_cd (VARCHAR) - Termination reason code
- group_bk (VARCHAR) - Group business key
- carrier_id (VARCHAR) - Carrier identifier
- policy_id (VARCHAR) - Policy identifier
- medicare_secondary_payer_type_cd (VARCHAR) - Medicare secondary payer type
- rx_coverage_type_cd (VARCHAR) - Prescription coverage type
- rx_bin_nbr (VARCHAR) - RX BIN number
- rx_pcn_nbr (VARCHAR) - RX PCN number
- rx_group_nbr (VARCHAR) - RX group number
- rx_id (VARCHAR) - RX identifier
- last_verification_dt (DATE) - Last verification date
- last_verification_nm (VARCHAR) - Last verification name
- verification_method_cd (VARCHAR) - Verification method code
- loi_start_dt (DATE) - Letter of Intent start date
- primary_holder_last_nm (VARCHAR) - Primary holder last name
- primary_holder_first_nm (VARCHAR) - Primary holder first name
- primary_holder_id (VARCHAR) - Primary holder identifier
- lock_token_nbr (INTEGER) - Lock token number
- attachment_source_id (VARCHAR) - Attachment source identifier

**System Columns:**
- last_update_dtm (TIMESTAMP) - Last update timestamp
- last_update_user_id (VARCHAR) - Last update user ID
- last_update_db_user_id (VARCHAR) - Last update database user ID

**Materialization:** Incremental
**Unique Key:** `['member_cob_hk', 'effective_dt']`
**Deduplication:** Hash diff comparison

**IMPORTANT:** NO `member_cob_ik` column in src_extra_columns!

### 4. s_member_cob_legacy_facets Effectivity Satellite

**Purpose:** Track time-variant COB attributes from Legacy source

**Specification:** Same as s_member_cob_gemstone_facets (see above)
**Source System:** legacy_facets

### 5. current_member_cob View

**Purpose:** Provide current state of member COB relationships

**Business Logic:**

1. **Effectivity Filter:**
   ```sql
   WHERE CURRENT_DATE BETWEEN COALESCE(src_start_date, '1900-01-01')
                          AND COALESCE(src_end_date, '9999-12-31')
   ```

2. **Source Prioritization:**
   - Gemstone facets (priority 1)
   - Legacy facets (priority 2)

3. **Recency Selection:**
   - Most recent effective_dt per member_cob_hk

**Join Pattern:**
```sql
FROM l_member_cob l
INNER JOIN h_member hm ON l.member_hk = hm.member_hk
INNER JOIN h_cob_indicator hc ON l.cob_indicator_hk = hc.cob_indicator_hk
LEFT JOIN prioritized_satellites s ON l.member_cob_hk = s.member_cob_hk
```

**Output Columns:**
- All business keys (member_bk, insurance_type_cd, insurance_order_cd, supp_drug_type_cd)
- All hash keys (member_cob_hk, member_hk, cob_indicator_hk)
- All descriptive attributes from satellite
- All system columns
- Source system metadata

**Materialization:** View

## Hash Key Standards

### Hash Algorithm
- Use dbt_utils.generate_surrogate_key() macro
- Algorithm: MD5 hash of concatenated business keys
- Output: 32-character hexadecimal string

### Naming Conventions
- Hub hash keys: `{entity_name}_hk`
- Link hash keys: `{entity1}_{entity2}_hk`
- Hash diff: `hash_diff`

### Business Key Handling
- Trim whitespace
- Cast to string
- NULL handling: COALESCE to empty string or default
- Composite keys: Concatenate in consistent order

## Incremental Load Strategy

### First Load (Full)
```sql
{% if is_incremental() %}
  -- Incremental logic
{% else %}
  -- Full load
{% endif %}
```

### Subsequent Loads (Incremental)

**Hubs and Links:**
- Filter: `load_dtm > (SELECT MAX(src_load_dtm) FROM {{ this }})`
- Deduplicate: Exclude existing hash keys
- Insert: Only new hash keys

**Satellites:**
- Filter: `load_dtm > (SELECT MAX(src_load_dtm) FROM {{ this }})`
- Deduplicate: Compare hash_diff for same pk + effective_dt
- Insert: Only changed records

## Effectivity Logic

### Source Mapping
| Source Column | DV2 Column | Purpose |
|---------------|------------|---------|
| mecb_eff_dt | src_eff | Effectivity timestamp |
| mecb_eff_dt | src_start_date | Period start |
| mecb_term_dt | src_end_date | Period end |

### Active Record Definition
```sql
CURRENT_DATE BETWEEN COALESCE(src_start_date, '1900-01-01')
                 AND COALESCE(src_end_date, '9999-12-31')
```

### NULL Termination Date Handling
- NULL `termination_dt` → `src_end_date = '9999-12-31'`
- Represents open-ended/current records

## Source System Integration

### Gemstone Facets
- **Database:** gemstone_facets
- **Schema:** dbo
- **Table:** cmc_mecb_cob
- **Priority:** 1 (Highest)
- **Identifier:** 'gemstone_facets'

### Legacy Facets
- **Database:** legacy_facets
- **Schema:** dbo
- **Table:** cmc_mecb_cob
- **Priority:** 2
- **Identifier:** 'legacy_facets'

### Source System Metadata
- All models include `source_system` column
- All models include `load_dtm` timestamp
- Enables source system traceability

## Testing Strategy

### Unit Tests

1. **Hash Key Generation**
   - Verify consistent hash generation
   - Test NULL handling in business keys
   - Validate composite key ordering

2. **Deduplication**
   - Verify first-in-time logic for hubs/links
   - Test cross-source deduplication
   - Validate ROW_NUMBER() partitioning

3. **Effectivity Logic**
   - Test active record selection
   - Verify NULL termination_dt handling
   - Validate date range filters

### Integration Tests

1. **End-to-End Flow**
   - Load data from both sources
   - Verify hub/link creation
   - Confirm satellite attribution
   - Validate current view output

2. **Incremental Loads**
   - Test new records insertion
   - Verify existing records exclusion
   - Validate change detection (hash_diff)

3. **Source Prioritization**
   - Confirm gemstone priority over legacy
   - Test tie-breaking by load_dtm

### Data Quality Checks

1. **Business Key Integrity**
   - No NULL values in business keys
   - No duplicate hash keys in hubs/links
   - Valid composite key combinations

2. **Referential Integrity**
   - All link.member_hk exists in h_member
   - All link.cob_indicator_hk exists in h_cob_indicator
   - All satellite.src_pk exists in l_member_cob

3. **Temporal Integrity**
   - src_start_date <= src_end_date
   - No overlapping effectivity periods for same pk
   - Valid date ranges

## Performance Considerations

### Indexing Strategy

**h_cob_indicator:**
- Primary key: cob_indicator_hk
- Composite index: (insurance_type_cd, insurance_order_cd, supp_drug_type_cd)

**l_member_cob:**
- Primary key: member_cob_hk
- Foreign key indexes: member_hk, cob_indicator_hk

**Satellites:**
- Primary key: (member_cob_hk, effective_dt)
- Index: src_start_date, src_end_date
- Index: hash_diff (for deduplication)

### Partitioning

**Satellites:**
- Partition by: load_dtm (monthly or yearly)
- Prune old partitions based on retention policy

### Query Optimization

**Current View:**
- Consider materializing as table for large datasets
- Use covering indexes for frequent query patterns
- Pre-aggregate if view performance degrades

## Dependencies

### External Dependencies
- **dbt Core:** >= 1.0.0
- **dbt-utils:** >= 0.8.0
- **Database:** Snowflake/BigQuery/Redshift (adapt SQL syntax as needed)

### Internal Dependencies
- **h_member:** Must exist before l_member_cob creation
- **Source tables:** Both source systems must be accessible

## Migration Path

### Initial Load
1. Create h_cob_indicator (full load from both sources)
2. Create l_member_cob (full load from both sources)
3. Create satellites (full load from both sources)
4. Create current view
5. Validate data integrity
6. Run reconciliation queries

### Cutover
1. Schedule downtime window (if required)
2. Execute final incremental load
3. Switch consumers to current_member_cob view
4. Monitor query performance
5. Decommission legacy views

## Monitoring and Alerts

### Load Metrics
- Records loaded per source
- Load duration
- Failed records count
- Hash key collisions

### Data Quality Metrics
- NULL business key violations
- Referential integrity violations
- Duplicate hash key violations
- Effectivity period overlaps

### Performance Metrics
- Query response time (current view)
- Incremental load performance
- Index usage statistics

## Deprecated Patterns

### DO NOT USE

1. **member_cob_ik column**
   - Deprecated surrogate key pattern
   - Not part of Data Vault 2.0 standard
   - Should NOT appear in any model

2. **Source system surrogate keys**
   - Do not use original system PKs as hash keys
   - Use business keys only

3. **Single-source loads**
   - Always union both sources
   - Maintain source system traceability

## Appendix

### Complete Column Mappings

| Source Column | Standardized Name | Target Models |
|---------------|-------------------|---------------|
| meme_ck | member_bk | Staging, Business Keys |
| mecb_insur_type | insurance_type_cd | h_cob_indicator, Staging |
| mecb_insur_order | insurance_order_cd | h_cob_indicator, Staging |
| mecb_mctr_styp | supp_drug_type_cd | h_cob_indicator, Staging |
| mecb_eff_dt | effective_dt | Satellites (src_eff, src_start_date) |
| mecb_term_dt | termination_dt | Satellites (src_end_date, attribute) |
| mecb_mctr_trsn | termination_reason_cd | Satellites |
| grgr_ck | group_bk | Satellites |
| mcre_id | carrier_id | Satellites |
| mecb_policy_id | policy_id | Satellites |
| mecb_mctr_msp | medicare_secondary_payer_type_cd | Satellites |
| mecb_mctr_ptyp | rx_coverage_type_cd | Satellites |
| mecb_rxbin | rx_bin_nbr | Satellites |
| mecb_rxpcn | rx_pcn_nbr | Satellites |
| mecb_rx_group | rx_group_nbr | Satellites |
| mecb_rx_id | rx_id | Satellites |
| mecb_last_ver_dt | last_verification_dt | Satellites |
| mecb_last_ver_name | last_verification_nm | Satellites |
| mecb_mctr_vmth | verification_method_cd | Satellites |
| mecb_loi_start_dt | loi_start_dt | Satellites |
| mecb_prim_last_nm | primary_holder_last_nm | Satellites |
| mecb_prim_first_nm | primary_holder_first_nm | Satellites |
| mecb_prim_id | primary_holder_id | Satellites |
| mecb_lock_token | lock_token_nbr | Satellites |
| atxr_source_id | attachment_source_id | Satellites |
| sys_last_upd_dtm | last_update_dtm | Satellites (system) |
| sys_usus_id | last_update_user_id | Satellites (system) |
| sys_dbuser_id | last_update_db_user_id | Satellites (system) |

### SQL File Inventory

| File | Type | Purpose |
|------|------|---------|
| stg_member_cob_gemstone_facets_rename.sql | Staging | Rename Gemstone columns |
| stg_member_cob_legacy_facets_rename.sql | Staging | Rename Legacy columns |
| stg_member_cob_gemstone_facets.sql | Staging | Generate hash keys (Gemstone) |
| stg_member_cob_legacy_facets.sql | Staging | Generate hash keys (Legacy) |
| h_cob_indicator.sql | Hub | Store unique COB indicators |
| l_member_cob.sql | Link | Link members to COB indicators |
| s_member_cob_gemstone_facets.sql | Satellite | Gemstone attributes |
| s_member_cob_legacy_facets.sql | Satellite | Legacy attributes |
| current_member_cob.sql | View | Current state view |
| member_cob_user_story.md | Documentation | User story |
| engineering_spec_member_cob.md | Documentation | This specification |

---

**Document Version:** 1.0
**Last Updated:** 2025-10-29
**Author:** Data Engineering Team
**Status:** Final
