# Kimball Dimensional Model Generation Request

## 📘 Project Purpose and Goals

### Purpose

We aim to automate the refactoring of legacy SQL Server-based dimensional models (EDW2) into dbt models for Snowflake (EDW3). When I use the term EDW2 I am refering to the legacy code from Wherescape/SQL Server, when I use the term EDW3, that refers to the new Snowflake implementation of our dimensional model and business vault. The legacy models were generated using Wherescape RED and are tightly coupled to an on-prem SQL Server environment. The goal is to modernize these models to align with the Data Vault 2.0 methodology and Snowflake-native performance patterns, using the automate_dv dbt package where applicable. The refactored EDW3 artifacts would live in the Curation Layer and pull data from the raw vault in the Integration Layer.

### Context Documents and example code
- For general EDP architecture: @docs\architecture\edp_platform_architecture.md
- For EDP Layered architecture specs: @docs\architecture\edp-layer-architecture-detailed.md
- For business vault design: @docs\engineering-knowledge-base\data-vault-2.0-guide.md
- When creating business rule documents use: @ai-resources\prompts\documentation\bizrules-documenter.md
- Example Input: @docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\input\network_set\dimNetworkSet.sql
- Example Output - mapping: @docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\network_set\mapping_edw2_refactor_network_set.csv
- Example Output - Business Rules Document: @docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\network_set\network_set_business_rules.md
- Example Output dbt Files: @docs\work-tracking\ai-transformation\use_cases\uc02_edw2_refactor\output\network_set

### Old Development Pattern

Each old dimensional artifact works similarly:

- uses a series of Wherescape transient stage tables and views to pull chunks of data from the raw vault, apply business rules and get the data ready to build the final artiofact
- Create a 'controller' for the artifact that has all the business rule applied records that need to be applied to the dimension or fact. For some artifacts, this is a full picture of the data, but some use an incremental load window depending on the data volume. This step is typically the one right before the proc to build the dimension, and in most cases should be modeled as a business vault computed satellite.
- Once the business vault objects have been created, the final step in the code is to create the master dimesional object.
- The goal is to modernize these models to align with the Data Vault 2.0 methodology, star schema dimensional modelling, and Snowflake-native performance patterns, using the automate_dv dbt package where applicable.

### Input/Output Specifications

- Inputs:
  - A prompt document containing relative path information for all legacy T-SQL stored procedures and views for a given dimensional artifact. These will be in sequnetial order as run in the legacy EDW environment.
  - Supporting architecture information including naming conventions, architecture layers, and business rules from the EDW2 environment.
  - mapping of old raw vault tables and columns to new raw vault tables and columns provide by the engineer after initial analysis

- Outputs:
  - Create output files in a folder named after the entity being refactored. For example, if refactoring the dimNetworkSet object, create a folder named `network_set` in the output path.
  - An incomplete mapping document for the raw vault translation with all EDW2 raw vault referencese for the current refactoring problem that an engineer can fill out with the analogous tables from the new raw vault. 
  - A list of recommended business vault objects.
  - dbt model SQL files using Snowflake SQL and automate_dv macros to build the business vault object.
  - dbt yml file for the dimensional object. Add descriptions for the table and columns that breifly describe the transformation of the columns and a consise description of the column purpose.
  - A mapping table of old-to-new source tables and columns.
- Edge Cases:
  - If a business rule is embedded in multiple layers of legacy code, flag it for engineer review.
  - If a source table or column cannot be mapped, prompt the engineer for clarification.

The workflow would go something like:

- generate a list of source tables and columns by anlyzing the provided old code. use a csv format
- have the engineer map the columns and tables to the new database objects.
- using the provided mapping, analyze the old code for business rules, potential wastefull compute, or opportunities to create a materialized business vault object.
- refactor the old code as CTEs and Snowflake SQL using dbt Cloud into dbt sql models for the business vault objects and EDW3 dimensional objects
- recommend tests appropriate for the dimensional model artifact in question.
- Create the folder if necessary and write the generated files to the following path: `docs\use_cases\uc02_edw2_refactor\output\<entity_name>`

## 🧱 Architecture Details

- **Platform**: Snowflake on AWS
- **Transformation Tool**: dbt Cloud
- **dbt Data Vault Package**: `automate_dv`
- **Source Systems**: `legacy_facets`, `gemstone_facets`, etc.

---

## 🔧 Generation Steps

### 1. Source Mapping

- **Purpose**: Generate a list of table and column mappings needed to map from the old raw vault source to the new raw vault source table names.
- **Logic**:
  - From the source code provided make a list of all the tables and source columns used in the code. Columns used to forward the data to the next stored proc or view . These should be raw vault artifacts and typically follow the naming patterns:
    - Satellites: `v_*_current`, or `v_s*_combined_current`
    - Reference: `v_r_*`
  - Save the output as a csv file named mapping_edw2_refactor_<entity_name>.csv: old_table_name,old_column_name
  - Pause here for the engineer to complete a mapping document based on this result, and verify that all dependencies are available

### 2. Mapping Validation

- **Purpose**: Verify that the submitted mapping is complete
- **Logic**:
  - When the engineer responds to step one with the mapping
  - check the mapping against the old source code for completeness

### 3. Business Vault Artifacts

- **Purpose**: Recommend missing business vault artifacts
- **Logic**:
  - analyze the old source code and the resulting dimensional artifact
  - recommend any business vault objects that should be created as part of the new code. Typically this would be a computed effectivity or standard satellite with any new business vault hubs or links needed, but perhaps a bridge, pit, etc. would be helpful.
  - Pause here for the engineer to give feedback and adjust the recommendation

### 4. Generate New Code

- **Purpose**: Generate the dbt code for the business vault object(s) and the dimensional artifact(s)
- **Logic**:
  - analyze the old source code, the mapping document, and the business vault recommendation
  - typically the steps would be:
    - prep_<entity_name>_business.sql or prep_<entity_name>.sql - prepare the data for business vault loading, this is where much of the business rule code would go. Use CTEs at the beginning of the dbt models as specified in the coding standards section
    - stg_<entity_name>_business.sql or stg_<entity_name>.sql - create hashkeys and hashdiff to load the business vault computed satellite or other business vault object
    - [bv_s,bv_brg,bv_h,bv_l,bv_pit]_<entity_name>.sql - load the business vault computed satellite or other business vault object using the automate_dv macros
  - Use the column mapping and code analysis results to create dbt models. Typically this would be a computed satellite and a dimension/fact, but this could be bridge or pit as well depending on the use case.
  - Pause here for the engineer to give feedback and adjust the recommendation

### 4. Testing Recommendations

- **Purpose**: Recommend automated tests that should be run with data loads
- **Logic**:
  - Analyze the generated dbt models
  - Generate a dbt model yml file with appropriate tests and descriptions for each of the dbt models

### 5. Business Rule Document

- **Purpose**: Document business rules applied in the transformations in the business vault and dimensional model in natural language as a markdown file for review by business data stewards and domain experts.
- **Logic**:
  - Analyze the generated dbt models and old code
  - Produce a document describing in natural language the source columns and transformations used to create each of the dimensional object columns that can be reviewed by the business

#### Business Rule Document Standards

**Naming Convention**:
- File should be named after the **entity** (not the technical model name)
- Remove technical prefixes like `ces_`, `sat_`, `dim_`, `fact_` from the filename
- Format: `<entity_name>_business_rules.md`
- Examples:
  - Model: `ces_member_cob_profile` → Document: `member_cob_profile_business_rules.md`
  - Model: `dim_member` → Document: `member_business_rules.md`
  - Model: `fact_claims` → Document: `claims_business_rules.md`

**Frontmatter Requirements**:
All business rule documents must include YAML frontmatter matching the architecture documentation format:

```yaml
---
title: "<Entity Name> Business Rules"
document_type: "business_rules"
business_domain: ["<domain1>", "<domain2>"]  # e.g., membership, claims, provider
edp_layer: "<layer>"  # e.g., business_vault, curation, dimensional
technical_topics: ["<topic1>", "<topic2>"]  # e.g., coordination-of-benefits, effectivity-satellite, data-vault-2.0
audience: ["<audience1>", "<audience2>"]  # e.g., claims-operations, business-analysts, data-stewards
status: "draft"  # draft | active | deprecated
last_updated: "YYYY-MM-DD"
version: "1.0"
author: "Dan Brickey"
description: "<One sentence description of what business rules this document covers>"
related_docs:
  - "<relative path to related doc 1>"
  - "<relative path to related doc 2>"
model_name: "<technical dbt model name>"  # e.g., ces_member_cob_profile
legacy_source: "<legacy source reference>"  # e.g., HDSVault.biz.spCOBProfileLookup
---
```

**Filing Workflow**:
1. **Generate**: Create business rule document in the use case output folder
   - Location: `docs\work_tracking\ai_transformation\use_cases\uc02_edw2_refactor\output\<entity_name>\<entity_name>_business_rules.md`
2. **Review**: Business stakeholders and data stewards review the draft
3. **Approve**: Update `status` field from `"draft"` to `"active"`
4. **File**: Move approved document to architecture rules folder
   - Target: `docs\architecture\rules\<domain>\<entity_name>_business_rules.md`
   - Domain folders: `membership`, `claims`, `provider`, `product`, `financial`, `broker`

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
- Handle nulls and edge cases.
- Maintain referential integrity.
- Implement incremental loading and error handling.

---
