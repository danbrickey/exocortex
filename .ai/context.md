# Additional Context for AI Assistants

## Architecture Documentation

All architecture documentation is maintained in `docs/architecture/`:

### Core Architecture
- **Project Overview**: @docs/architecture/edp-project-overview.md - Executive summary, project background, strategic context
- **Platform Architecture**: @docs/architecture/edp_platform_architecture.md - Technical platform details and naming conventions
- **Layer Architecture**: @docs/architecture/edp-layer-architecture-detailed.md - Medallion architecture layers (Raw, Integration, Curation, Consumption)
- **Project Roadmap**: @docs/architecture/project-roadmap.md - Project work breakdown and timeline

### Implementation Patterns
Located in `docs/architecture/patterns/`:
- **Raw Vault Patterns**: Raw Vault implementation for Data Vault 2.0 integration layer
- **Business Vault Patterns**: Business logic and calculations for curation layer
- **Multi-Tenancy Architecture**: Tenant isolation and security patterns

### Business Rules
Domain-specific business rules in `docs/architecture/rules/`:
- **Membership**: Member eligibility, enrollment, coverage rules
- **Provider**: Network management, credentialing, contracts
- **Claims**: Claims processing, adjudication, payment rules
- **Domain Context**: Business domain and bounded context definitions

### Standards
Technical and documentation standards in `docs/architecture/standards/`:
- **Diagramming Standards**: C4/DDD unified architecture diagramming guide

## Engineering Knowledge Base

Technical implementation guides in `docs/engineering-knowledge-base/`:
- **Data Vault 2.0 Guide**: Complete implementation guide for Data Vault methodology
- **Environment Configuration**: Database and environment setup details
- **Best Practices**: Technical standards and conventions

## Project Work Tracking

Active use case documentation in `docs/work_tracking/ai_transformation/use_cases/`:
- **UC01 Data Vault Refactor**: 3NF to Data Vault 2.0 migration
- **UC02 EDW2 Refactor**: WhereScape to dbt migration

Each use case has its own `.ai/instructions.md` for context-specific guidance.

## AI Resources

### Expert Prompts
Specialized prompts for specific tasks in `ai-resources/prompts/`:
- **Documentation Architect**: `@ai-resources/prompts/documentation/arcdoc-documentation-architect.md`
- **Data Vault Architect**: Architecture and modeling guidance
- **Diagram Specialist**: Technical diagram creation and updates
- **Career Tools**: Pitch deck builder, career path planning

### Skills
Custom skills for specialized workflows in `ai-resources/skills/`

## Key Reference Files

- **Legacy Data Dictionary**: `code/repositories/legacy_data_dictionary.csv` - Source system metadata and business context
- **Main README**: Root README.md - Project overview and getting started guide

## Usage Notes

When working on architecture or business rules:
1. Reference the appropriate `docs/architecture/` documents
2. Follow patterns defined in `docs/architecture/patterns/`
3. Use expert prompts from `ai-resources/prompts/` when needed
4. Maintain documentation using the multi-audience format (Executive Summary, Analytical Overview, Technical Architecture, Implementation Details)
