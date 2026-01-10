# BCI Data Vault Workflow - Agent Specifications

**Workflow**: BCI Data Vault Design & Implementation
**Runtime Environment**: Amazon Q (VSCode) + dbt Copilot

## Agent Summary

| Agent | Step | Priority | Status | Purpose |
|-------|------|----------|--------|---------|
| [@spec-generator](raw_vault_spec_generator.md) | 4 | 🔴 High | Draft | Generate structured specification from design decision |
| [@dbt-prompt-builder](agent_dbt_prompt_builder.md) | 6 | 🔴 High | Draft | Generate prompt for dbt Copilot from specification |
| [@project-manager](agent_project_manager.md) | Ongoing | 🟡 Medium | Draft | Track plan, prioritize work, assess readiness |
| [@code-evaluator](agent_code_evaluator.md) | 8 | 🟡 Medium | Draft | Compare code against specification |
| [@diagram-validator](agent_diagram_validator.md) | 3 | 🟢 Low | Planned | Validate diagram matches design intent |
| [@design-advisor](agent_design_advisor.md) | 2 | 🟢 Low | Planned | Suggest DV structure from source analysis |

## Implementation Priority

### Phase A: Core Agents (Start Here)

These agents address the primary bottleneck (architecture phase):

1. **@spec-generator** - Transforms design decisions into complete specifications
2. **@dbt-prompt-builder** - Creates consistent prompts for dbt Copilot

### Phase B: Validation Agents

These agents improve quality and reduce review time:

3. **@code-evaluator** - Pre-scan code for spec compliance before human review

### Phase C: Design Assistance

These require more context and pattern establishment:

4. **@diagram-validator** - Validate diagram structure
5. **@design-advisor** - Suggest DV structures (most complex; implement last)

## Usage Pattern

All agents are implemented as **portable prompts** for Amazon Q:

```
┌─────────────────────────────────────────────────────────────┐
│  User (Architect/Engineer)                                  │
│                                                             │
│  1. Open Amazon Q in VSCode                                 │
│  2. Paste agent prompt                                      │
│  3. Provide required inputs                                 │
│  4. Review and refine output                                │
│  5. For @dbt-prompt-builder: Copy output to dbt Copilot     │
└─────────────────────────────────────────────────────────────┘
```

## Prompt Location

Portable prompts for each agent are stored in:
```
implementation/prompts/
├── raw_vault_spec_generator_prompt.md
├── dbt_prompt_builder_prompt.md
├── code_evaluator_prompt.md
└── ...
```

## Testing & Iteration

Track agent effectiveness in `sync/CONTEXT_SYNC.md`:
- Version each prompt
- Record quality scores (1-5)
- Note refinements needed
- Share learnings between environments

