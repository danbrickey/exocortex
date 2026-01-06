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

_polymorphic business key expression_
```sql
case 
  when coalesce(prac.prcp_npi,'') <> '' 
    then prac.prcp_npi 
  when coalesce(prac.prcp_npi,'') = '' and coalesce(prac.prcp_ssn,'') <> ''
    then prac.prcp_ssn || '|' || prac.prcp_last_name || '|' || left(trim(prac.prcp_first_name),1) || '|' || prac.prcp_birth_dt (YYYYMMDD)
  else prac.prcp_last_name || '|' || left(trim(prac.prcp_first_name),1) || '|' || prac.prcp_birth_dt (YYYYMMDD)
end as practitioner_business_key
```

#### dbt Models to Build/Refactor

**Rename Views**:

- stg_practitioner_gemstone_facets_rename - Rename columns for gemstone facets
- stg_practitioner_legacy_facets_rename - Rename columns for legacy facets

- **Staging Join Example (for Rename views)**

```sql
-- example join for gemstone
source as (
    select 
      case 
        when coalesce(prac.prcp_npi,'') <> '' 
          then prac.prcp_npi 
        when coalesce(prac.prcp_npi,'') = '' and coalesce(prac.prcp_ssn,'') <> ''
          then prac.prcp_ssn || '|' || prac.prcp_last_name || '|' || left(trim(prac.prcp_first_name),1) || '|' || prac.prcp_birth_dt (YYYYMMDD)
        else prac.prcp_last_name || '|' || left(trim(prac.prcp_first_name),1) || '|' || prac.prcp_birth_dt (YYYYMMDD)
      end as practitioner_business_key,
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

**Same-As Links** (using automate_dv link macro):

- sal_practitioner - Same-as link for practitioner identity resolution in the case when business key information is updated in a way that changes the practitioner business key. The initial cases to handle are when there are multiple hub records with these similarities:
  - record has a prac_npi, but there is another record with the same prac.prcp_ssn, prac.prcp_last_name, left(trim(prac.prcp_first_name),1), and prac.prcp_birth_dt (YYYYMMDD)
  - record has a prac_npi, but there is another record with the same prac.prcp_last_name, left(trim(prac.prcp_first_name),1), and prac.prcp_birth_dt (YYYYMMDD)
  - record has a prac_ssn, but there is another record with the same prac.prcp_npi, prac.prcp_last_name, left(trim(prac.prcp_first_name),1), and prac.prcp_birth_dt (YYYYMMDD)

**Metadata:**

- Deliverables: practitioner Months, PCP Attribution
