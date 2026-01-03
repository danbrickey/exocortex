# BCI Data Vault Design Workflow

**Organization**: Blue Cross of Idaho (BCI)
**Status**: Draft (Phase 2 Complete)
**Created**: 2026-01-02
**Last Updated**: 2026-01-03

## Overview

An agentic workflow to accelerate Data Vault architecture at BCI by transforming design decisions into AI-ready specifications, generating starter prompts for dbt Copilot, and providing automated code evaluation against specs.

## Quick Links

| Artifact | Description |
|----------|-------------|
| [Brain Dump](input/brain_dump.md) | Original process description and conversation |
| [Real-World Process](specifications/01_real_world_process.md) | Current state specification |
| [Agentic Workflow](specifications/02_agentic_workflow.md) | AI-augmented design (pending) |
| [Agents](agents/README.md) | Agent specifications (pending) |
| [Amazon Q Guide](implementation/amazon_q_guide.md) | Practical guide for runtime environment |

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

## Current Status

- [x] Initial brain dump captured
- [x] Clarifying questions answered
- [x] Phase 2: Real-World Process Specification (draft)
- [x] Phase 2: Validated by user
- [ ] Phase 3: Agent/Human Allocation
- [ ] Phase 4: Agentic Workflow Specification
- [ ] Agents specified
- [ ] Prompts created
- [ ] Tested
- [ ] Deployed

## Open Questions

See the bottom of [brain_dump.md](input/brain_dump.md) for any pending items.
