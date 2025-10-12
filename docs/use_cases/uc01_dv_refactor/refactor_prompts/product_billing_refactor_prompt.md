# Data Vault Refactor Prompt: product_billing

Please follow the project guidelines and generate the refactored code for the **product_billing** entity.

## Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- **Data Dictionary source_table Name**
  - dbo.cmc_pdbl_prod_bill

- **Rename Views (2 per source)**
  - `stg_product_billing_legacy_facets_rename.sql`
  - `stg_product_billing_gemstone_facets_rename.sql`

- **Staging Views (2 per source)**
  - `stg_product_billing_legacy_facets.sql`
  - `stg_product_billing_gemstone_facets.sql`

- **Hub**
  - `h_product_billing.sql`
    - business Keys:
      - product_billing_hk from pdbc_pfx (Billing Component Prefix)

- **Links**
  - `l_product_billing_product_prefix.sql`
    - business Keys:
      - product_billing_hk from pdbc_pfx (Billing Component Prefix)
      - product_prefix_hk from pdbc_type (Type)

- **Effectivity Satellites (2 per source - attached to link)**
  - For each satellite:
    - src_eff: pdbl_eff_dt from source
    - src_start_date: pdbl_eff_dt from source
    - src_end_date: pdbl_term_dt from source
  - These satellites should include all renamed columns from the source table (descriptive attributes)
  - Include system columns (sys_last_upd_dtm, sys_usus_id, sys_dbuser_id)
  - `s_product_billing_legacy_facets.sql` (attached to l_product_billing_product_prefix)
  - `s_product_billing_gemstone_facets.sql` (attached to l_product_billing_product_prefix)

- **Current View**
  - `current_product_billing.sql`

## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views:

```csv
source_schema,source_table,source_column,table_description,column_description,column_data_type
dbo,cmc_pdbl_prod_bill,pdbc_pfx,Product Billing Component Table,Billing Component Prefix,char
dbo,cmc_pdbl_prod_bill,pdbl_id,Product Billing Component Table,Billing Component ID,char
dbo,cmc_pdbl_prod_bill,pdbl_eff_dt,Product Billing Component Table,Effective Date,datetime
dbo,cmc_pdbl_prod_bill,pdbl_term_dt,Product Billing Component Table,Termination Date,datetime
dbo,cmc_pdbl_prod_bill,bgbg_ck,Product Billing Component Table,Billing Group Contrived Key,int
dbo,cmc_pdbl_prod_bill,pdbl_exp_cat,Product Billing Component Table,Experience Category,char
dbo,cmc_pdbl_prod_bill,pdbl_acct_cat,Product Billing Component Table,Accounting Category,char
dbo,cmc_pdbl_prod_bill,pdbl_lobd_pct,Product Billing Component Table,Line of Business Percent,int
dbo,cmc_pdbl_prod_bill,pdbl_mctr_ctyp,Product Billing Component Table,Billing Component Type,char
dbo,cmc_pdbl_prod_bill,mcre_crcr_id,Product Billing Component Table,Carrier ID,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_conv_rate,Product Billing Component Table,Conventional Rate Table Prefix,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_mpp_rate,Product Billing Component Table,Minimum Premium Rate Table Prefix,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_mpp_liab,Product Billing Component Table,Minimum Premium Liablilty Factors Table Prefix,char
dbo,cmc_pdbl_prod_bill,pdvl_pfx,Product Billing Component Table,Volume Table Prefix,char
dbo,cmc_pdbl_prod_bill,pmft_pfx_area_fctr,Product Billing Component Table,Area Factor Prefix,char
dbo,cmc_pdbl_prod_bill,pdbl_area_defn,Product Billing Component Table,Area Definition,char
dbo,cmc_pdbl_prod_bill,pdbl_area_mod_type,Product Billing Component Table,Area Factor Table Modifier Type,char
dbo,cmc_pdbl_prod_bill,pmft_pfx_sic_fctr,Product Billing Component Table,SIC Factor Prefix,char
dbo,cmc_pdbl_prod_bill,pdbl_sic_mod_type,Product Billing Component Table,Industry Table Modifier Type,char
dbo,cmc_pdbl_prod_bill,pmtr_pfx,Product Billing Component Table,Trend Factor Prefix,char
dbo,cmc_pdbl_prod_bill,pdbl_trnd_mod_type,Product Billing Component Table,Trend Modification Type,char
dbo,cmc_pdbl_prod_bill,pdbl_load_type,Product Billing Component Table,Load Type,char
dbo,cmc_pdbl_prod_bill,pdbl_load_pct,Product Billing Component Table,Load Percent,int
dbo,cmc_pdbl_prod_bill,pdbl_load_amt,Product Billing Component Table,Load Amount,money
dbo,cmc_pdbl_prod_bill,pdbl_comm_incl_ind,Product Billing Component Table,Commission Processing Inclusion Indicator,char
dbo,cmc_pdbl_prod_bill,pdbl_type,Product Billing Component Table,Type,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_hcfa,Product Billing Component Table,Medicare Rate Table,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_hcfa_esrd,Product Billing Component Table,Medicare ESRD Rate Table,char
dbo,cmc_pdbl_prod_bill,mrfd_pfx,Product Billing Component Table,Medicare Factor Table,char
dbo,cmc_pdbl_prod_bill,pdbl_splt_bill_ind,Product Billing Component Table,Split Billing,char
dbo,cmc_pdbl_prod_bill,pdbl_split_pct,Product Billing Component Table,Split Percent,int
dbo,cmc_pdbl_prod_bill,pdbl_conv_rate_mod,Product Billing Component Table,Conventional Rate Table Prefix Modified by,char
dbo,cmc_pdbl_prod_bill,pdbl_mpp_rate_mod,Product Billing Component Table,Minimum Premium Rate Table Prefix Modified by,char
dbo,cmc_pdbl_prod_bill,pdbl_mpp_liab_mod,Product Billing Component Table,Liability Limit Table Prefix Modified by,char
dbo,cmc_pdbl_prod_bill,pmar_pfx,Product Billing Component Table,Volume Reduction Prefix,char
dbo,cmc_pdbl_prod_bill,pdbl_cap_pop_pct,Product Billing Component Table,Capitation Premium Percent,int
dbo,cmc_pdbl_prod_bill,pdrt_pfx_smkr,Product Billing Component Table,Smoker Factor Prefix,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_gndr,Product Billing Component Table,Gender Factor Prefix,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_uncl1,Product Billing Component Table,Und Class 1 Prefix,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_uncl2,Product Billing Component Table,Und Class 2 Prefix,char
dbo,cmc_pdbl_prod_bill,pdrt_pfx_uncl3,Product Billing Component Table,Und Class 3 Prefix,char
dbo,cmc_pdbl_prod_bill,pdbl_round_lev,Product Billing Component Table,Rounding Level,char
dbo,cmc_pdbl_prod_bill,pdbl_lock_token,Product Billing Component Table,Lock Token,smallint
dbo,cmc_pdbl_prod_bill,atxr_source_id,Product Billing Component Table,Attachment Source Id,datetime
dbo,cmc_pdbl_prod_bill,sys_last_upd_dtm,Product Billing Component Table,Last Update Datetime,datetime
dbo,cmc_pdbl_prod_bill,sys_usus_id,Product Billing Component Table,Last Update User ID,varchar
dbo,cmc_pdbl_prod_bill,sys_dbuser_id,Product Billing Component Table,Last Update DBMS User ID,varchar
```

## Architecture Notes

### Hub Design
The `h_product_billing` hub represents the core product billing component entity with:
- Business key: `pdbc_pfx` (Billing Component Prefix)
- This is a simple business key identifying unique billing components

### Link Design
The `l_product_billing_product_prefix` link represents the relationship between:
- Product Billing Component (via `product_billing_hk` from `pdbc_pfx`)
- Product Prefix/Type (via `product_prefix_hk` from `pdbc_type`)

This link captures the many-to-many relationship between billing components and product types.

### Satellite Design
The effectivity satellites are attached to the **link** (not the hub) because:
- The temporal attributes (effective/termination dates) describe the relationship validity period
- All descriptive attributes from the source table should be included in the satellites
- System audit columns (sys_last_upd_dtm, sys_usus_id, sys_dbuser_id) should be included
- Two satellites are needed (one per source system: legacy_facets and gemstone_facets)

### Current View Requirements
The `current_product_billing.sql` view should:
- Join the hub, link, and satellites to present the current state
- Apply effectivity date logic to show only active records
- Include all business attributes from both source systems
- Maintain backward compatibility with existing consumers
