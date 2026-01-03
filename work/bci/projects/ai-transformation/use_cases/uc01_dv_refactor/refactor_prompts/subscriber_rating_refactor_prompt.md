@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create dbt models and supporting docs from this info:

[sources] = legacy_facets, gemstone_facets
[entity_name] = subscriber_rating
[source_schema].[source_table] = dbo.cmc_sbrt_rate_data
[hub_name] = h_subscriber (existing hub))
[hub_key] = subscriber_hk [sbsb_ck from source]
[link_name] = (no link for this entity)
[effectivity_satellites]:
  - Names:
    - s_subscriber_rating_gemstone_facets
    - s_subscriber_rating_legacy_facets
  - effectivity satellites with all renamed columns from [source_table]
    - src_eff: sbrt_eff_dt from source
    - src_start_date: sbrt_eff_dt from source
    - src_end_date: sbrt_term_dt from source
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_sbrt_rate_data.csv
[current_view] = current_subscriber_rating