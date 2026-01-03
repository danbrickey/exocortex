# Amazon Q Prompt: Update Context Sync File

**Purpose**: Use this prompt inside Amazon Q (BCI environment) to generate an updated context sync file for export to Cursor.

---

## The Prompt

Copy and paste this into Amazon Q, then paste your current CONTEXT_SYNC.md content:

```
I need to update our workflow context sync file for export to an external design environment.

CURRENT CONTEXT SYNC FILE:
[Paste current CONTEXT_SYNC.md content here]

RECENT ACTIVITY TO ADD:
[Describe what you worked on this week]

Please update the context sync file with:
1. Updated dates
2. New activity entries
3. Any status changes
4. Lessons learned or observations
5. Updated next actions

IMPORTANT SECURITY REQUIREMENTS:
- Do NOT include any PHI or patient information
- Do NOT include hostnames, IPs, or infrastructure details
- Do NOT include credentials or secrets
- Do NOT include specific security configurations
- Generalize any business logic references
- Keep content safe for external sharing

Please output the complete updated CONTEXT_SYNC.md file.
```

---

## Quick Update Prompt (Minimal)

For a quick status update only:

```
Update this workflow status summary. Today's date is [DATE].

CURRENT STATUS:
[Paste the "Workflow Status" section]

UPDATES:
- [What changed]
- [What was completed]
- [Any new blockers]

Output just the updated status section, keeping it safe for external sharing (no PHI, no infrastructure details, no secrets).
```

---

## Weekly Sync Prompt (Comprehensive)

For a full weekly sync:

```
Generate a weekly sync update for our Data Vault workflow project.

This week I:
1. [Activity 1]
2. [Activity 2]
3. [Activity 3]

Prompt testing results:
- Spec generation: [worked well / needs refinement / not tested]
- dbt prompt: [worked well / needs refinement / not tested]
- Code evaluation: [worked well / needs refinement / not tested]

Issues encountered:
- [Issue 1]
- [Issue 2]

Create a context sync update that:
1. Summarizes progress
2. Notes what's working and what isn't
3. Lists next actions for both environments
4. Is SAFE FOR EXTERNAL SHARING (no PHI, no infrastructure, no secrets)

Format as markdown sections I can paste into CONTEXT_SYNC.md.
```

---

## After Running the Prompt

1. Review the output for any sensitive information
2. Copy the updated content
3. Save to CONTEXT_SYNC.md in BCI environment
4. Export via email to personal workstation
5. Update the copy in Cursor workspace

---

## Sync Frequency Recommendation

| Situation | Sync Frequency |
|-----------|----------------|
| Active development | Weekly |
| Testing phase | After each test cycle |
| Stable / maintenance | Bi-weekly or monthly |
| Major changes | Immediately after significant updates |
