# Implementation - Portable Prompts for Amazon Q

This folder contains production-ready prompts for the BCI Data Vault Design Workflow.

## Quick Start

| Step | Prompt | Purpose |
|------|--------|---------|
| 1 | [spec_intake_template.md](prompts/spec_intake_template.md) | Fill this out first |
| 2 | [raw_vault_spec_generator_prompt.md](prompts/raw_vault_spec_generator_prompt.md) | Generate specification |
| 3 | [dbt_prompt_builder_prompt.md](prompts/dbt_prompt_builder_prompt.md) | Generate dbt Copilot prompts |

## Workflow

```
┌──────────────────────────────────────────────────────────────────────────┐
│  STEP 1: Fill Intake Template                                            │
│  └── prompts/spec_intake_template.md                                     │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  STEP 2: Generate Specification (Amazon Q)                               │
│  └── Paste raw_vault_spec_generator_prompt.md + your filled template      │
│  └── Output: Complete specification document                             │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  STEP 3: Architect Review                                                │
│  └── Review/refine the generated spec                                    │
│  └── Approve for engineering                                             │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  STEP 4: Generate dbt Prompts (Amazon Q)                                 │
│  └── Paste dbt_prompt_builder_prompt.md + approved spec                  │
│  └── Request prompt for each model: staging → hub → satellites → SAL     │
└──────────────────────────────────────────────────────────────────────────┘
                                    │
                                    ▼
┌──────────────────────────────────────────────────────────────────────────┐
│  STEP 5: Generate dbt Code (dbt Copilot)                                 │
│  └── Paste each prompt into dbt Copilot                                  │
│  └── Review generated code against spec                                  │
└──────────────────────────────────────────────────────────────────────────┘
```

## Prompts Available

| Prompt | Agent | Priority | Status |
|--------|-------|----------|--------|
| [spec_intake_template.md](prompts/spec_intake_template.md) | (template) | 🔴 | ✅ Ready |
| [raw_vault_spec_generator_prompt.md](prompts/raw_vault_spec_generator_prompt.md) | @spec-generator | 🔴 | ✅ Ready |
| [dbt_prompt_builder_prompt.md](prompts/dbt_prompt_builder_prompt.md) | @dbt-prompt-builder | 🔴 | ✅ Ready |
| code_evaluator_prompt.md | @code-evaluator | 🟡 | 📋 Planned |

## Supporting Files

| File | Purpose |
|------|---------|
| [amazon_q_guide.md](amazon_q_guide.md) | Tips for using Amazon Q effectively |
| [context_sync_update.md](prompts/context_sync_update.md) | Prompt to update sync file |
| [security_audit_sync.md](prompts/security_audit_sync.md) | Audit before exporting files |

## Deployment to BCI

To use these in the BCI environment:

1. Copy the prompt files to your BCI VSCode workspace
2. Open Amazon Q chat
3. Paste the prompt
4. Follow with your inputs
5. Track results in `sync/CONTEXT_SYNC.md`

## Version Tracking

| Prompt | Current Version | Last Tested | Quality Score |
|--------|-----------------|-------------|---------------|
| raw_vault_spec_generator | v1.0 | Not yet | - |
| dbt_prompt_builder | v1.0 | Not yet | - |

Update this table as you test and iterate.

