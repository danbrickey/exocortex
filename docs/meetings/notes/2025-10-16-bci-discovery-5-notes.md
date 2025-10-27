# BCI Discovery Session 5 - Provider Directory and Data Scope

**Meeting:** BCI Data Sources Discovery Session 5 (EDP Focus)
**Date:** October 16, 2025
**Purpose:** Clarify BCBSA provider directory scope, provider mastering requirements, and finalize remaining data source specifications

## Decisions Made

1. **BCBSA Provider Directory Scope** - Decision maker: Rich Tallon/Dan
   - Not required for 9115 provider directory API (BCI providers only for that)
   - Required for EDP use cases and out-of-state claims
   - Contains all Blue Cross Blue Shield plans including BCI providers (creates duplication)

2. **Provider Data in Foundation Models** - Decision maker: Team (with follow-up needed)
   - Leaning toward including BCBSA data in foundation model
   - Needed to attach provider information to 20-30% of claims from out-of-state providers
   - Will create duplication requiring provider mastering approach

3. **Provider Information Architecture** - Decision maker: Wally
   - Provider info on claims is limited (TIN, address, specialty)
   - Provider FM contains detailed demographics
   - Claim FM contains provider identifiers, lookup to Provider FM for details

## Action Items

- ACTION: Confirm provider mastering scope with Joe | OWNER: Wally | DUE: Next session
- ACTION: Clarify foundation model use cases and requirements for BCI | OWNER: Dan/Wally | DUE: Internal discussion
- ACTION: Determine if BCBSA provider data loads to FM or stays in bronze | OWNER: Wally/Satish | DUE: After mastering scope confirmed
- ACTION: Document how duplicate providers (BCI in both facets and BCBSA) will be handled | OWNER: Satish/Wally | DUE: TBD

## Open Questions

- QUESTION: Is provider mastering in scope for EDP implementation? | OWNER: Joe | BY: TBD
- QUESTION: How to handle overlapping providers between BCI network and BCBSA directory? | OWNER: Wally/Dan | BY: After mastering decision
- QUESTION: What are specific BCI use cases for foundation models? | OWNER: Dan | BY: Internal clarification needed
- QUESTION: Can provider filtering by plan code support both use cases? | OWNER: Rich/Satish | BY: TBD

## Key Discussion Points

- Out-of-state claims represent 20-30% of volume, currently use messy claim-attached provider data from inter-plan system with incorrect NPIs
- BCBSA directory provides termination notices for other plans' providers, required for compliance notifications to members
- Foundation Models designed as standalone entities separate from claims, requiring lookup relationship rather than embedded data
