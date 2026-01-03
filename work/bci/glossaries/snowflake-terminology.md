# Snowflake Terminology Glossary

Common Snowflake services, features, and terminology sorted by frequency of use in enterprise data platform contexts.

## Core Architecture & Compute

**Virtual Warehouse**
Compute cluster that executes queries and DML operations, independently scalable up/down/out even while in use by active sessions, with automatic suspend/resume to optimize costs.

**Database**
Logical container for schemas and objects, supporting cloning, time travel, and fail-safe recovery with metadata management.

**Schema**
Namespace within a database containing tables, views, and other objects, providing organizational structure and access control.

**Stage**
Named location for storing data files for loading/unloading, available as internal (Snowflake-managed) or external (cloud storage).

**Storage Layer**
Centralized, managed storage for all data in Snowflake with automatic compression, encryption, and organization into micro-partitions.

**Compute Layer**
Independent processing resources (virtual warehouses) that execute queries without impacting storage or other compute resources.

## Data Management

**Time Travel**
Feature enabling access to historical data at any point within retention period (up to 90 days) for queries, clones, and restores.

**Fail-Safe**
Seven-day recovery period after time travel expires, providing disaster recovery through Snowflake support intervention only.

**Zero-Copy Cloning**
Creating instant, writable copies of databases, schemas, or tables without duplicating underlying data, using metadata pointers.

**Micro-Partition**
Snowflake's proprietary storage unit (50-500 MB compressed) with metadata for automatic pruning and optimized query performance.

**Clustering Key**
Column(s) defining how data is organized within micro-partitions to improve query performance on large tables.

**Data Sharing**
Secure sharing of live data between Snowflake accounts without copying or transferring data using reader accounts.

**Snowpipe**
Automated, serverless data ingestion service for continuous loading of micro-batches as files arrive in stages.

## Security & Governance

**RBAC (Role-Based Access Control)**
Security model using roles, privileges, and role hierarchies to manage access to objects and perform operations.

**Network Policy**
Access control restricting connections to Snowflake based on IP address allowlists and blocklists.

**Column-Level Security**
Security feature using masking policies and row access policies to protect sensitive data at granular levels.

**Dynamic Data Masking**
Policy-based feature that masks sensitive data in query results based on user role without altering stored data.

**External OAuth**
Integration with identity providers (Okta, Azure AD) for single sign-on authentication using OAuth 2.0 protocol.

**Key Pair Authentication**
Authentication method using public-private key cryptography instead of passwords for enhanced security.

**Object Tagging**
Metadata labels applied to objects for classification, tracking, and governance with tag-based masking policies.

## Workload Management

**Multi-Cluster Warehouse**
Virtual warehouse with automatic scaling to handle concurrency by adding/removing compute clusters based on query load.

**Resource Monitor**
Control mechanism for monitoring credit usage and setting alerts or suspension actions when thresholds are reached.

**Query Profile**
Detailed execution plan visualization showing operator statistics, data flow, and performance metrics for query optimization.

**Result Cache**
24-hour cache of query results automatically used when identical queries are executed on unchanged data.

**Metadata Cache**
Cache storing table metadata and statistics to accelerate query compilation and optimization.

## Data Integration

**External Table**
Table definition accessing data files in external cloud storage without loading into Snowflake, using metadata from stages.

**Materialized View**
Pre-computed query result stored as a table, automatically maintained and refreshed when underlying data changes.

**Stream**
Change data capture (CDC) object tracking DML changes to tables for incremental processing in data pipelines.

**Task**
Scheduled execution of SQL statements or stored procedures supporting dependencies and conditional logic for workflow orchestration.

**Connector**
Pre-built integrations for platforms like Spark, Kafka, Python, JDBC/ODBC enabling programmatic access to Snowflake.

## Advanced Features

**Snowpark**
Developer framework for building data pipelines and applications using DataFrame API in Python, Java, and Scala.

**User-Defined Function (UDF)**
Custom function written in SQL, JavaScript, Java, Python, or Scala for extending Snowflake's built-in functionality.

**Stored Procedure**
Procedural code block written in SQL, JavaScript, or Snowpark for executing complex business logic and workflows.

**External Function**
Function that calls external APIs or services (AWS Lambda, Azure Functions) from within Snowflake queries.

## Performance & Optimization

**Search Optimization Service**
Background service creating additional data structures to significantly improve point lookup and substring search performance.

**Automatic Clustering**
Service that continuously reorganizes data in large tables to maintain optimal clustering for query performance.

**Query Acceleration Service**
Serverless compute resource that accelerates portions of query workload by offloading work from virtual warehouses.

**Pruning**
Optimization technique using micro-partition metadata to skip scanning irrelevant partitions during query execution.

## Data Science & ML

**Snowflake ML**
Machine learning capabilities including feature engineering, model training, and deployment within Snowflake environment.

**Cortex**
AI and ML services providing pre-built models for text analytics, forecasting, and anomaly detection.

**Snowsight**
Modern web interface for querying, visualization, and dashboarding with collaborative worksheets and folders.

## Accounts & Organizations

**Account**
Top-level entity identified by account locator and cloud region containing databases, users, roles, and warehouses.

**Organization**
Container for multiple Snowflake accounts enabling centralized management, billing, and cross-account data sharing.

**Replication**
Feature for copying databases and objects across regions and cloud platforms for disaster recovery and geographic distribution.

**Failover/Failback**
Business continuity feature enabling primary account failure to redirect to secondary account with replication.

## Data Types & Formats

**VARIANT**
Semi-structured data type for storing JSON, Avro, ORC, Parquet, and XML with native querying capabilities.

**GEOGRAPHY**
Geospatial data type supporting geographic coordinates and shapes with spatial functions for analysis.

**File Format**
Named definition of data file structure (CSV, JSON, Avro, Parquet, ORC, XML) for loading and unloading operations.

## Common Snowflake Terms

**Credit**
Unit of Snowflake compute consumption based on warehouse size and duration, billed per-second with one-minute minimum.

**Edition**
Snowflake service tier (Standard, Enterprise, Business Critical) determining available features and compliance certifications.

**Secure View**
View with optimizations disabled to prevent data exposure through query plans, required for data sharing sensitive data.

**Transient Table**
Table without fail-safe period (only time travel) for reduced storage costs on temporary or non-critical data.

**Temporary Table**
Session-scoped table automatically dropped when session ends, useful for intermediate query results and staging.

**Information Schema**
System-defined schema containing metadata views about account objects, privileges, and usage statistics.

**Account Usage**
Shared database (SNOWFLAKE) containing historical metadata and usage information across the entire account.

**Warehouse Size**
T-shirt sizing (X-Small to 6X-Large) determining compute resources and credit consumption rate per hour.

**Session Parameter**
Configuration setting controlling session behavior like timezone, query timeout, and transaction isolation.

**Context Function**
Built-in function returning session, account, or user context information (CURRENT_USER, CURRENT_ROLE, CURRENT_WAREHOUSE).
