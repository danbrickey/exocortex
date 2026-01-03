# BCI Data Sources Discovery Session 5 - Meeting Notes

**Meeting:** BCI Data Sources Discovery Session 5
**Date:** October 16, 2025, 3:02 PM
**Attendees:** Dan Brickey, Sathish Dhanasekar, Rich Tallon, Vallimala Palaneeappan, Nilesh Trivedi, Kelly Good Clark, Lorraine Maldonado, Dale Fryer, Grant Ballard
**Purpose:** Determine BCBS Provider Directory integration approach for EDP

## Decisions Made

1. **BCBS Provider Directory not required for CMS 9115 compliance** - Rich Tallon confirmed the data is not needed for 9115 Provider Directory API but is important for other business-driven use cases and compliance regulations. High priority due to business needs.

2. **Rich Tallon leaning toward Foundation Model inclusion** - Recommended including BCBS Provider Directory in Foundation Model with plan code filtering capability to surface out-of-state claim information.

3. **Team will defer final decision pending scope clarity** - Vallimala Palaneeappan decided to take decision back internally to understand scope and Foundation Model usage before committing.

## Action Items

- **ACTION:** Send Foundation Model documentation to Dan Brickey | **OWNER:** Sathish Dhanasekar | **DUE:** Not specified
- **ACTION:** Clarify internally what Foundation Models will be used for and understand scope requirements | **OWNER:** Vallimala Palaneeappan | **DUE:** Not specified
- **ACTION:** Consult with Joe to determine if provider mastering is in scope | **OWNER:** Vallimala Palaneeappan | **DUE:** Not specified

## Open Questions

- **QUESTION:** Should BCBS Provider Directory load into Foundation Models or stay in raw/bronze layer? | **OWNER:** Vallimala Palaneeappan | **BY:** Not specified
- **QUESTION:** Is provider mastering in scope for EDP project? | **OWNER:** Joe (via Vallimala) | **BY:** Not specified
- **QUESTION:** What will BCI use Foundation Models for - analytics only or business rules/data pipelines? | **OWNER:** Dan Brickey/BCI team | **BY:** Not specified

## Key Discussion Points

- BCBS Provider Directory contains multi-plan FHIR data with complete resources (organization, location, practitioner). BCI receives data from Blue Cross Association after all plans submit.
- 20-30% of BCI claims involve out-of-state providers not in BCI network. Current Facets claim data is messy with incorrect NPIs. BCBS directory would provide cleaner data.
- BCBS Association assigns master IDs (practitioner, organization, location) that simplify provider matching across plans.

---

Generated with Claude Code

Co-Authored-By: Claude <noreply@anthropic.com>
