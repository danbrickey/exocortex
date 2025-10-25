---
title: "Engineering Specification: product_prefix Data Vault Refactor"
author: "Dan Brickey"
created: "2025-10-12"
entity: "product_prefix"
source_table: "dbo.cmc_pdpx_desc"
category: "engineering-spec"
tags: ["data-vault", "refactoring", "product", "product-component", "engineering-guide"]
---

# Engineering Specification: product_prefix Data Vault Refactor

## Overview

This specification provides the key information needed to manually create Data Vault 2.0 artifacts for the **product_prefix** entity. Engineers can use their own templates and copy/paste the unique elements provided here.

## Source Information

- **Source Table**: `dbo.cmc_pdpx_desc`
- **Source Systems**: `legacy_facets`, `gemstone_facets`
- **Entity Type**: Link-based (many-to-many relationship)

## Files to Create

1. Rename Views (2): `stg_product_prefix_{source}_rename.sql`
2. Staging Views (2): `stg_product_prefix_{source}.sql`
3. Hub (1): `h_product_prefix.sql`
4. Link (1): `l_product_prefix_product_component_type.sql`
5. Link Satellites (2): `s_l_product_prefix_product_component_type_{source}.sql`
6. Current View (1): `current_product_prefix.sql`

---

## 1. Rename Views

### Column Mappings (Source → Renamed)

```sql
-- Business Keys
pdbc_pfx as product_prefix_bk,
pdbc_type as product_component_type_bk,

-- Descriptive Attributes
pdpx_desc as prefix_description,
pdpx_lock_token as lock_token,
atxr_source_id as attachment_source_id,
sys_row_id as system_row_id,

-- Metadata (hardcoded for now)
'<SOURCE_SYSTEM>' as source,
'BCI' as tenant_id
```

### Source System Values
- Legacy: `'legacy_facets'`
- Gemstone: `'gemstone_facets'`

---

## 2. Staging Views

### Hash Key Definitions

```yaml
# Hub Hash Keys
- source_column: "product_prefix_bk"
  alias: "product_prefix_hk"

- source_column: "product_component_type_bk"
  alias: "product_component_type_hk"

# Link Hash Key
- source_columns:
    - "product_prefix_bk"
    - "product_component_type_bk"
  alias: "product_prefix_product_component_type_lk"
```

### Hash Diff Definition

```yaml
# Link Satellite Hash Diff
- columns:
    - "prefix_description"
    - "lock_token"
    - "attachment_source_id"
    - "system_row_id"
  alias: "product_prefix_product_component_type_hashdiff"
```

### Derived Columns

```sql
-- Load metadata
current_timestamp()::timestamp_ntz as load_datetime,
source,
tenant_id
```

### All Columns to Include in Staging

```
product_prefix_bk
product_component_type_bk
prefix_description
lock_token
attachment_source_id
system_row_id
source
tenant_id
load_datetime
product_prefix_hk
product_component_type_hk
product_prefix_product_component_type_lk
product_prefix_product_component_type_hashdiff
```

---

## 3. Hub Model: h_product_prefix

### Configuration

```yaml
source_model:
  - "stg_product_prefix_legacy_facets"
  - "stg_product_prefix_gemstone_facets"
src_pk: "product_prefix_hk"
src_nk: "product_prefix_bk"
src_ldts: "load_datetime"
src_source: "source"
```

---

## 4. Link Model: l_product_prefix_product_component_type

### Configuration

```yaml
source_model:
  - "stg_product_prefix_legacy_facets"
  - "stg_product_prefix_gemstone_facets"
src_pk: "product_prefix_product_component_type_lk"
src_fk:
  - "product_prefix_hk"
  - "product_component_type_hk"
src_ldts: "load_datetime"
src_source: "source"
```

---

## 5. Link Satellite Models

### Configuration (per source)

```yaml
source_model: "stg_product_prefix_{source}"
src_pk: "product_prefix_product_component_type_lk"
src_hashdiff: "product_prefix_product_component_type_hashdiff"
src_payload:
  - "prefix_description"
  - "lock_token"
  - "attachment_source_id"
  - "system_row_id"
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "source"
```

---

## 6. Current View: current_product_prefix

### Join Logic

```sql
-- Core structure
with link_current as (
    select
        product_prefix_product_component_type_lk,
        product_prefix_hk,
        product_component_type_hk,
        load_datetime,
        source
    from {{ ref('l_product_prefix_product_component_type') }}
),

-- Union satellites from both sources
satellite_union as (
    select * from {{ ref('s_l_product_prefix_product_component_type_legacy_facets') }}
    union all
    select * from {{ ref('s_l_product_prefix_product_component_type_gemstone_facets') }}
),

-- Get latest record per link key per source
satellite_current as (
    select *
    from satellite_union
    qualify row_number() over (
        partition by product_prefix_product_component_type_lk, source
        order by load_datetime desc
    ) = 1
)

select
    l.product_prefix_hk,
    l.product_component_type_hk,
    l.product_prefix_product_component_type_lk,
    s.prefix_description,
    s.lock_token,
    s.attachment_source_id,
    s.system_row_id,
    s.hashdiff,
    s.load_datetime,
    s.source
from link_current l
left join satellite_current s
    on l.product_prefix_product_component_type_lk = s.product_prefix_product_component_type_lk
    and l.source = s.source
```

### Columns in Final Output

```
product_prefix_hk
product_component_type_hk
product_prefix_product_component_type_lk
prefix_description
lock_token
attachment_source_id
system_row_id
hashdiff
load_datetime
source
```

---

## Dependencies

### Required Hubs
- `h_product_prefix` (created by this refactor)
- `h_product_component_type` (must exist or be created separately)

### Source References
- Raw CDC feeds from `dbo.cmc_pdpx_desc` in both source systems

---

## Data Quality Considerations

1. **Business Key Nulls**: Both `product_prefix_bk` and `product_component_type_bk` should be NOT NULL
2. **Hash Key Uniqueness**: Hub and Link hash keys should be unique per load
3. **Referential Integrity**: Link must reference existing hubs
4. **Change Detection**: Hash diff should properly detect attribute changes

---

## Notes for Engineers

- Follow the `automate_dv` macro conventions for all vault objects
- Ensure consistent naming across all artifacts (snake_case, lowercase)
- Use CTEs for clarity and logical separation of concerns
- Include all columns from the data dictionary, even if not in prior models
- Test incremental loading before deploying to production
- Validate that `h_product_component_type` exists before creating the link
