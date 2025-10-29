# Data Vault Engineering Spec – Member Rating

## 🧱 Artifact Summary

- **Entity Type**: Hub + Effectivity Satellites (attached to existing hub)
- **Hub Name**: h_member (existing hub)
- **Satellite(s)**:
  - s_member_rating_legacy_facets
  - s_member_rating_gemstone_facets
- **Current View**: current_member_rating
- **Staging Model(s)**:
  - stg_member_rating_legacy_facets
  - stg_member_rating_gemstone_facets
- **Source System(s)**: legacy_facets, gemstone_facets
- **Source Table**: dbo.cmc_mert_rate_data

---

## 🔑 Business Keys

### Hub Keys
- **member_hk**: References existing h_member hub (from meme_ck)

---

## 🔄 Rename Views

### Column Mapping
Use this mapping in both `stg_member_rating_legacy_facets_rename.sql` and `stg_member_rating_gemstone_facets_rename.sql`:

```sql
'{{ var('*_source_system') }}' as source,
'1' as tenant_id,
meme_ck as member_bk,
mert_eff_dt as rating_eff_dt,
mert_term_dt as rating_term_dt,
grgr_ck as group_bk,
mert_smoker_ind as smoker_ind,
mert_mctr_fct1 as underwriting_class_1_cd,
mert_mctr_fct2 as underwriting_class_2_cd,
mert_mctr_fct3 as underwriting_class_3_cd,
mert_lock_token as lock_token_nbr,
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
  member_hk:
    - "source"
    - "member_bk"
  member_rating_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - member_bk
      - rating_eff_dt
      - rating_term_dt
      - group_bk
      - smoker_ind
      - underwriting_class_1_cd
      - underwriting_class_2_cd
      - underwriting_class_3_cd
      - lock_token_nbr
      - attachment_source_id
      - edp_record_status
      - edp_record_source
```

---

## 🛰️ Effectivity Satellites

### s_member_rating_legacy_facets.sql / s_member_rating_gemstone_facets.sql

```yaml
source_model: "stg_member_rating_*_facets"

src_pk: "member_hk"

src_dfk: null

src_sfk: null

src_eff: "rating_eff_dt"

src_start_date: "rating_eff_dt"

src_end_date: "rating_term_dt"

src_hashdiff:
  source_column: "member_rating_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - member_bk
  - rating_eff_dt
  - rating_term_dt
  - group_bk
  - smoker_ind
  - underwriting_class_1_cd
  - underwriting_class_2_cd
  - underwriting_class_3_cd
  - lock_token_nbr
  - attachment_source_id
  - edp_record_status
  - edp_record_source
  - member_hk

src_ldts: "load_datetime"

src_source: "source"
```

**Note**: These are effectivity satellites attached directly to the h_member hub. Since src_pk is member_hk, multiple rating periods can exist for the same member, differentiated by their effective dates.

---

## 📄 Current View

### current_member_rating.sql

The current view should:
- Join h_member hub directly with both satellite models
- Union across all source systems (legacy_facets and gemstone_facets)
- Filter to the latest record per member_hk and rating_eff_dt combination
- Include all columns from satellites

---

## ⏱️ Recommended Tests

- **Satellite Tests**:
  - Not null member_hk
  - Not null hashdiff
  - Not null rating_eff_dt
  - Effective dates are valid (rating_eff_dt ≤ rating_term_dt)
  - No gaps in effective dates for same member
  - No overlapping effective date ranges for same member
  - Referential integrity to h_member hub

- **Data Quality Tests**:
  - Valid values for smoker_ind
  - Valid values for underwriting classification codes
  - Non-negative lock_token_nbr

---

## 📝 Implementation Notes

1. The h_member hub already exists, so we only need to create the effectivity satellites
2. The effectivity satellites attach directly to the h_member hub using member_hk as the src_pk
3. Each member can have multiple rating periods, differentiated by effective dates
4. Effectivity satellites track the temporal aspects of member ratings with src_eff, src_start_date, and src_end_date
5. The src_end_date (rating_term_dt) may need special handling for open-ended records (e.g., '2199-12-31' for no termination date)
6. Ensure that the source system variables are properly configured in dbt_project.yml

---

## 🔧 File Structure

```
models/
  integration/
    raw_vault/
      staging/
        member_rating/
          stg_member_rating_legacy_facets_rename.sql
          stg_member_rating_legacy_facets.sql
          stg_member_rating_gemstone_facets_rename.sql
          stg_member_rating_gemstone_facets.sql
      satellites/
        effectivity/
          s_member_rating_legacy_facets.sql
          s_member_rating_gemstone_facets.sql
    current_views/
      current_member_rating.sql
```
