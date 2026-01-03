# Amazon Q in VSCode - BCI Practical Guide

**Organization**: Blue Cross of Idaho (BCI)
**Purpose**: Reference guide for using Amazon Q Developer extension in the BCI work environment.

---

## Current Setup

| Component | Details |
|-----------|---------|
| IDE | Visual Studio Code |
| AI Extension | Amazon Q Developer |
| Model | Claude Opus 4.5 (via Amazon Q) |
| Use Cases | Spec generation, prompt creation, code evaluation |

---

## Amazon Q Capabilities in VSCode

### What Amazon Q Can Do

| Feature | Description | How to Use |
|---------|-------------|------------|
| **Chat** | Conversational AI in sidebar | Open Amazon Q panel, type questions |
| **Inline Suggestions** | Code completion as you type | Just start typing, accept with Tab |
| **Inline Chat** | Quick edits in editor | Select code → Ctrl+I (or Cmd+I) |
| **Code Explanation** | Explain selected code | Select code → right-click → "Explain" |
| **Security Scan** | Scan code for vulnerabilities | Command palette → "Amazon Q: Run Security Scan" |

### Context Features

| Feature | How It Works | Notes |
|---------|--------------|-------|
| **Current File** | Automatically included in chat context | Works well |
| **Selected Text** | Include specific code in prompts | Highlight before asking |
| **@workspace** | Reference workspace files | May have limitations compared to Cursor |
| **File References** | Mention specific files | Use relative paths |

### What Amazon Q Does NOT Have (vs. Cursor)

| Cursor Feature | Amazon Q Equivalent | Workaround |
|----------------|---------------------|------------|
| `@file` references | Manual copy/paste or @workspace | Paste relevant context into chat |
| Agent mode with tool use | Chat only | Break into smaller steps |
| Automatic file editing | Copy suggestions manually | Use inline chat for small edits |
| Multi-file context | Limited | Focus on one file at a time |
| Background indexing | Basic workspace awareness | Be explicit about file contents |

---

## Practical Usage Patterns

### Pattern 1: Spec Generation

```
Prompt Template for Amazon Q:

I have a Data Vault design for a [HUB/LINK/SATELLITE].

[Paste the design description or diagram metadata here]

Using our specification template:
[Paste template structure here]

Generate a complete specification for this entity including:
- Column definitions
- Business keys
- Source mappings
- Acceptance criteria for implementation
```

### Pattern 2: dbt Prompt Generation

```
Prompt Template for Amazon Q:

Given this specification:
[Paste completed spec]

Generate a prompt for dbt Copilot that will help create this [hub/link/satellite] model. The prompt should include:
- Entity type and name
- Source table references
- Column mappings
- Hash key requirements
- Any business rules
```

### Pattern 3: Code Evaluation

```
Prompt Template for Amazon Q:

Compare this dbt model code against the specification:

SPECIFICATION:
[Paste spec]

CODE:
[Paste dbt model code]

Check for:
1. All columns from spec are present
2. Business key matches specification
3. Source references are correct
4. Hash columns are properly defined
5. Any missing or extra elements

Report any discrepancies and flag items for human review.
```

---

## Troubleshooting

### Known Issues

| Issue | Symptom | Solution |
|-------|---------|----------|
| Chat window loading forever | Spinning indicator, no response | Restart VSCode, or use inline chat instead |
| Extension not responding | No suggestions, chat unresponsive | Check AWS authentication, reinstall extension |
| Memory issues | VSCode becomes slow | Close and reopen VSCode |
| Proxy issues | Connection failures | Configure system proxy settings manually |

### Version Check

**IMPORTANT**: Ensure you're on version **1.85.0 or later**. Version 1.84.0 had security issues.

Check version: Extensions panel → Amazon Q Developer → Check version number

### Getting Help

- [AWS Toolkit VSCode Issues](https://github.com/aws/aws-toolkit-vscode/issues)
- [AWS Developer Community](https://community.aws/)
- [Amazon Q Documentation](https://docs.aws.amazon.com/toolkit-for-vscode/latest/userguide/amazonq.html)

---

## Tips for Effective Use

### 1. Be Explicit with Context

Unlike Cursor, Amazon Q may not automatically pull in all relevant files. When asking questions:
- Paste relevant code/specs directly into the chat
- Specify file names and locations
- Include template structures in prompts

### 2. Use Structured Prompts

Amazon Q responds well to structured requests:
```
Given: [context]
Do: [specific task]
Format: [expected output format]
```

### 3. Break Down Complex Tasks

Instead of one big request, break into steps:
1. First, generate the spec
2. Then, review the spec
3. Then, generate the dbt prompt
4. Then, evaluate the code

### 4. Leverage Inline Chat for Edits

For editing existing code:
- Select the code block
- Press Ctrl+I (Cmd+I on Mac)
- Describe the change you want
- Review and accept

### 5. Save Good Prompts

When a prompt works well, save it to a file for reuse. This workflow will generate prompt templates you can use repeatedly.

---

## Comparison: Cursor vs Amazon Q

| Aspect | Cursor | Amazon Q |
|--------|--------|----------|
| Context handling | Automatic, rich | Manual, explicit |
| File editing | Direct with tools | Copy/paste or inline |
| Agent capabilities | Full agentic loop | Chat-based |
| Model options | Multiple | Claude via AWS |
| Best for | Design & iteration | Execution with prompts |

**Strategy**: Design and refine prompts in Cursor, then use those prompts in Amazon Q for production work at BCI.

---

## Next Steps

As we build out this workflow, this guide will be updated with:
- Tested prompt templates that work well in Amazon Q
- Specific workarounds for Data Vault / dbt tasks
- Examples from real (sanitized) usage
