# Data Vault Engineering Spec – Subscriber Rating

## 🧱 Artifact Summary

- **Entity Type**: Hub + Effectivity Satellites (attached to existing hub)
- **Hub Name**: h_subscriber (existing hub)
- **Satellite(s)**:
  - s_subscriber_rating_legacy_facets
  - s_subscriber_rating_gemstone_facets
- **Current View**: current_subscriber_rating
- **Staging Model(s)**:
  - stg_subscriber_rating_legacy_facets
  - stg_subscriber_rating_gemstone_facets
- **Source System(s)**: legacy_facets, gemstone_facets
- **Source Table**: dbo.cmc_sbrt_rate_data

---

## 🔑 Business Keys

### Hub Keys
- **subscriber_hk**: References existing h_subscriber hub (from sbsb_ck)

---

## 🔄 Rename Views

### Column Mapping
Use this mapping in both `stg_subscriber_rating_legacy_facets_rename.sql` and `stg_subscriber_rating_gemstone_facets_rename.sql`:

```sql
'{{ var('*_source_system') }}' as source,
'1' as tenant_id,
sbsb_ck as subscriber_bk,
sbrt_eff_dt as rating_eff_dt,
sbrt_term_dt as rating_term_dt,
grgr_ck as group_bk,
sbrt_sb_bill_ind as subscriber_billing_ind,
sbrt_smoker_ind as smoker_ind,
sbrt_rt_st as rating_state_cd,
sbrt_rt_cnty as rating_county_cd,
sbrt_rt_area as rating_area_cd,
sbrt_rt_sic as rating_sic_cd,
sbrt_lock_token as lock_token_nbr,
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
  subscriber_rating_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - subscriber_bk
      - rating_eff_dt
      - rating_term_dt
      - group_bk
      - subscriber_billing_ind
      - smoker_ind
      - rating_state_cd
      - rating_county_cd
      - rating_area_cd
      - rating_sic_cd
      - lock_token_nbr
      - attachment_source_id
      - edp_record_status
      - edp_record_source
```

---

## 🛰️ Effectivity Satellites

### s_subscriber_rating_legacy_facets.sql / s_subscriber_rating_gemstone_facets.sql

```yaml
source_model: "stg_subscriber_rating_*_facets"

src_pk: "subscriber_hk"

src_dfk: null

src_sfk: null

src_eff: "rating_eff_dt"

src_start_date: "rating_eff_dt"

src_end_date: "rating_term_dt"

src_hashdiff:
  source_column: "subscriber_rating_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - subscriber_bk
  - rating_eff_dt
  - rating_term_dt
  - group_bk
  - subscriber_billing_ind
  - smoker_ind
  - rating_state_cd
  - rating_county_cd
  - rating_area_cd
  - rating_sic_cd
  - lock_token_nbr
  - attachment_source_id
  - edp_record_status
  - edp_record_source
  - subscriber_hk

src_ldts: "load_datetime"

src_source: "source"
```

**Note**: These are effectivity satellites attached directly to the h_subscriber hub. Since src_pk is subscriber_hk, multiple rating periods can exist for the same subscriber, differentiated by their effective dates.

---

## 📄 Current View

### current_subscriber_rating.sql

The current view should:
- Join h_subscriber hub directly with both satellite models
- Union across all source systems (legacy_facets and gemstone_facets)
- Filter to the latest record per subscriber_hk and rating_eff_dt combination
- Include all columns from satellites

---

## ⏱️ Recommended Tests

- **Satellite Tests**:
  - Not null subscriber_hk
  - Not null hashdiff
  - Not null rating_eff_dt
  - Effective dates are valid (rating_eff_dt ≤ rating_term_dt)
  - No gaps in effective dates for same subscriber
  - No overlapping effective date ranges for same subscriber
  - Referential integrity to h_subscriber hub

- **Data Quality Tests**:
  - Valid values for subscriber_billing_ind
  - Valid values for smoker_ind
  - Valid state codes (rating_state_cd)
  - Valid county and area codes
  - Non-negative lock_token_nbr

---

## 📝 Implementation Notes

1. The h_subscriber hub already exists, so we only need to create the effectivity satellites
2. The effectivity satellites attach directly to the h_subscriber hub using subscriber_hk as the src_pk
3. Each subscriber can have multiple rating periods, differentiated by effective dates
4. Effectivity satellites track the temporal aspects of subscriber ratings with src_eff, src_start_date, and src_end_date
5. The src_end_date (rating_term_dt) may need special handling for open-ended records (e.g., '2199-12-31' for no termination date)
6. Ensure that the source system variables are properly configured in dbt_project.yml

---

## 🔧 File Structure

```
models/
  integration/
    raw_vault/
      staging/
        subscriber_rating/
          stg_subscriber_rating_legacy_facets_rename.sql
          stg_subscriber_rating_legacy_facets.sql
          stg_subscriber_rating_gemstone_facets_rename.sql
          stg_subscriber_rating_gemstone_facets.sql
      satellites/
        effectivity/
          s_subscriber_rating_legacy_facets.sql
          s_subscriber_rating_gemstone_facets.sql
    current_views/
      current_subscriber_rating.sql
```

---

## 📊 Source Data Dictionary

From `dbo.cmc_sbrt_rate_data`:

| Source Column | Target Column | Description | Data Type |
|--------------|---------------|-------------|-----------|
| sbsb_ck | subscriber_bk | Subscriber Contrived Key | int |
| sbrt_eff_dt | rating_eff_dt | Data Row Effective Date | datetime |
| sbrt_term_dt | rating_term_dt | Data Row Termination Date | datetime |
| grgr_ck | group_bk | Group Contrived Key | int |
| sbrt_sb_bill_ind | subscriber_billing_ind | Subscriber Billing Indicator | char |
| sbrt_smoker_ind | smoker_ind | Smoker Indicator for Rating | char |
| sbrt_rt_st | rating_state_cd | Rating State | char |
| sbrt_rt_cnty | rating_county_cd | Rating County | char |
| sbrt_rt_area | rating_area_cd | Rating Area | char |
| sbrt_rt_sic | rating_sic_cd | Standard Industry Class./No. Amer. Indust. Class. Sys. (SIC/NAICS) | char |
| sbrt_lock_token | lock_token_nbr | Lock Token | smallint |
| atxr_source_id | attachment_source_id | Attachment Source Id | datetime |
