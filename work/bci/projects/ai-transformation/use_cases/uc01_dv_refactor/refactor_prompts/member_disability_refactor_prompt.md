@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create dbt models and supporting docs from this info:

[context] = @docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md

[sources] = legacy_facets, gemstone_facets
[entity_name] = member_disability
[source_schema].[source_table] = dbo.dbo_cmc_mehd_handicap
[hub_name] = h_member (existing hub)
[hub_key] = member_hk [meme_ck from source]
[link_name] = (no link - standalone hub and satellites)
[effectivity_satellites]:
  - Names:
    - s_member_disability_gemstone_facets
    - s_member_disability_legacy_facets
  - effectivity satellites with all renamed columns from [source_table]
    - src_eff: mehd_eff_dt from source
    - src_start_date: mehd_eff_dt from source  
    - src_end_date: mehd_term_dt from source
  - include system columns
[data_dictionary_info] = @docs\sources\facets\dbo_cmc_mehd_handicap.csv
[current_view] = current_member_disability