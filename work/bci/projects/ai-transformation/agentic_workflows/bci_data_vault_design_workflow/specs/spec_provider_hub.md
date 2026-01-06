## Provider 360: Build Raw Vault Provider Hub and Satellites

**Title:**

**Provider 360: Build Raw Vault Provider Hub and Satellites**

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

```sql
coalesce(nullif(prov.prpr_npi,''),'^^') prov_npi,
coalesce(nullif(org.prpr_npi,''),'^^') org_npi,
coalesce(nullif(org.mctn_id,''),'^^') org_tin,
coalesce(nullif(p_geo.prad_state,''),'^^') provider_state,
```


#### dbt Models to Build/Refactor

**Rename Views**:

- stg_provider_gemstone_facets_rename - Rename columns for gemstone facets
- stg_provider_legacy_facets_rename - Rename columns for legacy facets

**Staging Views**:

- stg_provider_gemstone_facets - Stage data from cmc_prpr_prov for gemstone facets
- stg_practitioner_legacy_facets - Stage data from cmc_prpr_prov for legacy facets

- **Staging Join Example (for Rename views)**

```sql
-- example join for gemstone
source as (
    select
      --Polymorphic Business Key Expressions
      '110' as plan_code,
      coalesce(nullif(prov.prpr_npi,''),'^^') prov_npi,
      coalesce(nullif(org.prpr_npi,''),'^^') org_npi,
      coalesce(nullif(org.mctn_id,''),'^^') org_tin,
      coalesce(nullif(p_geo.prad_state,''),'^^') provider_state,
      prov.*,
      org.*
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} prov
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prer') }} rel
            on ind.prpr_id = rel.prpr_id
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prpr_prov') }} org
            on org.prpr_id = rel.prer_prpr_id
              and org.prpr_entity = rel.prer_prpr_entity
        left join {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_prad_address') }} p_geo
            on prov.prad_type_primary = p_geo.prad_type
              and prov.prad_id = p_geo.prad_id
)
```

**Hubs** (using automate_dv hub macro):

- h_practitioner - Hub for practitioner business key

**Satellites** (using automate_dv sat macro):

- s_practitioner_gemstone_facets - Descriptive attributes from Gemstone system
- s_practitioner_legacy_facets - Descriptive attributes from legacy system

**Same-As Links** (using automate_dv link macro):

- sal_practitioner_facets - Same-as link for practitioner identity resolution using the crosswalk between Gemstone and Legacy practitioners. \*\*\_Note\*\*\*: the staging view should have a hash expression for the sal_practitioner_facets_hk column.

**Metadata:**

- Deliverables: practitioner Months, PCP Attribution
