---
title: "Multi-Tenancy Architecture Pattern"
document_type: "pattern"
business_domain: []  # Cross-domain security pattern
edp_layer: "cross-layer"
technical_topics: ["multi-tenant", "security", "rbac", "data-quality", "snowflake"]
audience: ["executives", "directors", "architects", "engineers", "analysts"]
status: "active"
last_updated: "2025-10-16"
version: "1.2"
author: "Dan Brickey"
description: "Multi-tenancy pattern for secure data isolation across companies using tenant IDs and Snowflake row access policies"
related_docs:
  - "../edp-layer-architecture-detailed.md"
  - "../edp_platform_architecture.md"
related_business_rules: []
---

# Multi-Tenancy Architecture Pattern

## Executive Summary 🎯
*Audience: Executives, Directors, Business Stakeholders (2-3 min read)*

**Purpose**: Enable the EDP to securely host data from multiple companies (tenants) in a shared platform while maintaining strict data isolation and security controls.

**Business Value**:
- **Cost Efficiency**: Shared infrastructure reduces per-tenant operational costs
- **Scalability**: Onboard new companies/datasets without architectural changes
- **Security Compliance**: Row-level security ensures tenants only access their authorized data
- **Governance**: Centralized data governance with tenant-specific access controls

**Key Decisions**:
- Implement tenant ID column across all EDP layers (raw, integration, curation, consumption)
- Use Snowflake row access policies for automated security enforcement
- Data governance team controls tenant assignment and approval workflow
- Support multiple tenant IDs per company when security segmentation is required (e.g., BCI general vs. BCI Group 4 restricted)

**Investment**:
- Data governance workflow implementation (tooling: Snowflake UI + automated scripts)
- Tenant ID backfill for existing data in integration/curation/consumption layers
- Future: Raw layer tenant ID assignment (under discussion)
- Tenant crosswalk tables and row access policy development

---

## Analytical Overview 📊
*Audience: Business Analysts, Project Managers, Product Owners (5-7 min read)*

**Functional Capabilities**:
- **Tenant Isolation**: Data from different companies is logically separated using tenant IDs
- **Public Reference Data**: Industry-standard code sets and non-sensitive reference data (tenant_id = 0, TBD) accessible to all tenants
- **Granular Access Control**: Companies can have multiple tenant IDs for internal data segmentation (e.g., restricted employee data)
- **Automated Security Enforcement**: Snowflake row access policies automatically filter data based on user roles and tenant assignments
- **Data Governance Integration**: New data is reviewed and approved before becoming accessible to tenant users
- **Flexible Onboarding**: Adding new companies/datasets creates new tenant IDs without platform changes

**Data Requirements**:
- **Tenant ID Column**: Present in all tables across raw, integration, curation, and consumption layers
- **Tenant Metadata Table**: Describes each tenant ID, associated company, access level, and security requirements (to be created)
- **Tenant Assignment Crosswalks**: Domain-specific logic for assigning tenant IDs to rows (e.g., membership crosswalk for BCI Group 4 identification)
- **Row Access Policies**: Snowflake policies mapping roles to authorized tenant IDs

**Process Integration**:
1. **Data Ingestion**: New data enters raw layer → marked "not approved" → accessible only to data governance roles
2. **Governance Review**: Data governance team reviews new datasets, tags sensitive columns, creates tenant assignment rules
3. **Tenant Assignment**: Crosswalk tables or business logic assign tenant IDs to rows
4. **Access Policy Creation**: Row access policies grant role-based access to specific tenant IDs
5. **Data Propagation**: Tenant IDs flow from raw → integration → curation → consumption layers
6. **User Access**: End users query data, row access policies automatically filter to their authorized tenants

**Success Metrics**:
- Zero unauthorized cross-tenant data access incidents
- Tenant onboarding time (target: < 2 weeks from data arrival to user access)
- Data governance review SLA (to be defined based on complexity)
- Number of tenants supported on platform

**Stakeholder Impact**:
- **Data Governance Team**: Central authority for tenant assignment, approval workflow, row access policy management
- **Data Engineering Teams**: Implement tenant ID columns, maintain crosswalk tables, ensure propagation across layers
- **Security/Compliance**: Audit tenant access, validate row-level security effectiveness
- **Business Users**: Seamless access to authorized data, no visibility into other tenants' data

---

## Technical Architecture ⚙️
*Audience: Data Engineers, Architects, Technical Leads (15-30 min read)*

### Architecture Principles

1. **Defense in Depth**: Multiple layers of security (tenant ID assignment + row access policies + role-based access control)
2. **Fail-Safe Defaults**: New data defaults to "not approved" accessible only to data governance
3. **Separation of Duties**: Data governance controls tenant assignment; platform enforces via automated policies
4. **Data Lineage Integrity**: Tenant ID propagates immutably through all layers once assigned
5. **Scalability**: Pattern supports unlimited tenants without architectural changes

### Component Design

#### 1. Tenant ID Column Standard

**Implementation Across Layers**:

```sql
-- Standard tenant_id column in all tables (integer for performance)
tenant_id INTEGER NOT NULL
```

**Current State**:
- ✅ **Integration Layer**: Tenant ID present in all Data Vault hubs, links, satellites
- ✅ **Curation Layer**: Tenant ID present in Business Vault and dimensional models
- ✅ **Consumption Layer**: Tenant ID present in all consumption tables
- 🚧 **Raw Layer**: Tenant ID assignment under discussion (future enhancement)

**Design Notes**:
- Tenant ID is **integer** for optimal query performance and storage efficiency
- Tenant ID is **non-nullable** to ensure all rows have explicit tenant assignment
- Tenant ID is **immutable** once assigned (changes require explicit data governance approval)
- Tenant ID is a **surrogate key** resolved through the tenant registry table to descriptive names
- **Public Tenant** (tenant_id = 0, TBD): Used for non-sensitive, industry-standard reference data (e.g., code sets, descriptions) accessible to all tenants

#### 2. Tenant Metadata & Resolution

**Public Tenant (tenant_id = 0) - TBD**:

The public tenant concept is under consideration for industry-standard reference data that is non-sensitive and universally accessible. Examples include:
- **Standard Code Sets**: ICD-10 diagnosis codes, CPT procedure codes, NDC drug codes
- **Industry Descriptions**: Standard medical terminology, drug classifications
- **Public Reference Tables**: State codes, country codes, standard date dimensions

**Characteristics**:
- **No Security Restrictions**: Accessible to all users regardless of role or tenant affiliation
- **Non-Proprietary**: Data that could be obtained from public sources
- **Shared Resource**: Reduces data duplication across tenants (single instance of ICD-10 codes)
- **Data Governance Oversight**: Still reviewed by data governance to confirm public classification

**Note**: The public tenant concept (tenant_id = 0) is to be determined (TBD) and may be formalized in future phases.

---

**Tenant Metadata Table** (to be created):

```sql
-- Note: Schema may be edp_metadata or data governance schema (TBD)
CREATE TABLE edp_metadata.tenant_registry (
    tenant_id INTEGER PRIMARY KEY,
    tenant_name VARCHAR(200) NOT NULL,
    company_code VARCHAR(10) NOT NULL,
    security_level VARCHAR(50), -- e.g., 'NORMAL', 'RESTRICTED', 'GROUP4'
    description TEXT, -- Details on BCI normal membership, BCI Group 4 membership, etc.
    data_classification VARCHAR(50), -- e.g., 'PUBLIC', 'INTERNAL', 'CONFIDENTIAL', 'RESTRICTED'
    created_date TIMESTAMP_NTZ NOT NULL,
    created_by VARCHAR(100) NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    UNIQUE (tenant_name, security_level) -- Natural key: combination is unique
);

-- Example entries
-- tenant_id: 0, tenant_name: 'Public', security_level: 'PUBLIC', description: 'Industry-standard code sets and reference data accessible to all tenants (TBD)'
-- tenant_id: 1, tenant_name: 'Blue Cross Idaho', security_level: 'NORMAL', description: 'BCI general membership data'
-- tenant_id: 2, tenant_name: 'Blue Cross Idaho', security_level: 'GROUP4', description: 'BCI Group 4 restricted employee data'
-- tenant_id: 3, tenant_name: 'Acme Corp', security_level: 'NORMAL', description: 'Acme Corp general data'
```

**Tenant Assignment Crosswalk Tables** (domain-specific, to be created):

```sql
-- Example: Membership tenant assignment crosswalk (member-level)
-- Note: Crosswalks can be at group, subscriber/policy, or member level
CREATE TABLE edp_curation.membership_tenant_crosswalk (
    member_id VARCHAR(50) PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    assignment_reason VARCHAR(200), -- e.g., 'BCI employee (Group 4)'
    effective_date DATE NOT NULL,
    end_date DATE,
    created_date TIMESTAMP_NTZ NOT NULL,
    FOREIGN KEY (tenant_id) REFERENCES edp_metadata.tenant_registry(tenant_id)
);

-- Alternative: Group-level crosswalk
CREATE TABLE edp_curation.group_tenant_crosswalk (
    group_id VARCHAR(50) PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    assignment_reason VARCHAR(200),
    effective_date DATE NOT NULL,
    end_date DATE,
    created_date TIMESTAMP_NTZ NOT NULL
);

-- Alternative: Subscriber/Policy-level crosswalk
CREATE TABLE edp_curation.subscriber_tenant_crosswalk (
    subscriber_id VARCHAR(50) PRIMARY KEY,
    tenant_id INTEGER NOT NULL,
    assignment_reason VARCHAR(200),
    effective_date DATE NOT NULL,
    end_date DATE,
    created_date TIMESTAMP_NTZ NOT NULL
);

-- Business logic example for BCI:
-- IF member is BCI employee in Group 4 → tenant_id = 2 (BCI Group 4)
-- ELSE IF member is BCI member → tenant_id = 1 (BCI Normal)
-- ELSE IF member is from other company → tenant_id = {company_specific_id}

-- Note: New tenants may have their own security stratification rules
-- not necessarily member-based, but member-level is primary for HIPAA/sensitivity
```

#### 3. Row Access Policy Architecture

**Snowflake Row Access Policies**:

Row access policies are created and managed by the data governance team. These policies enforce tenant isolation by filtering rows based on the user's role and the table's tenant_id column.

**Generic Example** (illustrative only - actual policies owned by data governance):

```sql
-- Generic pattern: Row Access Policy for tables with tenant_id
CREATE OR REPLACE ROW ACCESS POLICY edp_security.{domain}_tenant_access
AS (tenant_id INTEGER) RETURNS BOOLEAN ->
    CASE
        -- Public tenant (0) is accessible to all users (TBD)
        WHEN tenant_id = 0 THEN TRUE

        -- Data governance roles see everything
        WHEN CURRENT_ROLE() IN ('DATA_GOVERNANCE_ADMIN', 'DATA_GOVERNANCE_ANALYST')
            THEN TRUE

        -- Tenant-specific access roles (managed by data governance)
        WHEN CURRENT_ROLE() = '{TENANT_ACCESS_ROLE}'
            AND tenant_id IN ({AUTHORIZED_TENANT_IDS})
            THEN TRUE

        -- Deny all other combinations
        ELSE FALSE
    END;

-- Apply policy to table
ALTER TABLE {schema}.{table_name}
    ADD ROW ACCESS POLICY edp_security.{domain}_tenant_access ON (tenant_id);
```

**Policy Management**:
- **Ownership**: Data governance team creates, maintains, and updates all row access policies
- **Tooling**: Snowflake UI and automated scripts for policy creation and deployment
- **Application**: Policies applied to all tables with tenant_id column
- **Maintenance**: Policies updated when new tenants onboard or access requirements change
- **Validation**: Regular audits to ensure policies align with security requirements

**Note**: Specific policy implementations are managed by data governance and not documented in public architecture documentation for security reasons.

#### 4. Data Governance Workflow

**Phase 1: New Data Arrival (Raw Layer - Future State)**

```
New Data Arrives
    ↓
Raw Layer Ingestion
    ↓
tenant_id = -1  -- PENDING_APPROVAL (or designated pending ID)
approval_status = 'NOT_APPROVED'
    ↓
Row Access Policy: Only DATA_GOVERNANCE roles can see
```

**Phase 2: Data Governance Review**

```
Data Governance Team Reviews Dataset
    ↓
1. Tag Sensitive Columns (data masking tags)
2. Identify Tenant Assignment Logic
    - Single tenant? (e.g., new company dataset)
    - Multiple tenants? (e.g., requires crosswalk for segmentation)
3. Create/Update Tenant Crosswalk Table (if needed)
4. Create/Update Row Access Policies
5. Mark Data as 'APPROVED'
```

**Phase 3: Tenant ID Assignment & Propagation**

```
Integration Layer Processing
    ↓
Apply Tenant Assignment Logic
    - Lookup crosswalk table
    - Apply business rules
    - Assign tenant_id
    ↓
Tenant ID propagates to:
    - Curation Layer (Business Vault, Dimensional Models)
    - Consumption Layer (Reporting Tables)
```

**Phase 4: User Access**

```
User Queries Data
    ↓
Row Access Policy Evaluates:
    - User's Current Role
    - Table's tenant_id Column
    ↓
Returns Only Authorized Rows
```

### Data Models

#### Tenant ID in Data Vault 2.0 (Integration Layer)

**Hubs**:
```sql
-- All hubs include tenant_id
CREATE TABLE edp_integration.hub_member (
    member_hk BINARY(16) PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    tenant_id INTEGER NOT NULL, -- e.g., 1 (BCI Normal), 2 (BCI Group 4)
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(200) NOT NULL
);
```

**Links**:
```sql
-- Links inherit tenant_id from related hubs
CREATE TABLE edp_integration.link_member_group (
    member_group_hk BINARY(16) PRIMARY KEY,
    member_hk BINARY(16) NOT NULL,
    group_hk BINARY(16) NOT NULL,
    tenant_id INTEGER NOT NULL, -- Derived from member_hk
    load_date TIMESTAMP_NTZ NOT NULL,
    record_source VARCHAR(200) NOT NULL
);
```

**Satellites**:
```sql
-- Satellites inherit tenant_id from parent hub
CREATE TABLE edp_integration.sat_member_details (
    member_hk BINARY(16) NOT NULL,
    load_date TIMESTAMP_NTZ NOT NULL,
    tenant_id INTEGER NOT NULL, -- Inherited from hub_member
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    -- ... other attributes
    PRIMARY KEY (member_hk, load_date)
);
```

#### Tenant ID in Dimensional Models (Curation Layer)

```sql
-- Dimensions include tenant_id
CREATE TABLE edp_curation.dim_member (
    member_dim_key NUMBER(38,0) PRIMARY KEY,
    member_id VARCHAR(50) NOT NULL,
    tenant_id INTEGER NOT NULL, -- e.g., 1 (BCI Normal), 2 (BCI Group 4)
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    -- ... dimension attributes
    effective_date DATE NOT NULL,
    expiration_date DATE NOT NULL,
    current_flag BOOLEAN NOT NULL
);

-- Facts include tenant_id (derived from dimension lookups)
CREATE TABLE edp_curation.fact_claims (
    claim_fact_key NUMBER(38,0) PRIMARY KEY,
    member_dim_key NUMBER(38,0) NOT NULL,
    provider_dim_key NUMBER(38,0) NOT NULL,
    tenant_id INTEGER NOT NULL, -- Derived from member or claim source
    claim_amount NUMBER(18,2),
    paid_amount NUMBER(18,2),
    -- ... fact measures
    FOREIGN KEY (member_dim_key) REFERENCES edp_curation.dim_member(member_dim_key)
);
```

### Integration Points

**Data Governance Tooling**:
- **Snowflake UI**: Manual column tagging, policy creation, tenant metadata management
- **Automated Scripts**: Batch tenant assignment, crosswalk table population, policy deployment
- **Future Consideration**: Self-service portal for data governance workflow automation

**Cross-Layer Data Flow**:
```
Raw Layer (Future)
    ↓ [Tenant ID Assignment via Crosswalk/Rules]
Integration Layer (Data Vault)
    ↓ [Tenant ID Propagation via Joins]
Curation Layer (Business Vault + Dimensional Models)
    ↓ [Tenant ID Inheritance]
Consumption Layer (Reporting Tables)
```

**External Systems**:
- **Source Systems**: Must provide company/tenant identification metadata to support assignment logic
- **BI Tools**: Query consumption layer, row access policies transparently filter results
- **Data Extracts**: Tenant ID included in extract files for downstream consumers

### Performance & Scalability

**Indexing Strategy**:
```sql
-- Create search optimization on tenant_id for performance
ALTER TABLE edp_consumption.dim_member
    ADD SEARCH OPTIMIZATION ON EQUALITY(tenant_id);

-- Cluster tables by tenant_id for large fact tables
ALTER TABLE edp_curation.fact_claims
    CLUSTER BY (tenant_id, claim_date);
```

**Scalability Considerations**:
- **Tenant Proliferation**: Design supports unlimited tenant IDs (no hardcoded limits)
- **Row Access Policy Complexity**: Monitor policy evaluation performance as tenant count grows
- **Crosswalk Table Growth**: Partition large crosswalk tables by tenant or date range
- **Query Performance**: Tenant ID filtering benefits from clustering and search optimization

**Capacity Planning**:
- **Current**: 1-2 primary tenants (BCI with 2 security levels)
- **Near-term**: 5-10 tenants expected within 12 months
- **Long-term**: 50+ tenants possible as platform scales

### Security & Compliance

**Security Controls**:
1. **Row-Level Security**: Snowflake row access policies enforce tenant isolation at query time
2. **Column-Level Security**: Data masking tags applied to sensitive columns per tenant requirements
3. **Role-Based Access Control (RBAC)**: Roles mapped to tenant access via row access policies
4. **Audit Logging**: Query history tracks which users accessed which tenant data

**Compliance Requirements**:
- **Data Residency**: All tenant data stored in US-based Snowflake region
- **HIPAA Compliance**: PHI data tagged and masked per HIPAA requirements (applies to healthcare tenants)
- **Access Auditing**: 90-day retention of query access logs for compliance reporting
- **Data Governance Approval**: All new data reviewed and approved before user access

**Security Testing**:
- **Cross-Tenant Access Tests**: Verify users cannot see other tenants' data
- **Policy Validation**: Automated tests ensure row access policies correctly filter by tenant
- **Penetration Testing**: Annual third-party security assessment of multi-tenancy controls

### Operational Considerations

**Monitoring**:
- **Tenant Onboarding Progress**: Track time from data arrival → governance approval → user access
- **Row Access Policy Performance**: Monitor query execution time impact of policy evaluation
- **Data Governance Queue**: Alert when pending approvals exceed SLA (SLA to be defined)
- **Tenant Data Volume**: Track row counts and storage per tenant for capacity planning

**Alerting**:
- **Policy Failures**: Alert when row access policy creation/application fails
- **Crosswalk Gaps**: Alert when tenant assignment logic finds unassigned rows
- **Governance SLA**: Alert when pending approvals exceed defined timeframe

**Support Procedures**:
- **New Tenant Onboarding**: Standard operating procedure for adding new tenant IDs
- **Tenant Access Troubleshooting**: Runbook for resolving user access issues
- **Policy Updates**: Change management process for row access policy modifications
- **Data Governance Escalation**: Process for complex tenant assignment scenarios

**Backup & Recovery**:
- **Tenant Metadata**: Daily backups of tenant registry and crosswalk tables
- **Row Access Policies**: Version-controlled policy definitions in Git repository
- **Tenant Isolation in Recovery**: Restore operations maintain tenant data separation

---

## Implementation Specifications 🔧
*Audience: Implementation Teams (Reference material)*

### Current Implementation Status

**Completed**:
- ✅ Tenant ID column added to integration, curation, and consumption layers
- ✅ Row access policy framework designed
- ✅ Initial tenant IDs defined (0: Public [TBD], 1: BCI Normal, 2: BCI Group 4)

**In Progress**:
- 🚧 Tenant metadata table creation
- 🚧 Tenant assignment crosswalk tables (membership example underway)
- 🚧 Row access policy deployment to production tables
- 🚧 Data governance workflow tooling (Snowflake UI + scripts)

**Planned (Future Enhancements)**:
- 📋 Raw layer tenant ID assignment workflow
- 📋 Automated tenant ID propagation validation
- 📋 Self-service data governance portal
- 📋 Tenant-specific data retention policies

### Detailed Configuration

**Tenant ID Convention**:
```
Integer surrogate keys with descriptive resolution via tenant_registry

Examples:
- 0  -- Public (Industry-standard reference data, accessible to all) [TBD]
- 1  -- BCI Normal (Blue Cross Idaho - general membership)
- 2  -- BCI Group 4 (Blue Cross Idaho - employee restricted data)
- 3  -- Acme Corp Normal (Acme Corp - general data)
- 4  -- Acme Corp Executive (Acme Corp - executive restricted data)
```

**Data Governance Role Hierarchy**:
```sql
-- Data Governance Roles (Full Access)
CREATE ROLE DATA_GOVERNANCE_ADMIN;
CREATE ROLE DATA_GOVERNANCE_ANALYST;

-- Tenant-Specific Access Roles
CREATE ROLE BCI_NORMAL_ACCESS;
CREATE ROLE BCI_RESTRICTED_ACCESS; -- Includes both NORMAL and GROUP4
CREATE ROLE ACME_ACCESS;

-- Grant hierarchy
GRANT ROLE DATA_GOVERNANCE_ANALYST TO ROLE DATA_GOVERNANCE_ADMIN;
GRANT ROLE BCI_NORMAL_ACCESS TO ROLE BCI_RESTRICTED_ACCESS;
```

### Code Patterns & Examples

**Pattern 1: Tenant Assignment in Integration Layer (ELT Process)**:
```sql
-- Example: Assigning tenant_id during raw → integration vault load
INSERT INTO edp_integration.hub_member (
    member_hk,
    member_id,
    tenant_id,
    load_date,
    record_source
)
SELECT
    MD5(CONCAT(r.member_id, r.source_system)),
    r.member_id,
    CASE
        -- Lookup crosswalk if exists
        WHEN c.tenant_id IS NOT NULL THEN c.tenant_id

        -- Default logic if no crosswalk entry
        WHEN r.source_system = 'BCI_ENROLLMENT' AND r.is_employee = TRUE AND r.group_number = '4'
            THEN 2  -- BCI Group 4
        WHEN r.source_system = 'BCI_ENROLLMENT'
            THEN 1  -- BCI Normal
        WHEN r.source_system = 'ACME_ENROLLMENT'
            THEN 3  -- Acme Corp Normal

        -- Fallback: -1 for PENDING_APPROVAL (manual governance review)
        ELSE -1
    END AS tenant_id,
    CURRENT_TIMESTAMP(),
    r.source_system
FROM edp_raw.member_enrollment r
LEFT JOIN edp_metadata.membership_tenant_crosswalk c
    ON r.member_id = c.member_id
WHERE r.load_date >= :LAST_LOAD_DATE;
```

**Pattern 2: Row Access Policy Template**:
```sql
-- Generic template for creating tenant-specific row access policies
-- Note: Actual policies owned and managed by data governance team
CREATE OR REPLACE ROW ACCESS POLICY edp_security.{DOMAIN}_tenant_access
AS (tenant_id INTEGER) RETURNS BOOLEAN ->
    CASE
        -- Data governance full access
        WHEN CURRENT_ROLE() IN ('DATA_GOVERNANCE_ADMIN', 'DATA_GOVERNANCE_ANALYST')
            THEN TRUE

        -- Tenant-specific roles (add entries per tenant)
        WHEN CURRENT_ROLE() = '{TENANT_ROLE}'
            AND tenant_id IN (1, 2, 3)  -- Authorized tenant IDs
            THEN TRUE

        -- Deny all others
        ELSE FALSE
    END;
```

**Pattern 3: Tenant ID Propagation Validation**:
```sql
-- Validation query: Ensure tenant_id propagates consistently across layers
WITH integration_tenant_counts AS (
    SELECT tenant_id, COUNT(*) AS row_count
    FROM edp_integration.hub_member
    GROUP BY tenant_id
),
curation_tenant_counts AS (
    SELECT tenant_id, COUNT(*) AS row_count
    FROM edp_curation.dim_member
    WHERE current_flag = TRUE
    GROUP BY tenant_id
),
consumption_tenant_counts AS (
    SELECT tenant_id, COUNT(*) AS row_count
    FROM edp_consumption.rpt_member_summary
    GROUP BY tenant_id
)
SELECT
    COALESCE(i.tenant_id, c.tenant_id, con.tenant_id) AS tenant_id,
    i.row_count AS integration_rows,
    c.row_count AS curation_rows,
    con.row_count AS consumption_rows,
    CASE
        WHEN i.row_count = c.row_count AND c.row_count = con.row_count THEN 'OK'
        ELSE 'MISMATCH - INVESTIGATE'
    END AS validation_status
FROM integration_tenant_counts i
FULL OUTER JOIN curation_tenant_counts c ON i.tenant_id = c.tenant_id
FULL OUTER JOIN consumption_tenant_counts con ON i.tenant_id = con.tenant_id
ORDER BY tenant_id;
```

### Testing Requirements

**Unit Tests**:
- [ ] Tenant assignment logic correctly identifies tenant_id for known scenarios
- [ ] Crosswalk table lookups return expected tenant_id
- [ ] Row access policies deny access when role doesn't match tenant
- [ ] Row access policies allow access when role matches tenant

**Integration Tests**:
- [ ] Tenant ID propagates from integration → curation → consumption layers
- [ ] Row access policies apply correctly to all tables with tenant_id
- [ ] User queries return only rows matching their authorized tenant(s)

**Security Tests**:
- [ ] Users with BCI_NORMAL_ACCESS cannot see tenant_id = 2 (BCI Group 4) data
- [ ] Users with BCI_RESTRICTED_ACCESS can see both tenant_id = 1 (BCI Normal) and tenant_id = 2 (BCI Group 4) data
- [ ] Users with ACME_ACCESS cannot see BCI data (tenant_id 1 or 2)
- [ ] Data governance roles can see all tenant data

**Performance Tests**:
- [ ] Row access policy evaluation does not degrade query performance beyond acceptable thresholds
- [ ] Clustering by tenant_id improves query performance for single-tenant queries
- [ ] Search optimization on tenant_id improves filter performance

### Deployment Procedures

**Phase 1: Tenant Metadata Setup**
1. Create `edp_metadata.tenant_registry` table (or data governance schema - TBD)
2. Populate with initial tenant definitions (0: Public [TBD], 1: BCI Normal, 2: BCI Group 4)
3. Create domain-specific crosswalk tables (start with membership at member-level; consider group and subscriber levels)
4. Validate crosswalk logic with sample data

**Phase 2: Row Access Policy Deployment**
1. Create row access policies for each domain (membership, claims, provider, etc.)
2. Test policies in development environment
3. Apply policies to tables in development
4. Validate user access via test queries
5. Promote policies to production (off-hours deployment)
6. Monitor for access issues post-deployment

**Phase 3: Data Governance Workflow**
1. Train data governance team on tenant assignment process
2. Implement Snowflake UI workflows for column tagging and policy creation
3. Develop automated scripts for batch tenant assignment
4. Define SLA for new data approval (to be determined based on complexity)
5. Establish escalation process for complex scenarios

**Phase 4: Raw Layer Integration (Future)**
1. Design tenant assignment workflow for raw layer
2. Implement tenant_id = -1 (PENDING_APPROVAL) default status
3. Integrate with data governance review process
4. Test with pilot dataset
5. Rollout to all raw layer ingestion pipelines

**Rollback Procedures**:
- Remove row access policies from tables (restores full access to all roles)
- Revert to previous policy version if policy update causes issues
- Maintain backup of tenant metadata and crosswalk tables for restore

---

## Open Questions & Future Considerations

### Open Questions

1. **Data Governance SLA**: What is the acceptable timeframe for data governance to review and approve new datasets?
   - *Depends on dataset complexity and crosswalk requirements*
   - *Need to establish baseline and refine based on actual performance*

2. **Raw Layer Tenant Assignment**: When will raw layer tenant ID assignment be implemented?
   - *Currently under discussion*
   - *Benefits: Earlier security enforcement, simpler downstream logic*
   - *Challenges: Requires crosswalk/rules at ingestion time*

3. **Multi-Tenant Fact Tables**: How should tenant_id be assigned when facts span multiple tenants (e.g., claims involving members from different tenants)?
   - *Likely: Use primary entity's tenant (e.g., claim inherits member's tenant)*
   - *Edge cases require business rules documentation*

4. **Tenant Metadata Ownership**: Who maintains the tenant registry and crosswalk tables long-term?
   - *Data governance team is likely owner*
   - *Need clear RACI for updates and audits*

### Future Enhancements

**Self-Service Data Governance Portal**:
- Web UI for data governance team to manage tenant assignments
- Automated tenant ID suggestion based on source system metadata
- Approval workflow with notifications and audit trail

**Dynamic Tenant Assignment**:
- Real-time tenant resolution using external APIs (e.g., query CRM for company tenant)
- Machine learning for tenant classification based on data patterns

**Tenant-Specific Data Retention**:
- Extend pattern to support different retention policies per tenant
- Automated archival/deletion based on tenant data retention requirements

**Tenant Analytics**:
- Dashboard showing data volume, query activity, and costs per tenant
- Chargeback model for multi-tenant cost allocation

**Global Multi-Region Support**:
- Extend pattern for tenants with data residency requirements in different Snowflake regions
- Cross-region tenant metadata synchronization

---

## Related Documentation

**Architecture**:
- [EDP Layer Architecture Detailed](../edp-layer-architecture-detailed.md) - Medallion architecture layers
- [EDP Platform Architecture](../edp_platform_architecture.md) - Overall platform design

**Security**:
- *Row Access Policy Standards* (to be created)
- *Data Masking and Classification Guide* (to be created)

**Business Rules** (Future):
- *Tenant Assignment Business Rules* (will be created when clearer examples are available)

---

*Document Status: In Progress - Architecture defined, implementation underway*
*Last Updated: 2025-10-16 by Dan Brickey*
*Version: 1.2 - Added public tenant concept (tenant_id = 0, TBD) for industry-standard reference data accessible to all tenants*
*Version: 1.1 - Updated with integer tenant_id, enhanced crosswalk options, simplified row access policy section per architectural review*
