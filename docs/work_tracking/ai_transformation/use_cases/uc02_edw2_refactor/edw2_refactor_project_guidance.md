# Kimball Dimensional Model Generation Request

## 📘 Project Purpose and Goals

### Purpose

We aim to automate the refactoring of legacy SQL Server-based dimensional models (EDW2) into dbt models for Snowflake (EDW3). When I use the term EDW2 I am refering to the legacy code from Wherescape/SQL Server, when I use the term EDW3, that refers to the new Snowflake implementation of our dimensional model and business vault. The legacy models were generated using Wherescape RED and are tightly coupled to an on-prem SQL Server environment. The goal is to modernize these models to align with the Data Vault 2.0 methodology and Snowflake-native performance patterns, using the automate_dv dbt package where applicable. The refactored EDW3 artifacts would live in the Curation Layer and pull data from the raw vault in the Integration Layer.

### Context Documents and example code
- @docs\architecture\edp_platform_architecture.md
- @docs\architecture\edp-layer-architecture-detailed.md
- @docs\engineering-knowledge-base\data-vault-2.0-guide.md
- @docs\use_cases\uc02_edw2_refactor\examples\input_example_edw2_refacor_dim_class_type_old_code.md
- @docs\use_cases\uc02_edw2_refactor\examples\input_example_edw2_refacor_dim_class_type mappings.csv

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
  - Display this list in a code block that can be copied in csv ready format: old_table_name,old_column_name
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
  - Use the column mapping and code analysis results to create dbt models. Typically this would be a computed satellite and a dimension/fact.
  - Use CTEs at the beginning of the dbt models as specified in the coding standards section
  - Pause here for the engineer to give feedback and adjust the recommendation

### 4. Testing Recommendations

- **Purpose**: Recommend automated tests that should be run with data loads
- **Logic**:
  - Analyze the generated dbt models
  - Generate a dbt model yml file with appropriate tests and descriptions for each of the dbt models

### 5. Business rule document

- **Purpose**: Document business rules applied in the transformations in the business vault and dimensional model in natural language as a markdown file for review by business data stewards and domain experts.
- **Logic**:
  - Analyze the generated dbt models and old code
  - Produce a document describing in natural the source columns and transformations used to create each of the dimensional object columns that can be reviewed by the business

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
