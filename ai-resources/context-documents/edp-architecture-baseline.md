---
title: "EDP Architecture Baseline - Project Overview & Strategic Context"
author: "AI Expert Team Cabinet"
last_updated: "2024-12-09T17:30:00Z"
version: "1.0.0"
category: "project-context"
tags: ["architecture", "EDP", "strategic-overview", "medallion-architecture"]
status: "current"
audience: ["stakeholders", "technical-team", "leadership"]
---

# Enterprise Data Platform (EDP) Architecture Baseline
*Comprehensive Project Overview & Strategic Context*

---

## Executive Summary

The Enterprise Data Platform (EDP) represents a comprehensive data modernization initiative designed to transform our organization's analytical capabilities through cloud-native architecture. The project encompasses dual parallel migrations: refactoring existing cloud infrastructure to Data Vault 2.0 methodology and continuing the migration of legacy on-premises systems to the cloud platform.

**Key Strategic Objectives:**
- Establish EDP as the enterprise hub for all analytical and operational data needs
- Implement Data Vault 2.0 methodology for scalable, auditable data architecture
- Enable advanced analytics, machine learning, and self-service capabilities
- Modernize from legacy WhereScape/SQL Server to cloud-native Snowflake/dbt platform

---

## Project Background & Context

### Historical Context
- **Duration:** 7+ quarters with significant disruption in timeline, goals, priorities, team members, and contracting partners
- **Current Status:** Achieving consistent pace and using upcoming quarter for infrastructure reset and operational standardization
- **Strategic Catalyst:** Introduction of new business partner with Data Vault 2.0 expertise and leadership alignment on methodology

### Business Drivers
- **Operational Efficiency:** Consolidate analytical and operational use cases into unified platform
- **Advanced Analytics:** Enable sophisticated data science, machine learning, and AI exploration capabilities
- **Business Agility:** Provide self-service analytics and real-time data access for critical business functions
- **Regulatory Compliance:** Ensure robust data governance, auditability, and HIPAA compliance for healthcare data

---

## Architecture Overview

### Current State: Dual-Track Migration Challenge

#### Track 1: Existing Cloud Infrastructure (Built Last Year)
- **Technology:** 3NF methodology in Snowflake
- **Status:** Currently serving active business needs
- **Challenge:** Requires refactoring to Data Vault 2.0 standards
- **Strategy:** Build Data Vault layer in parallel, maintain business continuity through current views

#### Track 2: Legacy On-Premises Migration (Ongoing)
- **Source:** WhereScape on SQL Server 
- **Target:** Cloud-native Snowflake platform
- **Approach:** Various ingestion paths feeding into Snowflake
- **Timeline:** Parallel with Data Vault refactoring

### Target Architecture: Medallion with Data Vault 2.0

```
Raw Layer → Integration Layer → Curation Layer → Consumption Layer
```

#### Layer Descriptions

**Raw Layer (Bronze Equivalent)**
- Raw CDC data from source systems
- Snowflake shares and ingested files  
- Equivalent to data lake with change data capture

**Integration Layer (Silver Equivalent)**
- **Current:** 3NF methodology (to be refactored)
- **Target:** Data Vault 2.0 Raw Vault with Hubs, Links, and Satellites
- Modular, reusable, integrated format with light cleansing
- Standardized record identification keys across sources
- Current Views for backward compatibility during transition

**Curation Layer (Gold Equivalent)**
- Business Vault following Data Vault 2.0 methodology
- Kimball dimensional models for analytics
- Flattened datasets for ML and extracts
- Purpose-built 3NF models for operational applications

**Consumption Layer**
- Common access layer with fit-for-use data
- Data Vault Information Marts
- Constrained datasets with appropriate security controls

---

## Technology Stack

### Core Infrastructure
- **Cloud Platform:** AWS
- **Data Warehouse:** Snowflake
- **Data Architecture:** Data Vault 2.0 (transitioning from 3NF)
- **Transformation Tool:** dbt Platform (formerly dbt Cloud)
- **Data Vault Package:** automate_dv (datavault4dbt)
- **Visualization Tool:** Tableau Cloud
- **Data Quality Tool:** Anomalo
- **Data Governance:** Alation

### Source Systems
1. **Legacy FACETS** (legacy_facets)
   - HCDM Code: FACETS_LGC
   - Tenant ID: BCI

2. **Gemstone FACETS** (gemstone_facets)
   - HCDM Code: FACETS_GMS  
   - Tenant ID: BCI

3. **VALENZ** (valenz)
   - System Code: VALENZ

### Environment Configuration

| Environment | Integration DB   | Curation DB      | Consumption DB   | Common DB         |
|-------------|------------------|------------------|------------------|-------------------|
| dev         | developer_schema | developer_schema | developer_schema | developer_schema  |
| team_dev    | dev_int_db       | dev_cur_db       | dev_con_db       | dev_common_db     |
| preprod     | preprod_int_db   | preprod_cur_db   | preprod_con_db   | preprod_common_db |
| prod        | prod_int_db      | prod_cur_db      | prod_con_db      | prod_common_db    |

---

## Data Characteristics & Workload Patterns

### Data Volume Profile
- **Largest Table:** 20+ years of premium billing information
- **Volume:** 500-750 million rows
- **Growth Pattern:** Accumulated over 20 years, suggesting manageable annual growth
- **Overall Scale:** Fairly minimal volumes, well within Snowflake capabilities

### Workload Characteristics
- **Primary:** Analytical workloads
- **Secondary:** Data extracts and custom mini datasets
- **Operational:** Portal use cases and targeted applications
- **Emerging:** Real-time customer service requirements

### Data Latency Requirements
- **Standard:** Twice daily and daily batch loading
- **Real-time Requirement:** Customer service use cases requiring near real-time (minutes)
- **Solution Approach:** MSK streaming pipeline for transactional tables critical to customer service

---

## Stakeholder Landscape

### Engagement Spectrum: Bimodal Adoption Pattern

#### High-Engagement Stakeholders
**Healthcare Economics Department**
- **Profile:** Sophisticated analysts, data scientists, and actuaries
- **Characteristics:** Data-savvy, excited about cloud migration, eager to accelerate
- **Needs:** Advanced analytics, ML models, AI exploration, trend analysis
- **Strategic Value:** Early adopters, perfect for MVP testing and feedback

**Provider Team**
- **Focus:** Provider-related data and analytics
- **Key Initiative:** Provider 360 data model development
- **Needs:** Comprehensive provider analytics and business question answering

#### Medium-Engagement Stakeholders
**Internal IT Teams**
- **Role:** Building web portals and data extracts
- **Needs:** Reliable data APIs and extract capabilities
- **Impact:** Platform adoption and operational success

#### Low-Engagement Stakeholders
**General Business Units**
- **Attitude:** "Not interested until something is prepared for them"
- **Strategy:** Target for later phases with proven, polished solutions
- **Approach:** Success story driven adoption

---

## Team Readiness & Capability Assessment

### Data Engineering Team
**Strengths:**
- Some experience with Data Vault patterns
- Basic exposure to dbt
- Established testing practices with consistent recommended tests
- Relational integrity and key uniqueness testing

**Development Areas:**
- Limited dbt experience requiring training and knowledge transfer
- Business Vault implementation patterns (identified weakness)
- Business-level testing and data quality validation

### Infrastructure & Development Operations
**Current State:**
- dbt's built-in CI/CD capabilities in use
- GitLab for source code control (integration opportunity)
- Medium testing maturity with room for business rule expansion

**Opportunities:**
- Enhanced GitLab integration for dbt CI/CD
- Expanded business rule testing capabilities
- Advanced data quality frameworks

---

## Master Data Management Challenges

### Current Capabilities
**Member/Person Matching:**
- Rudimentary member matching process in place
- Person ID creation based on membership information across systems
- No master data management style gold member records

**Provider Matching:**
- Provider matching algorithm providing cross-system provider ID crosswalks
- No gold provider records or true MDM implementation
- Potential identity resolution challenges across multiple source systems

### Strategic Implications for Data Vault Design
- Composite business key strategies may be required
- Multiple satellites per source system for conflicting data management
- Bridge tables for uncertain provider-to-provider relationships
- Careful effectivity satellite design for temporal identity management



---

## Next Steps & Priorities

### Immediate Architecture Focus (Current Quarter)
1. **Infrastructure Reset:** Align team on standardized operating policies and procedures
2. **Architecture Design:** Develop comprehensive Data Vault 2.0 design for key subject areas
3. **Team Readiness:** Prepare documentation, training materials, and implementation frameworks
4. **Stakeholder Management:** Develop communication strategy and expectation management

### Implementation Readiness (January Preparation)
1. **Data Vault Models:** Complete hub, link, and satellite designs for priority domains
2. **dbt Project Structure:** Establish project architecture and coding standards
3. **Testing Frameworks:** Implement comprehensive quality assurance approaches
4. **Current Views Strategy:** Design backward compatibility layer for downstream systems

### Long-term Strategic Goals
1. **Business Value Delivery:** Demonstrate ROI through Healthcare Economics and Provider 360 initiatives
2. **Platform Adoption:** Drive broader organizational adoption through success stories
3. **Advanced Capabilities:** Enable ML, AI, and self-service analytics capabilities
4. **Operational Excellence:** Achieve enterprise-grade reliability, security, and compliance

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Next Review:** [Quarterly Architecture Review]  
**Document Owner:** AI Expert Team Cabinet