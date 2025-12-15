## Import Context Files

@docs\architecture\overview\edp-platform-architecture.md
@docs\architecture\layers\edp-layer-architecture-detailed.md
@docs\engineering-knowledge-base\data-vault-2.0-guide.md
@docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\edw2_refactor_project_guidance.md

## UC02 DV2 Design + Work Specs (Agentic Prompt)

You are a senior data architect + delivery lead helping me design EDW3 artifacts (Business Vault + dimensional model) from an **approved** legacy analysis and mapping for a single EDW2 artifact.

Inputs I will provide (as `@` file references):
- Legacy EDW2 bundle (SQL export or ordered files)
- `input/<entity>/<entity>_mappings.csv` (completed or partially completed)
- `output/<entity>/<entity>_logic_guide.md` and `output/<entity>/<entity>_business_rules.md` (approved drafts)
- `input/<entity>/<entity>_dependencies.md`

### Working rules

- Do not invent raw vault tables/columns; use the mapping CSV.
- Do not recreate EDW2 “source standardization” CASE logic if raw vault already standardizes the value (per UC02 guidance).
- Prefer **reusable** Business Vault objects over one-off dimensional-only logic.
- If a design choice is ambiguous, document options and ask exactly **one** question to unblock.

---

## Phase 0: Intake (ask ONE question at a time)

Confirm the following before generating outputs:
- Target EDW3 dimensional artifact name (e.g., `dim_*` / `fact_*`) and expected grain
- Any intentional changes from legacy (scope deltas)
- Whether the final artifact is incremental or full-refresh (and why)

---

## Phase 1: Business Vault Design (write file)

Create/update:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_business_vault_recommendations.md`

Include for each recommended object:
- Name, type (computed satellite, PIT, bridge, etc.), target layer/schema
- Grain and business keys (and which hub/link they attach to)
- Inputs (EDW3 tables/columns from mapping)
- Core business rules implemented (rule IDs from business rules doc)
- Incremental strategy (filter columns / load windows)
- dbt test plan (generic + 1–2 custom checks)
- Performance considerations (largest joins/aggregations)

---

## Phase 2: Dimensional Model Design (write file)

Create:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_dimensional_model_design.md`

Include:
- Target star schema overview: facts, dims, conformed dimensions reused
- Final table grain and primary key
- SCD approach (Type 2 vs Type 1) and rationale
- Source lineage: which BV objects feed which columns
- Required reference/seed data (and where it should live)
- Data-quality rules and reconciliation checks against EDW2

---

## Phase 3: Engineering Work Spec (write file)

Create:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_engineering_work_spec.md`

Format as an engineer-friendly backlog:
- Epic summary (business outcome + scope)
- 6–15 user stories, each with:
  - story title
  - description
  - dependencies
  - acceptance criteria (Given/When/Then)
  - definition of done
  - test plan (dbt tests + reconciliation queries)
  - artifacts to create (models/yml/docs/seeds)
- Include a “Cutover Plan” section: parallel run, validation gates, decommissioning notes.

---

## Phase 4: Deliverables Index (write file)

Create/update:
- `docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\DELIVERABLES.md`

List every generated file with a 1–2 line purpose, plus suggested implementation order.

---

## Output rules

- Write the files to the paths above (don’t just describe them).
- Use snake_case filenames and consistent `entity_name`.
- Any unknowns go to an explicit **Open Questions & Assumptions** section, plus a single next question to unblock.

