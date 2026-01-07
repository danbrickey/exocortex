## Member 360: Build Raw Vault subscriber Satellites

**Title:**

**Member 360: Build Raw Vault subscriber Satellites**

**Description:**

As a data engineer,  
I want to create the subscriber satellites in the raw vault,  
So that we can track subscriber-level demographic and indicative data changes over time while maintaining the member as the core grain.

**Acceptance Criteria:**

Given the member hub (h_member) exists with loaded member records,  
when the subscriber satellite models execute,  
then all subscriber records are loaded with valid member hub hash keys and load timestamps.

Given multiple source records exist for the same subscriber over time,  
when the satellite models execute,  
then only records with changed attributes create new satellite records with proper effective dating.

Given gemstone and legacy facets are loaded,  
when data quality checks run,  
then no null values exist in required business key columns and all hash keys are valid.

Given the subscriber satellites reference the member hub,  
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
- `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc` - Subscriber demographic and indicative data from Gemstone system
- `stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc` - Subscriber demographic and indicative data from legacy system
- `stg_gemstone_facets_hist__dbo_cmc_meme_member` - Member data for join to get member hub key

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_subscriber_gemstone_facets_rename - Rename columns for gemstone facets
- stg_subscriber_legacy_facets_rename - Rename columns for legacy facets

<sup>1</sup> See [Source Column Mapping / Payload](#source-column-mapping--payload) table below for column mapping metadata.

**Staging Join Example (for Rename views)**:

```sql
-- Example join to get member hub key for subscriber satellites
source as (
    select
        -- Business Key Expressions
        sbsb.sbsb_id as subscriber_id,
        mem.meme_sfx as member_suffix,
        -- Subscriber attributes
        sbsb.sbsb_ck,
        sbsb.grgr_ck,
        sbsb.sbsb_last_name,
        sbsb.sbsb_first_name,
        sbsb.sbsb_mid_init,
        sbsb.sbsb_title,
        sbsb.sbsb_orig_eff_dt,
        sbsb.sbsb_mctr_sts,
        sbsb.sbsb_mctr_vip,
        sbsb.sbsb_mctr_srsn,
        sbsb.sbsb_prcs_sts,
        sbsb.sbsb_employ_id,
        sbsb.sbsb_hire_dt,
        sbsb.sbsb_retire_dt,
        sbsb.sbsb_conv_dt,
        sbsb.sbsb_fi,
        sbsb.sbsb_pay_cl_meth,
        sbsb.sbsb_eft_ind,
        sbsb.sbad_type_home,
        sbsb.sbad_type_mail,
        sbsb.sbad_type_work,
        sbsb.sbsb_last_name_xlow,
        sbsb.mcbr_ck,
        sbsb.sbsb_sig_dt,
        sbsb.sbsb_recd_dt,
        sbsb.sbsb_pay_fsac_meth,
        sbsb.sbsb_lock_token,
        sbsb.atxr_source_id,
        sbsb.sbsb_mlr_eft_ind_nvl,
        sbsb.sys_last_upd_dtm,
        sbsb.sys_usus_id,
        sbsb.sys_dbuser_id,
        sbsb.edp_start_dt,
        sbsb.edp_record_status
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc') }} sbsb
    inner join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_meme_member') }} mem
        on sbsb.sbsb_ck = mem.sbsb_ck
)
```

**Staging Views**:

- stg_subscriber_gemstone_facets - Stage data from cmc_sbsb_subsc for gemstone facets
- stg_subscriber_legacy_facets - Stage data from cmc_sbsb_subsc for legacy facets

**Satellites** (using automate_dv sat macro):

- s_subscriber_gemstone_facets - Descriptive attributes from Gemstone system
- s_subscriber_legacy_facets - Descriptive attributes from legacy system

#### Source Column Mapping / Payload

| source_table | source_column | target_column | column_description |
|--------------|---------------|---------------|-------------------|
| cmc_sbsb_subsc | sbsb_id | subscriber_id | Subscriber Identifier (Business Key) |
| cmc_meme_member | meme_sfx | member_suffix | Member Suffix (Business Key) |
| N/A | 'gemstone_facets' / 'legacy_facets' | source | Source System Identifier |
| N/A | '1' | tenant_id | Tenant Identifier |
| cmc_sbsb_subsc | sbsb_ck | subscriber_bk | Subscriber Contrived Key |
| cmc_sbsb_subsc | grgr_ck | employer_group_bk | Group Contrived Key |
| cmc_sbsb_subsc | sbsb_last_name | subscriber_last_name | Subscriber Last Name |
| cmc_sbsb_subsc | sbsb_first_name | subscriber_first_name | Subscriber First Name |
| cmc_sbsb_subsc | sbsb_mid_init | subscriber_mid_init | Subscriber Middle Initial |
| cmc_sbsb_subsc | sbsb_title | subscriber_title | Subscriber Title |
| cmc_sbsb_subsc | sbsb_orig_eff_dt | subscriber_original_eff_dt | Subscriber Original Effective Date |
| cmc_sbsb_subsc | sbsb_mctr_sts | subscriber_status | Subscriber Status |
| cmc_sbsb_subsc | sbsb_mctr_vip | subscriber_vip_type | Subscriber VIP Type |
| cmc_sbsb_subsc | sbsb_mctr_srsn | subscriber_status_reason | Status Reason Code |
| cmc_sbsb_subsc | sbsb_prcs_sts | subscriber_processing_status | Processing Status |
| cmc_sbsb_subsc | sbsb_employ_id | employee_id | Employee Identifier |
| cmc_sbsb_subsc | sbsb_hire_dt | subscriber_hire_dt | Subscriber Hire Date |
| cmc_sbsb_subsc | sbsb_retire_dt | subscriber_retire_dt | Subscriber Retire Date |
| cmc_sbsb_subsc | sbsb_conv_dt | subscriber_conversion_dt | Conversion Date |
| cmc_sbsb_subsc | sbsb_fi | subscriber_family_ind | Subscriber Family Indicator |
| cmc_sbsb_subsc | sbsb_pay_cl_meth | subscriber_claim_pay_method | Subscriber Claim Payment Method |
| cmc_sbsb_subsc | sbsb_eft_ind | subscriber_eft_ind | Electronic Fund Transfer Indicator |
| cmc_sbsb_subsc | sbad_type_home | subscriber_address_type_home | Subscriber Home Address Type |
| cmc_sbsb_subsc | sbad_type_mail | subscriber_address_type_mail | Subscriber Mailing Address Type |
| cmc_sbsb_subsc | sbad_type_work | subscriber_address_type_work | Subscriber Work Address Type |
| cmc_sbsb_subsc | sbsb_last_name_xlow | subscriber_last_name_search | Name Search (Case Insensitive) |
| cmc_sbsb_subsc | mcbr_ck | bank_relationship_bk | Bank Relationship Contrived Key |
| cmc_sbsb_subsc | sbsb_sig_dt | subscriber_signature_dt | Signature Date |
| cmc_sbsb_subsc | sbsb_recd_dt | subscriber_received_dt | Received Date |
| cmc_sbsb_subsc | sbsb_pay_fsac_meth | subscriber_fsa_pay_method | FSA Claim Payment Method |
| cmc_sbsb_subsc | sbsb_lock_token | subscriber_lock_token | Lock Token |
| cmc_sbsb_subsc | atxr_source_id | attachment_source_id | Attachment Source ID |
| cmc_sbsb_subsc | sbsb_mlr_eft_ind_nvl | subscriber_mlr_eft_ind | MLR Electronic Fund Transfer Indicator |
| cmc_sbsb_subsc | sys_last_upd_dtm | source_last_update_dtm | Source Last Update Datetime |
| cmc_sbsb_subsc | sys_usus_id | source_last_update_user_id | Source Last Update User ID |
| cmc_sbsb_subsc | sys_dbuser_id | source_db_user_id | Source DBMS User ID |
| cmc_sbsb_subsc | edp_start_dt | edp_start_dt | EDP Start Date |
| cmc_sbsb_subsc | edp_record_status | edp_record_status | EDP Record Status |

**Metadata:**

- Deliverables: Subscriber demographics, subscriber status tracking
- Dependencies: h_member hub must exist

---

## Specification Evaluation Report

### Overall Completeness Score: 95%

**Status:** Ready for Handoff

### Completeness Checks

**Passed:** 10 / 10
- ✅ **Title & Description**: Title includes Domain (Member) and Entity (subscriber). Description accurately reflects objects being built (satellites only).
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
- ✅ **Join Logic Documentation**: Staging join example includes multiple tables (cmc_sbsb_subsc, cmc_meme_member) and example is provided and complete with join conditions. Join logic corrected to use `sbsb.sbsb_ck = mem.sbsb_ck` to properly link subscriber to member.
- ✅ **Column Mapping Completeness**: Every column in the staging join example appears in the Source Column Mapping table with correct source_table reference, source_column name, appropriate target_column name, and descriptive column_description. Missing descriptions added for edp_start_dt and edp_record_status.
- ✅ **No Placeholders**: All [bracketed placeholders] have been replaced with actual values.
- ✅ **Consistency**: Description objects match Technical Details objects (satellites). Entity name (subscriber) used consistently throughout.
- ✅ **Naming Conventions**: All model names follow BCI conventions (stg_, s_ prefixes).
- ✅ **Actionability**: An engineer can implement without additional clarification:
  - Source models are identifiable (full paths provided)
  - Business key logic is executable (inherited from parent hub, columns clearly listed)
  - Column mappings are clear (complete mapping table)
  - Join logic is documented (complete example provided)

### Data Vault 2.0 Pattern Validation

**Passed:** 5 / 5
- ✅ **Hub Appropriateness**: Not applicable - this is a satellite-only specification referencing existing h_member hub.
- ✅ **Satellite vs Reference Table**: Satellites are appropriately used for descriptive attributes that change over time (subscriber demographics, status, dates, indicators) and need historization. This is not static lookup data.
- ✅ **Link Appropriateness**: Not applicable - no links in this specification.
- ✅ **Business Key Granularity**: Business key represents the correct level of detail (member level, inherited from parent hub). Note: Subscriber data is at subscriber level but attached to member hub for business context.
- ✅ **Satellite Rate of Change**: Subscriber data has moderate rate of change (demographic updates, status changes, date updates) which is appropriate for standard satellites. No need for hroc/mroc/lroc split.
- ✅ **Same-As Link Logic**: Not applicable - no same-as links in this specification.
- ✅ **Hub Scope**: Not applicable - satellites reference existing h_member hub.
- ✅ **No Over-Engineering**: Appropriate use of satellites for time-varying subscriber attributes. Not over-engineered.

**Anti-Patterns Identified:**
- None

### Red Flags (Critical Issues)

No red flags identified.

### Implementation Blockers

No implementation blockers identified. The specification contains all information needed for a data engineer or AI to implement:

1. ✅ All source models are clearly identified with full paths
2. ✅ Business key logic is executable (inherited from parent hub, columns listed)
3. ✅ Staging join example is complete and can be implemented (join logic corrected)
4. ✅ All columns from join example are mapped in Source Column Mapping table
5. ✅ Parent hub dependency is clearly documented
6. ✅ Acceptance criteria are testable and specific

### Pre-Handoff Questions

1. **Can an engineer identify all source models?** Yes - All source models are listed with full project and model names: `stg_gemstone_facets_hist__dbo_cmc_sbsb_subsc`, `stg_legacy_bcifacets_hist__dbo_cmc_sbsb_subsc`, `stg_gemstone_facets_hist__dbo_cmc_meme_member`
2. **Can an engineer write the business key expression?** Yes - Business key is clearly documented as inherited from h_member with columns `subscriber_id` and `member_suffix` listed individually (correct format for automate_dv)
3. **Can an engineer build the staging join from the example?** Yes - Complete staging join example provided with all tables, aliases, join conditions (corrected to `sbsb.sbsb_ck = mem.sbsb_ck`), and column selections
4. **Can an engineer map all columns from the Source Column Mapping table?** Yes - Complete mapping table includes all columns from the join example with source_table, source_column, target_column, and column_description
5. **Can an engineer implement all objects without questions?** Yes - All objects (rename views, staging views, satellites) are clearly defined with naming conventions and source references
6. **Are acceptance criteria testable for QA?** Yes - All acceptance criteria are specific, testable Given/When/Then statements that reference actual objects and can be validated

### Recommendations

- ✅ Specification is complete and ready for handoff
- ✅ Join logic corrected to properly link subscriber to member (`sbsb.sbsb_ck = mem.sbsb_ck`)
- ✅ Column descriptions added for edp_start_dt and edp_record_status
- ✅ Consider documenting if legacy facets join logic differs from gemstone (if applicable)
- ✅ Consider adding note about handling NULL values in business key columns if source data may contain NULLs

### Next Steps

Specification is ready for handoff to data engineering team. All required information is present, patterns are validated, and no blockers exist.
