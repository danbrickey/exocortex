# Title: Raw vault data pipeline for member_medicare_event

## Description

As a data engineer,
I want to rewrite the existing dbt model for the member_medicare_event entity, which currently supports a 3NF data model,
So that it instead builds a Data Vault 2.0 raw vault structure. This includes creating staging tables, hubs, links, and satellites using dbt, based on data already ingested into the EDP Raw Layer. The new models will follow Data Vault 2.0 standards to support scalability, auditability, and historical tracking.

## Context

The member_medicare_event entity tracks Medicare events and their details for members in both the legacy_facets and gemstone_facets source systems. The source data comes from the `dbo.cmc_memd_mecr_detl` table.

### Data Vault Structure

- **Hubs**:
  - `h_member` (existing) - Member business entity
  - `h_medicare_event` (new) - Medicare event business entity

- **Link**:
  - `l_member_medicare_event` - Relationship between members and medicare events

- **Satellites**:
  - `s_member_medicare_event_legacy_facets` - Effectivity satellite for legacy_facets source
  - `s_member_medicare_event_gemstone_facets` - Effectivity satellite for gemstone_facets source

- **Current View**:
  - `current_member_medicare_event` - Union of current/active records across all sources

## Acceptance Criteria

Given the design document is provided,
When I create a feature branch in the edp_data_domains repository,
Then I name the branch `feature/member_medicare_event-dv2-refactor` and base it on the main branch.

Given the design document is provided,
When I implement the raw vault models,
Then I create the following dbt models for the member_medicare_event entity:
- Rename views:
  - `stg_member_medicare_event_legacy_facets_rename.sql`
  - `stg_member_medicare_event_gemstone_facets_rename.sql`
- Staging views:
  - `stg_member_medicare_event_legacy_facets.sql`
  - `stg_member_medicare_event_gemstone_facets.sql`
- Hub:
  - `h_medicare_event.sql`
- Link:
  - `l_member_medicare_event.sql`
- Satellites (effectivity):
  - `s_member_medicare_event_legacy_facets.sql`
  - `s_member_medicare_event_gemstone_facets.sql`
- Current view:
  - `current_member_medicare_event.sql`

Given the raw vault models are implemented,
When I write dbt documentation (yml files),
Then each model includes:
- A table-level description explaining the vault object type and purpose
- Column-level documentation describing business keys, hash keys, and attributes
- Data lineage using dbt refs
- Documentation for effectivity satellites explaining the src_start_date and src_end_date logic

Given the raw vault models are implemented,
When I write dbt tests,
Then I include:
- Unique key tests for h_medicare_event hub (`medicare_event_hk`)
- Not null tests for h_medicare_event business key (`medicare_event_bk`)
- Unique key tests for l_member_medicare_event link (`member_medicare_event_lk`)
- Referential integrity tests for l_member_medicare_event to both h_member and h_medicare_event
- Not null tests for required hash keys and business keys in all models
- Hashdiff validation for satellites
- Row count and duplication checks for staging tables
- Data quality tests for effectivity dates (src_start_date, src_end_date)
- Tests to ensure edp_record_status is correctly calculated

Given the staging, hub, link, and satellite models are implemented,
When I implement the current view,
Then the view:
- Joins the link (l_member_medicare_event) with both hubs (h_member, h_medicare_event)
- Joins all satellites for the entity (s_member_medicare_event_legacy_facets, s_member_medicare_event_gemstone_facets)
- Unions across both source systems (legacy_facets and gemstone_facets)
- Filters to current/active records only (edp_record_status = 'ACTIVE')
- Includes all business keys, hash keys, and satellite attributes
- Properly handles the latest record per link key across all sources

Given all dbt models, tests, and documentation are complete,
When I run the dbt build command,
Then all models build successfully and all tests pass without errors.

Given all acceptance criteria are met,
When I create a pull request in edp_data_domains,
Then I:
- Include a summary of the Data Vault 2.0 models created
- Reference the legacy 3NF source table `dbo.cmc_memd_mecr_detl` being refactored
- Document that this is a multi-source implementation (legacy_facets and gemstone_facets)
- Document that effectivity satellites are used with src_eff, src_start_date, and src_end_date
- Highlight the creation of the new h_medicare_event hub
- Tag appropriate reviewers for code review

## Technical Notes

### Effectivity Satellite Configuration

The satellites for this entity are configured as effectivity satellites with:
- `src_eff`: `hcfa_eff_dt`
- `src_start_date`: `hcfa_eff_dt`
- `src_end_date`: `hcfa_term_dt`

### Business Keys

- **Member**: `meme_ck` from source (renamed to `member_ck`)
- **Medicare Event**: `memd_event_cd` from source (renamed to `medicare_event_cd`)

### Source Systems

- `legacy_facets` - Legacy Facets system
- `gemstone_facets` - Gemstone Facets system

### Dependencies

- The `h_member` hub must already exist in the data vault
- The `automate_dv` package must be installed and configured

## Estimated Effort

- Development: 3-5 days
- Testing: 1-2 days
- Code review and refinement: 1 day
- Total: 5-8 days

## Definition of Done

- All dbt models created and follow automate_dv conventions
- All models have complete yml documentation
- All models have appropriate dbt tests
- All tests pass successfully
- Code review completed and approved
- Pull request merged to main branch
- Models deployed to development and staging environments
