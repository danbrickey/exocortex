# Real-World Process Specification: BCI Data Vault Design & Implementation

**Organization**: Blue Cross of Idaho (BCI)

## Overview

| Attribute | Value |
|-----------|-------|
| **Trigger** | Business need for new data entity or refactor of existing Data Vault structure |
| **Outcome** | Approved, tested dbt code merged to develop branch in GitLab |
| **Frequency** | Ongoing (part of regular data engineering work) |
| **Typical Duration** | TBD (architecture phase is the bottleneck) |
| **Key Roles** | Architect, Data Engineer, Reviewing Architect/Lead Engineer |

## Process Flow

| Step | Name | Performer | Inputs | Outputs | Acceptance Criteria |
|------|------|-----------|--------|---------|---------------------|
| 1 | Identify Need | Architect / Stakeholder | Business requirement, data analysis | Decision to create/modify entity | Clear scope defined |
| 2 | Design Entity | Architect | Source documentation, existing model, Lucidchart diagrams | Design decision (hub/link/satellite structure) | Design reviewed with other architects |
| 3 | Create Diagram | Architect | Design decision | Updated Lucidchart diagram | Diagram reflects design intent |
| 4 | Write Specification | Architect | Design decision, diagram, source docs | Structured specification (template) | Complete enough for engineer to implement |
| 5 | Assign to Engineer | Architect / Lead | Specification | Work assignment | Engineer understands scope |
| 6 | Implement in dbt | Data Engineer | Specification | dbt model code | Code matches specification |
| 7 | Submit MR | Data Engineer | dbt code | GitLab Merge Request | MR created, tests pass |
| 8 | Review Code | Architect / Lead Engineer | MR, specification, diagram | Approval or feedback | Code matches design, follows standards |
| 9 | Merge to Develop | Reviewer | Approved MR | Code in develop branch | Merged successfully |

## Decision Points

| At Step | Condition | Path A | Path B |
|---------|-----------|--------|--------|
| 2 | Is this a new entity or refactor? | New: Design from scratch | Refactor: Analyze existing structure first |
| 8 | Does code match spec? | Yes: Approve MR | No: Request changes, return to Step 6 |

## Current Pain Points

| Issue | Impact | Step(s) Affected |
|-------|--------|------------------|
| **Architecture bottleneck** | Architecture takes longer than engineering | Steps 2-4 |
| **Spec completeness varies** | Engineers need clarification, rework occurs | Step 4 → Step 6 |
| **Manual review overhead** | Reviewer must mentally compare code to spec/diagram | Step 8 |
| **Freeform diagrams** | Hard to extract structured info from Lucidchart | Step 3 → Step 4 |
| **No AI assistance in review** | All validation is human effort | Step 8 |

## Artifacts

| Artifact | Format | Location | Notes |
|----------|--------|----------|-------|
| Lucidchart Diagram | Visual (freeform) | Lucidchart | Currently no standard conventions |
| Specification | Structured template | TBD | Template exists, details to be added |
| dbt Model Code | SQL / YAML | GitLab repo | dbt project structure |
| Merge Request | GitLab MR | Private GitLab | Contains code diff, comments |

## Current Tool Usage

| Step | Tools Used |
|------|------------|
| 2-4 (Design & Spec) | Lucidchart, manual documentation |
| 6 (Implementation) | VSCode, dbt, dbt Copilot (available) |
| 7-9 (Review & Merge) | GitLab |

## Bottleneck Analysis

```
TIME DISTRIBUTION (Current State - Estimated)

Design & Spec (Steps 2-4):  ████████████████████░░░░  ~60-70% of cycle time ← BOTTLENECK
Implementation (Steps 5-7): ██████░░░░░░░░░░░░░░░░░░  ~20-25% of cycle time
Review & Merge (Steps 8-9): ████░░░░░░░░░░░░░░░░░░░░  ~10-15% of cycle time
```

**Primary Opportunity**: Steps 2-4 (Design through Specification) - this is where AI assistance can have the biggest impact.

**Secondary Opportunity**: Step 8 (Review) - AI-assisted validation could accelerate reviews and catch issues earlier.

---

## Validation Status

✅ **Validated by user** (2026-01-03)

- Step sequence confirmed accurate
- Bottleneck estimate accepted (~60-70% in design/spec)
- Ready to proceed to Phase 3: Agent/Human Allocation
