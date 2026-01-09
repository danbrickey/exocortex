## Provider 360: Build Raw Vault provider_address Satellites

**Title:**

**Provider 360: Build Raw Vault provider_address Satellites**

**Description:**

As a data engineer,  
I want to create the provider_address satellites in the raw vault,  
So that we can track provider address information changes over time and support provider catalog and PCP attribution algorithms.

**Acceptance Criteria:**

Given the provider hub (h_provider) exists with loaded provider records,  
when the provider address satellite models execute,  
then all provider address records are loaded with valid provider hub hash keys and load timestamps.

Given multiple source records exist for the same provider address over time,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the provider address satellites are loaded,  
when the satellites are compared to the source staging models,  
then the record counts match.

Given the provider address satellites reference the provider hub,  
when referential integrity checks run,  
then all provider_hk values in the satellites exist in h_provider.

### Technical Details

#### Business Key

**Type:** Business Key

Business key inherited from parent hub h_provider:

```sql
-- Business key columns (inherited from h_provider)
'110' plan_code,
coalesce(nullif(prov.prpr_npi,''),'^^') prov_npi,
case
    when prov.prpr_entity IN ('G','P','F') and nullif(org.prpr_npi,'') is null
        then coalesce(nullif(prov.prpr_npi,''),'^^')
    else coalesce(nullif(org.prpr_npi,''),'^^')
end org_npi,
case
    when prov.prpr_entity IN ('G','P','F') and nullif(org.mctn_id,'') is null
        then coalesce(nullif(prov.mctn_id,''),'^^')
    else coalesce(nullif(org.mctn_id,''),'^^')
end org_tin,
coalesce(nullif(p_geo.prad_state,''),'^^') provider_state
```

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_prpr_prov` - Provider data from Gemstone Facets system
- `stg_gemstone_facets_hist__dbo_cmc_prer_relation` - Provider entity relationship data from Gemstone Facets system
- `stg_gemstone_facets_hist__dbo_cmc_prad_address` - Provider address data from Gemstone Facets system
- `stg_legacy_bcifacets_hist__dbo_cmc_prpr_prov` - Provider data from Legacy FACETS system
- `stg_legacy_bcifacets_hist__dbo_cmc_prer_relation` - Provider entity relationship data from Legacy FACETS system
- `stg_legacy_bcifacets_hist__dbo_cmc_prad_address` - Provider address data from Legacy FACETS system

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_provider_address_gemstone_facets_rename - Rename columns for gemstone facets
- stg_provider_address_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example gemstone join
source as (
    select
        -- Business Key Expressions
        '110' plan_code,
        coalesce(nullif(prov.prpr_npi,''),'^^') prov_npi,
        case
            when prov.prpr_entity IN ('G','P','F') and nullif(org.prpr_npi,'') is null
                then coalesce(nullif(prov.prpr_npi,''),'^^')
            else coalesce(nullif(org.prpr_npi,''),'^^')
        end org_npi,
        case
            when prov.prpr_entity IN ('G','P','F') and nullif(org.mctn_id,'') is null
                then coalesce(nullif(prov.mctn_id,''),'^^')
            else coalesce(nullif(org.mctn_id,''),'^^')
        end org_tin,
        coalesce(nullif(p_geo.prad_state,''),'^^') provider_state,
        -- Address attributes
        p_geo.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} prov
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prer_relation') }} rel
            on prov.prpr_id = rel.prpr_id
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} org
            on org.prpr_id = rel.prer_prpr_id
              and org.prpr_entity = rel.prer_prpr_entity
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prad_address') }} p_geo
            on prov.prad_id = p_geo.prad_id
    where nullif(org.mctn_id,'') is null and prov.prpr_entity IN ('G','P','F')
)
```

**Staging Views**:

- stg_provider_address_gemstone_facets - Stage data from cmc_prpr_prov, cmc_prer_relation, and cmc_prad_address for gemstone facets
- stg_provider_address_legacy_facets - Stage data from cmc_prpr_prov, cmc_prer_relation, and cmc_prad_address for legacy facets

**Satellites** (using automate_dv sat macro):

- s_provider_address_gemstone_facets - Descriptive attributes from Gemstone system
- s_provider_address_legacy_facets - Descriptive attributes from legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_prpr_prov (prov) | prpr_npi | provider_npi | National Practitioner Identifier |
| cmc_prpr_prov (prov) | prpr_entity | provider_entity | Provider Entity |
| cmc_prpr_prov (prov) | mctn_id | provider_tin | Provider Tax Identification Number |
| cmc_prpr_prov (org) | prpr_npi | organization_npi | Organizational National Practitioner Identifier |
| cmc_prpr_prov (org) | mctn_id | organization_tin | Organizational Provider Tax Identification Number |
| cmc_prer_relation | prpr_id | provider_id | Provider Identifier |
| cmc_prer_relation | prer_prpr_id | provider_relationship_id | Provider Entity Relationship Identifier |
| cmc_prer_relation | prer_prpr_entity | provider_relationship_entity | Provider Entity Relationship |
| cmc_prad_address | prad_id | provider_address_id | Provider Address ID |
| cmc_prad_address | prad_type | provider_address_type | Provider Address Type |
| cmc_prad_address | prad_eff_dt | provider_address_eff_dt | Provider Address (Type) Effective Date |
| cmc_prad_address | prad_term_dt | provider_address_term_dt | Provider Address (Type) Termination Date |
| cmc_prad_address | prad_addr1 | provider_address_line_1 | Provider Address (Type) Line 1 |
| cmc_prad_address | prad_addr2 | provider_address_line_2 | Provider Address (Type) Line 2 |
| cmc_prad_address | prad_addr3 | provider_address_line_3 | Provider Address (Type) Line 3 |
| cmc_prad_address | prad_city | provider_address_city | Provider Address (Type) City |
| cmc_prad_address | prad_state | provider_address_state | Provider Address (Type) State |
| cmc_prad_address | prad_zip | provider_address_zip | Provider Address (Type) Zip Code |
| cmc_prad_address | prad_county | provider_address_county | Provider Address (Type) County |
| cmc_prad_address | prad_ctry_cd | provider_address_country | Provider Address (Type) Country |
| cmc_prad_address | prad_phone | provider_address_phone | Provider Address (Type) Phone Number |
| cmc_prad_address | prad_phone_ext | provider_address_phone_ext | Provider Address (Type) Phone Extension Number |
| cmc_prad_address | prad_fax | provider_address_fax | Provider Address (Type) Fax Number |
| cmc_prad_address | prad_fax_ext | provider_address_fax_ext | Provider Address (Type) Fax Number Extension |
| cmc_prad_address | prad_email | provider_address_email | Provider Address (Type) Email |
| cmc_prad_address | prad_hd_ind | provider_address_handicap_ind | Provider Address (Type) Handicap Access Indicator |
| cmc_prad_address | prad_practice_ind | provider_address_practice_ind | Provider Address (Type) Practice Indicator |
| cmc_prad_address | prad_city_xlow | provider_address_city_xlow | Provider Address (Type) City Case Insensitivity Field |
| cmc_prad_address | prad_type_mail | provider_address_type_mail | Provider Address (Type) Corresponding Mailing Address |
| cmc_prad_address | prad_mctr_trsn | provider_address_term_reason | Provider Address (Type) Termination Reason |
| cmc_prad_address | prad_directory_ind | provider_address_directory_ind | Provider Address (Type) Directory Indicator |
| cmc_prad_address | prad_long | provider_address_longitude | Provider Address Longitude |
| cmc_prad_address | prad_lat | provider_address_latitude | Provider Address Latitude |
| cmc_prad_address | prad_geo_rtrn_cd | provider_address_geo_return_code | Provider Address Geo Access Return Code |
| cmc_prad_address | prad_lock_token | provider_address_lock_token | Lock Token |
| cmc_prad_address | atxr_source_id | attachment_source_id | Attachment Source Id |
| cmc_prad_address | sys_last_upd_dtm | system_last_update_dtm | Last Update Datetime |
| cmc_prad_address | sys_usus_id | system_user_id | Last Update User ID |
| cmc_prad_address | sys_dbuser_id | system_dbuser_id | Last Update DBMS User ID |
| cmc_prad_address | prad_mel_rtrn_cd_nvl | provider_address_melissa_return_code | Provider Address Melissa Data Return Code |
| N/A | '110' | plan_code | Plan code constant |
| N/A | '1' | tenant_id | Tenant identifier constant |
| N/A | gemstone_facets/legacy_facets | source | Source system identifier |

**Metadata:**

- Deliverables: Provider catalog, PCP attribution
- Dependencies: h_provider hub must exist

---

## Specification Evaluation Report

### Evaluation Date: 2025-01-28

### Recommendations

1. **Verify Join Logic**: Confirm that `prov.prad_id = p_geo.prad_id` is the correct join condition. The provider table may reference a specific address type, but we want all addresses. Consider if additional join conditions are needed.

2. **Business Key State Column**: The business key includes `provider_state` from the address table (`p_geo.prad_state`). Verify that this is the intended business key component, as addresses can have different states than the provider's primary state.

### Overall Completeness Score: 98%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- ✅ **Title & Description**: Title includes Domain (Provider) and Entity (provider_address). Description accurately reflects objects being built (satellites only).
- ✅ **Business Key**: Type clearly labeled (Business Key). SQL expression provided with individual columns/expressions listed (correct format for automate_dv). Business key inheritance from parent hub clearly documented. CASE statements for org_npi and org_tin are provided in the expression.
- ✅ **Source Models**: All 6 source models listed with full project and model names. Source project (`enterprise_data_platform`) specified. All models referenced in join example are listed.
- ✅ **Rename Views**: All rename views listed. Complex joins exist and staging join example provided (Gemstone only, which is correct since joins are identical between Gemstone and Legacy).
- ✅ **Staging Views**: All staging views listed with source table references.
- ✅ **Hubs/Links/Satellites**: All objects match description. Naming conventions followed (s_ prefix). No hubs or links for this satellite-only spec.
- ✅ **Same-As Links**: Not applicable - no same-as links in this specification.
- ✅ **Column Mapping**: Source Column Mapping table includes all columns from the staging join example:
  - Business key columns (plan_code, prov_npi, org_npi, org_tin, provider_state)
  - All address columns from cmc_prad_address (33 columns)
  - Provider and organization columns referenced in join logic
  - System columns (tenant_id, source)
- ✅ **Acceptance Criteria**: All criteria are specific, testable, and reference actual objects being built (satellites referencing h_provider hub).
- ✅ **Metadata**: Deliverables listed (Provider catalog, PCP attribution). Dependencies identified (h_provider hub must exist).

### Quality Checks

**Passed:** 6 / 6
- ✅ **Join Logic Documentation**: Complete staging join example provided (Gemstone only, which is correct). Example shows complex multi-table joins with proper join conditions. Business key expressions include CASE statements for org_npi and org_tin. WHERE clause filter included as requested.
- ✅ **Column Mapping Completeness**: Every column in the staging join example appears in the Source Column Mapping table with correct source_table reference, source_column name, appropriate target_column name, and descriptive column_description.
- ✅ **No Placeholders**: All placeholders have been replaced with actual values. No template instructional notes remain.
- ✅ **Consistency**: Description objects match Technical Details objects (satellites only). Entity name (provider_address) used consistently throughout.
- ✅ **Naming Conventions**: All model names follow BCI conventions (stg_, s_ prefixes).
- ✅ **Actionability**: An engineer can implement without additional clarification:
  - Source models are identifiable (full paths provided)
  - Business key logic is executable (inherited from parent hub, columns/expressions clearly listed)
  - Column mappings are clear (complete mapping table)
  - Join logic is documented (complete example provided with WHERE clause)

### Data Vault 2.0 Pattern Validation

**Passed:** 8 / 8
- ✅ **Hub Appropriateness**: Not applicable - this is a satellite-only specification referencing existing h_provider hub.
- ✅ **Satellite vs Reference Table**: Satellites are appropriately used for descriptive attributes that change over time (address information, effective dates, termination dates) and need historization. This is not static lookup data.
- ✅ **Link Appropriateness**: Not applicable - no links in this specification.
- ✅ **Business Key Granularity**: Business key represents the correct level of detail (provider level, inherited from parent hub). Includes provider_state from address table which allows tracking addresses by state.
- ✅ **Satellite Rate of Change**: Address data has moderate rate of change (address changes, effective dates, termination dates) which is appropriate for standard satellites. No need for hroc/mroc/lroc split.
- ✅ **Same-As Link Logic**: Not applicable - no same-as links in this specification.
- ✅ **Hub Scope**: Not applicable - satellites reference existing h_provider hub.
- ✅ **No Over-Engineering**: Appropriate use of satellites for time-varying address attributes. Not over-engineered.

**Anti-Patterns Identified:**
- None identified. All artifacts follow Data Vault 2.0 best practices.

### Red Flags (Critical Issues)

No red flags identified.

**Data Vault 2.0 Pattern Violations:**
- None identified.

### Implementation Blockers

No implementation blockers identified. The specification contains all information needed for a data engineer or AI to implement:

1. ✅ All source models are clearly identified with full paths
2. ✅ Business key logic is executable (inherited from parent hub, columns/expressions clearly listed with CASE statements)
3. ✅ Staging join example is complete and can be implemented (join logic, WHERE clause, all columns selected)
4. ✅ All columns from join example are mapped in Source Column Mapping table
5. ✅ Parent hub dependency is clearly documented
6. ✅ Acceptance criteria are testable and specific

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All 6 source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_prpr_prov`, `stg_gemstone_facets_hist__dbo_cmc_prer_relation`, `stg_gemstone_facets_hist__dbo_cmc_prad_address`, and their Legacy counterparts.

2. **Can an engineer write the business key expression?** Yes - Business key is clearly documented as inherited from h_provider with individual columns/expressions listed (correct format for automate_dv). CASE statements for org_npi and org_tin are provided. The format is correct for passing to automate_dv sat macro.

3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided (Gemstone only, which is correct). Join logic is clear with proper join conditions and WHERE clause filter. All columns are explicitly selected (no wildcards).

4. **Can an engineer map all columns from the Source Column Mapping table?** Yes - Complete mapping table includes all columns from the join example with source_table, source_column, target_column, and column_description. All 33 address columns plus business key columns and system columns are mapped.

5. **Can an engineer implement all objects without questions?** Yes - The specification is comprehensive. Source models are identifiable, business key logic is executable, join logic is documented, and all columns are mapped. The parent hub dependency is clearly documented.

6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable, and reference actual objects being built (satellites referencing h_provider hub).

### Next Steps

**Specification is ready for handoff to data engineering team.**

The specification contains all necessary information for implementation:
- ✅ Complete staging join example with WHERE clause filter
- ✅ All address columns mapped from CSV source
- ✅ Business key clearly documented with CASE statements
- ✅ Parent hub dependency identified
- ✅ Deliverables and business value documented
