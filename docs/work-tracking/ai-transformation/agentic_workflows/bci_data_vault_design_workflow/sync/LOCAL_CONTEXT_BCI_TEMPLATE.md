# Local Context - BCI Environment (TEMPLATE)

**Purpose**: Environment-specific context that does NOT cross the security perimeter.
**Instructions**: Copy this template to your BCI environment and rename to `LOCAL_CONTEXT.md`

---

## ⚠️ THIS FILE DOES NOT SYNC

This file contains BCI-specific context that should NOT leave the private network. It can include:
- Internal system names and configurations
- Team-specific details
- Implementation notes with specific data references
- Anything that shouldn't be emailed externally

For shared context, use `CONTEXT_SYNC.md`.

---

## BCI Environment Details

| Aspect | Details |
|--------|---------|
| Primary use | Implementation, testing, production |
| AI capabilities | Amazon Q (Claude via AWS), dbt Copilot |
| Constraints | Limited export, security perimeter |

---

## Internal References

### Systems (OK to document here, NOT in sync file)

| System | Notes |
|--------|-------|
| [Internal system name] | [Details] |

### Team Contacts

| Role | Person | Notes |
|------|--------|-------|
| [Role] | [Name] | [Notes] |

---

## Implementation Notes

### Current Sprint/Work Items

| Item | Status | Notes |
|------|--------|-------|
| | | |

### Environment-Specific Issues

- [Issues specific to BCI infrastructure]
- [Workarounds needed]

---

## Sensitive Patterns

[Document any patterns that reference internal systems or data structures that shouldn't leave the network]

---

*This file is LOCAL ONLY - do not export from BCI environment.*
