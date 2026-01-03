---
title: "PCP Attribution Business Rules"
document_type: "business_rules"
business_domain: ["membership", "provider", "quality-measures"]
edp_layer: "curation"
technical_topics: ["pcp-attribution", "primary-care-provider", "effectivity-satellite", "data-vault-2.0", "claims-analysis"]
audience: ["executive-leadership", "business-operations", "analytics-engineering"]
status: "draft"
last_updated: "2025-10-28"
version: "1.0"
author: "Dan Brickey"
description: "Business rules for assigning members to Primary Care Providers based on claims utilization patterns over 18-month evaluation windows"
related_docs:
  - "../cob_profile/member_cob_profile_business_rules.md"
  - "../member_person/member_person_business_rules.md"
model_name: "ces_member_pcp_attribution"
legacy_source: "HDSVault.biz.PCPAttribution_02_* (12 staging tables + views)"
---

# PCP Attribution – Business Rules

## Executive Snapshot

The PCP Attribution system automatically assigns every Blue Cross of Idaho member to their most appropriate Primary Care Provider based on where they actually receive care. Instead of relying on who members say their doctor is, the system looks at actual medical claims over the past 18 months to find which clinic they visit most often. This assignment drives quality reporting for programs like HEDIS and Star Ratings, helps care managers know which providers are responsible for members, and ensures we can demonstrate network adequacy to regulators. The system recalculates these assignments periodically to keep pace with members' changing healthcare relationships.

## Operational Summary

- **Automated Assignment**: Members are automatically assigned to the clinic they visit most frequently based on actual visit claims, eliminating manual tracking and enrollment data discrepancies.
- **Quality Program Support**: Attribution assignments drive accountability for HEDIS measures, Star Ratings, and value-based care contracts by clearly identifying which provider is responsible for each member's quality outcomes.
- **Care Coordination**: Care managers, case managers, and utilization review teams use these assignments to direct outreach and coordinate care with the appropriate primary care practice.
- **Network Adequacy**: State and federal regulators require proof that members have access to primary care, and this system tracks which members have established relationships with PCPs versus those who need outreach.
- **Historical Tracking**: The system maintains a complete history of PCP assignments over time, allowing analysis of member movement between practices, provider turnover impact, and attribution stability trends.

## Key Business Rules

### Rule 1: Evaluation Window
**18-Month Lookback Period**: When calculating PCP attribution on any evaluation date, the system reviews all eligible claims from the previous 18 months to identify utilization patterns.

**Details**: If evaluating attribution on January 1st 2024, the system examines claims from July 1st 2022 through January 1st 2024. Evaluation dates are configurable (monthly, quarterly, or as needed) and defined in a reference file maintained by the data engineering team.

### Rule 2: Member Eligibility
**Primary Medical Coverage Required**: Only members with Blue Cross of Idaho as their **primary** medical insurance carrier during the evaluation window are eligible for attribution, except when they have no medical eligibility at all or when another insurance company is the primary payer.

**Details**: The member must have active medical eligibility for at least one day in the lookback window, must be enrolled in a medical product category (not dental-only or vision-only), and BCI must be the primary payer (not secondary or tertiary). Members with gaps in eligibility still qualify if they meet these criteria for any portion of the window.

### Rule 3: Provider Eligibility
**PCPs and Select Specialists**: Providers qualify for attribution in one of two ways—either they are formally designated as in-network Primary Care Providers with the PCP indicator flag, or they are eligible specialists from approved specialty categories like Family Practice, Internal Medicine, or Pediatrics, except when they represent institutional facility types like hospitals or government health entities.

**Details**: Designated PCPs always take priority over specialists when a provider qualifies both ways. Specialist eligibility includes individual practitioners only (entity type 'P'), excluding organizational or institutional provider types such as hospitals ('HOSP'), government health facilities ('GOVH'), or tribal public health entities ('TPLH').

### Rule 4: Clinic-Level Attribution
**Practice Groups, Not Individual Doctors**: Members are attributed to the **clinic or practice group** (identified by Tax ID) rather than to individual physicians, except in cases where a provider operates independently without group affiliation.

**Details**: When a provider is part of a group practice, the system uses the group's Tax ID number. All providers within that Tax ID are treated as a single clinic, and visits to any provider in the group count toward that clinic's total. A single representative provider from the clinic is selected for reporting purposes based on who has the highest visit counts within that group.

### Rule 5: Qualifying Visits
**Evaluation and Management Encounters Only**: Only face-to-face Evaluation and Management (E&M) visits count toward attribution, identified by procedures that either have CMS RVU values or are designated Behavioral Integrated Health Care codes, except when claims are denied or still pending payment.

**Details**: The system only counts paid (status '02') or fully adjudicated (status '91') claims. Within those claims, it identifies E&M visits by checking if the procedure code appears in the CMS RVU reference file or the BIHC code list. Lab work, imaging, procedures, and administrative services don't count. Line items marked as denied (place of service '20') are excluded.

### Rule 6: Visit Counting
**Unique Visits, Not Line Items**: Each unique combination of member, provider, and service date counts as one visit, regardless of how many procedure codes or claim lines are involved, except when the same date represents separate appointments with different providers.

**Details**: If a member sees Dr. Smith on March 15th and the claim shows three different E&M procedure codes, that counts as one visit. If two separate claims exist for the same member-provider-date combination, they are deduplicated to one visit. However, if the member also sees Dr. Jones on March 15th, that counts as a second visit (different provider).

### Rule 7: Attribution Ranking
**Frequency and Recency Win**: When a member visits multiple clinics, the system ranks them by PCP designation first, then visit count, then how recent the last visit was, then total RVU value, except when all factors tie (then Tax ID breaks the tie alphabetically).

**Details**: The ranking process first groups visits by clinic (Tax ID), selecting a representative provider for each clinic. Then clinics are ranked: PCPs beat specialists regardless of visit counts; among same designation (PCP or Specialist), the clinic with more visits wins; if visit counts tie, the most recent visit wins; if still tied, highest total RVU wins; finally, alphabetical Tax ID order resolves any remaining ties. Only the #1 ranked clinic receives the attribution.

### Rule 8: Effectivity Periods
**Time-Based Attribution History**: Attribution assignments are stored with start and end dates representing the period when that assignment was active, allowing point-in-time lookups and historical analysis, except the most current period which has an open end date of 9999-12-31.

**Details**: When attribution is calculated on an evaluation date, that date becomes the effective date. The end date is set to one day before the next evaluation date, or to 9999-12-31 if there is no subsequent evaluation yet. A flag marks the current active attribution (end date = 9999-12-31). This design allows joining to claims using "service date BETWEEN effective_date AND end_date" to see which PCP was attributed at the time of service.

### Rule 9: Members Without Visits
**Explicit Null Attribution**: Members who qualify for attribution eligibility but have zero E&M visits during the evaluation window receive an explicit record with null provider fields and zero visit counts, allowing complete population visibility and care gap identification.

**Details**: These records include all the same time periods and identifiers as members with attribution, but provider NPI, Tax ID, and PCP indicator are null, and visit counts and RVUs are zero. This design enables reporting on "members eligible but not utilizing primary care" for outreach campaigns and network adequacy calculations.

## Engineering Notes

- **Incremental Processing**: All models support incremental processing by evaluation date, only recalculating when new evaluation periods are added to the seed file, reducing compute costs for periodic refreshes.
- **Multi-Step Pipeline**: The attribution logic is split into four computed satellites: provider eligibility (determines which providers can be attributed), member eligibility (determines which members need attribution), visit aggregation (counts E&M encounters by member-provider), and final attribution (applies ranking logic and calculates effectivity periods).
- **COB Dependency**: Member eligibility requires the `ces_member_cob_profile` model to filter to primary medical coverage, creating a critical upstream dependency that must process before attribution runs.
- **Seed Files Required**: Six seed files provide reference data (evaluation dates, specialty codes, RVU values, BIHC codes, Idaho service area counties, and zip code geocoding), all maintained outside the pipeline by business stakeholders.
- **Tax ID Hierarchy**: Provider group affiliations are resolved through the `current_provider_affiliation` table, prioritizing group-level Tax IDs over individual provider Tax IDs using a coalesce pattern.
- **Deduplication Strategy**: Visit counting uses distinct concatenation of provider_bk, service_from_date, and member_bk to ensure true unique visit counts across claim headers, lines, and procedures.
- **Clustering and Performance**: All models are clustered on source and member_bk (or provider_bk) to optimize query performance when filtering by member or looking up current attribution.

## Important Terms

- **Evaluation Date**: A specific calendar date on which PCP attribution is calculated, typically occurring monthly or quarterly according to business needs.
- **Lookback Window**: The 18-month period of historical claims examined when calculating attribution, starting from 18 months before the evaluation date.
- **Effectivity Period**: The time span during which a particular PCP attribution is considered active, defined by an effective date (when it starts) and end date (when it ends or is replaced by a new attribution).
- **Tax ID (Clinic)**: A federal Employer Identification Number (EIN) shared by all providers within a practice group, used to aggregate visits at the clinic level rather than individual provider level.
- **E&M Visit (Evaluation and Management)**: A face-to-face encounter between a member and provider for assessment, treatment planning, or care management, identified by procedure codes with CMS RVU values or BIHC designation.
- **RVU (Relative Value Unit)**: A CMS measure of the resources required to perform a medical service, combining physician work, practice expense, and malpractice components into a single number.
- **BIHC Codes**: Behavioral Integrated Health Care procedure codes representing mental health and substance use services delivered in primary care settings, included in E&M visit definitions.
- **COB (Coordination of Benefits)**: The insurance industry process that determines which insurance company is primary, secondary, or tertiary when a member has coverage from multiple carriers.
- **PCP Indicator**: A flag in the provider network data that designates a provider as an in-network Primary Care Provider eligible to accept PCP assignments.
- **Constituent ID**: A master data management identifier linking the same person across multiple member records and data systems (also called Person ID or MDM ID).

## Example Scenario

Consider Sarah Johnson, a Blue Cross member enrolled in a medical plan with BCI as her primary insurance. Over the past 18 months, Sarah visited three different practices:

- **Canyon Family Clinic** (Tax ID 99-1111111): Sarah saw Dr. Martinez 6 times for annual checkup, sick visits, and chronic condition management. Dr. Martinez is designated as an in-network PCP. Her most recent visit was April 15th, generating 15.2 total RVUs.
- **Boise Cardiology Specialists** (Tax ID 99-2222222): Sarah saw Dr. Patel 4 times for heart condition monitoring. Dr. Patel is a cardiologist (specialist, not PCP-designated). Last visit March 10th, 12.8 total RVUs.
- **Urgent Care Express** (Tax ID 99-3333333): Sarah visited twice for urgent issues. Providers are family practice specialists but not designated as in-network PCPs. Last visit January 5th, 6.0 total RVUs.

When the system calculates attribution on May 1st:

1. **Provider Eligibility**: All three clinics qualify—Canyon Family Clinic as designated PCP, the other two as eligible specialists.
2. **Member Eligibility**: Sarah qualifies because she has medical eligibility and BCI is her primary insurance.
3. **Visit Aggregation**: System counts 6 visits to Canyon Family, 4 to Cardiology, 2 to Urgent Care.
4. **Ranking**: Canyon Family Clinic ranks #1 because it has the PCP designation (beats specialists regardless of visits).
5. **Result**: Sarah is attributed to Dr. Martinez at Canyon Family Clinic from May 1st through the next evaluation date.

If Canyon Family Clinic were not PCP-designated, Cardiology would still lose to Canyon Family because Canyon Family has more visits (6 vs 4), even though Sarah saw specialists at both locations.

## What to Watch

- **Evaluation Frequency Changes**: If the business changes from quarterly to monthly evaluation, the number of effectivity periods will triple, increasing storage and potentially creating member confusion if PCPs switch frequently due to normal visit variation.
- **Seed File Maintenance**: Six different reference files require regular updates from various business teams (network, claims operations, quality)—missed updates can cause provider exclusions or incorrect E&M identification, with no automated alerts for stale data.
- **Attribution Volatility**: Members with low visit counts (2-3 visits split between clinics) may "bounce" between PCPs at each evaluation cycle based on single recent visits, potentially causing care coordination issues and conflicting outreach from multiple clinics.
