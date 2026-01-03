# Content Quality Evaluation Framework

This framework provides shared principles and methodology for evaluating content quality across all evaluator types. Use this as a reference when creating new evaluators or understanding how existing evaluators work.

## Core Philosophy: Combat AI-Generated "Slop"

AI makes it easy to generate large volumes of content. However, volume without value creates "slop"—content that looks complete but provides no actionable insight. These evaluators combat slop by requiring:

### 1. Specificity Over Generics
**Problem**: AI defaults to vague, safe claims that sound plausible but say nothing concrete.

**Solution**: Require verifiable specifics
- Customer names instead of "many customers"
- Actual numbers instead of "significant improvement"
- Precise dates instead of "recently"
- Specific examples instead of generic scenarios

**Example**:
- ❌ "Our solution helps companies improve efficiency"
- ✅ "Acme Corp reduced manual data entry from 14 hours/week to 2 hours/week within 3 months"

### 2. Proof Over Assertions
**Problem**: AI confidently states claims without evidence because generating assertions is easier than verifying facts.

**Solution**: Every major claim must have backing
- Customer quotes (with attribution)
- Data with sources and methodology
- Screenshots or screen recordings
- Links to case studies or external validation
- Benchmarks with comparison methodology

**Example**:
- ❌ "Industry-leading performance"
- ✅ "Processes 50,000 records in 200ms vs. Competitor X's 800ms (benchmark: Apache JMeter, N=1000 runs)"

### 3. Surgical Fixes Over Rewrites
**Problem**: Vague feedback like "make it better" leads to full rewrites that waste time.

**Solution**: Precise, actionable corrections
- Exact location (paragraph number, sentence start)
- Specific problem identified
- Exact replacement text provided
- Rationale for why the fix matters

**Example Fix Structure**:
```json
{
  "priority": 1,
  "location": "Paragraph 3, sentence starting 'Many enterprise customers...'",
  "problem": "Generic claim with no verification possible",
  "fix": "Replace with: 'Acme Corp reduced manual data entry from 14 hours per week to 2 hours per week within 3 months (source: case study link).'",
  "why": "Specific customer name + specific metrics + timeframe = verifiable and credible"
}
```

### 4. Measurable Criteria Over Subjective Judgment
**Problem**: "This feels off" or "could be better" provides no actionable guidance.

**Solution**: Concrete thresholds and tests
- 0-5 scoring scale with defined levels
- Pass/fail tests for required elements
- Quantifiable anti-patterns (e.g., "starts with 'Excited to share'")
- Objective verdict thresholds (ACCEPT ≥4.2, REVISE 3.0-4.1, REJECT <3.0)

## Standard Evaluation Methodology

All evaluators follow this consistent process:

### Step 1: Identify Content Type
Match the content to the appropriate evaluator:
- Marketing: blog posts, social media, ads, landing pages, product descriptions
- Sales: outreach emails, email campaigns
- Operations: support responses, meeting summaries, internal communications, client deliverables
- Technical: documentation, API guides

### Step 2: Score Against 5 Dimensions
Each evaluator assesses 5 domain-specific dimensions on a 0-5 scale:

**Score 5**: Excellent—exceeds requirements, best practices fully implemented
**Score 3**: Adequate—meets basic requirements but has room for improvement
**Score 0**: Failing—critical issues that make content ineffective

### Step 3: Check Required Elements
Verify presence and quality of must-have components:
- Present (yes/no)
- Quality assessment (specific, actionable feedback)

### Step 4: Identify Critical Gaps
List the 2-5 most serious issues that prevent the content from being effective.

### Step 5: Provide Surgical Fixes
Generate 3-5 prioritized fixes with:
- Priority ranking (1 = most critical)
- Exact location in the document
- Specific problem identified
- Exact replacement text
- Rationale for why this fix matters

### Step 6: Render Verdict
- **ACCEPT** (≥4.2): Ready to ship with minor or no changes
- **REVISE** (3.0-4.1): Fixable issues that should be addressed
- **REJECT** (<3.0): Fundamental problems requiring substantial rework

## Common Anti-Patterns Across All Content Types

These failures appear across different content types and should always be flagged:

### Generic Claims Without Evidence
❌ "Best-in-class"
❌ "Industry-leading"
❌ "Trusted by thousands"
❌ "Significant improvements"
❌ "Many customers report"

✅ Always require: specific customer names, exact metrics, or verifiable benchmarks

### Metrics Without Context
❌ "40% faster" (faster than what?)
❌ "Improved by 3x" (from what baseline?)
❌ "Reduced costs significantly" (by how much? over what period?)

✅ Always require: baseline, comparison point, measurement methodology, time period

### Vague Timeframes
❌ "Recently we've seen"
❌ "In the coming weeks"
❌ "Soon we'll release"

✅ Always require: specific dates or relative timeframes ("within 3 months," "by Oct 15")

### Empty Social Proof
❌ "Thousands of happy customers"
❌ "Leading companies use our platform"
❌ "Highly rated by users"

✅ Always require: named customers, specific ratings with source ("4.8/5 on G2, 340 reviews"), or quoted testimonials

### Feature Dumps Without Benefits
❌ "Our platform includes X, Y, and Z"
❌ "Powerful API with advanced capabilities"

✅ Always require: outcomes expressed in customer terms ("Deploy in 10 minutes instead of 3 hours")

### No Clear Call-to-Action
❌ "Learn more" (learn what? where?)
❌ "Get started" (with what? how long does it take?)
❌ "Contact us" (for what specific purpose?)

✅ Always require: specific next step with friction removed ("Watch 2-min demo—no signup required")

## Standard JSON Output Format

All evaluators return consistent JSON structure:

```json
{
  "overall_score": 3.8,
  "axis_scores": {
    "dimension_1": 4,
    "dimension_2": 3,
    "dimension_3": 4,
    "dimension_4": 3,
    "dimension_5": 5
  },
  "verdict": "ACCEPT/REVISE/REJECT",
  "required_elements": {
    "element_1": {
      "present": true,
      "quality": "Specific assessment of quality"
    },
    "element_2": {
      "present": false,
      "quality": "Missing entirely"
    }
  },
  "critical_gaps": [
    "First most serious issue preventing effectiveness",
    "Second critical gap",
    "Third gap (if applicable)"
  ],
  "top_fixes": [
    {
      "priority": 1,
      "location": "Exact location (paragraph, section, line)",
      "problem": "Specific issue identified",
      "fix": "Exact replacement text or specific action to take",
      "why": "Impact explanation—why this fix matters"
    }
  ]
}
```

## Verdict Threshold Guidelines

### ACCEPT (≥4.2 overall score)
- All required elements present with good quality
- Fewer than 2 critical gaps
- Minor improvements suggested but not blocking
- Content is ready to ship

### REVISE (3.0-4.1 overall score)
- Core structure is solid but needs improvements
- Missing 1 required element OR has 3+ gaps
- Fixes are surgical and well-defined
- Can move to ACCEPT with focused edits

### REJECT (<3.0 overall score)
- Fundamental issues require substantial rework
- Missing 2+ required elements
- Content could apply to any product/situation (zero specificity)
- Would require rewrite rather than editing

## Creating New Evaluators

When creating a new evaluator for a different content type, follow this template:

### 1. Define Content Type and Purpose
- What specific content type does this evaluate?
- What is the success metric for this content type?
- What would make someone reading/using this content successful?

### 2. Identify 5 Key Dimensions
Choose dimensions that:
- Address the most common failure modes for this content type
- Are measurable (can score 0-5 objectively)
- Cover different aspects (don't overlap)
- Map to actual business outcomes

### 3. Define Required Elements
Identify 3-5 must-have components without which the content cannot function.

### 4. Document Anti-Patterns
List the 5-10 most common failures specific to this content type.

### 5. Create Scoring Rubrics
For each dimension, define what Score 5, Score 3, and Score 0 look like with concrete examples.

### 6. Set Verdict Thresholds
Define specific conditions for ACCEPT/REVISE/REJECT (may vary slightly by content type but should align with framework).

## Evaluation Best Practices

### Be Specific, Not Generic
❌ "This document needs more detail"
✅ "Section 2 lacks metrics. Add: number of users affected, duration of impact, revenue loss"

### Locate Problems Precisely
❌ "The structure is unclear"
✅ "Paragraphs 3-5 discuss solution before stating the problem. Move problem statement to paragraph 1"

### Give Actionable Fixes
❌ "Make this more concise"
✅ "Cut paragraphs 4 and 7 (background context). Keep only paragraphs 1-3 and 8-10 (problem and solution)"

### Prioritize Using Impact
Focus fixes on:
1. Fundamental issues (missing purpose, wrong audience)
2. Proof/credibility issues (unsupported claims)
3. Clarity/structure issues (reader can't find key info)
4. Polish (voice, formatting)

### Be Honest But Constructive
- Call out real problems directly: "This document has no clear purpose" not "The purpose could be clearer"
- Acknowledge what works well (when verdict is ACCEPT or REVISE with minor issues)
- Remember the goal is improvement, not criticism
- Avoid hedge language in evaluation ("somewhat", "could be", "might benefit from")

## Related Resources

- **Business Document Evaluator**: [../../business-doc-evaluator/SKILL.md](../../business-doc-evaluator/SKILL.md)
- **Business Document Principles**: [../../business-doc-evaluator/references/principles.md](../../business-doc-evaluator/references/principles.md)
- **Content Evaluators Catalog**: [../README.md](../README.md)
