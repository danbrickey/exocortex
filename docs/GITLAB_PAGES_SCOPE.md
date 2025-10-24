# GitLab Pages Implementation - Scope and Effort Estimate

**Repository:** edp-architecture-docs
**Prepared By:** Dan Brickey
**Date:** 2025-10-22
**Purpose:** Evaluate the effort and value of implementing GitLab Pages for documentation

---

## Executive Summary

GitLab Pages would transform your markdown documentation repository into a polished, website-like documentation portal. The current setup already provides good documentation access via rendered markdown in GitLab. GitLab Pages would enhance the reader experience with cleaner navigation, search, and a more professional appearance.

**Estimated Effort:** 4-8 hours for initial setup, 1-2 hours for maintenance per quarter
**Value:** Medium to High (depends on audience and frequency of access)
**Complexity:** Medium (requires CI/CD configuration and static site generator setup)

---

## What is GitLab Pages?

GitLab Pages is a feature that publishes static websites directly from your GitLab repository. For documentation, this means:

- **Website-like interface** instead of repository file view
- **Built-in search functionality** across all documentation
- **Clean navigation** with sidebar menus and breadcrumbs
- **Custom themes** (e.g., Read the Docs, Material, GitBook style)
- **Automatic deployment** on every merge to main branch
- **Optional custom domain** (e.g., edp-docs.bcidaho.com)

### What It Looks Like

**Current Experience (GitLab Blob View):**
```
[GitLab Header with Repo Nav]
[File Tree Sidebar]
[Markdown Content - Rendered]
[Commit History / Edit Buttons]
```

**GitLab Pages Experience:**
```
[Clean Documentation Site Header]
[Searchable Sidebar Navigation]
[Full-Width Markdown Content]
[No Repository Chrome]
```

---

## Implementation Options

### Option 1: MkDocs Material (Recommended)

**What It Is:** A popular static site generator optimized for technical documentation with a modern, Material Design theme.

**Pros:**
- Beautiful, professional appearance
- Built-in search
- Mobile responsive
- Excellent navigation with sidebar
- Wide adoption in tech industry
- Easy configuration via YAML

**Cons:**
- Requires Python
- Needs mkdocs.yml configuration file
- Folder structure may need slight adjustments

**Effort:** 6-8 hours
- Setup MkDocs: 1 hour
- Configure theme and navigation: 2-3 hours
- Create GitLab CI/CD pipeline: 2 hours
- Test and adjust: 1-2 hours

**Example Sites:**
- Snowflake documentation style
- Kubernetes docs style

### Option 2: Docusaurus

**What It Is:** Facebook's documentation framework, used by major tech companies.

**Pros:**
- React-based, highly customizable
- Excellent search
- Versioning support
- i18n support

**Cons:**
- More complex setup
- Requires Node.js
- Steeper learning curve

**Effort:** 8-12 hours

### Option 3: Jekyll (GitLab Default)

**What It Is:** Simple static site generator, default for GitLab Pages.

**Pros:**
- Native GitLab Pages support
- Simple setup
- Ruby-based

**Cons:**
- Less polished for documentation
- Limited documentation-specific features
- Older technology

**Effort:** 4-6 hours

### Option 4: Hugo

**What It Is:** Fast, flexible static site generator.

**Pros:**
- Very fast builds
- Powerful theming
- Go-based (single binary)

**Cons:**
- Theme configuration can be complex
- Documentation themes less mature than MkDocs

**Effort:** 6-8 hours

---

## Recommended Approach: MkDocs Material

### Phase 1: Initial Setup (6-8 hours)

#### 1. Install MkDocs and Dependencies (1 hour)

Create `requirements.txt` in repository root:
```txt
mkdocs>=1.5.0
mkdocs-material>=9.0.0
mkdocs-awesome-pages-plugin
pymdown-extensions
```

#### 2. Create MkDocs Configuration (2-3 hours)

Create `mkdocs.yml` in repository root:
```yaml
site_name: EDP Architecture Documentation
site_description: Enterprise Data Platform Architecture and Business Rules
site_author: Blue Cross of Idaho - EDP Team
site_url: https://bluecross-of-idaho.gitlab.io/site-reliability/snowflake/edp-architecture-docs/

theme:
  name: material
  features:
    - navigation.tabs
    - navigation.sections
    - navigation.expand
    - navigation.top
    - search.suggest
    - search.highlight
    - content.code.copy
  palette:
    scheme: default
    primary: blue
    accent: light-blue

plugins:
  - search
  - awesome-pages

markdown_extensions:
  - pymdownx.highlight
  - pymdownx.superfences
  - pymdownx.tabbed
  - admonition
  - tables
  - toc:
      permalink: true

nav:
  - Home: README.md
  - Getting Started:
    - Documentation Index: DOCUMENTATION_INDEX.md
    - Taxonomy: TAXONOMY.md
  - Architecture:
    - Platform Overview: architecture/edp_platform_architecture.md
    - Layer Architecture: architecture/edp-layer-architecture-detailed.md
    - Patterns: architecture/patterns/
  - Business Rules:
    - Broker: architecture/rules/broker/
    - Claims: architecture/rules/claims/
    - Financial: architecture/rules/financial/
    - Membership: architecture/rules/membership/
    - Product: architecture/rules/product/
    - Provider: architecture/rules/provider/
  - Engineering:
    - Data Vault 2.0: engineering-knowledge-base/data-vault-2.0-guide.md
    - Environment Config: engineering-knowledge-base/environment-database-configuration.md
  - AI Resources: ai-resources/
```

#### 3. Create GitLab CI/CD Pipeline (2 hours)

Create `.gitlab-ci.yml` in repository root:
```yaml
image: python:3.11

pages:
  stage: deploy
  script:
    - pip install -r requirements.txt
    - mkdocs build --strict --verbose --site-dir public
  artifacts:
    paths:
      - public
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

test:
  stage: test
  script:
    - pip install -r requirements.txt
    - mkdocs build --strict --verbose
  rules:
    - if: $CI_COMMIT_BRANCH != $CI_DEFAULT_BRANCH
```

#### 4. Test and Deploy (1-2 hours)

- Test locally: `mkdocs serve`
- Push to GitLab
- Verify Pages deployment
- Fix any issues with navigation or links

### Phase 2: Enhancement (Optional, 2-4 hours)

- Add custom logo and branding
- Configure advanced search
- Add version selector (if needed)
- Implement custom domain
- Add social links
- Configure analytics (if desired)

---

## Effort Breakdown

### Initial Setup
| Task | Time | Complexity |
|------|------|------------|
| Install and configure MkDocs | 1 hour | Low |
| Create navigation structure | 2-3 hours | Medium |
| Setup GitLab CI/CD pipeline | 2 hours | Medium |
| Test and troubleshoot | 1-2 hours | Low-Medium |
| **Total Initial Setup** | **6-8 hours** | **Medium** |

### Ongoing Maintenance
| Task | Frequency | Time per Instance |
|------|-----------|-------------------|
| Update navigation for new docs | Per new doc | 5-10 minutes |
| Adjust theme/styling | As needed | 30-60 minutes |
| Troubleshoot build issues | Rare | 15-30 minutes |
| **Estimated Quarterly** | **Every 3 months** | **1-2 hours** |

---

## Value Assessment

### High Value If...

✅ **Documentation is accessed frequently by non-technical stakeholders**
- Executives, business analysts, product owners
- External partners (Hakkoda, Abacus)
- New team members onboarding

✅ **You want to improve discoverability**
- Built-in search across all documentation
- Better navigation structure
- More professional presentation

✅ **You plan to grow the documentation significantly**
- More domains, more business rules
- Multi-version documentation
- International/multi-language support

✅ **You want a public-facing documentation site**
- Share with external consultants
- Reference in presentations
- Professional external branding

### Lower Value If...

❌ **Primary audience is technical and comfortable with GitLab**
- Developers already use GitLab daily
- Documentation is primarily internal reference
- Small, stable documentation set

❌ **Limited time for setup and maintenance**
- Small team with competing priorities
- Documentation changes infrequently
- Current solution "good enough"

❌ **Documentation is highly sensitive**
- Concerns about Pages being too public
- Strict access controls required
- (Note: GitLab Pages can be made private, but requires configuration)

---

## Comparison: Current vs GitLab Pages

| Feature | Current (GitLab Blob) | GitLab Pages (MkDocs) |
|---------|----------------------|----------------------|
| **Markdown Rendering** | ✅ Good | ✅ Excellent |
| **Navigation** | ⚠️ File tree only | ✅ Sidebar + tabs + search |
| **Search** | ⚠️ File search only | ✅ Full-text content search |
| **Professional Look** | ⚠️ Repository interface | ✅ Clean documentation site |
| **Mobile Experience** | ⚠️ Functional | ✅ Optimized |
| **External Sharing** | ⚠️ Requires GitLab access | ✅ Can be public or private |
| **Setup Effort** | ✅ Zero (already done) | ⚠️ 6-8 hours initial |
| **Maintenance** | ✅ Minimal | ⚠️ 1-2 hours/quarter |
| **Version Control** | ✅ Same | ✅ Same |
| **Deployment** | ✅ Instant | ✅ Automated (2-3 min) |

---

## Recommendation

### Recommended Path: Staged Approach

**Now (This Week):**
1. ✅ Deploy improved README.md to GitLab (completed above)
2. ✅ Update Confluence landing page with corrected links (completed above)
3. ⏳ **Evaluate feedback** on current documentation access

**Later (Next Quarter - If Valuable):**
1. Implement MkDocs Material with GitLab Pages
2. Start with basic navigation
3. Enhance based on user feedback

### Why Wait?

1. **Validate Need:** See if improved README.md addresses user pain points
2. **Prioritize Value:** Ensure 6-8 hour investment aligns with documentation usage
3. **Resource Allocation:** Schedule during lower-priority period
4. **Gather Requirements:** Collect specific needs from stakeholders

### When to Proceed with GitLab Pages

Proceed if you answer "yes" to 2+ of these:

- [ ] Non-technical stakeholders access documentation weekly
- [ ] Users complain about finding information
- [ ] You're presenting documentation to external partners
- [ ] You plan to add 20+ new documents in next 6 months
- [ ] Leadership has requested more professional documentation
- [ ] You have 8 hours available for initial setup

---

## Quick Start Guide (If You Decide to Proceed)

### Prerequisites
- Python 3.11+ installed locally
- GitLab runner available (usually already configured)
- Write access to repository

### Steps

1. **Create Feature Branch**
   ```bash
   git checkout -b feature/gitlab-pages-setup
   ```

2. **Add MkDocs Files**
   - Create `requirements.txt` (see above)
   - Create `mkdocs.yml` (see above)
   - Create `.gitlab-ci.yml` (see above)

3. **Test Locally**
   ```bash
   pip install -r requirements.txt
   mkdocs serve
   # Open http://127.0.0.1:8000
   ```

4. **Push and Deploy**
   ```bash
   git add requirements.txt mkdocs.yml .gitlab-ci.yml
   git commit -m "Add GitLab Pages with MkDocs Material"
   git push origin feature/gitlab-pages-setup
   # Create merge request
   # Merge to main
   # Wait 2-3 minutes for Pages deployment
   ```

5. **Access Your Site**
   - URL: `https://bluecross-of-idaho.gitlab.io/site-reliability/snowflake/edp-architecture-docs/`
   - Update Confluence landing page with new URL

---

## Alternatives to Consider

### Alternative 1: Improve Current GitLab Experience (Minimal Effort)

**What:** Optimize existing GitLab markdown rendering
**Effort:** 1-2 hours
**Value:** Low-Medium

Actions:
- Add clear navigation to README.md ✅ (Done above)
- Create DOCUMENTATION_INDEX.md as landing page
- Use relative links consistently
- Add "Back to Top" links in long documents

**This may be sufficient for your needs.**

### Alternative 2: Confluence Wiki (No GitLab Pages)

**What:** Mirror documentation in Confluence
**Effort:** 4-6 hours initial + ongoing sync
**Value:** Medium (if team already uses Confluence heavily)

Pros:
- Familiar interface
- Integrated with other Confluence content
- Good search

Cons:
- Duplicate maintenance
- No version control benefits
- Harder to keep in sync

### Alternative 3: Third-Party Documentation Platform

**What:** Services like Notion, GitBook, ReadMe.io
**Effort:** Varies
**Value:** High (if budget allows)

Pros:
- Professional hosting
- Advanced features
- No infrastructure management

Cons:
- Monthly cost
- External dependency
- May not integrate with GitLab

---

## Decision Matrix

| Criterion | Weight | Current | MkDocs Pages | Score Difference |
|-----------|--------|---------|--------------|------------------|
| Ease of Use | High | 7/10 | 9/10 | +2 |
| Professional Look | Medium | 5/10 | 10/10 | +5 |
| Search Quality | High | 4/10 | 9/10 | +5 |
| Setup Effort | High | 10/10 | 3/10 | -7 |
| Maintenance | Medium | 9/10 | 7/10 | -2 |
| Mobile Experience | Low | 6/10 | 10/10 | +4 |
| **Weighted Score** | - | **6.8** | **7.6** | **+0.8** |

**Conclusion:** GitLab Pages provides moderate improvement (+0.8) with significant upfront effort. Worthwhile if documentation is heavily used or external-facing.

---

## Next Steps

1. **This Week:** Deploy improved README.md and updated Confluence page ✅
2. **This Month:** Gather feedback on documentation access
3. **Next Quarter:** Re-evaluate GitLab Pages based on:
   - Documentation growth
   - User feedback
   - Available time
   - Strategic priorities

**Want to proceed now?** Let me know and I can help with the implementation.

**Questions about this scope?** Happy to discuss any section in more detail.

---

**Prepared By:** Dan Brickey
**Review Status:** Draft
**Decision Required:** Whether to implement GitLab Pages now or defer
