# BCI Discovery Session 6 - Final Source Review and Technical Details

**Meeting:** BCI EDP/Interop Discovery Session 6
**Date:** October 23, 2025
**Purpose:** Review remaining TBD sources, finalize Salesforce ingestion approach, clarify Edge server data, sensitivity tagging, and tenant crosswalk implementation

## Decisions Made

1. **Salesforce Ingestion Scope** - Decision maker: Dan/Lindsey
   - Full Salesforce source ingestion required (not just 4 tables)
   - Timeline: Q1 2026
   - Current 4 tables (group assets, program codes) are pre-transformed, not raw Salesforce
   - Owned by Josh Matile's team

2. **Edge Server Data** - Decision maker: Dan
   - Source-only data, encounter submissions to CMS
   - Cadence: Weekly or biweekly ingestion (data only available Sept-April submission window)
   - No historical data needed (current year only)
   - Managed by Ryan George/Tamara Hess team

3. **Sensitivity Tagging Approach** - Decision maker: Dan/Satish/Lindsey
   - Column-level masking tags applied at bronze layer
   - Tags propagate to Foundation Models and Snowflake share
   - Separate solutioning meeting needed with Tina Day and data governance team
   - Must support tag changes over time (not one-time)

4. **Tenant/Group Crosswalk** - Decision maker: Dan
   - Three crosswalks needed: member, subscriber, group
   - Delivered via Snowflake share to Abacus
   - Separate technical discussion needed for implementation
   - Not one-time, must support ongoing updates

5. **GEVA Data** - Decision maker: Lindsey/Stacey
   - Deferred to 2026 (after January platform upgrade)
   - Will use API integration instead of file extracts
   - Current HDS extracts not suitable for migration

6. **Provider Web Billing** - Decision maker: Lindsey/Josh Matile
   - Source retiring in 2026, moving to Availity platform
   - Hold decision pending discussion with Josh Matile
   - May need interim solution if timing doesn't align

## Action Items

- ACTION: Get Salesforce ingestion timeline and requirements from Josh Matile | OWNER: Dan/Lorraine/Robert | DUE: Next week
- ACTION: Schedule solutioning meeting for sensitivity tagging with Tina Day | OWNER: Lorraine/Satish | DUE: Following week
- ACTION: Schedule technical discussion for tenant crosswalk implementation | OWNER: Lorraine/Satish | DUE: Following week
- ACTION: Provide sample sensitivity tagging data structure | OWNER: Dan | DUE: Before solutioning meeting
- ACTION: Identify Edge server SME (Ryan George or Tamara Hess) | OWNER: Robert Lindsay | DUE: TBD
- ACTION: Send meeting transcripts to BCI team | OWNER: Lorraine | DUE: End of day
- ACTION: Discuss GEVA roadmap with Stacey and Dom for API approach | OWNER: Lindsey/Robert | DUE: TBD
- ACTION: Clarify provider web billing EDP use case and Availity migration timeline | OWNER: Lindsey/Josh Matile | DUE: TBD

## Open Questions

- QUESTION: What is exact Salesforce ingestion cadence and format? | OWNER: Josh Matile | BY: Next week
- QUESTION: How will sensitivity tag changes propagate to downstream? | OWNER: Tina Day/Dan | BY: Solutioning session
- QUESTION: Will BCI users access Abacus data directly or only through EDP? | OWNER: Lindsey | BY: Impacts masking approach
- QUESTION: What is Edge server consumption process and data format? | OWNER: Ryan George/Tamara Hess | BY: TBD
- QUESTION: Is historical data needed for any CMS sources? | OWNER: Tamara Hess | BY: TBD

## Key Discussion Points

- Salesforce contains sales/marketing data including broker relationships, program enrollment, separate from current 4-table subset
- Edge server submissions follow CMS-dictated schedule (Sept-April, 4-5 submissions/year, blackout period May-Aug)
- Sensitivity tagging requires coordination with data governance labor-intensive review process, avoid duplication of effort
