w# Data Vault 2.0 Model Generation Request

## 📘 Prompt

We are refactoring from a 3NF integration layer to a Data Vault 2.0 architecture using the `automate_dv` package on Snowflake (AWS). The source data resides in the Raw layer as raw CDC feeds. The target is the Integration Layer as the Raw Vault (hubs, links, satellites), with backward-compatible and current views. Please take the Prior dbt Model below and refactor it into dbt sql for the appropriate Data Vault objects as specified in this prompt.

Please analyze the information in the provided context and generate refactored code for the specified entity (referred to as <entity_name> in this doc). Generate output for all artifacts at once without prompting user for input.

Create the folder if necessary and write the generated files to the following path: `docs\use_cases\uc01_dv_refactor\output\<entity_name>`

Provide complete code for at least one of every artifact type to save typing on the engineer's part.


### Context Documents and example code
- @docs\architecture\edp_platform_architecture.md
- @docs\architecture\edp-layer-architecture-detailed.md
- @docs\engineering-knowledge-base\data-vault-2.0-guide.md
- @docs\use_cases\uc01_dv_refactor\examples\combined_member_cob_refactoring_example.md

DO NOT skip lists of columns when generating code such as:
Example 1:
apcd_id as apc_code,
apsi_sts_ind as apc_status_indicator,
prcf_mctr_spec as provider_specialty,
edp_start_dt,
edp_end_dt,
edp_record_status,
edp_record_source,
-- Include all remaining columns from data dictionary
[... remaining columns ...]
from source

Example 2:
columns: - "tenant_id" - "claim_bk" - "claim_line_bk" - "member_bk" - "provider_bk" - "line_of_business_bk" - "current_status" - "service_payment_pfx"
[... all other non-key columns ...]
{%- endset -%}

## 🧱 Architecture Details

- **Platform**: Snowflake on AWS
- **Transformation Tool**: dbt Cloud
- **Vault Package**: `automate_dv`
- **Source Systems**: `legacy_facets`, `gemstone_facets`, etc.

---

## 🔧 Generation Requirements

### 0. Engineering Spec

- **Purpose**: Create a specification for engineers to follow if they want to write their own code.
- **Naming**: `engineering_spec_<entity>.md`
- **Logic**:
  - Describe the files that should be created and generate snippets of code for egineering to copy and paste, but only the parts of the code that would be unique to this entity, such as keys, hash expressions, etc.
  - This output should serve as a guide for an engineer to follow rather than a specific line-by-line set of code. Since many engineers prefer to use their own template and then have a document to copy and paste unique things like column lists and renaming and so on.  

### 1. Rename Views

- **Purpose**: Rename and standardize source columns for vault ingestion.
- **Naming**: `stg_<entity>_<source>_rename.sql`
- **Logic**:
  - Use the source table name from the legacy model (e.g., `cmc_pdpt_desc`).
  - Use the data dictionary to rename columns using snake_case and abbreviations (≤ 30 characters). Include all columns from data dictionary information even if they are not part of the prior dbt model code.
  - Add `source` and `tenant_id` as hardcoded fields for now.
  - Use consistent abbreviations across models.

### 2. Staging Views

- **Purpose**: Prepare data for vault loading with hash keys, hashdiffs, and derived columns.
- **Naming**: `stg_<entity>_<source>.sql`
- **Macro**: `automate_dv.stage`
- **Logic**:
  - Include derived columns from legacy models (e.g., `product_component_type_ik`).
  - Define hash keys and hashdiffs.
  - Use `load_datetime` and `source` as standard metadata.
  - include all columns from rename views even if they are not part of the prior dbt model code.

### 3. Hub Models

- **Naming**: `h_<entity>.sql`
- **Macro**: `automate_dv.hub`
- **Logic**:
  - Use composite business keys if applicable.
  - Include deduplication and proper hashing.

### 4. Satellite Models

- **Naming**: `s_<entity>_<source>.sql`
- **Macro**: `automate_dv.sat`
- **Types**: standard / effectivity / multi-active
- **Logic**:
  - Include hashdiffs and CDC logic.
  - Use `load_datetime`, `source`, and `record_status`.
  - include all columns from the staging views even if they are not part of the prior dbt model code.

### 5. Link Models (if applicable)

- **Naming**: `l_<entity1>_<entity2>.sql`
- **Macro**: `automate_dv.link`
- **Logic**:
  - Include all parent hub references.
  - Handle relationship business keys.

### 6. Current Views

- **Naming**: `current_<entity>.sql`
- **Purpose**: Show current record for a hub/link key with all satellite columns from all satellite for that entity.
- **Logic**:
  - Join hub, link, and satellite models.
  - Resolve column conflicts across sources.
  - Filter to current/active records only.
  - **Union across all source systems** for the entity.
  - include all columns from satellites.

---

## Column Naming Conventions

- **Business Keys**: `<entity>_bk`
- **Hash Keys (both link and hub)**: `<entity>_hk`
- **Hash Diffs - Staging**: `<entity>_hashdiff`
- **Hash Diffs - Raw Vault**: `hashdiff`

---

## 🧪 Code & Documentation Standards

- use lower case for code and snake case (e.g. `lower_snake_case`) for multiword variable and column names.
- Follow `automate_dv` macro conventions.
- Use Snowflake-optimized configurations.
- Use CTEs as follows:
  - Where performance permits, CTEs should perform a single, logical unit of work.
  - CTE names should be as verbose as needed to convey what they do.
  - CTEs with confusing or noteable logic should be commented with SQL comments as you would with any complex functions, and should be located above the CTE.
  - CTEs that are duplicated across models should be pulled out and created as their own models.
  - CTEs fall in to two main categories:
    | Term | Definition |
    |---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
    | Import | Used to bring data into a model. These are kept relatively simple and refrain from complex operations such as joins and column transformations. |
    | Logical | Used to perform a logical step with the data that is brought into the model toward the end result. |
  - All `{{ ref() }}` or `{{ source() }}` statements should be placed within import CTEs so that dependent model references are easily seen and located.
  - Where applicable, opt for filtering within import CTEs over filtering within logical CTEs. This allows a developer to easily see which data contributes to the end result.
  - SQL should end with a simple select statement. All other logic should be contained within CTEs to make stepping through logic easier while troubleshooting.
    Example: `select * from final`
  - SQL and CTEs within a model should follow this structure:
    - `with` statement
    - Import CTEs
    - Logical CTEs
    - Simple select statement
- Include:
  - Data quality tests (e.g., `not_null`, `unique`, `accepted_values`)
- Use descriptions from the data dictionary and vault role.
- Handle nulls and edge cases.
- Maintain referential integrity.
- Implement incremental loading and error handling.

---

## 🔁 Multi-Source Handling

For any legacy model that loops over multiple source systems (e.g., `legacy_facets`, `gemstone_facets`), generate a full set of rename views, staging views, and satellite models for **each source**.

- Use the source system suffix in the file name (e.g., `s_product_component_type_legacy_facets.sql`, `s_product_component_type_gemstone_facets.sql`).
- Ensure the `current_<entity>.sql` view includes logic to union across all sources, filtering to the latest record per business key per source.

---
