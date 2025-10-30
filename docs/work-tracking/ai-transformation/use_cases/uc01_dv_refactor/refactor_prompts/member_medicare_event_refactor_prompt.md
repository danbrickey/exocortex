@docs\work-tracking\ai-transformation\use_cases\uc01_dv_refactor\dv_refactor_project_context.md
Create dbt models and supporting docs from this info:

[sources] = legacy_facets, gemstone_facets
[entity_name] = member_medicare_event
[source_schema].[source_table] = dbo.cmc_memd_mecr_detl
[hub_name] = h_member (existing hub)
[hub_key] = member_hk [meme_ck from source]
[hub_name] = h_medicare_event
[hub_key] = medicare_event_hk [memd_event_cd from source]
[link_name] = l_member_medicare_event
[link_keys]:
  - member_medicare_event_lk:
    - member_hk (meme_ck from source) 
    - medicare_event_hk (memd_event_cd from source)
[effectivity_satellites]:
  - Names:
    - s_member_medicare_event_gemstone_facets
    - s_member_medicare_event_legacy_facets
  - effectivity satellites with all renamed columns from [source_table]
    - src_eff: memd_hcfa_eff_dt from source
    - src_start_date: memd_hcfa_eff_dt from source
    - src_end_date: memd_hcfa_term_dt from source
  - attached to [link_name] l_member_medicare_event
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_memd_mecr_detl.csv 
[current_view] = current_member_medicare_event

Output all generated files here: `docs\work-tracking\ai-transformation\use_cases\uc01_dv_refactor\output\[entity_name]`