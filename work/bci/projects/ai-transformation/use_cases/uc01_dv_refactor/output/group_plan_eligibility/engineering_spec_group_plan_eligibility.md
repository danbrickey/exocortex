# Engineering Spec: Group Plan Eligibility

## Overview
This document outlines the specifications for refactoring the `group_plan_eligibility` entity to Data Vault 2.0.

## Artifacts to Create

### 1. Rename Views
- **Path**: `models/staging/legacy_facets/stg_group_plan_eligibility_legacy_facets_rename.sql`
- **Path**: `models/staging/gemstone_facets/stg_group_plan_eligibility_gemstone_facets_rename.sql`
- **Source Table**: `dbo.cmc_cspi_cs_plan`
- **Key Columns**:
  - `grgr_ck` -> `group_ck`
  - `cspd_cat` -> `product_category`
  - `cscs_id` -> `class_id`
  - `cspi_id` -> `plan_id`
  - `cspi_eff_dt` -> `effective_date`
  - `cspi_term_dt` -> `termination_date`

### 2. Staging Models
- **Path**: `models/staging/legacy_facets/stg_group_plan_eligibility_legacy_facets.sql`
- **Path**: `models/staging/gemstone_facets/stg_group_plan_eligibility_gemstone_facets.sql`
- **Hash Keys**:
  - `group_hk`: `group_ck`
  - `product_category_hk`: `product_category`
  - `class_hk`: `class_id`
  - `plan_hk`: `plan_id`
  - `link_hk`: `group_ck` + `product_category` + `class_id` + `plan_id`
- **Hash Diff**: All non-key columns.

### 3. Link Model
- **Path**: `models/raw_vault/links/l_group_product_category_class_plan.sql`
- **Keys**: `link_hk`, `group_hk`, `product_category_hk`, `class_hk`, `plan_hk`

### 4. Satellite Models
- **Path**: `models/raw_vault/sats/s_group_plan_eligibility_legacy_facets.sql`
- **Path**: `models/raw_vault/sats/s_group_plan_eligibility_gemstone_facets.sql`
- **Type**: Effectivity Satellite
- **Src Eff**: `effective_date`
- **Src Start**: `effective_date`
- **Src End**: `termination_date`

### 5. Current View
- **Path**: `models/marts/current_group_plan_eligibility.sql`
- **Logic**: Union all sources, filter to `termination_date` > `current_date` (or high date).
