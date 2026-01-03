# Meeting Notes: BCI-EDP Interop Discovery Session 6

**Date:** October 23, 2025
**Attendees:** Dan Brickey, Sathish Dhanasekar, Lorraine Maldonado, Kelly Good Clark, Linsey Smith, Rich Tallon, James Hicks, Daphne Park
**Purpose:** Finalize remaining data source details and resolve open questions for 2025/2026 EDP implementation

## Decisions Made

1. **Salesforce ingestion timeline** - Linsey Smith decided to ingest complete Salesforce source in Q1 2026 rather than partial tables in 2025
2. **Jiva source** - Team decided to table Jiva ingestion for 2026 engagement, after Jiva platform upgrade completes in January 2026
3. **Provider Directory (BPD)** - Sathish decided to ingest BPD as complete source since claims reference these providers; will be NDJson format from S3 buckets
4. **Column masking approach** - Dan Brickey and team decided sensitivity tags will be applied at bronze layer and propagate to foundation models for both Abacus and EDP environments

## Action Items

- **ACTION:** Get Salesforce road map timeline, load cadence, file format, and historical data volume | **OWNER:** Dan Brickey | **DUE:** Before next meeting
- **ACTION:** Identify correct SMEs for Episode, Condition, Suspect Code sources | **OWNER:** Robert Lindsay | **DUE:** This week
- **ACTION:** Send all discovery session transcripts to BCI team | **OWNER:** Lorraine Maldonado | **DUE:** End of day October 23
- **ACTION:** Add Kelly Good Clark to Episode/Condition/Suspect source email thread | **OWNER:** Lorraine Maldonado | **DUE:** October 23
- **ACTION:** Discuss provider web billing EDP use case with provider reporting team | **OWNER:** Dan Brickey and Linsey Smith | **DUE:** Before Josh Mattel meeting
- **ACTION:** Schedule solution meetings for tenant/group crosswalk and sensitivity tagging | **OWNER:** Lorraine Maldonado | **DUE:** Next week (after Wednesday)

## Open Questions

- **QUESTION:** What is Salesforce load cadence, file format, and does it require full historical load? | **OWNER:** Dan Brickey to ask Lindsey | **BY:** Before next session
- **QUESTION:** Who are the SMEs for Episode, Condition, Suspect Code data sources? | **OWNER:** Robert Lindsay | **BY:** This week
- **QUESTION:** What are cadence, file type, and historical data requirements for CMS Edge Server? | **OWNER:** Tamara Hess's team or Ryan George's team via Robert Lindsay | **BY:** TBD
- **QUESTION:** What are format, frequency, volume, cadence for EMR data (Dave Johnstone's process)? | **OWNER:** Robert Lindsay to coordinate | **BY:** TBD
- **QUESTION:** Should provider web billing be ingested given Availity platform migration plans? | **OWNER:** Josh Mattel via Linsey Smith and Dan Brickey | **BY:** TBD

## Key Discussion Points

- Completed detailed discovery for 90% of sources; remaining items require specific SME contacts rather than full discovery sessions
- Data governance handshaking for sensitivity tagging and tenant/group crosswalks requires dedicated solution meeting to ensure no duplicate effort
- Veradigm CCD/ADT data loads multiple times daily via object replication; confirmed HL7v3 for CCD, HL7v2 for ADT

---

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
