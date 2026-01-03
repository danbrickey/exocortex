---
title: "Data Vault Refactor Prompt: product_prefix"
author: "Dan Brickey"
created: "2025-10-12"
entity: "product_prefix"
source_table: "dbo.cmc_pdpx_desc"
category: "refactor-prompt"
tags: ["data-vault", "refactoring", "product", "product-component"]
---

# Data Vault Refactor Prompt: product_prefix

Please follow the project guidelines and generate the refactored code for the **product_prefix** entity.

## Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- **Data Dictionary source_table Name**
  - dbo.cmc_pdpx_desc

- **Rename Views (2 per source)**
  - `stg_product_prefix_legacy_facets_rename.sql`
  - `stg_product_prefix_gemstone_facets_rename.sql`

- **Staging Views (2 per source)**
  - `stg_product_prefix_legacy_facets.sql`
  - `stg_product_prefix_gemstone_facets.sql`

- **Hub**
  - `h_product_prefix.sql`
    - business Keys:
      - product_prefix_hk from pdbc_pfx

- **Links**
  - `l_product_prefix_product_component_type.sql`
    - business Keys:
      - product_prefix_hk from pdbc_pfx
      - product_component_type_hk from pdbc_type

- **Standard Satellites (2 per source)**
  - `s_l_product_prefix_product_component_type_legacy_facets.sql`
  - `s_l_product_prefix_product_component_type_gemstone_facets.sql`
  - Attached to link: l_product_prefix_product_component_type
  - Includes all columns from cmc_pdpx_desc:
    - pdpx_desc (Component Prefix Description)
    - pdpx_lock_token (Lock Token)
    - atxr_source_id (Attachment Source Id)
    - sys_row_id (System Row Id)

- **Current View**
  - `current_product_prefix.sql`

## Business Context

This entity represents the **Product Component Type Link to Product Component Prefix** relationship. It connects:
- **Product Prefix** (pdbc_pfx) - Component Prefix ID
- **Product Component Type** (pdbc_type) - Component Type

This is a many-to-many relationship table that associates product prefixes with their component types, storing descriptive information about each prefix-type combination.

## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views:

```csv
source_schema,source_table,source_column,table_description,column_description,column_data_type
dbo,cmc_pdpx_desc,pdbc_pfx,Product Component Type Link to Product Component Prefix Table,Component Prefix ID,char
dbo,cmc_pdpx_desc,pdbc_type,Product Component Type Link to Product Component Prefix Table,Component Prefix ID,char
dbo,cmc_pdpx_desc,pdpx_desc,Product Component Type Link to Product Component Prefix Table,Component Prefix Description,char
dbo,cmc_pdpx_desc,pdpx_lock_token,Product Component Type Link to Product Component Prefix Table,Lock Token,smallint
dbo,cmc_pdpx_desc,atxr_source_id,Product Component Type Link to Product Component Prefix Table,Attachment Source Id,datetime
dbo,cmc_pdpx_desc,sys_row_id,Product Component Type Link to Product Component Prefix Table,System Row Id,varchar
```

## Architecture Notes

1. **Hub Design**: h_product_prefix is a simple hub with single business key (pdbc_pfx)
2. **Link Design**: l_product_prefix_product_component_type is a binary link connecting two hubs:
   - h_product_prefix
   - h_product_component_type (assumed to exist or be created separately)
3. **Satellite Design**: Standard link satellites containing all descriptive attributes, including system columns per requirements
4. **Source Systems**: Both legacy_facets and gemstone_facets sources required
5. **Current View**: Provides backward compatibility for existing consumers

## Implementation Checklist

- [ ] Create rename views for both sources
- [ ] Create staging views for both sources
- [ ] Create h_product_prefix hub
- [ ] Create l_product_prefix_product_component_type link
- [ ] Create link satellites for both sources
- [ ] Create current_product_prefix view
- [ ] Validate all naming conventions follow EDP standards
- [ ] Ensure hash keys are generated correctly using automate_dv
- [ ] Test change detection in satellites using hash_diff
- [ ] Verify current view returns expected results

## Dependencies

- **Required Hubs**:
  - h_product_prefix (created by this refactor)
  - h_product_component_type (must exist or be created separately)
- **Source Systems**: legacy_facets, gemstone_facets
- **Architecture Docs**:
  - [docs/architecture/overview/edp-platform-architecture.md](../../../architecture/overview/edp-platform-architecture.md)
  - [docs/engineering-knowledge-base/data-vault-2.0-guide.md](../../../engineering-knowledge-base/data-vault-2.0-guide.md)
