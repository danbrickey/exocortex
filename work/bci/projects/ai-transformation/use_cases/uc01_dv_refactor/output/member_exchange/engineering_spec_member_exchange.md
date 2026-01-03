# Data Vault Engineering Spec - member_exchange

## Artifact Summary
- **Entity Type**: Link with effectivity satellites (leverages existing hubs)
- **Hubs Referenced**: `h_member`, `h_product_category`
- **Link**: `l_member_exchange`
- **Effectivity Satellites**: `s_member_exchange_legacy_facets`, `s_member_exchange_gemstone_facets`
- **Rename Models**: `stg_member_exchange_legacy_facets_rename`, `stg_member_exchange_gemstone_facets_rename`
- **Staging Models**: `stg_member_exchange_legacy_facets`, `stg_member_exchange_gemstone_facets`
- **Current View**: `current_member_exchange`
- **Source Systems**: `legacy_facets`, `gemstone_facets`
- **Source Table**: `dbo.cmc_mees_exchange`

---

## Business Keys and Hashes

### Hub Keys
- `member_hk`: existing `h_member` hub hash built from `meme_ck`
- `product_category_hk`: existing `h_product_category` hub hash built from `cspd_cat`

### Link Key
- `member_exchange_lk`: hash of `member_hk` and `product_category_hk`; unique per member/product category relationship per source system

### Driving Key
- `member_hk` drives the effectivity satellites (per project requirement)

---

## Rename Views

Create identical mapping for both rename models, swapping the source-system variable and base staging reference:

```sql
'{{ var('*_source_system') }}' as source,
'1' as tenant_id,
meme_ck as member_bk,
cspd_cat as product_category_bk,
mees_eff_dt as exchange_effective_dt,
mees_term_dt as exchange_termination_dt,
grgr_ck as group_bk,
mees_channel as exchange_channel_cd,
mees_exchange as exchange_id,
mees_mctr_meth as enrollment_method_cd,
mees_aptc_ind as aptc_indicator,
mees_lock_token as lock_token_nbr,
atxr_source_id as attachment_source_id,
sys_last_upd_dtm as system_last_update_dtm,
sys_usus_id as system_update_user_id,
sys_dbuser_id as system_update_db_user_id,
mees_qhp_id_nvl as qhp_identifier,
mees_mem_id_nvl as exchange_assigned_member_id,
mees_policy_id_nvl as exchange_policy_id,
edp_start_dt,
edp_end_dt,
edp_record_status,
edp_record_source
```

Use `stg_legacy_facets_hist__dbo_cmc_mees_exchange` and `stg_gemstone_facets_hist__dbo_cmc_mees_exchange` as the raw imports.

---

## Staging Models

### Derived Columns
```yaml
derived_columns:
  source: "'{{ var('*_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"
```

### Hashed Columns
```yaml
hashed_columns:
  member_hk:
    - source
    - member_bk
  product_category_hk:
    - source
    - product_category_bk
  member_exchange_lk:
    - member_hk
    - product_category_hk
  member_exchange_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - edp_end_dt
      - member_bk
      - product_category_bk
      - exchange_effective_dt
      - exchange_termination_dt
      - group_bk
      - exchange_channel_cd
      - exchange_id
      - enrollment_method_cd
      - aptc_indicator
      - lock_token_nbr
      - attachment_source_id
      - system_last_update_dtm
      - system_update_user_id
      - system_update_db_user_id
      - qhp_identifier
      - exchange_assigned_member_id
      - exchange_policy_id
      - edp_record_status
      - edp_record_source
```

---

## Link Model (`l_member_exchange.sql`)

```yaml
source_model:
  stg_member_exchange_legacy_facets:
    src_pk: "member_exchange_lk"
    src_fk:
      - "member_hk"
      - "product_category_hk"
    src_ldts: "load_datetime"
    src_source: "source"
  stg_member_exchange_gemstone_facets:
    src_pk: "member_exchange_lk"
    src_fk:
      - "member_hk"
      - "product_category_hk"
    src_ldts: "load_datetime"
    src_source: "source"
```

Invoke `automate_dv.link` with the dictionary above and tag the model with `raw_vault` and `link`.

---

## Effectivity Satellites

Attach both satellites to the link using `automate_dv.eff_sat`:

```yaml
source_model: "stg_member_exchange_*_facets"
src_pk: "member_exchange_lk"
src_dfk: "member_hk"
src_sfk: "product_category_hk"
src_eff: "exchange_effective_dt"
src_start_date: "exchange_effective_dt"
src_end_date: "exchange_termination_dt"
src_hashdiff:
  source_column: "member_exchange_hashdiff"
  alias: "hashdiff"
src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - edp_end_dt
  - member_bk
  - product_category_bk
  - exchange_effective_dt
  - exchange_termination_dt
  - group_bk
  - exchange_channel_cd
  - exchange_id
  - enrollment_method_cd
  - aptc_indicator
  - lock_token_nbr
  - attachment_source_id
  - system_last_update_dtm
  - system_update_user_id
  - system_update_db_user_id
  - qhp_identifier
  - exchange_assigned_member_id
  - exchange_policy_id
  - edp_record_status
  - edp_record_source
  - member_hk
  - product_category_hk
  - member_exchange_lk
src_ldts: "load_datetime"
src_source: "source"
```

This satisfies the effectivity satellite requirements, including the driving key (`member_hk`) and full payload from the data dictionary.

---

## Current View (`current_member_exchange.sql`)

Key behaviours:
- Join `l_member_exchange` to `h_member`, `h_product_category`, and the effectivity satellite for each source.
- Retain satellite payload columns after the union.
- Only surface rows where `exchange_termination_dt` is null or in the future.
- Select the latest `load_datetime` per `member_exchange_lk` and `exchange_effective_dt` per source.
- Lower-case the `edp_record_source` value for downstream consumers.

---

## Recommended Tests
- **Link**: `unique` and `not_null` on `member_exchange_lk`; referential integrity tests back to `h_member` and `h_product_category`.
- **Satellites**:
  - `not_null` on `member_exchange_lk`, `member_hk`, `exchange_effective_dt`
  - Hashdiff change detection (`dbt_expectations.hashdiff`) if available
  - Validate `exchange_effective_dt <= exchange_termination_dt` (allow open-ended)
  - Ensure no duplicate `member_exchange_lk` + `exchange_effective_dt` combinations per source
- **Staging**: row count vs. rename, duplicates on `member_exchange_lk`, and mandatory column `not_null` checks.

---

## Implementation Notes
1. `member_hk` and `product_category_hk` already exist; reference the established hubs via the link instead of recreating them.
2. Include both source systems end to end (rename -> staging -> satellite) so the current view can union them consistently.
3. The payload includes insurer operational columns (channel, method, attachments). Keep naming consistent and under 30 characters.
4. `edp_start_dt` is reused as both `load_datetime` and `effective_from`; ensure ingestion logic preserves timestamp precision in Snowflake.

---

## Source Column Reference (`dbo.cmc_mees_exchange`)

| Source Column | Target Column | Description | Data Type |
|---------------|---------------|-------------|-----------|
| meme_ck | member_bk | Member contrived key | int |
| cspd_cat | product_category_bk | Class product category | char |
| mees_eff_dt | exchange_effective_dt | Member exchange effective date | datetime |
| mees_term_dt | exchange_termination_dt | Member exchange termination date | datetime |
| grgr_ck | group_bk | Group contrived key | int |
| mees_channel | exchange_channel_cd | Exchange channel identifier | varchar |
| mees_exchange | exchange_id | Exchange identifier | varchar |
| mees_mctr_meth | enrollment_method_cd | Enrollment method code | char |
| mees_aptc_ind | aptc_indicator | Advanced premium tax credit indicator | char |
| mees_lock_token | lock_token_nbr | Lock token number | smallint |
| atxr_source_id | attachment_source_id | Attachment source identifier | datetime |
| sys_last_upd_dtm | system_last_update_dtm | System last update timestamp | datetime |
| sys_usus_id | system_update_user_id | User id of last updater | varchar |
| sys_dbuser_id | system_update_db_user_id | DB user id of last updater | varchar |
| mees_qhp_id_nvl | qhp_identifier | Qualified health plan identifier | varchar |
| mees_mem_id_nvl | exchange_assigned_member_id | Exchange assigned member identifier | varchar |
| mees_policy_id_nvl | exchange_policy_id | Exchange policy identifier | varchar |
