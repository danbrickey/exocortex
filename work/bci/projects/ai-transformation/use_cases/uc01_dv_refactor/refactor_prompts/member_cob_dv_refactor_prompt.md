
## Import Context Files
@docs\architecture\edp_platform_architecture.md
@docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md
@docs\engineering-knowledge-base\data-vault-2.0-guide.md


## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views

@docs\sources\facets\dbo_cmc_mecb_cob.csv

Please follow the project guidelines and generate the refactored spec for the member_cob entity

### Expected Output Summary

- Data Dictionary source_table name:
  - cmc_mecb_cob

I expect that the Raw Vault artifacts will include:

- Rename Views (1 per source)
  - stg_member_cob_legacy_facets_rename.sql
  - stg_member_cob_gemstone_facets_rename.sql
- Staging Views (1 per source)
  - stg_member_cob_legacy_facets.sql
  - stg_member_cob_gemstone_facets.sql
- Hub
  - h_cob_indicator.sql
    - business Keys: cob_indicator_hk (composite key from source columns mecb_insur_type, mecb_insur_order, and mecb_mctr_styp)
- Link
  - l_member_cob.sql
    - business Keys: member_hk (from source column: meme_ck), cob_indicator_hk (composite key from source columns mecb_insur_type, mecb_insur_order, and mecb_mctr_styp)
- Effectivity Satellites (1 per source)
  - s_member_cob_legacy_facets.sql
  - s_member_cob_gemstone_facets.sql
- Current View
  - cv_member_cob.sql
- Backward Compatible View
  - bwd_member_cob.sql
