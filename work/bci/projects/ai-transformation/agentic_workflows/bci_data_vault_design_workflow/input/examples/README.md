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
| [spec_subscriber_satellites.md](spec_subscriber_satellites.md) | Satellites on existing hub | Parent hub reference, inherited business keys |
| [spec_member_rating_satellites.md](spec_member_rating_satellites.md) | Satellites on existing hub | Multi-table join to get hub key |
| [spec_member_disability_satellites.md](spec_member_disability_satellites.md) | Satellites on existing hub | Disability tracking with verification history |
| [spec_member_student_status_satellites.md](spec_member_student_status_satellites.md) | Satellites on existing hub | Student eligibility with school enrollment tracking |
| [spec_subscriber_rating_satellites.md](spec_subscriber_rating_satellites.md) | Satellites on existing hub | Subscriber premium rate factoring with geographic rating |
| [spec_subscriber_warning_msg_satellites.md](spec_subscriber_warning_msg_satellites.md) | Satellites on existing hub | Subscriber warning messages with effective dating |
| [spec_subscriber_employment_satellites.md](spec_subscriber_employment_satellites.md) | Satellites on existing hub | Subscriber employment with occupation and location |

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
- **Parent Hub**: [if satellite-only, reference existing hub]
- **Source Data**:
  - Source Project: [project]
  - Source Models: [list of staging models]
- **Staging Views**: [join logic description]
- **Business Key**: [key columns]
- **Hubs** (using automate_dv hub macro): [list, if applicable]
- **Satellites** (using automate_dv sat macro): [list]
- **Same-As Links** (using automate_dv link macro): [list with join logic, if applicable]

**Source Column Mapping / Payload**
| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|-------------------|
| ... | ... | ... | ... |

**Acceptance Criteria:**

Given [precondition],
when [action],
then [expected result].

**Metadata:**
- Story ID: [ID]
- Architect Estimate: [days]
- Deliverables: [list]
- Dependencies: [list, if applicable]
```

## Key Patterns for Agent Design

### 1. automate_dv Macro Usage
- Hubs: `automate_dv hub macro`
- Satellites: `automate_dv sat macro`
- Links/SALs: `automate_dv link macro`

### 2. Satellite-Only Entities
When adding satellites to an existing hub:
- Reference **Parent Hub** instead of defining a new hub
- Business keys are inherited from the parent hub
- Include join logic to get the hub key from staging data

### 3. Identity Resolution (Same-As Links)
SAL specs include:
- Join logic to prior system records
- Hash key column for the SAL
- Business key mapping for identity resolution

### 4. Source Column Mapping
- Include `column_description` for clarity
- Use `...table_name` shorthand for source tables
- Document business keys, system columns, and payload attributes

## Usage

When designing the `@spec-generator` agent, reference these examples to:
1. Extract the structural template (above)
2. Identify required fields and sections
3. Define acceptance criteria for generated specs
4. Understand automate_dv conventions

## Notes

- **YAML test blocks are NOT included** in specifications - tests are defined separately by engineers during implementation
- Specifications focus on design intent and column mappings, not implementation details
