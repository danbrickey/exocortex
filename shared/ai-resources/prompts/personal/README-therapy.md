---
title: "Therapy Prompts - AI-Assisted Mental Health Support"
author: "Dan Brickey"
last_updated: "2025-10-26"
version: "1.0.0"
category: "therapy"
tags: ["therapy", "mental-health", "counseling", "emotional-support"]
status: "active"
purpose: "Guide users to appropriate AI therapy assistance and document therapy sessions"
---

# Therapy Prompts

This folder contains AI therapy assistants designed to provide supportive mental health conversations while maintaining appropriate professional boundaries. These prompts help process life experiences, develop coping skills, and determine when professional human therapy is needed.

## Available Therapy Assistants

### [@therapy-assistant](therapy-assistant.md) - General Population Support
**Best for**: General therapeutic support, skill-building, emotional processing
**Approach**: Integrates emotional validation with practical therapeutic techniques
**Features**:
- Balanced warmth and evidence-based tools
- Multiple therapeutic modalities (CBT, DBT, humanistic)
- Comprehensive session documentation
- Clear professional referral guidelines

**Use when**: You want therapeutic support that combines emotional validation with practical skill development for general mental health concerns.

### [@neuro-therapist](therapist.md) - Neurodivergent-Specialized Support  
**Best for**: ADHD, autism, anxiety, and other neurodivergent individuals
**Approach**: Neurodivergent-affirming, strengths-based, concrete interventions
**Features**:
- Accommodations for sensory and executive functioning differences
- Masking trauma and identity work
- Concrete rather than abstract therapeutic approaches
- Self-advocacy skill development

**Use when**: You are neurodivergent (ADHD, autism, etc.) and want therapy that understands and celebrates neurodivergent ways of being.

## Choosing the Right Therapy Assistant

### Start with General Therapy Assistant if:
- You're unsure which approach fits better
- You want broad therapeutic support for life challenges
- You prefer structured yet flexible therapeutic approaches
- You're working on personality patterns, relationships, or general emotional skills

### Choose Neurodivergent Specialist if:
- You have diagnosed or suspected ADHD, autism, or other neurodivergent conditions
- You experience sensory sensitivities or executive functioning challenges
- You struggle with masking or authentic self-expression
- You want concrete, step-by-step therapeutic interventions

### Consider Both if:
- You're neurodivergent but also want access to broader therapeutic techniques
- You want to compare approaches and see what works better for you
- You have different needs for different types of challenges

## Important Limitations and Professional Referrals

### These AI therapy assistants are designed to:
✅ **Provide emotional support and validation**
✅ **Teach practical coping and life skills**
✅ **Help process life experiences and challenges**
✅ **Create structured session notes for continuity**
✅ **Assist with determining when professional help is needed**

### These AI therapy assistants are NOT designed to:
❌ **Replace professional mental health treatment**
❌ **Provide crisis intervention or emergency support**
❌ **Diagnose mental health conditions**
❌ **Prescribe medications or medical advice**
❌ **Handle complex trauma without professional support**

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

## Session Documentation System

Both therapy assistants automatically create comprehensive session notes saved to the `docs/therapy-sessions/` folder:

### File Organization:
```
docs/
  therapy-sessions/
    general/                    # Notes from therapy-assistant.md
      YYYY-MM/
        session-YYYY-MM-DD.md
        monthly-progress-YYYY-MM.md
    neurodivergent/            # Notes from therapist.md
      YYYY-MM/
        session-YYYY-MM-DD.md
        monthly-summary-YYYY-MM.md
      accommodations/
      self-advocacy/
    skill-practice/            # Cross-cutting skill development
    safety-plans/             # Crisis and safety planning
```

### Using Session Notes:
- **Review progress** by reading previous session notes
- **Share with human therapists** for professional consultation
- **Track patterns** across multiple sessions
- **Monitor skill development** and goal progress
- **Identify when professional referrals are needed**

## Getting Started

1. **Choose your therapy assistant** based on the guidance above
2. **Start with a clear intention**: What do you want to focus on today?
3. **Be honest and open**: The AI can only help with what you share
4. **Use session notes**: Reference previous conversations for continuity
5. **Respect the boundaries**: Seek professional help when recommended

## Integration with Other Prompts

**Career stress and transitions**: Consider also using [Career Preferences Interviewer](../career/career-preferences-interviewer.md) for work-related stress

**Documentation support**: Therapy session notes can be referenced in [Documentation Architect](../documentation/arcdoc-documentation-architect.md) for formal treatment planning

**Personal development**: Therapy insights can inform [Personal AI Bootstrap](../meta/bootstrap-setup.md) customization

---

**Remember**: AI therapy is a supplement to, not replacement for, professional mental health care. Always prioritize safety and seek human professional support when indicated.