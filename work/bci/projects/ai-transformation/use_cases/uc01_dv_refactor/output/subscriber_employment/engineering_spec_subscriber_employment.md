# Data Vault Engineering Spec – Subscriber Employment

## 🧱 Artifact Summary

- **Entity Type**: Hub + Effectivity Satellites (attached to existing hub)
- **Hub Name**: h_subscriber (existing hub)
- **Satellite(s)**:
  - s_subscriber_employment_legacy_facets
  - s_subscriber_employment_gemstone_facets
- **Current View**: current_subscriber_employment
- **Staging Model(s)**:
  - stg_subscriber_employment_legacy_facets
  - stg_subscriber_employment_gemstone_facets
- **Source System(s)**: legacy_facets, gemstone_facets
- **Source Table**: dbo.cmc_sbem_employ

---

## 🔑 Business Keys

### Hub Keys
- **subscriber_hk**: References existing h_subscriber hub (from sbsb_ck)

---

## 🔄 Rename Views

### Column Mapping
Use this mapping in both `stg_subscriber_employment_legacy_facets_rename.sql` and `stg_subscriber_employment_gemstone_facets_rename.sql`:

```sql
'{{ var('*_source_system') }}' as source,
'1' as tenant_id,
sbsb_ck as subscriber_bk,
sbem_eff_dt as employment_eff_dt,
sbem_term_dt as employment_term_dt,
sbem_mctr_trsn as employment_term_reason_cd,
grgr_ck as group_bk,
sbem_occ_cd as occupation_cd,
sbem_dept as department_cd,
sbem_loc as location_cd,
sbem_type as employment_type_cd,
sbem_mctr_dtyp as non_discrimination_type_cd,
sbem_lock_token as lock_token_nbr,
atxr_source_id as attachment_source_id,
edp_start_dt,
edp_end_dt,
edp_record_status,
edp_record_source
```

**Note**: Replace `*_source_system` with either `legacy_source_system` or `gemstone_source_system` depending on the source.

---

## 🧱 Staging Models

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
  subscriber_hk:
    - "source"
    - "subscriber_bk"
  subscriber_employment_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - subscriber_bk
      - employment_eff_dt
      - employment_term_dt
      - employment_term_reason_cd
      - group_bk
      - occupation_cd
      - department_cd
      - location_cd
      - employment_type_cd
      - non_discrimination_type_cd
      - lock_token_nbr
      - attachment_source_id
      - edp_record_status
      - edp_record_source
```

---

## 🛰️ Effectivity Satellites

### s_subscriber_employment_legacy_facets.sql / s_subscriber_employment_gemstone_facets.sql

```yaml
source_model: "stg_subscriber_employment_*_facets"

src_pk: "subscriber_hk"

src_dfk: null

src_sfk: null

src_eff: "employment_eff_dt"

src_start_date: "employment_eff_dt"

src_end_date: "employment_term_dt"

src_hashdiff:
  source_column: "subscriber_employment_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - subscriber_bk
  - employment_eff_dt
  - employment_term_dt
  - employment_term_reason_cd
  - group_bk
  - occupation_cd
  - department_cd
  - location_cd
  - employment_type_cd
  - non_discrimination_type_cd
  - lock_token_nbr
  - attachment_source_id
  - edp_record_status
  - edp_record_source
  - subscriber_hk

src_ldts: "load_datetime"

src_source: "source"
```

**Note**: These are effectivity satellites attached directly to the h_subscriber hub. Since src_pk is subscriber_hk, multiple employment periods can exist for the same subscriber, differentiated by their effective dates.

---

## 📄 Current View

### current_subscriber_employment.sql

The current view should:
- Join h_subscriber hub directly with both satellite models
- Union across all source systems (legacy_facets and gemstone_facets)
- Filter to the latest record per subscriber_hk and employment_eff_dt combination
- Include all columns from satellites

---

## ⏱️ Recommended Tests

- **Satellite Tests**:
  - Not null subscriber_hk
  - Not null hashdiff
  - Not null employment_eff_dt
  - Effective dates are valid (employment_eff_dt ≤ employment_term_dt)
  - No gaps in effective dates for same subscriber
  - No overlapping effective date ranges for same subscriber
  - Referential integrity to h_subscriber hub

- **Data Quality Tests**:
  - Valid values for employment_term_reason_cd
  - Valid values for employment_type_cd
  - Valid values for non_discrimination_type_cd
  - Valid occupation codes (occupation_cd)
  - Valid department codes (department_cd)
  - Valid location codes (location_cd)
  - Non-negative lock_token_nbr

---

## 📝 Implementation Notes

1. The h_subscriber hub already exists, so we only need to create the effectivity satellites
2. The effectivity satellites attach directly to the h_subscriber hub using subscriber_hk as the src_pk
3. Each subscriber can have multiple employment periods, differentiated by effective dates
4. Effectivity satellites track the temporal aspects of subscriber employment with src_eff, src_start_date, and src_end_date
5. The src_end_date (employment_term_dt) may need special handling for open-ended records (e.g., '2199-12-31' for no termination date)
6. Ensure that the source system variables are properly configured in dbt_project.yml
7. Employment data includes important details like occupation codes, department codes, location codes, and employment type classifications

---

## 🔧 File Structure

```
models/
  integration/
    raw_vault/
      staging/
        subscriber_employment/
          stg_subscriber_employment_legacy_facets_rename.sql
          stg_subscriber_employment_legacy_facets.sql
          stg_subscriber_employment_gemstone_facets_rename.sql
          stg_subscriber_employment_gemstone_facets.sql
      satellites/
        effectivity/
          s_subscriber_employment_legacy_facets.sql
          s_subscriber_employment_gemstone_facets.sql
    current_views/
      current_subscriber_employment.sql
```

---

## 📊 Source Data Dictionary

From `dbo.cmc_sbem_employ`:

| Source Column | Target Column | Description | Data Type |
|--------------|---------------|-------------|-----------|
| sbsb_ck | subscriber_bk | Subscriber Contrived Key | int |
| sbem_eff_dt | employment_eff_dt | Subscriber Employment Effective Date | datetime |
| sbem_term_dt | employment_term_dt | Subscriber Employment Termination Date | datetime |
| sbem_mctr_trsn | employment_term_reason_cd | Subscriber Employment Termination Reason | char |
| grgr_ck | group_bk | Group Contrived Key | int |
| sbem_occ_cd | occupation_cd | Subscriber Occupation Code | char |
| sbem_dept | department_cd | Subscriber Department Code | char |
| sbem_loc | location_cd | Subscriber Location | char |
| sbem_type | employment_type_cd | Subscriber Employment Type | char |
| sbem_mctr_dtyp | non_discrimination_type_cd | Non discrimination type | char |
| sbem_lock_token | lock_token_nbr | Lock Token | smallint |
| atxr_source_id | attachment_source_id | Attachment Source Id | datetime |
