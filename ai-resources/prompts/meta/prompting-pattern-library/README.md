# Prompting Pattern Library

**Version 1.0** | October 2025 | Tested with Claude 3.5/4, GPT-4/4o, Gemini 1.5 Pro

## Overview

A comprehensive library of proven prompting patterns, frameworks, and examples for effective LLM interactions. This library serves as the knowledge foundation for the Meta-Prompt Engineer and as a standalone educational resource for prompt engineering.

## How This Integrates with Meta-Prompt Engineer

### The Complementary Relationship

**Meta-Prompt Engineer** ([../meta-prompt-engineer.md](../meta-prompt-engineer.md)):
- **Purpose**: Systematically generate and evaluate competing prompt candidates
- **Approach**: Requirements analysis → 3 candidates → rubric evaluation → winner selection
- **Output**: One winning prompt with evidence-based selection rationale

**Prompting Pattern Library** (this directory):
- **Purpose**: Educational reference and knowledge base of proven patterns
- **Approach**: Catalog of 25+ patterns, failure modes, model quirks, orchestration strategies
- **Output**: Knowledge, examples, debugging strategies, optimization techniques

### Integration Workflow

```
User Request
    ↓
Meta-Prompt Engineer
    ↓
Phase 1: Requirements Analysis
    ↓
Phase 2: Generate Candidates ← [CONSULTS Pattern Library for proven patterns]
    ↓
Phase 3: Create Rubric
    ↓
Phase 4: Evaluate Candidates ← [REFERENCES failure modes to avoid]
    ↓
Phase 5: Select Winner ← [OPTIMIZES using model quirks]
    ↓
Continuous Improvement ← [DEBUGS using failure mode diagnostics]
```

### When Each Resource Should Be Used

**Use Meta-Prompt Engineer when:**
- Creating a new prompt from scratch
- Need to compare different prompting approaches
- Want systematic evaluation with scoring rubric
- Creating production prompts that must be validated

**Use Prompting Pattern Library when:**
- Learning about prompting techniques
- Teaching prompting to others
- Debugging why a prompt isn't working
- Optimizing prompts for specific LLMs
- Building multi-step agent systems
- Understanding "why" a pattern works

**Use Both Together when:**
- Creating high-stakes prompts (Meta-Prompt Engineer generates, Pattern Library informs)
- Troubleshooting underperforming prompts (Pattern Library diagnoses, Meta-Prompt Engineer rebuilds)
- Building educational content (Pattern Library provides theory, Meta-Prompt Engineer demonstrates methodology)

## Files in This Directory

### Main Reference
- **[prompting-pattern-library.md](prompting-pattern-library.md)** - Overview and quick reference of all patterns

### Detailed References

#### Pattern Catalog
**[references/prompt-patterns.md](references/prompt-patterns.md)**
- 25+ proven prompting patterns organized by category
- "Why it works" analysis for each pattern
- Examples with before/after comparisons
- When to use each pattern
- Research basis and citations

**Categories:**
- Structural Patterns (Role Prompting, Chain-of-Thought, Few-Shot, Zero-Shot, Tree of Thoughts)
- Output Control (Structured Output, Delimiters, Length Control, Style Constraints)
- Reasoning Enhancement (Self-Consistency, Reflection, Decomposition, Analogical Reasoning)
- Retrieval Patterns (Citation Requirements, Fact-Checking, Knowledge Boundaries)

#### Failure Mode Diagnostics
**[references/failure-modes.md](references/failure-modes.md)**
- Common prompting failures with symptoms
- Root cause diagnosis
- Cross-referenced solutions from pattern catalog
- Prevention strategies

**Common Issues:**
- Output format problems
- Reasoning failures
- Context handling issues
- Hallucination and fact accuracy
- Edge case handling

#### Model-Specific Optimization
**[references/model-quirks.md](references/model-quirks.md)**
- Claude-specific considerations and best practices
- GPT-4 optimization techniques
- Gemini 1.5 Pro characteristics
- Cross-model compatibility strategies
- When to use model-specific features

#### Advanced Orchestration
**[references/orchestration-patterns.md](references/orchestration-patterns.md)**
- Multi-step workflow patterns
- Planner-executor architectures
- Multi-agent collaboration
- Evaluation and feedback loops
- Complex task decomposition

## Quick Start Guide

### For Prompt Engineers Creating New Prompts

1. **Start with Meta-Prompt Engineer** to generate candidates
2. **During candidate generation**, reference this library for:
   - Proven patterns to incorporate (e.g., Chain-of-Thought for reasoning)
   - Common pitfalls to avoid (check failure-modes.md)
3. **After evaluation**, if candidates underperform:
   - Diagnose issues using [failure-modes.md](references/failure-modes.md)
   - Apply corrections from [prompt-patterns.md](references/prompt-patterns.md)
4. **For specific LLMs**, optimize using [model-quirks.md](references/model-quirks.md)

### For Learning Prompt Engineering

1. **Read** [prompting-pattern-library.md](prompting-pattern-library.md) for overview
2. **Study** [references/prompt-patterns.md](references/prompt-patterns.md) for detailed patterns
3. **Practice** by using Meta-Prompt Engineer to generate prompts
4. **Debug** your attempts using [references/failure-modes.md](references/failure-modes.md)
5. **Optimize** for your target LLM using [references/model-quirks.md](references/model-quirks.md)

### For Teaching Prompting

1. **Conceptual Foundation**: Use pattern catalog to explain core concepts
2. **Demonstration**: Use Meta-Prompt Engineer to show systematic evaluation
3. **Practice Exercises**: Have learners create prompts, then debug with failure modes
4. **Advanced Topics**: Introduce orchestration patterns for complex systems

## Core Principles (From the Library)

### Specificity Over Generality
❌ Vague: "Write about AI"
✅ Specific: "Write a 500-word technical explanation of transformer attention mechanisms for software engineers with no ML background"

### Provide Context Explicitly
❌ Poor context: "Fix this code"
✅ Good context: "Fix this Python function that should validate email addresses. Current issue: it fails on addresses with plus signs. Python 3.11, standard library only."

### Use Examples When Precision Matters
For tasks requiring specific formats or styles, provide 2-3 high-quality examples rather than lengthy descriptions.

### Structure Complex Prompts
1. Context and background
2. Specific task requirements
3. Output format specifications
4. Constraints and limitations
5. Examples (if applicable)

### Iterate Based on Output
Use the failure modes guide to diagnose issues and apply pattern corrections.

## Navigation by Use Case

### "My prompt isn't working correctly"
→ [references/failure-modes.md](references/failure-modes.md) for diagnosis
→ [references/prompt-patterns.md](references/prompt-patterns.md) for solutions

### "I need to create a new prompt"
→ [../meta-prompt-engineer.md](../meta-prompt-engineer.md) for systematic generation
→ [prompting-pattern-library.md](prompting-pattern-library.md) for pattern reference

### "I want to optimize for Claude/GPT-4/Gemini"
→ [references/model-quirks.md](references/model-quirks.md) for model-specific guidance

### "I'm building an agentic system"
→ [references/orchestration-patterns.md](references/orchestration-patterns.md) for multi-step workflows

### "I'm teaching prompting to others"
→ [references/prompt-patterns.md](references/prompt-patterns.md) for educational examples
→ [../meta-prompt-engineer.md](../meta-prompt-engineer.md) to demonstrate evaluation methodology

### "I want to understand why patterns work"
→ [references/prompt-patterns.md](references/prompt-patterns.md) for research-backed explanations

## Pattern Categories Quick Reference

### Structural Patterns
- **Role Prompting**: Assign specific persona/expertise
- **Chain-of-Thought**: Request step-by-step reasoning
- **Few-Shot Learning**: Provide example input-output pairs
- **Zero-Shot**: Detailed instructions without examples
- **Tree of Thoughts**: Explore multiple reasoning paths

### Output Control Patterns
- **Structured Output**: Define specific formats (JSON, XML, tables)
- **Delimiters**: Clear separators for inputs/outputs
- **Length Control**: Specify output length explicitly
- **Style Constraints**: Define tone, formality, audience

### Reasoning Enhancement Patterns
- **Self-Consistency**: Generate multiple solutions, select most common
- **Reflection**: Ask model to critique its output
- **Decomposition**: Break complex tasks into sub-tasks
- **Analogical Reasoning**: Request analogies/comparisons

### Retrieval Patterns
- **Citation Requirements**: Demand sources and evidence
- **Fact-Checking**: Request verification of claims
- **Knowledge Boundaries**: Acknowledge uncertainty

## Version History

**v1.0** (October 2025)
- Initial integration with Meta-Prompt Engineer
- 25+ prompting patterns documented
- Failure mode diagnostics for common issues
- Model-specific quirks for Claude, GPT-4, Gemini
- Orchestration patterns for agentic systems

## Source

Adapted from the "Prompting Pattern Library" custom skill, integrated as a knowledge foundation for the Meta-Prompt Engineer systematic prompt generation workflow.

## Related Resources

- **Meta-Prompt Engineer**: [../meta-prompt-engineer.md](../meta-prompt-engineer.md) - Systematic prompt generation and evaluation
- **Original README**: [README_ORIGINAL.md](README_ORIGINAL.md) - Original skill documentation for reference
