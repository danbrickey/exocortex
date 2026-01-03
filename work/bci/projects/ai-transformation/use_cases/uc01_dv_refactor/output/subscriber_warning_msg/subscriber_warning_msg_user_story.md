# Title: Raw vault data pipeline for subscriber_warning_msg

## Description

As a data engineer,
I want to rewrite the existing dbt model for the subscriber_warning_msg entity, which currently supports a 3NF data model,
So that it instead builds a Data Vault 2.0 raw vault structure. This includes creating staging tables and effectivity satellites using dbt, based on data already ingested into the EDP Raw Layer. The new models will follow Data Vault 2.0 standards to support scalability, auditability, and historical tracking.

## Background

The subscriber_warning_msg entity captures subscriber-level warning messages including message IDs, effective/termination dates, and termination reasons. This data exists in both legacy_facets and gemstone_facets source systems and needs to be integrated into the Data Vault architecture as effectivity satellites attached directly to the existing h_subscriber hub to properly track temporal changes in warning messages.

## Acceptance Criteria

Given the design document is provided,
When I create a feature branch in the edp_data_domains repository,
Then I name the branch `feature/subscriber-warning-msg-dv2-refactor` and base it on the main branch.

Given the design document is provided,
When I implement the raw vault models,
Then I create the appropriate rename views, staging, and effectivity satellite dbt models for the subscriber_warning_msg entity following the automate_dv package conventions and naming standards.

Specifically, I will create:
- Rename views:
  - stg_subscriber_warning_msg_legacy_facets_rename.sql
  - stg_subscriber_warning_msg_gemstone_facets_rename.sql
- Staging views:
  - stg_subscriber_warning_msg_legacy_facets.sql
  - stg_subscriber_warning_msg_gemstone_facets.sql
- Effectivity satellites (attached to h_subscriber hub):
  - s_subscriber_warning_msg_legacy_facets.sql
  - s_subscriber_warning_msg_gemstone_facets.sql
- Current view:
  - current_subscriber_warning_msg.sql

Given the raw vault models are implemented,
When I write dbt documentation (yml files),
Then each model includes:
- A table-level description explaining the vault object type and purpose
- Column-level documentation describing business keys, hash keys, and attributes
- Data lineage using dbt refs
- Descriptions for all columns including:
  - subscriber_bk (business key from sbsb_ck)
  - warning_msg_eff_dt (effective date)
  - warning_msg_term_dt (termination date)
  - message_id (warning message identifier)
  - termination_reason_cd
  - All other warning message attributes

Given the raw vault models are implemented,
When I write dbt tests,
Then I include:
- Referential integrity tests for satellites to h_subscriber hub
- Not null tests for required hash keys and business keys (subscriber_hk)
- Not null tests for warning_msg_eff_dt and message_id
- Hashdiff validation for effectivity satellites
- Row count and duplication checks for staging tables
- Data quality tests appropriate for the entity type:
  - Valid date ranges (warning_msg_eff_dt <= warning_msg_term_dt)
  - No overlapping effective date ranges for same subscriber and message
  - Valid values for message_id
  - Valid values for termination_reason_cd

Given the staging and effectivity satellite models are implemented,
When I implement the current view,
Then the view:
- Joins the h_subscriber hub directly with all effectivity satellites for the entity (both legacy and gemstone)
- Filters to current/active records only (latest load_datetime per subscriber_hk and warning_msg_eff_dt combination)
- Unions across all source systems for the entity
- Includes all descriptive columns from satellites

Given all dbt models, tests, and documentation are complete,
When I run the dbt build command,
Then all models build successfully and all tests pass without errors.

Given all acceptance criteria are met,
When I create a pull request in edp_data_domains,
Then I:
- Include a summary of the Data Vault 2.0 models created
- Reference the source table (dbo.cmc_sbwm_sb_msg) being transformed
- Document the multi-source handling for legacy_facets and gemstone_facets
- Explain that effectivity satellites attach directly to the existing h_subscriber hub
- Explain the effectivity satellite pattern for tracking temporal warning message changes
- Tag appropriate reviewers for code review

## Technical Notes

- The subscriber_warning_msg entity uses effectivity satellites attached directly to the existing h_subscriber hub
- The satellites use subscriber_hk as the src_pk, allowing multiple warning message periods per subscriber
- Effectivity satellites are used because warning message data has temporal aspects (effective and termination dates)
- The src_eff, src_start_date, and src_end_date parameters in the effectivity satellites handle the temporal logic
- Special handling may be needed for open-ended records where warning_msg_term_dt indicates no termination
- Both source systems (legacy_facets and gemstone_facets) need separate staging and satellite models
- The current view unions data from both sources and filters to the latest version per subscriber_hk and warning_msg_eff_dt combination
- Each subscriber can have multiple warning messages identified by different message_id values and effective dates

## Definition of Done

- [ ] Feature branch created: feature/subscriber-warning-msg-dv2-refactor
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
