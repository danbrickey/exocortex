# Snowflake Cortex AI Approval Pitch
**Executive Review Board Presentation**
*Modular talking points - select based on board questions*

---

## Executive Summary (30 seconds)

**Snowflake Cortex gives us production-grade AI capabilities that stay within our existing HIPAA-compliant environment, eliminating the productivity gap between what our engineers can do with consumer AI tools versus what they need for our enterprise data workloads.**

We're requesting approval for a controlled pilot to prove value in 2-3 use cases over Q4 2025 through Q2 2026, with costs managed through consumption-based billing. This unlocks capabilities we cannot achieve with M365 Copilot or other external tools while maintaining our security posture.

---

## Security & HIPAA Compliance (1 minute)

**Cortex processes all data within our existing Snowflake HIPAA-compliant environment—no data leaves the boundary we've already certified.**

- **Data residency**: Models run in the same AWS region as our production data (no external API calls, no third-party training)
- **Existing controls apply**: Row access policies, data masking, and RBAC we've already implemented work seamlessly with Cortex functions
- **Audit trail**: All Cortex operations log through Snowflake's query history and access logs, maintaining our compliance reporting
- **No model training on our data**: Cortex uses pre-trained models; our PHI is never used to train or improve external models
- **Contractual coverage**: Covered under our existing Snowflake BAA—no new vendor agreements or privacy assessments required

*This is fundamentally different from ChatGPT or other external AI services where data must leave our control.*

---

## Developer Productivity Gains (1 minute)

**Our engineers currently waste hours manually refactoring legacy SQL and validating data transformations—work that Cortex can accelerate while staying inside our security boundary.**

### Code Migration & Refactoring
- **The gap**: M365 Copilot can't handle complex SQL migrations from our legacy EDW2 warehouse (limited context, no database connectivity)
- **Cortex advantage**: Direct access to our schemas, can analyze 10,000+ line stored procedures in context, refactor to modern data vault patterns
- **Expected impact**: Reduce code migration time from weeks to days for critical business logic

### Data Quality Automation
- **Current state**: Manual spot-checks and reactive issue detection
- **Cortex capability**: Automated anomaly detection, schema validation, intelligent data profiling at scale
- **Expected impact**: Catch data quality issues before they reach production analytics

### Time-to-value**
- Engineers spend less time on mechanical work (parsing old code, writing boilerplate quality checks)
- More time on high-value architecture and optimization
- Faster delivery of migration milestones in our EDP roadmap

---

## Business Capability Unlocks (1 minute)

**Cortex enables business users to interact with data in natural language and automates knowledge work that currently requires specialized technical skills.**

### Natural Language Querying (Cortex Search)
- **Business value**: Non-technical users can ask questions like "show me enrollment trends for Medicare Advantage in King County" without writing SQL
- **Target users**: Business analysts, operations teams, executives needing ad-hoc insights
- **Competitive position**: Peer health plans are already deploying similar capabilities—we risk falling behind

### Document Intelligence (Arctic for document processing)
- **Immediate use case**: Summarize provider contracts for customer service agents responding to network inquiries
- **Current state**: Agents manually search lengthy PDF contracts, slowing response times
- **Expected impact**: Faster, more accurate customer service; reduced training burden for new agents

### Predictive Analytics Foundation
- **Strategic positioning**: Establishes foundation for advanced analytics (risk scoring, utilization forecasting, member churn prediction)
- **Business demand**: Multiple stakeholders have requested predictive capabilities we currently can't deliver
- **Platform advantage**: Keeps analytics in one platform rather than fragmented tools

---

## Risk Mitigation (30 seconds)

**The bigger risk is NOT adopting Cortex—our competitors are moving ahead with AI-powered analytics while our engineers work around limitations of consumer tools.**

- **Controlled approach**: Pilot POCs in sandbox first, production deployment only after validation
- **Cost containment**: Consumption pricing means we only pay for what we use (most models cost pennies per query)
- **Reversibility**: No vendor lock-in beyond Snowflake relationship we already have
- **Governance**: We control which models are enabled, who has access, and what data they can query

*Waiting for "perfect" AI security means accepting productivity losses and competitive disadvantage.*

---

## Competitive Positioning (30 seconds)

**Health plans that deliver faster insights and better member experiences will win in the value-based care era—AI is becoming table stakes.**

- **Industry trend**: Major payers (Humana, UnitedHealth, Elevance) are public about AI investments in data analytics
- **Talent retention**: Engineers expect access to modern tools; restricting AI capabilities makes us less attractive
- **Vendor ecosystem**: Snowflake's roadmap heavily emphasizes AI—staying on older capabilities means falling behind platform evolution

*We're not pursuing AI for hype—we're pursuing it because our data workloads demand it.*

---

## The Ask & Next Steps (30 seconds)

**Approve Cortex LLM functions, Arctic document processing, and Cortex Search for controlled pilot use in our production Snowflake account.**

### Scope
- **Timeline**: Q4 2025 – Q2 2026 for initial POCs
- **Access**: EDP data engineering teams under existing RBAC controls
- **Budget**: Consumption-based (no upfront licensing); estimate <$5K for pilot phase
- **Deliverables**: 2-3 validated use cases with documented ROI before broader rollout

### Governance
- Quarterly review with this board on pilot outcomes
- Document security controls and any incidents
- Develop usage policies before production deployment beyond data engineering

**Next step**: Approve pilot access so we can begin POC work in Q4 2025 with code migration use case.

---

## Supplemental: Addressing Common Concerns

### "What if a model hallucinates incorrect SQL?"
All Cortex-generated code goes through the same code review, testing, and validation as human-written code. Models augment engineer judgment; they don't replace it.

### "How do we prevent engineers from exposing PHI to the model?"
Cortex queries are subject to the same row access and masking policies as any Snowflake query. Engineers can't circumvent existing security controls.

### "What if Snowflake changes their AI terms?"
We can disable Cortex features at any time without impacting core data platform functionality. We're not building dependencies we can't unwind.

### "Why not wait for GitHub Copilot approval?"
GitHub Copilot helps with code syntax; Cortex helps with *data* problems (schema analysis, quality checks, complex transformations). They solve different problems. We need both.

---

*Document prepared: 2025-10-23*
*Author: Dan Brickey, EDP Data and Solution Architect*
*Review Board: CISO, CIO, Compliance, Finance, Operations*
