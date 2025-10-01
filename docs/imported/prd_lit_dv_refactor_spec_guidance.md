# Data Vault Metadata Generation from Existing dbt Models

# Request:

## Please analyze the provided dbt model sql code for the existing entity and generate:

A concise engineering specification file in Markdown format for data engineers
This output will support the generation of Data Vault 2.0 models (hubs, links, satellites) and backward-compatible current views using the dbt package automate_dv.

## Prompt info

**1. Expected Artifacts:**

- Provided in prompt - a list of the hubs, links, satellites, and other artifacts expected for this entity

**2. Data Dictionary:**

- Provided in prompt - a csv list of source table and column names with logical descriptions and datatypes

**3. Legacy Code:**

- Provided in prompt - sql file with legacy dbt model code

## Attachments Checklist

**1. Architecture specifications:**

- general architecture conventions for our solution

**2. Project guidance:**

- this document. guidance for this particular task

**3. Project example:**

- an example of the inputs that will be provided and the outputs that should be produced by this task

## Analysis Requirements

**1. Entity Identification:**

- Determine if the model represents a hub, link, or satellite.
- Extract the primary business entity name.
- Identify any related entities (for links).

**2. Business Key Analysis:**

- Identify business key column(s) from primary keys, unique constraints, or logical grouping
- Include source_system as part of the business key
- Detect composite or derived business keys.
- Do not use the existing columns name `*_ik` for the data vault objects.

**3. Source System Detection:**

- Identify all source tables referenced in FROM/JOIN clauses
- Map source tables to known source systems (e.g. `legacy_facets`, `gemstone_facets`)
- Determine staging table names using the pattern: `stg_*_<entity>_<source_system>`

**4. Column Naming Conventions:**

- use the suffix `_bk` to name business keys
- use the suffix `_dt` for date columns
- use the suffix `_dtm` for timestamp columns

- **5. Column Mapping Extraction:**
- Use the data dictionary info included to generate new column names that are more human readable, but not too long using the logical column names
- generate a rename query in the format <old_column_name> AS <new_column_name>
- generate a payload column list in yml format like " - "new_column_name"
- Map each SELECT column to its source column or expression
- Identify aliases, transformations, and derived expressions
- Identify columns that are derived as opposed to being included with no transformation
- Include the hub key expression in automate_dv format
- Identify load_datetime and source columns from edp_start_dt and source_system

**6. Satellite Grouping Strategy:**

- Group columns into logical satellites by source system
- Identify hashdiff columns (attributes that change together)
- Classify satellite type:
- Standard (default)
- Effectivity (if business effectivity columns exist)
- Multi-active (if sequence/collision columns exist)

**7. EDP and Load Date Handling:**

- Use edp_start_dt as the load timestamp (ldts)
- Ignore edp_end_dt in Data Vault modeling
- Include edp_record_status and edp_record_source in satellite payload

**8. Filter and Condition Analysis:**

- Extract WHERE clause filters
- Identify incremental logic using edp_start_dt
- Note any data quality filters

**9. Current View Requirements:**

- Generate a current view that unions all satellite sources
- Use the business keys (including source_system) to select the latest record

**10. Testing and documentation:**

- Generate tests based on both the yml info provided for the existing entity and tests that are recommended for data vault 2.0 artifacts.

## Output Format

Generate this output with the following format:

# Data Vault Engineering Spec – <entity>

## 🧱 Artifact Summary

- **Entity Type**: Hub / Satellite / Current View
- **Source Table**: Name of source table
- **Rename Model(s)**:
  - `stg_<entity>_legacy_facets_rename`
  - `stg_<entity>_gemstone_facets_rename`
- **Staging Model(s)**:
  - `stg_<entity>_legacy_facets`
  - `stg_<entity>_gemstone_facets`
- **Hub Name**: `h_<entity>`
- **Link Name**: `l_<entity1>_<entity2>`
- **Satellite(s)**:
  - `s_<entity>_legacy_facets`
  - `s_<entity>_gemstone_facets`
- **Effectivity Satellite(s)**:
  - `s_<entity>_legacy_facets`
  - `s_<entity>_gemstone_facets`
- **Current View**: `current_<entity>`
- **Source System(s)**: `legacy_facets`, `gemstone_facets`

### Rename Views

- **Rename Query**: a query to create a renamed version of the source columns prior to the staging model

### 🧱 Staging Models

- **Source Model Name**: `<staging_model_name>`
- **Source System**: `<source_system>`
- **Derived Columns**:
  - `<column_name>`: `<insert full expression here>`
- **Hashed Columns**:
- `<business_key_column_1>`
- `<business_key_column_2>`
  - `<column_name>`

### 🏛️ Hub

- **Hub Hash Key**: `<entity>_hk`
- **Natural Business Key**:
  - `<business_key_column>`
- **Load Timestamp**: `<ldts_column>`
- **Source System**: `<source_system>`
- **Source Model (Staging View)**: `<staging_model_name>`

### 🔗 Link

- **Link Hash Key**: `<link_hash_key>`
- **Foreign Hub Keys**:
  - `<hub_key_1>`
  - `<hub_key_2>`
- **Load Timestamp**: `<ldts_column>`
- **Source System**: `<source_system>`
- **Source Model (Staging View)**: `<staging_model_name>`

### 🛰️ Satellites

- **Hub or Link Key**: `<parent_hash_key>`
- **Hashdiff Columns**:
  - `<column_name>`
- **Payload Columns**:
  - `<column_name>`
- **Effective Date**: `<effective_date_column>` (if applicable)
- **Load Timestamp**: `<ldts_column>`
- **Source System**: `<source_system>`
- **Source Model (Staging View)**: `<staging_model_name>`

### 📄 Current View

- **Naming**: `cv_<entity_name>`
- **Base Hub**: `<hub_model_name>`
- **Satellites Joined**:
  - `<satellite_model_name>`
- **Load Timestamp Column**: `<ldts_column>`
- **Business Keys**:
  - `<business_key_column>`
- **Logic**: Select latest record per business key + source system

## ⏱️ Recommended tests

- [x] `<test_1>`
- [x] `<test_2>`
