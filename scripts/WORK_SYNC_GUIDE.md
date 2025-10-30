# EDP Documentation Work Sync Guide

> **How to sync your EDP documentation between personal GitHub (with AI) and work environment (GitLab)**

---

## Overview

This guide explains how to maintain your EDP architecture documentation in two locations:
1. **Personal GitHub** (here) - where you can use AI tools freely
2. **Work GitLab** - where your team can access the documentation

## The Complete Workflow

### Phase 1: Initial Setup (One-Time)

#### At Home

1. **Export your documentation**
   ```powershell
   .\scripts\export-docs-for-work.ps1
   ```

2. **Email the zip file** to your work account
   - Look in `.\exports\` folder
   - Email the file named `edp-docs-export_[timestamp].zip`

#### At Work

3. **Extract the zip file** on your work machine

4. **Create GitLab repository**
   - Navigate to your GitLab instance
   - Create new project: `edp-architecture-docs`
   - Visibility: Internal or Private
   - Don't initialize with README (you're providing one)

5. **Import to GitLab**
   ```bash
   cd path/to/extracted/export
   git init
   git add .
   git commit -m "Initial import of EDP architecture documentation"
   git remote add origin https://gitlab.yourcompany.com/edp/architecture-docs.git
   git push -u origin main
   ```

6. **Set up branch protection** (recommended)
   - In GitLab: Settings → Repository → Protected Branches
   - Protect `main` branch
   - Require merge requests for changes

7. **Create Confluence landing page**
   - Create new Confluence page: "EDP Architecture Documentation"
   - Copy content from `docs/CONFLUENCE_LANDING_PAGE.md`
   - **Important:** Replace all `https://gitlab.yourcompany.com/edp/architecture-docs` URLs with your actual GitLab repository URL
   - Publish the page
   - Share with your team

### Phase 2: Regular Updates

#### At Home (Weekly or As Needed)

1. **Work on documentation** with AI assistance
   - Use Claude Code or other AI tools
   - Update architecture docs
   - Capture business rules
   - Braindump processing

2. **Commit changes** to your local GitHub repo
   ```bash
   git add .
   git commit -m "Update claims processing architecture"
   git push
   ```

3. **Export for work**
   ```powershell
   .\scripts\export-docs-for-work.ps1
   ```

4. **Email zip to work account**

#### At Work

5. **Extract new export**

6. **Review changes**
   - Open `EXPORT_CHANGELOG.md`
   - Review recent commits and changes

7. **Update GitLab repository**
   ```bash
   cd path/to/your/gitlab/repo

   # Copy updated files from export
   cp -r path/to/export/docs/* ./docs/
   cp path/to/export/README.md ./
   cp path/to/export/CLAUDE.md ./

   # Commit and push
   git add .
   git commit -m "Documentation update - [brief description of changes]"
   git push
   ```

8. **Confluence stays current** (no changes needed - it links to GitLab)

---

## Key Files You Created

### 1. README.md
- **Purpose:** Root-level overview for GitLab repository
- **Location:** Repository root
- **Audience:** All team members visiting the GitLab repo
- **Contains:** Navigation, quick links, documentation standards, team contacts

### 2. docs/CONFLUENCE_LANDING_PAGE.md
- **Purpose:** Template for Confluence page that links to GitLab
- **Location:** Inside docs/ folder
- **Audience:** Team members discovering docs via Confluence search
- **Action Required:** Update all GitLab URLs to match your actual instance
- **Usage:** Copy content to create Confluence page (one-time setup)

### 3. scripts/export-docs-for-work.ps1
- **Purpose:** Automated export script for syncing to work
- **Location:** scripts/ folder
- **Audience:** You (Dan)
- **Usage:** Run whenever you want to sync changes to work
- **Output:** Timestamped zip file ready to email

### 4. scripts/README.md
- **Purpose:** Documentation for using the export script
- **Location:** scripts/ folder
- **Contains:** Usage examples, parameters, troubleshooting

---

## Quick Reference Commands

### Export Documentation (at home)
```powershell
# Standard export
.\scripts\export-docs-for-work.ps1

# Include AI resources
.\scripts\export-docs-for-work.ps1 -IncludeAIResources

# Custom location
.\scripts\export-docs-for-work.ps1 -ExportPath "C:\Temp\exports"
```

### Update GitLab (at work)
```bash
# Navigate to your GitLab repo
cd ~/edp-architecture-docs

# Copy updated files from export
cp -r ~/Downloads/extracted-export/docs/* ./docs/
cp ~/Downloads/extracted-export/README.md ./
cp ~/Downloads/extracted-export/CLAUDE.md ./

# Commit and push
git add .
git commit -m "Documentation update from [date]"
git push
```

---

## Decision Tree: Where Should I Work?

### Work At Home (Personal GitHub) When:
- ✅ You need AI assistance (Claude Code, ChatGPT, etc.)
- ✅ You're doing braindump processing
- ✅ You're capturing new architecture patterns
- ✅ You want to experiment with structure
- ✅ You need to iterate quickly

### Work At Work (GitLab) When:
- ✅ Team members need to collaborate on documentation
- ✅ You're capturing input from meetings/discussions
- ✅ Subject matter experts are contributing business rules
- ✅ You need formal review/approval process
- ✅ Documentation needs immediate team visibility

### Sync Frequency Recommendations

**Weekly Sync:** Default for steady documentation development

**Daily Sync:** During intensive documentation sprints or when team needs daily updates

**As-Needed Sync:** For mature documentation with infrequent changes

---

## Troubleshooting

### "PowerShell execution policy prevents running script"
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### "Email attachment too large"
- The export should be <5MB typically
- Consider `-IncludeAIResources:$false` to reduce size
- Use file sharing service if email blocks attachments

### "GitLab URLs broken in Confluence"
- Edit Confluence page
- Find/replace `https://gitlab.yourcompany.com/edp/architecture-docs` with your actual URL
- Your actual URL format might be different - check your GitLab instance

### "Team can't find documentation"
- Ensure Confluence landing page is published and not in draft
- Add page labels: `edp`, `architecture`, `documentation`
- Share Confluence link in team channels
- Pin to team Confluence space homepage

### "Merge conflicts in GitLab"
- This happens if multiple people edit same files
- Coordinate documentation updates
- Use feature branches for major changes
- Discuss at team sync if conflicts are frequent

---

## Best Practices

### Documentation Hygiene
- ✅ Always run export script AFTER committing to GitHub
- ✅ Review EXPORT_CHANGELOG.md before importing to work
- ✅ Verify no PHI/PII before first team share
- ✅ Keep personal GitHub and work GitLab in sync weekly

### Collaboration
- ✅ Announce documentation updates in team channels
- ✅ Link to specific docs in GitLab when discussing in Slack/Teams
- ✅ Accept team contributions via GitLab merge requests
- ✅ Use GitLab issues for documentation feedback

### Version Control
- ✅ Use descriptive commit messages
- ✅ Keep changes focused (don't bundle unrelated updates)
- ✅ Preserve export archives locally as backup snapshots
- ✅ Tag major documentation releases in GitLab

---

## Team Communication Template

When sharing documentation with your team for the first time:

```
Subject: EDP Architecture Documentation Now Available

Hi Team,

I've set up our official EDP architecture documentation repository. This includes:
- Platform architecture overview
- Layer-by-layer specifications
- Business rules by domain
- Data Vault 2.0 implementation guide
- Multi-tenancy patterns

📚 Access: [Confluence Landing Page Link]

The documentation is organized for multiple audiences (executives to engineers) with progressive disclosure - start at your level and drill down as needed.

Quick links:
- Documentation Index: [GitLab Link]
- Platform Overview: [GitLab Link]
- Your Domain Rules: [GitLab Link]

Questions? Let me know!

- Dan
```

---

## Future Enhancements (Optional)

Consider these improvements over time:

1. **GitLab CI/CD Pipeline**
   - Automated link checking
   - PHI/PII scanning
   - Markdown linting

2. **Automated Sync**
   - If you can access GitLab from home: dual remotes
   - Eliminates manual export/import

3. **GitLab Pages**
   - Static site generation from markdown
   - Alternative to Confluence for web viewing

4. **Documentation Dashboard**
   - Confluence macro showing documentation stats
   - Recent updates feed

---

**Questions or Issues?**

Contact: Dan Brickey, EDP Data & Solution Architect

---

**Version:** 1.0.0
**Created:** 2025-10-16
**Last Updated:** 2025-10-16
