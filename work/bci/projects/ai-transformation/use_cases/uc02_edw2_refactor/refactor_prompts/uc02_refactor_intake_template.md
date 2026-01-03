# UC02 Intake Template (Copy/Paste and Fill)

Use this intake to kick off UC02 EDW2 refactoring work. Fill it in, then paste it into your chat along with the relevant `@` file references.

```yaml
entity_name: "<snake_case>"                  # e.g., pcp_attribution
industry_vertical: "<e.g., Healthcare Payer>"

# What is the EDW2 artifact?
legacy_artifact_type: "<dimension|fact|lookup|other>"
legacy_artifact_name: "<e.g., dimClassType_Base>"
legacy_system: "EDW2 / WhereScape / SQL Server"

# Inputs (repo-relative paths preferred)
legacy_code:
  # Prefer a single bundled SQL export file OR an ordered list of files.
  bundle_sql_path: "<path or empty>"
  ordered_paths:
    - "<path 1>"
    - "<path 2>"
  execution_order_notes: "<how the procs run, windows, controller step>"

supporting_inputs:
  edw2_summary_md_path: "<optional: input/<entity>/<entity>_edw2.md>"
  dependencies_md_path: "<optional: input/<entity>/<entity>_dependencies.md>"
  mapping_csv_path: "<optional: input/<entity>/<entity>_mappings.csv>"
  prior_outputs_to_reuse:
    - "<optional: output/<entity>/<entity>_logic_guide.md>"

# Context documents
architecture_docs:
  - "docs/architecture/overview/edp-platform-architecture.md"
  - "docs/architecture/layers/edp-layer-architecture-detailed.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
  - "docs/work-tracking/ai-transformation/use_cases/uc02_edw2_refactor/edw2_refactor_project_guidance.md"

# Target (EDW3)
target_platform:
  warehouse: "Snowflake"
  transform_tool: "dbt"
  dv2_package: "automate_dv"
  layers_in_scope:
    - "integration (raw vault current views assumed)"
    - "curation (business vault + dimensional)"

# Rules for this refactor
changes_from_legacy:
  - "<explicit business changes allowed (if any)>"
non_goals:
  - "<what to avoid>"
assumptions:
  - "<raw vault already standardizes X, etc>"
open_questions:
  - "<unknowns to resolve with SMEs>"

# Operational requirements
load_pattern: "<full refresh|incremental|hybrid>"
schedule: "<daily, hourly, quarterly, ad-hoc>"
data_latency_sla: "<if any>"

# Deliverables you want generated this run
deliverables:
  discovery_docs: true
  mapping_template_or_validation: true
  business_rules_doc: true
  logic_guide_doc: true
  business_vault_recommendations: true
  dimensional_model_design: true
  engineering_work_spec: true
```

