# File Rename Instructions

## Overview
This document provides instructions for renaming all markdown files in the repository to lowercase (except README.md files), completing the documentation reorganization.

---

## Quick Start

### Option 1: PowerShell (Recommended for Windows)
```powershell
# From the repository root:
.\rename-to-lowercase.ps1
```

### Option 2: Git Bash
```bash
# From the repository root:
bash rename-to-lowercase.sh
```

### Option 3: Manual Rename
See the "Files to Rename" section below and rename each file individually.

---

## Files to Rename

### Root Level (2 files)
| Current Name | New Name |
|--------------|----------|
| `CLAUDE.md` | `claude.md` |
| `WORK_SYNC_GUIDE.md` | `work-sync-guide.md` |

### AI Resources (11 files)
| Current Name | New Name |
|--------------|----------|
| `ai-resources/prompts/architecture/technical-requirements/requirements-elicitation/SKILL.md` | `skill.md` |
| `ai-resources/prompts/career/CAREER_PATHS_MASTER_LIST.md` | `career-paths-master-list.md` |
| `ai-resources/prompts/development/vibe-coding/SKILL.md` | `skill.md` |
| `ai-resources/prompts/development/vibe-coding/vibe-coding/SKILL.md` | `skill.md` |
| `ai-resources/prompts/documentation/business-doc-evaluator/SKILL.md` | `skill.md` |
| `ai-resources/prompts/meta/agentic-development/SKILL.md` | `skill.md` |
| `ai-resources/prompts/personal/README-therapy.md` | `readme-therapy.md` |
| `ai-resources/prompts/strategy/ai-vendor-evaluation/ai-vendor-evaluation/SKILL.md` | `skill.md` |
| `ai-resources/prompts/utilities/excel-automation/complex-excel-builder/SKILL.md` | `skill.md` |
| `ai-resources/prompts/utilities/excel-editing/xlsx-editor/SKILL.md` | `skill.md` |

### Docs (9 files)
| Current Name | New Name |
|--------------|----------|
| `docs/gift-profiles/PROFILE-INDEX.md` | `profile-index.md` |
| `docs/gift-profiles/PROFILE-TEMPLATE.md` | `profile-template.md` |
| `docs/goals/career-goals/PROMPTS.md` | `prompts.md` |
| `docs/meetings/log/TODO.md` | `todo.md` |
| `docs/work-tracking/ai-transformation/PORTFOLIO_STRATEGY.md` | `portfolio-strategy.md` |
| `docs/work-tracking/ai-transformation/QUICK_START.md` | `quick-start.md` |
| `docs/work-tracking/ai-transformation/UC02_ACTION_PLAN.md` | `uc02-action-plan.md` |
| `docs/work-tracking/ai-transformation/use_cases/uc01_dv_refactor/PROMPTS.md` | `prompts.md` |
| `docs/work-tracking/ai-transformation/use_cases/uc02_edw2_refactor/output/class_type/DELIVERABLES.md` | `deliverables.md` |

**Total: 22 files**

---

## Manual Rename Instructions

If you prefer to rename files manually:

### For Windows (PowerShell or File Explorer)
1. Right-click on the file
2. Select "Rename"
3. Change to lowercase name
4. Press Enter

### For Git Bash or Command Line
For each file, use a two-step rename (required on case-insensitive filesystems):

```bash
# Example for CLAUDE.md
mv CLAUDE.md claude.md.tmp
mv claude.md.tmp claude.md
```

Or use git mv:
```bash
git mv CLAUDE.md claude.md.tmp
git mv claude.md.tmp claude.md
```

---

## After Renaming

### 1. Check Git Status
```bash
git status
```

You should see the renamed files.

### 2. Commit the Changes
```bash
git add -A
git commit -m "Rename all markdown files to lowercase (except README.md)"
```

### 3. Clean Up
After confirming everything works:
```bash
# Delete the rename scripts (optional)
rm rename-to-lowercase.ps1
rm rename-to-lowercase.sh
rm RENAME_INSTRUCTIONS.md
```

---

## Why Lowercase?

1. **Industry Standard** - Lowercase with hyphens is the documentation standard
2. **Web-Friendly** - Better for URLs and GitLab Pages
3. **Cross-Platform** - Works consistently across Windows, Mac, Linux
4. **Professional** - Cleaner, more consistent appearance

---

## Troubleshooting

### "File not found" errors
- Make sure you're in the repository root directory
- Check that the file still exists at that path

### Git shows weird rename behavior
- This is normal on case-insensitive filesystems (Windows, Mac)
- Git will properly track the rename

### Need to undo?
```bash
# If you haven't committed yet:
git checkout .

# If you have committed:
git revert HEAD
```

---

## Questions?

If you encounter any issues with the rename process, review the files listed above and rename them individually using File Explorer or your preferred method.

**All files should be lowercase except `README.md` files** (which maintain their uppercase name by convention).
