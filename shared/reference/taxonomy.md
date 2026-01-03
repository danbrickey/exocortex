---
title: "EDP Documentation Taxonomy"
author: "AI Expert Team Cabinet"
last_updated: "2025-10-16T10:30:00Z"
version: "1.0.0"
document_type: "taxonomy"
status: "active"
audience: ["all"]
description: "Controlled vocabulary and semantic tags for EDP documentation classification and discovery"
---

# EDP Documentation Taxonomy

> **Purpose**: Provides a controlled vocabulary of semantic tags for classifying and discovering EDP documentation. Use these standardized terms in document frontmatter to enable precise AI-powered search and navigation.

**Maintenance**: Review quarterly, update as new domains/topics emerge

---

## Business Domains

Use these tags to classify documentation by healthcare payer business domain:

| Tag | Description | Example Use Cases |
|-----|-------------|-------------------|
| `broker` | Producer/broker information, commission rules, agency management | Commission calculations, broker hierarchies |
| `claims` | Claims processing, adjudication, payment, appeals | Claim status workflows, COB rules, adjudication logic |
| `financial` | Premium billing, payment processing, accounting, general ledger | Billing cycles, payment application, premium calculations |
| `membership` | Member enrollment, eligibility, coverage determination | Enrollment rules, eligibility verification, coverage periods |
| `network` | Provider networks, contracting, credentialing | Network adequacy, provider directories, contract management |
| `product` | Plan designs, benefit structures, product configuration | Benefit packages, plan riders, product hierarchies |
| `provider` | Provider data, reimbursement, fee schedules | Provider taxonomies, fee schedule management, reimbursement rules |
| `regulatory` | Compliance, reporting, regulatory requirements | CMS reporting, state mandates, audit requirements |
| `utilization` | Care management, utilization review, case management | Pre-authorization, concurrent review, care coordination |

---

## EDP Architecture Layers

Use these tags to indicate which layer(s) of the EDP medallion architecture the documentation applies to:

| Tag | Description | Technologies | Example Use Cases |
|-----|-------------|--------------|-------------------|
| `raw` | Source system data ingestion, CDC patterns | MSK Kafka, Fivetran, AWS DMS | Source system connections, CDC patterns, landing zone |
| `integration` | Data Vault 2.0 integration layer, historization | Snowflake, dbt, Data Vault 2.0 | Hub/Link/Satellite modeling, business keys, temporal tracking |
| `curation` | Business Vault, master data, calculated fields | Snowflake, dbt, MDM patterns | Point-in-time tables, bridge tables, master data, business rules |
| `consumption` | Dimensional models, analytics marts, reporting | Snowflake, dbt, Kimball methodology | Star schemas, dimensional models, aggregates, reporting views |
| `cross-layer` | Platform-wide concerns spanning multiple layers | Snowflake, AWS, monitoring | Security, performance, monitoring, platform architecture |

---

## Technical Topics

Use these tags to classify documentation by technical subject matter:

### Data Architecture & Modeling
| Tag | Description |
|-----|-------------|
| `data-vault-2.0` | Data Vault 2.0 modeling patterns, hub/link/satellite design |
| `dimensional-modeling` | Kimball star schemas, facts, dimensions, slowly changing dimensions |
| `master-data-management` | MDM strategies, golden records, entity resolution |
| `data-quality` | Data quality rules, validation, profiling, monitoring |
| `historization` | Temporal tracking, SCD patterns, audit trails |

### Integration & Data Movement
| Tag | Description |
|-----|-------------|
| `cdc` | Change data capture patterns and technologies |
| `batch-processing` | Batch data pipelines, scheduled jobs |
| `real-time` | Real-time streaming, near-real-time processing |
| `data-pipelines` | ETL/ELT pipelines, orchestration, workflows |
| `api-integration` | REST APIs, API gateways, service integration |

### Platform & Infrastructure
| Tag | Description |
|-----|-------------|
| `snowflake` | Snowflake platform features, warehouses, databases |
| `aws` | AWS services, infrastructure, cloud architecture |
| `dbt` | dbt transformations, models, testing, documentation |
| `kafka` | MSK, Kafka streaming, topics, producers, consumers |
| `terraform` | Infrastructure as code, provisioning |

### Security & Compliance
| Tag | Description |
|-----|-------------|
| `security` | Access control, authentication, authorization, encryption |
| `rbac` | Role-based access control, permissions, privilege management |
| `multi-tenant` | Multi-tenancy patterns, data segregation, tenant isolation |
| `pii-phi` | PII/PHI data protection, HIPAA compliance, data masking |
| `compliance` | Regulatory compliance, audit trails, controls |

### Performance & Operations
| Tag | Description |
|-----|-------------|
| `performance` | Query optimization, indexing, caching, tuning |
| `monitoring` | Observability, logging, alerting, metrics |
| `scalability` | Scaling patterns, capacity planning, elasticity |
| `cost-optimization` | Cost management, resource optimization |
| `disaster-recovery` | Backup, recovery, business continuity |

---

## Document Types

Use these tags to classify the type/purpose of the document:

| Tag | Description | Examples |
|-----|-------------|----------|
| `architecture` | System design, technical architecture, component interaction | Platform architecture, layer design, integration patterns |
| `business-rules` | Domain business logic, calculation rules, business processes | Claim adjudication rules, eligibility determination, COB logic |
| `specification` | Technical requirements, functional specs, acceptance criteria | Engineering specs, API specifications, data contracts |
| `pattern` | Reusable design patterns, best practices, templates | Hub design patterns, pipeline templates, modeling patterns |
| `guide` | Implementation how-to guides, tutorials, runbooks | Data Vault implementation guide, dbt setup guide |
| `reference` | Reference documentation, glossaries, terminology | Technology stack reference, terminology glossary |
| `standards` | Coding standards, naming conventions, policies | Naming conventions, code standards, documentation standards |
| `glossary` | Terms and definitions for a specific domain or technology | Healthcare terminology, Snowflake glossary, Data Vault terms |

---

## Audience Tags

Use these tags to indicate the intended audience(s):

| Tag | Description |
|-----|-------------|
| `executives` | C-level executives, senior leadership |
| `directors` | Directors, program managers, decision-makers |
| `architects` | Solution architects, enterprise architects, data architects |
| `engineers` | Data engineers, software engineers, developers |
| `analysts` | Business analysts, data analysts, BI developers |
| `product-owners` | Product owners, product managers |
| `stakeholders` | Business stakeholders, domain experts |
| `all` | Suitable for all audiences |

---

## Status Tags

Use these tags to indicate document lifecycle status:

| Tag | Description |
|-----|-------------|
| `draft` | Work in progress, not yet reviewed |
| `review` | Under review, pending approval |
| `active` | Approved, current, in use |
| `deprecated` | No longer current, superseded by newer documentation |
| `archived` | Historical record, reference only |

---

## Usage Guidelines

### In Document Frontmatter

```yaml
---
title: "Multi-Tenancy Architecture Pattern"
document_type: "pattern"
business_domain: ["membership", "claims", "provider"]
edp_layer: "integration"
technical_topics: ["data-vault-2.0", "multi-tenant", "security", "rbac", "performance"]
audience: ["architects", "engineers"]
status: "active"
---
```

### For AI Search Queries

When asking AI to find documentation:
- **Use taxonomy terms**: "Find architecture docs about claims domain in the integration layer"
- **Combine tags**: "Show me business-rules documentation for membership with multi-tenant patterns"
- **Be specific**: "Find guides about data-vault-2.0 historization for engineers"

### When Creating New Documents

1. **Select relevant tags** from each category (domain, layer, topics, type, audience)
2. **Use multiple tags** when appropriate (e.g., a document can cover multiple domains or topics)
3. **Be consistent**: Use exact tag names from this taxonomy
4. **Update taxonomy**: Propose new tags if existing ones don't fit (update this document)

---

## Cross-Reference to Documentation Standards

See [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) for the master catalog of all EDP documentation organized using this taxonomy.

---

**Next Review Date**: 2026-01-16

