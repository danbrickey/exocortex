@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create dbt models and supporting docs from this info:

[sources] = legacy_facets, gemstone_facets
[entity_name] = subscriber_employment
[source_schema].[source_table] = dbo.cmc_sbem_employ
[hub_name] = h_subscriber (existing hub))
[hub_key] = subscriber_hk [sbsb_ck from source]
[link_name] = (no link for this entity)
[effectivity_satellites]:
  - Names:
    - s_subscriber_employment_gemstone_facets
    - s_subscriber_employment_legacy_facets
  - effectivity satellites with all renamed columns from [source_table]
    - src_eff: sbem_eff_dt from source
    - src_start_date: sbem_eff_dt from source
    - src_end_date: sbem_term_dt from source
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_sbem_employ.csv
[current_view] = current_subscriber_employment