# Amazon Q Prompt: Security Audit for CONTEXT_SYNC.md

**Purpose**: Run this audit BEFORE exporting CONTEXT_SYNC.md from the BCI environment.

---

## The Audit Prompt

Copy and paste this into Amazon Q, then paste your CONTEXT_SYNC.md content:

```
Please audit this context sync file for sensitive information before I export it from our private network.

CONTEXT_SYNC.md CONTENT:
[Paste the file content here]

Check for and flag ANY of the following:

## MUST NOT CONTAIN:

### Protected Health Information (PHI)
- Patient names, IDs, or identifiers
- Member information
- Claim details
- Any healthcare-specific PII

### Infrastructure Details
- Internal hostnames or FQDNs
- IP addresses (internal or external)
- Server names
- Database connection strings
- AWS resource identifiers (ARNs, account IDs)
- Snowflake account identifiers

### Security Information
- Credentials, passwords, tokens, API keys
- Security configurations
- Firewall rules
- Access control details
- Vulnerability information

### Proprietary Business Information
- Specific business logic that's competitive advantage
- Contract terms
- Pricing information
- Non-public financial data

### Internal References
- Full names of employees (first name only is usually OK)
- Internal project codenames (if sensitive)
- Specific vendor contract details

## OUTPUT FORMAT:

1. **SAFE**: List items that are clearly safe to export
2. **FLAGGED**: List any items that need review, with the specific concern
3. **BLOCKED**: List any items that MUST be removed before export
4. **RECOMMENDATION**: Overall assessment (SAFE TO EXPORT / NEEDS CLEANUP / DO NOT EXPORT)

If you find issues, suggest sanitized alternatives where possible.
```

---

## Quick Audit (Minimal)

For a fast check:

```
Scan this text for: PHI, hostnames, IPs, credentials, AWS/Snowflake identifiers, or proprietary business details.

[Paste content]

Reply with: SAFE, NEEDS REVIEW (list concerns), or DO NOT EXPORT (list blockers).
```

---

## Common Patterns to Watch For

| Pattern | Risk | How to Sanitize |
|---------|------|-----------------|
| `*.bcidaho.com` | Internal hostname | Remove or use `[internal-system]` |
| `10.x.x.x` or `172.x.x.x` | Internal IP | Remove |
| `arn:aws:...` | AWS resource | Remove |
| `xxx.snowflakecomputing.com` | Snowflake account | Remove |
| Full names | Privacy | Use first name or initials |
| Specific table names with PHI | Data exposure | Generalize to `[member-table]` |

---

## Audit Checklist (Manual Backup)

Before exporting, manually verify:

- [ ] No PHI or member/patient references
- [ ] No internal hostnames (*.bcidaho.com, etc.)
- [ ] No IP addresses
- [ ] No credentials or tokens
- [ ] No AWS/Snowflake account identifiers
- [ ] No specific security configurations
- [ ] Employee names limited to first names or roles
- [ ] Business logic is generalized, not specific
- [ ] No vendor contract specifics

---

## If Issues Are Found

1. **Identify** the specific sensitive content
2. **Decide**: Remove entirely, or sanitize?
3. **Sanitize options**:
   - Replace with placeholder: `[internal-system]`, `[team-member]`
   - Generalize: "the member table" instead of specific table name
   - Remove the section entirely
4. **Re-audit** after changes
5. **Document** in LOCAL_CONTEXT.md what was removed (so you remember)

---

## Export Workflow

```
┌─────────────────┐
│ Update          │
│ CONTEXT_SYNC.md │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Run Security    │
│ Audit Prompt    │
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐ ┌───────────┐
│ SAFE  │ │ FLAGGED   │
└───┬───┘ └─────┬─────┘
    │           │
    │           ▼
    │     ┌───────────┐
    │     │ Sanitize  │
    │     │ & Re-audit│
    │     └─────┬─────┘
    │           │
    ▼           ▼
┌─────────────────┐
│ Export via      │
│ Email           │
└─────────────────┘
```
