# Personal Operating System - User Guide

**Author**: Dan Brickey
**Last Updated**: October 15, 2025
**Version**: 1.0

---

## Purpose

This is your **unified personal operating system** for managing:
- Daily work activities and reflections
- BCI-specific goals and transformation work
- External career trajectory and portfolio
- Delegation and mentoring practices
- Multiple reporting outputs for different audiences

**Core Principle**: Write once (daily), synthesize multiple times (weekly/monthly), output many times (reports for different audiences).

---

## System Overview

```
INPUT → PROCESSING → OUTPUT

Daily Journals → Weekly Reviews → BCI Leadership Reports
                ↓                  Performance Reviews
              Monthly Reviews  →  Career Portfolio
                ↓                  LinkedIn Updates
            Quarterly Reviews
```

---

## Folder Structure

```
docs/
├── personal/                      # PRIVATE: Your raw input and synthesis
│   ├── daily_journal/            # Daily dictation, raw notes
│   ├── weekly_reviews/           # Weekly rollups (30-45 min)
│   ├── monthly_reviews/          # Monthly checkpoints (1-2 hours)
│   └── quarterly_reviews/        # Quarterly strategy (2-3 hours)
│
├── work_tracking/                # BCI TACTICAL: Execution tracking
│   ├── delegation/               # Delegation log and archive
│   ├── mentoring/                # Mentee development tracking
│   ├── projects/                 # Active and completed projects
│   └── ai_transformation/        # AI initiatives at BCI
│
├── goals/                        # STRATEGIC: Vision and objectives
│   ├── bci_goals/                # BCI 12-month transformation
│   └── career_goals/             # 2.5+ year career trajectory
│
└── reports/                      # OUTPUT: Audience-specific summaries
    ├── bci_leadership/           # For Ram, David
    ├── performance_reviews/      # For annual reviews
    └── career_portfolio/         # For job search, LinkedIn
```

---

## Daily Workflow (10-15 minutes)

**When**: End of day (or throughout day)
**Where**: `personal/daily_journal/YYYY_MM_DD.md`

**What to capture**:
- Meeting notes and decisions
- Delegations made (with fear/anxiety tracking)
- Work completed
- To-dos for tomorrow
- Reflections and insights
- Time spent (optional but helpful)

**Template**: `personal/daily_journal/template.md`

**Key**: This is RAW and PRIVATE. No polish needed. Just capture everything.

---

## Weekly Workflow (30-45 minutes)

**When**: Friday afternoon or Monday morning
**Where**: `personal/weekly_reviews/YYYY_Wxx_review.md`

**What to do**:
1. Review daily journals from the week (M-F)
2. Summarize key accomplishments
3. Track delegation progress (update delegation log)
4. Assess progress on BCI goals (`goals/bci_goals/current_goals.md`)
5. Assess progress on career plan (`goals/career_goals/career_plan.md`)
6. Identify patterns and insights
7. Plan next week's priorities

**Template**: `personal/weekly_reviews/template.md`

**Key**: This connects daily actions to strategic goals.

---

## Monthly Workflow (1-2 hours)

**When**: Last day of month
**Where**: `personal/monthly_reviews/YYYY_MM_review.md`

**What to do**:
1. Review 4-5 weekly reviews from the month
2. Assess progress against monthly objectives
3. Calculate metrics (time distribution, delegation success, etc.)
4. Analyze BCI goals progress (3/6/12-month milestones)
5. Analyze career plan progress (current phase status)
6. Identify what's working and what needs adjustment
7. Plan next month's priorities
8. **Generate reports** (see "Report Generation" section)

**Template**: `personal/monthly_reviews/template.md`

**Key**: This is your strategic checkpoint and report generation point.

---

## Quarterly Workflow (2-3 hours)

**When**: End of quarter
**Where**: `personal/quarterly_reviews/YYYY_Qx_review.md`

**What to do**:
1. Review 3 monthly reviews from the quarter
2. Assess 3-month goals from BCI goals
3. Assess career plan phase progress
4. Major strategic assessment (what worked, what didn't)
5. Set next quarter's goals
6. Archive current quarter's goals

**Template**: `personal/quarterly_reviews/template.md` *(to be created)*

**Key**: This is major course correction and strategic planning.

---

## Delegation Workflow

### When Delegating a Task
1. **Before**: Use script from `work_tracking/delegation/delegation_guide.md`
2. **During**: Have the conversation using framework
3. **After**: Log in `work_tracking/delegation/delegation_log.md`
   - Task description
   - Delegatee
   - Fear/anxiety
   - Follow-up date
4. **Follow-up**: Check in, document outcome
5. **Reflect**: Track fear vs. reality, build evidence

### Monthly Archiving
- Move completed delegations to `work_tracking/delegation/delegation_archive/YYYY_MM_delegations.md`
- Calculate monthly metrics (tasks delegated, success rate, time freed)
- Update evidence table in delegation guide

**Resources**:
- `work_tracking/delegation/delegation_log.md` - Current delegations
- `work_tracking/delegation/delegation_guide.md` - Scripts and frameworks

---

## Mentoring Workflow

### Per Mentee
1. **Create file**: `work_tracking/mentoring/mentees/[name].md`
2. **Use template**: Copy from `work_tracking/mentoring/mentees/template.md`
3. **After each session**: Log discussion, actions, next steps
4. **Monthly**: Review progress, adjust development plan

### Tracking
- Individual mentee files for detailed tracking
- Weekly reviews summarize mentoring activity
- Monthly reviews assess overall mentoring impact

---

## Report Generation

### Monthly Leadership Report
**Frequency**: Monthly
**Audience**: Ram Garimella, David Yoo
**Source**: Your monthly review
**Template**: `reports/bci_leadership/monthly_summary_template.md`
**Time**: 10-15 minutes (because you already did the work in monthly review)

**What to include**:
- Key accomplishments (architecture, team development, AI transformation)
- Project status
- Team impact
- Decisions made
- Next month focus

---

### Performance Review / Accomplishment Log
**Frequency**: Continuous (add from monthly reviews)
**Audience**: You (for annual review prep)
**Location**: `reports/performance_reviews/accomplishment_log.md`
**Time**: 5-10 minutes/month to add new accomplishments

**What to include**:
- Major accomplishments with metrics
- Leadership and team development
- Technical contributions
- Professional development

**Pull from this for**:
- Annual performance reviews
- Promotion cases
- Resume updates

---

### Career Portfolio Updates
**Frequency**: As projects complete
**Audience**: External (job search, LinkedIn)
**Location**: `reports/career_portfolio/portfolio_projects.md`
**Source**: Monthly reviews + project documentation

**What to include**:
- AI projects with business impact
- Architecture and business value
- Technologies used
- Your role
- Links to GitHub, diagrams, write-ups

---

## Integration Points

### BCI Goals ↔ Career Plan
- **BCI Phase 0** (delegation/workflow optimization) = **Career Plan Phase 0**
- **BCI AI transformation work** = **Career Plan portfolio projects**
- **BCI team development** = **Career Plan leadership evidence**

**How it works**:
- Same work, tracked in both systems
- BCI goals focus on transformation AT Blue Cross
- Career plan focuses on external trajectory and portfolio
- Monthly reviews assess both simultaneously

### Daily Journals → Reports
- Daily journals capture raw data
- Weekly reviews synthesize into progress
- Monthly reviews calculate metrics and accomplishments
- Reports extract what's relevant for each audience

**No duplication**: Write it once in daily journal, use it many times in reports.

---

## Key Files Reference

### Most Frequently Used
- `personal/daily_journal/YYYY_MM_DD.md` - Daily (10-15 min)
- `work_tracking/delegation/delegation_log.md` - As you delegate
- `personal/weekly_reviews/YYYY_Wxx_review.md` - Weekly (30-45 min)
- `personal/monthly_reviews/YYYY_MM_review.md` - Monthly (1-2 hours)

### Strategic Planning
- `goals/bci_goals/current_goals.md` - BCI quarterly goals
- `goals/bci_goals/vision.md` - "Island of competency" vision
- `goals/bci_goals/architecture_goals.md` - 3/6/12-month milestones
- `goals/career_goals/career_plan.md` - 2.5-year career trajectory

### Frameworks & Guides
- `work_tracking/delegation/delegation_guide.md` - Delegation scripts
- `work_tracking/mentoring/mentees/template.md` - Mentee tracking

### Reports (Generated from Reviews)
- `reports/bci_leadership/monthly_summary_template.md`
- `reports/performance_reviews/accomplishment_log.md`
- `reports/career_portfolio/portfolio_projects.md`

---

## Tips for Success

### 1. Don't Skip Daily Journals
- Even 5 minutes of capture is better than nothing
- Raw is fine - this is private
- Dictate if typing is too slow
- This is your memory - future you will thank you

### 2. Weekly Reviews Are Critical
- Connects daily work to strategic goals
- Catches issues early
- Builds evidence (especially for delegation)
- Only 30-45 minutes - worth it

### 3. Monthly Reviews = Report Time
- Do your monthly review first
- Then generate reports (they'll take 10-15 min each)
- All your accomplishments will be summarized and ready

### 4. Use Templates
- Templates reduce cognitive load
- Customize them as you learn what works
- But don't let perfect be enemy of good

### 5. Archive Regularly
- Move completed delegations monthly
- Archive quarterly goals at end of quarter
- Keep daily journals (they're your personal archive)

---

## Troubleshooting

### "I don't have time for this"
- Start with daily journals only (10 min/day)
- Add weekly reviews when you see the value
- Monthly reviews SAVE time (by generating reports easily)
- This system creates time by reducing duplicated effort

### "Too many folders"
- Start with the daily journal
- Add delegation log when you start delegating
- Add other pieces as needed
- You don't have to use everything at once

### "I'm behind on reviews"
- Do a catch-up session
- Going forward, set calendar reminders
- Friday afternoon or Monday morning work well
- Make it a habit (same time each week)

### "Not sure what to track"
- If in doubt, write it in daily journal
- Weekly/monthly reviews will reveal patterns
- Adjust as you learn what matters

---

## Success Metrics

**You'll know this is working when**:
- You can generate a leadership report in 15 minutes
- You have evidence that delegation is working
- You can see progress on both BCI and career goals
- Annual review prep takes 30 minutes (not 3 days)
- You have a portfolio of accomplishments ready for job search

---

## Questions?

This is YOUR system - customize it as needed. The templates are starting points, not rigid requirements.

The key is: **Write once, synthesize often, output to multiple audiences.**

---

**Related Documents**:
- [BCI Goals - Current](goals/bci_goals/current_goals.md)
- [BCI Goals - Vision](goals/bci_goals/vision.md)
- [BCI Goals - Architecture Milestones](goals/bci_goals/architecture_goals.md)
- [Career Plan](goals/career_goals/career_plan.md)
- [Delegation Guide](work_tracking/delegation/delegation_guide.md)
