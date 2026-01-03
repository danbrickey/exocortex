# The 9 Principles of Quality Business Writing

## Principle 1: Purpose - Every Document Exists to Change Someone's Mind or Behavior

Documents must have a clear purpose: what specific decision or action should the reader take after reading? If you can't articulate the intended behavior change, the document shouldn't exist.

**Test:** Can you state in one sentence what this document is supposed to make someone do or understand differently?

**Common failures:**
- Documents that explain things without orienting readers toward decisions or actions
- Analysis without recommendations
- Meeting notes without action items or decisions
- Status reports that list activities but make no asks
- **Specific anti-pattern**: "This document provides an overview of..." (overview for what purpose? what should reader do?)
- **Specific anti-pattern**: Ending with "Let me know if you have questions" instead of "Please approve by Friday" or "Decision needed: A or B?"

**Why this matters:** If Purpose is broken, nothing else matters. A well-structured document with no clear purpose is still useless. This is always the highest priority issue.

## Principle 2: Structure - Structure Is a Forcing Function for Thought

Real structure sequences information in the order the reader needs it to make a decision and makes gaps in thinking visible. Templates are not structure—they let you fill boxes without developing actual arguments.

**Test:** Does the structure force you to answer hard questions? If you can't fill a section, does it reveal what you don't know yet?

**Common failures:**
- Generic five-section documents (Introduction, Background, Analysis, Recommendations, Conclusion) that look complete but say nothing
- Structure as formatting rather than logic
- **Specific anti-pattern**: Executive brief that puts recommendation on page 3 instead of paragraph 1
- **Specific anti-pattern**: Discussing solutions before stating the problem
- **Specific anti-pattern**: Sections filled with content because template has sections, not because logic requires them

## Principle 3: Constraints - Constraints Do More Work Than Instructions

Every constraint ("don't include X", "maximum 500 words", "use only provided data") is more valuable than an instruction ("include Y"). Constraints force prioritization; instructions allow comprehensiveness.

**Test:** Are there hard limits on length, scope, and content? Do these limits force hard choices about what matters most?

**Common failures:**
- No length constraints (leads to padding and filler)
- No scope boundaries (everything is included because nothing was excluded)
- No content constraints (AI fills gaps with plausible-sounding fiction)
- **Specific anti-pattern**: Executive brief that's 5 pages instead of 1 page (making it not actually a "brief")
- **Specific anti-pattern**: Meeting notes that transcribe entire discussion instead of capturing decisions/actions only
- **Specific anti-pattern**: Status report with 10 paragraphs of context when exec needs 3 bullet points

**Why this matters:** AI's default mode is comprehensive helpfulness. Without constraints, every document expands to include everything, making nothing a priority.

## Principle 4: Self-Evaluation - Quality Scales Through Self-Evaluation, Not Human Review

If your quality control depends on humans reading everything, you've already lost. Make documents self-check against explicit criteria before delivery.

**Test:** Does the document verify itself against concrete quality checks? Are the checks specific enough to be pass/fail?

**Common failures:** No built-in quality verification. Vague checks ("Is this good?" vs "Does every action item have an owner and deadline?"). Reliance on human review that can't scale.

## Principle 5: Failure Modes - Failure Modes Are More Predictable Than Success

You can't define what makes a great document, but you can define what makes a broken one. Every document type has predictable failure modes—test for those.

**Test:** Does the document address the specific ways this document type typically fails? Are checks objective and testable?

**Common failures:** Optimizing for "great" instead of "not broken". Missing the predictable failures (meeting notes without decisions, briefs without asks, docs without error handling).

## Principle 6: Input Quality - You Can't Prompt Your Way Around Bad Inputs

AI will happily write comprehensive documents from incomplete information by filling gaps with plausible-sounding inferences. The output looks complete but is built on assumptions, not facts.

**Test:** Do you have the actual information required for this document type? Not "I sort of know this" but specific data, decisions, and examples?

**Common failures:**
- Prompting AI to write before gathering actual information
- Accepting output that looks complete without verifying it's based on real data
- **Specific anti-pattern**: "Our solution improves efficiency by approximately 40%" (estimated number, not measured)
- **Specific anti-pattern**: "The team decided to proceed with Option B" (inferred decision that wasn't actually made)
- **Specific anti-pattern**: "Customer feedback has been positive" (invented claim with no actual customer quotes or survey data)
- **Specific anti-pattern**: Using placeholder metrics that AI generated: "reduced processing time from 4.2 hours to 1.3 hours" (suspiciously precise numbers that weren't actually measured)

**Why this matters:** If inputs are wrong, nothing downstream can fix it. A beautifully structured document built on assumptions is still fiction. This is the second-highest priority issue after Purpose.

## Principle 7: Voice - Every Organization's Documents Sound the Same Unless You Fight It

AI has a default voice (diplomatically hedge-y, generically professional). Without explicit voice specification, everything converges to the same tone, flattening the signal that comes from how people write.

**Test:** Does this document sound like it came from your organization/person, or does it sound like generic AI?

**Common failures:**
- Same cadence, transitions, and hedge language across all documents
- Loss of personality and differentiation
- Voice carries information about certainty—AI's default flattens this
- **Specific anti-pattern**: Starting sentences with "It's worth noting that..." (generic AI hedge phrase)
- **Specific anti-pattern**: Overuse of "Additionally," "Moreover," "Furthermore" as transition words
- **Specific anti-pattern**: "This allows for greater flexibility" instead of direct "This lets you X"
- **Specific anti-pattern**: Passive voice hiding responsibility: "It was decided" instead of "Sarah decided"
- **Specific anti-pattern**: Diplomatic hedging that removes useful certainty: "It may be beneficial to consider" instead of "We should" or "We might"

**Note:** This principle is more subjective than others. When evaluating, focus on whether generic AI phrases appear ("It's worth noting", "Additionally", "Moreover") rather than judging voice authenticity.

## Principle 8: Iteration - Iteration Is About Diagnosis, Not Polishing

"Make it better" doesn't work. Effective iteration requires specific diagnosis of what's broken before the next revision.

**Test:** Can you articulate the specific problem? Not "this feels off" but "Section 2 is too long" or "examples are generic" or "no clear recommendation"?

**Common failures:** Vague iteration requests that lead to full rewrites. Multiple passes without identifying the actual problem. Wasted iterations because the diagnosis was wrong.

## Principle 9: Workflows - Documents Don't Exist in Isolation—They Exist in Workflows

## Principle 9: Workflows - Documents Don't Exist in Isolation—They Exist in Workflows

Documents are tools in workflows. If the format doesn't match how the document is actually used in your organization, it doesn't matter how well-written it is.

**Test:** How is this document used downstream? Who reads it? What do they do with it? Does the format enable that use?

**Common failures:** Documents optimized as standalone artifacts rather than workflow tools. Format that doesn't match actual usage (meeting notes that can't be imported into task tracker, reports that don't surface information decision-makers need).

**Note:** This principle requires context about the organization's workflows. If you lack this context, note in evaluation: "Cannot assess Principle 9 without workflow context" and skip this principle.

---

## Principle Prioritization for Evaluation

When identifying priority fixes, use this hierarchy:

**Tier 1 - Fundamental (Always highest priority)**
1. **Principle 1 (Purpose)** - If this is broken, nothing else matters
2. **Principle 6 (Input Quality)** - Can't fix output if inputs are wrong

**Tier 2 - Structural (Fix after Tier 1)**
3. **Principle 3 (Constraints)** - Missing constraints cause everything else to expand
4. **Principle 2 (Structure)** - Affects how everything is organized

**Tier 3 - Refinement (Fix after Tier 1 and 2)**
5. **Principle 4 (Self-Evaluation)** - Important for scaling
6. **Principle 5 (Failure Modes)** - Document-specific quality
7. **Principle 8 (Iteration)** - Process improvement

**Tier 4 - Polish (Often subjective or context-dependent)**
8. **Principle 7 (Voice)** - Subjective, but matters for differentiation
9. **Principle 9 (Workflows)** - Requires organizational context

Within the same tier, prioritize fixes that:
- Affect the document's core function
- Block downstream usage
- Are quick wins (high impact, low effort)

---

## Document-Specific Failure Modes

### Meeting Notes
- No decisions documented (discussion transcribed but no "We decided X" statements)
- Action items without owners or deadlines
  - ❌ "Team to follow up on proposal"
  - ✅ "[Sarah] [Oct 15] Send pricing proposal to Acme Corp"
- Action items where owner is listed as "team" or "we" instead of specific person
- No clear next steps or what happens if deadlines are missed
- Missing date/attendees (can't tell who made decisions or when)
- Open questions buried in discussion instead of explicitly tracked with owner assigned to resolve

### Status Reports
- No actual status stated (just narrative of activities without "on track" / "at risk" / "blocked")
- Vague progress claims
  - ❌ "Making good progress on the API integration"
  - ✅ "API integration: 60% complete (3 of 5 endpoints done), on track for Oct 15 launch"
- Hidden blockers buried in paragraphs instead of called out explicitly
- No clear asks for help or escalation
- Metrics without context: "40% improvement" (from what baseline? measured how?)
- Lists what was done without stating whether goals were met

### Executive Briefs
- No decision request in first paragraph (exec has to read to page 3 to learn what you're asking for)
- Recommendation buried or absent
  - ❌ Discusses options A, B, C without stating which one to choose
  - ✅ "Recommendation: Choose Option B. Decision needed by Oct 15."
- Vague options without trade-offs
  - ❌ "Option A: Improve performance. Option B: Reduce costs."
  - ✅ "Option A: 20% faster ($50K cost, 3 month timeline). Option B: 30% cheaper (but 10% slower, 1 month timeline)."
- Unsourced claims and estimated numbers presented as facts
  - ❌ "This will generate approximately $2M in revenue"
  - ✅ "Projected $1.8-2.2M revenue (based on Acme deal at $75K ACV × 25 similar prospects in pipeline)"
- No risk section or only discusses upsides

### Project Proposals
- Vague problem statement
- Solution describes features, not outcomes
- No resource estimates provided (or estimates lack justification)
- Scope creep (no out-of-scope section)
- Hidden dependencies

### PRDs
- Vague requirements
- Missing edge cases
- Solution prescribed instead of problem described
- Success criteria unmeasurable at launch
- Undocumented open questions

### Technical Documentation
- Missing prerequisites (developer discovers required tools through error messages)
  - ❌ Says "install the dependencies" without listing what they are
  - ✅ "Prerequisites: Node 18+, PostgreSQL 14+, Redis 6+"
- Happy path only (no error handling or edge cases documented)
- Incomplete code examples (pseudocode that can't actually run, or missing imports/error handling)
- No troubleshooting section for common errors
  - ❌ No guidance when developer gets "ECONNREFUSED"
  - ✅ "Error ECONNREFUSED: Database isn't running. Start with: docker-compose up db"
- Assumed knowledge not stated upfront ("assumes familiarity with REST APIs")
- Examples don't show expected output (developer doesn't know if they succeeded)
- No guidance on production vs. development setup differences

### Post-Mortems
- Blame individuals instead of systems
- Surface-level root cause
- Vague impact
- Timeline without specific times
- Action items without owners

### SOPs
- Assumes tribal knowledge
- Vague steps without clear actions
- No edge case handling
- No quality verification
- Outdated with no review schedule
