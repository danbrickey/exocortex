---
title: "Member Person Business Rules"
document_type: "business_rules"
business_domain: ["membership", "person"]
edp_layer: "business_vault"
technical_topics: ["computed-satellite", "data-vault-2.0", "member-identification", "external-id-mapping"]
audience: ["executive-leadership", "business-operations", "analytics-engineering"]
status: "draft"
last_updated: "2025-10-28"
version: "1.0"
author: "Dan Brickey"
description: "Defines how member records are linked to external person identifiers and which members qualify for cross-system identification."
related_docs:
  - "docs/architecture/edp_platform_architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "bv_s_member_person"
legacy_source: "HDSVault.biz.v_FacetsMemberUMI_current"
---

# Member Person – Business Rules

## Executive Snapshot

This logic connects health plan members to their external person identifiers used across our enterprise systems. It ensures we can accurately track member data across multiple platforms while filtering out test accounts and maintaining data quality. This capability enables accurate member identification for care coordination, claims processing, and customer service operations.

## Operational Summary

- **Cross-System Member Lookup**: Enables staff to find the same person across different systems using either member ID or external person ID.
- **Data Quality Protection**: Automatically excludes proxy/test subscriber accounts that should not appear in production reporting or analytics.
- **Valid Member Enforcement**: Only processes members who have valid subscriber and group relationships, preventing orphaned or incomplete records.
- **External ID Validation**: Only includes members with external reference member IDs (EXRM type), ensuring we can link to other enterprise systems.
- **Historical Tracking**: Maintains complete history of member demographic changes and ID assignments over time.

## Key Business Rules

- **External Person ID Linking**: When a member record exists in our claims system, then link it to the external person identifier (EXRM type) if one exists, except for members without external IDs who receive a null person_id.

- **Proxy Subscriber Exclusion**: When a subscriber identifier starts with "PROXY", then exclude that member from the crosswalk, except none (this is an absolute filter for test accounts).

- **Valid Group Requirement**: When processing a member record, then that member must belong to a valid, active group, except members without group relationships are excluded entirely.

- **Valid Subscriber Requirement**: When processing a member record, then that member must have a valid, active subscriber record, except members without subscriber relationships are excluded entirely.

- **Source Consistency Validation**: When joining member, subscriber, and group records, then all records must share the same source system identifier, except none (cross-source joins are not permitted).

- **Current Records Only**: When building the lookup table, then use only the most recent version of each member's data, except historical versions are preserved in the business vault satellite.

- **External ID Type Restriction**: When linking to external person IDs, then only use person_id_type = 'EXRM', except other ID types (internal references, temporary IDs) are excluded.

- **Standardized Source Codes**: When identifying the source system, then use the standardized source codes from the raw vault (GEM, FCT), except do not recreate legacy source_id to source code mappings.

## Engineering Notes

- **Join Strategy**: Uses LEFT JOIN for person (some members may not have external IDs), INNER JOIN for subscriber and group (required relationships).
- **Source Consistency**: All joins enforce matching source codes between entities to prevent cross-source data contamination.
- **Change Detection**: Business vault satellite uses hashdiff on all payload columns to track demographic and relationship changes.
- **Incremental Loading**: Business vault satellite uses incremental materialization with member_hk as unique key for performance.
- **Lookup Table Current State**: Crosswalk table queries business vault for current records only using max(effective_from) pattern.
- **Hash Key Strategy**: Uses source and member_bk to generate member_hk (ties to h_member hub); lookup table generates composite surrogate key from source + member_bk.
- **Null Handling**: member_suffix coalesced to empty string in lookup table to enable reliable composite key matching.

## Important Terms

- **Member**: A person covered under a health insurance policy, identified by member_bk.
- **Subscriber**: The primary policyholder responsible for the insurance account, identified by subscriber_identifier.
- **Group**: The employer or organization sponsoring the insurance coverage, identified by group_id.
- **Person ID**: The external identifier (person_id) used to link this member to enterprise systems outside the claims platform.
- **EXRM ID Type**: Stands for "External Reference Member" - the specific type of person ID used for cross-system member linking.
- **Proxy Subscriber**: Test or placeholder subscriber accounts that start with "PROXY" and should be excluded from production data.
- **Source**: The originating claims system - either GEM (Gemstone Facets) or FCT (Legacy Facets).
- **Business Vault Computed Satellite**: A data vault table that combines data from multiple raw vault sources and applies business rules, tracking full history of changes.
- **Crosswalk Table**: A lookup table that maps member identifiers to person identifiers for the current point in time.
- **Business Key (bk)**: The natural identifier from the source system that uniquely identifies an entity.

## Example Scenario

**Situation**: A customer service representative receives a call from John Smith who has a question about his claim.

**How the rules work**:

1. The rep searches using member_bk = "M123456" and source = "GEM"
2. The crosswalk lookup finds: group_id = "ABC-CORP", subscriber_identifier = "SUB-789", member_suffix = "01"
3. **External ID Linking** rule: System returns person_id = "EXRM-999888" (the EXRM type external identifier)
4. **Proxy Exclusion** rule: If subscriber_identifier was "PROXY-TEST-001", this member would not appear in results
5. **Valid Group Requirement**: The member has group_bk = "GRP-ABC", so passes validation
6. **Valid Subscriber Requirement**: The member has subscriber_bk = "SUB-789-BK", so passes validation
7. The rep can now use person_id "EXRM-999888" to look up John's records in care management, provider directory, and other enterprise systems

**What happens next**: If John's group changes employment groups next week, a new record will be added to the business vault satellite with the updated group_id, but the historical version remains available for claims processed during his time at the previous group.

## What to Watch

- **Missing External IDs**: Some members may not have person_id values if they lack EXRM type external identifiers. Monitor the percentage of members without person_id to identify integration issues with the external identity system.

- **Source Consistency**: The source code matching enforced in joins assumes raw vault correctly standardizes GEM/FCT values. If source values are inconsistent or null, members will be excluded from the crosswalk.

- **Proxy Subscriber Detection**: The "PROXY%" pattern match assumes all test accounts follow this naming convention. Test accounts with different naming patterns will not be filtered and could contaminate production reporting.

- **Group/Subscriber Relationship Changes**: When members change groups or subscribers, new records are created in the business vault satellite. Ensure downstream reporting uses the lookup table (current state) unless historical analysis is explicitly required.
