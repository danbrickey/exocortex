---
title: "EDP Near-Real-Time Architecture"
document_type: "architecture"
ai_workflow_tags: ["near-realtime", "customer-service", "dynamic-tables", "streams", "virtualization"]
code_evaluation_scope: "realtime-pipelines"
business_context: "Sub-minute data latency for customer service portal"
technical_audience: "architects|developers|data-engineers"
last_updated: "2025-10-01"
related_components: ["snowflake-streams", "dynamic-tables", "views", "customer-service-portal"]
related_docs: ["edp-data-ingestion-architecture.md", "edp-layer-architecture-detailed.md"]
---

# EDP Near-Real-Time Architecture

## Executive Summary

The EDP platform implements a near-real-time data architecture targeting sub-minute latency from source system changes to customer service portal availability. The architecture leverages Snowflake Streams for CDC capture, virtual views for integration layer, and dynamic tables in the curation layer for business rule application. Initial implementation supports approximately 50-100 critical tables for customer service operations, focusing on eligibility, claims, and deductibles.

## AI Workflow Guidance

**Key Patterns**: Stream → View (Integration) → Dynamic Table (Curation) → View (Consumption)
**Implementation Hints**: Virtualize where possible, materialize only for complex business rules
**Validation Points**: Latency under 1 minute from stream to consumption, cost constraints met

---

## Business Context

### Primary Use Case: Customer Service Portal

**Purpose**: Real-time data access for customer service representatives

**Critical Data Requirements**:
- **Eligibility Changes**: Member enrollment, coverage changes, plan updates
- **Claims Status**: Current claim processing status, approvals, denials
- **Financial Information**: Deductibles, out-of-pocket maximums, remaining benefits
- **Coverage Details**: Current benefits, network status, prior authorizations

**Latency Requirements**:
- **Target**: Sub-minute (< 1 minute) from source system change to portal
- **Business Justification**: Customer service reps need accurate, current information during member phone calls
- **Constraint**: Cost-effective solution within budget constraints

### Future Real-Time Use Cases

While customer service portal is the primary driver, the architecture is designed generically to support:
- Member self-service portals
- Provider real-time eligibility verification
- Care management dashboards
- Real-time fraud detection alerts

---

## Architecture Overview

### Latency Budget Breakdown

```
┌─────────────────────────────────────────────────────────────────┐
│                    LATENCY BUDGET (~60 seconds)                 │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  Source → S3 (Snowpipe Stream Ingestion)                        │
│  ├─ CDC on SQL Server: ~10-20 seconds                          │
│  ├─ File write to S3: ~10-20 seconds                           │
│  └─ Snowpipe ingestion: ~10-20 seconds                         │
│  SUBTOTAL: ~30-60 seconds                                       │
│                                                                 │
│  Stream → Integration Layer (Virtual Views)                     │
│  └─ View queries: Instant (virtual, no materialization)         │
│                                                                 │
│  Integration → Curation Layer (Dynamic Tables)                  │
│  ├─ Business rule processing: Variable by complexity            │
│  ├─ Dynamic table refresh: Configured for minimal lag           │
│  └─ May require 1-3 layers depending on business logic          │
│  SUBTOTAL: Target < 1 minute                                    │
│                                                                 │
│  Curation → Consumption Layer (Virtual Views)                   │
│  └─ View queries: Instant (virtual, no materialization)         │
│                                                                 │
│  TOTAL TARGET: < 2 minutes end-to-end                           │
└─────────────────────────────────────────────────────────────────┘
```

### Layer-by-Layer Virtualization Strategy

**Philosophy**: Virtualize wherever possible, materialize only when necessary

#### Raw Layer (Already Physical)
- Snowflake Streams (transient storage)
- Physical history tables (batch loaded every 4 hours)
- **Status**: Physical by design (foundation layer)

#### Integration Layer (Target: Virtual Views)
```sql
-- Virtual view combining stream + history
CREATE VIEW int_db.member.vw_member_eligibility_realtime AS
SELECT * FROM raw_db.legacy_facets_history.member_eligibility
WHERE load_timestamp > DATEADD(hour, -4, CURRENT_TIMESTAMP())
UNION ALL
SELECT * FROM raw_db.legacy_facets_transient.member_eligibility;
```

**Characteristics**:
- No physical tables (all views)
- Light cleansing (character encoding, dangerous characters)
- Record ID hashing applied in view logic
- **Fallback**: If performance issues arise, convert to dynamic tables

**Expected Performance**: Instant (metadata-only operation)

#### Curation Layer (Dynamic Tables for Business Rules)
```sql
-- Dynamic table with business rules
CREATE DYNAMIC TABLE cur_db.member.dt_member_current_eligibility
  TARGET_LAG = '1 minute'
  WAREHOUSE = realtime_wh
AS
SELECT
    member_id,
    coverage_effective_date,
    coverage_termination_date,
    plan_id,
    -- Complex business rule: determine current eligibility
    CASE
        WHEN CURRENT_DATE BETWEEN coverage_effective_date
             AND COALESCE(coverage_termination_date, '9999-12-31')
        THEN 'ACTIVE'
        WHEN CURRENT_DATE < coverage_effective_date
        THEN 'PENDING'
        ELSE 'TERMINATED'
    END AS eligibility_status,
    -- Additional business calculations
    ...
FROM int_db.member.vw_member_eligibility_realtime;
```

**Materialization Criteria**:
- Significant business rule processing required
- Complex transformations (date logic, case statements, aggregations)
- Too expensive to compute on-the-fly

**Dynamic Table Layers**:
- **Layer 1**: Basic business rule application (eligibility status, coverage validation)
- **Layer 2**: Calculated fields (remaining deductibles, benefit utilization)
- **Layer 3** (if needed): Complex aggregations or denormalizations

**Target Lag**: 1 minute (configurable per table based on complexity)

#### Consumption Layer (Virtual Views)
```sql
-- Fit-for-purpose view for customer service portal
CREATE VIEW con_db.customer_service.vw_member_summary AS
SELECT
    m.member_id,
    m.first_name,
    m.last_name,
    e.eligibility_status,
    e.plan_id,
    d.deductible_remaining,
    c.open_claims_count
FROM cur_db.member.dt_member_demographics m
JOIN cur_db.member.dt_member_current_eligibility e ON m.member_id = e.member_id
JOIN cur_db.financial.dt_deductible_summary d ON m.member_id = d.member_id
LEFT JOIN cur_db.claims.dt_claim_summary c ON m.member_id = c.member_id;
```

**Characteristics**:
- Virtual views only (no materialization)
- Joins across curation layer dynamic tables
- Row-level security applied via policies
- Column masking for PII/PHI

---

## Table Scope and Selection

### Initial Implementation: 50-100 Critical Tables

**Selection Criteria**:
1. **Operational Criticality**: Data needed for real-time customer service decisions
2. **Change Frequency**: Tables with frequent updates that need to be reflected quickly
3. **Business Impact**: High-value data for customer interactions
4. **Query Patterns**: Tables frequently accessed together in portal queries

**Primary Domains Covered**:
- **Member**: Demographics, eligibility, coverage
- **Claims**: Claim status, payment status, outstanding amounts
- **Financial**: Deductibles, out-of-pocket, premiums
- **Provider**: Network status, provider information

### Lessons from MSK Failure

**Previous Approach (Too Expensive)**:
- Attempted to stream 1000+ tables via MSK (Kafka)
- Cost: $3-4k/day initially, reduced to hundreds/day
- **Result**: Abandoned due to cost constraints

**New Approach (Cost-Controlled)**:
- Highly selective table list (50-100 tables)
- Snowflake-native streaming (Snowpipe + Streams)
- 4-hour batch processing for remaining tables
- **Cost Target**: Stay within budget constraints

---

## Technical Implementation

### Snowflake Streams Configuration

**Stream Creation Pattern**:
```sql
-- Create stream on raw history table
CREATE STREAM raw_db.legacy_facets_transient.stream_member_eligibility
    ON TABLE raw_db.legacy_facets_history.member_eligibility
    APPEND_ONLY = FALSE;  -- Capture all DML (INSERT, UPDATE, DELETE)
```

**Stream Characteristics**:
- Captures changes since last consumed
- Tracks INSERT, UPDATE, DELETE operations
- Includes CDC metadata (operation type, timestamp)
- Low storage cost (only changes stored)

### Dynamic Table Configuration

**Refresh Strategy**:
```sql
-- Target lag configuration
CREATE DYNAMIC TABLE cur_db.member.dt_member_eligibility
    TARGET_LAG = '1 minute'
    WAREHOUSE = realtime_small_wh
    REFRESH_MODE = AUTO
AS
SELECT ...;
```

**Warehouse Sizing for Dynamic Tables**:
- Start with SMALL warehouse
- Monitor actual refresh times
- Scale up only if missing target lag consistently
- Consider multi-cluster for concurrent access

**Monitoring Queries**:
```sql
-- Check dynamic table lag
SELECT
    name,
    database_name,
    schema_name,
    target_lag,
    data_timestamp,
    scheduling_state,
    refresh_mode
FROM INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE schema_name = 'member'
ORDER BY data_timestamp DESC;

-- Check if lag target is being met
SELECT
    name,
    target_lag,
    DATEDIFF(second, data_timestamp, CURRENT_TIMESTAMP()) AS actual_lag_seconds,
    CASE
        WHEN DATEDIFF(second, data_timestamp, CURRENT_TIMESTAMP()) >
             EXTRACT(EPOCH FROM target_lag)
        THEN 'BEHIND TARGET'
        ELSE 'ON TARGET'
    END AS lag_status
FROM INFORMATION_SCHEMA.DYNAMIC_TABLES;
```

### Integration Layer View Patterns

**Standard Real-Time View Template**:
```sql
-- Template for integration layer real-time views
CREATE OR REPLACE VIEW int_db.{domain}.vw_{entity}_realtime AS
WITH stream_data AS (
    SELECT * FROM raw_db.{source}_transient.{table}
),
recent_history AS (
    SELECT * FROM raw_db.{source}_history.{table}
    WHERE load_timestamp > DATEADD(hour, -4, CURRENT_TIMESTAMP())
),
combined AS (
    SELECT * FROM recent_history
    UNION ALL
    SELECT * FROM stream_data
)
SELECT
    -- Light cleansing
    REGEXP_REPLACE(column1, '[^\x20-\x7E]', '') AS column1_clean,

    -- Record ID hashing
    MD5(CONCAT({source_id}, '::', {primary_key})) AS record_id_hash,

    -- Standard columns
    *
FROM combined;
```

### Consumption Layer Access Patterns

**Portal Query Optimization**:
```sql
-- Optimized for customer service lookup by member ID
CREATE VIEW con_db.customer_service.vw_member_portal_data AS
SELECT
    -- Pre-joined for single portal query
    m.member_id,
    m.first_name,
    m.last_name,
    e.eligibility_status,
    c.open_claims_count,
    f.deductible_remaining
FROM cur_db.member.dt_member_current_eligibility e
JOIN cur_db.member.dt_member_demographics m
    ON e.member_id = m.member_id
LEFT JOIN cur_db.claims.dt_claim_summary c
    ON e.member_id = c.member_id
LEFT JOIN cur_db.financial.dt_financial_summary f
    ON e.member_id = f.member_id;

-- Add search optimization for portal lookups
ALTER VIEW con_db.customer_service.vw_member_portal_data
    ADD SEARCH OPTIMIZATION ON EQUALITY(member_id);
```

---

## Cost Management

### Cost Control Strategies

**1. Selective Table Scope**
- Only 50-100 most critical tables in real-time path
- Remaining tables use 4-hour batch processing
- Regular review of table necessity

**2. Warehouse Optimization**
- Start with smallest warehouse that meets SLA
- Use auto-suspend aggressively (1-2 minutes)
- Monitor actual refresh times vs. warehouse size

**3. Virtual Layer Preference**
- Integration and consumption layers virtualized
- Only curation layer materialized (dynamic tables)
- Reduces storage and compute costs

**4. Dynamic Table Tuning**
- Target lag only as low as needed (not lower)
- Some tables may tolerate 2-5 minute lag vs. 1 minute
- Stagger refresh times to avoid concurrent spikes

### Cost Monitoring

**Daily Cost Tracking**:
```sql
-- Monitor warehouse costs for real-time workloads
SELECT
    DATE(start_time) AS date,
    warehouse_name,
    SUM(credits_used) AS total_credits,
    SUM(credits_used) * {credit_cost} AS estimated_cost
FROM SNOWFLAKE.ACCOUNT_USAGE.WAREHOUSE_METERING_HISTORY
WHERE warehouse_name LIKE '%realtime%'
GROUP BY DATE(start_time), warehouse_name
ORDER BY date DESC, total_credits DESC;
```

**Budget Alerts**:
- Set resource monitors on real-time warehouses
- Alert at 80% and 90% of daily budget
- Automatic suspension at 100% to prevent overrun

---

## Failure Handling and Resilience

### Known Gaps (To Be Determined During Testing)

**Failure Modes Not Yet Defined**:
- Stream consumption failures
- Dynamic table refresh failures
- Warehouse unavailability
- Excessive lag recovery procedures

**Testing Plan**:
1. Simulate source system outages
2. Test stream backpressure handling
3. Validate dynamic table catch-up behavior
4. Measure degraded mode performance

### Fallback Strategies (Proposed)

**Graceful Degradation**:
```sql
-- Portal query with fallback to batch data
CREATE VIEW con_db.customer_service.vw_member_with_fallback AS
SELECT
    COALESCE(rt.member_id, batch.member_id) AS member_id,
    COALESCE(rt.eligibility_status, batch.eligibility_status) AS eligibility_status,
    CASE
        WHEN rt.member_id IS NOT NULL THEN 'REALTIME'
        ELSE 'BATCH (DELAYED)'
    END AS data_freshness_indicator,
    ...
FROM cur_db.member.dt_member_current_eligibility rt
FULL OUTER JOIN cur_db.member.tbl_member_batch_eligibility batch
    ON rt.member_id = batch.member_id;
```

**Manual Intervention Triggers**:
- Lag exceeds 5 minutes for more than 10 minutes
- Stream depth exceeds threshold
- Warehouse credit consumption exceeds daily budget

---

## Performance Expectations

### Target SLAs

| Metric | Target | Acceptable | Action Required |
|--------|--------|------------|-----------------|
| **End-to-End Latency** | < 1 minute | < 2 minutes | > 2 minutes |
| **Dynamic Table Lag** | < 1 minute | < 2 minutes | > 3 minutes |
| **Portal Query Response** | < 1 second | < 3 seconds | > 5 seconds |
| **Daily Cost** | < $X | < $Y | > $Y |

*Note: Specific cost targets to be defined based on budget allocation*

### Performance Testing Approach

**Load Testing**:
1. Simulate high-frequency changes to critical tables
2. Measure actual lag under load
3. Test concurrent portal user queries
4. Validate warehouse auto-scaling behavior

**Stress Testing**:
1. Introduce backlog of changes
2. Measure catch-up time
3. Monitor warehouse credit consumption spike
4. Validate no data loss during stress

---

## Migration from MSK

### Why MSK Was Abandoned

**Cost Issues**:
- Initial cost: $3-4k/day
- Optimized cost: Still hundreds/day
- Unsustainable within project budget constraints

**Scope Issues**:
- Attempted to stream 1000+ tables
- Most tables didn't need real-time latency
- Over-engineered for actual requirements

### Snowflake-Native Approach Benefits

**Cost Advantages**:
- No separate Kafka infrastructure
- Pay only for compute during refresh
- Snowflake storage costs vs. Kafka retention

**Operational Simplicity**:
- One platform (Snowflake) vs. two (Snowflake + MSK)
- Native integration (Streams + Dynamic Tables)
- Fewer moving parts to monitor

**Performance Adequacy**:
- Sub-minute latency sufficient for customer service
- No need for sub-second streaming latency
- Simpler architecture easier to troubleshoot

---

## AI Implementation Hints

### Code Generation Patterns

**Real-Time View Template**:
```yaml
# Input specification
entity:
  name: member_eligibility
  source_system: legacy_facets
  domain: member
  realtime_required: true

# Generated view
view_name: int_db.member.vw_member_eligibility_realtime
base_tables:
  - raw_db.legacy_facets_history.member_eligibility (recent)
  - raw_db.legacy_facets_transient.member_eligibility (stream)
union_strategy: union_all
cleansing_rules:
  - remove_unprintable_characters
  - standardize_encoding
```

**Dynamic Table Template**:
```yaml
# Input specification
entity:
  name: member_current_eligibility
  domain: member
  source_view: int_db.member.vw_member_eligibility_realtime
  target_lag: 1 minute
  warehouse: realtime_small_wh
  business_rules:
    - calculate_eligibility_status
    - determine_coverage_period
    - validate_plan_assignment
```

### Validation Criteria

**Must Have**:
- [ ] Integration layer uses virtual views (no physical tables)
- [ ] Curation layer uses dynamic tables with target lag ≤ 1 minute
- [ ] Consumption layer uses virtual views (no physical tables)
- [ ] Only 50-100 tables in real-time path
- [ ] Stream + history union pattern in integration views

**Should Have**:
- [ ] Warehouse auto-suspend configured ≤ 2 minutes
- [ ] Resource monitors on real-time warehouses
- [ ] Lag monitoring queries in place
- [ ] Cost tracking by real-time workload
- [ ] Fallback to batch data if real-time unavailable

**Performance Validation**:
```sql
-- Verify view is virtual (not materialized)
SHOW VIEWS LIKE 'vw_member_eligibility_realtime';

-- Verify dynamic table target lag
SELECT target_lag FROM INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE name = 'dt_member_current_eligibility';

-- Verify actual lag meets target
SELECT
    name,
    DATEDIFF(second, data_timestamp, CURRENT_TIMESTAMP()) AS actual_lag_seconds
FROM INFORMATION_SCHEMA.DYNAMIC_TABLES
WHERE schema_name = 'member';
```

---

## Evaluation Criteria

### Architecture Compliance
- [ ] Virtualization-first strategy followed
- [ ] Physical tables only in curation layer (dynamic tables)
- [ ] Stream + history union pattern for integration layer
- [ ] Table scope limited to 50-100 critical tables

### Performance Criteria
- [ ] End-to-end latency < 2 minutes (target: < 1 minute)
- [ ] Dynamic table lag meets configured targets
- [ ] Portal queries return < 3 seconds
- [ ] No data loss during normal operations

### Cost Criteria
- [ ] Daily cost within budget allocation
- [ ] Resource monitors configured and active
- [ ] Warehouse sizing appropriate for workload
- [ ] No runaway compute costs

### Operational Criteria
- [ ] Monitoring in place for lag and cost
- [ ] Alerting configured for SLA violations
- [ ] Failure modes understood and documented
- [ ] Runbook for common issues available

---

**Document Version**: 1.0
**Author**: Dan Brickey
**Last Updated**: 2025-10-01
**Status**: Implementation in progress - testing phase pending
