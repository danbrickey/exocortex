---
title: "Network Set Business Rules"
document_type: "business_rules"
business_domain: ["provider", "membership", "product"]
edp_layer: "business_vault"
technical_topics: ["network-management", "effectivity-satellite", "data-vault-2.0", "provider-networks", "member-eligibility"]
audience: ["provider-network-operations", "claims-operations", "business-analysts", "data-stewards"]
status: "draft"
last_updated: "2025-10-27"
version: "1.0"
author: "Dan Brickey"
description: "Business rules for network set dimension and member/provider network set lookups including temporal effectivity logic"
related_docs:
  - "docs/architecture/edp_platform_architecture.md"
  - "docs/architecture/edp-layer-architecture-detailed.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "bv_s_network_set, bv_s_member_network_set_business, bv_sprovider_network_set_business"
legacy_source: "EDW2 dimNetworkSet stored procedures"
---

# Network Set Business Rules

## Overview

The Network Set artifacts provide a comprehensive view of healthcare provider networks and their associations with members and providers. These artifacts enable the organization to track which networks are available, which members are assigned to specific networks based on their eligibility and plan details, and which providers participate in specific networks over time.

The network set implementation consists of three interconnected components:

1. **Network Set Dimension**: Master list of all network sets with their attributes
2. **Member Network Set Lookup**: Temporal tracking of member-to-network assignments
3. **Provider Network Set Lookup**: Temporal tracking of provider network participation

## 1. Network Set Dimension

### Purpose

The Network Set Dimension (`bv_s_network_set`) serves as the master reference for all network sets across source systems, consolidating data from both legacy FACETS systems and the BCI Master Data Management (MDM) system.

### Source Data

- **Primary Sources**:
  - `current_network_set`: Network set definitions including prefixes, effective dates, and termination dates
  - `current_network`: Network master data containing network names and identifiers
  - `current_product_component`: Product component descriptions for network sets
  - `r_provider_network_mdm`: MDM reference data for provider networks (BCI MDM system)

### Business Rules

#### Network Set Identification

1. **Network Set Primary Key**: Combination of `network_set` (prefix) and `network_id`
   - Example: Network set "ABC" with network ID "12345"

2. **Historical Cutoff**: Only include network sets with termination dates on or after January 1, 2016
   - Rule: `network_set_term_dt >= '01/01/2016'`
   - Rationale: Excludes obsolete historical networks that are no longer relevant for current operations

3. **Null Handling**: Exclude records where `network_set_prefix` is null
   - Ensures data quality by preventing incomplete network set definitions

#### Network Name Resolution

Network names are derived using source-specific logic:

1. **Legacy FACETS Source** (`source = 'legacy_facets'`):
   - Network name comes directly from `current_network.network_name`
   - Uses historical network naming conventions from legacy systems

2. **Other Sources**:
   - Network name comes from `current_product_component.component_prefix_description`
   - Uses the product component description where component type = 'NWST'
   - Provides standardized, modern naming conventions

#### MDM Integration

1. **MDM Captured Flag**:
   - Records from raw vault sources: `mdm_captured = 'N'`
   - Records from BCI MDM system: `mdm_captured = 'Y'`
   - Purpose: Track which networks have been validated and managed through MDM

2. **MDM Record Source**:
   - MDM records use `dss_record_source = 'bci-mdm.ref.providernetwork'`
   - Raw vault records use their original `edp_record_source`

3. **MDM Field Mapping**:
   - `facets_network_set` → `network_set`
   - `network_code` → `network_code`
   - `network_name` → `network_name`
   - `facets_nwnw_id` → `network_id`

#### Duplicate Resolution

When multiple records exist for the same network set and network ID combination:

1. **Deduplication Logic**: Use `row_number()` partitioned by `network_set` and `network_id`
   - Order by `source desc` to prioritize certain source systems
   - Keep only the first record (`row_num = 1`)

2. **Grouping**: Results are grouped to ensure distinct network set definitions
   - Group by: `tenant_id`, `source`, `network_set_prefix`, `network_name`, `network_id`, `dss_record_source`

### Output Columns

| Column | Description | Business Rule |
|--------|-------------|---------------|
| `tenant_id` | Organization tenant identifier | Carried from source systems |
| `source` | Source system identifier | Identifies origin system (legacy_facets, gemstone_facets, etc.) |
| `network_code` | Network code identifier | Same as network_set_prefix |
| `network_name` | Descriptive network name | Resolved based on source system logic |
| `network_id` | Network identifier | Foreign key to network master |
| `network_set` | Network set prefix | Primary business key component |
| `mdm_captured` | MDM flag | 'Y' if from MDM, 'N' if from raw vault |
| `dss_record_source` | Data lineage tracking | Source system or 'bci-mdm.ref.providernetwork' |
| `dss_create_time` | Record creation timestamp | System-generated |
| `dss_update_time` | Record update timestamp | System-generated |

---

## 2. Member Network Set Lookup

### Purpose

The Member Network Set Lookup (`bv_s_member_network_set_business`) provides temporal tracking of which network sets are assigned to each member based on their eligibility, plan assignments, and product configurations. This effectivity satellite enables accurate network assignment determination for any point in time.

### Source Data

- **Primary Sources**:
  - `current_member_eligibility`: Member eligibility records with effective and termination dates
  - `current_member`: Member master data
  - `current_group_plan_eligibility`: Group plan assignments linking members to network sets
  - `current_network_set`: Network set definitions with temporal validity
  - `current_product_component`: Product component validation
  - `current_group`: Employer group information
  - `current_subscriber`: Subscriber identifiers
  - `h_member`: Member hub for hash key linkage
  - `dim_network_set`: Network set dimension for hash key linkage

### Business Rules

#### Eligibility Filtering

1. **Active Eligibility Only**: Include only members with active eligibility
   - Rule: `eligibility_ind = 'Y'`
   - Purpose: Exclude terminated or inactive member records

2. **Medical Product Category**: Limit to medical membership
   - Rule: `product_category_bk = 'M'`
   - Rationale: Network sets are specific to medical benefits; excludes dental, vision, etc.

3. **Historical Cutoff**: Only include eligibility terminating on or after January 1, 2017
   - Rule: `elig_term_dt >= '01/01/2017'`
   - Purpose: Focus on recent/current member eligibility

4. **Record Status**: Only active records
   - Rule: `edp_record_status = 'Y'` across all joined tables
   - Ensures data quality by excluding logically deleted records

#### Temporal Join Logic

The temporal joins ensure that network assignments are only created when all component date ranges overlap:

1. **Plan-to-Eligibility Temporal Join**:
   ```
   plan_eff_dt <= elig_term_dt AND plan_term_dt >= elig_eff_dt
   ```
   - Ensures plan coverage overlaps with member eligibility period

2. **Network Set-to-Plan Temporal Join**:
   ```
   network_set_eff_dt <= plan_term_dt AND network_set_term_dt >= plan_eff_dt
   ```
   - Ensures network set is valid during the plan's effective period

3. **Network Set-to-Eligibility Temporal Join**:
   ```
   network_set_eff_dt <= elig_term_dt AND network_set_term_dt >= elig_eff_dt
   ```
   - Ensures network set is valid during the member's eligibility period

#### Date Range Calculation

The model uses a sophisticated temporal effectivity algorithm to create non-overlapping date ranges:

##### Step 1: Identify Date Boundaries
All potential start and end dates are collected from three sources:
- Member eligibility dates (`elig_eff_dt`, `elig_term_dt`)
- Plan dates (`plan_eff_dt`, `plan_term_dt`)
- Network set dates (`network_set_eff_dt`, `network_set_term_dt`)

##### Step 2: Generate Discrete Date Ranges
- **From Dates**: All effective dates plus day-after-termination dates
  - Effective dates: `elig_eff_dt`, `plan_eff_dt`, `network_set_eff_dt`
  - Day after termination: `dateadd(day, 1, term_dt)` for non-high-date terminators
  - High date handling: Keep `12/31/9999` as-is without adding a day

- **Thru Dates**: All termination dates plus day-before-effective dates
  - Termination dates: `elig_term_dt`, `plan_term_dt`, `network_set_term_dt`
  - Day before effective: `dateadd(day, -1, eff_dt)`

##### Step 3: Match From/Thru Dates
- Pair each from_date with the nearest thru_date where `thru_date >= from_date`
- Use `row_number()` with `datediff(day, from_date, thru_date)` to find closest match
- Exclude impossible dates (`9999-12-31` and `2200-01-01`)

##### Step 4: Attribute Assignment
For each discrete date range:
- Find all network set assignments where the start_date falls within:
  - Eligibility period
  - Plan period
  - Network set validity period
- When multiple network sets qualify, prioritize using `network_set_seq_no`
- Keep only the first match (`rownum = 1`)

##### Step 5: Gap Removal
- Remove date ranges where no network set could be assigned
- Rule: `network_set_prefix is not null AND network_id is not null`

##### Step 6: Contiguous Date Range Consolidation
Use recursive CTE logic to consolidate adjacent date ranges with the same attributes:

1. **Anchor**: Find ranges with no immediately preceding range (start of a contiguous period)
   - Look for ranges where `dateadd(day, -1, start_date) <> prior_end_date`

2. **Recursive**: Chain forward through adjacent ranges
   - Connect ranges where `dateadd(day, -1, next_start_date) = current_end_date`
   - Same member, network_id, and network_set_prefix
   - Limit recursion to 99 levels to prevent infinite loops

3. **Final Collapse**: Group by start_date and take `max(end_date)`
   - Results in the longest possible contiguous date ranges

#### Business Keys Enrichment

After date range calculation, enrich with business identifiers:

- `group_id`: From `current_group` via member's `employer_group_bk`
- `subscriber_id`: From `current_subscriber` via member's `subscriber_bk`
- `member_suffix`: From `current_member`

#### Current Record Indicator

- Rule: `is_current = '1'` when current timestamp falls between `dss_start_date` and `dss_end_date`
- Otherwise: `is_current = '0'`
- Purpose: Enable fast filtering for current state queries

### Output Columns

| Column | Description | Business Rule |
|--------|-------------|---------------|
| `source` | Source system identifier | Inherited from member eligibility |
| `tenant_id` | Organization tenant identifier | Inherited from member data |
| `member_bk` | Member business key | Primary member identifier |
| `group_id` | Employer group identifier | Resolved from member's employer group |
| `subscriber_id` | Subscriber identifier | Resolved from member's subscriber relationship |
| `member_suffix` | Member suffix | Member's suffix within subscriber family |
| `network_set_prefix` | Network set prefix | Assigned network set |
| `network_id` | Network identifier | Network associated with the set |
| `dss_start_date` | Effectivity start date | Begin date of network assignment |
| `dss_end_date` | Effectivity end date | End date of network assignment |
| `is_current` | Current record indicator | '1' if currently active, '0' otherwise |
| `hk_member` | Member hash key | Data Vault 2.0 hub key reference |
| `hk_network_set` | Network set hash key | Data Vault 2.0 dimension key reference |
| `dss_record_source` | Data lineage tracking | Source system for audit trail |
| `dss_create_time` | Record creation timestamp | System-generated |
| `dss_update_time` | Record update timestamp | System-generated |

---

## 3. Provider Network Set Lookup

### Purpose

The Provider Network Set Lookup (`bv_sprovider_network_set_business`) provides temporal tracking of provider participation in network sets. This effectivity satellite enables accurate determination of provider network status for any point in time, critical for claims adjudication and provider directory accuracy.

### Source Data

- **Primary Sources**:
  - `current_provider_network_relational`: Provider-network relationships with effective/term dates
  - `current_network`: Network master with network names and types
  - `current_user_defined_code_translations`: Network type descriptions
  - `current_product_component`: Network prefix descriptions
  - `h_provider`: Provider hub for hash key linkage
  - `dim_network_set`: Network set dimension for hash key linkage

### Business Rules

#### Provider Network Relationship Processing

##### Step 1: Handle Overlapping Date Ranges

The source data may contain overlapping effective dates for the same provider-network-prefix combination. The logic handles this by:

1. **Adjust Overlapping Effective Dates**:
   - When consecutive records have the same `provider_network_eff_dt`
   - Shift the later record's effective date to the day after the earlier record's termination
   - Rule: `dateadd(day, 1, lag(provider_network_term_dt))`

2. **Group by Effective Date**:
   - Take `max(provider_network_term_dt)` for each unique effective date
   - Handles cases where multiple termination dates exist for the same effective date

##### Step 2: Temporal Window Analysis

Use window functions to establish temporal context:

1. **Prior and Next Dates**: Track preceding and following date ranges
   - `prior_provider_network_eff_dt`: Previous effective date for same provider/network/prefix
   - `next_provider_network_eff_dt`: Next effective date
   - `prior_provider_network_term_dt`: Previous termination date
   - `next_provider_network_term_dt`: Next termination date

2. **Start Date Determination**:
   - If `prior_provider_network_eff_dt = '1900-01-01'`: Use actual `provider_network_eff_dt`
   - Otherwise: Use `provider_network_eff_dt` as-is
   - Purpose: Handle legacy records with placeholder dates

##### Step 3: End Date Calculation

Calculate end dates using lead window functions:

1. **For Non-Final Records**:
   - End date = `dateadd(day, -1, next_start_date)`
   - Creates non-overlapping date ranges

2. **For Final (Current) Records**:
   - When `lead(start_date) is null`
   - End date = `provider_network_term_dt` (high date or actual termination)
   - Ensures open-ended ranges for active relationships

##### Step 4: Participation Status

- **Active**: When `lead(start_date, 1, null) is null` (no subsequent record)
- **InActive**: When another record follows (superseded by new relationship)
- Purpose: Track current vs. historical network participation

#### Pre-2003 Records Handling

Special logic creates pre-participation records:

1. **Condition**: When `min(provider_network_eff_dt) > '2003-01-01'`
2. **Create Synthetic Record**:
   - Effective date: `'2003-01-01'`
   - Termination date: `dateadd(day, -1, min(provider_network_eff_dt))`
3. **Purpose**: Establish that provider was not in network before their first recorded participation

#### Network Attribute Enrichment

##### Network Name
- Source: `current_network.network_name`
- Provides human-readable network identifier

##### Network Type
- **Source**: `current_network.network_type`
- **Default**: 'PRE' (prior to network type being required) when null or empty
- **Translation**: Lookup description from `current_user_defined_code_translations`
  - Entity: 'NWNW'
  - Code type: 'TYPE'
- **Typo Correction**: Fix truncated description
  - Change: 'Health Maintenance Organizatio' → 'Health Maintenance Organization'

##### Network Prefix Description
- **BCI Special Handling**: When `provider_network_prefix_bk = 'BCI'`, use literal 'BCI'
- **Standard Lookup**: Use `current_product_component.component_prefix_description`
  - Component type: 'NWPR'
- Purpose: Provide business-friendly network prefix names

#### Effectivity Satellite Date Ranges

##### DSS_START_DATE Calculation
1. **First Record** (where `provider_network_eff_dt = min_provider_network_eff_dt`):
   - Use `'1900-01-01'` to represent "beginning of time"
   - Enables type 2 SCD queries without null handling

2. **Subsequent Records**:
   - Use actual `provider_network_eff_dt`
   - Maintains historical versioning

##### DSS_END_DATE Calculation
1. **Current/Latest Record** (where `provider_network_eff_dt = max_provider_network_eff_dt`):
   - Use `'2999-12-31'` to represent "end of time"
   - Indicates open-ended current relationship

2. **Historical Records**:
   - Use `dateadd(day, -1, next_provider_network_eff_dt)`
   - Creates non-overlapping, contiguous date ranges

#### Current Record Indicator

- Rule: `is_current = '1'` when current timestamp falls between `dss_start_date` and `dss_end_date`
- Otherwise: `is_current = '0'`
- Purpose: Enable fast filtering for current network participation

#### Record Status Filtering

- Rule: `edp_record_status = 'Y'` for all joined tables
- Purpose: Exclude logically deleted or inactive source records

#### Deduplication

- Use `row_number()` partitioned by `source`, `provider_bk`
- Order by `load_datetime desc`, `provider_hk`
- Keep only the most recent version (`rownum = 1`)

### Output Columns

| Column | Description | Business Rule |
|--------|-------------|---------------|
| `tenant_id` | Organization tenant identifier | Inherited from network data |
| `source` | Source system identifier | Inherited from provider-network relationship |
| `provider_id` | Provider business identifier | Uppercase, trimmed provider_bk |
| `network_id` | Network identifier | Trimmed network_bk |
| `network_description` | Network name | From current_network |
| `network_prefix` | Network prefix code | Trimmed provider_network_prefix_bk |
| `network_prefix_description` | Network prefix description | From product component or 'BCI' literal |
| `network_type` | Network type code | From network, default 'PRE' if null |
| `network_type_description` | Network type description | Translated from user-defined codes |
| `network_effective_date` | Network participation start | From source data |
| `network_term_date` | Network participation end | From source data or calculated |
| `network_participation_status` | Participation status | 'Active' or 'InActive' |
| `dss_start_date` | Effectivity start date | Calculated per effectivity satellite rules |
| `dss_end_date` | Effectivity end date | Calculated per effectivity satellite rules |
| `is_current` | Current record indicator | '1' if currently active, '0' otherwise |
| `provider_hk` | Provider hash key | Data Vault 2.0 hub key reference |
| `hk_network_set` | Network set hash key | Data Vault 2.0 dimension key reference |
| `dss_record_source` | Data lineage tracking | Source system for audit trail |
| `dss_create_time` | Record creation timestamp | System-generated |
| `dss_update_time` | Record update timestamp | System-generated |

---

## Data Quality Considerations

### Network Set Dimension
- Deduplication ensures one record per network set + network ID combination
- MDM flag enables tracking of data governance maturity
- Historical cutoff prevents obsolete data from cluttering dimensional models

### Member Network Set Lookup
- Temporal join logic ensures referential integrity across eligibility, plan, and network set
- Gap removal eliminates invalid date ranges
- Contiguous date consolidation prevents unnecessary fragmentation
- Recursive CTE limit (99) prevents runaway queries

### Provider Network Set Lookup
- Overlapping date range handling ensures clean temporal boundaries
- Pre-2003 synthetic records provide complete historical context
- Type 2 SCD patterns with high dates ('2999-12-31') enable point-in-time queries
- Deduplication by load_datetime ensures latest provider hub version is used

---

## Integration Points

### Upstream Dependencies
- **Raw Vault Tables**: All current_* tables from the Integration Layer
- **Reference Data**: MDM provider network reference table
- **Hubs**: h_member and h_provider for hash key relationships

### Downstream Consumers
- **Claims Adjudication**: Determines if provider is in-network for member's benefit period
- **Provider Directories**: Shows current network participation for member-facing tools
- **Benefit Eligibility**: Links members to their assigned network for benefit determination
- **Financial Reporting**: Network-based cost and utilization reporting
- **Compliance Reporting**: Ensures network adequacy and access standards

---

## Glossary

| Term | Definition |
|------|------------|
| **Network Set** | A grouping of provider networks used to define member access to providers |
| **Network Set Prefix** | Short code identifying a network set (e.g., 'BCI', 'ABC') |
| **Network ID** | Unique identifier for a specific network within a network set |
| **Effectivity Satellite** | Data Vault 2.0 pattern tracking temporal validity with start/end dates |
| **High Date** | Far-future date (9999-12-31 or 2999-12-31) representing open-ended validity |
| **Low Date** | Far-past date (1900-01-01) representing beginning of historical tracking |
| **Contiguous Date Ranges** | Adjacent time periods with no gaps between end and next start date |
| **Temporal Join** | Join condition using date range overlap logic |
| **MDM** | Master Data Management - centralized data governance system |
| **DSS Fields** | Decision Support System fields for data warehouse metadata |
| **Component Type NWST** | Product component type for network sets |
| **Component Type NWPR** | Product component type for provider network prefixes |
