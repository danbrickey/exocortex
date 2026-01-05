# BCI Data Vault Design Workflow

**Organization**: Blue Cross of Idaho (BCI)
**Status**: ✅ Ready for BCI Testing (Phase A Prompts Complete)
**Created**: 2026-01-02
**Last Updated**: 2026-01-04

## Overview

An agentic workflow to accelerate Data Vault architecture at BCI by transforming design decisions into AI-ready specifications, generating starter prompts for dbt Copilot, and providing automated code evaluation against specs.

## Quick Links

| Artifact | Description |
|----------|-------------|
| [Brain Dump](input/brain_dump.md) | Original process description and conversation |
| [Real-World Process](specifications/01_real_world_process.md) | Current state specification |
| [Agentic Workflow](specifications/02_agentic_workflow.md) | AI-augmented design |
| [Agents](agents/README.md) | Agent specifications |
| [Specifications](specs/) | Data Vault specifications (output of workflow) |
| [Amazon Q Guide](implementation/amazon_q_guide.md) | Practical guide for runtime environment |
| [Context Sync](sync/CONTEXT_SYNC.md) | **Shareable status file** for BCI ↔ Cursor sync |
| [Local Context (Cursor)](sync/LOCAL_CONTEXT_CURSOR.md) | Cursor-only context (does NOT sync) |
| [Local Context (BCI Template)](sync/LOCAL_CONTEXT_BCI_TEMPLATE.md) | Template for BCI-only context |
| [Sync Update Prompt](implementation/prompts/context_sync_update.md) | Amazon Q prompt to update sync file |
| [Security Audit Prompt](implementation/prompts/security_audit_sync.md) | **Audit before export** - checks for sensitive data |

## Tech Stack Constraints

### Two-Environment Design

| Environment | Purpose | Tools |
|-------------|---------|-------|
| **Design Time** (Cursor) | Build, test, iterate on workflow | Claude (full capabilities) |
| **Runtime** (BCI VSCode) | Where workflow is actually used | Amazon Q, Snowflake Cortex AI, MS Copilot Chat, dbt Copilot |

### Runtime Tools (BCI Environment)

| Tool | Role | Status |
|------|------|--------|
| **Amazon Q (VSCode)** | Primary AI assistant - runs the workflow | ✅ Core |
| **dbt Copilot** | dbt model creation (receives prompts from Amazon Q) | ✅ Core |
| Snowflake + AWS | Data platform | ✅ Infrastructure |
| dbt | Transformation code (main artifact) | ✅ Infrastructure |
| Lucidchart | Current diagramming tool | ✅ Input |
| MS Copilot Chat | Chatbot only (awkward as coding assistant) | ⚠️ Awareness |
| Snowflake Cortex AI | Not yet implemented | ⚠️ Future |

**Key Constraint**: Workflow runs on Amazon Q + dbt Copilot. Prompts designed here in Cursor must be portable to BCI's VSCode environment.

### Asymmetric Data Flow

```
┌─────────────────────────────┐              ┌─────────────────────────────┐
│  CURSOR (Design)            │              │  BCI (Private Network)      │
│                             │              │                             │
│  ┌───────────────────────┐  │              │  ┌───────────────────────┐  │
│  │ LOCAL_CONTEXT_CURSOR  │  │              │  │ LOCAL_CONTEXT (BCI)   │  │
│  │ (stays here)          │  │              │  │ (stays here)          │  │
│  │ • Design notes        │  │              │  │ • Internal systems    │  │
│  │ • Cursor techniques   │  │              │  │ • Team details        │  │
│  └───────────────────────┘  │              │  └───────────────────────┘  │
│                             │              │                             │
│  ┌───────────────────────┐  │  ◀── EASY ── │  (Copy prompts/templates)  │
│  │ CONTEXT_SYNC.md       │◀─┼──────────────┼─▶│ CONTEXT_SYNC.md       │  │
│  │ (shared, audited)     │  │  ── HARD ──▶ │  │ (shared, audited)     │  │
│  └───────────────────────┘  │  Email+Audit │  └───────────────────────┘  │
└─────────────────────────────┘              └─────────────────────────────┘
```

**Data flow rules**:
- **Into BCI**: Copy anytime (prompts, templates, workflow updates)
- **Out of BCI**: Weekly via email (CONTEXT_SYNC.md only)
- **Before export**: Run security audit prompt to check for sensitive data
- **Local context**: Stays in each environment, never crosses perimeter

## Current Status

- [x] Initial brain dump captured
- [x] Clarifying questions answered
- [x] Phase 2: Real-World Process Specification (validated)
- [x] Phase 3: Agent/Human Allocation (4 hybrid, 4 human, 1 agent)
- [x] Phase 4: Agentic Workflow Specification
- [x] Agents specified (3 of 5 - high/medium priority)
  - [x] @spec-generator (High priority)
  - [x] @dbt-prompt-builder (High priority)
  - [x] @code-evaluator (Medium priority)
  - [ ] @diagram-validator (Low priority - planned)
  - [ ] @design-advisor (Low priority - planned)
- [x] Prompts created - Phase A (spec-generator, dbt-prompt-builder)
- [ ] Prompts created - Phase B (code-evaluator)
- [ ] Tested in BCI environment
- [ ] Deployed

## Ready for Testing

**Status**: ✅ Ready to deploy to BCI for testing

Copy these files to BCI VSCode:
1. `implementation/prompts/spec_intake_template.md`
2. `implementation/prompts/spec_generator_prompt.md`
3. `implementation/prompts/dbt_prompt_builder_prompt.md`
4. `implementation/amazon_q_guide.md`
5. `sync/CONTEXT_SYNC.md`

See `implementation/README.md` for the test workflow.

## Open Questions

See the bottom of [brain_dump.md](input/brain_dump.md) for any pending items.
