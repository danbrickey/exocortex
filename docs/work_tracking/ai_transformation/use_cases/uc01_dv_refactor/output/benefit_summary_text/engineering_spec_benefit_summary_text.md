# Engineering Specification: benefit_summary_text

## Overview

This specification provides guidance for implementing the Data Vault 2.0 refactoring of the `benefit_summary_text` entity from source table `dbo.cmc_bstx_sum_text`.

## Entity Structure

### Source Information
- **Source Table**: `dbo.cmc_bstx_sum_text`
- **Source Systems**: `legacy_facets`, `gemstone_facets`
- **Entity Name**: `benefit_summary_text`

### Data Vault Components

**Hub**: `h_benefit_summary_text_sequence`
- Business Key: `bstx_seq_no`

**Link**: `l_benefit_summary_text_product_prefix`
- Three-way link connecting:
  - Product Prefix Hub (pdbc_pfx)
  - Benefit Summary Type Hub (bsbs_type)
  - Benefit Summary Text Sequence Hub (bstx_seq_no)

**Satellites**:
- `s_benefit_summary_text_legacy_facets` (attached to link)
- `s_benefit_summary_text_gemstone_facets` (attached to link)

## Column Mappings

### Source to Renamed Columns

```sql
-- Rename view column mappings
pdbc_pfx as product_prefix,
bsbs_type as benefit_summary_type,
bstx_seq_no as benefit_summary_text_seq_no,
bstx_text as benefit_summary_text,
bstx_lock_token as lock_token,
atxr_source_id as attachment_source_id
```

### Business Keys

```yaml
# Hub: h_benefit_summary_text_sequence
source_column:
  - "benefit_summary_text_seq_no"
hashed_columns:
  - "benefit_summary_text_seq_no"
```

### Link Keys

```yaml
# Link: l_benefit_summary_text_product_prefix
source_fk:
  - "product_prefix_hk"
  - "benefit_summary_type_hk"
  - "benefit_summary_text_sequence_hk"
```

### Hash Key Definitions (Staging View)

```yaml
hashed_columns:
  benefit_summary_text_sequence_hk:
    - "benefit_summary_text_seq_no"

  product_prefix_hk:
    - "product_prefix"

  benefit_summary_type_hk:
    - "benefit_summary_type"

  benefit_summary_text_lk:
    - "product_prefix"
    - "benefit_summary_type"
    - "benefit_summary_text_seq_no"
```

### Hash Diff Columns (Satellite Attributes)

```yaml
# Include all descriptive columns for change detection
hashdiff:
  columns:
    - "benefit_summary_text"
    - "lock_token"
    - "attachment_source_id"
```

## File Generation Checklist

### 1. Rename Views (2 files)
- [ ] `stg_benefit_summary_text_legacy_facets_rename.sql`
- [ ] `stg_benefit_summary_text_gemstone_facets_rename.sql`

### 2. Staging Views (2 files)
- [ ] `stg_benefit_summary_text_legacy_facets.sql`
- [ ] `stg_benefit_summary_text_gemstone_facets.sql`

### 3. Hub (1 file)
- [ ] `h_benefit_summary_text_sequence.sql`

### 4. Link (1 file)
- [ ] `l_benefit_summary_text_product_prefix.sql`

### 5. Satellites (2 files)
- [ ] `s_benefit_summary_text_legacy_facets.sql`
- [ ] `s_benefit_summary_text_gemstone_facets.sql`

### 6. Current View (1 file)
- [ ] `current_benefit_summary_text.sql`

## Data Type Considerations

- **benefit_summary_text** (`bstx_text`): **varbinary** type - ensure proper casting to string types if needed for display
- **benefit_summary_text_seq_no** (`bstx_seq_no`): **smallint** - sequence ordering field
- **attachment_source_id** (`atxr_source_id`): **datetime** - system tracking timestamp

## Key Implementation Notes

1. **Three-Way Link**: This entity requires a link because it connects three business keys (product_prefix, benefit_summary_type, and text_sequence)
2. **Satellites on Link**: The descriptive attributes are attached to the link rather than a hub because they describe the relationship
3. **Varbinary Handling**: The `benefit_summary_text` column is varbinary and may need special handling in reporting views
4. **Source System Tagging**: Maintain separate satellites for each source system to track lineage
5. **Current View**: Union across both source systems and filter to latest records per business key

## Testing Recommendations

- Verify hash key generation consistency across source systems
- Test varbinary data type handling in staging and satellite loads
- Validate link integrity between all three parent hubs
- Confirm hashdiff properly detects changes in descriptive attributes
- Test incremental loading behavior
