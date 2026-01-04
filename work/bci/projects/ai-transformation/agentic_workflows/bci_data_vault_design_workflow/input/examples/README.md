# Specification Examples

Reference examples of Data Vault specifications. These examples inform the `@spec-generator` agent design and serve as the quality bar for generated specifications.

## Purpose

- Show the target format for specification output
- Provide patterns for different entity types (hub, link, satellite)
- Demonstrate the level of detail needed for engineers to implement

## Examples

| File | Entity Type | Key Patterns Shown |
|------|-------------|-------------------|
| [spec_member_hub.md](spec_member_hub.md) | Hub + Satellites + Same-As Link | Multi-source staging, column mapping table, SAL identity resolution |
| [spec_provider_hub.md](spec_provider_hub.md) | Hub + Satellites + Same-As Link | Complex business key logic, organization relationships |

## Specification Template Structure

Extracted from examples - this is the target format for `@spec-generator`:

```markdown
## Story [ID]: [Title]

**Title:** [Descriptive name]

**Description:**
As a data engineer,
I want to [action],
So that [business value].

**Technical Details:**

- **Entity Name**: [name]
- **Source Data**:
  - Source Project: [project]
  - Source Models: [list of staging models]
- **Staging Views**: [join logic description]
- **Business Key**: [key columns]
- **Hubs** (using automate_dv hub macro): [list]
- **Satellites** (using automate_dv sat macro): [list]
- **Same-As Links** (using automate_dv link macro): [list with join logic]

**Source Column Mapping / Payload**
| source_table | source_column | target_column |
|--------------|---------------|---------------|
| ... | ... | ... |

**Acceptance Criteria:**

Given [precondition],
when [action],
then [expected result].

[Include YAML test definitions for count matches]

**Metadata:**
- Story ID: [ID]
- Architect Estimate: [days]
- Deliverables: [list]
```

## Key Patterns for Agent Design

### 1. automate_dv Macro Usage
- Hubs: `automate_dv hub macro`
- Satellites: `automate_dv sat macro`
- Links/SALs: `automate_dv link macro`

### 2. Test Definitions
Specs include YAML test blocks for validation:
```yml
models:
  - name: [model_name]
    tests:
      - source_count_match:
          business_key_column: [hk_column]
          source_model: [count_model]
```

### 3. Identity Resolution (Same-As Links)
SAL specs include:
- Join logic to prior system records
- Hash key column for the SAL
- Business key mapping for identity resolution

## Usage

When designing the `@spec-generator` agent, reference these examples to:
1. Extract the structural template (above)
2. Identify required fields and sections
3. Define acceptance criteria for generated specs
4. Understand automate_dv conventions
