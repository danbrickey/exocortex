# AI Transformation Initiatives at Blue Cross

**Last Updated**: October 15, 2025
**Status**: Active Development

---

## Overview

This folder tracks AI transformation work at Blue Cross Idaho, including:
- AI-assisted workflows and code generation use cases
- AI enablement programs (Office Hours, Champions Network)
- AI POCs and pilot projects
- Portfolio candidates for external career positioning

---

## Folder Structure

```
ai_transformation/
├── README.md (this file)
├── use_cases/                      # AI-assisted technical workflows
│   ├── uc01_dv_refactor/          # Data Vault 2.0 refactoring
│   ├── uc02_edw2_refactor/        # EDW2 to EDW3 migration
│   └── uc03_ai_dv_code_generation/ # Greenfield code generation
├── portfolio_candidates/           # Tracking projects for external portfolio
│   └── portfolio_tracker.md
└── initiatives/                    # AI programs and enablement (future)
    ├── ai_office_hours_log.md
    └── ai_champions_network.md
```

---

## Active Use Cases

### UC01: Data Vault 2.0 Refactoring
**Status**: Active, 5+ entities refactored
**Purpose**: Refactor 3NF models to Data Vault 2.0 using AI-assisted code generation
**Business Value**: 60-70% reduction in refactoring time, improved consistency
**Tech Stack**: Claude Code, dbt, automate_dv, Snowflake

**Key Entities Completed**:
- member_cob
- group_plan_eligibility
- product_prefix
- product_billing
- benefit_summary_text

**Location**: `use_cases/uc01_dv_refactor/`

---

### UC02: EDW2 to EDW3 Migration
**Status**: Active, 1 entity complete (class_type)
**Purpose**: Migrate SQL Server dimensional models to Snowflake dbt models
**Business Value**: Accelerates cloud migration, preserves business logic
**Tech Stack**: Claude Code, dbt, Data Vault 2.0, Snowflake

**Key Deliverables**:
- Business rules documentation
- Source-to-target mappings
- dbt models (business vault + dimensional)
- Comprehensive specifications

**Location**: `use_cases/uc02_edw2_refactor/`

---

### UC03: AI-Assisted Data Vault Code Generation (Planned)
**Status**: Requirements defined, not yet implemented
**Purpose**: Generate Data Vault code from design specifications (YAML/diagrams)
**Business Value**: 60-80% reduction in initial coding time for new entities
**Tech Stack**: Claude Code, Mermaid diagrams, YAML, dbt, automate_dv

**Location**: `use_cases/uc03_ai_dv_code_generation/`

---

## Portfolio Candidates

These use cases are being evaluated as potential **external portfolio projects** for career positioning:

| Use Case | Portfolio Readiness | Business Impact | Technical Complexity | External Appeal |
|----------|-------------------|-----------------|---------------------|----------------|
| UC01: DV Refactor | ⭐⭐⭐⭐ High | 60-70% time savings | High (DV, dbt, AI) | Strong |
| UC02: EDW Migration | ⭐⭐⭐⭐⭐ Very High | Proven metrics, complete example | High (migration, DV, AI) | **BEST** |
| UC03: Code Generation | ⭐⭐ Medium | Planned, no metrics yet | Very High (AI generation) | Strong but not proven |

**Recommendation for Q1 2026 POC**: Consider expanding **UC02 (EDW Migration)** as your first AI portfolio project:
- ✅ Complete working example (class_type)
- ✅ Measurable business impact
- ✅ Comprehensive documentation
- ✅ Demonstrates AI + architecture + migration expertise
- ✅ Replicable pattern for other entities

See `portfolio_candidates/portfolio_tracker.md` for detailed analysis.

---

## Integration with Career Plan

These AI transformation initiatives directly support **Career Plan Phase 0 and beyond**:

### Career Plan Alignment
- **Phase 0 (Oct-Nov 2025)**: AI workflow optimization → UC01, UC02 are perfect examples
- **Q1 2026 POC**: Contract Benefits Summarization (planned)
- **Q2-Q3 2026**: Expand AI use cases, potentially formalize UC02 as portfolio project

### Portfolio Development
- UC02 can be documented as **Portfolio Project #1** (if expanded)
- Demonstrates:
  - AI Solutions Architect skills (design, implementation)
  - AI Strategist skills (business value, ROI)
  - Healthcare domain expertise
  - Technical depth (Data Vault, dbt, Snowflake, AI)

---

## How to Use This Folder

### For Daily Work
- Track progress on use cases in your daily journal (`personal/daily_journal/`)
- Log specific refactorings or migrations as they complete
- Capture time savings and metrics

### For Weekly Reviews
- Summarize use case progress
- Identify patterns and learnings
- Track which entities are complete

### For Monthly Reviews
- Assess overall AI transformation impact
- Calculate cumulative time savings
- Update portfolio candidates based on new examples
- Generate metrics for leadership reports

### For Portfolio
- Pull completed use cases from here into `reports/career_portfolio/`
- Document with architecture diagrams, business impact, metrics
- Prepare for job search, LinkedIn, conference talks

---

## Metrics to Track

### Quantitative
- **Time savings**: Hours saved per entity vs. manual refactoring
- **Entities completed**: Count by use case
- **Code quality**: Test pass rates, compilation success
- **Consistency**: Adherence to standards (%)

### Qualitative
- Developer feedback on AI-assisted workflows
- Architect confidence in generated code
- Ease of maintenance and debugging

---

## Future AI Initiatives (Q2-Q4 2026)

### AI Office Hours
**Purpose**: Enable data engineers to use AI tools (Claude Code, Copilot, etc.)
**Status**: Planned for May 2026 (per career plan)
**Location**: `initiatives/ai_office_hours_log.md` (to be created)

### AI Champions Network
**Purpose**: Build community of practice for AI adoption
**Status**: Planned for May-June 2026
**Location**: `initiatives/ai_champions_network.md` (to be created)

### Contract Benefits POC (Q1 2026)
**Purpose**: PDF contract summarization using Cortex AI
**Status**: Scoped, launching January 2026
**Location**: To be tracked here or in `../projects/active/`

---

## Related Files

**BCI Goals**: `docs/goals/bci_goals/`
- Vision and architecture goals that AI transformation supports

**Career Plan**: `docs/goals/career_goals/career_plan.md`
- How AI transformation work feeds external career trajectory

**Monthly Reviews**: `docs/personal/monthly_reviews/`
- Track AI transformation progress alongside other work

**Reports**: `docs/reports/career_portfolio/`
- Publish completed projects for external positioning

---

## Notes

- This folder is integrated with the **Personal Operating System**
- Use cases here serve dual purpose: BCI value AND career portfolio
- Track metrics consistently for both internal reporting and external positioning
- Old location: `docs/use_cases/` (moved Oct 15, 2025)

---

**Questions?** See `docs/PERSONAL_OPERATING_SYSTEM.md` for how this integrates with your overall tracking system.
