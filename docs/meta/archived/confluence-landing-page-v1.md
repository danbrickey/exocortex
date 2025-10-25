# EDP Architecture Documentation

> **Official documentation repository for the Enterprise Data Platform (EDP) project**

---

## 📚 Access Documentation

The EDP Architecture Documentation is maintained in GitLab for version control, markdown formatting, and collaborative editing.

### 🔗 [**Access Full Documentation Repository**](https://gitlab.yourcompany.com/edp/architecture-docs)

---

## 🚀 Quick Links

### Getting Started
- 📖 [**Documentation Index**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/DOCUMENTATION_INDEX.md) - Start here for AI-navigable access to all documentation
- 🏷️ [**Taxonomy Guide**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/TAXONOMY.md) - Controlled vocabulary for searching documentation

### Key Architecture Documents
- 🏗️ [**EDP Platform Architecture**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/architecture/edp_platform_architecture.md) - High-level platform overview
- 📊 [**Layer Architecture Detailed**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/architecture/edp-layer-architecture-detailed.md) - Specifications for all medallion layers
- 🔐 [**Multi-Tenancy Pattern**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/architecture/patterns/multi-tenancy-architecture.md) - Security pattern for data isolation

### Implementation Guides
- 📘 [**Data Vault 2.0 Guide**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/engineering-knowledge-base/data-vault-2.0-guide.md) - Comprehensive implementation reference
- ⚙️ [**Environment Configuration**](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/engineering-knowledge-base/environment-database-configuration.md) - Database and environment setup

### Business Rules by Domain
- 🤝 [**Broker Rules**](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules/broker) - Producer/broker business logic
- 📋 [**Claims Rules**](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules/claims) - Claims processing and adjudication
- 💰 [**Financial Rules**](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules/financial) - Premium billing and accounting
- 👥 [**Membership Rules**](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules/membership) - Enrollment and eligibility
- 📦 [**Product Rules**](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules/product) - Plan designs and benefits
- 🏥 [**Provider Rules**](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules/provider) - Network and reimbursement

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
→ Start with [EDP Platform Architecture](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/architecture/edp_platform_architecture.md) - read the Executive Summary section

**"I need technical details about a specific layer..."**
→ See [Layer Architecture Detailed](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/architecture/edp-layer-architecture-detailed.md)

**"I need to understand business rules for my domain..."**
→ Browse [Business Rules folders](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/architecture/rules) by domain

**"I need implementation guidance..."**
→ Check [Engineering Knowledge Base](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/docs/engineering-knowledge-base)

**"I need to find everything about [specific topic]..."**
→ Use the [Documentation Index](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/docs/DOCUMENTATION_INDEX.md) organized by type, domain, and layer

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

1. Review the [Contributing Guide](https://gitlab.yourcompany.com/edp/architecture-docs#-contributing-and-updating-documentation) in GitLab
2. Create a feature branch for your changes
3. Follow the [Documentation Quality Checklist](https://gitlab.yourcompany.com/edp/architecture-docs#documentation-quality-checklist)
4. Submit a merge request for review

---

## 👥 Contact

**EDP Data & Solution Architect:** Dan Brickey

**Questions or feedback?** Contact the EDP Architecture team or submit an issue in GitLab.

---

## 📚 Additional Context

For project context, team structure, and AI collaboration resources, see:
- [CLAUDE.md](https://gitlab.yourcompany.com/edp/architecture-docs/-/blob/main/CLAUDE.md) - Project context and team information
- [AI Resources](https://gitlab.yourcompany.com/edp/architecture-docs/-/tree/main/ai-resources) - AI tools and prompt templates

---

**Last Updated:** 2025-10-16
**Maintained By:** Dan Brickey, EDP Data & Solution Architect

---

## 🔖 Page Labels

`edp` `architecture` `data-platform` `documentation` `data-vault` `snowflake` `analytics`
