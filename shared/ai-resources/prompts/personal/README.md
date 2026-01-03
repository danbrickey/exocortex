---
title: "Personal Growth & Wellbeing Prompts"
author: "Dan Brickey"
created: "2025-10-26"
version: "1.0.0"
category: "personal"
tags: ["personal-development", "mental-health", "journaling", "therapy", "self-reflection"]
status: "active"
purpose: "Central hub for AI-assisted personal development, mental health support, and daily reflection tools"
---

# Personal Growth & Wellbeing Prompts

This folder contains AI assistants designed to support your personal development, mental health, and daily reflection practices. These prompts work together to create a comprehensive system for self-awareness, emotional processing, and intentional growth.

## Available Tools

### 🌅 [Daily Reflection Guide](daily-reflection-guide.md)
**Purpose**: Transform brain dumps into structured journal entries
**Best for**: End-of-day processing, capturing insights, organizing thoughts
**Key Features**:
- Adaptive questioning based on your emotional state and content
- Extracts tasks, therapy notes, and growth moments
- Creates authentic first-person journal entries
- Supports therapy preparation and pattern recognition

**Use when**: You want to process your day, capture important moments, extract action items, or prepare for therapy sessions.

---

### 🧠 Mental Health Support

#### [@therapy-assistant](therapy-assistant.md) - General Therapeutic Support
**Purpose**: Provide supportive mental health conversations with evidence-based techniques
**Best for**: General therapeutic support, skill-building, emotional processing
**Approach**: Integrates emotional validation with practical therapeutic techniques (CBT, DBT, humanistic)
**Key Features**:
- Balanced warmth and evidence-based tools
- Multiple therapeutic modalities
- Comprehensive session documentation
- Clear professional referral guidelines

**Use when**: You want therapeutic support that combines emotional validation with practical skill development for general mental health concerns.

#### [@neuro-therapist](therapist.md) - Neurodivergent-Specialized Support
**Purpose**: Neurodivergent-affirming therapy for ADHD, autism, and other neurodivergent individuals
**Best for**: ADHD, autism, anxiety, and neurodivergent-specific challenges
**Approach**: Strengths-based, concrete interventions, celebrates neurodivergent ways of being
**Key Features**:
- Accommodations for sensory and executive functioning differences
- Masking trauma and identity work
- Concrete rather than abstract therapeutic approaches
- Self-advocacy skill development

**Use when**: You are neurodivergent (ADHD, autism, etc.) and want therapy that understands and celebrates neurodivergent ways of being.

---

## How These Tools Work Together

### Daily Reflection + Therapy Integration
1. **Evening**: Use [Daily Reflection Guide](daily-reflection-guide.md) to process your day
2. **Journal entry** captures patterns, emotions, and therapy-relevant insights
3. **Before therapy**: Review journal entries to identify topics for your session
4. **During therapy prep**: Use therapy assistant to explore topics more deeply
5. **After therapy**: Journal about insights and action items from the session

### Workflow Example

**Monday Evening**:
- Brain dump your day to Daily Reflection Guide
- It asks clarifying questions about a difficult work interaction
- Journal entry captures the event + identifies a people-pleasing pattern
- "FOR MY THERAPIST" section notes this for your Wednesday session

**Wednesday Morning** (before therapy):
- Review Monday's journal entry
- Use Therapy Assistant to explore the people-pleasing pattern more deeply
- Bring both the journal insight and pre-session exploration to your therapist

**Wednesday Evening** (after therapy):
- Brain dump therapy session insights to Daily Reflection Guide
- Captures action items and skills to practice
- Creates record of therapeutic progress

---

## Choosing the Right Tool

### Use Daily Reflection Guide for:
- ✅ End-of-day brain dumps and processing
- ✅ Organizing scattered thoughts
- ✅ Extracting tasks and commitments
- ✅ Capturing emotional experiences
- ✅ Preparing material for therapy sessions
- ✅ Tracking patterns over time

### Use Therapy Assistant (General) for:
- ✅ Processing specific emotional challenges
- ✅ Learning and practicing coping skills
- ✅ Working through relationship issues
- ✅ Developing emotional regulation strategies
- ✅ Exploring patterns and behaviors
- ✅ Getting unstuck on decisions

### Use Neuro-Therapist for:
- ✅ ADHD executive functioning support
- ✅ Autism masking and authenticity work
- ✅ Sensory processing challenges
- ✅ Neurodivergent identity exploration
- ✅ Concrete skill-building for daily life
- ✅ Self-advocacy in medical/work settings

---

## Important Boundaries & When to Seek Professional Help

### These AI tools are designed to:
✅ Provide emotional support and validation
✅ Teach practical coping and life skills
✅ Help process life experiences and challenges
✅ Create structured notes for continuity
✅ Assist with determining when professional help is needed

### These AI tools are NOT designed to:
❌ Replace professional mental health treatment
❌ Provide crisis intervention or emergency support
❌ Diagnose mental health conditions
❌ Prescribe medications or medical advice
❌ Handle complex trauma without professional support

### When to Seek Professional Human Therapy

**Immediately contact professionals for**:
- Suicidal thoughts with plan or intent
- Self-harm behaviors
- Substance abuse requiring intervention
- Psychosis or severe dissociation
- Active trauma requiring specialized treatment

**Strongly consider professional support for**:
- Persistent symptoms affecting daily functioning
- Complex trauma or PTSD symptoms
- Medication evaluation needs
- Couples, family, or group therapy
- Formal diagnosis or psychological testing

**Crisis Resources**:
- **988** - Suicide & Crisis Lifeline (call or text)
- **Crisis Text Line**: Text HOME to 741741
- **National Domestic Violence Hotline**: 1-800-799-7233
- **Local emergency services**: 911

---

## Documentation & Organization

### Recommended Folder Structure

Create a `docs/` folder in your repository to store outputs:

```
docs/
  journal/                      # Daily reflection entries
    2025-10/
      journal-2025-10-26.md
      journal-2025-10-27.md
    2025-11/
      journal-2025-11-01.md
  therapy-sessions/            # Therapy assistant sessions
    general/                   # From therapy-assistant.md
      2025-10/
        session-2025-10-26.md
    neurodivergent/           # From therapist.md
      2025-10/
        session-2025-10-26.md
  patterns/                   # Extracted patterns and insights
    people-pleasing-pattern.md
    work-anxiety-analysis.md
```

### File Naming Conventions
- **Journal entries**: `journal-YYYY-MM-DD.md`
- **Therapy sessions**: `session-YYYY-MM-DD.md`
- **Pattern tracking**: `[pattern-name]-[date-range].md`

---

## Getting Started

### First Time Setup (5 minutes)

1. **Create your documentation folders**:
   ```bash
   mkdir -p docs/journal/$(date +%Y-%m)
   mkdir -p docs/therapy-sessions/general/$(date +%Y-%m)
   mkdir -p docs/therapy-sessions/neurodivergent/$(date +%Y-%m)
   mkdir -p docs/patterns
   ```

2. **Try your first journal entry**:
   - Open [daily-reflection-guide.md](daily-reflection-guide.md)
   - Do a quick brain dump of your day (2-3 sentences is fine!)
   - Answer the clarifying questions
   - Save the journal entry to `docs/journal/YYYY-MM/journal-YYYY-MM-DD.md`

3. **Explore therapy support** (optional):
   - Choose [therapy-assistant.md](therapy-assistant.md) or [therapist.md](therapist.md) based on your needs
   - Start with a specific challenge or emotion you want to process
   - Save session notes for continuity

### Daily Practice Suggestions

**Minimum viable routine** (5-10 minutes):
- End-of-day brain dump to Daily Reflection Guide
- Save journal entry
- Check ACTION ZONE for tomorrow's commitments

**Enhanced routine** (15-20 minutes):
- Morning: Review yesterday's journal entry
- Evening: Brain dump to Daily Reflection Guide
- Weekly: Review week's entries for patterns
- Before therapy: Compile insights from journal entries

**Deep work routine** (30+ minutes):
- Daily journaling
- Bi-weekly therapy assistant sessions
- Monthly pattern analysis (review all journal entries)
- Quarterly goal setting based on insights

---

## Tips for Effective Use

### Journaling Best Practices
1. **Don't overthink it**: Stream of consciousness is perfect
2. **Be honest**: The AI doesn't judge, and honesty leads to better insights
3. **Review regularly**: Patterns emerge over time, not in single entries
4. **Use the therapy section**: Flag items worth exploring professionally
5. **Track action items**: Export tasks to your productivity system

### Therapy Assistant Best Practices
1. **Start with intention**: What do you want to focus on today?
2. **Reference previous sessions**: Continuity deepens therapeutic value
3. **Practice skills between sessions**: Real change happens in daily life
4. **Know when to escalate**: Trust the referral recommendations
5. **Share with professionals**: Session notes can support human therapy

### Privacy & Data Considerations
- These are **local files** in your repository
- Consider **encryption** if storing sensitive content
- Be mindful of what you **commit to git** (use `.gitignore` for private journals)
- Never share session notes without **careful review**

---

## Integration with Other Prompt Categories

**Career Development**:
- Use therapy prompts to process work stress before using [Career CV Interviewer](../career/career-cv-interviewer.md)
- Journal about career transitions to identify values and preferences

**Documentation & Knowledge Management**:
- Use [Meeting Notes Summarizer](../documentation/meeting_notes_summarizer.md) for work, Daily Reflection for personal
- Both create structured outputs from unstructured input

**Meta-Prompting**:
- If these prompts need customization, use [Meta-Librarian Architect](../meta/meta-librarian-architect_v1_2.md) to evolve them
- Reference therapy patterns when customizing your [.ai/instructions.md](../../../.ai/instructions.md)

---

## Continuous Improvement

These prompts should evolve with your needs:

- **Too structured?** Reduce question count or skip sections
- **Missing something?** Add custom sections to journal template
- **New patterns?** Create dedicated tracking documents
- **Therapeutic approach not fitting?** Customize tone or techniques

Use the [Meta-Librarian Architect](../meta/meta-librarian-architect_v1_2.md) to systematically improve these prompts based on your experience.

---

**Remember**: Personal growth is a journey, not a destination. These tools are here to support your path, at whatever pace feels right for you.

For detailed therapy information and session documentation guidance, see [README-therapy.md](README-therapy.md).
