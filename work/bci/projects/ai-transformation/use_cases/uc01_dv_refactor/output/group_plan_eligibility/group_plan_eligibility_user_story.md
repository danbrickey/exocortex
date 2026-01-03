# Title: Raw vault data pipeline for group_plan_eligibility

## Description
As a data engineer,
I want to rewrite the existing dbt model for the group_plan_eligibility entity, which currently supports a 3NF data model,
So that it instead builds a Data Vault 2.0 raw vault structure. This includes creating staging tables, hubs, links, and satellites using dbt, based on data already ingested into the EDP Raw Layer. The new models will follow Data Vault 2.0 standards to support scalability, auditability, and historical tracking.

## Acceptance Criteria

Given the design document is provided,
When I create a feature branch in the edp_data_domains repository,
Then I name the branch `feature/group_plan_eligibility-dv2-refactor` and base it on the main branch.

Given the design document is provided,
When I implement the raw vault models,
Then I create the appropriate rename views, staging, hub, link, and satellite dbt models for the group_plan_eligibility entity following the automate_dv package conventions and naming standards.

Given the raw vault models are implemented,
When I write dbt documentation (yml files),
Then each model includes:
- A table-level description explaining the vault object type and purpose
- Column-level documentation describing business keys, hash keys, and attributes
- Data lineage using dbt refs

Given the raw vault models are implemented,
When I write dbt tests,
Then I include:
- Unique key tests for hubs
- Referential integrity tests for links
- Not null tests for required hash keys and business keys
- Hashdiff validation for satellites
- Row count and duplication checks for staging tables
- Data quality tests appropriate for the entity type

Given the staging, hub, link, and satellite models are implemented,
When I implement the current view,
Then the view:
- Joins the hub, links, and all satellites for the entity
- Resolves column conflicts across multiple sources
- Filters to current/active records only
- Unions across all source systems for the entity

Given all dbt models, tests, and documentation are complete,
When I run the dbt build command,
Then all models build successfully and all tests pass without errors.

Given all acceptance criteria are met,
When I create a pull request in edp_data_domains,
Then I:
- Include a summary of the Data Vault 2.0 models created
- Reference the legacy 3NF source models being replaced
- Document any multi-source handling for the entity
- Tag appropriate reviewers for code review
