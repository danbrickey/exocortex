# Title: Raw vault data pipeline for member_exchange

## Description
As a data engineer,
I want to rewrite the existing dbt model for the member_exchange entity, which currently supports a 3NF data model,
So that it instead builds a Data Vault 2.0 raw vault structure. This includes creating staging tables, links, and effectivity satellites using dbt, based on data already ingested into the EDP Raw Layer. The new models will follow Data Vault 2.0 standards to support scalability, auditability, and historical tracking.

## Acceptance Criteria

Given the design document is provided,
When I create a feature branch in the edp_data_domains repository,
Then I name the branch `feature/member_exchange-dv2-refactor` and base it on the main branch.

Given the design document is provided,
When I implement the raw vault models,
Then I create the `stg_member_exchange_*` rename and staging models, the `l_member_exchange` link, the `s_member_exchange_*` effectivity satellites, and the `current_member_exchange` view following the automate_dv conventions.

Given the raw vault models are implemented,
When I write dbt documentation (yml files),
Then each model includes:
- A table-level description explaining the vault object type and purpose
- Column-level documentation describing business keys, hash keys, and attributes
- Data lineage entries that reference `stg_member_exchange_*`, `l_member_exchange`, `s_member_exchange_*`, and `current_member_exchange`

Given the raw vault models are implemented,
When I write dbt tests,
Then I include:
- Unique and not_null tests on `member_exchange_lk`
- Referential integrity tests from `l_member_exchange` to `h_member` and `h_product_category`
- Not null tests on `member_hk`, `product_category_hk`, and `exchange_effective_dt` in each satellite
- Hashdiff change detection for each satellite
- Row count and duplication checks for the staging models

Given the staging, link, and satellite models are implemented,
When I implement the current view,
Then the view:
- Joins `l_member_exchange`, `h_member`, `h_product_category`, and both satellites
- Unions across `legacy_facets` and `gemstone_facets`
- Filters to active (current or future-dated) records only
- Presents all satellite payload attributes for analytics consumers

Given all dbt models, tests, and documentation are complete,
When I run the dbt build command,
Then all models build successfully and all tests pass without errors.

Given all acceptance criteria are met,
When I create a pull request in edp_data_domains,
Then I:
- Include a summary of the Data Vault 2.0 models created
- Reference the legacy 3NF source model being replaced
- Document the multi-source handling for member_exchange
- Tag appropriate reviewers for code review
