# Engineering Specification: Group Plan Eligibility

## Overview

This specification provides the unique elements needed to implement the Data Vault 2.0 model for the `group_plan_eligibility` entity. Engineers can use their preferred templates and copy/paste the specific configurations below.

## Source Information

**Source Table**: `dbo.cmc_cspi_cs_plan`
**Source Systems**: `legacy_facets`, `gemstone_facets`
**Entity Name**: `group_plan_eligibility`

## Business Keys

### Link Business Keys
The link `l_group_product_category_class_plan` uses a composite business key from multiple hubs:

```sql
-- Link business key components
group_hk        -- from h_group (business key: grgr_ck)
product_category_hk  -- from h_product_category (business key: cspd_cat)
class_hk        -- from h_class (business key: cscs_id)
plan_hk         -- from h_plan (business key: cspi_id)
```

## Column Mappings (Rename Views)

### Source to Target Column Names

```sql
-- Business Keys
grgr_ck as group_bk,
cscs_id as class_bk,
cspd_cat as product_category_bk,
cspi_id as plan_bk,

-- Effectivity Dates
cspi_eff_dt as plan_effective_dt,
cspi_term_dt as plan_termination_dt,

-- Product Information
pdpd_id as product_id,

-- Plan Attributes
cspi_sel_ind as plan_selectable_ind,
cspi_fi as plan_family_ind,

-- Rate Guarantee
cspi_guar_dt as rate_guarantee_dt,
cspi_guar_per_mos as rate_guarantee_period_months,
cspi_guar_ind as rate_guarantee_ind,

-- Prefixes and References
pmar_pfx as age_vol_reduction_tbl_pfx,
wmds_seq_no as warning_message_seq_no,

-- Open Enrollment
cspi_open_beg_mmdd as open_enroll_begin_mmdd,
cspi_open_end_mmdd as open_enroll_end_mmdd,

-- Administration
gpai_id as group_admin_rules_id,
cspi_its_prefix as its_prefix,
cspi_age_calc_meth as premium_age_calc_method,

-- Card and ID Information
cspi_card_stock as member_id_card_stock,
cspi_mctr_ctyp as member_id_card_type,

-- HEDIS
cspi_hedis_cebreak as hedis_cont_enroll_break,
cspi_hedis_days as hedis_cont_enroll_days,

-- Plan Year
cspi_pdpd_beg_mmdd as plan_year_begin_mmdd,
cspi_pdpd_co_mnth as plan_co_month,

-- Network and Coverage
nwst_pfx as network_set_pfx,
cvst_pfx as covering_provider_set_pfx,

-- HRA and Postponement
hsai_id as hra_admin_info_id,
cspi_postpone_ind as postponement_ind,

-- Additional Prefixes
grdc_pfx as debit_card_bank_rel_pfx,
uted_pfx as dental_util_edits_pfx,

-- Value Based and Billing
vbbr_id as value_based_benefits_id,
svbl_id as billing_strategy_id,

-- System Fields
cspi_lock_token as lock_token,
atxr_source_id as attachment_source_id,
sys_last_upd_dtm as last_update_dtm,
sys_usus_id as last_update_user_id,
sys_dbuser_id as last_update_dbuser_id,

-- NVL Fields (nullable variants)
cspi_sec_plan_cd_nvl as secondary_plan_cd,
mcre_id_nvl as auth_cert_entity_id,
cspi_its_acct_excp_nvl as its_account_exception,
cspi_ren_beg_mmdd_nvl as renewal_begin_mmdd,
cspi_hios_id_nvl as hios_id,
cspi_itspfx_acctid_nvl as its_pfx_account_id,

-- Patient Care
pgps_pfx as patient_care_program_set_pfx
```

## Hash Key Definitions

### Staging View Hash Configurations

```yaml
# Hub Hash Keys (derived from business keys)
derived_columns:
  group_hk:
    value: "grgr_ck"
  class_hk:
    value: "cscs_id"
  product_category_hk:
    value: "cspd_cat"
  plan_hk:
    value: "cspi_id"

# Link Hash Key
  group_product_category_class_plan_hk:
    value: "group_hk || product_category_hk || class_hk || plan_hk"

# Hashdiff for satellite
  group_plan_eligibility_hashdiff:
    is_hashdiff: true
    columns:
      - plan_effective_dt
      - plan_termination_dt
      - product_id
      - plan_selectable_ind
      - plan_family_ind
      - rate_guarantee_dt
      - rate_guarantee_period_months
      - rate_guarantee_ind
      - age_vol_reduction_tbl_pfx
      - warning_message_seq_no
      - open_enroll_begin_mmdd
      - open_enroll_end_mmdd
      - group_admin_rules_id
      - its_prefix
      - premium_age_calc_method
      - member_id_card_stock
      - member_id_card_type
      - hedis_cont_enroll_break
      - hedis_cont_enroll_days
      - plan_year_begin_mmdd
      - network_set_pfx
      - plan_co_month
      - covering_provider_set_pfx
      - hra_admin_info_id
      - postponement_ind
      - debit_card_bank_rel_pfx
      - dental_util_edits_pfx
      - value_based_benefits_id
      - billing_strategy_id
      - lock_token
      - attachment_source_id
      - last_update_dtm
      - last_update_user_id
      - last_update_dbuser_id
      - secondary_plan_cd
      - auth_cert_entity_id
      - its_account_exception
      - renewal_begin_mmdd
      - hios_id
      - its_pfx_account_id
      - patient_care_program_set_pfx
```

## Link Model Configuration

```yaml
# l_group_product_category_class_plan.sql
source_model: "stg_group_plan_eligibility_{source}"
src_pk: "group_product_category_class_plan_hk"
src_fk:
  - group_hk
  - product_category_hk
  - class_hk
  - plan_hk
src_ldts: "load_datetime"
src_source: "source"
```

## Effectivity Satellite Configuration

Both satellites use the same effectivity configuration:

```yaml
# Effectivity Satellite
source_model: "stg_group_plan_eligibility_{source}"
src_pk: "group_product_category_class_plan_hk"
src_dfk: "group_product_category_class_plan_hk"  # Link foreign key
src_sfk: "plan_hk"                               # Driving key
src_start_date: "plan_effective_dt"
src_end_date: "plan_termination_dt"
src_eff: "plan_effective_dt"
src_ldts: "load_datetime"
src_source: "source"
```

### Payload Columns for Satellites

All non-key columns from the rename view should be included:

```yaml
src_payload:
  - product_id
  - plan_selectable_ind
  - plan_family_ind
  - rate_guarantee_dt
  - rate_guarantee_period_months
  - rate_guarantee_ind
  - age_vol_reduction_tbl_pfx
  - warning_message_seq_no
  - open_enroll_begin_mmdd
  - open_enroll_end_mmdd
  - group_admin_rules_id
  - its_prefix
  - premium_age_calc_method
  - member_id_card_stock
  - member_id_card_type
  - hedis_cont_enroll_break
  - hedis_cont_enroll_days
  - plan_year_begin_mmdd
  - network_set_pfx
  - plan_co_month
  - covering_provider_set_pfx
  - hra_admin_info_id
  - postponement_ind
  - debit_card_bank_rel_pfx
  - dental_util_edits_pfx
  - value_based_benefits_id
  - billing_strategy_id
  - lock_token
  - attachment_source_id
  - last_update_dtm
  - last_update_user_id
  - last_update_dbuser_id
  - secondary_plan_cd
  - auth_cert_entity_id
  - its_account_exception
  - renewal_begin_mmdd
  - hios_id
  - its_pfx_account_id
  - patient_care_program_set_pfx
```

## Current View Logic

The current view should:
1. Join the link `l_group_product_category_class_plan`
2. LEFT JOIN both satellites (`s_group_plan_eligibility_legacy_facets` and `s_group_plan_eligibility_gemstone_facets`)
3. Filter to current records only (where `load_end_datetime IS NULL`)
4. Include all payload columns from both satellites with appropriate source prefixes

## Files to Create

1. `stg_group_plan_eligibility_legacy_facets_rename.sql`
2. `stg_group_plan_eligibility_gemstone_facets_rename.sql`
3. `stg_group_plan_eligibility_legacy_facets.sql`
4. `stg_group_plan_eligibility_gemstone_facets.sql`
5. `l_group_product_category_class_plan.sql`
6. `s_group_plan_eligibility_legacy_facets.sql`
7. `s_group_plan_eligibility_gemstone_facets.sql`
8. `current_group_plan_eligibility.sql`

## Notes

- This is a relationship entity connecting Group, Product Category, Class, and Plan
- Uses effectivity satellites to track time-based relationships
- The link drives the relationship; satellites contain the descriptive attributes
- Effectivity dates: `cspi_eff_dt` (start) and `cspi_term_dt` (end)
- The driving foreign key for effectivity is `plan_hk`
