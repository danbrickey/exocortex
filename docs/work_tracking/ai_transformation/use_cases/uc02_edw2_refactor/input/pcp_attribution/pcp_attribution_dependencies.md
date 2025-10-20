# PCP Attribution Pipeline Dependencies

## External Pipeline Dependencies (Must exist before PCP Attribution)

### 1. COB Profile Lookup (`r_COBProfileLookup`)
- **Status**: BLOCKING DEPENDENCY
- **Schema**: HDSVault.biz
- **Columns Used**:
  - SourceID (GEM=1, FCT=2)
  - meme_ck (member business key)
  - StartDate
  - EndDate
  - MedicalCOBOrder ('Primary', 'Secondary', etc.)
- **Purpose**: Identifies primary insurance coverage for members
- **Business Rule**: Only members with 'Primary' medical COB during evaluation period
- **Recommendation**: Create separate refactoring task → `input/cob_profile_lookup/`
- **EDW3 Target**: Business Vault computed satellite or bridge

### 2. Member Constituent Crosswalk (`ds_MemberConstituent_Base`)
- **Status**: BLOCKING DEPENDENCY
- **Schema**: HDSInformationMart.xref
- **Columns Used**:
  - ConstituentId (MDM/master member ID)
  - meme_ck (member business key)
  - grgr_id (group ID)
  - sbsb_id (subscriber ID)
  - meme_sfx (member suffix)
- **Purpose**: Maps member keys to master constituent identifier
- **Business Rule**: Joins on compound key (grgr_id, sbsb_id, meme_sfx)
- **Recommendation**: Check if this exists in EDW3 member mastering logic; if not, create refactoring task → `input/member_constituent_xref/`
- **EDW3 Target**: Business Vault link or bridge table

## Reference Data Requirements (Can be handled as seeds or existing refs)

### 3. Provider Specialty Classification (`PCPAttribution_02_ProviderSpecialty`)
- **Type**: Static reference table
- **Columns**: specialty_code, specialty_desc
- **Purpose**: Filter eligible providers by specialty
- **Recommendation**: Create as dbt seed file or reference existing specialty reference table
- **File**: `pcp_attribution_provider_specialty_seed.csv`

### 4. BIHC Procedure Codes (`PCPAttribution_02_BIHC_Codes`)
- **Type**: Reference/configuration table
- **Columns**: cpt_code, cpt_desc
- **Purpose**: Identifies BIHC (Behavioral Integrated Health Care) visit codes
- **Recommendation**: Create as dbt seed file
- **File**: `pcp_attribution_bihc_codes_seed.csv`

### 5. CMS RVU Reference (`PCPAttribution_02_FeeSchCmsDataFileRVU`)
- **Type**: External reference data (CMS published)
- **Columns**: hcpcs, (RVU values)
- **Purpose**: Identify evaluation & management codes via RVU values
- **Recommendation**: Check if CMS reference data exists in EDW3; if not, create seed
- **File**: `pcp_attribution_cms_rvu_seed.csv`

### 6. Idaho Adjacent County Reference (`PCPAttribution_02_IdahoAdjacentCounty`)
- **Type**: Geographic reference
- **Purpose**: Define Idaho service area
- **Recommendation**: Create as dbt seed file
- **File**: `pcp_attribution_idaho_county_seed.csv`

### 7. Zip Code Reference (`USZipCode_Melissa`)
- **Type**: External vendor data (Melissa Data)
- **Columns**: ZipCode, StateID, FIPSCountyCode, fipscode
- **Purpose**: Geocode member addresses to FIPS codes
- **Recommendation**: Reference existing EDW3 zip code reference table
- **EDW3 Table**: Likely `reference.zip_code_melissa` or similar

## Load Order Requirements

1. **First**: COB Profile Lookup (blocking)
2. **First**: Member Constituent Crosswalk (blocking)
3. **Second**: All reference data (seeds)
4. **Third**: PCP Attribution pipeline can run

## Missing Columns in Current Mapping

Add these columns to `pcp_attribution_mappings.csv`:

```csv
v_providernetworkrelationshipextended_combined_current,nwpr_eff_dt,current_provider_network_relational,provider_network_eff_date
v_providernetworkrelationshipextended_combined_current,nwpr_pcp_ind,current_provider_network_relational,pcp_indicator
```

## Next Steps

1. Update `pcp_attribution_mappings.csv` with the two missing columns
2. Verify COB Profile Lookup and Member Constituent Crosswalk exist in EDW3
3. If dependencies don't exist, create separate refactoring tasks for them
4. Gather reference data files for seed creation
5. Proceed with business vault artifact recommendations
