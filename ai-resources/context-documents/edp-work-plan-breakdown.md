---
title: "EDP Detailed Questions & Work Plan - Functional Area Breakdown"
author: "AI Expert Team Cabinet"
last_updated: "2024-12-09T17:30:00Z"
version: "1.0.0"
category: "project-planning"
tags: ["work-plan", "functional-areas", "questions", "implementation", "roadmap"]
status: "active-planning"
audience: ["project-team", "architects", "stakeholders"]
related_docs: ["edp-architecture-baseline.md"]
---

# EDP Detailed Questions & Work Plan
*Functional Area Breakdown for Architecture Development*

---

## Document Purpose

This working document organizes all outstanding questions from our Cabinet discussion into functional work streams. Each section represents a logical area of work that can be tackled by relevant team members and subject matter experts to drive out the architectural details needed for January implementation readiness.

---

## 1. Architecture & Data Modeling

**Lead Contributors:** Atlas (Functional Architecture), Sage (Data Vault & Modeling)  
**Objective:** Establish fundamental design patterns and data modeling approaches

### Core Architecture Design Questions

**Scope & Prioritization:**
1. What subject areas or business domains need to be ready for Data Vault implementation when data engineering resumes in January?
2. Should we prioritize based on business value, complexity, or downstream dependencies?
3. What would be the highest-priority architectural deliverable to have ready for January?

**Data Vault Design Decisions:**
4. What's the complexity level of creating equivalent current views from Data Vault structures?
5. Are there specific transformation patterns we need to preserve from the 3NF model?
6. How does the Data Vault refactoring interact with ongoing infrastructure hardening work?
7. What Snowflake configuration decisions should align with our Data Vault patterns?

### Master Data Management & Business Keys

**Identity Resolution Strategy:**
1. For the Person/Member hub, what's the most stable identifier across systems for business key strategy?
2. Is the current person ID algorithm reliable enough for business keys, or should we consider composite keys?
3. What's the confidence level and collision rate for the provider matching algorithm?

**Source System Integration:**
4. For overlapping data between Legacy FACETS, Gemstone FACETS, and VALENZ, is there a hierarchy of trust?
5. Do matching algorithms account for providers changing affiliations or members moving between plans?
6. What are the most common data quality issues with current matching processes?
7. What specific pain points should Data Vault address regarding existing matching processes?

### **Deliverables for this Work Stream:**
- Subject area prioritization matrix
- Hub, Link, and Satellite design patterns
- Business key strategy documentation
- Current views backward compatibility design
- Master data management approach

---

## 2. Platform & Infrastructure

**Lead Contributor:** Frost (Snowflake Platform Architect)  
**Objective:** Optimize Snowflake configuration for Data Vault performance and scalability

### Performance Optimization

**Query Pattern Analysis:**
1. For analytical workloads, are we dealing with complex aggregations across large date ranges or focused queries?
2. What are current SLA expectations for extracts and portal data models?
3. How many concurrent users and processes do we expect hitting the platform simultaneously?
4. What's the current performance baseline we need to meet or improve upon when transitioning from 3NF to Data Vault?

**Storage & Clustering Strategy:**
5. What's the archival and retention strategy for 20+ years of premium data?
6. Should we consider Snowflake's time travel for compliance or automated archival to cheaper storage tiers?
7. What clustering strategy should we implement for Data Vault hub-and-spoke model?

### **Deliverables for this Work Stream:**
- Snowflake warehouse sizing and scaling strategy
- Clustering key recommendations for Data Vault tables
- Performance benchmarking approach
- Storage optimization and retention policies
- Cost management framework

---

## 3. Implementation & Development

**Lead Contributors:** Forge (dbt Engineering), River (Data Engineering & Pipeline Operations)  
**Objective:** Define development practices, data flow architecture, and implementation approaches

### Development Framework & Team Readiness

**Knowledge Transfer & Training:**
1. What level of Data Vault 2.0 knowledge should we assume when data engineering resumes?
2. What documentation/training materials need to be ready for January?
3. What business rule testing frameworks should we implement?

**Development Operations:**
4. Should we enhance GitLab integration for dbt CI/CD capabilities?
5. How do we structure the dbt project for optimal Data Vault pattern implementation?
6. What automate_dv package configurations are optimal for our use cases?

### Data Integration & Pipeline Architecture

**Real-time vs. Batch Processing:**
1. With MSK streaming pipeline for customer service data, should we stream directly into Raw Vault or create separate real-time staging?
2. Which transactional tables are we targeting for the streaming pipeline?
3. How do we handle scenarios where the same business entity comes through both batch Data Vault and real-time customer service streams?

**Legacy Migration & CDC:**
4. What CDC mechanisms are we using for twice-daily batch loads from source systems?
5. For WhereScape migration, what's the current job orchestration and dependency management?
6. What's the expected timeline for implementing real-time customer service capabilities versus Data Vault refactoring?

### **Deliverables for this Work Stream:**
- dbt project structure and coding standards
- automate_dv configuration templates
- Training and onboarding materials
- Data ingestion architecture design
- Real-time and batch processing integration patterns
- GitLab CI/CD integration plan

---

## 4. Data Quality & Governance

**Lead Contributor:** Sherlock (Quality Assurance & Testing)  
**Objective:** Establish comprehensive data quality frameworks and compliance processes

### Business Rule Validation

**Domain Expert Integration:**
1. When data governance identifies business domain experts, how do we systematically capture their quality rules?
2. Should we prioritize technical Data Vault integrity first, then layer in business rules as domain expertise develops?

**Data Vault Quality Frameworks:**
3. Should we leverage Data Vault's auditability features to build quality dashboards for business stakeholders?
4. What business rule testing frameworks should we implement for healthcare compliance?

### Compliance & Security

**Healthcare Compliance:**
5. How do we ensure HIPAA compliance throughout the Data Vault implementation?

### **Deliverables for this Work Stream:**
- Data quality testing framework
- Business rule capture and validation processes
- HIPAA compliance validation approach
- Data lineage and auditability dashboards
- Quality metrics and monitoring

---

## 5. Strategy & Stakeholder Management

**Lead Contributors:** Rose (Product Strategy & Planning), Face (Stakeholder Communication)  
**Objective:** Manage stakeholder expectations and define implementation strategy

### Implementation Strategy & Prioritization

**MVP Definition & Scope:**
1. What's the minimum viable Data Vault implementation that would satisfy Healthcare Economics' immediate analytical needs?
2. Should Provider 360 data model be our first major Data Vault business vault implementation?
3. Which stakeholder group should drive our initial Data Vault implementation priorities?

**Expectation Management:**
4. How do we manage expectations with Healthcare Economics regarding advanced AI/ML capabilities timeline?
5. What's the communication strategy for bimodal stakeholder adoption?

### Communication & Engagement Strategy

**Stakeholder Tier Management:**
1. How do we keep Healthcare Economics engaged during foundational work without overpromising?
2. What's the timeline for showing tangible Provider 360 progress?
3. Should we plan for quick wins with Healthcare Economics to build enthusiasm in "wait and see" business units?
4. What's the communication strategy for each stakeholder tier?

### **Deliverables for this Work Stream:**
- Implementation roadmap and MVP definition
- Stakeholder communication plan
- Success story development strategy
- Expectation management framework
- Progress demonstration timeline

---

## Work Stream Dependencies & Coordination

### Critical Path Dependencies
1. **Architecture & Data Modeling** must complete before **Implementation & Development** can finalize technical specifications
2. **Platform & Infrastructure** decisions impact **Implementation & Development** approaches
3. **Strategy & Stakeholder Management** informs prioritization for all technical work streams
4. **Data Quality & Governance** requirements influence **Architecture & Data Modeling** decisions

### Cross-Functional Coordination Points
- **Architecture ↔ Platform:** Data Vault patterns must align with Snowflake optimization strategies
- **Implementation ↔ Quality:** Development practices must incorporate testing frameworks
- **Strategy ↔ All Technical:** Business priorities drive technical implementation sequence
- **All Streams:** Current views backward compatibility affects all technical decisions

---

## Next Steps for Each Work Stream

### Immediate Actions (Next 2 Weeks)
1. **Architecture & Data Modeling:** Define priority subject areas and begin hub/link/satellite design
2. **Platform & Infrastructure:** Analyze current query patterns and establish performance baselines
3. **Implementation & Development:** Assess team readiness and plan training materials
4. **Data Quality & Governance:** Engage with data governance team on domain expert identification
5. **Strategy & Stakeholder Management:** Finalize MVP scope and stakeholder communication plan

### Medium-term Goals (Next Month)
- Complete detailed designs and specifications for each work stream
- Validate cross-functional dependencies and integration points
- Establish implementation timeline for January readiness
- Begin stakeholder engagement and expectation setting

### Long-term Objectives (Quarter End)
- All architectural decisions documented and validated
- Implementation frameworks and standards established
- Team training and onboarding materials completed
- January implementation plan finalized and communicated

---

**Document Version:** 1.0  
**Last Updated:** [Current Date]  
**Next Review:** Weekly work stream check-ins  
**Document Owner:** AI Expert Team Cabinet