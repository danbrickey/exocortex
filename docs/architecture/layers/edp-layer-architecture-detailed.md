---
title: "EDP Layer Architecture - Detailed Specifications"
document_type: "architecture"
business_domain: []  # Cross-domain layer specifications
edp_layer: "cross-layer"
technical_topics: ["data-vault-2.0", "dimensional-modeling", "medallion-architecture", "data-pipelines", "master-data-management"]
audience: ["architects", "engineers"]
status: "active"
last_updated: "2025-10-01"
version: "1.0"
author: "Dan Brickey"
description: "Detailed specifications for Raw, Integration, Curation, Consumption, and Common layers with Data Vault 2.0 and dimensional modeling patterns"
related_docs:
  - "edp_platform_architecture.md"
  - "edp-data-ingestion-architecture.md"
  - "../engineering-knowledge-base/data-vault-2.0-guide.md"
---

# EDP Layer Architecture - Detailed Specifications

## Executive Summary

The EDP platform implements a four-layer medallion architecture with Data Vault 2.0 methodology: Raw Layer (Bronze/immutable audit), Integration Layer (Silver/Raw Vault), Curation Layer (Gold/Business Vault + Dimensional), and Consumption Layer (Information Marts). Each layer serves distinct purposes with clear data ownership, transformation rules, and consumption patterns. A fifth Common Database supports technical metadata and logging across all layers.

## AI Workflow Guidance

**Key Patterns**: Medallion architecture with Data Vault 2.0 at Integration/Curation layers
**Implementation Hints**: Raw = source-centric, Integration = domain-centric Raw Vault, Curation = business-centric transformations
**Validation Points**: Layer separation, naming conventions, transformation logic placement

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    EDP LAYER ARCHITECTURE                       │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Raw Layer          Integration Layer    Curation Layer        │
│  (Bronze)           (Silver)             (Gold)                │
│  ┌──────────┐      ┌──────────────┐     ┌───────────────┐     │
│  │ Source   │──→   │  Raw Vault   │──→  │Business Vault │     │
│  │ Organized│      │  (Hubs/      │     │(PIT, Bridge,  │     │
│  │ CDC Data │      │   Links/     │     │ Calc Fields)  │     │
│  │ Immutable│      │   Satellites)│     ├───────────────┤     │
│  └──────────┘      │              │     │ Dimensional   │     │
│                    │ Domain-      │     │ Models        │     │
│                    │ Organized    │     │ (Kimball)     │     │
│                    │ Light        │     ├───────────────┤     │
│                    │ Cleansing    │     │ Flattened     │     │
│                    │              │     │ ML/Extract    │     │
│                    │ Record ID    │     ├───────────────┤     │
│                    │ Process      │     │ 3NF           │     │
│                    └──────────────┘     │ Operational   │     │
│                                         └───────────────┘     │
│                                                   │            │
│                                                   ↓            │
│                                         ┌───────────────┐     │
│                                         │ Consumption   │     │
│                                         │ Layer         │     │
│                                         │ (Info Marts)  │     │
│                                         │               │     │
│                                         │ Fit-for-      │     │
│                                         │ Purpose       │     │
│                                         │ Custom Logic  │     │
│                                         │ Access Control│     │
│                                         └───────────────┘     │
│                                                                │
│  ┌────────────────────────────────────────────────────────┐   │
│  │         Common Database (Technical Infrastructure)     │   │
│  │         - Logging, Metadata, Utilities                 │   │
│  └────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

---

## Layer 1: Raw Layer (Bronze / Landing)

### Purpose
Immutable audit trail of all source system changes, organized by source system structure.

### Characteristics
- **Organization**: By source system and source database
- **Structure**: Dual-schema pattern per source database (history + transient)
- **Data Quality**: No cleansing, exact replica of source with CDC metadata
- **Mutability**: Append-only, never updated or deleted
- **Retention**: Full historical record (20+ years for some datasets)

### Schema Organization
```
RAW_DB/
├── {source_system}_{database}_history/
│   ├── table1 (permanent, append-only)
│   ├── table2
│   └── tableN
├── {source_system}_{database}_transient/
│   ├── table1 (stream, temporary)
│   ├── table2
│   └── tableN
└── ...
```

### Data Content
**Preserved from Source**:
- All source columns and data types
- Source data values (no transformation)
- Original source system keys

**Added Metadata**:
- CDC operation type (INSERT, UPDATE, DELETE)
- CDC transaction timestamp
- Source file information
- Snowflake load timestamp

### Use Cases
- Source data audit and compliance
- Historical data recovery
- Data lineage foundation
- Debugging data issues at source

### AI Implementation Hints
**Code Pattern**:
```sql
-- History table structure
CREATE TABLE {source}_{db}_history.{table} (
    -- All source columns
    {source_columns},

    -- CDC metadata
    cdc_operation VARCHAR(10),
    cdc_timestamp TIMESTAMP_NTZ,

    -- Load metadata
    load_timestamp TIMESTAMP_NTZ DEFAULT CURRENT_TIMESTAMP(),
    source_file VARCHAR(500)
);
```

**Validation Criteria**:
- [ ] Tables are append-only (no UPDATE/DELETE allowed)
- [ ] CDC metadata present on all tables
- [ ] Schema matches source system exactly
- [ ] Dual-schema pattern implemented per source database

---

## Layer 2: Integration Layer (Silver / Raw Vault)

### Purpose
Enterprise-wide data integration using Data Vault 2.0 Raw Vault methodology, organized by business domain with light cleansing and standardized record identification.

### Characteristics
- **Organization**: By business domain (not source system)
- **Methodology**: Data Vault 2.0 (Hubs, Links, Satellites)
- **Data Quality**: Light cleansing (dangerous characters, unprintable symbols)
- **Integration**: Source-system agnostic business terms
- **Record ID**: Standardized identification across sources
- **Current Views**: Backward compatibility layer for legacy 3NF consumers

### Data Vault 2.0 Artifacts

#### Hubs
**Purpose**: Unique business keys across all source systems

**Structure**:
```sql
CREATE TABLE h_{business_entity} (
    {entity}_hk     BINARY(16),        -- Hash key (surrogate)
    {entity}_bk     VARCHAR(...),      -- Business key (natural)
    record_source   VARCHAR(50),       -- Source system
    load_timestamp  TIMESTAMP_NTZ
);
```

**Examples**:
- `h_member` - Member/Person across all systems
- `h_provider` - Provider across all systems
- `h_claim` - Claim across all systems

**AI Hints**: Hub identifies "who" or "what" - the core business entities

#### Links
**Purpose**: Relationships between business entities

**Structure**:
```sql
CREATE TABLE l_{relationship} (
    {relationship}_hk  BINARY(16),     -- Link hash key
    {entity1}_hk       BINARY(16),     -- FK to Hub 1
    {entity2}_hk       BINARY(16),     -- FK to Hub 2
    record_source      VARCHAR(50),
    load_timestamp     TIMESTAMP_NTZ
);
```

**Examples**:
- `l_member_provider` - Member-Provider relationships
- `l_claim_service` - Claim-Service line relationships
- `l_member_coverage` - Member-Coverage relationships

**AI Hints**: Link captures "how" entities relate, supports many-to-many

#### Satellites
**Purpose**: Descriptive attributes and change history for Hubs and Links

**Structure**:
```sql
CREATE TABLE s_{entity}_{source_system} (
    {entity}_hk        BINARY(16),      -- FK to Hub/Link
    load_timestamp     TIMESTAMP_NTZ,   -- When loaded
    load_end_timestamp TIMESTAMP_NTZ,   -- When superseded (NULL = current)
    record_source      VARCHAR(50),
    hash_diff          BINARY(16),      -- Change detection

    -- All descriptive attributes
    {attribute1},
    {attribute2},
    ...
);
```

**Examples**:
- `s_member_demographics_legacy_facets` - Legacy FACETS member demographics
- `s_member_demographics_gemstone_facets` - Gemstone FACETS member demographics
- `s_provider_credentials_valenz` - VALENZ provider credentials

**AI Hints**:
- One satellite per source system per hub (multi-source pattern)
- Satellites capture "what we know" about entities over time
- Full historization via load_timestamp/load_end_timestamp

### Domain Organization

**Current Domains**:
- Member Domain
- Provider Domain
- Claims Domain
- Coverage/Eligibility Domain
- Financial Domain

**Schema Structure**:
```
INTEGRATION_DB/
├── member/
│   ├── h_member
│   ├── s_member_demographics_{source}
│   ├── s_member_address_{source}
│   └── ...
├── provider/
│   ├── h_provider
│   ├── s_provider_demographics_{source}
│   └── ...
└── claims/
    ├── h_claim
    ├── l_claim_member
    ├── s_claim_header_{source}
    └── ...
```

### Light Cleansing Rules
**Scope**: Limited to technical cleansing only
- Remove dangerous/unprintable characters
- Standardize encoding (UTF-8)
- Strip control characters
- **NOT**: Business rule validation or data correction

### Record Identification Process
**Purpose**: Create standardized enterprise IDs across source systems

**Current Capabilities**:
- **Member/Person Matching**: Rudimentary algorithm, creates cross-system Person ID
- **Provider Matching**: Cross-system Provider ID crosswalks

**Implementation in Data Vault**:
- Composite business keys where needed
- Multiple satellites per source for conflicting data
- Bridge tables for uncertain relationships
- Effectivity satellites for temporal identity

### Current Views (Backward Compatibility)
**Purpose**: Support existing 3NF consumers during migration

**Pattern**:
```sql
CREATE VIEW current_{entity} AS
SELECT
    hub.{entity}_bk,
    sat.attribute1,
    sat.attribute2,
    ...
FROM h_{entity} hub
JOIN s_{entity}_latest sat
    ON hub.{entity}_hk = sat.{entity}_hk
WHERE sat.load_end_timestamp IS NULL;  -- Current records only
```

**Strategy**: Maintain business continuity while refactoring from 3NF to Data Vault

### AI Implementation Hints

**Code Templates**:
```yaml
# dbt model using automate_dv package
{{
  config(
    materialized='incremental'
  )
}}

{%- set source_model = "stg_member_demographics" -%}
{%- set src_pk = "member_hk" -%}
{%- set src_nk = "member_id" -%}
{%- set src_ldts = "load_timestamp" -%}
{%- set src_source = "record_source" -%}

{{ automate_dv.hub(
    src_pk=src_pk,
    src_nk=src_nk,
    src_ldts=src_ldts,
    src_source=src_source,
    source_model=source_model
) }}
```

**Validation Criteria**:
- [ ] All hubs have business keys from multiple sources
- [ ] Links connect related hubs correctly
- [ ] Satellites maintain full change history
- [ ] Multi-source pattern: one satellite per source system
- [ ] Current views provide 3NF-style access for backward compatibility

---

## Layer 3: Curation Layer (Gold / Business Vault + Dimensional)

### Purpose
Fit-for-you data organized by domain or business process, with enterprise business rules applied. Supports multiple consumption patterns: dimensional, flattened, 3NF operational.

### Characteristics
- **Organization**: By business domain or major business process
- **Methodology**: Data Vault Business Vault + Kimball Dimensional + 3NF operational
- **Data Quality**: Full business rule application and validation
- **Audience**: Analytics, ML, operational applications
- **Flexibility**: Multiple modeling approaches for different use cases

### Data Vault Business Vault Artifacts

#### Point-in-Time (PIT) Tables
**Purpose**: Pre-joined snapshots for efficient temporal queries

**Structure**:
```sql
CREATE TABLE pit_{entity}_daily (
    {entity}_hk             BINARY(16),
    snapshot_date           DATE,
    s_demographics_ldts     TIMESTAMP_NTZ,
    s_address_ldts          TIMESTAMP_NTZ,
    s_coverage_ldts         TIMESTAMP_NTZ,
    ...
);
```

**Use Case**: Simplify "as-of" queries across multiple satellites

#### Bridge Tables
**Purpose**: Resolve complex many-to-many relationships

**Structure**:
```sql
CREATE TABLE bridge_{relationship} (
    bridge_hk          BINARY(16),
    {entity1}_hk       BINARY(16),
    {entity2}_hk       BINARY(16),
    relationship_type  VARCHAR(50),
    effective_from     DATE,
    effective_to       DATE,
    weight             DECIMAL(5,4)  -- For relationship strength
);
```

**Use Case**: Provider-to-provider relationships, uncertain mappings

#### Calculated Fields and Business Rules
**Purpose**: Apply enterprise business logic

**Examples**:
- Member age calculations
- Claim payment amounts
- Coverage periods
- Risk scores
- Eligibility flags

**Pattern**: Implemented as satellites on business vault hubs/links

### Kimball Dimensional Models

#### Star Schema Components

**Fact Tables**:
```sql
CREATE TABLE fact_claims (
    claim_key              INTEGER,
    member_key             INTEGER,
    provider_key           INTEGER,
    service_date_key       INTEGER,
    paid_date_key          INTEGER,

    -- Degenerate dimensions
    claim_number           VARCHAR(50),
    claim_line_number      INTEGER,

    -- Measures
    billed_amount          DECIMAL(18,2),
    allowed_amount         DECIMAL(18,2),
    paid_amount            DECIMAL(18,2),
    member_responsibility  DECIMAL(18,2),

    -- Audit
    load_timestamp         TIMESTAMP_NTZ
);
```

**Dimension Tables**:
```sql
CREATE TABLE dim_member (
    member_key             INTEGER,  -- Surrogate key
    member_id              VARCHAR(50),  -- Business key

    -- Type 2 SCD attributes
    first_name             VARCHAR(100),
    last_name              VARCHAR(100),
    birth_date             DATE,
    gender                 VARCHAR(10),

    -- Type 2 SCD metadata
    effective_from_date    DATE,
    effective_to_date      DATE,
    current_flag           BOOLEAN,

    -- Audit
    load_timestamp         TIMESTAMP_NTZ
);
```

**SCD Patterns**:
- **Type 1**: Overwrite (no history needed)
- **Type 2**: Full history with effective dates (most common)
- **Type 3**: Limited history (previous + current value)

#### Conformed Dimensions
**Purpose**: Shared dimensions across multiple fact tables

**Examples**:
- `dim_date` - Shared across all facts
- `dim_provider` - Shared across claims, payments, network facts
- `dim_member` - Shared across claims, eligibility, financial facts

**Benefit**: Consistent cross-subject analysis

### Flattened Datasets for ML and Extracts

**Purpose**: Denormalized, wide-format tables for data science and external systems

**Structure**:
```sql
CREATE TABLE ml_member_risk_features (
    member_id              VARCHAR(50),
    snapshot_date          DATE,

    -- Demographic features
    age                    INTEGER,
    gender                 VARCHAR(10),
    geographic_region      VARCHAR(50),

    -- Historical features
    total_claims_12mo      INTEGER,
    total_paid_12mo        DECIMAL(18,2),
    chronic_conditions     ARRAY,

    -- Calculated features
    risk_score             DECIMAL(10,4),
    predicted_cost         DECIMAL(18,2),

    -- Audit
    load_timestamp         TIMESTAMP_NTZ
);
```

**Use Cases**:
- Machine learning model training
- Data science experimentation
- Third-party data feeds
- Regulatory reporting extracts

### 3NF Operational Models

**Purpose**: Normalized structures for operational applications and portals

**Structure**: Traditional 3NF with primary/foreign keys

**Use Cases**:
- Provider portal data access
- Member portal queries
- Customer service applications
- Real-time operational reporting

**Example**:
```sql
-- 3NF for operational provider portal
CREATE TABLE op_provider (
    provider_id       VARCHAR(50) PRIMARY KEY,
    npi               VARCHAR(10),
    tax_id            VARCHAR(20),
    provider_name     VARCHAR(200),
    ...
);

CREATE TABLE op_provider_location (
    location_id       INTEGER PRIMARY KEY,
    provider_id       VARCHAR(50) REFERENCES op_provider,
    address_line1     VARCHAR(100),
    city              VARCHAR(50),
    ...
);
```

### Schema Organization

```
CURATION_DB/
├── business_vault/
│   ├── pit_member_daily
│   ├── pit_provider_daily
│   ├── bridge_provider_network
│   └── ...
├── dimensional/
│   ├── fact_claims
│   ├── fact_premium
│   ├── dim_member
│   ├── dim_provider
│   ├── dim_date
│   └── ...
├── ml_datasets/
│   ├── ml_member_risk_features
│   ├── ml_claims_prediction_features
│   └── ...
└── operational/
    ├── op_provider_*
    ├── op_member_*
    └── ...
```

### AI Implementation Hints

**Business Vault Patterns**:
```sql
-- PIT table generation (dbt macro)
{{ automate_dv.pit(
    source_model=ref('hub_member'),
    satellites=['s_member_demographics', 's_member_address'],
    snapshot_relation='snapshot_dates'
) }}
```

**Dimensional Model Patterns**:
```sql
-- Type 2 SCD dimension (dbt snapshot)
{% snapshot dim_member_snapshot %}
{{
    config(
      target_schema='dimensional',
      unique_key='member_id',
      strategy='check',
      check_cols=['first_name', 'last_name', 'birth_date']
    )
}}
SELECT * FROM {{ ref('stg_member') }}
{% endsnapshot %}
```

**Validation Criteria**:
- [ ] Business rules documented and implemented
- [ ] PIT tables for complex entities (>3 satellites)
- [ ] Dimensional models follow Kimball methodology
- [ ] Conformed dimensions shared across facts
- [ ] ML datasets properly denormalized
- [ ] Operational 3NF models have proper constraints

---

## Layer 4: Consumption Layer (Information Marts)

### Purpose
Fit-for-purpose data exposed to specific user groups with appropriate access controls and custom transformations for specialized use cases.

### Characteristics
- **Organization**: By business purpose or external party
- **Data Source**: Selections from Curation Layer
- **Customization**: Non-enterprise business logic allowed
- **Security**: Row-level and column-level access controls
- **Audience**: Specific stakeholder groups, external parties, specialized applications

### Use Case Categories

#### 1. Regulatory and Compliance Extracts

**CMS Audit Information**:
```sql
CREATE TABLE cms_audit_claims_extract (
    -- CMS-required format
    member_hicn           VARCHAR(50),
    service_date          DATE,
    diagnosis_codes       ARRAY,
    procedure_codes       ARRAY,
    -- ... CMS-specific fields
);
```

**Characteristics**:
- Exact format required by regulatory body
- Scheduled extraction (monthly/quarterly)
- Audit trail of submissions
- Compliance validation rules

#### 2. External Party Data Feeds

**Edge Server (QHP Line of Business)**:
- Custom transformation logic specific to Edge requirements
- Proprietary format and calculations
- Regular scheduled transmission

**BCBS National Data Warehouse**:
```sql
CREATE TABLE bcbs_national_dw_feed (
    -- Monthly feed of claims, membership, provider
    feed_month           DATE,
    member_data          VARIANT,
    claims_data          VARIANT,
    provider_data        VARIANT,
    -- BCBS-specific formatting
);
```

**Characteristics**:
- Transformation to third-party specifications
- Quality validation before transmission
- Transmission tracking and reconciliation

#### 3. Stakeholder-Specific Views

**Healthcare Economics Department**:
```sql
CREATE TABLE he_analytics_dataset (
    -- Pre-aggregated for analytics team
    analysis_month       DATE,
    member_segment       VARCHAR(50),
    -- Calculated metrics
    member_months        INTEGER,
    pmpm_claims          DECIMAL(18,2),
    trend_factor         DECIMAL(10,4),
    -- Access limited to HE team
);
```

**Provider Team (Provider 360)**:
```sql
CREATE VIEW provider_360_comprehensive AS
SELECT
    -- Denormalized provider view
    p.provider_id,
    p.provider_name,
    -- Performance metrics
    perf.quality_score,
    perf.cost_efficiency,
    -- Network participation
    net.contracts,
    net.locations,
    -- Historical trends
    ...
FROM curation_db.dimensional.dim_provider p
JOIN ...
-- Row-level security: users see only their assigned providers
```

#### 4. Data Science Experimentation

**Purpose**: Sandbox for hypothesis testing and model development

**Characteristics**:
- Temporary tables and views
- Exploratory calculations
- Feature engineering experiments
- Model training datasets
- Prediction outputs

**Example**:
```sql
CREATE TABLE ds_experiment_member_churn (
    experiment_id        VARCHAR(50),
    created_by           VARCHAR(100),
    created_date         DATE,

    -- Experimental features
    feature_set          VARIANT,

    -- Model outputs
    churn_probability    DECIMAL(10,4),
    model_version        VARCHAR(20),

    -- Lifecycle
    status               VARCHAR(20)  -- draft, validated, archived
);
```

### Security and Access Control

#### Row-Level Security
```sql
CREATE ROW ACCESS POLICY rap_provider_team
AS (provider_id VARCHAR) RETURNS BOOLEAN ->
    EXISTS (
        SELECT 1 FROM user_provider_assignments
        WHERE user_name = CURRENT_USER()
          AND provider_id = provider_id
    );

ALTER TABLE provider_360_comprehensive
    ADD ROW ACCESS POLICY rap_provider_team ON (provider_id);
```

#### Column Masking
```sql
CREATE MASKING POLICY mask_member_ssn
AS (val VARCHAR) RETURNS VARCHAR ->
    CASE
        WHEN CURRENT_ROLE() IN ('ADMIN', 'COMPLIANCE') THEN val
        ELSE '***-**-' || RIGHT(val, 4)
    END;

ALTER TABLE member_details
    MODIFY COLUMN ssn SET MASKING POLICY mask_member_ssn;
```

### Schema Organization

```
CONSUMPTION_DB/
├── regulatory/
│   ├── cms_audit_*
│   ├── state_reporting_*
│   └── ...
├── external_feeds/
│   ├── edge_server_*
│   ├── bcbs_national_dw_*
│   └── ...
├── stakeholder_views/
│   ├── he_analytics_*
│   ├── provider_360_*
│   └── ...
└── data_science/
    ├── ds_experiment_*
    ├── ds_model_output_*
    └── ...
```

### AI Implementation Hints

**Template for External Feed**:
```sql
-- Consumption layer view for external feed
CREATE OR REPLACE VIEW {external_party}_feed AS
SELECT
    -- Custom transformations for external party
    {custom_field_mappings}
FROM {{ ref('curated_entity') }}
WHERE {external_party_filter_criteria}
  AND {data_quality_validations};
```

**Validation Criteria**:
- [ ] Row-level security policies applied where appropriate
- [ ] Column masking for PII/PHI fields
- [ ] Custom transformations documented
- [ ] Data quality validations before external transmission
- [ ] Access limited to specific user groups/roles
- [ ] Audit trail of data access and extracts

---

## Layer 5: Common Database (Technical Infrastructure)

### Purpose
Cross-layer technical metadata, logging, and functional infrastructure to support platform operations.

### Characteristics
- **Organization**: By technical function
- **Audience**: Platform administrators, data engineers
- **Scope**: Non-business data (technical only)
- **Lifespan**: Varies by function (logs vs. persistent config)

### Schema Categories

#### 1. Logging and Audit
```sql
CREATE SCHEMA logging;

CREATE TABLE logging.dbt_run_log (
    run_id              VARCHAR(50),
    job_name            VARCHAR(200),
    start_timestamp     TIMESTAMP_NTZ,
    end_timestamp       TIMESTAMP_NTZ,
    status              VARCHAR(20),
    rows_affected       INTEGER,
    error_message       TEXT
);

CREATE TABLE logging.data_quality_results (
    test_id             VARCHAR(50),
    test_name           VARCHAR(200),
    table_name          VARCHAR(200),
    test_timestamp      TIMESTAMP_NTZ,
    test_result         VARCHAR(20),
    failure_count       INTEGER,
    failure_details     VARIANT
);
```

#### 2. Metadata and Configuration
```sql
CREATE SCHEMA metadata;

CREATE TABLE metadata.source_system_registry (
    source_system_code  VARCHAR(50) PRIMARY KEY,
    source_system_name  VARCHAR(200),
    hcdm_code           VARCHAR(50),
    tenant_id           VARCHAR(50),
    active_flag         BOOLEAN,
    created_date        DATE,
    modified_date       DATE
);

CREATE TABLE metadata.data_lineage (
    lineage_id          VARCHAR(50),
    source_object       VARCHAR(500),
    target_object       VARCHAR(500),
    transformation_type VARCHAR(100),
    dbt_model_name      VARCHAR(200),
    last_updated        TIMESTAMP_NTZ
);
```

#### 3. Utilities and Helper Functions
```sql
CREATE SCHEMA utilities;

CREATE TABLE utilities.date_dimension (
    date_key            INTEGER PRIMARY KEY,
    full_date           DATE,
    day_of_week         INTEGER,
    day_name            VARCHAR(20),
    month_name          VARCHAR(20),
    quarter             INTEGER,
    fiscal_year         INTEGER,
    is_holiday          BOOLEAN,
    holiday_name        VARCHAR(100)
);

CREATE TABLE utilities.record_id_mappings (
    source_system       VARCHAR(50),
    source_id           VARCHAR(200),
    enterprise_id       VARCHAR(200),
    entity_type         VARCHAR(50),
    confidence_score    DECIMAL(5,4),
    created_timestamp   TIMESTAMP_NTZ
);
```

#### 4. Process Control
```sql
CREATE SCHEMA process_control;

CREATE TABLE process_control.batch_control (
    batch_id            VARCHAR(50) PRIMARY KEY,
    process_name        VARCHAR(200),
    source_system       VARCHAR(50),
    load_date           DATE,
    start_timestamp     TIMESTAMP_NTZ,
    end_timestamp       TIMESTAMP_NTZ,
    status              VARCHAR(20),
    records_processed   INTEGER
);
```

### Schema Organization

```
COMMON_DB/
├── logging/
│   ├── dbt_run_log
│   ├── data_quality_results
│   ├── snowpipe_load_history
│   └── ...
├── metadata/
│   ├── source_system_registry
│   ├── data_lineage
│   ├── table_catalog
│   └── ...
├── utilities/
│   ├── date_dimension
│   ├── record_id_mappings
│   ├── reference_data
│   └── ...
└── process_control/
    ├── batch_control
    ├── task_schedule
    └── ...
```

### AI Implementation Hints

**Logging Integration in dbt**:
```sql
-- Post-hook to log dbt model execution
{{ config(
    post_hook=[
        "INSERT INTO {{ var('common_db') }}.logging.dbt_run_log
         SELECT '{{ invocation_id }}', '{{ this }}',
                {{ dbt_utils.current_timestamp() }},
                'SUCCESS', {{ sql_row_count }}"
    ]
) }}
```

**Validation Criteria**:
- [ ] Logging tables capture all critical processes
- [ ] Metadata registry maintained for all source systems
- [ ] Data lineage tracked for compliance
- [ ] Utility tables available to all layers
- [ ] Process control enables monitoring and alerting

---

## Cross-Layer Principles

### 1. Data Flow Direction
**Rule**: Data flows left-to-right (Raw → Integration → Curation → Consumption)

**Never**:
- Read from higher layer in lower layer (e.g., Integration reading from Curation)
- Skip layers (e.g., Raw directly to Consumption)

### 2. Transformation Placement
**Raw Layer**: No transformation, CDC metadata only
**Integration Layer**: Light cleansing, domain organization, record ID
**Curation Layer**: Business rules, dimensional modeling, denormalization
**Consumption Layer**: Custom/non-enterprise transformations, access control

### 3. Naming Conventions

**Prefixes by Artifact Type**:
- `h_` - Hub
- `l_` - Link
- `s_` - Satellite
- `pit_` - Point-in-Time
- `bridge_` - Bridge table
- `fact_` - Fact table
- `dim_` - Dimension table
- `ml_` - Machine learning dataset
- `op_` - Operational 3NF
- `current_` - Current view (backward compatibility)

**Suffixes**:
- `_history` - Raw layer historical table
- `_transient` - Raw layer stream
- `_{source_system}` - Satellite source system identifier
- `_daily` / `_monthly` - PIT table grain

### 4. Data Quality by Layer
**Raw**: Schema validation only
**Integration**: Technical data quality (format, type, key uniqueness)
**Curation**: Business rule validation and data quality
**Consumption**: Use-case specific validation

### 5. Security by Layer
**Raw**: Restricted to platform administrators
**Integration**: Data engineers and architects
**Curation**: Analysts and data scientists (domain-based)
**Consumption**: End users (role-based, row/column security)

---

## Evaluation Criteria

### Architecture Compliance
- [ ] All layers implemented with correct purpose and scope
- [ ] Data flows unidirectionally (no upstream reads)
- [ ] Transformations placed in appropriate layer
- [ ] Naming conventions followed consistently
- [ ] Common database used for technical infrastructure

### Data Vault Implementation (Integration Layer)
- [ ] Hubs for all major business entities
- [ ] Links for all entity relationships
- [ ] Multi-source satellite pattern (one per source system)
- [ ] Full historization maintained
- [ ] Current views for backward compatibility

### Dimensional Modeling (Curation Layer)
- [ ] Star schema with proper fact/dimension separation
- [ ] Conformed dimensions across fact tables
- [ ] SCD Type 2 for changing dimensions
- [ ] Grain clearly defined for all facts

### Access Control (Consumption Layer)
- [ ] Row-level security where appropriate
- [ ] Column masking for PII/PHI
- [ ] Role-based access control
- [ ] Audit logging of sensitive data access

---

**Document Version**: 1.0
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
