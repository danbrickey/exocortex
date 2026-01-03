# Content Quality Evaluators

Specialized evaluators for marketing, sales, and operations content. These prompts assess specific content types against measurable criteria to identify and fix AI-generated "slop"—generic content that wastes reader time.

## Quick Start

1. **Choose your evaluator** based on content type (see catalog below)
2. **Copy the evaluator prompt** into your AI tool
3. **Append the content** you want evaluated
4. **Get structured feedback** with:
   - Overall score (0-5 scale)
   - Dimension-by-dimension analysis
   - Verdict (ACCEPT/REVISE/REJECT)
   - 3-5 surgical fixes with exact locations and replacement text

## Philosophy

These evaluators combat AI's tendency to produce verbose, generic content by requiring:

- **Specificity**: Concrete examples instead of vague claims
- **Proof**: Verifiable data instead of assertions
- **Clarity**: Exact fixes instead of "make it better"
- **Measurability**: 0-5 scores instead of subjective judgment

See [Evaluation Framework](references/evaluation-framework.md) for detailed methodology.

---

## Marketing Content Evaluators

Evaluate external-facing marketing content for conversion and engagement.

### [Blog Post Evaluator](marketing/blog-post-evaluator.md)
**For**: Blog posts, article content, thought leadership pieces

**Evaluates**:
- Specificity (concrete examples vs. generic claims)
- Proof Density (claims backed by data)
- Positioning Clarity (who this is for)
- Differentiation (why not competitors)
- Call-to-Action (clear next step)

**Use when**: Publishing blog content, reviewing draft articles, training content writers

---

### [Social Media Post Evaluator](marketing/social-media-evaluator.md)
**For**: LinkedIn posts, Twitter/X threads, social media content

**Evaluates**:
- Hook Strength (first sentence earns the read)
- Specificity (concrete examples vs. platitudes)
- Insight Novelty (fresh take vs. generic wisdom)
- Engagement Design (invites discussion)
- Format Optimization (scannable on mobile)

**Use when**: Drafting social posts, reviewing content calendar, improving engagement rates

---

### [Ad Copy Evaluator](marketing/ad-copy-evaluator.md)
**For**: Google Ads, Meta ads, LinkedIn ads, display ads

**Evaluates**:
- Benefit Clarity (specific outcome in first 5 words)
- Objection Handling (addresses why not competitor)
- Urgency Creation (time-bound reason to act)
- Friction Removal (clear what happens next)
- Trust Signals (specific proof)

**Use when**: Creating ad campaigns, optimizing CTR, reducing CPA

---

### [Product Description Evaluator](marketing/product-description-evaluator.md)
**For**: E-commerce listings, SaaS product pages, marketplace content

**Evaluates**:
- Use Case Specificity (who should buy this)
- Problem-Solution Mapping (pain point addressed)
- Differentiation (why not alternatives)
- Technical Precision (specs detailed enough to evaluate)
- Objection Preemption (addresses concerns)

**Use when**: Writing product pages, optimizing conversion, reducing returns

---

### [Landing Page Copy Evaluator](marketing/landing-page-evaluator.md)
**For**: Landing pages, hero sections, conversion-focused pages

**Evaluates**:
- Value Proposition Clarity (benefit clear in 5 seconds)
- Specificity and Proof (claims backed by evidence)
- Objection Handling (addresses alternatives)
- CTA Clarity and Friction (obvious next step)
- Message Hierarchy (most important info first)

**Use when**: Building landing pages, A/B testing, improving conversion rates

---

### [Video Script Evaluator](marketing/video-script-evaluator.md)
**For**: Explainer videos, demo videos, tutorials, marketing videos

**Evaluates**:
- Hook Strength (first 10 seconds earn next 50)
- Pacing and Momentum (no wasted words)
- Show vs. Tell (demonstrates with visuals)
- Clarity of Progression (clear structure)
- Call-to-Action Strength (specific next step)

**Use when**: Scripting videos, reducing drop-off rates, improving engagement

---

### [Email Newsletter Evaluator](marketing/email-newsletter-evaluator.md)
**For**: Email newsletters, content digests, subscriber communications

**Evaluates**:
- Subject Line Value Proposition (concrete promise)
- Above-Fold Value (payoff in first 2 sentences)
- Content Curation Quality (every item is valuable)
- Scannability (value in 60 seconds)
- Actionability (specific takeaways)

**Use when**: Sending newsletters, improving open rates, reducing unsubscribes

---

## Sales Content Evaluators

Evaluate sales outreach and campaign content for response rates and conversion.

### [Outreach Email Evaluator](sales/outreach-email-evaluator.md)
**For**: Cold emails, warm outreach, sales prospecting

**Evaluates**:
- Personalization Depth (research beyond company name)
- Problem Hypothesis (educated guess at pain point)
- Relevance Signal (why this matters now)
- Value Clarity (outcomes not features)
- Ask Size (low-friction next step)

**Use when**: Sales outreach, improving response rates, training SDRs

---

### [Email Campaign Evaluator](sales/email-campaign-evaluator.md)
**For**: Marketing email campaigns, promotional emails, product updates

**Evaluates**:
- Subject Line Specificity (concrete promise)
- Personalization Signals (segmentation beyond name)
- Value Proposition Clarity (benefit in first sentence)
- Social Proof (customer evidence)
- Friction Reduction (clear single CTA)

**Use when**: Email marketing, improving click rates, reducing unsubscribes

---

## Operations Content Evaluators

Evaluate internal and client-facing operational content for clarity and effectiveness.

### [Support Response Evaluator](operations/support-response-evaluator.md)
**For**: Customer support emails, chat responses, ticket replies

**Evaluates**:
- Problem Comprehension (understands specific issue)
- Solution Completeness (all steps to resolve)
- Clarity and Precision (non-technical user can follow)
- Context Awareness (references customer situation)
- Proactive Guidance (prevents related problems)

**Use when**: Support ticket responses, reducing ticket ping-pong, improving CSAT

---

### [Meeting Summary Evaluator](operations/meeting-summary-evaluator.md)
**For**: Meeting notes, decision records, action item summaries

**Evaluates**:
- Decision Clarity (decisions explicitly called out)
- Action Item Precision (owner, due date, deliverable)
- Context Efficiency (why decisions were made)
- Open Question Tracking (unresolved items with owner)
- Scanability (find info in 30 seconds)

**Use when**: Recording meetings, sharing decisions, ensuring accountability

---

### [Internal Communication Evaluator](operations/internal-communication-evaluator.md)
**For**: Company announcements, policy changes, internal memos

**Evaluates**:
- Change Clarity (what changed as of when)
- Scope Definition (who this affects)
- Action Requirements (what people need to do)
- Reasoning (why this change)
- Question Prevention (anticipates FAQs)

**Use when**: Company announcements, reducing follow-up questions, change management

---

### [Technical Documentation Evaluator](operations/technical-documentation-evaluator.md)
**For**: API docs, integration guides, architecture documentation

**Evaluates**:
- Completeness (all necessary steps covered)
- Code Example Quality (runnable, realistic)
- Error Coverage (common errors with solutions)
- Structural Clarity (find info in 60 seconds)
- Production Readiness (covers rate limits, auth, scaling)

**Use when**: Writing developer docs, reducing support tickets, improving DX

---

### [Business Rules Documentation Evaluator](operations/business-rules-documentation-evaluator.md)
**For**: 4-level progressive business rules documentation (Executive → Management → Analyst → Engineering)

**Evaluates**:
- Audience-Appropriate Depth (each level matches target audience)
- Specificity & Verifiability (concrete examples vs. generic claims)
- Progressive Complexity (logical learning flow across levels)
- Code Translation Quality (business logic → natural language)
- Practical Completeness (includes examples, troubleshooting, testing)

**Use when**: Evaluating bizrules-documenter output, onboarding documentation, teaching warehouse logic

**Note**: Returns **Markdown** feedback document (not JSON) saved as `{original_filename}_feedback.md`

---

### [Executive Memo Evaluator](operations/executive-memo-evaluator.md)
**For**: Strategy docs, decision proposals, executive briefs

**Evaluates**:
- Bottom Line Up Front (recommendation in first paragraph)
- Decision Quality (options, pros/cons, reasoning)
- Data Specificity (claims backed by numbers)
- Risk Identification (downsides and mitigation)
- Scannability (key points in 3 minutes)

**Use when**: Executive presentations, decision memos, strategy documents

---

### [Client Deliverable Evaluator](operations/client-deliverable-evaluator.md)
**For**: Consulting reports, analysis documents, client-facing deliverables

**Evaluates**:
- Actionability (can start Monday without calls)
- Insight Density (non-obvious value)
- Evidence Backing (supported by client data)
- Prioritization (clear sequencing)
- Executive Readiness (board-ready formatting)

**Use when**: Client consulting work, final deliverables, maintaining relationships

---

## When to Use Which Evaluator

### Marketing vs. Sales vs. Operations

**Marketing Evaluators** → External-facing content for broad audiences
- Goal: Engagement, conversion, brand building
- Examples: Blog posts, social media, ads, landing pages

**Sales Evaluators** → Direct outreach to prospects
- Goal: Response rates, qualified conversations
- Examples: Cold emails, email campaigns

**Operations Evaluators** → Internal or client-facing operational content
- Goal: Clarity, efficiency, actionability
- Examples: Support responses, meeting notes, technical docs, executive memos

### Content Evaluators vs. Business Document Evaluator

**Use Content Evaluators** (this directory) for:
- Marketing and sales content
- External communications
- Conversion-focused content
- Engagement metrics matter

**Use [Business Document Evaluator](../business-doc-evaluator/SKILL.md)** for:
- Internal business documents (PRDs, post-mortems, SOPs)
- Meeting notes and status reports
- Organizational workflow documents
- Purpose and action clarity matter

See [Business Document Evaluator](../business-doc-evaluator/SKILL.md) for evaluating internal business documents.

---

## Evaluation Output Format

Most evaluators return structured JSON (exception: Business Rules Documentation Evaluator returns Markdown):

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
    "element_name": {
      "present": true,
      "quality": "Specific assessment"
    }
  },
  "critical_gaps": [
    "Most serious issue",
    "Second critical gap"
  ],
  "top_fixes": [
    {
      "priority": 1,
      "location": "Exact location",
      "problem": "Specific issue",
      "fix": "Exact replacement text",
      "why": "Impact explanation"
    }
  ]
}
```

## Verdict Meanings

- **ACCEPT** (≥4.2): Ready to ship
- **REVISE** (3.0-4.1): Fixable issues, apply surgical fixes
- **REJECT** (<3.0): Fundamental problems, needs substantial rework

---

## Resources

- **[Evaluation Framework](references/evaluation-framework.md)** - Shared principles and methodology
- **[Business Document Evaluator](../business-doc-evaluator/SKILL.md)** - For internal business documents
- **[Business Document Principles](../business-doc-evaluator/references/principles.md)** - 9 principles of quality business writing

---

## Contributing New Evaluators

To create a new evaluator for a different content type:

1. Review the [Evaluation Framework](references/evaluation-framework.md)
2. Identify 5 key dimensions specific to your content type
3. Define required elements and anti-patterns
4. Create scoring rubrics (0, 3, 5) with examples
5. Follow the standard output format
6. Add to this README with description and use cases

See [Evaluation Framework - Creating New Evaluators](references/evaluation-framework.md#creating-new-evaluators) for detailed guidance.
