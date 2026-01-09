# Member Months Definition 2026-Q1 - User Stories Reference Table

**Created**: 2026-01-XX  
**Source**: `member_months_definition_2026-q1.xlsx - User stories.csv`  
**Purpose**: Complete reference table of all user stories with full metadata for specification creation

---

## Initiative Flags

- **member_months**: Member Months initiative
- **provider_catalog**: Provider Catalog initiative  
- **network**: Network initiative
- **pcp_attribution**: PCP Attribution initiative
- **product_key**: Product Key initiative

---

## Complete User Stories Table

| # | Initiatives | Est. Days | Status | Team | Spec Status | Source | Source Table | Subject Area | Entity | Hub | Satellite 1 | Satellite 2 | Link 1 | Link 2 | Same As Link | Reference | BV Satellite | Dimension | Fact |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| 1 | N,N,N,Y,N | 8 | Active | Sam | Not Started | raw_layer | cmc_cdml | claim | claim_line | h_claim_line | s_claim_line_gemstone_facets | s_claim_line_legacy_facets | l_claim_line | l_claim_line_provider | | | | | |
| 2 | N,N,N,Y,N | 8 | Active | Sam | Not Started | raw_layer | cmc_clcl | claim | claim | h_claim | s_claim_gemstone_facets | s_claim_legacy_facets | l_claim_eligibility | l_claim_provider | | | | | |
| 3 | N,N,N,Y,N | 5 | Active | Sam | Not Started | raw_vault | various | claim | claim_line | | | | | | | | bes_claim_line | | |
| 4 | N,N,N,Y,N | 5 | Active | Sam | Not Started | raw_vault | various | claim | claim | | | | | | | | bes_claim | | |
| 5 | N,N,N,Y,N | 3 | Active | Sam | Not Started | raw_layer | cmc_clhi | claim | claim_procedure | | s_claim_procedure_gemstone_facets | s_claim_procedure_legacy_facets | l_claim_procedure | | | | | | |
| 6 | N,N,N,Y,N | 4 | Active | Sam | Not Started | raw_layer | procedure | procedure | procedure | h_procedure | s_procedure_valenz | | | | | | | | |
| 7 | N,N,N,Y,N | 5 | Active | Sam | Not Started | raw_vault | various | procedure | procedure | | | | | | | | bes_procedure | | |
| 8 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_mcar_area | geography | area | | | | | | | ref_area | | | |
| 9 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_mcaz_area_zips | geography | area_zip | | | | | | | ref_area_zip | | | |
| 10 | Y,Y,N,N,N | 1 | Active | Shay | Not Started | raw_layer | county_group | geography | county_group | | | | | | | ref_county_group | | | |
| 11 | Y,Y,N,N,N | 1 | Active | Shay | Not Started | raw_layer | r_uszipcode | geography | us_zip_code | | | | | | | ref_us_zip_code | | | |
| 12 | Y,Y,N,N,N | 3 | Active | Shay | Not Started | raw_vault | various | geography | us_zip_code | | | | | | | | | dim_geography | |
| 13 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | bci_groups_group | group | group_policy | | | s_group_policy_legacy_facets | | | | | | | |
| 14 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | bci_ipgr_its_group | group | alpha_prefix | | s_alpha_prefix_gemstone_facets | s_alpha_prefix_legacy_facets | | | | | | | |
| 15 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cer_atad_address_d | group | group_address | | s_group_address_gemstone_facets | s_group_address_legacy_facets | | | | | | | |
| 16 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cer_atct_contact_d | group | group_contact | | s_group_contact_gemstone_facets | s_group_contact_legacy_facets | | | | | | | |
| 17 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cer_atxr_attach_u | group | attachment | | s_attachment_gemstone_facets | s_attachment_legacy_facets | | | | | | | |
| 18 | N,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_grgc | group | group_count | | s_group_count_gemstone_facets | s_group_count_legacy_facets | | | | | | | |
| 19 | Y,N,N,Y,N | 6 | Active | Shay | Not Started | raw_layer | cmc_grgr_group | group | group | h_group | s_group_gemstone_facets | s_group_legacy_facets | | | sal_group | | | |
| 20 | Y,N,N,Y,N | 5 | Active | Shay | Not Started | raw_vault | various | group | group | | | | | | | | bes_group | | |
| 21 | Y,N,N,Y,N | 3 | Active | Shay | Not Started | biz_vault | various | group | group | | | | | | | | | dim_group | |
| 22 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_grre_relation | group | group_relation | | s_group_relation_gemstone_facets | s_group_relation_legacy_facets | | | | | | | |
| 23 | N,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_grrt | group | group_rating | | s_group_rating_gemstone_facets | s_group_rating_legacy_facets | | | | | | | |
| 24 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_mcre_relat_ent | group | group_address | | s_group_address_gemstone_facets | s_group_address_legacy_facets | | | | | | | |
| 25 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_pagr_parent_gr | group | parent_group | | s_parent_group_gemstone_facets | s_parent_group_legacy_facets | | | | | | | |
| 26 | Y,N,N,N,N | 3 | Active | Shay | Not Started | raw_layer | cmc_exid_ext_id | member | external_id | | s_external_id_gemstone_facets | s_external_id_legacy_facets | | | sal_person | | | |
| 27 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_mecb | member | member_cob | | s_member_cob_gemstone_facets | s_member_cob_legacy_facets | | | | | | | |
| 28 | Y,N,N,N,N | 0 | ~~Canceled~~ | Shay | Not Started | raw_layer | cmc_meda | member | member_additional_info | | s_member_additional_info_gemstone_facets | s_member_additional_info_legacy_facets | | | | | | | |
| 29 | N,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_mees_exchange | member | member_subsidy | | s_member_subsidy_gemstone_facets | s_member_subsidy_legacy_facets | | | | | | | |
| 30 | N,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_mehd | member | member_disability | | s_member_disability_gemstone_facets | s_member_disability_legacy_facets | | | | | | | |
| 31 | Y,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_memd | member | member_medicare_event | | s_member_medicare_event_gemstone_facets | s_member_medicare_event_legacy_facets | | | | | | | |
| 32 | Y,N,N,N,N | 0 | ~~Canceled~~ | Shay | Not Started | raw_layer | cmc_memd | member | member_medicare_county_code | | s_member_medicare_county_code_gemstone_facets | s_member_medicare_county_code_legacy_facets | | | | | | | |
| 33 | Y,N,N,N,N | 0 | ~~Canceled~~ | Shay | Not Started | raw_layer | cmc_memd | member | member_medicare_pbp | | s_member_medicare_pbp_gemstone_facets | s_member_medicare_pbp_legacy_facets | | | | | | | |
| 34 | Y,N,N,N,N | 0 | ~~Canceled~~ | Shay | Not Started | raw_layer | cmc_memd | member | member_medicare_mbi | | s_member_medicare_mbi_gemstone_facets | s_member_medicare_mbi_legacy_facets | | | | | | | |
| 35 | Y,N,N,N,N | 0 | ~~Canceled~~ | Shay | Not Started | raw_layer | cmc_memd | member | member_medicare_contract | | s_member_medicare_contract_gemstone_facets | s_member_medicare_contract_legacy_facets | | | | | | | |
| 36 | Y,N,N,Y,N | 6 | Active | Shay | Delivered | raw_layer | cmc_meme_member | member | member | h_member | s_member_gemstone_facets | s_member_legacy_facets | | | sal_member | | | |
| 37 | Y,N,N,Y,N | 5 | Active | Shay | Not Started | raw_vault | various | member | member | | | | | | | | bes_member | | |
| 38 | Y,N,N,Y,N | 3 | Active | Shay | Not Started | biz_vault | various | member | member | | | | | | | | | dim_member | |
| 39 | Y,N,N,Y,N | 3 | Active | Shay | Not Started | raw_layer | cmc_mepe | member | member_eligiblity | | s_member_eligiblity_gemstone_facets | s_member_eligiblity_legacy_facets | l_member_eligibility | | | | | |
| 40 | Y,N,N,Y,N | 5 | Active | Shay | Not Started | raw_vault | various | member | member_eligiblity | | | | | | | | bs_member_months | | |
| 41 | Y,N,N,Y,N | 3 | Active | Shay | Not Started | biz_vault | various | member | member_eligiblity | | | | | | | | | fact_member_months |
| 42 | Y,N,N,Y,N | 3 | Active | Shay | Pending | raw_layer | cmc_mepr | member | member_provider | | s_member_provider_gemstone_facets | s_member_provider_legacy_facets | l_member_provider | | | | | |
| 43 | Y,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_mert | member | member_rating | | s_member_rating_gemstone_facets | s_member_rating_legacy_facets | | | | | | |
| 44 | N,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_mest | member | member_student | | s_member_student_gemstone_facets | s_member_student_legacy_facets | | | | | | |
| 45 | Y,N,N,N,N | 1 | Active | Shay | Pending | raw_layer | cmc_sbad_addr | member | subscriber_address | | s_subscriber_address_gemstone_facets | s_subscriber_address_legacy_facets | | | | | | |
| 46 | Y,N,N,N,N | 1 | Active | Shay | Pending | raw_layer | cmc_sbad_addr | member | member_address | | s_member_address_gemstone_facets | s_member_address_legacy_facets | | | | | | |
| 47 | Y,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_sbem_employ | member | subscriber_employment | | s_subscriber_employment_gemstone_facets | s_subscriber_employment_legacy_facets | | | | | | |
| 48 | Y,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_sbrt | member | subscriber_rating | | s_subscriber_rating_gemstone_facets | s_subscriber_rating_legacy_facets | | | | | | |
| 49 | Y,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_sbsb_subsc | member | subscriber | | s_subscriber_gemstone_facets | s_subscriber_legacy_facets | | | | | | |
| 50 | Y,N,N,N,N | 1 | Active | Shay | Delivered | raw_layer | cmc_sbwm | member | subscriber_warning | | s_subscriber_warning_gemstone_facets | s_subscriber_warning_legacy_facets | | | | | | |
| 51 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_sgsg_sub_group | group | subgroup | | s_subgroup_gemstone_facets | s_subgroup_legacy_facets | | | | | | |
| 52 | Y,N,N,N,N | 2 | Active | Shay | Not Started | raw_layer | cmc_wmds_desc | member | warning_message | | s_warning_message_gemstone_facets | s_warning_message_legacy_facets | | | ref_warning_message | | | |
| 53 | Y,N,N,N,N | 1 | Active | Shay | Not Started | dbt | seed_file | member | age_band | | | | | | | ref_age_band | | | |
| 54 | Y,Y,Y,N,N | 4 | Active | Sam | Not Started | raw_layer | cmc_nwnw_network | network | network | h_network | s_network_gemstone_facets | s_network_legacy_facets | | | | | | |
| 55 | Y,Y,Y,N,N | 5 | Active | Sam | Not Started | raw_vault | various | network | network | | | | | | | | bes_network | | |
| 56 | Y,Y,Y,N,N | 3 | Active | Sam | Not Started | biz_vault | various | network | network | | | | | | | | | dim_network | |
| 57 | Y,Y,Y,N,N | 1 | Active | Sam | Not Started | raw_layer | cmc_nwst_net_set | network | network_set | | s_network_set_gemstone_facets | s_network_set_legacy_facets | | | | | | |
| 58 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | balancedfundingproduct | product | balanced_funding | | s_balanced_funding_gemstone_facets | s_balanced_funding_legacy_facets | | | | | | |
| 59 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | bci_classtype_assignment | product | class_type_assignment | | | s_class_type_assignment_legacy_facets | | | | | | |
| 60 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_bgbg | product | billing_group | | s_billing_group_gemstone_facets | s_billing_group_legacy_facets | | | | | | |
| 61 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_bsbs | product | benefit_summary | | s_benefit_summary_gemstone_facets | s_benefit_summary_legacy_facets | | | | | | |
| 62 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_bstx | product | benefit_summary_text | | s_benefit_summary_text_gemstone_facets | s_benefit_summary_text_legacy_facets | | | | | | |
| 63 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | cmc_cscs_class | product | class | | s_class_gemstone_facets | s_class_legacy_facets | | | | | | |
| 64 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | cmc_cspd | product | product_category | | s_product_category_gemstone_facets | s_product_category_legacy_facets | | | | | | |
| 65 | Y,N,N,N,Y | 5 | Active | Shay | Not Started | raw_layer | cmc_cspi_cs_plan | product | product_plan | | s_product_plan_gemstone_facets | s_product_plan_legacy_facets | l_group_product_network | | sal_product | | | |
| 66 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | cmc_itpp_plan_prfl | product | its_plan_code | | s_its_plan_code_gemstone_facets | s_its_plan_code_legacy_facets | | | | | | |
| 67 | N,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_lobd_line_bus | product | line_of_business | | s_line_of_business_gemstone_facets | s_line_of_business_legacy_facets | | | | | | |
| 68 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_pdbc | product | product_benefit | | s_product_benefit_gemstone_facets | s_product_benefit_legacy_facets | | | | | | |
| 69 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_pdbl | product | product_billing | | s_product_billing_gemstone_facets | s_product_billing_legacy_facets | | | | | | |
| 70 | Y,N,N,N,Y | 4 | Active | Shay | Not Started | raw_layer | cmc_pdds_prod_desc | product | product | h_product | s_product_gemstone_facets | s_product_legacy_facets | | | | | | |
| 71 | Y,N,N,N,Y | 5 | Active | Shay | Not Started | raw_vault | various | product | product | | | | | | | | bes_product | | |
| 72 | Y,N,N,N,Y | 3 | Active | Shay | Not Started | biz_vault | various | product | product | | | | | | | | | dim_product | |
| 73 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | cmc_pdpd_product | product | product_attributes | | s_product_attributes_gemstone_facets | s_product_attributes_legacy_facets | | | | | | |
| 74 | Y,N,N,N,N | 1 | Active | Shay | Not Started | raw_layer | cmc_pdpt | product | product_prefix | | s_product_prefix_gemstone_facets | s_product_prefix_legacy_facets | | | | | | |
| 75 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | cmc_plds_plan_desc | product | plan | | s_plan_gemstone_facets | s_plan_legacy_facets | | | | | | |
| 76 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_layer | r_classification | product | classification | | | | | | | ref_classification | | | |
| 77 | Y,N,N,N,Y | 1 | Active | Shay | Not Started | raw_vault | r_contract_pbp | product | contract_pbp | | | | | | | ref_contract_pbp | | | |
| 78 | N,Y,N,Y,N | 0 | ~~Canceled~~ | Sam | Not Started | raw_layer | cmc_mcti | provider | tax_id_information | | s_tax_id_information_gemstone_facets | s_tax_id_information_legacy_facets | | | | | | |
| 79 | N,Y,N,Y,N | 1 | Active | Sam | Not Started | raw_layer | cmc_mctn | provider | tax_id_description | | s_tax_id_description_gemstone_facets | s_tax_id_description_legacy_facets | | | | | | |
| 80 | N,Y,N,N,N | 3 | Active | Sam | Not Started | raw_layer | cmc_nwpr | provider | network_provider | | s_network_provider_gemstone_facets | s_network_provider_legacy_facets | l_network_participation | | | | | |
| 81 | N,Y,N,N,N | 5 | Active | Sam | Not Started | raw_vault | various | provider | provider_catalog | | | | | | | | bs_provider_catalog | | |
| 82 | N,Y,N,N,N | 3 | Active | Sam | Not Started | biz_vault | various | provider | provider_catalog | | | | | | | | | fact_provider_catalog |
| 83 | N,Y,N,N,N | 6 | Active | Sam | Delivered | raw_layer | cmc_prac | provider | practitioner | h_practitioner | s_practitioner_gemstone_facets | s_practitioner_legacy_facets | | | sal_practitioner_facets | | | |
| 84 | N,Y,N,Y,N | 1 | Active | Sam | Delivered | raw_layer | cmc_prad | provider | provider_address | | s_provider_address_gemstone_facets | s_provider_address_legacy_facets | | | | | | |
| 85 | N,Y,N,Y,N | 0 | ~~Canceled~~ | Sam | Not Started | raw_layer | cmc_prer | provider | provider_affiliation | | s_provider_affiliation_gemstone_facets | s_provider_affiliation_legacy_facets | | | | | | |
| 86 | N,Y,N,Y,N | 4 | Active | Sam | Delivered | raw_layer | cmc_prpr | provider | provider | h_provider | s_provider_gemstone_facets | s_provider_legacy_facets | | | | | | |
| 87 | N,Y,N,Y,N | 2 | Active | Sam | Not Started | raw_layer | cmc_prpr | provider | provider_practitioner | | | | l_provider_practitioner | | | | | |
| 88 | N,Y,N,Y,N | 5 | Active | Sam | Not Started | raw_vault | various | provider | provider | | | | | | | | bes_provider | | |
| 89 | N,Y,N,Y,N | 3 | Active | Sam | Not Started | biz_vault | various | provider | provider | | | | | | | | | dim_provider | |
| 90 | N,N,N,Y,N | 7 | Active | Sam | Not Started | raw_vault | various | provider | pcp_attribution | | | | l_member_attributed_pcp | | bes_pcp_attribution | | | |
| 91 | N,Y,N,N,N | 3 | Active | Sam | Not Started | biz_vault | various | provider | provider_1 | | | | | | | | | dim_provider_1 | |
| 92 | N,Y,N,N,N | 3 | Active | Sam | Not Started | biz_vault | various | provider | provider_2 | | | | | | | | | dim_provider_2 | |
| 93 | Y,N,N,N,N | 3 | Active | Shay | Not Started | biz_vault | various | member | member_1 | | | | | | | | | dim_member_1 | |
| 94 | Y,N,N,N,N | 3 | Active | Shay | Not Started | biz_vault | various | member | member_2 | | | | | | | | | dim_member_2 | |
| 95 | Y,N,N,N,N | 3 | Active | Shay | Not Started | biz_vault | various | member | member_3 | | | | | | | | | dim_member_3 | |

---

## Legend

- **Initiatives**: member_months, provider_catalog, network, pcp_attribution, product_key (Y=Yes, N=No)
- **Est. Days**: Estimated days for implementation (0 = Canceled)
- **Status**: Active = In plan; ~~Canceled~~ = Architecture decision changed, work not proceeding
- **Team**: Sam = Provider/Network/Claim domains; Shay = Member/Group/Product/Geography domains
- **Spec Status**: Not Started = Spec not written yet; Pending = Spec written but not delivered to engineers; Delivered = Spec delivered to engineers
- **Source**: raw_layer, raw_vault, biz_vault, dbt
- **BV Satellite**: Business Vault Satellite
- **BV**: Business Vault
- **Dim**: Dimension
- **Fact**: Fact table

## Notes on Canceled Stories

Stories marked as ~~Canceled~~ have 0 estimated days, indicating the architecture approach has changed and these will not be implemented as originally planned. These stories are retained for historical reference and to track if work moves to other stories (which would increase those estimates). When canceling stories or moving work, update the estimates accordingly to maintain accurate quarter planning.
