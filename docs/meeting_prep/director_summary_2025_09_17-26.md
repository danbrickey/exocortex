---
title: "Director Summary: EDP Activities September 17-26, 2025"
author: "Dan Brickey"
date_range: "2025-09-17 to 2025-09-26"
created: "2025-09-29"
category: "director-summary"
tags: ["PI-planning", "environment-migration", "architecture", "real-time-data", "business-alignment"]
source: "Journal entries from docs/journal/"
---

# Director Summary: EDP Activities
**Period:** September 17-26, 2025

---

## Executive Summary

Successfully completed PI planning week and initiated critical infrastructure consolidation by migrating development environment from Rising Sun to NorthStar Snowflake account. Established business alignment strategy with data domain councils and secured new partnership with Abacus for CMS interoperability requirements. Navigated repository security incident with minimal disruption to development schedules.

---

## Action Items

### High Priority
- **Owner**: Dan Brickey
- **Task**: Complete dbt environment testing in NorthStar Dev (formerly Franken) and finalize Rising Sun decommissioning plan
- **Due Date**: End of Sprint 1 (mid-October 2025)
- **Priority**: High

- **Owner**: Dan Brickey / Lindsay / Data Governance
- **Task**: Schedule and launch Membership and Product Data Domain Councils (following Provider Council model)
- **Due Date**: Early Q4 2025
- **Priority**: High

- **Owner**: Data Engineering Teams
- **Task**: Split code repositories for OneView (streaming), Data Integrations (extracts), and Data Domains (analytics) to enable independent release schedules
- **Due Date**: Mid-PI 3.2
- **Priority**: High

### Medium Priority
- **Owner**: Dan Brickey / Nicole Bowen / Tina Day
- **Task**: Complete Provider 360 business modeling and metric naming alignment
- **Due Date**: October 2025
- **Priority**: Medium

- **Owner**: Dan Brickey
- **Task**: Organize design meetings for OneView AI proof of concept (contract document harvesting)
- **Due Date**: Q1 2026 POC target, design by end Q4 2025
- **Priority**: Medium

- **Owner**: Engineering Admins
- **Task**: Create dual raw database structure in Dev (dev_raw_DB for ingestion, dev_eng_raw_DB for engineering with zero-copy clone)
- **Due Date**: Sprint 1
- **Priority**: Medium

---

## Key Decisions Made

### Infrastructure & Environment Consolidation
- **Decision**: Migrate development environment from Rising Sun to NorthStar account immediately, using existing "Franken" environment (to be renamed "Dev")
- **Rationale**: Enable front-loaded disruption in PI to minimize impact on feature delivery later in quarter; clean slate approach avoids carrying forward two years of technical debt
- **Impact**: All development work consolidated to single Snowflake account; Rising Sun repurposed as POC/training account with synthetic data

- **Decision**: Rename Franken to Dev rather than clone/replicate approach
- **Rationale**: Faster timeline with upfront disruption preferred by development teams over prolonged migration
- **Impact**: RBAC/PBAC configuration work required early in PI; development teams operational faster

- **Decision**: Create separate raw databases for ingestion development vs. engineering development using zero-copy clones
- **Rationale**: Ingestion team needs stable raw layer for testing; engineering teams need fresh production-like data for development
- **Impact**: Enables both teams to work independently without disrupting each other's workflows

### Real-Time Data Architecture
- **Decision**: Implement "deferred merge view" pattern as primary approach for near real-time customer service data (Option 1 of 3 evaluated)
- **Rationale**: Existing working pattern developed for Kafka pipelines can be repurposed; lower implementation effort than alternatives; achieves <5 minute latency target
- **Impact**: Batch loading remains at 4-6 hour cycle while real-time views provide seconds-level latency for critical customer service tables

- **Decision**: Move from Kafka/MSK to S3 CSV file ingestion for most sources
- **Rationale**: Performance adequate with partitioning; significant cost reduction; simplifies architecture
- **Impact**: MSK retained only for true real-time requirements; OneView app pipelines refactored for CSV-based streaming

### Repository & Code Management
- **Decision**: Split monolithic dbt repository into three independent projects: EDP_Streaming (real-time), EDP_Data_Integrations (extracts), EDP_Data_Domains (analytics)
- **Rationale**: Different use cases have incompatible release schedules and orchestration needs; OneView requires independent real-time development cycle
- **Impact**: Enables autonomous team delivery; reduces cross-team dependencies and scheduling conflicts

### Business Alignment & Strategic Initiatives
- **Decision**: Establish Data Domain Councils for Membership and Product (following successful Provider Council model)
- **Rationale**: Drive business-aligned data product prioritization and roadmap; create shared vocabulary through domain-driven design
- **Impact**: Improved stakeholder engagement; business-driven prioritization; foundation for MDM solution proposal from Hakoda next quarter

- **Decision**: Pursue hybrid approach for legacy migration: AI-assisted refactoring combined with domain-by-domain migration
- **Rationale**: Full domain AI migration (200K lines) proved too ambitious; focused approach on related business entities more tractable
- **Impact**: Reduced scope enables AI acceleration without overwhelming context; maintains lift-and-shift fallback for complex domains

### AI Innovation Strategy
- **Decision**: OneView AI POC will focus on contract document harvesting (extracting structured info from PDF images) rather than notes summarization or benefit text extraction
- **Rationale**: Highest business value; clear customer service use case; achievable scope for Q1 2026 POC
- **Impact**: Design work begins Q4 2025; infrastructure requirements identified; customer service capability enhancement

---

## Accomplishments

### PI Planning Execution
- **Achievement**: Successfully completed PI 3.2 planning week with all teams aligned on features, stories, and dependencies
- **Business Value**: Clear roadmap for next 10 weeks; cross-team coordination established; architecture decisions documented
- **Next Steps**: Sprint 1 execution begins with environment transition as foundation

### Infrastructure Migration Initiated
- **Achievement**: Migrated EDP_source_data project to NorthStar (Franken/Dev environment); EDP_Data_Domains project 90% complete
- **Business Value**: Single Snowflake account architecture reduces complexity and cost; enables Rising Sun decommissioning
- **Next Steps**: Complete testing in Dev; migrate Test and Prod configurations; finalize Rising Sun retirement plan

### Business Partnership Launch
- **Achievement**: Abacus interoperability project kickoff successful; SOW signed; work begins October 2025
- **Business Value**: CMS compliance for mandates 9115 and 0057 (FHIR/prior auth); Snowflake share for raw and silver layer data ingestion
- **Next Steps**: Multi-source system ingestion planning; timeline extends to summer 2026 for full deployment

### C4-DDD Architecture Framework Development
- **Achievement**: Created unified C4 diagramming method combined with domain-driven design for multi-level stakeholder communication
- **Business Value**: Executive-level context diagrams for ECC, technical container diagrams for ARB, detailed component designs for engineering teams
- **Next Steps**: Apply framework to Provider 360, Membership, and Product domain modeling; socialize with business stakeholders

---

## Escalation Items

### Repository Security Incident - RESOLVED
- **Issue**: Code repository mistakenly flagged for PHI in cleartext and deleted without notification; contained PHI-like test data, not actual PHI
- **Impact**: Loss of all branches except develop; complete loss of merge/change history; Main branch now contains in-progress dev features
- **Resolution**: Restored develop branch from backup; recreated branch protection rules; all environments operational within 24 hours
- **Recommendation**:
  - Implement notification process before repository deletion
  - Review and improve test data generation standards to avoid PHI-like patterns
  - Establish clearer backup/restore procedures for future incidents
  - **Would have been production-down event if production were live**

### Architecture Decision Timing
- **Issue**: Major architecture decisions made during PI planning week creating time pressure for affected teams
- **Impact**: Teams pulled into multiple architecture discussions during planning activities; reduced time for feature story development
- **Recommendation**: Front-load architecture decision-making before PI planning week begins; balance team availability at end of previous PI

### Snowflake AI Cortex Cost Spike
- **Issue**: Alarming increase in Cortex AI compute spend detected in Rising Sun environment
- **Impact**: Unexpected budget consumption; sustainability of AI POC approaches questioned
- **Recommendation**:
  - Engage Snowflake AI expert for realistic/affordable POC guidance
  - Establish AI usage tracking and budget alerts
  - Review AI POC methodologies for cost-effectiveness before expansion

---

## Strategic Context & Progress

### Environment Consolidation Timeline
**Current State**: Development split across Rising Sun and NorthStar Snowflake accounts; Franken environment in NorthStar used for testing
**In-Progress**: Migration to NorthStar (Franken→Dev) in final testing; Rising Sun decommissioning plan in development
**Target State (End of PI)**: All development, test, and production in single NorthStar account; Rising Sun repurposed for POC/synthetic data

### Real-Time Data Capability Development
**Current State**: Batch loading twice daily (4-6 hour cycles); MSK streaming partially implemented but expensive
**In-Progress**: Deferred merge view pattern implementation for customer service use cases; CSV-based ingestion architecture
**Target State**: <5 minute latency for customer service critical tables; cost-effective S3 CSV ingestion; MSK retired except true real-time needs

### Business Alignment Maturity
**Current State**: Provider Data Council established and meeting regularly; ad-hoc business engagement for other domains
**In-Progress**: Membership and Product Council formation; Provider 360 modeling alignment; C4-DDD framework development
**Target State**: All major domains have active Data Councils; business-driven roadmap prioritization; MDM solution proposal from Hakoda

### Team Structure Evolution
**Current State**: Dan moved from individual contributor team to business alignment/solution architecture team
**Responsibilities**: Solution architecture oversight, environment/repo changes, business domain modeling (Member/Product), Hakoda offshore team coordination
**Delegation Strategy**: Ram emphasized distributing tangible work to others; spread guidance across teams; reserve time for business alignment work

---

## Risk & Dependency Management

### Resource Allocation
- Architecture team capacity stretched across business alignment, infrastructure migration, and ongoing feature delivery
- Offshore Hakoda team requires continued modeling work (Provider, Member, Product domains) to maintain momentum
- Balance between delegation and hands-on technical leadership needs calibration

### Cross-Team Dependencies
- OneView real-time data capability depends on CSV ingestion architecture completion
- Repository splitting depends on successful NorthStar migration completion
- Data Domain Council success depends on C4-DDD framework adoption and business stakeholder availability

### Vendor & Partner Coordination
- Abacus timeline extends to summer 2026; need to align EDP data model maturity with their delivery schedule
- Hakoda MDM proposal next quarter must align with Data Council outputs and business domain modeling
- Snowflake consultant (Ranga) availability critical for real-time architecture validation and cost optimization

---

## Metrics & Health Indicators

### PI Planning Success Metrics
- ✅ All teams completed planning with acceptance criteria
- ✅ Dependencies identified and sequenced
- ✅ First 2 sprints planned in detail
- ⚠️ Architecture decisions made during planning (improve timing for next PI)

### Environment Migration Progress
- ✅ EDP_source_data project migrated and tested
- 🔄 EDP_Data_Domains project in final testing phase
- 📋 Test and Prod configuration migration pending
- 📋 Rising Sun decommissioning plan in development

### Business Engagement Health
- ✅ Provider Data Council active and productive
- 🔄 Membership and Product Councils in formation
- ✅ Abacus partnership launched successfully
- 📋 AI POC design meetings scheduled for Q4

### Technical Health
- ✅ Repository restored with minimal production impact
- ⚠️ AI compute costs require monitoring and optimization
- ✅ Real-time architecture approach validated and scoped
- ✅ C4-DDD framework developed for business communication

---

## Stakeholder Communication Priorities

### For Leadership (CIO/CTO Level)
- Single Snowflake account consolidation reduces operational complexity and cost
- CMS compliance partnership (Abacus) launched on schedule
- Business alignment strategy (Data Councils) driving product roadmap prioritization
- AI innovation balanced with cost management and realistic POC scope

### For Architecture Review Board
- Real-time data architecture selected (deferred merge view pattern)
- Repository splitting strategy enables autonomous team delivery
- C4-DDD framework provides consistent multi-level architecture communication
- Infrastructure migration on track for mid-PI completion

### For Data Engineering Teams
- Development environment migration in final testing; minimal disruption expected
- Repository splitting coming mid-PI to enable independent release schedules
- Real-time capability development unblocked by architecture decisions
- Clear delegation of modeling work to offshore team

### For Business Stakeholders
- Provider 360 modeling progressing with business engagement
- Membership and Product Data Councils launching to drive business-aligned prioritization
- AI customer service capability (contract document harvesting) scoped for Q1 2026
- Domain-driven design framework improving business-IT shared vocabulary

---

**Next Summary Due:** October 7, 2025 (covering Sprint 1 of PI 3.2)
**Key Milestones to Track:**
- NorthStar Dev environment fully operational
- Repository split completed for OneView/Streaming
- First Membership/Product Data Council meetings held
- Real-time deferred merge view pattern implemented and tested