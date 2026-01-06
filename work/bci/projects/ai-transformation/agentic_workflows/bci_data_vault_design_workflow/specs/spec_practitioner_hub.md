## Story EDP035: Raw Vault Practitioner: Build Core Practitioner Hub and Satellites

**Title:**

**Raw Vault practitioner: Build Core Practitioner Hub and Satellites**

**Description:**

As a data engineer,  
I want to refactor the practitioner hub and associated satellites in the raw vault,  
So that we can track practitioner changes over time and support practitioner catalog and PCP attribution analytics.

**Technical Details:**

**Business Key**

- practitioner_npi (if no NPI, then use practitioner tax ID plus name and birthdate)
- organization_npi
- organization_tax_id

**Staging Views** (using automate_dv stage macro):

- stg_practitioner_gemstone_facets - Stage data from cmc_prpr_prov for gemstone facets
- stg_practitioner_legacy_facets - Stage data from cmc_prpr_prov for legacy facets

- **Staging Join Example (for Rename view)**

```sql
-- example join for gemstone
source as (
    select
      prov.prpr_npi,org.prpr_npi,org.mctn_id,
      prov.*,
      org.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} prov
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prer') }} rel
            on ind.prpr_id = rel.prpr_id
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} org
            on org.prpr_id = rel.rel_prpr_id
              and org.prpr_entity = rel.prpr_entity
)
```

**Hubs** (using automate_dv hub macro):

- h_practitioner - Hub for practitioner business key

**Satellites** (using automate_dv sat macro):

- s_practitioner_gemstone_facets - Descriptive attributes from Gemstone system
- s_practitioner_legacy_facets - Descriptive attributes from legacy system

**Same-As Links** (using automate_dv link macro):

- sal_practitioner_facets - Same-as link for practitioner identity resolution using the crosswalk between Gemstone and Legacy practitioners. \*\*\_Note\*\*\*: the staging view should have a hash expression for the sal_practitioner_facets_hk column.

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

**Metadata:**

- Story ID: EDP035
- Estimate: 6 days
- Deliverables: practitioner Months, PCP Attribution
