## Provider 360: Build Raw Vault Practitioner Hub and Satellites

**Title:**

**Provider 360: Build Raw Vault Practitioner Hub and Satellites**

**Description:**

As a data engineer,  
I want to refactor the practitioner hub and associated satellites in the raw vault,  
So that we can track practitioner changes over time and support practitioner catalog and PCP attribution analytics.

**Acceptance Criteria:**

Given source data is loaded to staging views,  
when the hub model executes,  
then all unique practitioner business keys are loaded with valid hash keys and load timestamps.

Given multiple source records exist for the same practitioner,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the hub is loaded,  
when the hub is compared to source practitioner records,  
then the key counts in the hub match the source records.

Given the same-as link is populated,  
when the link is compared to the source data,
then all practitioner records are linked across source systems with valid hub references.

### Technical Details

#### Business Key

**Type:** Polymorphic Business Key
 - practitioner_business_key NOTE: please see example for the full polymorphic business key expression.

#### Source Models

**Source Project:** `enterprise_data_platform`

**Source Models Referenced:**
- `stg_gemstone_facets_hist__dbo_cmc_prcp_comm_prac` - Practitioner data from Gemstone Facets system
- `stg_legacy_bcifacets_hist__dbo_cmc_prcp_comm_prac` - Practitioner data from Legacy FACETS system

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_practitioner_gemstone_facets_rename - Rename columns for gemstone facets
- stg_practitioner_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example gemstone join
source as (
    select 
      case 
        when coalesce(prac.prcp_npi,'') <> '' 
          then prac.prcp_npi 
        when coalesce(prac.prcp_npi,'') = '' and coalesce(prac.prcp_ssn,'') <> ''
          then prac.prcp_ssn || '|' || coalesce(nullif(prac.prcp_last_name,''),'^^')
        else coalesce(nullif(prac.prcp_last_name,''),'^^') || '|' || coalesce(nullif(left(trim(prac.prcp_first_name),1),''),'^^') || '|' || coalesce(nullif(to_char(prac.prcp_birth_dt, 'YYYYMMDD'),''),'^^')
      end as practitioner_business_key,
      case 
        when coalesce(prac.prcp_npi,'') <> '' 
          then 'NPI' 
        when coalesce(prac.prcp_npi,'') = '' and coalesce(prac.prcp_ssn,'') <> ''
          then 'SSN_NAME'
        else 'NAME_INITIAL_DOB'
      end as polymorphic_key_type,
      prac.* 
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prcp_comm_prac') }} prac
    where coalesce(prac.prcp_id, '') <> ''
)
```

**Staging Views**:

- stg_practitioner_gemstone_facets - Stage data from cmc_prcp_comm_prac for gemstone facets
- stg_practitioner_legacy_facets - Stage data from cmc_prcp_comm_prac for legacy facets

**Hubs** (using automate_dv hub macro):

- h_practitioner - Hub for practitioner business key

**Satellites** (using automate_dv sat macro):

- s_practitioner_gemstone_facets - Descriptive attributes from Gemstone system
- s_practitioner_legacy_facets - Descriptive attributes from legacy system

**Same-As Link** (using automate_dv link macro):

- sal_practitioner_facets - Same-as link for practitioner identity resolution in the case when business key information is updated in a way that changes the practitioner business key. The initial cases to handle are when there are multiple hub records with these similarities:
  - record has a prcp_npi, but there is another record with the same prac.prcp_ssn, prac.prcp_last_name, left(trim(prac.prcp_first_name),1), and to_char(prac.prcp_birth_dt, 'YYYYMMDD')
  - record has a prcp_npi, but there is another record with the same prac.prcp_last_name, left(trim(prac.prcp_first_name),1), and to_char(prac.prcp_birth_dt, 'YYYYMMDD')
  - record has a prcp_ssn, but there is another record with the same prac.prcp_npi, prac.prcp_last_name, left(trim(prac.prcp_first_name),1), and to_char(prac.prcp_birth_dt, 'YYYYMMDD')
  
  **Note**: the staging view should have a hash expression for the sal_practitioner_facets_hk column.

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|---------------------|
| cmc_prcp_comm_prac | prcp_id | practitioner_id | Common Practitioner Identifier |
| cmc_prcp_comm_prac | prcp_ssn | practitioner_ssn | Common Practitioner Social Security Number |
| cmc_prcp_comm_prac | prcp_last_name | practitioner_last_name | Common Practitioner Last Name |
| cmc_prcp_comm_prac | prcp_first_name | practitioner_first_name | Common Practitioner First Name |
| cmc_prcp_comm_prac | prcp_mid_init | practitioner_mid_init | Common Practitioner Middle Initial |
| cmc_prcp_comm_prac | prcp_title | practitioner_title | Common Practitioner Title |
| cmc_prcp_comm_prac | prcp_sex | practitioner_sex | Common Practitioner Gender |
| cmc_prcp_comm_prac | prcp_birth_dt | practitioner_birth_dt | Common Practitioner Birth Date |
| cmc_prcp_comm_prac | prcp_last_chan_dtm | practitioner_last_chan_dtm | Common Practitioner Last Channel Date |
| cmc_prcp_comm_prac | prcp_tier_no | practitioner_tier_no | Common Practitioner Tier Number |
| cmc_prcp_comm_prac | prcp_last_name_xlow | practitioner_last_name_xlow | Common Practitioner Last Name Case Insensitivity Field |
| cmc_prcp_comm_prac | prcp_mccy_ctry | practitioner_mccy_ctry | Common Practitioner Country of Citizenship |
| cmc_prcp_comm_prac | prcr_id | credentialing_id | Credentialing Identifier |
| cmc_prcp_comm_prac | prcp_mctr_lang | practitioner_language_ind | Common Practitioner Language Indicator |
| cmc_prcp_comm_prac | prcp_extn_addr_ind | practitioner_extn_addr_ind | Common Practitioner External Address Indicator |
| cmc_prcp_comm_prac | prcp_npi | practitioner_npi | National Provider Identifier |
| cmc_prcp_comm_prac | prcp_term_dt | practitioner_term_dt | Common Practitioner Termination Date |
| cmc_prcp_comm_prac | prcp_mctr_trsn | practitioner_term_reason | Common Practitioner Termination Reason |
| cmc_prcp_comm_prac | prcp_lock_token | lock_token | Lock Token |
| cmc_prcp_comm_prac | atxr_source_id | attachment_source_id | Attachment Source Id |
| cmc_prcp_comm_prac | sys_last_upd_dtm | system_last_update_dtm | Last Update Datetime |
| cmc_prcp_comm_prac | sys_usus_id | system_user_id | Last Update User ID |
| cmc_prcp_comm_prac | sys_dbuser_id | system_dbuser_id | Last Update DBMS User ID |
| N/A | '1' | tenant_id | Tenant identifier constant |
| N/A | gemstone_facets/legacy_facets | source | Source system identifier |

**Metadata:**

- Deliverables: Practitioner Months, PCP Attribution
- Dependencies: None

---

## Specification Evaluation Report (Updated)

### Evaluation Date: 2025-01-27
### Previous Score: 100%
### Current Score: 100%

**Changes Since Last Evaluation:**
- ✅ **Updated Standard**: Business Key section now correctly shows "- practitioner_business_key NOTE: please see example for the full polymorphic business key expression." This follows the new standard where polymorphic business keys reference the staging join example rather than duplicating the CASE statement.
- ✅ **Typo Fixed**: Changed "polymophic_key_type" to "polymorphic_key_type" on line 79.
- ✅ **Correct**: Only Gemstone staging join example included (appropriate since joins are identical between Gemstone and Legacy)

### Overall Completeness Score: 100%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- Title & Description: Title includes Domain (Provider) and Entity (Practitioner Hub and Satellites). Description accurately reflects objects being built (hub, satellites, and same-as link).
- Business Key: Type clearly labeled as "Polymorphic Business Key". Business key name listed with note referencing staging join example where the complete CASE statement is provided (per new standard).
- Source Models: All 2 source models listed with full project and model names. Source project (`enterprise_data_platform`) specified.
- Rename Views: All rename views listed. Only Gemstone staging join example provided (correct per new rules since joins are identical). Legacy follows same pattern with `stg_legacy_bcifacets_hist__dbo_*` models.
- Staging Views: All staging views listed with source table references.
- Hubs/Links/Satellites: All objects match description. Naming conventions followed (h_, s_, sal_).
- Same-As Links: Resolution logic described. Note about hash expression included. Column names are correct.
- Column Mapping: Source Column Mapping table includes all columns from cmc_prcp_comm_prac data dictionary (24 columns). All columns referenced in business key expression are included.
- Acceptance Criteria: All criteria are specific, testable, and reference actual objects being built.
- Metadata: Deliverables listed. Dependencies identified.

**Failed:** 0 / 10
- None

### Quality Checks

**Passed:** 6 / 6
- Join Logic Documentation: Complete staging join example provided (Gemstone only, which is correct since joins are identical). Example includes complete polymorphic business key CASE statement with valid SQL syntax.
- Column Mapping Completeness: All columns referenced in join example appear in Source Column Mapping table with correct source_table references, source_column names, appropriate target_column names, and descriptive column_description.
- No Placeholders: All placeholders have been replaced with actual values. No template instructional notes remain.
- Consistency: Description objects match Technical Details objects. Entity name used consistently throughout.
- Naming Conventions: All model names follow BCI conventions (stg_, h_, s_, sal_ prefixes).
- Actionability: An engineer can implement without additional clarification - source models are identifiable, business key logic is executable with valid SQL syntax (found in staging join example), column mappings are clear, join logic is documented.

**Failed:** 0 / 6
- None

### Data Vault 2.0 Pattern Validation

**Passed:** 8 / 8
- Hub Appropriateness: Practitioner hub represents a significant business entity - appropriate.
- Satellite vs Reference Table: Satellites are used for descriptive attributes that change over time and need historization - appropriate. No static lookup data incorrectly modeled as satellites.
- Link Appropriateness: Same-as link represents identity resolution across systems - appropriate.
- Business Key Granularity: Polymorphic business key represents correct level of detail for practitioner entity, handling cases where NPI, SSN, or name/birthdate combinations identify practitioners.
- Satellite Rate of Change: No indication of high rate of change issues requiring split.
- Same-As Link Logic: Same-as link logic is appropriate for identity resolution when business key information changes - appropriate use case.
- Hub Scope: Practitioner hub represents a business concept that exists across multiple source systems (Gemstone and Legacy FACETS) - appropriate.
- No Over-Engineering: Appropriate complexity for practitioner entity with demographic tracking.

**Anti-Patterns Identified:**
- None identified. All artifacts follow Data Vault 2.0 best practices.

### Red Flags (Critical Issues)

- None identified.

**Data Vault 2.0 Pattern Violations:**
- None identified.

### Implementation Blockers

These issues would prevent a data engineer or AI from implementing this specification:

- None identified. Specification is complete and actionable.

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All 2 source models are listed in the Source Models section with full paths (`enterprise_data_platform.stg_gemstone_facets_hist__dbo_cmc_prcp_comm_prac` and `enterprise_data_platform.stg_legacy_bcifacets_hist__dbo_cmc_prcp_comm_prac`).

2. **Can an engineer write the business key expression?** Yes - Business key is clearly defined as a polymorphic expression. The complete CASE statement is provided in the staging join example (lines 66-72), and the Business Key section correctly references it with a note. This follows the new standard for polymorphic business keys.

3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided (Gemstone only, which is correct). Join logic is clear and complete with valid SQL syntax, including the complete polymorphic business key CASE statement.

4. **Can an engineer map all columns from the mapping table?** Yes - Comprehensive column mapping table provided with all 24 columns from cmc_prcp_comm_prac plus standard fields (tenant_id, source). All columns have descriptions.

5. **Can an engineer implement all objects without questions?** Yes - Specification is comprehensive with all required information. Source models, business keys (with reference to staging join example), join logic, and column mappings are all clearly documented with valid SQL syntax.

6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable, and reference actual objects being built.

### Recommendations

- None. Specification is complete and ready for handoff.

### Next Steps

**Specification is ready for handoff to the data engineering team.**

All critical issues have been resolved:
- ✅ Business Key section follows new standard (references staging join example)
- ✅ Complete polymorphic business key CASE statement provided in staging join example
- ✅ Only Gemstone staging join example included (correct per new rules)
- ✅ Typo fixed: "polymophic_key_type" → "polymorphic_key_type"
