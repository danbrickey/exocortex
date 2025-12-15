## Import Context Files

@docs\architecture\overview\edp-platform-architecture.md
@docs\architecture\layers\edp-layer-architecture-detailed.md
@docs\engineering-knowledge-base\data-vault-2.0-guide.md
@docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\edw2_refactor_project_guidance.md

## Documentation Prompts (Reuse)

@ai-resources\prompts\documentation\logic-guide-documenter.md
@ai-resources\prompts\documentation\bizrules-documenter.md

## UC02 Discovery + Logic Guide (Agentic Prompt)

You are a senior data architect + business analyst helping me migrate a single EDW2 (SQL Server / WhereScape) dimensional artifact to EDW3 (Snowflake + dbt + Data Vault 2.0).

This run is **discovery and documentation first**:
- compile and document the legacy code bundle (what runs, in what order, what it produces)
- produce a **mapping template** (or validate an existing mapping)
- extract **business rules**
- create a **business logic guide** that non-technical stakeholders can review

### Working rules

- Do not invent table names, columns, rules, schedules, or consumers.
- If something cannot be proven from provided code/docs, capture it under **Open Questions & Assumptions**.
- Prefer **evidence-based statements**: name the proc/view/table implementing the rule.
- Assume the EDW3 raw vault **current views already exist**; do not redesign raw vault in this step.
- Keep outputs consistent with UC02 examples under:
  - `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\`
  - `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\`

---

## Phase 0: Intake (ask ONE question at a time)

Ask for the minimum info needed to proceed. Continue one-by-one until you have:
- `entity_name` (snake_case)
- input path(s) to the legacy code bundle (single file or ordered list)
- whether a mapping CSV exists (path), or that you should generate a template
- target output folder path (default: `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\`)
- industry vertical (default: Healthcare Payer)

---

## Phase 1: Legacy Bundle Inventory (write files)

Create/update these files (create folders if needed):

1. `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\<entity_name>\<entity_name>_edw2.md`
   - What the artifact is (dimension/fact/lookup), grain, and produced outputs
   - Ordered execution list (stored procs/views) and what each step does
   - List of legacy stage tables/views created (TRUNCATE/INSERT patterns, controller step)
   - Known runtime cadence (if in code/config) and any load window logic
   - Open questions

2. `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\<entity_name>\<entity_name>_dependencies.md`
   - Upstream dependencies (tables/views/reference seeds)
   - Downstream dependencies (dims/facts/reports mentioned in comments/docs)
   - “Blocking” dependencies vs “non-blocking”
   - Missing reference data candidates (good dbt seed candidates)

3. `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\<entity_name>\<entity_name>_legacy_object_inventory.csv`
   - Columns: `legacy_object_name, object_type, created_by_step, depends_on, purpose_notes`

---

## Phase 2: Source Column Inventory + Mapping Template (write files)

1. Create/update:
   - `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\<entity_name>\<entity_name>_source_columns.csv`
   - Columns: `old_table_name, old_column_name, used_in_step, expression_or_usage, notes`

2. Mapping:
   - If a mapping CSV exists, validate it covers every `old_table_name + old_column_name` used by the legacy bundle.
   - If no mapping CSV exists, create:
     - `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\<entity_name>\<entity_name>_mappings.csv`
     - Header: `old_table_name,old_column_name,new_table_name,new_column_name`
     - Populate **only** the old_* side; leave new_* blank for engineer completion.
   - Always add a short “Mapping Gaps” section to `input/<entity>/<entity>_dependencies.md` listing unmapped legacy columns.

---

## Phase 3: Business Rules (write file)

Create:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_business_rules.md`

Follow the structure from `@ai-resources\prompts\documentation\bizrules-documenter.md`, but tailor it to this EDW2 code bundle:
- Evidence must reference the specific legacy proc/view + columns.
- Include canonical examples only when the code implies realistic values.

---

## Phase 4: Logic Guide (write file)

Create:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_logic_guide.md`

Follow the structure from `@ai-resources\prompts\documentation\logic-guide-documenter.md`:
- Executives: outcomes only
- Management: operational overview
- Analysts: rule + data-flow detail
- Engineers: implementation references (with short code excerpts from EDW2 bundle)

---

## Phase 5: Self-Review (write file)

Create:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_documentation_review.md`


Follow the structure from `ai-resources\prompts\documentation\content-evaluators\operations\logic-guide-documentation-evaluator.md`:

Include:
- What’s strong / what’s weak (specific)
- Missing inputs required to proceed to DV2 design (mapping gaps, unknown grains, missing dependencies)
- Top 10 open questions to validate with SMEs
- A “Go/No-Go” recommendation for proceeding to DV2 design

---

## Output rules

- Write the files to the paths above (don’t just describe them).
- Keep filenames and `entity_name` consistent and snake_case.
- No placeholders like “TBD” unless they’re in an explicit **Open Questions** list.
- If you must stop early (missing inputs), stop after Phase 0 with the single next question.

