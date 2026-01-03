# Local Context - Cursor Environment

**Purpose**: Environment-specific context that does NOT cross the security perimeter.
**Location**: This file stays in the Cursor environment only.

---

## ⚠️ THIS FILE DOES NOT SYNC

This file contains context specific to the Cursor design environment. It should NOT be copied to the BCI environment.

For shared context, use [CONTEXT_SYNC.md](CONTEXT_SYNC.md).

---

## Cursor Environment Details

| Aspect | Details |
|--------|---------|
| Primary use | Workflow design, prompt iteration |
| AI capabilities | Full Claude (Cursor), all tools available |
| Constraints | No access to BCI production data |

---

## Design Notes (Cursor-Specific)

### Prompt Iterations

| Prompt | Version | Notes |
|--------|---------|-------|
| Spec Generation | v1 | Initial design, untested |
| dbt Copilot | v1 | Initial design, untested |
| Code Evaluation | v1 | Initial design, untested |

### Ideas to Explore

- [ ] [Ideas specific to design work]

### Cursor-Specific Techniques

- [Notes about what works well in Cursor]
- [Patterns that may not translate to Amazon Q]

---

## Personal Notes

[Any notes that are helpful for design work but shouldn't be shared]

---

*This file is LOCAL ONLY - do not sync to BCI environment.*
