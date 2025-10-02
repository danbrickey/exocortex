# Data Vault Engineering Spec – Group Plan Eligibility

## 🧱 Artifact Summary

**Entity Type**: Link + Effectivity Satellites
**Link Name**: l_group_product_category_class_plan
**Satellite(s)**:
- s_group_plan_eligibility_legacy_facets
- s_group_plan_eligibility_gemstone_facets

**Current View**: current_group_plan_eligibility
**Staging Model(s)**:
- stg_group_plan_eligibility_legacy_facets
- stg_group_plan_eligibility_gemstone_facets

**Source System(s)**: legacy_facets, gemstone_facets
**Source Table**: dbo.cmc_cspi_cs_plan

---

## 🎯 Business Context

The Group Plan Eligibility entity represents the linking relationship between Groups, Product Categories, Classes, and Plans in the healthcare system. This is a many-to-many relationship table that defines which plan/product combinations are available to which group/class combinations, along with effective dating and configuration details.

**Key Business Concepts**:
- Tracks plan eligibility at the intersection of group, product category, class, and plan
- Maintains temporal validity through effective and termination dates
- Stores configuration details for plan administration and member services
- Critical for enrollment, billing, and benefit determination processes

---

## 🔄 Data Vault Architecture

### Link Structure
**l_group_product_category_class_plan**
- **Business Keys**:
  - `group_hk` (from grgr_ck)
  - `product_category_hk` (from cspd_cat)
  - `class_hk` (from cscs_id)
  - `plan_hk` (from cspi_id)

### Effectivity Satellite Configuration
Both satellites use the same temporal logic:
- **src_eff**: cspi_eff_dt (effective date from source)
- **src_start_date**: cspi_eff_dt (plan effective date)
- **src_end_date**: cspi_term_dt (plan termination date)

---

## 📊 Column Mapping

### Business Key Columns (Link)
| Source Column | Business Key | Hash Key | Description |
|---------------|--------------|----------|-------------|
| grgr_ck | group_bk | group_hk | Group identifier |
| cspd_cat | product_category_bk | product_category_hk | Product category code |
| cscs_id | class_bk | class_hk | Class identifier |
| cspi_id | plan_bk | plan_hk | Plan identifier |

### Descriptive Attributes (Satellites)
| Source Column | Renamed Column | Data Type | Description |
|---------------|----------------|-----------|-------------|
| cspi_eff_dt | plan_eff_dt | datetime | Plan effective date |
| cspi_term_dt | plan_term_dt | datetime | Plan termination date |
| pdpd_id | product_id | char | Product ID |
| cspi_sel_ind | selectable_ind | char | Selectable indicator |
| cspi_fi | family_ind | char | Family indicator |
| cspi_guar_dt | rate_guarantee_dt | datetime | Rate guarantee date |
| cspi_guar_per_mos | rate_guarantee_period_mos | smallint | Rate guarantee period (months) |
| cspi_guar_ind | rate_guarantee_ind | char | Rate guarantee indicator |
| pmar_pfx | age_volume_reduction_table_pfx | char | Age/volume reduction table prefix |
| wmds_seq_no | warning_message_seq_no | smallint | Warning message sequence number |
| cspi_open_beg_mmdd | open_enrollment_begin_mmdd | smallint | Open enrollment begin date (MMDD) |
| cspi_open_end_mmdd | open_enrollment_end_mmdd | smallint | Open enrollment end date (MMDD) |
| gpai_id | group_admin_rules_id | char | Group administration rules ID |
| cspi_its_prefix | its_prefix | char | ITS prefix |
| cspi_age_calc_meth | premium_age_calc_method | char | Premium age calculation method |
| cspi_card_stock | member_id_card_stock | char | Member ID card stock |
| cspi_mctr_ctyp | product_member_id_card_type | char | Product member ID card type |
| cspi_hedis_cebreak | hedis_continuous_enrollment_break | char | HEDIS continuous enrollment break |
| cspi_hedis_days | hedis_continuous_enrollment_days | smallint | HEDIS continuous enrollment days |
| cspi_pdpd_beg_mmdd | plan_year_begin_mmdd | smallint | Plan year begin date (MMDD) |
| nwst_pfx | network_set_pfx | char | Network set prefix |
| cspi_pdpd_co_mnth | plan_product_co_month | smallint | Plan product co-pay month |
| cvst_pfx | covering_provider_set_pfx | char | Covering provider set prefix |
| hsai_id | hra_admin_info_id | char | HRA administrative information ID |
| cspi_postpone_ind | postponement_ind | char | Postponement indicator |
| grdc_pfx | debit_card_bank_rel_pfx | char | Debit card/bank relationship prefix |
| uted_pfx | dental_util_edits_pfx | char | Dental utilization edits prefix |
| vbbr_id | value_based_benefits_parms_id | char | Value-based benefits parameters ID |
| svbl_id | billing_strategy_vision_id | char | Billing strategy (vision only) |
| cspi_lock_token | lock_token | smallint | Lock token |
| atxr_source_id | attachment_source_id | datetime | Attachment source ID |
| sys_last_upd_dtm | last_update_dtm | datetime | Last update datetime |
| sys_usus_id | last_update_user_id | varchar | Last update user ID |
| sys_dbuser_id | last_update_db_user_id | varchar | Last update DBMS user ID |
| cspi_sec_plan_cd_nvl | secondary_plan_processing_cd | char | Secondary plan processing code |
| mcre_id_nvl | auth_cert_entity_id | char | Authorization/certification entity ID |
| cspi_its_acct_excp_nvl | its_account_exception | char | ITS account exception |
| cspi_ren_beg_mmdd_nvl | policy_renewal_begins_mmdd | smallint | Policy renewal begins date (MMDD) |
| cspi_hios_id_nvl | hios_id | varchar | Health Insurance Oversight System ID |
| cspi_itspfx_acctid_nvl | its_prefix_account_id | varchar | ITS prefix account ID |
| pgps_pfx | patient_care_program_set_pfx | varchar | Patient care program set prefix |

---

## ⏱️ Recommended Tests

### Data Quality Tests
- **Uniqueness**: Unique combination of business keys (group_bk, product_category_bk, class_bk, plan_bk, plan_eff_dt)
- **Not Null Constraints**:
  - group_bk must not be null
  - product_category_bk must not be null
  - class_bk must not be null
  - plan_bk must not be null
  - plan_eff_dt must not be null

### Temporal Validity Tests
- Effective dates are valid (plan_eff_dt ≤ plan_term_dt)
- No gaps in effective dates for same business key combination
- No overlapping effective date ranges for same business key combination

### Referential Integrity Tests
- Valid references to h_group
- Valid references to h_product_category
- Valid references to h_class
- Valid references to h_plan
- Referential integrity between link and satellites

### Business Rule Tests
- Rate guarantee period is positive when rate_guarantee_ind is active
- Open enrollment dates are valid (begin_mmdd ≤ end_mmdd)
- Plan year begin date is valid (MMDD format: 0101-1231)

---

## 📝 Implementation Notes

### Hub Dependencies
This link requires the following hubs to exist:
- **h_group**: Hub for group entities
- **h_product_category**: Hub for product category entities
- **h_class**: Hub for class entities
- **h_plan**: Hub for plan entities

### Effectivity Satellite Pattern
The satellites use the automate_dv `eff_sat` macro which handles:
- Temporal tracking via effective dates
- Hash diff for change detection
- All descriptive attributes as payload columns
- Support for multiple dependent foreign keys

### Current View Logic
The current view:
- Unions data from both legacy_facets and gemstone_facets satellites
- Joins to all four hubs to denormalize business keys
- Uses max(load_datetime) to get the most recent satellite record
- Provides a business-friendly interface matching original 3NF structure

---

## 🔗 Related Artifacts

**Dependencies**:
- h_group (group hub)
- h_product_category (product category hub)
- h_class (class hub)
- h_plan (plan hub)
- stg_legacy_bcifacets_hist__dbo_cmc_cspi_cs_plan (source staging)
- stg_gemstone_facets_hist__dbo_cmc_cspi_cs_plan (source staging)

**Downstream Consumers**:
- Business Vault curated views
- Member eligibility processing
- Billing and premium calculation
- Enrollment management
- Benefit determination logic

---

## 📅 Migration Strategy

### Phase 1: Implementation
1. Ensure all four hub tables exist and are populated
2. Deploy rename views for column standardization
3. Deploy staging models with hash key generation
4. Deploy link table to establish relationships
5. Deploy effectivity satellites with temporal logic
6. Deploy current view for business consumption

### Phase 2: Validation
1. Row count reconciliation against source tables
2. Business key uniqueness validation
3. Temporal integrity checks (no gaps/overlaps)
4. Referential integrity validation
5. Hash key consistency verification

### Phase 3: Cutover
1. Run parallel testing against legacy 3NF structure
2. Validate query performance meets SLA requirements
3. Migrate downstream dependencies to current view
4. Document mapping for troubleshooting
5. Monitor data quality metrics post-cutover

---

## ✅ Acceptance Criteria

- [ ] All source columns mapped to renamed columns
- [ ] All four hash keys generated correctly
- [ ] Link table populated with valid foreign key references
- [ ] Effectivity satellites track temporal changes
- [ ] Current view returns expected row counts
- [ ] All recommended tests pass
- [ ] Documentation complete and reviewed
- [ ] Performance benchmarks meet requirements

---

**Document Version**: 1.0
**Last Updated**: 2025-10-02
**Author**: EDP AI Expert Team
