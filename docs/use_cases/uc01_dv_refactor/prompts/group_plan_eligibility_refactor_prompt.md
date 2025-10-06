# Data Vault Refactor Prompt: group_plan_eligibility

## Import Context Files
@docs\architecture\edp_platform_architecture.md
@docs\use_cases\uc01_dv_refactor\dv_refactor_project_context.md
@docs\engineering-knowledge-base\data-vault-2.0-guide.md

@docs\sources\facets\dbo_cmc_cspi_cs_plan.csv

Please follow the project guidelines and generate the refactored code for the **group_plan_eligibility** entity, using [dbo_cmc_cspi_cs_plan.csv] as the data dictionary info 

## Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- **Data Dictionary source_table Name**
  - dbo.cmc_cspi_cs_plan

- **Rename Views (2 per source)**
  - `stg_group_plan_eligibility_legacy_facets_rename.sql`
  - `stg_group_plan_eligibility_gemstone_facets_rename.sql`

- **Staging Views (2 per source)**
  - `stg_group_plan_eligibility_legacy_facets.sql`
  - `stg_group_plan_eligibility_gemstone_facets.sql`

- **Links**
  - `l_group_product_category_class_plan.sql`
    - business Keys: 
      - group_hk from grgr_ck
      - product_category_hk from cspd_cat
      - class_hk from cscs_id
      - plan_hk from cspi_id

- **Effectivity Satellites (2 per source)**
  - For each satellite:
    - src_eff: cspi_eff_dt from source
    - src_start_date: cspi_eff_dt from source
    - src_end_date: cspi_term_dt from source
  - `s_group_plan_eligibility_legacy_facets.sql`
  - `s_group_plan_eligibility_gemstone_facets.sql`

- **Current View**
  - `current_group_plan_eligibility.sql`

## Data Dictionary

Use this information to map source view references in the prior model code back to the source columns, and rename columns in the rename views: [dbo_cmc_cspi_cs_plan.csv] 

### Data Dictionary

**Table:** dbo.cmc_cspi_cs_plan
**Description:** Plan/Product Linking Data Table

| Source Column | Column Description | Data Type |
| --- | --- | --- |
| grgr_ck | Class/Plan Group Contrived Key | int |
| cscs_id | Class ID | char |
| cspd_cat | Class/Plan Product Category | char |
| cspi_id | Plan ID | char |
| cspi_eff_dt | Class/Plan Effective Date | datetime |
| cspi_term_dt | Class/Plan Termination Date | datetime |
| pdpd_id | Product ID | char |
| cspi_sel_ind | Class/Plan Selectable Indicator | char |
| cspi_fi | Class/Plan Family Indicator | char |
| cspi_guar_dt | Class/Plan Rate Guarantee Date | datetime |
| cspi_guar_per_mos | Class/Plan Rate Guarantee Period Months | smallint |
| cspi_guar_ind | Class/Plan Rate Guarantee Indicator | char |
| pmar_pfx | Class/Plan Age Volume Reduction Table Prefix | char |
| wmds_seq_no | Class/Plan User Warning Message | smallint |
| cspi_open_beg_mmdd | Class/Plan Open Enrollment Begin Period | smallint |
| cspi_open_end_mmdd | Class/Plan Open Enrollment End Period | smallint |
| gpai_id | Class/Plan Group Administration Rules ID | char |
| cspi_its_prefix | ITS Prefix | char |
| cspi_age_calc_meth | Premium Age Calculation Method | char |
| cspi_card_stock | Member ID Card Stock | char |
| cspi_mctr_ctyp | Product Member ID Card Type | char |
| cspi_hedis_cebreak | HEDIS Continuous Enrollment Break | char |
| cspi_hedis_days | HEDIS Continuous Enrollment Days | smallint |
| cspi_pdpd_beg_mmdd | Plan Year Begin Date | smallint |
| nwst_pfx | Network Set Prefix | char |
| cspi_pdpd_co_mnth |  | smallint |
| cvst_pfx | Covering Provider Set Prefix | char |
| hsai_id | HRA Administrative Information ID | char |
| cspi_postpone_ind | Postponement Indicator | char |
| grdc_pfx | Debit Card/Bank Relationship Prefix | char |
| uted_pfx | Dental Utilization Edits Prefix | char |
| vbbr_id | Value Based Benefits Parms ID | char |
| svbl_id | Billing Strategy (Vision Only) | char |
| cspi_lock_token | Lock Token | smallint |
| atxr_source_id | Attachment Source Id | datetime |
| sys_last_upd_dtm | Last Update Datetime | datetime |
| sys_usus_id | Last Update User ID | varchar |
| sys_dbuser_id | Last Update DBMS User ID | varchar |
| cspi_sec_plan_cd_nvl | Secondary Plan Processing code | char |
| mcre_id_nvl | Authorization/Certification Related Entity ID | char |
| cspi_its_acct_excp_nvl | ITS Account Exception | char |
| cspi_ren_beg_mmdd_nvl | Policy Issuance or Renewal Begins Date | smallint |
| cspi_hios_id_nvl | Health Insurance Oversight System Identifier | varchar |
| cspi_itspfx_acctid_nvl | ITS Prefix Account ID | varchar |
| pgps_pfx | Patient Care Program Set | varchar |
