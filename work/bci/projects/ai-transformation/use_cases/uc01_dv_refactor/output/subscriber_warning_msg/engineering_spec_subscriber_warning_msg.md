# Data Vault Engineering Spec – Subscriber Warning Message

## 🧱 Artifact Summary

- **Entity Type**: Hub + Effectivity Satellites (attached to existing hub)
- **Hub Name**: h_subscriber (existing hub)
- **Satellite(s)**:
  - s_subscriber_warning_msg_legacy_facets
  - s_subscriber_warning_msg_gemstone_facets
- **Current View**: current_subscriber_warning_msg
- **Staging Model(s)**:
  - stg_subscriber_warning_msg_legacy_facets
  - stg_subscriber_warning_msg_gemstone_facets
- **Source System(s)**: legacy_facets, gemstone_facets
- **Source Table**: dbo.cmc_sbwm_sb_msg

---

## 🔑 Business Keys

### Hub Keys
- **subscriber_hk**: References existing h_subscriber hub (from sbsb_ck)

---

## 🔄 Rename Views

### Column Mapping
Use this mapping in both `stg_subscriber_warning_msg_legacy_facets_rename.sql` and `stg_subscriber_warning_msg_gemstone_facets_rename.sql`:

```sql
'{{ var('*_source_system') }}' as source,
'1' as tenant_id,
sbsb_ck as subscriber_bk,
sbwm_eff_dt as warning_msg_eff_dt,
wmds_seq_no as message_id,
sbwm_term_dt as warning_msg_term_dt,
sbwm_mctr_trsn as termination_reason_cd,
grgr_ck as group_bk,
sbwm_lock_token as lock_token_nbr,
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
  subscriber_warning_msg_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - subscriber_bk
      - warning_msg_eff_dt
      - message_id
      - warning_msg_term_dt
      - termination_reason_cd
      - group_bk
      - lock_token_nbr
      - attachment_source_id
      - edp_record_status
      - edp_record_source
```

---

## 🛰️ Effectivity Satellites

### s_subscriber_warning_msg_legacy_facets.sql / s_subscriber_warning_msg_gemstone_facets.sql

```yaml
source_model: "stg_subscriber_warning_msg_*_facets"

src_pk: "subscriber_hk"

src_dfk: null

src_sfk: null

src_eff: "warning_msg_eff_dt"

src_start_date: "warning_msg_eff_dt"

src_end_date: "warning_msg_term_dt"

src_hashdiff:
  source_column: "subscriber_warning_msg_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - subscriber_bk
  - warning_msg_eff_dt
  - message_id
  - warning_msg_term_dt
  - termination_reason_cd
  - group_bk
  - lock_token_nbr
  - attachment_source_id
  - edp_record_status
  - edp_record_source
  - subscriber_hk

src_ldts: "load_datetime"

src_source: "source"
```

**Note**: These are effectivity satellites attached directly to the h_subscriber hub. Since src_pk is subscriber_hk, multiple warning message periods can exist for the same subscriber, differentiated by their effective dates.

---

## 📄 Current View

### current_subscriber_warning_msg.sql

The current view should:
- Join h_subscriber hub directly with both satellite models
- Union across all source systems (legacy_facets and gemstone_facets)
- Filter to the latest record per subscriber_hk and warning_msg_eff_dt combination
- Include all columns from satellites

---

## ⏱️ Recommended Tests

- **Satellite Tests**:
  - Not null subscriber_hk
  - Not null hashdiff
  - Not null warning_msg_eff_dt
  - Effective dates are valid (warning_msg_eff_dt ≤ warning_msg_term_dt)
  - No gaps in effective dates for same subscriber
  - No overlapping effective date ranges for same subscriber
  - Referential integrity to h_subscriber hub

- **Data Quality Tests**:
  - Valid values for message_id
  - Valid values for termination_reason_cd
  - Non-negative lock_token_nbr
  - Valid group_bk references

---

## 📝 Implementation Notes

1. The h_subscriber hub already exists, so we only need to create the effectivity satellites
2. The effectivity satellites attach directly to the h_subscriber hub using subscriber_hk as the src_pk
3. Each subscriber can have multiple warning message periods, differentiated by effective dates and message_id
4. Effectivity satellites track the temporal aspects of subscriber warning messages with src_eff, src_start_date, and src_end_date
5. The src_end_date (warning_msg_term_dt) may need special handling for open-ended records (e.g., '2199-12-31' for no termination date)
6. Ensure that the source system variables are properly configured in dbt_project.yml

---

## 🔧 File Structure

```
models/
  integration/
    raw_vault/
      staging/
        subscriber_warning_msg/
          stg_subscriber_warning_msg_legacy_facets_rename.sql
          stg_subscriber_warning_msg_legacy_facets.sql
          stg_subscriber_warning_msg_gemstone_facets_rename.sql
          stg_subscriber_warning_msg_gemstone_facets.sql
      satellites/
        effectivity/
          s_subscriber_warning_msg_legacy_facets.sql
          s_subscriber_warning_msg_gemstone_facets.sql
    current_views/
      current_subscriber_warning_msg.sql
```
