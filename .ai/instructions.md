# Exocortex - AI Assistant Context

## Repository Overview

This is **Exocortex** - a multi-domain personal knowledge base for Dan Brickey, combining:
- **Work**: Current employer (BCI) + career management
- **Personal**: Life planning, journaling, philosophy
- **Education**: Formal and self-directed learning
- **Shared**: AI tools, prompts, and reference materials

## Domain Structure

```
exocortex/
├── work/
│   ├── bci/                    # Blue Cross of Idaho (current)
│   └── career/                 # Cross-employer career
├── personal/                   # Personal life
├── education/                  # Learning & development  
└── shared/                     # Cross-domain resources
```

---

## Work/BCI Context

### Who I Am
- **Role**: EDP Data and Solution Architect at Blue Cross of Idaho
- **Focus**: Data Vault 2.0 implementation, AI transformation

### Key Collaborators

**Leadership**:
- CIO: David Yoo
- Director of Data and Analytics: Ram Garimella
- EDP Program Manager: Linsey Smith
- Enterprise Architects: Sani Messenger, Dom Desimini, Rich Tallon

**Teams I oversee architecturally**:
- EDP Data Domains (Data Vault implementation)
- EDP Admin (Snowflake config, RBAC)
- EDP Ingestion, OneView, Extracts teams

### Technical Stack
- **Platform**: Snowflake on AWS
- **Transformation**: dbt Cloud with automate_dv package
- **Visualization**: Tableau Cloud
- **Data Quality**: Anomalo
- **Governance**: Alation

### Data Vault Conventions
- **Hubs**: `h_<entity>`
- **Links**: `l_<entity1>_<entity2>`
- **Satellites**: `s_<entity>_<source>`
- **Current Views**: `current_<entity>`
- **Business Vault**: `bv_h_<entity>_<purpose>`

### BCI-Specific References
- Architecture: `work/bci/architecture/`
- Engineering KB: `work/bci/engineering-kb/`
- Projects: `work/bci/projects/`
- Glossaries: `work/bci/glossaries/`

---

## Work/Career Context

Cross-employer career management:
- Goals: `work/career/goals/`
- Portfolio: `work/career/portfolio/`
- Resume: `work/career/resume/`
- Assessments: `work/career/assessments/`

---

## Personal Context

Private life content in `personal/`:
- Journal, reviews, philosophy, gifts, media

---

## Education Context

Learning content in `education/`:
- Masters in Applied AI (UVU): `education/masters-applied-ai/`
- Self-study: `education/self-study/`

---

## Shared Resources

Available across all domains:
- AI prompts: `shared/ai-resources/prompts/`
- Skills: `shared/ai-resources/skills/`
- Reference: `shared/reference/`

---

## Document Standards

- Frontmatter with timestamps, versions, authors
- Cascade updates from detail → folder README → parent
- Commit related changes together

---

## Security Awareness

- Never include credentials, tokens, or secrets
- BCI content: No PHI, respect security perimeter
- Sync pattern for cross-perimeter sharing: See `work/bci/projects/ai-transformation/agentic_workflows/bci_data_vault_design_workflow/sync/`
