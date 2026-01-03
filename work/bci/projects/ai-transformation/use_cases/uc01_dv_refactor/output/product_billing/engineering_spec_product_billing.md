# Engineering Specification: product_billing

## Overview
This specification provides guidance for refactoring the product_billing entity from 3NF to Data Vault 2.0 architecture. Use this as a reference when implementing your own code using your preferred templates.

## Source Information
- **Source Table**: `dbo.cmc_pdbl_prod_bill`
- **Source Systems**: `legacy_facets`, `gemstone_facets`
- **Total Columns**: 48

## Business Keys
```sql
-- Hub Business Key
pdbc_pfx as billing_component_pfx  -- Primary identifier

-- Link Business Keys
pdbc_pfx as billing_component_pfx  -- Foreign key to h_product_billing
pdbl_type as product_type          -- Foreign key to h_product_prefix
```

## Hash Key Expressions

### Hub Hash Key (product_billing_hk)
```sql
-- In staging view
{{ automate_dv.hash_concat([
    'billing_component_pfx'
]) }} as product_billing_hk
```

### Link Hash Key (product_billing_product_prefix_lk)
```sql
-- In staging view
{{ automate_dv.hash_concat([
    'billing_component_pfx',
    'product_type'
]) }} as product_billing_product_prefix_lk
```

### Foreign Hub Hash Keys
```sql
-- h_product_billing hash key (already defined above)
{{ automate_dv.hash_concat(['billing_component_pfx']) }} as product_billing_hk

-- h_product_prefix hash key (assuming this hub exists)
{{ automate_dv.hash_concat(['product_type']) }} as product_prefix_hk
```

## Column Renaming Map
Use these mappings in your rename views:

| Source Column | Renamed Column | Type | Description |
|--------------|----------------|------|-------------|
| pdbc_pfx | billing_component_pfx | char | Billing Component Prefix |
| pdbl_id | billing_component_id | char | Billing Component ID |
| pdbl_eff_dt | effective_date | datetime | Effective Date |
| pdbl_term_dt | termination_date | datetime | Termination Date |
| bgbg_ck | billing_group_ck | int | Billing Group Contrived Key |
| pdbl_exp_cat | experience_category | char | Experience Category |
| pdbl_acct_cat | accounting_category | char | Accounting Category |
| pdbl_lobd_pct | line_of_business_pct | int | Line of Business Percent |
| pdbl_mctr_ctyp | billing_component_type | char | Billing Component Type |
| mcre_crcr_id | carrier_id | char | Carrier ID |
| pdrt_pfx_conv_rate | conv_rate_table_pfx | char | Conventional Rate Table Prefix |
| pdrt_pfx_mpp_rate | mpp_rate_table_pfx | char | Minimum Premium Rate Table Prefix |
| pdrt_pfx_mpp_liab | mpp_liab_table_pfx | char | Minimum Premium Liability Factors Table Prefix |
| pdvl_pfx | volume_table_pfx | char | Volume Table Prefix |
| pmft_pfx_area_fctr | area_factor_pfx | char | Area Factor Prefix |
| pdbl_area_defn | area_definition | char | Area Definition |
| pdbl_area_mod_type | area_mod_type | char | Area Factor Table Modifier Type |
| pmft_pfx_sic_fctr | sic_factor_pfx | char | SIC Factor Prefix |
| pdbl_sic_mod_type | sic_mod_type | char | Industry Table Modifier Type |
| pmtr_pfx | trend_factor_pfx | char | Trend Factor Prefix |
| pdbl_trnd_mod_type | trend_mod_type | char | Trend Modification Type |
| pdbl_load_type | load_type | char | Load Type |
| pdbl_load_pct | load_pct | int | Load Percent |
| pdbl_load_amt | load_amt | money | Load Amount |
| pdbl_comm_incl_ind | commission_incl_ind | char | Commission Processing Inclusion Indicator |
| pdbl_type | product_type | char | Type |
| pdrt_pfx_hcfa | medicare_rate_table_pfx | char | Medicare Rate Table |
| pdrt_pfx_hcfa_esrd | medicare_esrd_table_pfx | char | Medicare ESRD Rate Table |
| mrfd_pfx | medicare_factor_table_pfx | char | Medicare Factor Table |
| pdbl_splt_bill_ind | split_billing_ind | char | Split Billing |
| pdbl_split_pct | split_pct | int | Split Percent |
| pdbl_conv_rate_mod | conv_rate_mod | char | Conventional Rate Table Prefix Modified by |
| pdbl_mpp_rate_mod | mpp_rate_mod | char | Minimum Premium Rate Table Prefix Modified by |
| pdbl_mpp_liab_mod | mpp_liab_mod | char | Liability Limit Table Prefix Modified by |
| pmar_pfx | volume_reduction_pfx | char | Volume Reduction Prefix |
| pdbl_cap_pop_pct | capitation_premium_pct | int | Capitation Premium Percent |
| pdrt_pfx_smkr | smoker_factor_pfx | char | Smoker Factor Prefix |
| pdrt_pfx_gndr | gender_factor_pfx | char | Gender Factor Prefix |
| pdrt_pfx_uncl1 | und_class_1_pfx | char | Und Class 1 Prefix |
| pdrt_pfx_uncl2 | und_class_2_pfx | char | Und Class 2 Prefix |
| pdrt_pfx_uncl3 | und_class_3_pfx | char | Und Class 3 Prefix |
| pdbl_round_lev | rounding_level | char | Rounding Level |
| pdbl_lock_token | lock_token | smallint | Lock Token |
| atxr_source_id | attachment_source_id | datetime | Attachment Source Id |
| sys_last_upd_dtm | sys_last_upd_dtm | datetime | Last Update Datetime |
| sys_usus_id | sys_usus_id | varchar | Last Update User ID |
| sys_dbuser_id | sys_dbuser_id | varchar | Last Update DBMS User ID |

## Hashdiff Column Lists

### For Effectivity Satellites
Include ALL columns from the rename view in the hashdiff:

```sql
-- Hashdiff expression for staging view
{{ automate_dv.hashdiff(
    columns=[
        'billing_component_id',
        'billing_group_ck',
        'experience_category',
        'accounting_category',
        'line_of_business_pct',
        'billing_component_type',
        'carrier_id',
        'conv_rate_table_pfx',
        'mpp_rate_table_pfx',
        'mpp_liab_table_pfx',
        'volume_table_pfx',
        'area_factor_pfx',
        'area_definition',
        'area_mod_type',
        'sic_factor_pfx',
        'sic_mod_type',
        'trend_factor_pfx',
        'trend_mod_type',
        'load_type',
        'load_pct',
        'load_amt',
        'commission_incl_ind',
        'medicare_rate_table_pfx',
        'medicare_esrd_table_pfx',
        'medicare_factor_table_pfx',
        'split_billing_ind',
        'split_pct',
        'conv_rate_mod',
        'mpp_rate_mod',
        'mpp_liab_mod',
        'volume_reduction_pfx',
        'capitation_premium_pct',
        'smoker_factor_pfx',
        'gender_factor_pfx',
        'und_class_1_pfx',
        'und_class_2_pfx',
        'und_class_3_pfx',
        'rounding_level',
        'lock_token',
        'attachment_source_id',
        'sys_last_upd_dtm',
        'sys_usus_id',
        'sys_dbuser_id'
    ]
) }} as product_billing_hashdiff
```

## Effectivity Satellite Configuration

### Effectivity Columns
```sql
-- In staging view, add these derived columns:
effective_date as edp_start_dt,
termination_date as edp_end_dt,
case
    when termination_date is null or termination_date > current_timestamp()
    then 'A'
    else 'I'
end as edp_record_status
```

### automate_dv.eff_sat Configuration
```yaml
source_model: stg_product_billing_<source>
src_pk: product_billing_product_prefix_lk  # Link hash key
src_dfk:
  - product_billing_hk
  - product_prefix_hk
src_sfk: product_billing_hk  # Driving key
src_start_date: effective_date
src_end_date: termination_date
src_eff: effective_date
src_ldts: load_datetime
src_source: record_source
```

## File Structure
Create these files for the product_billing entity:

```
output/product_billing/
├── stg_product_billing_legacy_facets_rename.sql
├── stg_product_billing_gemstone_facets_rename.sql
├── stg_product_billing_legacy_facets.sql
├── stg_product_billing_gemstone_facets.sql
├── h_product_billing.sql
├── l_product_billing_product_prefix.sql
├── s_product_billing_legacy_facets.sql
├── s_product_billing_gemstone_facets.sql
└── current_product_billing.sql
```

## Key Implementation Notes

1. **Link Attachment**: Satellites are attached to the LINK (l_product_billing_product_prefix), not the hub
2. **Effectivity Logic**: Use pdbl_eff_dt and pdbl_term_dt for temporal tracking
3. **Multi-Source**: Generate separate rename, staging, and satellite models for each source system
4. **Current View**: Must union across both source systems and apply effectivity filtering
5. **All Columns**: Include ALL 48 columns from the data dictionary in satellites, not just key columns

## Standard Metadata Columns
Add these to all staging views:
```sql
'<source_system>' as record_source,
current_timestamp() as load_datetime,
'edp' as tenant_id
```

## Testing Checklist
- [ ] Verify all 48 source columns are included in rename views
- [ ] Confirm hash keys match between staging and vault models
- [ ] Validate effectivity date logic (start/end/status)
- [ ] Test current view returns only active records
- [ ] Confirm both source systems are included in current view union
- [ ] Verify hashdiff includes all descriptive columns
