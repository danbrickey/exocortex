

@ai-resources\prompts\data_vault_refactor_prompt_generator.md
Create a prompt from this info:
[sources] = legacy_facets, gemstone_facets
[entity_name] = benefit_summary_text
[source_schema].[source_table] = dbo.cmc_bstx_sum_text
[hub_name] = h_benefit_summary_text_sequence
[hub_key] = benefit_summary_text_sequence_hk [bstx_seq_no from source]
[link_name] = l_benefit_summary_text_product_prefix
[link_keys]:
  - benefit_summary_text_lk:
    - product_prefix_hk (pdbc_pfx) 
    - benefit_summary_type_hk (bsbs_type)
    - benefit_summary_text_sequence_hk (bstx_seq_no)
[standard_satellites]:
  - Names:
    - s_benefit_summary_text_gemstone_facets
    - s_benefit_summary_text_legacy_facets
  - standard satellites with all renamed columns from [source_table] 
  - attached to [link_name] l_benefit_summary_text_product_prefix
  - include system columns
[data_dictionary_info] = @docs/sources/facets/dbo_cmc_bstx_sum_text.csv 
[current_view] = current_benefit_summary_text


[effectivity_satellites]:
  - Names:
    - s_benefit_summary_text_gemstone_facets
    - s_benefit_summary_text_legacy_facets
  - effectivity satellites with all renamed columns from [source_table]
    - src_eff: pdbl_eff_dt from source
    - src_start_date: pdbl_eff_dt from source  
    - src_end_date: pdbl_term_dt from source 
  - attached to [link_name] l_benefit_summary_text_product_prefix
  - include system columns

[standard_satellites]:
  - Names:
    - s_benefit_summary_text_gemstone_facets
    - s_benefit_summary_text_legacy_facets
  - standard satellites with all renamed columns from [source_table] 
  - attached to [link_name] l_benefit_summary_text_product_prefix
  - include system columns

@docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md use this prompt info: @docs\use_cases\uc01_dv_refactor\refactor_prompts\benefit_summary_text_refactor_prompt.md