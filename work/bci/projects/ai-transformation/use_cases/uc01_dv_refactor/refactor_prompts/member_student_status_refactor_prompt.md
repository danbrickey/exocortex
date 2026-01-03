@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create dbt models and supporting docs from this info:

[sources] = legacy_facets, gemstone_facets
[entity_name] = member_student_status
[source_schema].[source_table] = dbo.cmc_mest_student
[hub_name] = h_member (existing hub)
[hub_key] = member_hk [meme_ck from source]
[link_name] = (no link - standalone hub and satellites)
[effectivity_satellites]:
  - Names:
    - s_member_student_status_gemstone_facets
    - s_member_student_status_legacy_facets
  - effectivity satellites with all renamed columns from [source_table]
    - src_eff: mest_eff_dt from source
    - src_start_date: mest_eff_dt from source  
    - src_end_date: mest_term_dt from source 
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_mest_student.csv 
[current_view] = current_member_student_status