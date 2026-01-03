---
name: business-doc-evaluator
description: Evaluates business documents (meeting notes, status reports, executive briefs, proposals, PRDs, technical docs, post-mortems, SOPs) against 9 quality principles to identify specific problems and provide actionable fixes. Use when the user explicitly asks to "evaluate", "review", or "assess" document quality, when something "feels off" about a document, or when checking if a document is ready to ship.
---

# Business Document Quality Evaluator

Evaluates any business document against 9 principles of quality business writing, identifying specific failures and providing actionable fixes.

## When to Use This Skill

**Trigger this skill when the user:**
- Explicitly asks to "evaluate", "review", or "assess" a document's quality
- Says something "feels off" or "isn't working" about a document
- Asks if a document is "ready to ship/send/share"
- Asks for "feedback on" a business document
- Mentions concerns about "AI-generated document" quality
- Asks "what's wrong with this" or "why isn't this document effective"

**Do NOT trigger this skill for:**
- Simple editing requests ("fix typos", "make this shorter", "rewrite this section")
- Creative writing (fiction, poetry, marketing copy)
- Code review (use different skills)
- Casual communication (Slack messages, informal emails)
- Documents still in active drafting (not ready for evaluation)
- Heavily domain-specific documents where you lack context (legal contracts, medical reports)

## How This Works

This skill evaluates documents against 9 core principles (see references/principles.md for details). Each principle addresses a common failure mode in business writing. The evaluation produces:

1. **Principle-by-principle assessment** - Which principles are violated and how
2. **Priority ranking** - Most critical issues first
3. **Specific fixes** - Not "make it better" but "do exactly this"
4. **Impact analysis** - Why each issue matters

## Evaluation Process

### Step 1: Document Length Check

Before starting evaluation, check document length:
- **Short documents** (<1,000 words or <3 pages): Full evaluation appropriate
- **Medium documents** (1,000-2,500 words or 3-8 pages): Full evaluation appropriate
- **Long documents** (>2,500 words or >8 pages): Use streamlined approach (see guidelines below)

### Step 2: Identify Document Type

Determine what type of document this is:
- Meeting notes
- Status report
- Executive brief / decision memo
- Project proposal
- PRD (Product Requirements Document)
- Technical documentation
- Post-mortem / incident report
- SOP (Standard Operating Procedure)
- Other business document

**If the document type isn't obvious:** Ask the user to clarify.

**If the document serves multiple purposes** (e.g., "meeting notes with status update"):
1. Identify the primary purpose (what is the document mostly doing?)
2. Apply the failure modes for that primary type
3. Note in evaluation: "This document combines [type 1] and [type 2], evaluated primarily as [type 1]"

### Step 3: Load Principles

**CRITICAL: You MUST read the principles file before evaluation.**

Use the view tool to read `/mnt/skills/user/business-doc-evaluator/references/principles.md` to load:
- All 9 principles with their tests
- Document-specific failure modes
- Prioritization hierarchy

### Step 4: Quick Scan for Fundamental Issues

Before doing full evaluation, check for fundamental failures:

**Principle 1 (Purpose) Check:**
- Can you state in one sentence what this document is supposed to make someone do?
- Is there a clear decision or action requested?

**Principle 6 (Input Quality) Check:**
- Does the document contain specific facts, numbers, decisions, and examples?
- Or does it contain vague claims, estimated numbers, or inferred information?

**If either Principle 1 or Principle 6 has a fundamental failure:**

Consider stopping evaluation and returning:
```
OVERALL VERDICT: REJECT - Fundamental Issue

PRIMARY PROBLEM: [Principle 1 or 6 failure description]

EVIDENCE: [Specific examples from document]

RECOMMENDATION: Fix this core issue before detailed evaluation. The other principles don't matter until this is resolved.

NEXT STEPS: [What specifically needs to be gathered or clarified]
```

Only proceed with full evaluation if these two principles are at least PARTIAL (not complete FAIL).

### Step 5: Evaluate Against All Principles

For each of the 9 principles, assess:
- **PASS**: Principle is satisfied
- **FAIL**: Principle is violated
- **PARTIAL**: Principle is partially satisfied with room for improvement
- **N/A**: Cannot assess (lack context, e.g., Principle 9 without workflow knowledge)

For each FAIL or PARTIAL, document:
- Which principle is violated
- Specific evidence from the document
- Impact of the violation
- Specific fix with exact location in document

### Step 6: Structure Output

Use the output format specified in the "Output Format" section below.

## Output Format

### Standard Evaluation Output

```
DOCUMENT TYPE: [meeting notes / status report / etc]

OVERALL VERDICT: [SHIP / REVISE / REJECT]
- SHIP: Document is ready to use
- REVISE: Document has fixable issues that should be addressed
- REJECT: Document has fundamental problems (Principle 1 or 6 failures, wrong type, missing critical information)

DOCUMENT-SPECIFIC CHECKS:
[For the specific document type, check against known failure modes from principles.md]
Example for meeting notes:
✓ PASS: Decisions documented with decision-maker
✓ PASS: Action items have owner and deadline
✓ PASS: Date and attendees listed
✗ FAIL: No clear next steps identified

PRINCIPLE EVALUATION:

Principle 1 (Purpose): [PASS / PARTIAL / FAIL]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 2 (Structure): [PASS / PARTIAL / FAIL]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 3 (Constraints): [PASS / PARTIAL / FAIL]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 4 (Self-Evaluation): [PASS / PARTIAL / FAIL]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 5 (Failure Modes): [PASS / PARTIAL / FAIL]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 6 (Input Quality): [PASS / PARTIAL / FAIL]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 7 (Voice): [PASS / PARTIAL / FAIL / N/A]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 8 (Iteration): [PASS / PARTIAL / FAIL / N/A]
[If PARTIAL or FAIL: Specific problem, evidence, fix]

Principle 9 (Workflows): [PASS / PARTIAL / FAIL / N/A]
[If PARTIAL or FAIL: Specific problem, evidence, fix]
[If N/A: "Cannot assess without organizational workflow context"]

PRIORITY FIXES:
[Maximum 5 fixes, prioritized using the hierarchy from principles.md]

1. [Highest priority - typically Tier 1: Principle 1 or 6]
   Problem: [Specific issue]
   Location: [Where in document]
   Fix: [Exact action to take]
   Why this matters: [Impact on document effectiveness]

2. [Second priority - typically Tier 2: Principle 3 or 2]
   Problem: [Specific issue]
   Location: [Where in document]
   Fix: [Exact action to take]
   Why this matters: [Impact]

3. [Third priority]
   [Same format]

[Continue for up to 5 total fixes - don't overwhelm with everything]

WHAT WENT WELL: [Include only if OVERALL VERDICT is SHIP or REVISE with minor issues]
[2-3 specific things the document does right - be genuine, not patronizing]
```

### Streamlined Output for Long Documents

For documents >2,500 words or >8 pages, use this streamlined approach:

```
DOCUMENT TYPE: [type]
DOCUMENT LENGTH: [word count / page count]

OVERALL VERDICT: [SHIP / REVISE / REJECT]

QUICK SCAN RESULTS:
- Principle 1 (Purpose): [assessment with 1 sentence explanation]
- Principle 6 (Input Quality): [assessment with 1 sentence explanation]
- Principle 3 (Constraints): [assessment with 1 sentence explanation]

TOP 3 PRIORITY FIXES:
[Only the 3 most critical issues with specific locations and fixes]

RECOMMENDATION:
[If document needs substantial work: "Recommend addressing priority fixes above, then requesting re-evaluation of specific sections rather than entire document."]
```

## Evaluation Guidelines

**Be specific, not generic:**
- Bad: "This document needs more detail"
- Good: "Section 2 lacks metrics. Add: number of users affected, duration of impact, revenue loss"

**Locate problems precisely:**
- Bad: "The structure is unclear"
- Good: "Paragraphs 3-5 discuss solution before stating the problem. Move problem statement to paragraph 1"

**Give actionable fixes:**
- Bad: "Make this more concise"
- Good: "Cut paragraphs 4 and 7 (background context). Keep only paragraphs 1-3 and 8-10 (problem and solution)"

**Prioritize using the tier system:**
- Tier 1 issues (Principles 1, 6) always come first
- Within same tier, prioritize by impact on document function
- Maximum 5 fixes in output - more than that is overwhelming
- For documents with 10+ issues, group related fixes

**Be honest but constructive:**
- Call out real problems directly - "This document has no clear purpose" not "The purpose could be clearer"
- Acknowledge what works well (when verdict is SHIP or REVISE with minor issues)
- Remember the goal is improvement, not criticism
- Avoid hedge language in evaluation ("somewhat", "could be", "might benefit from")

**Handle subjective principles carefully:**
- Principle 7 (Voice): Look for generic AI phrases rather than judging authenticity
- Principle 9 (Workflows): Mark N/A if you lack organizational context
- When uncertain, explain your reasoning: "This appears to fail Principle X because [evidence], but this may be intentional for [reason]"

## Common Evaluation Patterns

**Pattern 1: No clear purpose (Principle 1 failure)**
This is the most common and most serious failure. If the document doesn't have a clear purpose, stop evaluation and return fundamental failure output. Don't evaluate structure, voice, etc. when there's no purpose to support.

Example: Meeting notes that transcribe everything said but don't capture decisions or action items.

**Pattern 2: Built on assumptions (Principle 6 failure)**
AI filled gaps with plausible-sounding fiction. The document appears finished but contains invented data, inferred decisions, or estimated numbers. This requires stopping evaluation and identifying what actual information is missing.

Example: Project proposal with ROI numbers that weren't calculated, just estimated by AI.

**Pattern 3: No constraints (Principle 3 failure)**
Document includes everything because nothing was explicitly excluded. This typically co-occurs with Principle 2 (Structure) failures.

Example: Executive brief that's 5 pages instead of 1 page, making it not actually a brief.

**Pattern 4: Happy path only (Principle 5 failure)**
Technical docs, SOPs, and post-mortems especially: they show how things work when everything goes right, but not what to do when things break.

Example: Technical documentation with no troubleshooting section or error handling.

**Pattern 5: Multiple fundamental failures**
When both Principle 1 and Principle 6 fail, the document is fundamentally broken. Use the REJECT verdict and recommend starting over with clear purpose and actual information.
