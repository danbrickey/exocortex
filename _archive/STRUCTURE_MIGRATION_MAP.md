# Structure Migration Map

**Migration Date**: 2026-01-03
**From**: `edp-ai-expert-team` structure
**To**: `exocortex` multi-domain structure

## Migration Summary

This document maps the old folder structure to the new locations. Keep for reference during transition period (recommended: 2 weeks), then delete `_archive/` folder.

---

## Old → New Location Mapping

### Work/BCI Content

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `docs/architecture/` | `work/bci/architecture/` | BCI EDP architecture |
| `docs/engineering-knowledge-base/` | `work/bci/engineering-kb/` | Data Vault, Snowflake guides |
| `docs/glossaries/` | `work/bci/glossaries/` | Terminology docs |
| `docs/goals/bci-goals/` | `work/bci/goals/` | BCI work goals |
| `docs/meetings/` | `work/bci/meetings/` | Meeting notes, transcripts |
| `docs/work-tracking/` | `work/bci/projects/` | Work tracking, AI transformation |
| `docs/sources/` | `work/bci/sources/` | Data source documentation |
| `docs/imported/` | `work/bci/imported/` | Imported work files |
| `docs/reports/` | `work/bci/reports/` | Performance reports |
| `docs/meta/` | `work/bci/context/` | Meta documentation |

### Career Content

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `docs/goals/career-goals/` | `work/career/goals/` | Career planning (excl. masters) |
| `docs/goals/assessments/` | `work/career/assessments/` | Skills assessments |

### Personal Content

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `docs/personal/philosophy/` | `personal/philosophy/` | Philosophy notes |
| `docs/personal/videos/` | `personal/media/` | Personal media |
| `docs/personal/weekly_reviews/` | `personal/reviews/weekly/` | Weekly reviews |
| `docs/personal/monthly_reviews/` | `personal/reviews/monthly/` | Monthly reviews |
| `docs/gift-profiles/` | `personal/gifts/` | Gift planning |

### Education Content

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `docs/goals/career-goals/masters_applied_ai_uvu/` | `education/masters-applied-ai/` | UVU Masters program |

### Shared Content

| Old Location | New Location | Notes |
|--------------|--------------|-------|
| `ai-resources/` | `shared/ai-resources/` | Prompts, skills |
| `docs/reference/` | `shared/reference/` | Reference documents |
| `docs/documentation-index.md` | `shared/reference/documentation-index.md` | Doc index |
| `docs/taxonomy.md` | `shared/reference/taxonomy.md` | Taxonomy |

---

## New Structure Overview

```
exocortex/
├── work/
│   ├── bci/                    # Blue Cross of Idaho
│   │   ├── architecture/
│   │   ├── engineering-kb/
│   │   ├── glossaries/
│   │   ├── goals/
│   │   ├── meetings/
│   │   ├── projects/           # Was work-tracking
│   │   ├── sources/
│   │   ├── imported/
│   │   ├── reports/
│   │   └── context/
│   ├── career/
│   │   ├── goals/
│   │   ├── portfolio/
│   │   ├── resume/
│   │   └── assessments/
│   └── _archive/               # Future: previous employers
│
├── personal/
│   ├── journal/
│   ├── reviews/
│   │   ├── weekly/
│   │   └── monthly/
│   ├── philosophy/
│   ├── gifts/
│   └── media/
│
├── education/
│   ├── masters-applied-ai/
│   └── self-study/
│
├── shared/
│   ├── ai-resources/
│   ├── glossaries/
│   ├── templates/
│   └── reference/
│
└── _archive/                   # This folder - delete after 2 weeks
```

---

## Key Context Files Updated

| File | Updates Made |
|------|--------------|
| `.cursorrules` | Multi-domain context switching |
| `.ai/instructions.md` | Needs path updates |
| `README.md` | Needs rewrite for new structure |

---

## Cleanup Checklist

After 2 weeks, if everything is working:

- [ ] Verify all links/references work
- [ ] Confirm no broken imports
- [ ] Delete `_archive/` folder
- [ ] Delete empty `docs/` folder remnants
- [ ] Delete empty `ai-resources/` folder
- [ ] Update any external references to old paths

---

## Rollback

If needed, the git history preserves all file locations. To find old content:

```bash
git log --all --full-history -- "docs/[old-path]"
```
