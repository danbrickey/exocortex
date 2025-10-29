@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create dbt models and supporting docs from this info:
[sources] = legacy_facets, gemstone_facets
[entity_name] = member_rating
[source_schema].[source_table] = dbo.cmc_mert_rate_data
[hub_name] = h_member (existing hub)
[hub_key] = member_hk (meme_ck from source)
[effectivity_satellites]:
  - Names:
    - s_member_rating_gemstone_facets
    - s_member_rating_legacy_facets
  - effectivity satellites with all renamed columns from cmc_mert_rate_data
    - src_eff: mert_eff_dt from source
    - src_start_date: mert_eff_dt from source  
    - src_end_date: mert_term_dt from source 
  - attached to [link_name] l_member_rating
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_mert_rate_data.csv  
[current_view] = current_member_rating