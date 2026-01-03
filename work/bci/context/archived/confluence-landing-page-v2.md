# EDP Architecture Documentation - Confluence Setup Guide

## Part 1: Your Confluence-Ready Content

Copy the content below and paste it into Confluence following the setup instructions in Part 2.

---

# EDP Architecture Documentation

> **Official documentation repository for the Enterprise Data Platform (EDP) project**

---

## 📚 Access Documentation

The EDP Architecture Documentation is maintained in GitLab for version control, markdown formatting, and collaborative editing.

### 🔗 [**Access Full Documentation Repository**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs)

---

## 🚀 Quick Links

### Getting Started
- 📖 [**Documentation Index**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/DOCUMENTATION_INDEX.md) - Start here for AI-navigable access to all documentation
- 🏷️ [**Taxonomy Guide**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/TAXONOMY.md) - Controlled vocabulary for searching documentation

### Key Architecture Documents
- 🏗️ [**EDP Platform Architecture**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/architecture/edp_platform_architecture.md) - High-level platform overview
- 📊 [**Layer Architecture Detailed**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/architecture/edp-layer-architecture-detailed.md) - Specifications for all medallion layers
- 🔐 [**Multi-Tenancy Pattern**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/architecture/patterns/multi-tenancy-architecture.md) - Security pattern for data isolation

### Implementation Guides
- 📘 [**Data Vault 2.0 Guide**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/engineering-knowledge-base/data-vault-2.0-guide.md) - Comprehensive implementation reference
- ⚙️ [**Environment Configuration**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/engineering-knowledge-base/environment-database-configuration.md) - Database and environment setup

### Business Rules by Domain
- 🤝 [**Broker Rules**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules/broker) - Producer/broker business logic
- 📋 [**Claims Rules**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules/claims) - Claims processing and adjudication
- 💰 [**Financial Rules**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules/financial) - Premium billing and accounting
- 👥 [**Membership Rules**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules/membership) - Enrollment and eligibility
- 📦 [**Product Rules**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules/product) - Plan designs and benefits
- 🏥 [**Provider Rules**](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules/provider) - Network and reimbursement

---

## 💡 Why GitLab?

The documentation is maintained in GitLab to provide:

✅ **Version Control** - Track all changes with full history and rollback capability
✅ **Markdown Format** - Clean, readable formatting with excellent rendering
✅ **Collaborative Editing** - Team members can submit updates via merge requests
✅ **AI-Optimized Structure** - Taxonomy and indexing for AI-powered navigation
✅ **Single Source of Truth** - One authoritative location for all architecture documentation
✅ **Cross-References** - Linked documentation creates a knowledge graph

---

## 🔍 How to Find Information

### By Your Need

**"I need to understand the overall architecture..."**
→ Start with [EDP Platform Architecture](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/architecture/edp_platform_architecture.md) - read the Executive Summary section

**"I need technical details about a specific layer..."**
→ See [Layer Architecture Detailed](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/architecture/edp-layer-architecture-detailed.md)

**"I need to understand business rules for my domain..."**
→ Browse [Business Rules folders](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/architecture/rules) by domain

**"I need implementation guidance..."**
→ Check [Engineering Knowledge Base](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/engineering-knowledge-base)

**"I need to find everything about [specific topic]..."**
→ Use the [Documentation Index](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/DOCUMENTATION_INDEX.md) organized by type, domain, and layer

### By Document Type

- **Architecture** - System design, patterns, technical decisions
- **Business Rules** - Domain-specific logic and calculations
- **Implementation Guides** - How-to guides and technical references
- **Patterns** - Reusable architecture patterns

### By EDP Layer

- **Raw Layer** - Source system landing zone
- **Integration Layer** - Data Vault 2.0 raw vault
- **Curation Layer** - Business vault and dimensional models
- **Consumption Layer** - Analytics-ready data products

---

## 🏗️ Documentation Structure

All architecture documentation follows a **multi-audience layering** approach:

1. **Executive Summary** (2-3 min read) - Business context and value
2. **Analytical Overview** (5-7 min read) - Functional capabilities and requirements
3. **Technical Architecture** (15-30 min read) - Detailed technical design
4. **Implementation Specifications** (reference) - Code patterns and deployment

**Start at your level of interest and drill down as needed.**

---

## 🔐 Compliance Note

All documentation is **free of PHI/PII**. Examples use sanitized/fictional data only.

If you discover any sensitive information in the documentation, please report it immediately to Dan Brickey.

---

## 📝 Contributing to Documentation

Have documentation updates or new business rules to capture?

1. Review the [Contributing Guide](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs#-contributing-and-updating-documentation) in GitLab
2. Create a feature branch for your changes
3. Follow the [Documentation Quality Checklist](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs#documentation-quality-checklist)
4. Submit a merge request for review

---

## 👥 Contact

**EDP Data & Solution Architect:** Dan Brickey

**Questions or feedback?** Contact the EDP Architecture team or submit an issue in GitLab.

---

## 📚 Additional Context

For project context, team structure, and AI collaboration resources, see:
- [CLAUDE.md](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/blob/main/CLAUDE.md) - Project context and team information
- [AI Resources](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs/-/tree/main/ai-resources) - AI tools and prompt templates

---

**Last Updated:** 2025-10-22
**Maintained By:** Dan Brickey, EDP Data & Solution Architect

---

## 🔖 Page Labels

`edp` `architecture` `data-platform` `documentation` `data-vault` `snowflake` `analytics`

---

## Part 2: Step-by-Step Confluence Setup

### Step 1: Create the Page
1. Go to your Confluence Space (likely under EDP or Data Platform)
2. Click **"Create"** button (top right)
3. Select **"Blank page"** template
4. Set page title: **"EDP Architecture Documentation"**

### Step 2: Paste and Format Content
1. Copy all content from Part 1 above (starting with the heading)
2. Paste into the Confluence editor
3. Confluence will auto-convert most markdown formatting

### Step 3: Add Confluence Enhancements (Optional but Recommended)

**Add an Info Panel at the top:**
- Click **Insert** → **Info Panel**
- Paste: "Official documentation repository for the Enterprise Data Platform (EDP) project"

**Add a Button for the main GitLab link:**
- Highlight the main repository link
- Click **Link** → Consider using Confluence's button macro for prominence

**Add a Table of Contents:**
- Click **Insert** → **Table of Contents**
- Place it right after the "Access Documentation" section

**Use Expand macros for collapsible sections:**
- Highlight the "How to Find Information" section
- Click **Insert** → **Expand**
- This makes the page cleaner for users who don't need all details

### Step 4: Add Page Labels
At the bottom of the page, add these labels (Confluence has a labels section):
- `edp`
- `architecture`
- `data-platform`
- `documentation`
- `data-vault`
- `snowflake`
- `analytics`

### Step 5: Set Page Properties (Optional)
- **Add to Space sidebar** if you want it easily accessible
- **Set permissions** if needed (usually inherits from space)
- **Watch page** to get notified of changes

### Step 6: Link to Confluence from GitLab
Add a reference in your GitLab repository's main README.md:

```markdown
## 📄 Confluence Landing Page

For quick access to this documentation from within Confluence, see:
[EDP Architecture Documentation (Confluence)](YOUR_CONFLUENCE_PAGE_URL)
```

---

## Part 3: Confluence Formatting Tips

### Headings
- `#` becomes Heading 1
- `##` becomes Heading 2
- Adjust using the paragraph style dropdown if needed

### Links
- Most markdown links `[text](url)` will convert automatically
- Verify all links work after pasting

### Emoji
- Should paste directly: 📚 🚀 💡 🔍
- If they don't appear, use Confluence's emoji picker (`:` then type emoji name)

### Lists
- Bulleted and numbered lists should convert automatically
- Use Tab/Shift+Tab to adjust indentation

### Code/Monospace
- Inline code: Use Confluence's code formatting (Ctrl+Shift+M or toolbar)
- Code blocks: Insert → Code Block macro

---

## Part 4: Testing Your Page

After publishing, verify:
- ✅ All GitLab links work and point to correct files
- ✅ Emoji display correctly
- ✅ Heading hierarchy makes sense
- ✅ Page is accessible to intended audience
- ✅ Labels are applied
- ✅ Table of contents (if added) generates correctly

---

## Need Help?

If links aren't working or formatting looks off, let me know and I can help troubleshoot specific issues.
