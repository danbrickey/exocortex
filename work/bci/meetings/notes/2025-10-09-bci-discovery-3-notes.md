# BCI Discovery Session 3 - Data Sources (Interop and EDP)

**Meeting:** BCI Data Sources Discovery Session 3
**Date:** October 9, 2025
**Purpose:** Discovery of data sources for EDP and Interop, clarification of CMS mandate scope (9115 and 0057), historical data availability and ingestion strategies

## Decisions Made

1. **Broker Data Scope** - Decision maker: Team consensus
   - Treat broker data as separate domain
   - Prioritize for 2026, not 2025

2. **Membership Crosswalk Handling** - Decision maker: Dan B
   - Crosswalk data will remain in bronze layer only
   - Will not be promoted to silver member FM models

3. **Pharmacy Fulfilled Rx** - Decision maker: Team consensus
   - Not a required source for 9115 or EDP
   - Excluded from current scope

4. **Dental Claims Timeline** - Decision maker: Team consensus
   - Exist in facets but scoped for 2026, not 2025

## Action Items

- ACTION: Confirm if Formulary data is needed for CMS compliance and establish data availability | OWNER: Dominic/Dan B | DUE: TBD
- ACTION: Assess impact of unavailable historical formulary data | OWNER: Dan B | DUE: TBD
- ACTION: Evaluate completeness and compliance relevance of Carelon RX claims history | OWNER: Rich T | DUE: TBD
- ACTION: Confirm if CVS Caremark Rx Claims required for compliance | OWNER: Rich T | DUE: TBD
- ACTION: Share CVS Caremark Rx Claims mapping | OWNER: Dan B | DUE: TBD
- ACTION: Confirm format of BCI Simplr files to be sent to Abacus | OWNER: Kelly | DUE: TBD
- ACTION: Confirm expectations and delivery method for sensitivity tags | OWNER: Dan B | DUE: TBD
- ACTION: Confirm if sensitivity tag data is accessible directly from Snowflake tables | OWNER: Valli P | DUE: TBD
- ACTION: Provide mappings and descriptions for FM model standardization (Facets RDM Tables) | OWNER: Dan B | DUE: TBD

## Open Questions

- QUESTION: Can formulary data be obtained in standard format for CMS compliance? | OWNER: Dominic/Dan B | BY: TBD
- QUESTION: What is compliance impact if historical formulary data unavailable? | OWNER: Dan B | BY: TBD
- QUESTION: What data format/structure for Simplr provider credentialing files? | OWNER: Kelly | BY: TBD

## Key Discussion Points

- Gemstone data starts 2022, legacy data back to 2016 requiring archival ingestion with crosswalk capability
- RX Claims: Carelon available from 2022, CVS/Caremark in on-prem databases potentially back to 2010 requiring different connector
- Simplr provider data delivered via Parquet in S3, no historical data needed, links to Facets via NPI
