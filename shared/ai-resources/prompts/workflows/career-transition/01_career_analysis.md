---
title: "Career Transition Workflow - Step 1: Career Analysis & Path Selection"
author: "Dan Brickey"
version: "1.1.0"
last_updated: "2025-10-26"
category: "workflow"
tags: ["career-transition", "career-analysis", "multi-step-workflow", "step-1"]
status: "active"
workflow_position: "1/4"
previous_step: "00_career_preferences.md"
next_step: "02_qualification_assessment.md"
estimated_time: "45-60 minutes"
---

# Step 1: Career Analysis & Path Selection

**Workflow**: Career Transition (Step 1 of 4)
**Goal**: Understand your current position, identify target career paths, and select the best fit based on both skills AND preferences
**Time**: 45-60 minutes

## Overview

This is the foundation step where you explore career options and make an informed decision about your target role. You'll use the career analyzer to compare multiple paths and select the one that best aligns with your skills, interests, goals, AND preferences (if you completed Step 0).

**Key Integration**: If you completed Step 0 (Career Preferences), this step will use your preference profile to filter and prioritize career paths that align with both your capabilities and what makes you thrive.

## Prerequisites

**What you need**:
- Clear understanding of your current role and experience
- Some idea of what interests you (even if vague)
- Honest assessment of your strengths and weaknesses
- Career goals and timeline (even if rough)
- **[OPTIONAL]** Career preferences profile from Step 0

**What you don't need**:
- Certainty about your target role (we'll help you figure it out)
- Complete work history documented (we'll build that later)
- Resume prepared (that comes in Step 3)

## Step 1.1: Initial Career Exploration

**Action**: Use [@nav](../../meta/nav-resource-navigator.md) or [@discover](../../meta/discover-prompt-finder.md) to explore career categories

**Prompt to use**:
```
@discover I'm exploring career options
```

**Or navigate directly to**:
- [Career folder](../../career/) to browse 60 career paths by industry
- [Quick Start Guide - Career Changer section](../../QUICK_START.md#career-changer--job-seeker)

**Output**: List of 2-5 career areas that interest you (e.g., "Tech roles", "Creative roles", "Business roles")

**Time**: 10 minutes

---

## Step 1.2: Multi-Domain Career Analysis

**Action**: Use [Career Analyzer](../../career/career-analyzer.md) to compare multiple career paths

**Prompt to use** (Standard):
```
@career-analyzer

I'm currently [your current role] with [X years] experience.
I'm interested in transitioning to [domain/area].
I want to compare:
- [Option 1]
- [Option 2]  
- [Option 3]
```

**Prompt to use** (With Preferences from Step 0):
```
@career-analyzer

I'm currently [your current role] with [X years] experience.
I'm interested in transitioning to [domain/area].

I've completed a career preferences assessment with these key findings:
- [Top 2-3 preference themes from Step 0]
- [Important work environment needs]
- [Key values/motivations]

I want to compare these options with my preferences in mind:
- [Option 1]
- [Option 2]
- [Option 3]

Please factor in both my capability fit AND preference alignment.
```

**Example**:
```
@career-analyzer

I'm currently a Business Analyst with 5 years experience in healthcare.
I'm interested in transitioning to tech roles.
I want to compare:
- Full Stack Engineer
- Product Manager
- Data Analyst
```

**What the Career Analyzer will do**:
1. Analyze your transferable skills for each path
2. Identify skill gaps for each option
3. Assess qualification timeline (6 months, 1 year, 2+ years)
4. Provide development roadmaps for each
5. Compare salary expectations
6. Recommend the best fit(s)

**Output**:
- Comparison matrix of 2-5 career paths
- Qualification assessment for each
- Recommended path(s) based on your profile
- Skill gap analysis

**Time**: 20-30 minutes (including analysis conversation)

---

## Step 1.3: Select Target Career Path

**Decision Point**: Choose 1-2 target career paths to pursue

**Considerations**:
- **Skill overlap**: Which path leverages your existing skills best?
- **Timeline**: How quickly do you need/want to transition?
- **Interest**: Which role genuinely excites you?
- **Market demand**: What's the job market like?
- **Salary**: Does it meet your financial needs?
- **Work-life balance**: Does it match your lifestyle goals?

**Action**: Make a decision and document it

**Output**:
```
PRIMARY TARGET: [Role name]
- Why: [2-3 sentences on why this is the best fit]
- Timeline goal: [When you want to land this role]
- Key gaps to address: [Top 3 skill/experience gaps]

BACKUP TARGET (optional): [Alternative role]
- Why: [Rationale if primary doesn't work out]
```

**Time**: 10-15 minutes

---

## Step 1.4: Prepare for Deep Dive

**Action**: Gather information for the detailed assessment in Step 2

**What to prepare**:
- Your resume/CV (if you have one, even if outdated)
- List of projects/work experience (can be rough notes)
- Educational background and certifications
- Technical skills and tools you know
- Soft skills and achievements
- Portfolio links (GitHub, website, work samples) if applicable

**You can do this casually** - jot down notes, bullet points, or just think through it. The detailed assessment in Step 2 will be interactive and will help you structure this information.

**Time**: 5-10 minutes

---

## Checkpoint: Are You Ready for Step 2?

Before moving to Step 2, you should have:

- ✅ Selected a **primary target career path** (and optional backup)
- ✅ Understand why this path is a good fit for you
- ✅ Know your approximate timeline goal (3 months, 6 months, 1 year)
- ✅ Have rough notes on your experience and skills
- ✅ Identified your top 3 skill/experience gaps

**If you have all of these, you're ready to proceed to Step 2!**

---

## Step 1 Output Summary

**What you've accomplished**:
- ✅ Explored career options across industries
- ✅ Compared 2-5 career paths systematically
- ✅ Selected your target career path(s)
- ✅ Identified key skill gaps
- ✅ Set a timeline goal
- ✅ Prepared for detailed assessment

**What you created**:
- Target career selection document
- Skill gap analysis notes
- Timeline and goals

**What's next**:
→ **[Step 2: Qualification Assessment & Roadmap](02_qualification_assessment.md)**

In Step 2, you'll use the specific career path prompt to:
- Complete a detailed qualification interview
- Get a personalized development roadmap
- Receive concrete action steps for the next 30-90 days
- Identify specific resources and learning paths

---

## Troubleshooting

**"I can't decide between two paths"**:
- It's OK to pursue both in parallel through Step 2
- The detailed assessment will help clarify which is more viable
- You can always pivot later

**"None of the careers in the analyzer matched exactly"**:
- Check the 60 specific career paths in [career/](../../career/)
- Use the closest match and ask the analyzer to customize
- Contact @meta-librarian to create a custom career path prompt

**"I have no idea what I want to do"**:
- Start broader: "I want to work in tech" or "I'm interested in creative work"
- Use [@tutor](../../specialized/tutor-learning-assistant.md) for skill assessment
- Consider using vocational career paths for entry points

**"The timeline seems too long/short"**:
- Timelines are estimates based on typical paths
- Your actual timeline depends on your dedication and circumstances
- Discuss accelerated or extended paths with the career path prompt in Step 2

---

## Tips for Success

💡 **Be honest**: The more accurate your self-assessment, the better the recommendations

💡 **Think broadly**: Don't limit yourself to obvious transitions - explore adjacent fields

💡 **Consider multiple paths**: Comparing 3-5 options gives you perspective

💡 **Market research**: Check job boards for your target role to validate demand

💡 **Network early**: Reach out to people in your target roles for informational interviews

💡 **Stay flexible**: Your target might evolve as you learn more - that's normal

---

**Ready to proceed? → [Step 2: Qualification Assessment & Roadmap](02_qualification_assessment.md)**
