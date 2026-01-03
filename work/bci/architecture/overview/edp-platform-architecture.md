---
title: "Enterprise Data Platform (EDP) Data Domain Architecture Context"
document_type: "architecture"
business_domain: []  # Cross-domain platform architecture
edp_layer: "cross-layer"
technical_topics: ["data-vault-2.0", "dimensional-modeling", "snowflake", "dbt", "aws", "medallion-architecture"]
audience: ["executives", "architects", "engineers", "analysts"]
status: "active"
last_updated: "2025-10-01"
version: "1.1"
author: "Dan Brickey"
description: "High-level EDP platform architecture, AWS + Snowflake integration, medallion architecture with Data Vault 2.0"
related_docs:
  - "edp-data-ingestion-architecture.md"
  - "edp-layer-architecture-detailed.md"
  - "../engineering-knowledge-base/environment-database-configuration.md"
  - "../engineering-knowledge-base/data-vault-2.0-guide.md"
---

# Enterprise Data Platform (EDP) Data Domain Architecture Context

## Overview

This document describes the architecture, tools, environments, and conventions for the Enterprise Data Platform (EDP) Data Domain project, designed for Data Vault 2.0 implementation using dbt and Snowflake. The EDP vision is to make it a hub for all the enterprise data needs. Both analytical and operational use cases that do not need to run directly in the source systems will be served here, and as the EDP is built out, the existing on prem services and processes will move to the EDP when dependencies are in place.

### Related Documentation
For detailed information, see:
- [EDP Data Ingestion Architecture](edp-data-ingestion-architecture.md) - CDC, streaming, batch ingestion patterns
- [EDP Layer Architecture Detailed](edp-layer-architecture-detailed.md) - Comprehensive layer specifications
- [Environment and Database Configuration](../engineering-knowledge-base/environment-database-configuration.md) - Environment setup and data flow

## Platform Architecture

### Core Infrastructure

- **Cloud Platform**: `AWS`
- **Data Warehouse**: `Snowflake`
- **Data Architecture**: `Data Vault 2.0` (transitioning from 3NF)
- **Transformation Tool**: `dbt Platform` (formerly dbt Cloud)
- **Data Vault Package**: `automate_dv` (datavault4dbt)
- **Visualization Tool**: `Tableau Cloud`
- **Data Quality Tool**: `Anomalo`
- **Data Governance and Catalog Tool**: `Alation`

### Data Layer Architecture

```
Raw Layer → Integration Layer → Curation Layer → Consumption Layer
```

#### Layer Descriptions

- **Raw Layer** (Bronze equivalent): Immutable audit trail of source system changes
  - Raw CDC (Change Data Capture) data from source systems
  - Snowflake shares and ingested files
  - Dual-schema pattern per source database: `{source}_{db}_history` (permanent) and `{source}_{db}_transient` (streams)
  - Organized by source system (not domain)
  - No transformation or cleansing applied
  - See: [EDP Data Ingestion Architecture](edp-data-ingestion-architecture.md) for ingestion details

- **Integration Layer** (Silver equivalent): Data Vault 2.0 Raw Vault
  - Organized by business domain (not source system)
  - Hubs, Links, and Satellites following Data Vault 2.0 methodology
  - Light cleansing: dangerous characters, encoding standardization
  - Record identification keys for cross-source uniqueness
  - Multi-source satellite pattern (one satellite per source system)
  - Current Views for backward compatibility with legacy 3NF consumers
  - Refactoring in progress from existing 3NF implementation
  - See: [EDP Layer Architecture](edp-layer-architecture-detailed.md#layer-2-integration-layer-silver--raw-vault) for details

- **Curation Layer** (Gold equivalent): Business Vault + Dimensional + Operational
  - Business Vault: PIT tables, bridge tables, calculated fields, business rules
  - Dimensional Models: Kimball star schemas for analytics (facts, dimensions, conformed dimensions)
  - Flattened datasets for ML models and data science
  - 3NF operational models for portal/application use cases
  - Enterprise business rule application
  - See: [EDP Layer Architecture](edp-layer-architecture-detailed.md#layer-3-curation-layer-gold--business-vault--dimensional) for details

- **Consumption Layer**: Information Marts
  - Fit-for-purpose data for specific stakeholder groups
  - Custom/non-enterprise transformations allowed
  - Regulatory extracts (CMS, EDGE Server, BCBS National DW)
  - Row-level and column-level access controls
  - Data science experimentation sandboxes
  - See: [EDP Layer Architecture](edp-layer-architecture-detailed.md#layer-4-consumption-layer-information-marts) for details

- **Common Database**: Technical infrastructure across all layers
  - Logging and audit tables
  - Metadata and configuration
  - Utilities and helper functions
  - Process control and monitoring
  - See: [EDP Layer Architecture](edp-layer-architecture-detailed.md#layer-5-common-database-technical-infrastructure) for details

## Data Vault Naming Conventions

### Entity Prefixes and Suffixes

#### Raw Vault (Integration Layer) Naming Conventions

- **Staging Rename Tables**: `stg_<entity>_<source>_rename` (e.g. `stg_product_gemstone_facets_rename`)
- **Data Vault Staging Tables**: `stg_<entity>_<source>` (e.g. `stg_product_gemstone_facets`)
- **Hubs**: `h_<entity>` (e.g. `h_product`)
- **Links**: `l_<entity1>_<entity2>` (e.g. `l_class_group`)
- **Satellites**: `s_<entity>_<source>` (e.g. `s_product_gemstone_facets`)
- **Reference Tables**: `r__<entity>` (e.g. `r_date_spine`)
- **Current Views**: `current_<entity>`

#### Business Vault (Curation Layer) Naming Conventions

- **Business Vault Hubs**: `bv_h_<entity>_<purpose>`
- **Bridge Tables**: `bridge_<entity>_<purpose>`
- **Point-In-Time (PIT) Tables**: `pit_<entity>_<purpose>`
- **Business Vault Satellites - Calculations**: `bv_s_<entity>_calculations`
- **Business Vault Satellites - Business Rules**: `bv_s_<entity>_business_rules`
- **Business Vault Satellites - Mixed Logic**: `bv_s_<entity>_business`
- **Business Vault Reference Tables**: `bv_r_<entity>`

- **When splitting data by rate of change**: `*_hroc`, `*_mroc`, `*_lroc` (for high, medium, and low rates of change respectively)

#### Information Mart (Consumption Layer)

- **Dimensions**: `dim_<entity>` (e.g. `dim_product`)
- **Fact Tables**: `fact_<entity> (e.g. `fact_member_coverage`)
- **Bridge Tables**: `bridge_<entity>_<purpose>` (e.g. `bridge_medical_claim_procedure`)

### Source System Suffixes

Use full source_system value as suffix:

- `legacy_facets` - Legacy FACETS system
- `gemstone_facets` - Gemstone FACETS system
- `valenz` - VALENZ system

## Source Systems

### Primary Systems

1. **Legacy FACETS** (`legacy_facets`)
   - HCDM Code: `FACETS_LGC`
   - Tenant ID: `BCI`

2. **Gemstone FACETS** (`gemstone_facets`)
   - HCDM Code: `FACETS_GMS`
   - Tenant ID: `BCI`

3. **VALENZ** (`valenz`)
   - System Code: `VALENZ`

## Data Vault Configuration Standards

### Standard automate_dv Columns

- **Load Date**: `load_datetime` - Load Date Time Stamp
- **Record Source**: `source` - Record Source
- **Hash Key**: `{entity}_hk` - Hub hash key (e.g. member_hk, member_provider_hk)
- **Hash Diff**: `{entity}_hashdiff` - Hash Difference for change detection (e.g. subscriber_hashdiff)

### Business Key Handling

- Support for simple and composite business keys
- Derived business key expressions using SQL functions
- Proper hashing using automate_dv macros

### Satellite Types Supported

- **Standard Satellites**: Basic attribute storage
- **Effectivity Satellites**: Time-based effective periods
- **Multi-Active Satellites**: Multiple active records per business key

### Current View Requirements

- Include all satellite columns
- Handle column name mapping and data type consistency
- Implement conflict resolution for overlapping columns
- **Default Behavior**: Use same key as hub/link including source_system
- Filter to most recent business key record from satellite for each source
- **Do not combine records from multiple sources** unless explicitly specified
- Base on hub or link table
- LEFT JOIN to satellites for current records only
- Handle null values and missing data appropriately

## Configuration Variables

### Incremental Loading

- **Load Unit**: `hh` (hourly)
- **Load Offset**: `-1` hours (overlap for late-arriving data)

### Documentation Requirements

- Relation-level documentation enabled
- Column-level documentation enabled
- Persist documentation in curation and consumption layers

---

## Environments and Databases

The EDP platform maintains three primary environments with a unique data-down/code-up flow:

### Environment Structure

| Environment | Purpose | Data Source | Code Source |
|-------------|---------|-------------|-------------|
| **prod** | Production | Live sources | Deployed from test |
| **test** (preprod) | Pre-production | Cloned from prod | Promoted from dev |
| **dev** | Development | Cloned from prod | Active development |

### Database Pattern per Environment

Each environment contains five databases:

| Layer | Dev | Team Dev | Test (Preprod) | Prod |
|-------|-----|----------|----------------|------|
| Raw | `{user}_schema` | `dev_raw_db` | `preprod_raw_db` | `prod_raw_db` |
| Integration | `{user}_schema` | `dev_int_db` | `preprod_int_db` | `prod_int_db` |
| Curation | `{user}_schema` | `dev_cur_db` | `preprod_cur_db` | `prod_cur_db` |
| Consumption | `{user}_schema` | `dev_con_db` | `preprod_con_db` | `prod_con_db` |
| Common | `{user}_schema` | `dev_common_db` | `preprod_common_db` | `prod_common_db` |

### Special Databases

- **`dev_dbt_transform_db`**: Individual developer schemas for isolated dbt development
- **`dev_raw_db`**: Ingestion team development (separate from `dev_raw_clone_db`)
- **`dev_raw_clone_db`**: Zero-copy clone of prod raw for dbt development
- **`snowflake_admin_db`**: Platform administration
- **`data_governance_db`**: Security policies and data governance

### Data and Code Flow

**Data flows downward**: `prod → test → dev` (via zero-copy cloning)
**Code flows upward**: `dev → test → prod` (via GitLab promotion)

See: [Environment and Database Configuration](../engineering-knowledge-base/environment-database-configuration.md) for complete details

---

## AI Leverage Opportunities

The EDP platform has identified three major use cases for AI assistance:

### UC01: 3NF to Data Vault Refactoring
Refactoring existing 3NF data models in the Integration Layer to Data Vault 2.0 structures.
**Status**: Active development
**Documentation**: [Use Case 01](../use_cases/uc01_dv_refactor/)

### UC02: EDW Stored Procedure Translation
Translating on-premises WhereScape SQL Server stored procedures to dbt pipelines, including business rule documentation and Business Vault creation.
**Status**: Planned
**Documentation**: [Use Case 02](../use_cases/uc02_edw2_refactor/)

### UC03: AI-Assisted Data Vault Code Generation
Generating Data Vault 2.0 dbt starter code from design specifications (diagrams or YAML).
**Status**: Planned
**Documentation**: [Use Case 03](../use_cases/uc03_ai_dv_code_generation/)

---

## Usage Notes for Other Projects

When referencing this architecture in other chats or projects:

1. **Data Vault Implementation**: Follow automate_dv package conventions
2. **Naming**: Always use the specified prefixes and source system suffixes
3. **Current Views**: Default to single-source views unless multi-source is explicitly required
4. **Environment Handling**: Use the database naming patterns for proper environment separation
5. **Schema Organization**: Follow the established domain-based schema structure
6. **Testing**: Apply appropriate test severity based on environment type
7. **Layer Separation**: Respect layer boundaries - no upstream reads, transformations in appropriate layers
8. **Ingestion Patterns**: Use dual-schema pattern (history + transient) for all raw layer sources

This architecture is intended to support a scalable, auditable data platform with clear lineage for the transition from 3NF to Data Vault 2.0.

---

**Document Version**: 1.1
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
