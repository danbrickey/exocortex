   # EDP Architecture Documentation

   > **Official documentation repository for Blue Cross of Idaho's Enterprise Data Platform (EDP) project**

   [![GitLab](https://img.shields.io/badge/GitLab-Documentation-orange?logo=gitlab)](https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs)
   [![Snowflake](https://img.shields.io/badge/Snowflake-EDP-29B5E8?logo=snowflake)](https://www.snowflake.com/)

   ---

   ## 📖 Welcome

   This repository contains comprehensive architecture documentation, business rules, and implementation guides for the Enterprise Data Platform. The documentation is designed for **multi-audience access** with layered content that serves executives, analysts, architects, and engineers.

   **This is a documentation-first repository.** All content is maintained in markdown format with version control, collaborative editing via merge requests, and AI-optimized structure for intelligent navigation.

   ---

   ## 🚀 Quick Start

   ### New to EDP?
   Start here to understand the platform:
   1. [EDP Platform Architecture](architecture/edp_platform_architecture.md) - High-level overview (start with Executive Summary)
   2. [Layer Architecture Detailed](architecture/edp-layer-architecture-detailed.md) - Technical specifications for all data layers
   3. [Data Vault 2.0 Guide](engineering-knowledge-base/data-vault-2.0-guide.md) - Implementation methodology

   ### Looking for Specific Information?
   - **Business Rules by Domain** → See [Business Rules](#-business-rules-by-domain) section below
   - **Implementation Guidance** → Browse [Engineering Knowledge Base](#-engineering--implementation-guides)
   - **Search Everything** → Use [Documentation Index](DOCUMENTATION_INDEX.md) or [Taxonomy Guide](TAXONOMY.md)

   ### Contributing Documentation?
   See our [Contributing Guide](#-contributing-and-updating-documentation) below.

   ---

   ## 📚 Documentation Structure

   ### Navigation Methods

   This repository provides multiple ways to find information:

   | Method | Best For | Link |
   |--------|----------|------|
   | **Documentation Index** | Comprehensive catalog by type, domain, and layer | [DOCUMENTATION_INDEX.md](DOCUMENTATION_INDEX.md) |
   | **Taxonomy Guide** | Controlled vocabulary and search terms | [TAXONOMY.md](TAXONOMY.md) |
   | **Folder Browse** | Exploring related documents | Navigate folders below |
   | **GitLab Search** | Keyword search across all files | Use search bar above |

   ---

   ## 🏗️ Architecture Documentation

   ### Platform Overview
   - [**EDP Platform Architecture**](architecture/edp_platform_architecture.md) - Complete platform design and technical decisions
   - [**Layer Architecture Detailed**](architecture/edp-layer-architecture-detailed.md) - Medallion architecture specifications
   - [**Multi-Tenancy Pattern**](architecture/patterns/multi-tenancy-architecture.md) - Security and data isolation design

   ### Architecture Patterns
   Browse reusable patterns in [architecture/patterns/](architecture/patterns/)

   ---

   ## 📋 Business Rules by Domain

   Domain-specific business logic, calculations, and transformations:

   | Domain | Description | Location |
   |--------|-------------|----------|
   | 🤝 **Broker** | Producer/broker relationships and commissions | [architecture/rules/broker/](architecture/rules/broker) |
   | 📋 **Claims** | Claims processing, adjudication, and payment | [architecture/rules/claims/](architecture/rules/claims) |
   | 💰 **Financial** | Premium billing, accounting, and financial reconciliation | [architecture/rules/financial/](architecture/rules/financial) |
   | 👥 **Membership** | Enrollment, eligibility, and member demographics | [architecture/rules/membership/](architecture/rules/membership) |
   | 📦 **Product** | Plan designs, benefits, and product catalogs | [architecture/rules/product/](architecture/rules/product) |
   | 🏥 **Provider** | Network management, credentialing, and reimbursement | [architecture/rules/provider/](architecture/rules/provider) |

   ---

   ## 🔧 Engineering & Implementation Guides

   Technical how-to guides and reference materials:

   - [**Data Vault 2.0 Guide**](engineering-knowledge-base/data-vault-2.0-guide.md) - Comprehensive implementation reference
   - [**Environment & Database Configuration**](engineering-knowledge-base/environment-database-configuration.md) - Setup and configuration guide
   - [**Naming Conventions**](engineering-knowledge-base/naming-conventions.md) - Standards for database objects
   - [**Development Patterns**](engineering-knowledge-base/) - Browse all guides in this folder

   ---

   ## 🎯 How to Find Information

   ### By Your Need

   **"I need to understand the overall architecture..."**
   → Start with [EDP Platform Architecture](architecture/edp_platform_architecture.md) - read the Executive Summary section

   **"I need technical details about a specific layer..."**
   → See [Layer Architecture Detailed](architecture/edp-layer-architecture-detailed.md)

   **"I need to understand business rules for my domain..."**
   → Browse [Business Rules by Domain](#-business-rules-by-domain) table above

   **"I need implementation guidance..."**
   → Check [Engineering Knowledge Base](#-engineering--implementation-guides)

   **"I need to find everything about [specific topic]..."**
   → Use the [Documentation Index](DOCUMENTATION_INDEX.md) organized by type, domain, and layer

   ### By Document Type

   - **Architecture** - System design, patterns, technical decisions → [architecture/](architecture/)
   - **Business Rules** - Domain-specific logic and calculations → [architecture/rules/](architecture/rules/)
   - **Implementation Guides** - How-to guides and technical references → [engineering-knowledge-base/](engineering-knowledge-base/)
   - **AI Resources** - Prompts and context for AI tools → [ai-resources/](ai-resources/)

   ### By EDP Layer

   - **Raw Layer** - Source system landing zone
   - **Integration Layer** - Data Vault 2.0 raw vault
   - **Curation Layer** - Business vault and dimensional models
   - **Consumption Layer** - Analytics-ready data products

   See [Layer Architecture Detailed](architecture/edp-layer-architecture-detailed.md) for complete specifications.

   ---

   ## 💡 Why This Repository?

   This documentation repository provides:

   ✅ **Version Control** - Track all changes with full history and rollback capability
   ✅ **Markdown Format** - Clean, readable formatting with excellent rendering
   ✅ **Collaborative Editing** - Team members submit updates via merge requests
   ✅ **AI-Optimized Structure** - Taxonomy and indexing for AI-powered navigation
   ✅ **Single Source of Truth** - One authoritative location for all architecture documentation
   ✅ **Cross-References** - Linked documentation creates a knowledge graph

   ---

   ## 🏛️ Documentation Standards

   All architecture documentation in this repository follows a **multi-audience layering** approach:

   1. **Executive Summary** (2-3 min read) - Business context and value proposition
   2. **Analytical Overview** (5-7 min read) - Functional capabilities and requirements
   3. **Technical Architecture** (15-30 min read) - Detailed technical design
   4. **Implementation Specifications** (reference) - Code patterns and deployment details

   **Start at your level of interest and drill down as needed.**

   ### Document Metadata

   All documents include frontmatter with:
   - **Timestamps** - Created and last updated dates
   - **Version** - Semantic versioning
   - **Author** - Document owner
   - **Audience** - Target readers
   - **Status** - Draft, Review, Approved

   ---

   ## 📝 Contributing and Updating Documentation

   ### How to Contribute

   Have documentation updates or new business rules to capture?

   1. **Create a feature branch** for your changes
      ```bash
      git checkout -b feature/your-documentation-update
      ```

   2. **Make your changes** following our standards:
      - Use markdown format
      - Include frontmatter metadata
      - Follow multi-audience layering approach
      - Keep content free of PHI/PII

   3. **Test your changes**
      - Verify markdown renders correctly
      - Check all internal links work
      - Ensure cross-references are accurate

   4. **Submit a merge request** with:
      - Clear description of changes
      - Reason for update
      - Any affected downstream documents

   ### Documentation Quality Checklist

   Before submitting, verify:

   - [ ] Frontmatter is complete and accurate
   - [ ] Document follows multi-audience layering (when applicable)
   - [ ] All links are functional
   - [ ] Content is free of PHI/PII
   - [ ] Examples use sanitized/fictional data
   - [ ] Cross-referenced documents are updated if needed
   - [ ] Folder README.md is updated (if adding new files)
   - [ ] DOCUMENTATION_INDEX.md is updated (for new documents)

   ### Cascade Updates

   When updating documentation:
   1. Update the detail document
   2. Update the folder README.md
   3. Update parent folder documentation as needed
   4. Update DOCUMENTATION_INDEX.md
   5. **Commit all changes together** to maintain consistency

   ---

   ## 🔐 Security and Compliance

   **All documentation in this repository is free of PHI/PII.**

   Examples use sanitized, fictional, or anonymized data only. If you discover any sensitive information in the documentation, please **report it immediately** to Dan Brickey or submit a confidential issue.

   ### Compliance Guidelines

   - Do not include actual member, provider, or employer information
   - Use placeholder IDs (e.g., MEMBER_12345, GROUP_ABC)
   - Sanitize all SQL examples and data samples
   - Redact any internal system details that could pose security risks

   ---

   ## 🤖 AI Resources

   This repository includes AI-optimized resources for intelligent navigation and code generation:

   - [**AI Resources Folder**](ai-resources/) - Prompts, context documents, and tools
   - [**CLAUDE.md**](CLAUDE.md) - Project context for AI assistants
   - [**Taxonomy Guide**](TAXONOMY.md) - Controlled vocabulary for AI search

   ---

   ## 📄 Additional Access Points

   ### Confluence Landing Page
   For quick access from within Confluence, see the **EDP Architecture Documentation** page in your space.

   ### Local Development
   To work with this repository locally:

   ```bash
   # Clone the repository
   git clone https://gitlab.com/bluecross-of-idaho/site-reliability/snowflake/edp-architecture-docs.git

   # Navigate to the repository
   cd edp-architecture-docs

   # View documentation in your favorite markdown viewer
   # Recommended: VS Code with Markdown Preview Enhanced extension
   ```

   ---

   ## 👥 Team and Contact

   **EDP Data & Solution Architect:** Dan Brickey

   **Questions or feedback?**
   - Contact the EDP Architecture team
   - Submit an issue in GitLab
   - Create a merge request with suggested improvements

   ### Key Stakeholders
   - **CIO:** David Yoo
   - **Director of Data and Analytics:** Ram Garimella
   - **EDP Program Manager:** Linsey Smith
   - **Enterprise Architects:** Sani Messenger, Dom Desimini, Rich Tallon

   ---

   ## 🔖 Repository Tags

   `edp` `enterprise-data-platform` `architecture` `documentation` `data-vault` `snowflake` `analytics` `blue-cross-idaho` `healthcare-data`

   ---

   ## 📅 Maintenance

   **Last Updated:** 2025-10-22
   **Maintained By:** Dan Brickey, EDP Data & Solution Architect
   **Review Cycle:** Quarterly or as needed for significant platform changes

   ---

   ## 📖 Quick Reference

   | I Want To... | Go Here |
   |--------------|---------|
   | Understand the platform | [EDP Platform Architecture](architecture/edp_platform_architecture.md) |
   | Find business rules | [Business Rules by Domain](#-business-rules-by-domain) |
   | Get implementation guidance | [Engineering Knowledge Base](#-engineering--implementation-guides) |
   | Search all documentation | [Documentation Index](DOCUMENTATION_INDEX.md) |
   | Learn Data Vault 2.0 | [Data Vault Guide](engineering-knowledge-base/data-vault-2.0-guide.md) |
   | Understand multi-tenancy | [Multi-Tenancy Pattern](architecture/patterns/multi-tenancy-architecture.md) |
   | Configure environments | [Environment Configuration](engineering-knowledge-base/environment-database-configuration.md) |
   | Contribute documentation | [Contributing Guide](#-contributing-and-updating-documentation) |

   ---

   **Welcome to the EDP Architecture Documentation. Let's build something great together.**
