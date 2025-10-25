---
title: "EDP Documentation Master Index"
author: "AI Expert Team Cabinet"
last_updated: "2025-10-24T18:00:00Z"
version: "2.0.0"
document_type: "index"
status: "active"
audience: ["all"]
description: "AI-navigable master catalog for locating documentation across the EDP project"
maintenance: "Update monthly (auto-generated sections) + manual updates for major additions"
changelog: "v2.0.0 - Reorganized with lowercase naming, new architecture/overview and architecture/layers folders"
---

# EDP Documentation Master Index

> **Purpose**: AI-navigable index for locating documentation across the EDP (Enterprise Data Platform) project
>
> **How to Use**:
> - Browse by intent ("I need to understand...")
> - Search by document type, business domain, or EDP layer
> - Follow cross-references to related documentation
>
> **Maintenance**: Auto-generated monthly + manual updates for major additions

---

## Quick Navigation by Intent

### "I need to understand the EDP platform architecture..."

**Start Here**:
- **Platform Overview**: [edp-platform-architecture.md](architecture/overview/edp-platform-architecture.md) - High-level EDP architecture, AWS + Snowflake integration, medallion architecture
- **Layer Architecture**: [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) - Detailed specifications for Raw, Integration, Curation, and Consumption layers
- **Patterns Library**: [patterns/](architecture/patterns/) - Reusable architecture patterns (multi-tenancy, security, performance)

**Related**:
- Technology stack and tools: [technology-stack-reference.md](engineering-knowledge-base/technology-stack-reference.md)
- Environment configuration: [environment-database-configuration.md](engineering-knowledge-base/environment-database-configuration.md)

---

### "I need to understand data ingestion and integration..."

**Start Here**:
- **Data Ingestion Architecture**: [data-ingestion-architecture.md](architecture/layers/data-ingestion-architecture.md) - CDC patterns, source system connections, MSK streaming
- **Near Real-Time Architecture**: [near-realtime-architecture.md](architecture/layers/near-realtime-architecture.md) - Real-time streaming patterns, Kafka/MSK integration

**Related**:
- Data Vault integration layer: [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) (Integration Layer section)
- Source system documentation: [sources/facets/](sources/facets/)

---

### "I need to understand Data Vault 2.0 modeling..."

**Start Here**:
- **Data Vault 2.0 Guide**: [data-vault-2.0-guide.md](engineering-knowledge-base/data-vault-2.0-guide.md) - Comprehensive implementation guide for DV2.0 patterns
- **Integration Layer Architecture**: [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) (Integration Layer section) - DV2.0 implementation in EDP

**Related**:
- Data Vault terminology: [data-vault-2.0-terminology.md](glossaries/data-vault-2.0-terminology.md)
- Hub/Link/Satellite patterns: [patterns/](architecture/patterns/)

---

### "I need to understand business rules for a domain..."

**Claims Domain**:
- *(Coming soon)* Claims adjudication rules, COB logic, payment processing

**Membership Domain**:
- *(Coming soon)* Enrollment eligibility, coverage determination, group/member relationships

**Provider Domain**:
- *(Coming soon)* Network management, reimbursement rules, credentialing

**Product Domain**:
- *(Coming soon)* Benefit structures, plan hierarchies, product configuration

> **Note**: Business rules documentation is being developed using the multi-audience format (executive, business, technical, implementation). Check [architecture/rules/](architecture/rules/) for latest additions.

---

### "I need implementation guidance or how-to guides..."

**Data Engineering**:
- **Data Vault Implementation**: [data-vault-2.0-guide.md](engineering-knowledge-base/data-vault-2.0-guide.md)
- **Environment Setup**: [environment-database-configuration.md](engineering-knowledge-base/environment-database-configuration.md)

**Technology References**:
- **Technology Stack**: [technology-stack-reference.md](engineering-knowledge-base/technology-stack-reference.md)
- **Snowflake Terminology**: [snowflake-terminology.md](glossaries/snowflake-terminology.md)
- **dbt Cloud Terminology**: [dbt-cloud-terminology.md](glossaries/dbt-cloud-terminology.md)
- **AWS Terminology**: [aws-terminology.md](glossaries/aws-terminology.md)

---

### "I need to understand source systems..."

**FACETS (Legacy & Gemstone)**:
- Source system overview: [sources/facets/README.md](sources/facets/README.md)
- FACETS entity documentation: [sources/facets/](sources/facets/)

**Other Source Systems**:
- VALENZ: *(Documentation coming)*
- Epic: *(Documentation coming)*
- Custom Applications: *(Documentation coming)*

---

### "I need terminology and glossaries..."

**Technology Glossaries**:
- [aws-terminology.md](glossaries/aws-terminology.md) - AWS services and concepts
- [dbt-cloud-terminology.md](glossaries/dbt-cloud-terminology.md) - dbt Cloud features and terminology
- [snowflake-terminology.md](glossaries/snowflake-terminology.md) - Snowflake platform terminology
- [sql-server-terminology.md](glossaries/sql-server-terminology.md) - SQL Server legacy system terms
- [data-vault-2.0-terminology.md](glossaries/data-vault-2.0-terminology.md) - Data Vault 2.0 concepts

**Domain Glossaries**:
- [healthcare-payer-terminology.md](glossaries/healthcare-payer-terminology.md) - Healthcare payer industry terms

---

## Index by Document Type

### Architecture Documentation

| Document | Layers | Topics | Audience | Last Updated |
|----------|--------|--------|----------|--------------|
| [edp-platform-architecture.md](architecture/overview/edp-platform-architecture.md) | Cross-layer | Platform, AWS, Snowflake, medallion architecture | Architects, Engineers, Directors | 2025-10-15 |
| [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) | All layers | Layer specifications, data flow, transformations | Architects, Engineers | 2025-10-15 |
| [data-ingestion-architecture.md](architecture/layers/data-ingestion-architecture.md) | Raw | CDC, source systems, MSK, ingestion patterns | Architects, Engineers | 2025-10-10 |
| [near-realtime-architecture.md](architecture/layers/near-realtime-architecture.md) | Raw, Integration | Real-time streaming, Kafka, event processing | Architects, Engineers | 2025-10-10 |
| [master-data-management-strategy.md](architecture/layers/master-data-management-strategy.md) | Curation | MDM, golden records, entity resolution | Architects, Engineers, Analysts | 2025-10-08 |
| [multi-tenancy-architecture.md](architecture/patterns/multi-tenancy-architecture.md) | Integration | Multi-tenant, security, RBAC, data segregation | Architects, Engineers | 2025-10-16 |

### Business Rules Documentation

| Domain | Document | Topics | Audience | Last Updated |
|--------|----------|--------|----------|--------------|
| *(Coming soon)* | Enrollment Eligibility Rules | Membership, eligibility, coverage | Business, Architects, Analysts | TBD |
| *(Coming soon)* | Claims Adjudication Rules | Claims, COB, payment, adjudication | Business, Architects, Analysts | TBD |
| *(Coming soon)* | Provider Reimbursement Rules | Provider, fee schedules, reimbursement | Business, Architects, Analysts | TBD |

> **Note**: Business rules docs use multi-audience format with Executive, Business, Technical, and Implementation sections. See [architecture/rules/README.md](architecture/rules/README.md) for template and standards.

### Implementation Guides

| Document | Topics | Technologies | Audience | Last Updated |
|----------|--------|--------------|----------|--------------|
| [data-vault-2.0-guide.md](engineering-knowledge-base/data-vault-2.0-guide.md) | Data Vault 2.0, hub/link/satellite, historization | Snowflake, dbt | Engineers, Architects | 2025-09-30 |
| [environment-database-configuration.md](engineering-knowledge-base/environment-database-configuration.md) | Environment setup, database config, RBAC | Snowflake | Engineers, Architects | 2025-09-28 |
| [technology-stack-reference.md](engineering-knowledge-base/technology-stack-reference.md) | Technology overview, tool selection | All EDP technologies | All audiences | 2025-09-25 |

### Reference & Glossaries

| Document | Domain/Technology | Audience | Last Updated |
|----------|-------------------|----------|--------------|
| [data-vault-2.0-terminology.md](glossaries/data-vault-2.0-terminology.md) | Data Vault 2.0 | All | 2025-09-30 |
| [healthcare-payer-terminology.md](glossaries/healthcare-payer-terminology.md) | Healthcare payer | All | 2025-09-28 |
| [snowflake-terminology.md](glossaries/snowflake-terminology.md) | Snowflake | Engineers, Architects | 2025-09-25 |
| [dbt-cloud-terminology.md](glossaries/dbt-cloud-terminology.md) | dbt Cloud | Engineers | 2025-09-25 |
| [aws-terminology.md](glossaries/aws-terminology.md) | AWS | Architects, Engineers | 2025-09-25 |
| [sql-server-terminology.md](glossaries/sql-server-terminology.md) | SQL Server (legacy) | Engineers | 2025-09-20 |

---

## Index by Business Domain

### Claims Domain
**Architecture**:
- *(Coming soon)* Claims processing pipeline architecture
- *(Coming soon)* Adjudication workflow design

**Business Rules**:
- *(Coming soon)* Claims adjudication logic
- *(Coming soon)* Coordination of benefits (COB) rules
- *(Coming soon)* Claim status transitions
- *(Coming soon)* Payment calculation rules

**Source Systems**:
- FACETS claims tables documentation: [sources/facets/](sources/facets/)

**Data Vault Entities**:
- *(Coming soon)* Claim hub, claim line link, adjudication satellites

---

### Membership Domain
**Architecture**:
- [multi-tenancy-architecture.md](architecture/patterns/multi-tenancy-architecture.md) - Multi-tenant member data segregation
- *(Coming soon)* Member enrollment pipeline

**Business Rules**:
- *(Coming soon)* Enrollment eligibility determination
- *(Coming soon)* Coverage period calculation
- *(Coming soon)* Group/member relationship rules

**Source Systems**:
- FACETS member tables: [sources/facets/](sources/facets/)

**Data Vault Entities**:
- *(Coming soon)* Person hub, member link, coverage satellites

---

### Provider Domain
**Architecture**:
- *(Coming soon)* Provider network architecture
- *(Coming soon)* Provider data integration patterns

**Business Rules**:
- *(Coming soon)* Network adequacy rules
- *(Coming soon)* Reimbursement calculation logic
- *(Coming soon)* Fee schedule application rules

**Source Systems**:
- FACETS provider tables: [sources/facets/](sources/facets/)

**Data Vault Entities**:
- *(Coming soon)* Provider hub, network relationship links

---

### Product Domain
**Architecture**:
- *(Coming soon)* Product configuration architecture
- *(Coming soon)* Benefit structure design

**Business Rules**:
- *(Coming soon)* Benefit package composition
- *(Coming soon)* Product hierarchy rules
- *(Coming soon)* Plan rider application logic

**Source Systems**:
- FACETS product/benefit tables: [sources/facets/](sources/facets/)

**Data Vault Entities**:
- *(Coming soon)* Product hub, benefit plan links, coverage detail satellites

---

### Financial Domain
**Architecture**:
- *(Coming soon)* Premium billing architecture
- *(Coming soon)* Payment processing pipeline

**Business Rules**:
- *(Coming soon)* Premium calculation rules
- *(Coming soon)* Billing cycle logic
- *(Coming soon)* Payment application rules

**Source Systems**:
- FACETS financial tables: [sources/facets/](sources/facets/)

**Data Vault Entities**:
- *(Coming soon)* Invoice hub, payment links, premium detail satellites

---

## Index by EDP Layer

### Raw Layer (Source Data Landing)
**Architecture**:
- [data-ingestion-architecture.md](architecture/layers/data-ingestion-architecture.md) - CDC patterns and ingestion
- [near-realtime-architecture.md](architecture/layers/near-realtime-architecture.md) - Real-time streaming
- [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) - Raw layer specifications

**Topics**: CDC, MSK Kafka, Fivetran, source system connections, landing zones

---

### Integration Layer (Data Vault 2.0)
**Architecture**:
- [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) - Integration layer specifications
- [multi-tenancy-architecture.md](architecture/patterns/multi-tenancy-architecture.md) - Multi-tenant patterns

**Implementation Guides**:
- [data-vault-2.0-guide.md](engineering-knowledge-base/data-vault-2.0-guide.md) - DV2.0 implementation guide

**Topics**: Hubs, Links, Satellites, business keys, historization, multi-tenancy

---

### Curation Layer (Business Vault & Master Data)
**Architecture**:
- [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) - Curation layer specifications
- [master-data-management-strategy.md](architecture/layers/master-data-management-strategy.md) - MDM strategy

**Topics**: Point-in-time tables, bridge tables, business rules, calculated fields, master data

---

### Consumption Layer (Dimensional Models & Analytics)
**Architecture**:
- [edp-layer-architecture-detailed.md](architecture/layers/edp-layer-architecture-detailed.md) - Consumption layer specifications

**Topics**: Star schemas, dimensional models, fact tables, aggregates, reporting views

---

## Cross-Reference Resources

### Documentation Standards
- **Taxonomy**: [taxonomy.md](taxonomy.md) - Controlled vocabulary for documentation classification
- **Architecture README**: [architecture/README.md](architecture/README.md) - Architecture documentation standards
- **Engineering KB README**: [engineering-knowledge-base/README.md](engineering-knowledge-base/README.md) - Implementation guide standards

### AI Resources
- **Architecture Prompts**: [ai-resources/prompts/documentation/architecture_documentation_architect.md](../ai-resources/prompts/documentation/architecture_documentation_architect.md)
- **Context Documents**: [ai-resources/context-documents/](../ai-resources/context-documents/)

### Project Overview
- **Main README**: [README.md](../README.md) - Project overview and repository structure
- **CLAUDE.md**: [CLAUDE.md](../CLAUDE.md) - Project context for AI assistants

---

## How to Use This Index with AI

### Finding Documentation by Intent
**Example prompts**:
- "Find architecture documentation about claims processing in the integration layer"
- "Show me business rules for membership eligibility"
- "Where can I find Data Vault implementation guides?"

### Following the Discovery Path
1. **Start broad**: Look in "Quick Navigation by Intent" section
2. **Drill down**: Follow links to specific documents
3. **Explore related**: Check "Related" links and cross-references
4. **Check taxonomy**: Use [taxonomy.md](taxonomy.md) for precise keyword searches

### Searching by Tags
Use taxonomy tags in AI queries:
```
Find documents tagged with:
- business_domain: "claims"
- edp_layer: "integration"
- technical_topics: ["data-vault-2.0", "multi-tenant"]
```

---

## Maintenance Notes

### Last Auto-Generated: *(Not yet automated)*
### Next Scheduled Update: 2025-11-16
### Manual Updates: Document additions, major restructuring

**To add a new document to this index**:
1. Ensure document has complete frontmatter with taxonomy tags (see [taxonomy.md](taxonomy.md))
2. Add entry to appropriate section(s) in this index
3. Update cross-references and related docs
4. Update "Last Updated" timestamp in this file

---

## Future Enhancements

- [ ] Auto-generation script for document catalog tables (Python)
- [ ] Monthly automated index refresh
- [ ] Document dependency graph visualization
- [ ] AI-powered document recommendation based on role/task
- [ ] Full-text search integration with taxonomy tags

---

**Questions or suggestions?** This index evolves with our documentation. Propose improvements as the doc set grows.

