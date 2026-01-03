---
title: "EDP Environment and Database Configuration"
document_type: "process"
ai_workflow_tags: ["environments", "databases", "code-promotion", "data-replication"]
code_evaluation_scope: "platform-configuration"
business_context: "Development workflow and environment separation strategy"
technical_audience: "developers|data-engineers|architects"
last_updated: "2025-10-01"
related_components: ["snowflake", "dbt", "gitlab", "environments"]
---

# EDP Environment and Database Configuration

## Executive Summary

The EDP platform maintains three primary environments (dev, test, prod) with a unique data-down/code-up flow pattern. Each environment contains five databases representing the four architectural layers plus common technical infrastructure. Special considerations exist for ingestion development and dbt development workflows to enable parallel work streams.

## AI Workflow Guidance

**Key Patterns**: Data replication downward, code promotion upward, developer isolation schemas
**Implementation Hints**: Prod raw cloned to lower environments, dbt developers get individual schemas
**Validation Points**: Code promotion through GitLab, data governance approval for ingestion changes

---

## Environment Overview

### Environment Inventory

| Environment | Purpose | Data Source | Code Source | Audience |
|-------------|---------|-------------|-------------|----------|
| **prod** | Production | Live source systems | Deployed from test | End users, production workloads |
| **test** (preprod) | Pre-production validation | Cloned from prod | Promoted from dev | QA, stakeholders, UAT |
| **dev** (team_dev) | Team development | Cloned from prod | Active development | Data engineering team |
| **dev** (individual) | Developer personal | Cloned from prod | Feature branches | Individual developers |

### Data Flow vs. Code Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                    DATA FLOWS DOWNWARD ⬇                        │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   PROD (Live Sources)                                           │
│     │                                                           │
│     │ (zero-copy clone)                                        │
│     ↓                                                           │
│   TEST (Prod raw clone)                                         │
│     │                                                           │
│     │ (zero-copy clone)                                        │
│     ↓                                                           │
│   DEV (Prod raw clone)                                          │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                    CODE FLOWS UPWARD ⬆                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│   DEV (Feature branches)                                        │
│     │                                                           │
│     │ (GitLab merge request)                                   │
│     ↓                                                           │
│   TEST (Release candidate)                                      │
│     │                                                           │
│     │ (Release management)                                     │
│     ↓                                                           │
│   PROD (Deployed release)                                       │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Database Structure per Environment

### Standard 5-Database Pattern

Each environment contains five databases following this naming convention:

| Layer | Dev | Team Dev | Test (Preprod) | Prod |
|-------|-----|----------|----------------|------|
| **Raw** | `{user}_schema` | `dev_raw_db` | `preprod_raw_db` | `prod_raw_db` |
| **Integration** | `{user}_schema` | `dev_int_db` | `preprod_int_db` | `prod_int_db` |
| **Curation** | `{user}_schema` | `dev_cur_db` | `preprod_cur_db` | `prod_cur_db` |
| **Consumption** | `{user}_schema` | `dev_con_db` | `preprod_con_db` | `prod_con_db` |
| **Common** | `{user}_schema` | `dev_common_db` | `preprod_common_db` | `prod_common_db` |

### Individual Developer Environment (Special Case)

**Database**: `dev_dbt_transform_db`
**Schema Pattern**: `{username}_schema`

**Purpose**: Isolated workspace for dbt developers during feature development

**Workflow**:
1. Developer creates feature branch in GitLab
2. dbt transformations execute in `dev_dbt_transform_db.{username}_schema`
3. Developer iterates and tests in personal schema
4. Upon completion, merge to `develop` branch
5. Code runs in team `dev_*_db` databases

**Benefits**:
- No interference between developers
- Safe experimentation and troubleshooting
- Parallel feature development
- Easy cleanup (drop schema when feature complete)

---

## Special Databases Outside Standard Pattern

### 1. Snowflake Admin Database

**Database**: `snowflake_admin_db`
**Purpose**: Platform administration and database management
**Audience**: Snowflake administrators, DBAs

**Contents**:
- User and role management scripts
- Warehouse configuration
- Resource monitor definitions
- Platform-level utilities

**Access**: Highly restricted (SYSADMIN, ACCOUNTADMIN roles only)

### 2. Data Governance Database

**Database**: `data_governance_db`
**Purpose**: Centralized security policy management
**Audience**: Data governance team

**Contents**:
- Row access policies
- Column masking policies
- Policy assignment logic
- Compliance audit queries

**Security**:
- Restricted to data governance analysts
- All security policies managed centrally
- Version-controlled policy definitions

### 3. Dev Raw Database (Ingestion Development)

**Database**: `dev_raw_db` (in dev environment only)
**Purpose**: Ingestion team development workspace
**Distinct From**: `dev_raw_clone_db` (used by dbt developers)

**Workflow**:
```
Ingestion Team Development
    ↓
dev_raw_db (new ingestion pipelines)
    ↓
Data Governance Review & Approval
    ↓
Promotion to prod_raw_db
    ↓
Zero-copy clone to dev_raw_clone_db
    ↓
Available to dbt developers
```

**Rationale**: Chicken-and-egg problem
- dbt developers need source data to build transformations
- Ingestion development happens before data exists in production
- Separate dev raw database enables ingestion development without impacting dbt developers

### 4. Dev Raw Clone Database (dbt Development)

**Database**: `dev_raw_clone_db` (in dev environment only)
**Purpose**: Read-only source data for dbt development
**Source**: Zero-copy clone of `prod_raw_db`

**Characteristics**:
- Refreshed on schedule (daily/weekly)
- Contains production-like data
- Foundation for all dbt development work
- No writes allowed (clone only)

**Usage**:
```sql
-- dbt source configuration
sources:
  - name: raw_legacy_facets
    database: "{{ var('raw_clone_db') }}"  -- dev_raw_clone_db in dev
    schema: legacy_facets_history
    tables:
      - name: member
      - name: claim
```

---

## Data Replication Strategy

### Prod to Lower Environments

**Mechanism**: Snowflake zero-copy cloning
**Frequency**:
- Test: Daily or on-demand
- Dev: Weekly or on-demand

**Cloning Process**:
```sql
-- Clone prod raw to test
CREATE OR REPLACE DATABASE test_raw_db
  CLONE prod_raw_db;

-- Clone prod raw to dev
CREATE OR REPLACE DATABASE dev_raw_clone_db
  CLONE prod_raw_db;
```

**Benefits**:
- Instant replication (metadata operation)
- No storage duplication until data diverges
- Production-like data for testing
- Consistent test data across team

**Limitations**:
- Only raw layer is cloned
- Integration/Curation/Consumption layers built by dbt
- No PII/PHI masking (relies on role-based access)

### Ingestion Development Exception

**Scenario**: New source system being onboarded

**Workflow**:
1. Ingestion team builds CDC pipeline in dev environment
2. Data lands in `dev_raw_db` (not `dev_raw_clone_db`)
3. dbt developers can begin development against `dev_raw_db` for new source
4. After data governance approval:
   - Ingestion pipeline promoted to prod
   - Data begins flowing to `prod_raw_db`
5. `dev_raw_clone_db` refreshed to include new source
6. dbt development continues against `dev_raw_clone_db`

**Temporary Connection**:
```sql
-- dbt temporarily points to dev_raw_db for new source
sources:
  - name: new_source_system
    database: "dev_raw_db"  -- temporary, until prod deployment
    schema: new_source_history
```

---

## Code Promotion Strategy

### GitLab Workflow

**Branches**:
- `feature/*` - Individual developer feature work
- `develop` - Team development integration branch
- `release/*` - Release candidate branches
- `main` - Production code

**Promotion Flow**:
```
Developer Feature Branch
    ↓ (merge request + review)
develop Branch (runs in dev environment)
    ↓ (release branch creation)
release/* Branch (runs in test/preprod environment)
    ↓ (UAT approval + merge)
main Branch (deployed to prod environment)
```

### dbt Cloud CI/CD Integration

**Triggers**:
- Push to `feature/*` → Slim CI run (changed models only)
- Merge to `develop` → Full dev deployment
- Merge to `release/*` → Full test/preprod deployment
- Merge to `main` → Full prod deployment

**dbt Environment Targets**:
```yaml
# profiles.yml structure
dbt_project:
  outputs:
    dev:
      type: snowflake
      account: "{{ env_var('SNOWFLAKE_ACCOUNT') }}"
      database: dev_dbt_transform_db
      schema: "{{ env_var('DBT_SCHEMA') }}"  # username_schema

    team_dev:
      database: dev_int_db  # or dev_cur_db, dev_con_db

    preprod:
      database: preprod_int_db  # or preprod_cur_db, preprod_con_db

    prod:
      database: prod_int_db  # or prod_cur_db, prod_con_db
```

### Release Management Process

**Steps**:
1. **Development Complete**: All features merged to `develop`
2. **Release Branch**: Create `release/YYYY-MM-DD` from `develop`
3. **Deploy to Test**: Automated deployment to preprod databases
4. **User Acceptance Testing**: Stakeholders validate in test environment
5. **Approval Gate**: Release manager approves for production
6. **Merge to Main**: Release branch merged to `main`
7. **Production Deployment**: Automated deployment to prod databases
8. **Validation**: Smoke tests and monitoring

**Rollback Strategy**:
- Git revert of main branch
- Redeploy previous release
- Time travel queries for data recovery (if needed)

---

## Environment Configuration Details

### Snowflake Warehouses by Environment

| Environment | Warehouse Name | Size | Auto-Suspend | Purpose |
|-------------|----------------|------|--------------|---------|
| **prod** | `prod_transform_wh` | Large | 5 min | dbt production runs |
| **prod** | `prod_analytics_wh` | Medium | 2 min | End-user analytics queries |
| **prod** | `prod_ingestion_wh` | Small | 1 min | SnowPipe tasks and merges |
| **test** | `test_transform_wh` | Medium | 5 min | dbt UAT runs |
| **test** | `test_analytics_wh` | Small | 2 min | Stakeholder testing |
| **dev** | `dev_transform_wh` | Small | 10 min | dbt development |
| **dev** | `dev_ingestion_wh` | XSmall | 5 min | Ingestion development |

### dbt Project Variables by Environment

```yaml
# dbt_project.yml
vars:
  # Environment-specific database names
  raw_clone_db: "{{ target.name }}_raw_clone_db"  # or dev_raw_db for new sources
  int_db: "{{ target.name }}_int_db"
  cur_db: "{{ target.name }}_cur_db"
  con_db: "{{ target.name }}_con_db"
  common_db: "{{ target.name }}_common_db"

  # Developer-specific schema (dev only)
  dev_schema: "{{ env_var('DBT_USER') }}_schema"
```

---

## Access Control by Environment

### Role-Based Access Matrix

| Role | Prod | Test | Dev | Dev (Individual) |
|------|------|------|-----|------------------|
| **End Users** | Read (consumption layer) | No access | No access | No access |
| **Analysts** | Read (curation + consumption) | Read (testing) | No access | No access |
| **Data Engineers** | Read (all layers) | Read/Write (all layers) | Read/Write (all layers) | Read/Write (own schema) |
| **Architects** | Read/Write (with approval) | Read/Write | Read/Write | Read/Write |
| **Admins** | Full access | Full access | Full access | Full access |

### Database-Level Grants

```sql
-- Production: Restricted writes
GRANT SELECT ON DATABASE prod_int_db TO ROLE analyst;
GRANT SELECT ON DATABASE prod_cur_db TO ROLE analyst;
GRANT SELECT, INSERT, UPDATE ON DATABASE prod_int_db TO ROLE data_engineer;

-- Test: Relaxed for UAT
GRANT SELECT, INSERT, UPDATE, DELETE ON DATABASE test_int_db TO ROLE data_engineer;

-- Dev: Full access for development
GRANT ALL PRIVILEGES ON DATABASE dev_int_db TO ROLE data_engineer;

-- Individual dev schemas: Personal ownership
GRANT ALL PRIVILEGES ON SCHEMA dev_dbt_transform_db.dan_brickey_schema
  TO USER dan.brickey;
```

---

## Monitoring and Observability

### Environment Health Metrics

**Per Environment**:
- dbt job success/failure rates
- Model build duration trends
- Data freshness by source
- Query performance percentiles
- Warehouse credit consumption

**Cross-Environment**:
- Code promotion lead time (dev → prod)
- Release frequency
- Rollback frequency
- Data sync lag (prod → test/dev clones)

### Alerting Configuration

**Production Alerts** (immediate):
- dbt job failures
- Data freshness SLA violations
- Snowpipe ingestion failures
- Abnormal warehouse usage spikes

**Test Alerts** (delayed):
- Extended dbt job failures (>2 hours)
- Data clone staleness (>3 days)

**Dev Alerts** (informational):
- Long-running developer queries (>30 min)
- Schema cleanup reminders (stale dev schemas)

---

## AI Implementation Hints

### Environment Detection in Code

```sql
-- dbt macro for environment-aware logic
{% macro get_database(layer) %}
  {% if target.name == 'prod' %}
    {{ return('prod_' ~ layer ~ '_db') }}
  {% elif target.name == 'preprod' %}
    {{ return('preprod_' ~ layer ~ '_db') }}
  {% elif target.name == 'team_dev' %}
    {{ return('dev_' ~ layer ~ '_db') }}
  {% else %}
    -- Individual developer
    {{ return('dev_dbt_transform_db') }}
  {% endif %}
{% endmacro %}
```

### Developer Schema Initialization

```sql
-- Automated schema setup for new developer
CREATE SCHEMA IF NOT EXISTS dev_dbt_transform_db.{{ username }}_schema;

GRANT ALL PRIVILEGES ON SCHEMA dev_dbt_transform_db.{{ username }}_schema
  TO USER {{ username }};

-- Clone reference data to dev schema
CREATE TABLE dev_dbt_transform_db.{{ username }}_schema.ref_data
  CLONE dev_common_db.utilities.reference_data;
```

### Environment-Specific Testing

```yaml
# dbt test configuration
models:
  edp_project:
    integration:
      # Strict testing in prod
      +severity: "{{ 'error' if target.name == 'prod' else 'warn' }}"

    curation:
      # Relaxed testing in dev
      +enabled: "{{ target.name in ['prod', 'preprod'] }}"
```

---

## Evaluation Criteria

### Must Have
- [ ] Three primary environments (prod, test, dev) configured
- [ ] Five databases per environment (raw, int, cur, con, common)
- [ ] Data cloning from prod to lower environments
- [ ] Code promotion through GitLab (dev → test → prod)
- [ ] Individual developer schemas in dev_dbt_transform_db
- [ ] Separate dev_raw_db for ingestion development

### Should Have
- [ ] Automated data clone refresh scheduled
- [ ] dbt CI/CD integrated with GitLab branches
- [ ] Environment-specific warehouse sizing
- [ ] Role-based access control by environment
- [ ] Monitoring and alerting per environment

### Validation Commands

```sql
-- Verify environment databases exist
SHOW DATABASES LIKE 'prod_%';
SHOW DATABASES LIKE 'preprod_%';
SHOW DATABASES LIKE 'dev_%';

-- Check data clone freshness
SELECT SYSTEM$CLUSTERING_INFORMATION('dev_raw_clone_db.schema.table');

-- Verify developer schemas
SHOW SCHEMAS IN DATABASE dev_dbt_transform_db;

-- Validate role grants
SHOW GRANTS TO ROLE data_engineer;
```

---

## Automation Triggers

### When to Apply
- New environment provisioning
- New developer onboarding
- Environment refresh/rebuild
- Database cloning schedule

### Input Requirements
- Environment name (dev, test, prod)
- Database naming convention
- Clone refresh schedule
- Developer username list
- Role definitions

### Expected Outputs
- Database creation scripts
- Schema initialization scripts
- Clone refresh tasks
- Access control grants
- Monitoring configuration

---

**Document Version**: 1.0
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
