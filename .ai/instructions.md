# EDP AI Expert Team Project Context

## Project Overview
This is the EDP AI Expert Team repository - a specialized consulting practice for Enterprise Data Platform migration and modernization work combining human expertise with AI-powered collaboration.

## Key Project Files for Context
- **README.md** - Main project overview and structure
- **ai-resources/context-documents/edp-architecture-baseline.md** - Technical architecture context
- **ai-resources/context-documents/edp-work-plan-breakdown.md** - Project work breakdown
- **docs/engineering-knowledge-base/data-vault-2.0-guide.md** - Technical implementation guide


- **EDP Data and Solution Architect**: Dan Brickey, (AKA me)

## Others I collaborate with that I take direction from or have oversight on what I am doing.
- **CIO**: David Yoo
- **Director of Data and Analytics**: Ram Garimella
- **EDP Program Manager**: Linsey Smith
- **Enterprise Architect**: Sani Messenger
- **Enterprise Architect**: Dom Desimini
- **Enterprise Architect**: Rich Tallon

## BCI Teams I collaborate with that I have architectural oversight on:

### **EDP Data Domains Team: data engineering for raw vault, business vault, and dimensional model**
- Currently not staffed during Q4 2025

### **EDP Admin Team: snowflake config, RBAC, **
- **Product Owner**: Sam Schrader
- **Scrum Coach**: Emmanuel Obaze
- **Hakkoda - Architect**: Emily Sowder
- **Snowflake Admin**: Ian Truslow
- **Snowflake/AWS Admin**: Mike Bills
- **Hakkoda - Architect**: Martin Rivera

### **EDP Ingestion Team**
- **Delivery Team Manager - Ingestion**: Kelly Good Clark
- **Data Engineer - Ingestion**: James Hicks
- **Data Engineer - Ingestion**: Pei-Chi Liu

### **EDP OneView Team**
- **Product Owner - OneView**: Jesse Ahern
- **Data Engineer - OneView**: Shreya Thacker
- **Data Engineer - OneView**: Jason Seger

### **EDP Extracts Team**
- **Product Owner - Extracts**: Carl Morse
- **Data Engineer - Extracts**: Amith Kishore
- **Data Engineer - Extracts**: Brad Georgeson

## BCI Teams I collaborate with or advise outside the EDP solution

### **HDS Team (On-prem DW)**
- **Manager - HDS**: Rob Hopper
- **Data Engineer - HDS**: Cameron Gilbert
- **Data Engineer - HDS**: Brian Dix
- **Data Engineer - HDS**: Cathy Rexrode
- **Data Engineer - HDS**: Alex Opoiyo
- **Data Engineer - HDS**: Hawk Yi

## Business Partners I collaborate with
- **Hakkoda**: Architecture and implementation guidance for the EDP
- **Abacus**: Interop partner for cloud data, EDP and some CMS feeds for now

## Other Contractors I collaborate with regularly
- **Hakkoda - Architect**: Odell Ordonez
- **Abacus - Program Manager**: Lorraine Maldonado
- **Abacus - Architect**: Satish Dhanasekar

## Repository Structure
- `ai-resources/` - AI Tools, Context & Prompts
- `code/` - code repo structures echoed from sources and/or targets as needed
- `docs/` - Documentation & Knowledge Base

## Document Standards
- Frontmatter with timestamps, versions, authors, audience
- Cascade updates from detail → folder README → parent
- Commit changes together

## Auto-Import Context Files
@docs\architecture\edp-project-overview.md
@docs\architecture\edp_platform_architecture.md
@docs\architecture\edp-layer-architecture-detailed.md
@docs\architecture\project-roadmap.md
@docs\engineering-knowledge-base\environment-database-configuration.md

For additional context including architecture patterns, business rules, and standards, see [.ai/context.md](.ai/context.md).

## EDP Data Domains - dbt Implementation Context

### Project Structure
The `code/repositories/edp-data-domains/` folder contains the main dbt project for Data Vault 2.0 implementation.

**Main dbt Project: `edp-data-domains/`**
- **Purpose**: Core Data Vault 2.0 implementation for Enterprise Data Platform
- **Architecture**: Medallion pattern with Raw → Integration → Curation → Consumption layers
- **Platform**: Snowflake on AWS using dbt Cloud and automate_dv package

**Layer Organization:**
- `models/integration/dv_staging/` - Source staging and renaming for Data Vault
- `models/integration/dv_raw_vault/` - Hubs, Links, Satellites, and Current Views
- `models/curation/biz_vault/` - Business Vault with calculations and business rules
- `models/curation/edw3/` - Existing 3NF models being refactored
- `models/consumption/` - Information marts and dimensional models
- `models/common/` - Shared macros and reference tables

### Platform Architecture
- **Cloud Platform**: AWS
- **Data Warehouse**: Snowflake
- **Transformation Tool**: dbt Cloud
- **Data Vault Package**: automate_dv (automateDV)
- **Visualization**: Tableau Cloud
- **Data Quality**: Anomalo
- **Data Governance**: Alation

### Source Systems
- **Legacy FACETS** (`legacy_facets`) - Historical claims and member data
- **Gemstone FACETS** (`gemstone_facets`) - Current operational system
- **VALENZ** (`valenz`) - Additional data source

### Data Vault Naming Conventions
- **Hubs**: `h_<entity>` (e.g., `h_member`, `h_provider`)
- **Links**: `l_<entity1>_<entity2>` (e.g., `l_member_provider`)
- **Satellites**: `s_<entity>_<source>` (e.g., `s_member_legacy_facets`)
- **Current Views**: `current_<entity>` (single-source, latest records)
- **Business Vault**: `bv_h_<entity>_<purpose>`, `bv_s_<entity>_business`

### Development Workflow for Data Vault Models
1. **Analysis Phase**: Document source analysis in `../analysis/`
2. **Staging**: Create `stg_<entity>_<source>_rename` and `stg_<entity>_<source>` models
3. **Raw Vault**: Generate hubs, links, and satellites using automate_dv
4. **Current Views**: Create business-friendly interfaces to Raw Vault
5. **Business Vault**: Implement calculations and business rules in Curation layer
6. **Information Marts**: Build dimensional models in Consumption layer

### Key Implementation Guidelines
- Use `load_datetime`, `source`, `{entity}_hk`, `{entity}_hashdiff` columns
- Implement Current Views with single-source filtering by default
- Support composite business keys and derived expressions
- Follow automate_dv macro conventions for hub/link/satellite generation
- Incremental loading: Hourly with 24-hour overlap for late data

## Architecture Patterns
For detailed implementation patterns, see:
- **Raw Vault Patterns**: `docs/architecture/patterns/raw-vault-patterns.md` - Hub-link-satellite architecture, naming conventions, and healthcare entity patterns for the integration layer
- **Business Vault Patterns**: `docs/architecture/patterns/business-vault-patterns.md` - Business logic, calculations, and healthcare-specific implementations for the curation layer
- **Multi-Tenancy Pattern**: `docs/architecture/patterns/multi-tenancy-architecture.md` - Tenant isolation and security patterns

## Quick References
When working on this project, consider referencing:
1. Expertise prompts from `ai-resources/prompts`
2. Technical context from `ai-resources/context-documents/`
3. Implementation guides from `docs/engineering-knowledge-base/`
4. Project Architecture `docs/architecture`
5. Architecture Patterns `docs/architecture/patterns/`
6. Business Rules `docs/architecture/rules/`
7. Legacy data dictionary: `code/repositories/legacy_data_dictionary.csv`
