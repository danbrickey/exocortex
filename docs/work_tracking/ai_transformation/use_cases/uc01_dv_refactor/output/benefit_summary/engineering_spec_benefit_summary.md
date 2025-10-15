# Engineering Specification: benefit_summary Entity

## Overview

This specification provides the unique code snippets needed to implement the Data Vault 2.0 refactoring for the **benefit_summary** entity. Engineers can use their preferred templates and copy/paste the specific elements shown here.

---

## Source Information

**Source Table**: `dbo.cmc_bsbs_sum`
**Source Systems**: `legacy_facets`, `gemstone_facets`

---

## Data Vault Structure

### Hub: h_benefit_summary_type
- **Business Key**: `bsbs_type`
- **Hash Key Column**: `benefit_summary_type_hk`

### Link: l_benefit_summary_product_prefix
- **Parent Hubs**:
  - `h_benefit_summary_type`
  - `h_product_prefix`
- **Business Keys**:
  - `bsbs_type` → `benefit_summary_type_hk`
  - `pdbc_pfx` → `product_prefix_hk`
- **Hash Key Column**: `benefit_summary_product_prefix_lk`

### Satellites (per source)
- **s_benefit_summary_legacy_facets**
- **s_benefit_summary_gemstone_facets**
- **Parent**: `l_benefit_summary_product_prefix`

---

## Column Mappings

### Source to Renamed Columns

```sql
-- Key Columns
pdbc_pfx as product_prefix_bk,
bsbs_type as benefit_summary_type_bk,

-- Descriptive Columns
bsbs_desc as benefit_summary_desc,

-- System Columns
bsbs_lock_token as lock_token,
atxr_source_id as attachment_source_id,
sys_last_upd_dtm as last_update_dtm,
sys_usus_id as last_update_user_id,
sys_dbuser_id as last_update_db_user_id
```

---

## Hash Key Definitions

### Hub Hash Key (in staging)

```yaml
source_model: "stg_benefit_summary_<source>_rename"
hashed_columns:
  benefit_summary_type_hk:
    - "benefit_summary_type_bk"
```

### Link Hash Key (in staging)

```yaml
hashed_columns:
  benefit_summary_product_prefix_lk:
    - "benefit_summary_type_bk"
    - "product_prefix_bk"
  benefit_summary_type_hk:
    - "benefit_summary_type_bk"
  product_prefix_hk:
    - "product_prefix_bk"
```

### Hashdiff Definition (in staging)

```yaml
hashed_columns:
  benefit_summary_hashdiff:
    is_hashdiff: true
    columns:
      - "benefit_summary_desc"
      - "lock_token"
      - "attachment_source_id"
      - "last_update_dtm"
      - "last_update_user_id"
      - "last_update_db_user_id"
```

---

## Hub Configuration

```yaml
source_model: "stg_benefit_summary_<source>"
src_pk: "benefit_summary_type_hk"
src_nk: "benefit_summary_type_bk"
src_ldts: "load_datetime"
src_source: "record_source"
```

---

## Link Configuration

```yaml
source_model: "stg_benefit_summary_<source>"
src_pk: "benefit_summary_product_prefix_lk"
src_fk:
  - "benefit_summary_type_hk"
  - "product_prefix_hk"
src_ldts: "load_datetime"
src_source: "record_source"
```

---

## Satellite Configuration

```yaml
source_model: "stg_benefit_summary_<source>"
src_pk: "benefit_summary_product_prefix_lk"
src_hashdiff:
  source_column: "benefit_summary_hashdiff"
  alias: "hashdiff"
src_payload:
  - "benefit_summary_desc"
  - "lock_token"
  - "attachment_source_id"
  - "last_update_dtm"
  - "last_update_user_id"
  - "last_update_db_user_id"
src_eff: "load_datetime"
src_ldts: "load_datetime"
src_source: "record_source"
```

---

## Current View Join Logic

```sql
-- Join hub
from {{ ref('h_benefit_summary_type') }} as hub

-- Join link
inner join {{ ref('l_benefit_summary_product_prefix') }} as lnk
  on hub.benefit_summary_type_hk = lnk.benefit_summary_type_hk

-- Join satellites (union across sources)
left join (
  select * from {{ ref('s_benefit_summary_legacy_facets') }}
  where load_end_datetime is null
  union all
  select * from {{ ref('s_benefit_summary_gemstone_facets') }}
  where load_end_datetime is null
) as sat
  on lnk.benefit_summary_product_prefix_lk = sat.benefit_summary_product_prefix_lk
```

---

## Data Dictionary Reference

| Source Column | Renamed Column | Description |
|---------------|----------------|-------------|
| pdbc_pfx | product_prefix_bk | Benefit Summary Benefit Component Prefix |
| bsbs_type | benefit_summary_type_bk | Benefit Summary Type |
| bsbs_desc | benefit_summary_desc | Benefit Summary Description |
| bsbs_lock_token | lock_token | Lock Token |
| atxr_source_id | attachment_source_id | Attachment Source Id |
| sys_last_upd_dtm | last_update_dtm | Last Update Datetime |
| sys_usus_id | last_update_user_id | Last Update User ID |
| sys_dbuser_id | last_update_db_user_id | Last Update DBMS User ID |

---

## Files to Create

1. **stg_benefit_summary_legacy_facets_rename.sql**
2. **stg_benefit_summary_gemstone_facets_rename.sql**
3. **stg_benefit_summary_legacy_facets.sql**
4. **stg_benefit_summary_gemstone_facets.sql**
5. **h_benefit_summary_type.sql**
6. **l_benefit_summary_product_prefix.sql**
7. **s_benefit_summary_legacy_facets.sql**
8. **s_benefit_summary_gemstone_facets.sql**
9. **current_benefit_summary.sql**

---

## Notes

- Both source systems (`legacy_facets` and `gemstone_facets`) require identical structures
- The link connects benefit_summary_type to product_prefix
- All descriptive attributes live in satellites attached to the link
- Current view unions across both source satellites
