---
title: "EDP Data Ingestion Architecture"
document_type: "architecture"
ai_workflow_tags: ["ingestion", "cdc", "streaming", "batch", "snowpipe", "near-realtime"]
code_evaluation_scope: "ingestion-pipelines"
business_context: "Foundation for all data movement into EDP platform"
technical_audience: "architects|developers|data-engineers"
last_updated: "2025-10-01"
related_components: ["snowflake", "s3", "snowpipe", "streams", "dynamic-tables"]
---

# EDP Data Ingestion Architecture

## Executive Summary

The EDP platform uses a flexible multi-path ingestion architecture supporting both batch and near-real-time data delivery. All source data flows through a CDC (Change Data Capture) process from on-premises SQL Server systems to AWS S3, then into Snowflake via SnowPipe. The architecture supports dual processing modes: batch processing every 4 hours for standard analytics, and near-real-time views with target latency under 10 minutes for operational use cases.

## AI Workflow Guidance

**Key Patterns**: CDC → S3 → SnowPipe → Stream → Physical Table pattern for all ingestion
**Implementation Hints**: Use Snowflake Streams for near-real-time, batch loads for standard analytics
**Validation Points**: Verify immutability of raw layer, confirm dual-mode processing capabilities

---

## Ingestion Flow Overview

```
On-Prem SQL Server (CDC)
    → AWS S3 (CSV files)
        → Snowflake SnowPipe
            → Snowflake Stream (transient)
                ├→ Near-Real-Time Views (10min latency target)
                │   └→ Dynamic Tables (layered transformation)
                └→ Batch Load (every 4 hours)
                    └→ Physical History Table (immutable audit)
```

---

## Component Details

### 1. Source Systems: On-Premises CDC

**Technology**: SQL Server Change Data Capture (CDC)
**Characteristics**:
- Captures INSERT, UPDATE, DELETE operations from source databases
- Tracks changes at transaction level
- Provides complete audit trail of source system modifications

**Output Format**: CSV files containing change records with CDC metadata

### 2. Cloud Staging: AWS S3

**Purpose**: Cloud landing zone for CDC data
**Structure**:
- Organized by source system
- CSV format for compatibility and cost efficiency
- Acts as intermediate storage between on-prem and Snowflake

**Benefits**:
- Decouples source systems from Snowflake ingestion
- Provides recovery point for data replay
- Enables cost-effective storage of raw CDC data

### 3. Snowflake Ingestion: SnowPipe + Streams

#### SnowPipe Configuration
**Function**: Automated, continuous data loading from S3 to Snowflake
**Trigger**: File arrival notifications from S3
**Target**: Snowflake Streams (transient storage)

**Advantages**:
- Near-real-time ingestion as files arrive
- Serverless architecture (no warehouse required)
- Automatic scaling based on file volume

#### Snowflake Streams
**Purpose**: Staging area for incoming CDC data
**Characteristics**:
- Transient tables (not permanent storage)
- Holds changes until processed by downstream pipelines
- Enables dual consumption: real-time and batch

**Usage Patterns**:
1. **Near-Real-Time Path**: Queried directly via views
2. **Batch Path**: Consumed every 4 hours for history table loading

---

## Processing Modes

### Near-Real-Time Processing (Target: <10 minutes latency)

**Architecture Pattern**:
```sql
-- Real-time view combining history + current stream
CREATE VIEW vw_near_realtime_entity AS
SELECT * FROM tbl_entity_history          -- Historical records
UNION ALL
SELECT * FROM stream_entity_incoming      -- Current changes in stream
```

**Downstream Transformation**:
- **Dynamic Tables (Layer 1)**: Initial transformations on combined data
- **Dynamic Tables (Layer 2)**: Business logic and calculated fields
- **Dynamic Tables (Layer 3)**: Final consumption-ready format

**Use Cases**:
- Customer service representative dashboards
- Real-time eligibility verification
- Live claim status inquiries
- Operational decision support

**Configuration Considerations**:
- Dynamic table refresh intervals tuned for 10-minute latency target
- Warehouse sizing optimized for continuous micro-batch processing
- Monitoring for lag detection and alerting

### Batch Processing (Every 4 hours)

**Architecture Pattern**:
```sql
-- Periodic merge from stream to history table
MERGE INTO tbl_entity_history h
USING stream_entity_incoming s
ON h.record_id = s.record_id
   AND h.valid_from = s.valid_from
WHEN MATCHED THEN UPDATE ...
WHEN NOT MATCHED THEN INSERT ...
```

**Characteristics**:
- Scheduled task execution every 4 hours
- Processes accumulated changes from stream
- Appends to immutable history tables in raw layer
- Larger batch sizes for cost-efficient processing

**Use Cases**:
- Standard analytical reporting
- Historical trend analysis
- Data science model training
- Regulatory compliance reporting

**Benefits**:
- Cost optimization through larger batch processing
- Reduced compute resource consumption
- Stable, predictable processing windows

---

## Raw Layer Organization

### Schema Structure per Source System

Each source system database receives **two schemas** in Snowflake:

#### 1. History Schema (Permanent Storage)
**Naming**: `{source_system}_{database}_history`
**Example**: `gemstone_members_history`

**Purpose**: Immutable audit trail of all source system changes
**Storage**: Permanent tables
**Structure**:
- All source table columns
- CDC metadata (operation type, transaction timestamp)
- Snowflake metadata (load timestamp, file source)

**Characteristics**:
- Append-only (never updated or deleted)
- Complete historical record
- Foundation for time-travel queries
- Compliance and audit support

#### 2. Transient Schema (Stream Storage)
**Naming**: `{source_system}_{database}_transient`
**Example**: `gemstone_members_transient`

**Purpose**: Temporary holding for incoming changes
**Storage**: Transient tables (Snowflake Streams)
**Lifecycle**:
- Populated by SnowPipe as files arrive
- Consumed by near-real-time views continuously
- Merged to history tables every 4 hours
- Stream advances (changes removed) after merge

**Characteristics**:
- No time-travel (transient storage)
- Cost-optimized for temporary data
- Dual consumption pattern (real-time + batch)

### Example: Gemstone Source with 5 Databases

```
RAW_DB (Snowflake Database)
├── gemstone_members_history        (permanent tables)
├── gemstone_members_transient      (streams)
├── gemstone_claims_history         (permanent tables)
├── gemstone_claims_transient       (streams)
├── gemstone_providers_history      (permanent tables)
├── gemstone_providers_transient    (streams)
├── gemstone_financial_history      (permanent tables)
├── gemstone_financial_transient    (streams)
├── gemstone_admin_history          (permanent tables)
└── gemstone_admin_transient        (streams)
```

---

## Integration with Medallion Architecture

### Raw Layer = Bronze Layer Equivalent

**EDP Raw Layer Design Principles**:
1. **Source-System Organization**: Data organized by source system, not by domain
2. **Immutability**: History tables never modified, only appended
3. **Complete Audit Trail**: Every change captured with full CDC metadata
4. **Dual-Mode Support**: Architecture supports both real-time and batch consumption

**Differences from Traditional Bronze**:
- Dual schema pattern (history + transient) for each source
- Built-in near-real-time capability through stream views
- CDC metadata preserved throughout raw layer

---

## Quality and Monitoring

### Data Quality Checkpoints

**Ingestion Validation**:
- File arrival monitoring in S3
- SnowPipe load success/failure tracking
- Row count reconciliation (source → S3 → Snowflake)

**Stream Health**:
- Stream lag monitoring (time since last consumed)
- Stream depth tracking (number of uncommitted changes)
- Stale stream alerts (beyond expected thresholds)

**History Table Integrity**:
- Append-only enforcement (no updates/deletes)
- CDC sequence validation (detect gaps)
- Duplicate detection (same change loaded twice)

### Performance Monitoring

**Near-Real-Time Path**:
- Dynamic table lag (current lag vs. 10-minute target)
- View query performance metrics
- Warehouse utilization for continuous processing

**Batch Processing**:
- Task execution duration trends
- Merge operation performance
- History table growth rates

---

## AI Implementation Hints

### File Patterns for Ingestion Code
```
ingestion/
├── snowpipe/
│   ├── {source_system}_{database}_pipe.sql
│   └── {source_system}_{database}_stage.sql
├── streams/
│   └── {source_system}_{database}_stream.sql
├── tasks/
│   └── {source_system}_{database}_batch_merge.sql
└── views/
    └── {source_system}_{database}_realtime.sql
```

### Code Templates
**SnowPipe Definition**:
```sql
CREATE PIPE pipe_{source}_{database}_{table}
AUTO_INGEST = TRUE
AS
COPY INTO {source}_{database}_transient.{table}
FROM @stage_{source}_{database}/{table}/
FILE_FORMAT = (TYPE = CSV, SKIP_HEADER = 1);
```

**Batch Merge Task**:
```sql
CREATE TASK task_{source}_{database}_merge
WAREHOUSE = ingestion_wh
SCHEDULE = 'USING CRON 0 */4 * * * America/Chicago'
AS
CALL sp_merge_{source}_{database}_changes();
```

### Integration Points for dbt
- dbt sources reference history tables (immutable)
- Near-real-time models reference real-time views
- Incremental models use CDC metadata for efficient processing

---

## Evaluation Criteria

### Must Have
- [ ] All source systems follow dual-schema pattern (history + transient)
- [ ] SnowPipe configured with auto-ingest from S3
- [ ] Batch merge tasks scheduled every 4 hours
- [ ] Near-real-time views combine history + stream
- [ ] Raw layer tables are append-only (immutable)

### Should Have
- [ ] Monitoring alerts for stream lag exceeding thresholds
- [ ] Dynamic table refresh tuned for 10-minute target latency
- [ ] Row count reconciliation between source and Snowflake
- [ ] CDC sequence gap detection implemented

### Validation Commands
```sql
-- Verify dual schema existence
SHOW SCHEMAS IN DATABASE raw_db LIKE '%history%';
SHOW SCHEMAS IN DATABASE raw_db LIKE '%transient%';

-- Check SnowPipe status
SHOW PIPES IN DATABASE raw_db;

-- Verify stream health
SELECT system$stream_has_data('stream_entity_incoming');

-- Validate batch task schedule
SHOW TASKS IN DATABASE raw_db;
```

---

## Automation Triggers

### When to Apply
- New source system database being onboarded
- Additional tables identified for near-real-time processing
- New CDC feeds from on-premises systems

### Input Requirements
- Source system name and database list
- Table schemas and primary keys
- S3 bucket structure and paths
- Near-real-time vs. batch-only classification

### Expected Outputs
- SnowPipe definitions for each source table
- Stream objects for transient storage
- Merge tasks for batch processing
- Real-time views for operational use cases
- Monitoring queries and alerts

---

**Document Version**: 1.0
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
