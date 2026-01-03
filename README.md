# Exocortex

**Your external cognitive layer** - A multi-domain personal knowledge base combining work, career, personal, and educational content with AI-augmented workflows.

---

## Structure

```
exocortex/
├── work/                       # Professional domains
│   ├── bci/                    # Blue Cross of Idaho (current employer)
│   ├── career/                 # Cross-employer career management
│   └── _archive/               # Previous employers
│
├── personal/                   # Personal life
│   ├── journal/                # Daily journaling
│   ├── reviews/                # Weekly/monthly reviews
│   ├── philosophy/             # Philosophy notes
│   ├── gifts/                  # Gift planning
│   └── media/                  # Personal media
│
├── education/                  # Learning & development
│   ├── masters-applied-ai/     # UVU Masters program
│   └── self-study/             # Self-directed learning
│
├── shared/                     # Cross-domain resources
│   ├── ai-resources/           # Prompts, skills, workflows
│   └── reference/              # Reference documents
│
└── _archive/                   # Migration reference (temporary)
```

---

## Domains

### 🏢 Work (`work/`)

**Current**: Blue Cross of Idaho (BCI)
- EDP architecture and Data Vault implementation
- Meeting notes, projects, engineering knowledge
- AI transformation workflows

**Career**: Cross-employer professional development
- Resume, portfolio, career goals
- Skills assessments
- Job search materials

### 🏠 Personal (`personal/`)

Private life content:
- Daily journaling and reviews
- Philosophy and personal development
- Gift planning and personal media

### 📚 Education (`education/`)

Learning and development:
- Formal education (Masters in Applied AI)
- Self-study notes and courses
- Certifications and skill building

### 🔧 Shared (`shared/`)

Cross-domain tools:
- AI prompts and skill packages
- Reference documents
- Templates

---

## AI Context Switching

This repository uses `.cursorrules` to automatically detect and switch between contexts:

- **Work/BCI**: Data Vault, dbt, Snowflake, healthcare data references
- **Career**: Resume, portfolio, job search references
- **Personal**: Journal, goals, philosophy references
- **Education**: Courses, learning, study references

If context is unclear, the AI will ask which domain you're working in.

---

## Quick Start

1. **Open in Cursor** - Context rules are auto-loaded
2. **Start a conversation** - AI will detect your context
3. **Reference files** - Use `@` to include specific documents

### Key Files

| Purpose | Location |
|---------|----------|
| Context switching rules | `.cursorrules` |
| AI instructions | `.ai/instructions.md` |
| BCI Data Vault workflow | `work/bci/projects/ai-transformation/agentic_workflows/` |
| AI prompts | `shared/ai-resources/prompts/` |

---

## Security Notes

- **Work content**: May reference BCI internal systems - no PHI or sensitive data in repo
- **Sync pattern**: See `work/bci/projects/ai-transformation/agentic_workflows/bci_data_vault_design_workflow/sync/` for cross-perimeter sync process
- **Personal content**: Private - not shared externally

---

## Migration Note

This repository was reorganized from `edp-ai-expert-team` to `exocortex` on 2026-01-03.

See `_archive/STRUCTURE_MIGRATION_MAP.md` for the old→new location mapping.

After verifying everything works (2 weeks), the `_archive/` folder can be deleted.
