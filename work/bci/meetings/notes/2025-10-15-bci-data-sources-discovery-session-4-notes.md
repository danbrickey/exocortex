# BCI Data Sources Discovery Session 4 - Meeting Notes

**Meeting:** BCI Data Sources Discovery Session 4
**Date:** October 15, 2025, 3:10 PM
**Attendees:** Lorraine Maldonado, Sathish Dhanasekar, Dan Brickey, Kelly Good Clark, Dominic Desimini, Nilesh Trivedi, Sagar Shah, Vallimala Palaneeappan, Dale Fryer
**Purpose:** Review remaining BCI data sources for EDP/interop integration

## Decisions Made

1. **Custom payment tables (gemstone/facets)** - Dan Brickey decided to keep BCI custom payment tables in Bronze layer only, not Silver/Gold foundation models. These tables track negative claim transactions for payment balancing that cannot be recreated reliably from facets data alone.

2. **Vision claims procedure codes** - Team decided to ingest vision procedure codes as reference data from BCI. Dan will investigate whether VSP uses standard CPT codes or custom procedure codes before finalizing approach.

3. **Edge data scope** - Team decided Edge data is source-only for now (not needed for interop 2025). Tamara Hess will provide details on consumption requirements at next meeting.

4. **Salesforce data** - Dan decided current four tables (program groups, program lists, group program eligibility) are sufficient for now via flat file replication. Future direct Salesforce integration deferred pending Lindsay's roadmap confirmation.

## Action Items

- **ACTION:** Investigate VSP vision claims to determine if they use standard CPT codes or custom procedure codes | **OWNER:** Dan Brickey | **DUE:** Before next meeting
- **ACTION:** Confirm Salesforce roadmap and future data requirements with Lindsay (PDP Program Manager) | **OWNER:** Dan Brickey | **DUE:** October 16, 2025
- **ACTION:** Invite Tamara Hess to tomorrow's meeting for Edge, CMS files (MO2/MO4/TRR), and EMR data discussion | **OWNER:** Dale Fryer/Lorraine Maldonado | **DUE:** October 16, 2025
- **ACTION:** Ensure Rich Tallon and Suresh Vuppu attend tomorrow's meeting for BC BSA provider directory discussion | **OWNER:** Dale Fryer/Lorraine Maldonado | **DUE:** October 16, 2025
- **ACTION:** Provide landing bucket information for TRR replication | **OWNER:** Kelly Good Clark | **DUE:** October 16, 2025
- **ACTION:** Confirm if Hicken/MBI crosswalk is needed beyond what exists in facets MEMD tables | **OWNER:** Tamara Hess (via tomorrow's meeting) | **DUE:** October 16, 2025
- **ACTION:** Send updated meeting invite for tomorrow with corrections and missing attendees | **OWNER:** Lorraine Maldonado | **DUE:** October 15, 2025 EOD

## Open Questions

- **QUESTION:** Does BCI need MO2/MO4 in foundation models or source-only? | **OWNER:** Team with Tamara Hess | **BY:** October 16, 2025
- **QUESTION:** What EMR clinical data sources exist beyond Veradigm (mentioned: LabCorp, Quest Diagnostics)? | **OWNER:** Tamara Hess team | **BY:** October 16, 2025
- **QUESTION:** Does BC BSA provider directory need to be ingested for interop or just for analytics? Does BCI publish this to members via Fire APIs? | **OWNER:** Rich Tallon | **BY:** October 16, 2025
- **QUESTION:** What is the exact format for retro chart review supplemental claims (CCD/ADT) - confirm HL7 V2 vs other formats | **OWNER:** Kelly Good Clark | **BY:** October 16, 2025
- **QUESTION:** Can ICD/CPT reference codes be sourced from public CMS data instead of BCI, except for vision custom codes? | **OWNER:** Product team | **BY:** TBD

## Key Discussion Points

- **Custom payment tables context:** BCI maintains custom tables with negative claim transactions because facets doesn't create void claims. These tables are system of record for accounting, EOB generation, and payment integrity. Historical data matching has failed when trying to recreate from facets, so direct ingestion is required.
- **Salesforce program tracking:** Four tables track group buy-up programs (smoking cessation, diabetes prevention, weight loss). Data flows to Geva for clinical progress tracking and links to HE scores. Future expansion may require direct Salesforce API access.
- **Clinical data complexity:** Multiple clinical data sources (Veradigm CCD/ADT, EMR data, LabCorp, Quest) with varying formats. Not needed for 2025 interop but mandatory for 2026 use case 0057.

---

Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
