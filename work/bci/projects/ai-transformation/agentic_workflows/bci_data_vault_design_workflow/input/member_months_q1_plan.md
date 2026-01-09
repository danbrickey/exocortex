# Member Months Definition 2026-Q1 - Work Plan

**Created**: 2026-01-XX  
**Purpose**: Organized work plan for Q1 2026 sprints  
**Teams**: Provider Domain Team | Member Domain Team

---

## Overview

This document organizes user stories by:
1. **Source Layer** (raw_layer → raw_vault → biz_vault)
2. **Domain** (Provider vs Member)
3. **Initiative** (member_months, provider_catalog, network, pcp_attribution, product_key)

**Total Stories**: 95  
**Total Estimated Days**: ~250 days

---

## Team Assignments

### Provider Domain Team
- **Domains**: Provider, Network, Claim
- **Focus**: Provider catalog, network participation, claim processing

### Member Domain Team  
- **Domains**: Member, Group, Product, Eligibility
- **Focus**: Member months, product key, group management

---

## Work Plan by Layer

---

## PHASE 1: RAW LAYER

### Provider Domain - Raw Layer

#### Claim Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 1 | claim_line | cmc_cdml | h_claim_line | s_claim_line_gemstone_facets<br>s_claim_line_legacy_facets | l_claim_line<br>l_claim_line_provider | 8 | pcp_attribution | N |
| 2 | claim | cmc_clcl | h_claim | s_claim_gemstone_facets<br>s_claim_legacy_facets | l_claim_eligibility<br>l_claim_provider | 8 | pcp_attribution | N |
| 5 | claim_procedure | cmc_clhi | | s_claim_procedure_gemstone_facets<br>s_claim_procedure_legacy_facets | l_claim_procedure | 3 | pcp_attribution | N |

#### Procedure Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 6 | procedure | procedure | h_procedure | s_procedure_valenz | | 4 | pcp_attribution | N |

#### Network Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 54 | network | cmc_nwnw_network | h_network | s_network_gemstone_facets<br>s_network_legacy_facets | | 4 | member_months<br>provider_catalog<br>network | N |
| 57 | network_set | cmc_nwst_net_set | | s_network_set_gemstone_facets<br>s_network_set_legacy_facets | | 1 | member_months<br>provider_catalog<br>network | N |
| 80 | network_provider | cmc_nwpr | | s_network_provider_gemstone_facets<br>s_network_provider_legacy_facets | l_network_participation | 3 | provider_catalog<br>network | N |

#### Provider Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 78 | tax_id_information | cmc_mcti | | s_tax_id_information_gemstone_facets<br>s_tax_id_information_legacy_facets | | - | provider_catalog<br>pcp_attribution | N |
| 79 | tax_id_description | cmc_mctn | | s_tax_id_description_gemstone_facets<br>s_tax_id_description_legacy_facets | | 1 | provider_catalog<br>pcp_attribution | N |
| 83 | practitioner | cmc_prac | h_practitioner | s_practitioner_gemstone_facets<br>s_practitioner_legacy_facets | | sal_practitioner_facets | 6 | provider_catalog | Y |
| 84 | provider_address | cmc_prad | | s_provider_address_gemstone_facets<br>s_provider_address_legacy_facets | | 1 | provider_catalog<br>pcp_attribution | P |
| 85 | provider_affiliation | cmc_prer | | s_provider_affiliation_gemstone_facets<br>s_provider_affiliation_legacy_facets | | - | provider_catalog<br>pcp_attribution | N |
| 86 | provider | cmc_prpr | h_provider | s_provider_gemstone_facets<br>s_provider_legacy_facets | | | 4 | provider_catalog<br>pcp_attribution | Y |
| 87 | provider_practitioner | cmc_prpr | | | | l_provider_practitioner | 2 | provider_catalog<br>pcp_attribution | N |

**Provider Domain Raw Layer Total**: ~32 days

---

### Member Domain - Raw Layer

#### Geography Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 8 | area | cmc_mcar_area | | | | ref_area | 1 | member_months | N |
| 9 | area_zip | cmc_mcaz_area_zips | | | | | ref_area_zip | 1 | member_months | N |
| 10 | county_group | county_group | | | | | ref_county_group | 1 | member_months<br>provider_catalog | N |
| 11 | us_zip_code | r_uszipcode | | | | | ref_us_zip_code | 1 | member_months<br>provider_catalog | N |

#### Group Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 13 | group_policy | bci_groups_group | | | s_group_policy_legacy_facets | | 1 | member_months | N |
| 14 | alpha_prefix | bci_ipgr_its_group | | s_alpha_prefix_gemstone_facets<br>s_alpha_prefix_legacy_facets | | | 1 | member_months | N |
| 15 | group_address | cer_atad_address_d | | s_group_address_gemstone_facets<br>s_group_address_legacy_facets | | | 1 | member_months | N |
| 16 | group_contact | cer_atct_contact_d | | s_group_contact_gemstone_facets<br>s_group_contact_legacy_facets | | | 1 | member_months | N |
| 17 | attachment | cer_atxr_attach_u | | s_attachment_gemstone_facets<br>s_attachment_legacy_facets | | | 1 | member_months | N |
| 18 | group_count | cmc_grgc | | s_group_count_gemstone_facets<br>s_group_count_legacy_facets | | | 1 | - | N |
| 19 | group | cmc_grgr_group | h_group | s_group_gemstone_facets<br>s_group_legacy_facets | | sal_group | 6 | member_months<br>product_key | N |
| 22 | group_relation | cmc_grre_relation | | s_group_relation_gemstone_facets<br>s_group_relation_legacy_facets | | | 1 | member_months | N |
| 23 | group_rating | cmc_grrt | | s_group_rating_gemstone_facets<br>s_group_rating_legacy_facets | | | 1 | - | N |
| 24 | group_address | cmc_mcre_relat_ent | | s_group_address_gemstone_facets<br>s_group_address_legacy_facets | | | 1 | member_months | N |
| 25 | parent_group | cmc_pagr_parent_gr | | s_parent_group_gemstone_facets<br>s_parent_group_legacy_facets | | | 1 | member_months | N |
| 51 | subgroup | cmc_sgsg_sub_group | | s_subgroup_gemstone_facets<br>s_subgroup_legacy_facets | | | 1 | member_months | N |

#### Member Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 26 | external_id | cmc_exid_ext_id | | s_external_id_gemstone_facets<br>s_external_id_legacy_facets | | sal_person | 3 | member_months | N |
| 27 | member_cob | cmc_mecb | | s_member_cob_gemstone_facets<br>s_member_cob_legacy_facets | | | 1 | member_months | N |
| 28 | member_additional_info | cmc_meda | | s_member_additional_info_gemstone_facets<br>s_member_additional_info_legacy_facets | | | - | member_months | N |
| 29 | member_subsidy | cmc_mees_exchange | | s_member_subsidy_gemstone_facets<br>s_member_subsidy_legacy_facets | | | 1 | - | P |
| 30 | member_disability | cmc_mehd | | s_member_disability_gemstone_facets<br>s_member_disability_legacy_facets | | | 1 | - | Y |
| 31 | member_medicare_event | cmc_memd | | s_member_medicare_event_gemstone_facets<br>s_member_medicare_event_legacy_facets | | | 1 | member_months | P |
| 32 | member_medicare_county_code | cmc_memd | | s_member_medicare_county_code_gemstone_facets<br>s_member_medicare_county_code_legacy_facets | | | - | member_months | N |
| 33 | member_medicare_pbp | cmc_memd | | s_member_medicare_pbp_gemstone_facets<br>s_member_medicare_pbp_legacy_facets | | | - | member_months | N |
| 34 | member_medicare_mbi | cmc_memd | | s_member_medicare_mbi_gemstone_facets<br>s_member_medicare_mbi_legacy_facets | | | - | member_months | N |
| 35 | member_medicare_contract | cmc_memd | | s_member_medicare_contract_gemstone_facets<br>s_member_medicare_contract_legacy_facets | | | - | member_months | N |
| 36 | member | cmc_meme_member | h_member | s_member_gemstone_facets<br>s_member_legacy_facets | | sal_member | 6 | member_months<br>product_key | Y |
| 39 | member_eligiblity | cmc_mepe | | s_member_eligiblity_gemstone_facets<br>s_member_eligiblity_legacy_facets | l_member_eligibility | 3 | member_months<br>product_key | N |
| 42 | member_provider | cmc_mepr | | s_member_provider_gemstone_facets<br>s_member_provider_legacy_facets | l_member_provider | 3 | member_months<br>product_key | P |
| 43 | member_rating | cmc_mert | | s_member_rating_gemstone_facets<br>s_member_rating_legacy_facets | | | 1 | member_months | Y |
| 44 | member_student | cmc_mest | | s_member_student_gemstone_facets<br>s_member_student_legacy_facets | | | 1 | - | Y |
| 45 | subscriber_address | cmc_sbad_addr | | s_subscriber_address_gemstone_facets<br>s_subscriber_address_legacy_facets | | | 1 | member_months | P |
| 46 | member_address | cmc_sbad_addr | | s_member_address_gemstone_facets<br>s_member_address_legacy_facets | | | 1 | member_months | P |
| 47 | subscriber_employment | cmc_sbem_employ | | s_subscriber_employment_gemstone_facets<br>s_subscriber_employment_legacy_facets | | | 1 | member_months | Y |
| 48 | subscriber_rating | cmc_sbrt | | s_subscriber_rating_gemstone_facets<br>s_subscriber_rating_legacy_facets | | | 1 | member_months | Y |
| 49 | subscriber | cmc_sbsb_subsc | | s_subscriber_gemstone_facets<br>s_subscriber_legacy_facets | | | 1 | member_months | Y |
| 50 | subscriber_warning | cmc_sbwm | | s_subscriber_warning_gemstone_facets<br>s_subscriber_warning_legacy_facets | | | 1 | member_months | Y |
| 52 | warning_message | cmc_wmds_desc | | s_warning_message_gemstone_facets<br>s_warning_message_legacy_facets | | ref_warning_message | 2 | member_months | N |
| 53 | age_band | seed_file | | | | | ref_age_band | 1 | member_months | N |

#### Product Domain
| # | Entity | Source Table | Hub | Satellites | Links | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|---|---|
| 58 | balanced_funding | balancedfundingproduct | | s_balanced_funding_gemstone_facets<br>s_balanced_funding_legacy_facets | | | 1 | member_months<br>product_key | N |
| 59 | class_type_assignment | bci_classtype_assignment | | | s_class_type_assignment_legacy_facets | | | 1 | member_months<br>product_key | N |
| 60 | billing_group | cmc_bgbg | | s_billing_group_gemstone_facets<br>s_billing_group_legacy_facets | | | 1 | member_months | N |
| 61 | benefit_summary | cmc_bsbs | | s_benefit_summary_gemstone_facets<br>s_benefit_summary_legacy_facets | | | 1 | member_months | N |
| 62 | benefit_summary_text | cmc_bstx | | s_benefit_summary_text_gemstone_facets<br>s_benefit_summary_text_legacy_facets | | | 1 | member_months | N |
| 63 | class | cmc_cscs_class | | s_class_gemstone_facets<br>s_class_legacy_facets | | | 1 | member_months<br>product_key | N |
| 64 | product_category | cmc_cspd | | s_product_category_gemstone_facets<br>s_product_category_legacy_facets | | | 1 | member_months<br>product_key | N |
| 65 | product_plan | cmc_cspi_cs_plan | | s_product_plan_gemstone_facets<br>s_product_plan_legacy_facets | l_group_product_network | sal_product | 5 | member_months<br>product_key | N |
| 66 | its_plan_code | cmc_itpp_plan_prfl | | s_its_plan_code_gemstone_facets<br>s_its_plan_code_legacy_facets | | | 1 | member_months<br>product_key | N |
| 67 | line_of_business | cmc_lobd_line_bus | | s_line_of_business_gemstone_facets<br>s_line_of_business_legacy_facets | | | 1 | - | N |
| 68 | product_benefit | cmc_pdbc | | s_product_benefit_gemstone_facets<br>s_product_benefit_legacy_facets | | | 1 | member_months | N |
| 69 | product_billing | cmc_pdbl | | s_product_billing_gemstone_facets<br>s_product_billing_legacy_facets | | | 1 | member_months | N |
| 70 | product | cmc_pdds_prod_desc | h_product | s_product_gemstone_facets<br>s_product_legacy_facets | | | 4 | member_months<br>product_key | N |
| 73 | product_attributes | cmc_pdpd_product | | s_product_attributes_gemstone_facets<br>s_product_attributes_legacy_facets | | | 1 | member_months<br>product_key | N |
| 74 | product_prefix | cmc_pdpt | | s_product_prefix_gemstone_facets<br>s_product_prefix_legacy_facets | | | 1 | member_months | N |
| 75 | plan | cmc_plds_plan_desc | | s_plan_gemstone_facets<br>s_plan_legacy_facets | | | 1 | member_months<br>product_key | N |
| 76 | classification | r_classification | | | | | ref_classification | 1 | member_months<br>product_key | N |

**Member Domain Raw Layer Total**: ~60 days

---

## PHASE 2: RAW VAULT

### Provider Domain - Raw Vault

| # | Entity | Source | BV Satellite | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|
| 3 | claim_line | various | bes_claim_line | 5 | pcp_attribution | N |
| 4 | claim | various | bes_claim | 5 | pcp_attribution | N |
| 7 | procedure | various | bes_procedure | 5 | pcp_attribution | N |
| 81 | provider_catalog | various | bs_provider_catalog | 5 | provider_catalog<br>network | N |
| 88 | provider | various | bes_provider | 5 | provider_catalog<br>pcp_attribution | N |
| 90 | pcp_attribution | various | bes_pcp_attribution | 7 | pcp_attribution | N |

**Provider Domain Raw Vault Total**: ~32 days

---

### Member Domain - Raw Vault

| # | Entity | Source | BV Satellite | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|
| 12 | us_zip_code | various | | 3 | member_months<br>provider_catalog | N |
| 20 | group | various | bes_group | 5 | member_months<br>product_key | N |
| 37 | member | various | bes_member | 5 | member_months<br>product_key | N |
| 40 | member_eligiblity | various | bs_member_months | 5 | member_months<br>product_key | N |
| 71 | product | various | bes_product | 5 | member_months<br>product_key | N |
| 77 | contract_pbp | r_contract_pbp | | 1 | member_months<br>product_key | N |

**Member Domain Raw Vault Total**: ~24 days

---

## PHASE 3: BUSINESS VAULT

### Provider Domain - Business Vault

| # | Entity | Dimension | Fact | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|
| 56 | network | dim_network | | 3 | member_months<br>provider_catalog<br>network | N |
| 82 | provider_catalog | | fact_provider_catalog | 3 | provider_catalog<br>network | N |
| 89 | provider | dim_provider | | 3 | provider_catalog<br>pcp_attribution | N |
| 91 | provider_1 | dim_provider_1 | | 3 | provider_catalog | N |
| 92 | provider_2 | dim_provider_2 | | 3 | provider_catalog | N |

**Provider Domain Business Vault Total**: ~15 days

---

### Member Domain - Business Vault

| # | Entity | Dimension | Fact | Est. Days | Initiatives | Spec |
|---|---|---|---|---|---|---|
| 21 | group | dim_group | | 3 | member_months<br>product_key | N |
| 38 | member | dim_member | | 3 | member_months<br>product_key | N |
| 41 | member_eligiblity | | fact_member_months | 3 | member_months<br>product_key | N |
| 72 | product | dim_product | | 3 | member_months<br>product_key | N |
| 93 | member_1 | dim_member_1 | | 3 | member_months | N |
| 94 | member_2 | dim_member_2 | | 3 | member_months | N |
| 95 | member_3 | dim_member_3 | | 3 | member_months | N |

**Member Domain Business Vault Total**: ~21 days

---

## Summary by Initiative

### Member Months Initiative
- **Total Stories**: 60+
- **Estimated Days**: ~150 days
- **Domains**: Member, Group, Product, Geography, Network

### Provider Catalog Initiative
- **Total Stories**: 25+
- **Estimated Days**: ~80 days
- **Domains**: Provider, Network

### Network Initiative
- **Total Stories**: 5
- **Estimated Days**: ~20 days
- **Domains**: Network

### PCP Attribution Initiative
- **Total Stories**: 15+
- **Estimated Days**: ~50 days
- **Domains**: Provider, Claim, Member

### Product Key Initiative
- **Total Stories**: 20+
- **Estimated Days**: ~60 days
- **Domains**: Product, Group, Member

---

## Notes

- Stories marked with **Spec: Y** require full specification documents
- Stories marked with **Spec: P** require partial specifications
- Stories with **Est. Days: -** need estimation
- Some entities appear multiple times across layers (e.g., member, provider, product, group, network)
- Dependencies exist between layers - raw_layer must be completed before raw_vault, raw_vault before biz_vault
