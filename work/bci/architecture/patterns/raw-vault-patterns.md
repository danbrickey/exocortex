---
title: "Raw Vault Implementation Patterns"
document_type: "pattern"
business_domain: ["cross-domain"]  # Applies to all domains
edp_layer: "integration"
technical_topics: ["data-vault-2.0", "raw-vault", "dbt", "hubs", "links", "satellites", "current-views"]
audience: ["architects", "engineers"]
status: "active"
last_updated: "2025-10-24"
version: "1.0"
author: "Dan Brickey"
description: "Raw Vault implementation standards for Data Vault 2.0 integration layer including hub-link-satellite architecture, naming conventions, and healthcare entity patterns"
related_docs:
  - "../edp-layer-architecture-detailed.md"
  - "../edp_platform_architecture.md"
  - "../../engineering-knowledge-base/data-vault-2.0-guide.md"
  - "./business-vault-patterns.md"
related_business_rules:
  - "../rules/domain-bounded-context-overview.md"
---

# Raw Vault Implementation Patterns

## Analytical Overview 📊
*Audience: Business Analysts, Project Managers, Product Owners (5-7 min read)*

**Purpose**: The Raw Vault implements Data Vault 2.0 methodology in the Integration layer, storing all source data in hub-and-spoke architecture with full historization and auditability. This layer provides the foundation for all downstream data transformations.

**Functional Capabilities**:
- **Business Entity Storage**: Core business entities (members, providers, claims) with unique business keys
- **Relationship Tracking**: Associations between entities with full temporal history
- **Historical Tracking**: All changes to attributes over time with audit trail
- **Source Agnostic Design**: Supports multiple source systems without data conflicts
- **Current State Views**: Business-friendly interfaces showing latest data state

**Business Value**:
- Complete audit trail for compliance and regulatory requirements
- Support for multiple source systems (legacy and current)
- Foundation for consistent business definitions across the platform
- Enables point-in-time analysis and historical reconstruction

---

## Technical Architecture 🔧
*Audience: Data Engineers, Solution Architects, Technical Leads (10-15 min read)*

### Raw Vault Architecture

#### Entity Structure
The Raw Vault is organized into four main categories:

- **`hubs/`** - Business entities with unique business keys
- **`links/`** - Relationships between business entities
- **`sat/`** - Descriptive attributes and historical changes
- **`current_views/`** - Business-friendly interfaces to Raw Vault data

### Naming Conventions

#### Core Entities
- **Hubs**: `h_<entity>` (e.g., `h_member`, `h_provider`, `h_claim`)
- **Links**: `l_<entity1>_<entity2>` (e.g., `l_member_provider`, `l_claim_procedure`)
- **Satellites**: `s_<entity>_<source>` (e.g., `s_member_legacy_facets`, `s_provider_gemstone_facets`)
- **Reference Tables**: `r_<entity>` (e.g., `r_date_spine`)

#### Supporting Objects
- **Staging Rename**: `stg_<entity>_<source>_rename`
- **Data Vault Staging**: `stg_<entity>_<source>`
- **Current Views**: `current_<entity>` (e.g., `current_member`, `current_provider`)

### Source System Integration

#### Source System Codes
- **`legacy_facets`** - Legacy FACETS system (historical data)
- **`gemstone_facets`** - Gemstone FACETS system (current operational)
- **`valenz`** - VALENZ system (additional data source)

#### Business Key Strategy
Based on legacy data dictionary analysis, implement composite business keys for:

- **Members**: Combine member ID with source system to prevent key collisions
  - Example: `member_id || '|' || source_system`
- **Providers**: Use provider NPI where available, fall back to source-specific IDs
  - Example: `provider_npi` OR `provider_id || '|' || source_system`
- **Claims**: Combine claim number with source system for uniqueness
  - Example: `claim_number || '|' || source_system`
- **Procedures**: Use standard procedure codes (CPT, HCPCS) with modifiers
  - Example: `procedure_code || '|' || modifier`

### Standard automate_dv Columns

#### Required Columns
All Data Vault entities must include:

- **`load_datetime`** - Load Date Time Stamp (audit trail)
- **`source`** - Record Source (data lineage)
- **`{entity}_hk`** - Hub Hash Key (unique identifier)
- **`{entity}_hashdiff`** - Hash Difference (change detection for satellites)

### Healthcare Domain Entities

#### Core Member Hub (`h_member`)
**Business Key Strategy**: `member_id || '|' || source_system`

**Key Satellites**:
- `s_member_legacy_facets` - Historical member demographics
- `s_member_gemstone_facets` - Current member information
- `s_member_eligibility` - Coverage and benefit information

**Related Business Rules**: See [Membership Business Rules](../rules/membership/README.md)

#### Core Provider Hub (`h_provider`)
**Business Key Strategy**: `provider_npi` OR `provider_id || '|' || source_system`

**Key Satellites**:
- `s_provider_legacy_facets` - Provider demographics and contracts
- `s_provider_gemstone_facets` - Current provider information
- `s_provider_credentials` - Licensing and certification data

**Related Business Rules**: See [Provider Business Rules](../rules/provider/README.md)

#### Core Claim Hub (`h_claim`)
**Business Key Strategy**: `claim_number || '|' || source_system`

**Key Satellites**:
- `s_claim_header` - Basic claim information
- `s_claim_financial` - Payment and adjustment details
- `s_claim_clinical` - Medical coding and diagnosis

**Related Business Rules**: See [Claims Business Rules](../rules/claims/README.md)

#### Key Links
- **`l_member_provider`** - Member-provider relationships (PCP assignments, referrals)
- **`l_claim_member`** - Claims associated with members
- **`l_claim_provider`** - Claims associated with providers
- **`l_claim_procedure`** - Procedures performed on claims

### Legacy Data Dictionary Integration

#### BPA System Context
The legacy data dictionary reveals Business Process Application (BPA) tables containing:

- **Rule Groups** (`bpa_brgr_rul_grp_r`): Configure business process rules
- **Service Categories** (`bpa_dpsc_svc_cat_a`): Healthcare service classification
- **Data States** (`bpa_dsas_data_state`): Entity lifecycle tracking
- **Conditions** (`bpa_dscr_cond_r`): Business condition definitions

#### Business Key Derivation
Reference `code/repositories/legacy_data_dictionary.csv` for:

- **Primary Keys**: Original table key structures
- **Business Identifiers**: Member IDs, provider IDs, claim numbers
- **Relationship Keys**: Foreign key patterns between entities
- **Effective Dating**: Temporal validity patterns

---

## Implementation Details 💻
*Audience: Data Engineers, Developers (Detailed technical specifications)*

### automate_dv Implementation Patterns

#### Hub Implementation
```sql
-- Example Hub
{{ automate_dv.hub(
    src_pk='member_hk',
    src_nk='member_business_key',
    src_ldts='load_datetime',
    src_source='source',
    source_model='stg_member_legacy_facets'
) }}
```

#### Satellite Implementation
```sql
-- Example Satellite
{{ automate_dv.sat(
    src_pk='member_hk',
    src_hashdiff='member_hashdiff',
    src_payload=['first_name', 'last_name', 'date_of_birth'],
    src_eff='effective_from',
    src_ldts='load_datetime',
    src_source='source',
    source_model='stg_member_legacy_facets'
) }}
```

#### Link Implementation
```sql
-- Example Link
{{ automate_dv.link(
    src_pk='member_provider_hk',
    src_fk=['member_hk', 'provider_hk'],
    src_ldts='load_datetime',
    src_source='source',
    source_model='stg_member_provider_assignment'
) }}
```

### Current Views Implementation

#### Design Principles
- **Single-Source Default**: Each current view shows latest data from one source system
- **No Cross-Source Combination**: Avoid merging conflicting data without explicit business rules
- **Hub-Based**: Join from hub to get all satellite attributes for current state
- **Latest Record**: Filter satellites to most recent `load_datetime` per business key

#### Current View Template
```sql
-- current_member example
select
    h.member_hk,
    h.member_business_key,
    h.load_datetime as hub_load_datetime,
    s.first_name,
    s.last_name,
    s.date_of_birth,
    s.load_datetime as sat_load_datetime
from {{ ref('h_member') }} h
left join {{ ref('s_member_legacy_facets') }} s
    on h.member_hk = s.member_hk
    and s.load_datetime = (
        select max(load_datetime)
        from {{ ref('s_member_legacy_facets') }} s2
        where s2.member_hk = h.member_hk
    )
```

### Incremental Loading Strategy

#### Configuration
- **Load Unit**: Hourly (`hh`)
- **Load Offset**: -24 hours (overlap for late-arriving data)
- **Change Detection**: Use `hashdiff` columns for efficient incremental processing

#### Implementation
```sql
{{ config(
    materialized='incremental',
    incremental_strategy='merge',
    unique_key='member_hk'
) }}
```

### Data Quality and Testing

#### Hub Testing
- Business key uniqueness within load batch
- Hash key consistency and collision detection
- Source system coverage validation

**Example dbt Test**:
```yaml
version: 2

models:
  - name: h_member
    columns:
      - name: member_hk
        tests:
          - unique
          - not_null
      - name: member_business_key
        tests:
          - not_null
```

#### Satellite Testing
- Hash difference change detection accuracy
- Temporal consistency (no future effective dates)
- Referential integrity to parent hubs/links

**Example dbt Test**:
```yaml
models:
  - name: s_member_legacy_facets
    columns:
      - name: member_hk
        tests:
          - relationships:
              to: ref('h_member')
              field: member_hk
      - name: member_hashdiff
        tests:
          - not_null
```

#### Link Testing
- Valid relationships between existing hub entities
- Business rule compliance for relationship types
- Temporal relationship consistency

### Performance Considerations

#### Clustering Strategy
- Hub tables: Cluster on business key columns
- Satellite tables: Cluster on hash key and load_datetime
- Link tables: Cluster on all foreign keys

#### Incremental Processing
- Use appropriate lookback windows (24 hours default)
- Monitor for late-arriving data patterns
- Adjust overlap based on source system SLAs

---

## Reference Files

- **Platform Architecture**: [EDP Platform Architecture](../edp_platform_architecture.md)
- **Layer Architecture**: [EDP Layer Architecture](../edp-layer-architecture-detailed.md)
- **Data Vault Guide**: [Data Vault 2.0 Implementation Guide](../../engineering-knowledge-base/data-vault-2.0-guide.md)
- **Business Vault Patterns**: [Business Vault Implementation Patterns](./business-vault-patterns.md)
- **Legacy Dictionary**: `code/repositories/legacy_data_dictionary.csv`
- **Business Rules**: [Architecture Rules Index](../rules/domain-bounded-context-overview.md)
