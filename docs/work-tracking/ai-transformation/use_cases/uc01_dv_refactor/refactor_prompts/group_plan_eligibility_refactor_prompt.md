# Data Vault Refactor Prompt: group_plan_eligibility

## Import Context Files
@docs\architecture\edp_platform_architecture.md
@docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md
@docs\engineering-knowledge-base\data-vault-2.0-guide.md


## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views

@docs\sources\facets\dbo_cmc_cspi_cs_plan.csv

Please follow the project guidelines and generate the refactored code for the **group_plan_eligibility** entity.

## Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- **Data Dictionary source_table Name**
  - dbo.cmc_cspi_cs_plan

- **Rename Views (2 per source)**
  - `stg_group_plan_eligibility_legacy_facets_rename.sql`
  - `stg_group_plan_eligibility_gemstone_facets_rename.sql`

- **Staging Views (2 per source)**
  - `stg_group_plan_eligibility_legacy_facets.sql`
  - `stg_group_plan_eligibility_gemstone_facets.sql`

- **Links**
  - `l_group_product_category_class_plan.sql`
    - business Keys: 
      - group_hk from grgr_ck
      - product_category_hk from cspd_cat
      - class_hk from cscs_id
      - plan_hk from cspi_id

- **Effectivity Satellites (2 per source)**
  - For each satellite:
    - src_eff: cspi_eff_dt from source
    - src_start_date: cspi_eff_dt from source
    - src_end_date: cspi_term_dt from source
  - `s_group_plan_eligibility_legacy_facets.sql`
  - `s_group_plan_eligibility_gemstone_facets.sql`

- **Current View**
  - `current_group_plan_eligibility.sql`

