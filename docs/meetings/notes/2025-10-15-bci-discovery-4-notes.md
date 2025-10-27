# BCI Discovery Session 4 - Custom Claims Tables and Data Sources

**Meeting:** BCI Data Sources Discovery Session 4
**Date:** October 15, 2025
**Purpose:** Deep dive into custom claims payment tables, retro chart review data, clinical data sources, and additional reference data requirements

## Decisions Made

1. **Custom Payment Tables (BCI Maintenance Table)** - Decision maker: Dan/Satish
   - Keep in bronze layer as source-only data
   - Not promoted to Foundation Models for EDP/Interop use cases
   - Used for payment integrity and accounting reconciliation only

2. **EOB Generation Approach** - Decision maker: Satish
   - EOB can be generated from Facets claim data directly
   - Custom payment tables not required for EOB generation
   - Custom tables needed only for payment balancing use cases

3. **Vision Claims Procedure Codes** - Decision maker: Team consensus
   - Need to ingest custom V-codes from VSP vision claims
   - Codes embedded in vision claim files, will scrape from claims
   - Not standard CPT codes, separate ingestion required

4. **Episodes/Parallel Intelligence/Advance Med Sources** - Decision maker: Team
   - Already ingesting for condition and suspect condition data
   - No additional data sets needed beyond current scope for 2025

## Action Items

- ACTION: Confirm EMR data sources and formats with Tamara Hess team | OWNER: Robert Lindsay | DUE: Following session
- ACTION: Confirm CMS data sources (MOR, TRR, MO2, MO4) ingestion status | OWNER: Wally/Team | DUE: TBD
- ACTION: Provide deep dive on Vision claims procedure code requirements | OWNER: Dan | DUE: TBD
- ACTION: Confirm if retro chart review sources (CCD, ADT) formats have changed | OWNER: Dale/Brett Barton | DUE: TBD
- ACTION: Provide details on clinical data hub sources | OWNER: Dominic/Kelly | DUE: TBD

## Open Questions

- QUESTION: Can facets-based claim transformation match accounting penny-for-penny? | OWNER: Dan | BY: As needed
- QUESTION: Do we need HICN/MBI crosswalk or is Facets MEMD table sufficient? | OWNER: Tamara Hess | BY: Next session
- QUESTION: What EMR sources beyond Veradigm (LabCorp, Quest, others)? | OWNER: Robert Lindsay/Brett Barton | BY: TBD
- QUESTION: Are standard ICD/CPT codes sufficient or custom codes needed? | OWNER: Dan | BY: When feature confirmed

## Key Discussion Points

- Custom payment table creates negative transaction versions of claims with adjusted pay dates for financial accuracy, critical for payment integrity but not for clinical/interop use cases
- Facets claim adjustments use suffix increments (00, 01, 02) with adjusted-from/adjusted-to links, custom table simplifies with current/prior indicators
- TRR already being replicated to Abacus landing bucket, team to verify if already in use
