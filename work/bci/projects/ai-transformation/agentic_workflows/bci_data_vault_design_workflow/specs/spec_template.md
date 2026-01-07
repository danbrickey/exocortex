## [Domain] 360: Build Raw Vault [Entity] Hub and Satellites

**Note:** [Domain] refers to the business domain (e.g., Provider, Member, Claim). [Entity] refers to the specific hub/satellite entity being built (e.g., provider, member, practitioner, claim_line).

**Title:**

**[Domain] 360: Build Raw Vault [Entity] Hub and Satellites**

**Description:**

As a data engineer,  
I want to [create/refactor] the [entity] [objects] in the raw vault,  
So that we can [business value].

**Note:** [objects] should match what's defined in Technical Details below. Examples:
- "hub, links, and satellites" (if all three are present)
- "hub and satellites" (if hub and satellites only)
- "satellites" (if satellites only, referencing existing hub)
- "link" (if link only)

**Acceptance Criteria:**

Given source data is loaded to staging views,  
when the hub model executes,  
then all unique [entity] business keys are loaded with valid hash keys and load timestamps.

Given multiple source records exist for the same [entity],  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the hub is loaded,  
when the hub is compared to source [entity] records,  
then the key counts in the hub match the source records.

Given the same-as link is populated,  
when the link is compared to the source data,
then all [entity] records are linked across source systems with valid hub references.

### Technical Details

#### Business Key

**Type:** [Polymorphic Business Key / Business Key]

**Note:** For automate_dv implementation, business keys should be specified as a list of individual columns/expressions, not as a concatenated expression. The automate_dv hub macro accepts multiple business key columns and handles the concatenation internally.

**Agent Note:** This automate_dv note is for agent guidance only and should NOT appear in the final engineering specification. Engineers already understand how to use automate_dv, so remove this note when generating the spec.

- **For multi-column business keys**: List each column/expression separately (one per line)
- **For polymorphic business keys**: Provide the case statement or conditional logic showing how the key varies based on field contents
- **For simple business keys**: List the column(s) directly

```sql
-- Example: Multi-column business key (for automate_dv)
'110' plan_code,
coalesce(nullif(prov.prpr_npi,''),'^^') prov_npi,
coalesce(nullif(org.prpr_npi,''),'^^') org_npi,
coalesce(nullif(org.mctn_id,''),'^^') org_tin,

-- Example: Polymorphic business key (case statement)
case 
  when coalesce(prac.prcp_npi,'') <> '' 
    then prac.prcp_npi 
  when coalesce(prac.prcp_npi,'') = '' and coalesce(prac.prcp_ssn,'') <> ''
    then prac.prcp_ssn || '|' || prac.prcp_last_name || '|' || left(trim(prac.prcp_first_name),1) || '|' || to_char(prac.prcp_birth_dt, 'YYYYMMDD')
  else prac.prcp_last_name || '|' || left(trim(prac.prcp_first_name),1) || '|' || to_char(prac.prcp_birth_dt, 'YYYYMMDD')
end as practitioner_business_key

-- Example: Simple business key
subscriber_id,
member_suffix
```

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_[source_system]_facets_hist__dbo_[table_name]` - [description]
- `stg_[source_system]_facets_hist__dbo_[table_name]` - [description]

**Note:** List all source models referenced in the staging join example or mentioned elsewhere in this specification.

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_[entity]_gemstone_facets_rename - Rename columns for gemstone facets
- stg_[entity]_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

**Note:** Since Legacy and Gemstone are instances of the same application code, the join logic is usually identical. Only include a Legacy example if the join logic differs from Gemstone. If the joins are the same, include only the Gemstone example below. The Legacy rename view will follow the same pattern, referencing `stg_legacy_bcifacets_hist__dbo_*` models instead of `stg_gemstone_facets_hist__dbo_*`.

```sql
-- Example gemstone join
source as (
    select
      -- Business Key Expressions
      [business_key_columns],
      [other_columns]
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_[source_table]') }} [alias]
    [join logic]
)
```

[If join logic differs between Gemstone and Legacy, include Legacy example here:
```sql
-- Example legacy join (only include if join logic differs from Gemstone)
source as (
    select
      -- Business Key Expressions
      [business_key_columns],
      [other_columns]
    from {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_[source_table]') }} [alias]
    [different join logic]
)
```
]

**Staging Views**:

- stg_[entity]_gemstone_facets - Stage data from [source_table] for gemstone facets
- stg_[entity]_legacy_facets - Stage data from [source_table] for legacy facets

**Hubs** (using automate_dv hub macro):

- h_[entity] - Hub for [entity] business key

**Satellites** (using automate_dv sat macro):

- s_[entity]_gemstone_facets - Descriptive attributes from Gemstone system
- s_[entity]_legacy_facets - Descriptive attributes from legacy system

**Same-As Links** (using automate_dv link macro):

- sal_[entity]_facets - Same-as link for [entity] identity resolution [description of resolution logic]. **Note**: the staging view should have a hash expression for the sal_[entity]_facets_hk column.

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| ... | ... | ... | ... |

**Metadata:**

- Deliverables: [list]
- Dependencies: [list, if applicable]

---

## Specification Evaluation Rubric

**Note:** This section is used by the spec generator agent for automatic evaluation. Remove this entire section before handing off the specification to the data engineering team.

**Purpose:** Use this rubric to validate specification completeness before handoff to data engineering team. Each item should be verified.

### Completeness Checks

- [ ] **Title & Description**: Title includes Domain and Entity. Description accurately reflects objects being built (hub/links/satellites).
- [ ] **Business Key**: Type clearly labeled (Polymorphic vs Business Key). SQL expression provided and complete. For multi-column business keys, individual columns/expressions are listed (not concatenated), which is the correct format for automate_dv macros. For polymorphic business keys, the complete case statement/conditional expression is provided.
- [ ] **Source Models**: All source models listed with full project and model names. Source project specified.
- [ ] **Rename Views**: All rename views listed. If complex joins exist, staging join example provided. If Gemstone and Legacy joins are identical, only Gemstone example included (Legacy follows same pattern with `stg_legacy_bcifacets_hist__dbo_*` models).
- [ ] **Staging Views**: All staging views listed with source table references.
- [ ] **Hubs/Links/Satellites**: All objects match description. Naming conventions followed (h_, s_, sal_).
- [ ] **Same-As Links**: Resolution logic described. Note about hash expression included if applicable.
- [ ] **Column Mapping**: Source Column Mapping table includes all columns referenced in:
  - Business key expressions
  - Staging join example (if provided)
  - Any columns mentioned in Technical Details
- [ ] **Acceptance Criteria**: All criteria are specific, testable, and reference actual objects being built.
- [ ] **Metadata**: Deliverables listed. Dependencies identified if any exist.

### Quality Checks

- [ ] **Join Logic Documentation**: If staging join example includes multiple tables or complex logic, example is provided and complete.
- [ ] **Column Mapping Completeness**: Every column in the staging join example appears in the Source Column Mapping table with:
  - Correct source_table reference
  - Correct source_column name
  - Appropriate target_column name
  - Descriptive column_description
- [ ] **No Placeholders**: All [bracketed placeholders] have been replaced with actual values.
- [ ] **Consistency**: Description objects match Technical Details objects. Entity name used consistently throughout.
- [ ] **Naming Conventions**: All model names follow BCI conventions (stg_, h_, s_, sal_ prefixes).
- [ ] **Actionability**: An engineer can implement without additional clarification:
  - Source models are identifiable
  - Business key logic is executable
  - Column mappings are clear
  - Join logic is documented (if complex)

### Red Flags (Must Address Before Handoff)

- ⚠️ **Missing Join Example**: Complex joins exist but no example provided
- ⚠️ **Duplicate Join Examples**: Both Gemstone and Legacy examples included when join logic is identical (should only include Gemstone example when joins are the same)
- ⚠️ **Incomplete Column Mapping**: Columns referenced in join example missing from mapping table
- ⚠️ **Ambiguous Business Key**: Business key expression unclear or incomplete
- ⚠️ **Incorrect Business Key Format**: Multi-column business key shown as concatenated expression instead of individual columns (automate_dv expects individual columns for multi-column keys)
- ⚠️ **Mismatched Objects**: Description says "hub and satellites" but Technical Details only shows satellites
- ⚠️ **Placeholders Remaining**: Any [placeholder] text still present
- ⚠️ **Missing Source References**: Source models listed without project or full model path

### Data Vault 2.0 Pattern Validation

**Purpose:** Validate that artifacts follow Data Vault 2.0 best practices and are appropriately modeled.

- [ ] **Hub Appropriateness**: Hub represents a significant business entity (member, provider, claim). Not a micro-concept that should be an attribute.
- [ ] **Satellite vs Reference Table**: 
  - Satellites are used for descriptive attributes that change over time and need historization
  - Reference tables (`r_`) should be used for static lookup data, code tables, or data that doesn't need history
  - If satellite contains only static lookup values, consider if it should be a reference table instead
- [ ] **Link Appropriateness**: Link represents a relationship between two or more hubs. Not a single entity that should be a hub.
- [ ] **Business Key Granularity**: Business key represents the correct level of detail (grain) for the entity.
- [ ] **Satellite Rate of Change**: If satellite has very high rate of change, consider splitting into multiple satellites by rate of change (hroc/mroc/lroc).
- [ ] **Same-As Link Logic**: Same-as link logic is appropriate for identity resolution across systems, not for simple relationships.
- [ ] **Hub Scope**: Hub represents a business concept that exists across multiple source systems or has significant business importance.
- [ ] **No Over-Engineering**: Simple concepts aren't over-engineered (e.g., a simple code table doesn't need a hub with satellites).

**Common Anti-Patterns to Flag:**

- ⚠️ **Satellite Should Be Reference**: Static code/lookup data defined as satellite (should be `r_` reference table)
- ⚠️ **Hub Too Granular**: Micro-concept given its own hub when it should be an attribute or part of another hub
- ⚠️ **Missing Reference Table**: Static lookup data that should be a reference table is defined as satellite
- ⚠️ **Link Misused**: Single entity relationship that should be a hub, or simple attribute relationship that doesn't need a link
- ⚠️ **Over-Engineering**: Simple concept unnecessarily complex (e.g., hub for a single-attribute code table)

### Pre-Handoff Questions

Before handing off to data engineering team, confirm:

1. Can an engineer identify all source models from the information provided?
2. Can an engineer write the business key expression from the specification?
3. Can an engineer build the staging join from the example (if provided)?
4. Can an engineer map all columns from the Source Column Mapping table?
5. Can an engineer implement all objects (hubs/links/satellites) without asking questions?
6. Are acceptance criteria testable and specific enough for QA validation?

**Specification Status:** [ ] Ready for Handoff | [ ] Needs Revision
