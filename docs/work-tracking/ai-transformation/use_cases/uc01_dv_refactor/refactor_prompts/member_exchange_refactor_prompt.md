@docs\work-tracking\ai-transformation\use_cases\uc01_dv_refactor\dv_refactor_project_context.md
Create dbt models and supporting docs from this info:

[sources] = legacy_facets, gemstone_facets
[entity_name] = member_exchange
[source_schema].[source_table] = dbo.cmc_mees_exchange
[hub_name] = h_member (existing hub)
[hub_key] = member_hk [meme_ck from source]
[hub_name] = h_product_category (existing hub)
[hub_key] = product_category_hk [cspd_cat from source]
[link_name] = l_member_exchange
[link_keys]:
  - member_exchange_lk:
    - member_hk (meme_ck from source) 
    - product_category_hk (cspd_cat from source)
[effectivity_satellites]:
  - Names:
    - s_member_exchange_gemstone_facets
    - s_member_exchange_legacy_facets
  - attached to [link_name] l_member_exchange
  - include system columns
  - driving_key: member_hk
  - src_eff: mees_eff_dt
  - src_start_date: mees_eff_dt
  - src_end_date: mees_term_dt
  - payload_columns: all non-key columns from [data_dictionary_info]
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_mees_exchange.csv
[current_view] = current_member_exchange

Output all generated files here: docs\work-tracking\ai-transformation\use_cases\uc01_dv_refactor\output\[entity_name]