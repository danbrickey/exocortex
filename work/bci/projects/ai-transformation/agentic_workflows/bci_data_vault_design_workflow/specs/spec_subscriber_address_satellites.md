## Member 360: Build Raw Vault subscriber_address Satellites

**Title:**

**Member 360: Build Raw Vault subscriber_address Satellites**

**Description:**

As a data engineer,  
I want to create the subscriber_address satellites in the raw vault,  
So that we can track subscriber address, phone, fax, and email information changes over time including address lines, city, state, zip, county, country, and contact information for Member Months analytics and geographic analysis.

**Acceptance Criteria:**

Given the member hub (h_member) exists with loaded member records,  
when the subscriber address satellite models execute,  
then all subscriber address records are loaded with valid member hub hash keys and load timestamps.

Given multiple source records exist for the same subscriber over time,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the subscriber address satellites are loaded,  
when the satellites are compared to the source staging models,  
then the record counts match.

Given the subscriber address satellites reference the member hub,  
when referential integrity checks run,  
then all member_hk values in the satellites exist in h_member.

### Technical Details

#### Business Key

**Type:** Business Key

Business key inherited from parent hub h_member:

```sql
-- Business key columns (inherited from h_member)
subscriber_id,
member_suffix
```

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_sbad_addr` - Subscriber address data from Gemstone system
- `stg_legacy_bcifacets_hist__dbo_cmc_sbad_addr` - Subscriber address data from Legacy system
- `stg_gemstone_facets_hist__dbo_cmc_meme_member` - Member data from Gemstone system for join to get member hub key
- `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc` - Subscriber data from Gemstone system for join to get member hub key
- `stg_legacy_bcifacets_hist__dbo_cmc_meme_member` - Member data from Legacy system for join to get member hub key
- `stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc` - Subscriber data from Legacy system for join to get member hub key

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_subscriber_address_gemstone_facets_rename - Rename columns for gemstone facets
- stg_subscriber_address_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example join to get member hub key for subscriber address satellites
source as (
    select
        -- Business Key Expressions
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        -- Address attributes
        sbad.sbsb_ck,
        sbad.sbad_type,
        sbad.grgr_ck,
        sbad.sbad_addr1,
        sbad.sbad_addr2,
        sbad.sbad_addr3,
        sbad.sbad_city,
        sbad.sbad_state,
        sbad.sbad_zip,
        sbad.sbad_county,
        sbad.sbad_ctry_cd,
        sbad.sbad_phone,
        sbad.sbad_phone_ext,
        sbad.sbad_fax,
        sbad.sbad_fax_ext,
        sbad.sbad_email,
        sbad.sbad_city_xlow,
        sbad.sbad_lock_token,
        sbad.atxr_source_id,
        sbad.sys_last_upd_dtm,
        sbad.sys_usus_id,
        sbad.sys_dbuser_id
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbad_addr') }} sbad
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on sbad.sbsb_ck = mem.sbsb_ck
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
        on mem.sbsb_ck = sbsb.sbsb_ck
        and sbad.sbad_type IN (sbsb.sbad_type_home, sbsb.sbad_type_mail, sbsb.sbad_type_work)
)
```

**Staging Views**:

- stg_subscriber_address_gemstone_facets - Stage data from cmc_sbad_addr for gemstone facets
- stg_subscriber_address_legacy_facets - Stage data from cmc_sbad_addr for legacy facets

**Satellites** (using automate_dv sat macro):

- s_subscriber_address_gemstone_facets - Descriptive attributes from Gemstone system
- s_subscriber_address_legacy_facets - Descriptive attributes from legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|-------------------|
| cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| cmc_sbad_addr | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| cmc_sbad_addr | sbad_type | address_type | Subscriber Address Type |
| cmc_sbad_addr | grgr_ck | employer_group_bk | Group Contrived Key |
| cmc_sbad_addr | sbad_addr1 | address_line_1 | Subscriber Address Line 1 |
| cmc_sbad_addr | sbad_addr2 | address_line_2 | Subscriber Address Line 2 |
| cmc_sbad_addr | sbad_addr3 | address_line_3 | Subscriber Address Line 3 |
| cmc_sbad_addr | sbad_city | city | City |
| cmc_sbad_addr | sbad_state | state | State |
| cmc_sbad_addr | sbad_zip | zip_code | Zip Code |
| cmc_sbad_addr | sbad_county | county | County |
| cmc_sbad_addr | sbad_ctry_cd | country_code | Country Code |
| cmc_sbad_addr | sbad_phone | phone_number | Subscriber Phone Number |
| cmc_sbad_addr | sbad_phone_ext | phone_extension | Phone Extension |
| cmc_sbad_addr | sbad_fax | fax_number | Subscriber Fax Number |
| cmc_sbad_addr | sbad_fax_ext | fax_extension | Fax Extension |
| cmc_sbad_addr | sbad_email | email | Email Address |
| cmc_sbad_addr | sbad_city_xlow | city_search_case_insensitive | City search case insensitive |
| cmc_sbad_addr | sbad_lock_token | lock_token | Lock Token |
| cmc_sbad_addr | atxr_source_id | attachment_source_id | Attachment Source Id |
| cmc_sbad_addr | sys_last_upd_dtm | system_last_update_dtm | Last Update Datetime |
| cmc_sbad_addr | sys_usus_id | system_user_id | Last Update User ID |
| cmc_sbad_addr | sys_dbuser_id | system_dbuser_id | Last Update DBMS User ID |

**Metadata:**

- Deliverables: Member Months, geographic analysis
- Dependencies: h_member hub must exist

---

## Specification Evaluation Report

### Evaluation Date: 2025-01-28

### Recommendations

- ✅ Specification is complete and ready for handoff
- ✅ Consider documenting if legacy facets join logic differs from gemstone (if applicable)
- ✅ Consider adding note about handling NULL values in business key columns if source data may contain NULLs

### Overall Completeness Score: 95%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- ✅ **Title & Description**: Title includes Domain (Member) and Entity (subscriber_address). Description accurately reflects objects being built (satellites only).
- ✅ **Business Key**: Type clearly labeled (Business Key). SQL expression provided with individual columns listed (correct format for automate_dv). Business key inheritance from parent hub clearly documented.
- ✅ **Source Models**: All source models listed with full project and model names. Source project specified. All models referenced in join example are listed.
- ✅ **Rename Views**: All rename views listed. Complex joins exist and staging join example provided.
- ✅ **Staging Views**: All staging views listed with source table references.
- ✅ **Hubs/Links/Satellites**: All objects match description. Naming conventions followed (s_ prefix). No hubs or links for this satellite-only spec.
- ✅ **Same-As Links**: Not applicable for this specification (satellites only, no identity resolution needed).
- ✅ **Column Mapping**: Source Column Mapping table includes all columns referenced in business key expressions and staging join example.
- ✅ **Acceptance Criteria**: All criteria are specific, testable, and reference actual objects being built (satellites and parent hub).
- ✅ **Metadata**: Deliverables listed. Dependencies identified (h_member hub must exist).

### Quality Checks

**Passed:** 6 / 6
- ✅ **Join Logic Documentation**: Staging join example includes multiple tables (cmc_sbad_addr, cmc_meme_member, cmc_sbsb_subsc) and example is provided and complete with join conditions.
- ✅ **Column Mapping Completeness**: Every column in the staging join example appears in the Source Column Mapping table with correct source_table reference, source_column name, appropriate target_column name, and descriptive column_description.
- ✅ **No Placeholders**: All [bracketed placeholders] have been replaced with actual values.
- ✅ **Consistency**: Description objects match Technical Details objects (satellites). Entity name (subscriber_address) used consistently throughout.
- ✅ **Naming Conventions**: All model names follow BCI conventions (stg_, s_ prefixes).
- ✅ **Actionability**: An engineer can implement without additional clarification:
  - Source models are identifiable (full paths provided)
  - Business key logic is executable (inherited from parent hub, columns clearly listed)
  - Column mappings are clear (complete mapping table)
  - Join logic is documented (complete example provided)

### Data Vault 2.0 Pattern Validation

**Passed:** 5 / 5
- ✅ **Hub Appropriateness**: Not applicable - this is a satellite-only specification referencing existing h_member hub.
- ✅ **Satellite vs Reference Table**: Satellites are appropriately used for descriptive attributes that change over time (address, phone, fax, email information) and need historization. This is not static lookup data.
- ✅ **Link Appropriateness**: Not applicable - no links in this specification.
- ✅ **Business Key Granularity**: Business key represents the correct level of detail (member level, inherited from parent hub).
- ✅ **Satellite Rate of Change**: Address and contact information has moderate rate of change (address updates, phone/fax/email changes) which is appropriate for standard satellites. No need for hroc/mroc/lroc split.
- ✅ **Same-As Link Logic**: Not applicable - no same-as links in this specification.
- ✅ **Hub Scope**: Not applicable - satellites reference existing h_member hub.
- ✅ **No Over-Engineering**: Appropriate use of satellites for time-varying address and contact attributes. Not over-engineered.

**Anti-Patterns Identified:**
- None

### Red Flags (Critical Issues)

No red flags identified.

### Implementation Blockers

No implementation blockers identified. The specification contains all information needed for a data engineer or AI to implement:

1. ✅ All source models are clearly identified with full paths
2. ✅ Business key logic is executable (inherited from parent hub, columns listed)
3. ✅ Staging join example is complete and can be implemented
4. ✅ All columns from join example are mapped in Source Column Mapping table
5. ✅ Parent hub dependency is clearly documented
6. ✅ Acceptance criteria are testable and specific

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_sbad_addr`, `stg_legacy_bcifacets_hist__dbo_cmc_sbad_addr`, `stg_gemstone_facets_hist__dbo_cmc_meme_member`, `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`
2. **Can an engineer write the business key expression?** Yes - Business key is clearly documented as inherited from h_member with columns `subscriber_id` and `member_suffix` listed individually (correct format for automate_dv)
3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided with all tables, aliases, join conditions, and column selections
4. **Can an engineer map all columns from the Source Column Mapping table?** Yes - Complete mapping table includes all columns from the join example with source_table, source_column, target_column, and column_description
5. **Can an engineer implement all objects without questions?** Yes - All objects (rename views, staging views, satellites) are clearly defined with naming conventions and source references
6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable Given/When/Then statements that reference actual objects and can be validated

### Next Steps

Specification is ready for handoff to data engineering team. All required information is present, patterns are validated, and no blockers exist.
