# Title: Raw vault data pipeline for subscriber_employment

## Description

As a data engineer,
I want to rewrite the existing dbt model for the subscriber_employment entity, which currently supports a 3NF data model,
So that it instead builds a Data Vault 2.0 raw vault structure. This includes creating staging tables and effectivity satellites using dbt, based on data already ingested into the EDP Raw Layer. The new models will follow Data Vault 2.0 standards to support scalability, auditability, and historical tracking.

## Background

The subscriber_employment entity captures subscriber-level employment data including occupation codes, department codes, location codes, employment type classifications, and effective/termination dates. This data exists in both legacy_facets and gemstone_facets source systems and needs to be integrated into the Data Vault architecture as effectivity satellites attached directly to the existing h_subscriber hub to properly track temporal changes.

## Acceptance Criteria

Given the design document is provided,
When I create a feature branch in the edp_data_domains repository,
Then I name the branch `feature/subscriber-employment-dv2-refactor` and base it on the main branch.

Given the design document is provided,
When I implement the raw vault models,
Then I create the appropriate rename views, staging, and effectivity satellite dbt models for the subscriber_employment entity following the automate_dv package conventions and naming standards.

Specifically, I will create:
- Rename views:
  - stg_subscriber_employment_legacy_facets_rename.sql
  - stg_subscriber_employment_gemstone_facets_rename.sql
- Staging views:
  - stg_subscriber_employment_legacy_facets.sql
  - stg_subscriber_employment_gemstone_facets.sql
- Effectivity satellites (attached to h_subscriber hub):
  - s_subscriber_employment_legacy_facets.sql
  - s_subscriber_employment_gemstone_facets.sql
- Current view:
  - current_subscriber_employment.sql

Given the raw vault models are implemented,
When I write dbt documentation (yml files),
Then each model includes:
- A table-level description explaining the vault object type and purpose
- Column-level documentation describing business keys, hash keys, and attributes
- Data lineage using dbt refs
- Descriptions for all columns including:
  - subscriber_bk (business key from sbsb_ck)
  - employment_eff_dt (effective date)
  - employment_term_dt (termination date)
  - employment_term_reason_cd
  - occupation_cd
  - department_cd
  - location_cd
  - employment_type_cd
  - non_discrimination_type_cd
  - All other employment attributes

Given the raw vault models are implemented,
When I write dbt tests,
Then I include:
- Referential integrity tests for satellites to h_subscriber hub
- Not null tests for required hash keys and business keys (subscriber_hk)
- Not null tests for employment_eff_dt
- Hashdiff validation for effectivity satellites
- Row count and duplication checks for staging tables
- Data quality tests appropriate for the entity type:
  - Valid date ranges (employment_eff_dt <= employment_term_dt)
  - No overlapping effective date ranges for same subscriber
  - Valid values for employment_term_reason_cd
  - Valid values for employment_type_cd
  - Valid values for non_discrimination_type_cd

Given the staging and effectivity satellite models are implemented,
When I implement the current view,
Then the view:
- Joins the h_subscriber hub directly with all effectivity satellites for the entity (both legacy and gemstone)
- Filters to current/active records only (latest load_datetime per subscriber_hk and employment_eff_dt combination)
- Unions across all source systems for the entity
- Includes all descriptive columns from satellites

Given all dbt models, tests, and documentation are complete,
When I run the dbt build command,
Then all models build successfully and all tests pass without errors.

Given all acceptance criteria are met,
When I create a pull request in edp_data_domains,
Then I:
- Include a summary of the Data Vault 2.0 models created
- Reference the source table (dbo.cmc_sbem_employ) being transformed
- Document the multi-source handling for legacy_facets and gemstone_facets
- Explain that effectivity satellites attach directly to the existing h_subscriber hub
- Explain the effectivity satellite pattern for tracking temporal employment changes
- Tag appropriate reviewers for code review

## Technical Notes

- The subscriber_employment entity uses effectivity satellites attached directly to the existing h_subscriber hub
- The satellites use subscriber_hk as the src_pk, allowing multiple employment periods per subscriber
- Effectivity satellites are used because employment data has temporal aspects (effective and termination dates)
- The src_eff, src_start_date, and src_end_date parameters in the effectivity satellites handle the temporal logic
- Special handling may be needed for open-ended records where employment_term_dt indicates no termination
- Both source systems (legacy_facets and gemstone_facets) need separate staging and satellite models
- The current view unions data from both sources and filters to the latest version per subscriber_hk and employment_eff_dt combination
- Employment data includes important classification codes (occupation, department, location, employment type, non-discrimination type)

## Definition of Done

- [ ] Feature branch created: feature/subscriber-employment-dv2-refactor
- [ ] All rename views created and tested
- [ ] All staging views created with proper hashing and derived columns
- [ ] Effectivity satellites created for both source systems and attached to h_subscriber hub
- [ ] Current view created with proper joins and union logic
- [ ] All yml documentation files created with table and column descriptions
- [ ] All dbt tests implemented and passing
- [ ] dbt build command runs successfully with no errors
- [ ] Pull request created with comprehensive description
- [ ] Code review completed and approved
- [ ] Changes merged to main branch
