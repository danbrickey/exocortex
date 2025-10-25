# Data Vault Refactor Prompt: benefit_summary_text

Please follow the project guidelines and generate the refactored code for the **benefit_summary_text** entity.

## Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- **Data Dictionary source_table Name**
  - dbo.cmc_bstx_sum_text

- **Rename Views (2 per source)**
  - `stg_benefit_summary_text_legacy_facets_rename.sql`
  - `stg_benefit_summary_text_gemstone_facets_rename.sql`

- **Staging Views (2 per source)**
  - `stg_benefit_summary_text_legacy_facets.sql`
  - `stg_benefit_summary_text_gemstone_facets.sql`

- **Hub**
  - `h_benefit_summary_text_sequence.sql`
    - Business Key: benefit_summary_text_sequence_hk from bstx_seq_no

- **Link**
  - `l_benefit_summary_text_product_prefix.sql`
    - Business Keys:
      - product_prefix_hk from pdbc_pfx
      - benefit_summary_type_hk from bsbs_type
      - benefit_summary_text_sequence_hk from bstx_seq_no

- **Standard Satellites (2 per source)**
  - `s_benefit_summary_text_legacy_facets.sql`
    - Attached to: l_benefit_summary_text_product_prefix
    - Contains: All renamed columns from source table including system columns (atxr_source_id)
    - Hash Diff: Include all descriptive attributes for change detection
  - `s_benefit_summary_text_gemstone_facets.sql`
    - Attached to: l_benefit_summary_text_product_prefix
    - Contains: All renamed columns from source table including system columns (atxr_source_id)
    - Hash Diff: Include all descriptive attributes for change detection

- **Current View**
  - `current_benefit_summary_text.sql`

## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views:

```csv
source_schema,source_table,source_column,table_description,column_description,column_data_type
dbo,cmc_bstx_sum_text,pdbc_pfx,Benefit Summary Text Table,Benefit Summary Benefit Component Prefix,char
dbo,cmc_bstx_sum_text,bsbs_type,Benefit Summary Text Table,Benefit Summary Text Type,char
dbo,cmc_bstx_sum_text,bstx_seq_no,Benefit Summary Text Table,Benefit Summary Text Sequence Number,smallint
dbo,cmc_bstx_sum_text,bstx_text,Benefit Summary Text Table,Benefit Summary Text Line,varbinary
dbo,cmc_bstx_sum_text,bstx_lock_token,Benefit Summary Text Table,Lock Token,smallint
dbo,cmc_bstx_sum_text,atxr_source_id,Benefit Summary Text Table,Attachment Source Id,datetime
```

## Key Design Notes

### Hub Design
- **h_benefit_summary_text_sequence**: Represents the text sequence as a unique business entity
- The sequence number (bstx_seq_no) serves as the business key

### Link Design
- **l_benefit_summary_text_product_prefix**: Connects benefit summary text to product prefixes and benefit types
- This is a three-way link connecting:
  - Product Prefix (pdbc_pfx)
  - Benefit Summary Type (bsbs_type)
  - Benefit Summary Text Sequence (bstx_seq_no)

### Satellite Design
- Standard satellites contain descriptive attributes including:
  - bstx_text (benefit summary text line - varbinary data type)
  - bstx_lock_token (lock token for optimistic locking)
  - atxr_source_id (system tracking column)
- Satellites are attached to the link to track the relationship-specific attributes
- Change detection should include all descriptive columns in hash_diff

### Data Type Considerations
- **bstx_text** is varbinary type - ensure proper handling in transformations
- **bstx_seq_no** is smallint - sequence ordering field
- **atxr_source_id** is datetime - system tracking timestamp

## Implementation Requirements

1. Follow EDP platform architecture standards for naming conventions
2. Use automate_dv macros for hub, link, and satellite generation
3. Implement proper source system tagging (legacy_facets, gemstone_facets)
4. Include all system columns in satellite tracking
5. Create current view for backward compatibility
6. Ensure proper data type casting and handling for varbinary field
