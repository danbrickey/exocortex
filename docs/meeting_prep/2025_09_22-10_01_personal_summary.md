---
title: "Personal Technical Summary - Sept 22 - Oct 1, 2025"
author: "Dan Brickey"
created: "2025-10-02"
date_range: "2025-09-22 to 2025-10-01"
category: "personal-summary"
tags: ["action-items", "completed", "follow-up", "blockers"]
source: "docs/journal/2025_09_22.md through 2025_10_01.md"
---

# Personal Summary - 3 Weeks (Sept 22 - Oct 1)

## My Action Item Progress
- ⚠ **OneView Unstructured Data PoC**: Organizing design meetings for Q1 2026 PoC - need to schedule 2-week follow-up
- ⚠ **HCE Roadmap Dependencies**: Refine roadmap to include dependency tracking (currently priority-only)
- 🔄 **Contract Document PoC**: Obtain PHI-sanitized contract docs from data governance, set up Snowflake stage test with Cortex AI
- 🔄 **Provider 360 Metrics**: Rename "Provider Engagement" fact (conflicts with business team name), finalize metrics with council
- 🔄 **C4 Diagramming Method**: Developing approach for business-friendly high-level + engineering-detailed diagrams
- 📋 **dbt Support Follow-up**: Send additional info to dbt support for 'franken' reference issue (tomorrow AM)
- 📋 **Customer Service FAQ Collection**: Jesse volunteering to collect frequently asked questions for contract benefit queries
- 📋 **Business Data Councils**: Expand Provider Data Council model to Membership and Product domains

## My Completed Tasks
- ✓ **dbt Franken Transition**: Successfully transitioned EDP_source_data and EDP_data_domains to Northstar dev environment
- ✓ **ARB Presentation**: MSK → S3 CSV proposal approved by Architecture Review Board
- ✓ **PI 3.2 Planning**: Completed sprint planning for Team 1, wrapped up dependencies/sequencing analysis
- ✓ **Abacus Interop Kickoff**: SOW signed, engagement starts Monday covering CMS-9115 and CMS-0057 compliance
- ✓ **AI PoC Demo**: Presented code migration results to David Yu, agreed on hybrid lift-and-shift + AI refactor approach
- ✓ **Near Real-Time Design**: Selected deferred merge view option (existing pattern) over triggered tasks or dynamic tables
- ✓ **Dev Environment Separation**: Decided on dual raw layers: dev_raw_db (ingestion) + dev_raw_clone_db (engineering)
- ✓ **Github Authentication Issue**: Resolved with Sean Trent + dbt support
- ✓ **Repository Strategy**: Proposed split into EDP_streaming, EDP_data_integrations, EDP_data_domains for independent release schedules

## My Follow-up Items
- **2-week meeting**: OneView unstructured data PoC design progress review
- **HCE table tracking**: Review dependency list after ~1 month collection period
- **Provider metrics**: Tuesday meeting to align on renamed fact and finalized metrics
- **Abacus architecture alignment**: Clarify how Bronze/Silver (medallion) meshes with Data Vault 2.0 layers
- **dbt testing**: Complete dev environment validation after 'franken' → 'dev' rename
- **Kafka retirement**: Finalize MSK vs. CSV decision for remaining real-time sources
- **MDM proposal**: Track Hakoda's MDM solution work alongside business domain council outputs

## I am Blocked by:
- **dbt 'franken' reference**: Persistent database name issue in dev environment despite config verification (support ticket open)
- **Policy scan issue**: Blocking merge of EDP_source_data branch transition code (waiting on Sean Trent's team)
- **Tenant ID assignment**: Abacus interoperability - decision needed on whether Abacus or EDP applies tenant ID
- **MMI file**: Association data file not in production yet (low priority - not needed soon)

## I am Blocking:
- **Data engineering teams**: Waiting on dev_raw_clone_db setup (Ian working today) + dbt 'franken' issue resolution
- **OneView real-time data**: Dependency on CSV S3 implementation for deferred merge view pattern
- **Provider/Membership/Product councils**: Need example models + diagramming approach before next meetings
- **HCE analytics requirements**: Roadmap refinement blocked until table dependency tracking complete

## Key Technical Decisions Made
- **Abacus Integration Architecture**: Bronze/Silver flows into our raw layer (not direct to curation) to maintain Data Vault 2.0 methodology and security control. Enables AI code generation approach.
- **Ingestion Method**: ARB approved move to S3 CSV for all ingestion (retiring MSK/Parquet). Performance adequate with partitioning + Glacier rolling.
- **Near Real-Time Pattern**: Deferred merge view (UNION ALL of ingested table + stream waiting data) + dynamic tables in curation layer. Already have working pattern from Kafka work.
- **Dev Environment Strategy**: Two raw layers in dev - dev_raw_db for ingestion teams, dev_raw_clone_db for engineering teams (zero-copy clone, not view layer).
- **Repository Split**: Separate repos for streaming, integrations, analytical transformations - independent release schedules per use case.
- **AI Code Migration**: Hybrid approach - one domain at a time, AI-refactored into cloud. Reduce scope to related entity sets within domain.
- **Franken Rename**: Confirmed rename to 'dev' prefix (vs. clone then rename).

## IT Organizational Context
- **McKinsey 7S Framework**: David Yu using for IT strategy evaluation
- **New IT Structure**: 7 departments reporting to CIO - BRM, o-CIO, Cybersecurity/GR, Infrastructure, EA/Common Services, AI/Innovation, Data
- **Design vs. Maintenance**: Shift from 30% design/70% maintenance → 70% design/30% maintenance. Contractors for maintenance, internal staff for design/build.
- **Gemstone Holdings**: BCI becoming subsidiary alongside Eagle Pharmacy, Range Health Care. IT servicing multiple companies.

## HCE Use Cases (Cloud Migration)
1. **Reference Data Upload**: Streamlit tool for uploading supplemental reference data (vs. on-prem sandbox)
2. **Analytics Output Persistence**: Approval process to persist ML model outputs into raw layer (feedback loop for data products)
3. **Analytical Capabilities**: Cloud equivalents to EDW 2D models + Health Data Services platform

## OneView Unstructured Data PoC (Q1 2026)
- **Primary Use Case**: Contract document summarization for customer service agents (PDFs/images → Snowflake Cortex Arctic model)
- **Broader Pattern**: Reusable development pattern for claims images + other unstructured data analytics
- **Next Steps**: FAQ collection from customer service (Jesse), PHI-sanitized docs from data governance (Dan), stage setup test
