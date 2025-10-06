# dbt Cloud Terminology Glossary

Common dbt Cloud features, concepts, and terminology sorted by frequency of use in data transformation and analytics engineering contexts.

## Core Concepts

**Model**
SQL SELECT statement transformed into table or view in data warehouse, representing fundamental building block of dbt project.

**Project**
Collection of dbt models, tests, documentation, and configurations organized in repository with dbt_project.yml file.

**Run**
Execution of dbt commands (dbt run, dbt test, dbt build) processing models and materializations in dependency order.

**Materialization**
Strategy determining how model SQL is persisted in warehouse (table, view, incremental, ephemeral).

**Source**
Raw table declaration in data warehouse representing external data before transformation with freshness checks.

**Ref Function**
Jinja function {{ ref('model_name') }} creating dependencies between models and enabling dynamic table references.

**Job**
Scheduled or triggered execution of dbt commands in production environment with notifications and artifact generation.

**Environment**
Isolated configuration (Development or Deployment) with specific connection credentials, schema targets, and dbt version.

## Development Workflow

**IDE (Integrated Development Environment)**
Browser-based editor in dbt Cloud for writing models, tests, and documentation with built-in version control.

**Command Line**
Interface for executing dbt commands (run, test, build, compile, docs generate) during development and deployment.

**Compile**
Process translating Jinja and SQL into executable SQL that will run in data warehouse without execution.

**Preview**
Feature in dbt Cloud IDE showing query results of compiled SQL for model without creating database object.

**DAG (Directed Acyclic Graph)**
Visual representation of model dependencies showing execution order and lineage between data transformations.

**Lineage**
Dependency chain showing data flow from sources through models to final outputs for impact analysis.

## Testing & Quality

**Test**
Assertion about model data validating quality and integrity (unique, not_null, relationships, accepted_values).

**Generic Test**
Reusable, parameterized test defined once and applied to multiple columns or models via YAML configuration.

**Singular Test**
Custom SQL query returning failing rows for specific business logic validation unique to one model.

**Schema Test**
Tests defined in YAML schema files for validating column properties and relationships between models.

**Data Test**
Generic term for all test types ensuring data quality, accuracy, and conformity to business rules.

## Documentation

**Documentation**
Auto-generated website from code describing models, columns, tests, and lineage with markdown descriptions.

**Description**
Markdown text in YAML or config blocks explaining purpose and context of models, columns, and other resources.

**docs Block**
Reusable documentation snippet defined once and referenced in multiple places using {{ doc('block_name') }}.

**Column-Level Lineage**
Detailed tracking showing which source columns contribute to each column in derived models.

## Incremental Processing

**Incremental Model**
Materialization building table incrementally by processing only new/changed records since last run for efficiency.

**is_incremental() Macro**
Conditional check determining if model is running in incremental mode versus full refresh.

**Unique Key**
Column(s) identifying distinct rows in incremental model for upsert/merge logic during incremental runs.

**Full Refresh**
Flag (--full-refresh) forcing complete rebuild of incremental models ignoring incremental logic.

## Configuration & Variables

**dbt_project.yml**
Main configuration file defining project settings, model paths, materializations, and variable defaults.

**Config Block**
In-model configuration using {{ config() }} Jinja to set materialization, schema, tags, and other properties.

**Variable**
Dynamic value defined in dbt_project.yml or CLI accessible via {{ var('variable_name') }} in models.

**Target**
Runtime environment specification (dev, prod) determining connection and schema compilation context.

**Profile**
Connection configuration (profiles.yml) containing warehouse credentials and target definitions for environments.

## Packages & Macros

**Package**
Reusable dbt code (macros, models, tests) from dbt Hub or Git repositories imported via packages.yml.

**Macro**
Reusable Jinja function for generating SQL, performing calculations, or implementing custom logic across project.

**dbt_utils**
Popular package providing utility macros for date operations, SQL generation, testing, and common transformations.

## dbt Cloud Specific

**Account**
Top-level organizational unit in dbt Cloud containing projects, environments, users, and billing configuration.

**Connection**
Warehouse credentials and configuration for connecting to data platform (Snowflake, BigQuery, Redshift, Databricks).

**Repository**
Git repository (GitHub, GitLab, Azure DevOps) linked to dbt Cloud project for version control integration.

**Deployment Environment**
Production-like environment where scheduled jobs run with specific credentials and configuration.

**Development Credentials**
Personal warehouse credentials for individual developers accessing sandbox schemas during development.

**Job Scheduler**
Interface for configuring job timing using cron expressions or continuous deployment triggers.

**Run History**
Audit log of all job executions with status, duration, logs, and artifacts for troubleshooting.

**Artifacts**
Generated files from runs including manifest.json, catalog.json, and run_results.json for metadata.

**Webhook**
HTTP endpoint for triggering jobs via external systems or CI/CD pipelines with event-driven workflows.

**Slim CI**
Continuous integration feature running only modified models and downstream dependencies for faster validation.

## Monitoring & Observability

**Run Status**
Execution outcome (Success, Failed, Cancelled, Running) indicating job completion state with error details.

**Model Timing**
Performance metrics showing compilation and execution duration per model for optimization insights.

**Test Results**
Output showing passed/failed tests with row counts and sample failing records for investigation.

**Freshness Check**
Source data staleness validation comparing loaded_at_field against warn_after and error_after thresholds.

**Logs**
Detailed command output showing SQL compilation, execution progress, errors, and warnings during runs.

**Notifications**
Email or Slack alerts configured on jobs for run failures, successes, or specific conditions.

## Snapshots & SCDs

**Snapshot**
Type-2 slowly changing dimension implementation capturing historical changes in mutable source tables over time.

**Check Strategy**
Method for detecting changes in snapshot (timestamp or check_cols) determining when to create new rows.

**valid_from / valid_to**
Columns added by snapshots indicating period when row version was current for temporal queries.

## Advanced Features

**Exposure**
Declaration of downstream use of dbt models in BI tools, dashboards, or applications for dependency tracking.

**Metric**
Business metric definition with aggregation logic and dimensions for consistent KPI calculation (dbt Metrics).

**Seed**
CSV file loaded into warehouse as table for static data like lookup tables or configurations.

**Hook**
SQL statement executed before or after model runs (pre-hook, post-hook, on-run-start, on-run-end).

**Analysis**
Saved query in analyses/ folder for ad-hoc investigation compiled but not materialized as table.

**Project Dependency**
Multi-project setup where one dbt project references models from another using ref() across project boundaries.

## Jinja & Templating

**Jinja**
Templating language enabling dynamic SQL generation with variables, loops, conditionals, and macros.

**Statement Block**
Jinja tag {% %} for control flow (if, for, set) versus expression {{ }} for output.

**Adapter Dispatch**
Macro feature allowing warehouse-specific implementations based on target platform (adapter.dispatch()).

**Context Variables**
Built-in Jinja variables (target, env_var, modules, graph) providing runtime information.

## Materialization Types

**Table Materialization**
Strategy dropping and recreating table on each run, simple but inefficient for large datasets.

**View Materialization**
Creates database view executing query at read time, no data storage but query performance cost.

**Ephemeral Materialization**
Inline CTE interpolated into dependent models, no database object created for intermediate transforms.

**Incremental Materialization**
Appends or updates only new records identified by logic, most efficient for large, append-heavy datasets.

## Common dbt Cloud Terms

**Developer Seat**
License type allowing read-write access to IDE for model development with personal credentials.

**Read-Only Seat**
License type for viewing documentation, lineage, and run history without development capabilities.

**dbt Version**
Specific release of dbt Core (1.0, 1.5, 1.7) determining available features and syntax.

**Selector**
Syntax for running subset of models using tags, paths, or graph operators (dbt run --select tag:daily).

**State Comparison**
Comparing current project against prior run artifacts for slim CI and change detection.

**Defer**
Feature using production artifacts to avoid building upstream dependencies in development runs.

**Clone**
Command creating empty table structures matching production for schema validation without data copying.

**Parse**
Process reading all project files to build DAG and validate syntax before execution.

**Threads**
Concurrent model executions configured per environment for parallel processing within dependency constraints.

**Invocation ID**
Unique identifier for each dbt command execution correlating logs and events.
