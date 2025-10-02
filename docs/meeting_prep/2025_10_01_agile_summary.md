---
title: "Agile Team Update - October 1, 2025"
author: "Dan Brickey"
created: "2025-10-02"
date_range: "2025-10-01"
category: "agile-update"
tags: ["agile", "technical-update", "blockers", "action-items"]
source: "docs/journal/2025_10_01.md"
---

# Technical Update - October 1, 2025

## Completed Tasks
- ✓ EDP roadmap refinement meeting with HCE department (Dave Algren, Rhett Barton, Joe Shear)
- ✓ Abacus-Hakoda architecture integration decision finalized
- ✓ Provider Data Product Council session - clarified terminology and metrics approach
- ✓ One View benefit summary PoC planning session completed
- ✓ dbt support ticket opened for 'franken' environment issue

## Key Technical Decisions
- **Abacus Integration Architecture**: Confirmed Abacus Bronze/Silver will flow into our raw layer (not direct to curation). Maintains Data Vault 2.0 methodology and control over security/tenant ID. Enables AI-generated code refactoring approach.
- **Provider Engagement Model**: Renaming fact table (term conflicts with existing business team). Metrics are straw man examples for inspiration, not final requirements.

## Action Items
- **HCE Team** (Dave/Rhett/Joe): Track table dependencies during monthly business processes, deliver list in ~1 month
- **Dan**: Refine roadmap to include dependency tracking (currently priority-only)
- **Jesse**: Collect FAQ list from customer service for contract benefit questions
- **Dan**: Obtain PHI-sanitized contract docs from data governance for PoC testing
- **Dan**: Set up Snowflake external/internal stage test with Cortex AI (Arctic model)
- **Dan**: Schedule 2-week follow-up meeting for unstructured data PoC progress
- **Dan**: Send follow-up info to dbt support tomorrow AM
- **Provider Data Council**: Review proposed metrics, develop pain point-specific metrics

## Blockers
- **dbt Development Environment**: 'franken' database reference persisting despite config verification. Support ticket open, awaiting resolution with additional info.

## In Progress
- **Unstructured Data PoC**: Contract document ingestion → Snowflake Cortex summarization for customer service agents
  - Pattern applies to broader use cases (claims images, other unstructured data)
  - Output: Reusable development pattern for company-wide analytics

## Diagrams/Communication Process Improvement
- Need clearer straw man/pilot terminology in business data council presentations
- Developing better diagramming approach: business terminology at high level, engineering detail at low level (discussion with data governance ongoing)
