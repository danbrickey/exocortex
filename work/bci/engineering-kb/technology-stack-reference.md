---
title: "EDP Technology Stack and Tooling Reference"
document_type: "reference"
ai_workflow_tags: ["technology-stack", "dbt-packages", "tools", "versions", "cicd"]
code_evaluation_scope: "platform-tooling"
business_context: "Complete technology stack inventory and configuration"
technical_audience: "developers|data-engineers|architects"
last_updated: "2025-10-01"
related_components: ["dbt", "snowflake", "gitlab", "aws", "testing", "quality"]
---

# EDP Technology Stack and Tooling Reference

## Executive Summary

The EDP platform leverages a modern cloud-native data stack centered on Snowflake, dbt, and AWS. The stack emphasizes latest-version adoption, GitLab-based CI/CD, and a rich ecosystem of dbt packages for testing, code generation, and data quality. Key tools include automate_dv for Data Vault, dbt-expectations for testing, and various AWS services for ingestion and orchestration.

## AI Workflow Guidance

**Key Patterns**: Latest version strategy, package-based extensibility, GitLab CI/CD
**Implementation Hints**: Reference dbt package versions, AWS service integration patterns
**Validation Points**: Package compatibility, version constraints, tool configurations

---

## Core Platform Components

### Data Warehouse: Snowflake

**Version**: Enterprise Edition
**Update Strategy**: Snowflake-managed (automatic patches)
**Account Region**: AWS US-based region

**Key Features Utilized**:
- Streams (for CDC and near-real-time processing)
- Dynamic Tables (for near-real-time transformations)
- Tasks (for batch job scheduling)
- Zero-copy cloning (for environment data replication)
- Time Travel (for data recovery and auditing)
- Row Access Policies (for security)
- Column Masking Policies (for PII/PHI protection)
- Tag-based governance (for classification propagation)

**Snowflake-Specific Configuration**:
```sql
-- Tag propagation enabled
ALTER ACCOUNT SET TAG_PROPAGATION = TRUE;

-- Extended time travel for compliance
ALTER DATABASE prod_raw_db SET DATA_RETENTION_TIME_IN_DAYS = 90;

-- Resource monitors for cost control
CREATE RESOURCE MONITOR daily_budget
  WITH CREDIT_QUOTA = {quota}
  TRIGGERS
    ON 80 PERCENT DO NOTIFY
    ON 90 PERCENT DO NOTIFY
    ON 100 PERCENT DO SUSPEND;
```

### Transformation: dbt Platform (formerly dbt Cloud)

**Version Strategy**: Always latest
**Update Cadence**: Automatic adoption of new releases
**Hosting**: dbt Cloud (managed service)

**Version Management**:
```yaml
# dbt_project.yml
require-dbt-version: ">=1.5.0"  # Minimum, but always run latest in practice
```

**dbt Platform Features Used**:
- Jobs and scheduling
- Development IDE
- CI/CD jobs (Slim CI)
- Documentation hosting
- Lineage graphs
- Metadata API

**Scheduler Strategy** (In Transition):
- **Current**: dbt Platform native scheduler
- **Under Consideration**: Migration to GitLab CI/CD for consistency
- **Future Possibility**: Apache Airflow on AWS

### Version Control and CI/CD: GitLab

**Hosting**:
- **Current**: GitLab.com (SaaS)
- **Future**: Possible migration to self-hosted for privacy/AI concerns

**Repository Structure**:
```
edp-dbt-project/
├── .gitlab-ci.yml
├── dbt_project.yml
├── models/
│   ├── staging/
│   ├── integration/
│   ├── curation/
│   └── consumption/
├── tests/
├── macros/
└── packages.yml
```

**Protected Branches**:
- `develop` (main development branch)
- `test` (pre-production)
- `prod` (production)
- `uat` (user acceptance testing - planned)

**Branch Protection Rules**:
- Merge requests required for all protected branches
- Approvals required:
  - `develop`: Peer review (any team member)
  - `test`: Team lead approval
  - `prod`: Change Advisory Board (CAB) approval

**GitLab CI/CD Pipeline** (For Non-dbt Components):
```yaml
# .gitlab-ci.yml example for ingestion scripts
stages:
  - lint
  - test
  - deploy_dev
  - deploy_test
  - deploy_prod

lint_python:
  stage: lint
  script:
    - pip install flake8
    - flake8 ingestion/

test_ingestion:
  stage: test
  script:
    - pytest tests/ingestion/

deploy_dev:
  stage: deploy_dev
  script:
    - aws s3 sync scripts/ s3://edp-dev-scripts/
  only:
    - develop

deploy_prod:
  stage: deploy_prod
  script:
    - aws s3 sync scripts/ s3://edp-prod-scripts/
  only:
    - prod
  when: manual
```

### Cloud Platform: AWS

**Services in Use**:

#### AWS S3 (Simple Storage Service)
**Purpose**: Landing zone for CDC files, scripts storage
**Buckets**:
- `edp-prod-raw-data/` - Production CDC files
- `edp-dev-raw-data/` - Development ingestion files
- `edp-scripts/` - ETL scripts and utilities

**Organization**:
```
s3://edp-prod-raw-data/
├── legacy_facets/
│   ├── member/
│   ├── claim/
│   └── provider/
├── gemstone_facets/
│   └── ...
└── valenz/
    └── ...
```

#### AWS Lambda
**Purpose**: Event-driven processing, file transformations
**Use Cases**:
- S3 file arrival notifications to Snowpipe
- File format conversions
- Data quality pre-checks before Snowflake ingestion
- Custom ingestion workflows

**Example**:
```python
# Lambda function to trigger Snowpipe on S3 upload
import boto3
import snowflake.connector

def lambda_handler(event, context):
    # S3 event parsing
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = event['Records'][0]['s3']['object']['key']

    # Trigger Snowpipe
    # (Snowpipe has auto-ingest, but this for custom logic)
    ...
```

#### AWS Glue
**Purpose**: Data cataloging, metadata management
**Use Cases**:
- S3 data catalog
- Schema inference for new data sources
- Integration with Snowflake external tables (if needed)

#### AWS MSK (Managed Streaming for Kafka)
**Status**: Being phased out
**Reason**: Cost constraints ($3-4k/day initially, still hundreds/day after optimization)
**Replacement**: Snowflake-native streaming (Streams + Dynamic Tables)

**Legacy Configuration** (Documented for reference):
```
MSK Cluster:
- Broker nodes: 3
- Instance type: kafka.m5.large
- Storage: 1 TB per broker
- Topics: 1000+ (attempted to stream all tables)
- Cost: Unsustainable for project budget
```

#### Apache Airflow (Under Consideration)
**Status**: Planned/evaluation phase
**Purpose**: Potential replacement for dbt Cloud scheduling
**Hosting**: AWS Managed Workflows for Apache Airflow (MWAA)

**Evaluation Criteria**:
- Cost vs. dbt Cloud scheduler
- Complexity of DAG management
- Integration with dbt Core
- Team learning curve

---

## dbt Package Ecosystem

### packages.yml Configuration

```yaml
packages:
  # Data Vault 2.0 automation
  - package: Datavault-UK/automate_dv
    version: [">=0.9.0", "<1.0.0"]

  # Standard utilities
  - package: dbt-labs/dbt_utils
    version: [">=1.0.0", "<2.0.0"]

  # Advanced testing
  - package: calogica/dbt_expectations
    version: [">=0.9.0", "<1.0.0"]

  # Project health evaluation
  - package: dbt-labs/dbt_project_evaluator
    version: [">=0.7.0", "<1.0.0"]

  # Test and run metadata logging
  - package: brooklyn-data/dbt_artifacts
    version: [">=2.0.0", "<3.0.0"]

  # Code generation
  - package: dbt-labs/codegen
    version: [">=0.9.0", "<1.0.0"]

  # Data profiling
  - package: data-mie/dbt_profiler
    version: [">=0.7.0", "<1.0.0"]

  # Synthetic data generation
  - package: edanalytics/dbt_synth_data
    version: [">=0.1.0", "<1.0.0"]
```

### Package Details and Usage

#### automate_dv (Datavault-UK)
**Purpose**: Data Vault 2.0 pattern automation

**Key Macros**:
- `automate_dv.hub()` - Generate hub tables
- `automate_dv.link()` - Generate link tables
- `automate_dv.sat()` - Generate satellite tables
- `automate_dv.eff_sat()` - Effectivity satellites
- `automate_dv.ma_sat()` - Multi-active satellites
- `automate_dv.pit()` - Point-in-time tables
- `automate_dv.bridge()` - Bridge tables

**Usage Example**:
```sql
-- models/integration/hubs/h_member.sql
{{ config(materialized='incremental', unique_key='member_hk') }}

{{ automate_dv.hub(
    src_pk='member_hk',
    src_nk='member_bk',
    src_ldts='load_timestamp',
    src_source='record_source',
    source_model=ref('stg_member')
) }}
```

#### dbt_utils (dbt Labs)
**Purpose**: Standard utility macros

**Commonly Used Macros**:
- `dbt_utils.surrogate_key()` - Generate hash keys
- `dbt_utils.union_relations()` - Union multiple sources
- `dbt_utils.star()` - Select all columns except specified
- `dbt_utils.current_timestamp()` - Cross-database current timestamp
- `dbt_utils.date_spine()` - Generate date dimension

**Usage Example**:
```sql
-- Generate surrogate key
{{ dbt_utils.surrogate_key([
    'source_system',
    'member_id'
]) }} AS member_hk
```

#### dbt_expectations (Calogica)
**Purpose**: Advanced data quality testing inspired by Great Expectations

**Test Types**:
- `expect_column_values_to_be_between`
- `expect_column_values_to_match_regex`
- `expect_column_values_to_be_in_set`
- `expect_table_row_count_to_equal_other_table`
- `expect_column_pair_values_to_be_equal`

**Usage Example**:
```yaml
# models/schema.yml
models:
  - name: dim_member
    columns:
      - name: age
        tests:
          - dbt_expectations.expect_column_values_to_be_between:
              min_value: 0
              max_value: 120
      - name: gender
        tests:
          - dbt_expectations.expect_column_values_to_be_in_set:
              value_set: ['M', 'F', 'U', 'X']
```

#### dbt_project_evaluator (dbt Labs)
**Purpose**: Evaluate dbt project health and best practices

**Checks**:
- Model naming conventions
- Test coverage
- Documentation completeness
- Source freshness configuration
- Circular dependency detection
- Model directory structure

**Usage**:
```bash
dbt run --select package:dbt_project_evaluator
```

**Output**: Reports on project health with recommendations

#### dbt_artifacts (Brooklyn Data)
**Purpose**: Log dbt run and test metadata for analysis

**Captured Data**:
- Model execution times
- Test results (pass/fail)
- Row counts affected
- Resource usage
- Failure details

**Storage**: Logs to Snowflake tables for analysis

**Usage**:
```yaml
# dbt_project.yml
on-run-end:
  - "{{ dbt_artifacts.upload_results(results) }}"
```

**Query Logs**:
```sql
-- Analyze model performance over time
SELECT
    model_name,
    AVG(execution_time_seconds) AS avg_time,
    MAX(execution_time_seconds) AS max_time,
    COUNT(*) AS run_count
FROM common_db.metadata.dbt_run_results
WHERE run_date >= CURRENT_DATE - 30
GROUP BY model_name
ORDER BY avg_time DESC;
```

#### codegen (dbt Labs)
**Purpose**: Generate dbt YAML and SQL code

**Key Macros**:
- `codegen.generate_source()` - Generate source YAML
- `codegen.generate_base_model()` - Generate staging model SQL
- `codegen.generate_model_yaml()` - Generate model documentation YAML

**Usage for Staging Views**:
```sql
-- Generate staging model from source
{{ codegen.generate_base_model(
    source_name='raw_legacy_facets',
    table_name='member'
) }}
```

**Output**:
```sql
-- Auto-generated staging model
WITH source AS (
    SELECT * FROM {{ source('raw_legacy_facets', 'member') }}
),
renamed AS (
    SELECT
        cmc_meme_ck AS member_id,
        first_name,
        last_name,
        birth_date,
        ...
    FROM source
)
SELECT * FROM renamed
```

#### dbt_profiler (data-mie)
**Purpose**: Generate data profiling queries for exploration

**Capabilities**:
- Column-level statistics (min, max, avg, distinct count)
- Null percentage
- Data type inference
- Value distribution analysis

**Usage**:
```sql
-- Profile a table
{{ dbt_profiler.profiler(
    relation=ref('stg_member_demographics'),
    include_columns=['first_name', 'last_name', 'birth_date', 'gender']
) }}
```

#### dbt_synth_data (edAnalytics)
**Purpose**: Generate synthetic test data for development

**Use Cases**:
- Create privacy-safe test datasets
- Generate volume test data
- Populate dev environments without production data

**Usage**:
```yaml
# Generate synthetic member data
models:
  - name: synthetic_members
    config:
      materialized: table
    meta:
      synth:
        rows: 10000
        columns:
          member_id:
            type: sequential_id
          first_name:
            type: faker
            faker_type: first_name
          last_name:
            type: faker
            faker_type: last_name
          birth_date:
            type: random_date
            start_date: '1950-01-01'
            end_date: '2010-12-31'
```

---

## Data Quality and Testing Tools

### Anomalo
**Purpose**: Automated data quality monitoring

**Integration Status**:
- **Connection**: Active to Snowflake
- **Implementation**: Just getting started
- **Ownership**: Data governance team + domain experts

**Capabilities**:
- Automatic anomaly detection (distribution shifts, null rate changes)
- Custom rule definition
- Data quality dashboards
- Alerting on quality issues

**Domain Expert Involvement**:
- Domain experts define quality checks
- Anomalo surfaces potential issues
- Experts validate and refine rules

**Future Integration**:
```sql
-- Potential dbt integration with Anomalo API
-- Check quality before downstream processing
{% if execute %}
    {% set quality_check = run_query("
        SELECT status FROM anomalo_api.quality_check_results
        WHERE table_name = 'stg_member_demographics'
          AND check_date = CURRENT_DATE
    ") %}

    {% if quality_check.rows[0][0] == 'FAIL' %}
        {{ exceptions.raise_compiler_error("Quality check failed for stg_member_demographics") }}
    {% endif %}
{% endif %}
```

### dbt Native Testing
**Coverage**: All dbt-managed tables have minimum tests

**Standard Test Suite**:
```yaml
# Minimum tests on every table
models:
  - name: example_model
    columns:
      - name: primary_key
        tests:
          - unique
          - not_null
      - name: foreign_key
        tests:
          - relationships:
              to: ref('parent_table')
              field: id
```

**Testing Maturity Assessment**:
- **Technical Testing**: High maturity (keys, nulls, relationships)
- **Business Rule Testing**: Medium maturity (some domain-specific tests)
- **Data Analyst Testing**: Low maturity (not yet "does this data make sense?")

**Test Severity by Environment**:
```yaml
# dbt_project.yml
models:
  edp:
    +severity: "{{ 'error' if target.name == 'prod' else 'warn' }}"
```

---

## Data Governance and Cataloging

### Alation
**Purpose**: Data catalog and governance

**Integration**:
- **Metadata Sync**: Active from Snowflake and dbt
- **Sync Method**: Automated via Alation connectors
- **Last Verified**: ~1 year ago (needs re-validation after environment changes)

**Capabilities Used**:
- Browse Snowflake objects
- View dbt model documentation
- Data lineage visualization
- Glossary and business term definitions

**Known Issues**:
- Environment changes may have caused metadata inconsistencies
- Needs review and potential re-configuration
- Integration not failing, but may be stale

**Future Improvements**:
```yaml
# dbt model metadata for Alation sync
models:
  - name: dim_member
    description: "Member dimension for analytics"
    meta:
      alation:
        steward: "data_governance_team"
        domain: "member"
        classification: "confidential"
        retention_policy: "7_years"
```

---

## Warehouse Configuration

### Warehouse Sizing Strategy

**Default Sizes by Workload**:
```sql
-- Extra small for lightweight pipelines
CREATE WAREHOUSE ingestion_xs_wh
  WITH WAREHOUSE_SIZE = 'XSMALL'
       AUTO_SUSPEND = 60
       AUTO_RESUME = TRUE
       INITIALLY_SUSPENDED = TRUE;

-- Small for standard incremental loads
CREATE WAREHOUSE transform_small_wh
  WITH WAREHOUSE_SIZE = 'SMALL'
       AUTO_SUSPEND = 120
       AUTO_RESUME = TRUE;

-- Medium for initial builds
CREATE WAREHOUSE transform_medium_wh
  WITH WAREHOUSE_SIZE = 'MEDIUM'
       AUTO_SUSPEND = 300
       AUTO_RESUME = TRUE;

-- Large for full rebuilds or complex data
CREATE WAREHOUSE transform_large_wh
  WITH WAREHOUSE_SIZE = 'LARGE'
       AUTO_SUSPEND = 600
       AUTO_RESUME = TRUE;
```

### Dynamic Warehouse Selection in dbt

**Macro for Load-Dependent Sizing**:
```sql
-- macros/get_warehouse.sql
{% macro get_warehouse() %}
    {% if flags.FULL_REFRESH %}
        {{ return('transform_large_wh') }}
    {% elif is_incremental() %}
        {{ return('transform_small_wh') }}
    {% else %}
        {{ return('transform_medium_wh') }}  -- Initial build
    {% endif %}
{% endmacro %}
```

**Model Configuration**:
```sql
-- models/integration/hubs/h_member.sql
{{ config(
    materialized='incremental',
    snowflake_warehouse=get_warehouse()
) }}
```

### Auto-Scaling Warehouses

**Limited Use**:
- Most warehouses: Single-cluster, no auto-scaling
- High-concurrency warehouses: Multi-cluster with scaling

**Example Multi-Cluster Configuration**:
```sql
-- Analytics warehouse with auto-scaling for concurrent users
CREATE WAREHOUSE analytics_wh
  WITH WAREHOUSE_SIZE = 'MEDIUM'
       MIN_CLUSTER_COUNT = 1
       MAX_CLUSTER_COUNT = 3
       SCALING_POLICY = 'STANDARD'
       AUTO_SUSPEND = 120
       AUTO_RESUME = TRUE;
```

**Reasoning**: Cost control prioritized over auto-scaling convenience

---

## Monitoring and Alerting

### dbt Platform Monitoring
**Integration**: Microsoft Teams

**Notifications**:
- Job start/completion
- Job failures
- Test failures
- Data freshness violations

**Teams Channel Configuration**:
```
# Per-team channels for targeted monitoring
- #data-engineering-alerts (all dbt jobs)
- #data-quality-alerts (test failures)
- #ingestion-alerts (source freshness)
```

### Snowflake Monitoring
**Tools**:
- Snowflake Web UI (warehouse utilization, query history)
- Account Usage views (cost analysis, performance)
- Resource monitors (budget alerts)

**Key Queries**:
```sql
-- Daily credit consumption
SELECT
    DATE(start_time) AS date,
    warehouse_name,
    SUM(credits_used) AS daily_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
GROUP BY 1, 2
ORDER BY 1 DESC, 3 DESC;

-- Long-running queries
SELECT
    query_id,
    user_name,
    warehouse_name,
    execution_time / 1000 AS execution_seconds,
    query_text
FROM SNOWFLAKE.ACCOUNT_USAGE.QUERY_HISTORY
WHERE execution_time > 300000  -- > 5 minutes
ORDER BY execution_time DESC
LIMIT 100;
```

### Cost Monitoring

**Spending Reports**:
- Tag-based cost allocation
- Warehouse-level tracking
- Environment-level rollups

**Tags for Cost Tracking**:
```sql
-- Tag warehouses by workload type
ALTER WAREHOUSE transform_small_wh SET TAG workload_type = 'transformation';
ALTER WAREHOUSE ingestion_xs_wh SET TAG workload_type = 'ingestion';
ALTER WAREHOUSE analytics_wh SET TAG workload_type = 'analytics';

-- Query costs by workload
SELECT
    tag_value AS workload_type,
    SUM(credits_used) AS total_credits
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY wh
JOIN SNOWFLAKE.ACCOUNT_USAGE.TAG_REFERENCES tags
    ON wh.warehouse_name = tags.object_name
WHERE tag_name = 'workload_type'
GROUP BY 1;
```

---

## Materialization Strategies

### View vs. Table Decision Matrix

| Scenario | Materialization | Rationale |
|----------|----------------|-----------|
| **Simple column rename/select** | View | No compute needed, instant refresh |
| **Light transformations** | View | Query time acceptable |
| **Complex business logic** | Table | Expensive to compute repeatedly |
| **Large table (>50M rows)** | Table (incremental) | Performance optimization |
| **Consumption layer (simple)** | View | Low latency to curated data |
| **Consumption layer (complex)** | Table | Pre-computed for performance |
| **Near-real-time transformations** | Dynamic Table | Continuous refresh needed |

### dbt Materialization Configuration

**Project-Level Defaults**:
```yaml
# dbt_project.yml
models:
  edp:
    staging:
      +materialized: view  # Always views
    integration:
      +materialized: incremental  # Hubs, Links, Sats
    curation:
      dimensional:
        +materialized: table
        +on_schema_change: sync_all_columns
      business_vault:
        +materialized: incremental
    consumption:
      +materialized: view  # Default to view, override per model
```

**Model-Specific Override**:
```sql
-- Large consumption table needing materialization
{{ config(
    materialized='table',
    cluster_by=['member_id', 'service_date']
) }}
```

---

## AI Implementation Hints

### Tool Version Validation
```bash
# Verify package versions
dbt deps
dbt list --resource-type package

# Check dbt version
dbt --version
```

### Package Compatibility Check
```yaml
# Ensure compatible package versions
packages:
  - package: Datavault-UK/automate_dv
    version: ">=0.9.0,<1.0.0"  # Semantic versioning
```

### Warehouse Optimization Pattern
```sql
-- Macro to suggest warehouse size based on table stats
{% macro suggest_warehouse(table_name) %}
    {% set row_count = run_query("
        SELECT COUNT(*) FROM " ~ table_name
    ).rows[0][0] %}

    {% if row_count < 1000000 %}
        XSMALL or SMALL
    {% elif row_count < 10000000 %}
        SMALL or MEDIUM
    {% elif row_count < 100000000 %}
        MEDIUM or LARGE
    {% else %}
        LARGE or XLARGE
    {% endif %}
{% endmacro %}
```

---

## Evaluation Criteria

### Must Have
- [ ] dbt packages installed and version-controlled
- [ ] Warehouse sizing appropriate for workload
- [ ] GitLab CI/CD configured for non-dbt components
- [ ] dbt project evaluator passing health checks
- [ ] Test coverage on all models (minimum: unique, not_null)

### Should Have
- [ ] Anomalo connected and quality checks defined
- [ ] Alation metadata sync validated and current
- [ ] Cost monitoring tags applied to warehouses
- [ ] Auto-suspend configured on all warehouses
- [ ] dbt_artifacts logging enabled

### Nice to Have
- [ ] Apache Airflow evaluation completed
- [ ] Multi-cluster warehouses for high concurrency
- [ ] Advanced dbt_expectations tests on critical models
- [ ] Synthetic data generation for all dev tables

---

**Document Version**: 1.0
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
