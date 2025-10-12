# Data Vault Refactor Prompt: benefit_summary

Please follow the project guidelines and generate the refactored code for the **benefit_summary** entity.

## Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- **Data Dictionary source_table Name**
  - dbo.cmc_bsbs_sum

- **Rename Views (2 per source)**
  - `stg_benefit_summary_legacy_facets_rename.sql`
  - `stg_benefit_summary_gemstone_facets_rename.sql`

- **Staging Views (2 per source)**
  - `stg_benefit_summary_legacy_facets.sql`
  - `stg_benefit_summary_gemstone_facets.sql`

- **Hub**
  - `h_benefit_summary_type.sql`
    - business Key: benefit_summary_type_hk from bsbs_type

- **Link**
  - `l_benefit_summary_product_prefix.sql`
    - business Keys:
      - benefit_summary_type_hk from bsbs_type
      - product_prefix_hk from pdbc_pfx

- **Standard Satellites (2 per source)**
  - `s_benefit_summary_legacy_facets.sql`
    - Attached to: l_benefit_summary_product_prefix
    - Contains: All descriptive columns from source (bsbs_desc) plus system columns (atxr_source_id, sys_last_upd_dtm, sys_usus_id, sys_dbuser_id, bsbs_lock_token)
    - Change detection: Include all renamed columns in hash_diff calculation

  - `s_benefit_summary_gemstone_facets.sql`
    - Attached to: l_benefit_summary_product_prefix
    - Contains: All descriptive columns from source (bsbs_desc) plus system columns (atxr_source_id, sys_last_upd_dtm, sys_usus_id, sys_dbuser_id, bsbs_lock_token)
    - Change detection: Include all renamed columns in hash_diff calculation

- **Current View**
  - `current_benefit_summary.sql`

## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views:

```csv
source_schema,source_table,source_column,table_description,column_description,column_data_type
dbo,cmc_bsbs_sum,pdbc_pfx,Benefit Summary Table,Benefit Summary Benefit Component Prefix,char
dbo,cmc_bsbs_sum,bsbs_type,Benefit Summary Table,Benefit Summary Type,char
dbo,cmc_bsbs_sum,bsbs_desc,Benefit Summary Table,Benefit Summary Description,varchar
dbo,cmc_bsbs_sum,bsbs_lock_token,Benefit Summary Table,Lock Token,smallint
dbo,cmc_bsbs_sum,atxr_source_id,Benefit Summary Table,Attachment Source Id,datetime
dbo,cmc_bsbs_sum,sys_last_upd_dtm,Benefit Summary Table,Last Update Datetime,datetime
dbo,cmc_bsbs_sum,sys_usus_id,Benefit Summary Table,Last Update User ID,varchar
dbo,cmc_bsbs_sum,sys_dbuser_id,Benefit Summary Table,Last Update DBMS User ID,varchar
```

## Implementation Notes

1. **Hub Design**: The hub captures the business entity "benefit_summary_type" with bsbs_type as the natural business key
2. **Link Design**: The link represents the relationship between benefit_summary_type and product_prefix (pdbc_pfx)
3. **Satellite Design**: Standard satellites attached to the link contain all descriptive attributes and system columns from both source systems
4. **Source Systems**: legacy_facets and gemstone_facets
5. **Current View**: Provides current state view for backward compatibility during transition
