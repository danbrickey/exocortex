# Data Vault Design Workflow - Brain Dump

**Captured**: 2026-01-02
**Source**: Cursor Chat Session

---

## Original Description

### The Problem

What I want to do is take it, create or design a DataVault model, or refactor an existing DataVault model, and create an agentic workflow to implement those changes or the new design. I'd like to use an agent to do pieces of that.

It would be really nice if I could have a simple diagramming tool that I could draw a picture of the hubs, links, and satellites and their connections, and then have the agent start working on the code or the refactoring.

I'd like to make that process as agentic as possible, but **my main goal is to accelerate the current bottleneck that architecture takes longer than the data engineering part of the process**.

I was looking for tutorials that helped me go in that direction or systems that people have already figured out to do that. But I'm not looking for new commercial tools to help with that. I have a sort of a set tech stack that I'm working with.

### Tech Stack

- **Snowflake** hosted on AWS
- **dbt** for data transformations (most of the code we write is in dbt)
- **dbt Copilot** - available for engineer acceleration
- **Microsoft Copilot Chat** - available
- **Claude via Amazon QuickStart** - limited version of a Claude coding assistant

Working within those constraints, I'd like to find some tutorials that will help me start making our workflows more AI-native.

### Diagramming

Current diagramming tool is **Lucidchart**. I don't know how well that would work in a workflow.

### Vision for the Workflow

The goal here is to take our design decisions and turn them into specs that a data engineer can work from. **The more AI-ready those specs are, the better.**

#### What I Want to Support

1. **Architecture Process** - I'm already comfortable making architectural decisions and discussing those with other architects
2. **Specification Writing** - Need help writing the specification with enough information for a data engineer or coding assistant to take that refactoring/design and implement it in code
3. **Code Generation (Future)** - Eventually would like AI code generation, but not the first step
4. **Code Evaluation** - Want an AI evaluator for the code based on acceptance criteria from the specs
5. **Human Review Support** - AI process to test code against specification and identify things for a human to review in more detail

#### What I Don't Want (Yet)

- Don't want to take the data engineer out of the loop right now
- Think I'll need to retrain data engineers to evaluate code more than write code, but we're not quite there yet

#### Key Outputs Desired

- Specs and evaluations that work equally well for AI-generated code as for human-generated code
- Starter prompts for dbt Copilot as part of the output
- If possible, work from diagrams; if not, text descriptions are acceptable

---

## Parsed Understanding

### Current State
- Architect makes Data Vault design decisions (hubs, links, satellites)
- Discusses designs with other architects
- Currently using Lucidchart for diagramming
- Once design is complete, data engineers implement in dbt (Snowflake/AWS)
- **Bottleneck**: Architecture → Spec handoff takes longer than the actual coding

### Desired Future State

1. **Captures architectural decisions** (ideally from diagrams, but text is acceptable)
2. **Produces detailed specifications** that are:
   - Complete enough for a data engineer to implement
   - AI-ready (could work with dbt Copilot or future AI code gen)
3. **Generates starter prompts** for dbt Copilot to accelerate engineers
4. **Evaluates code against specs** - AI-powered review that flags items for human attention

---

## Pending Clarifying Questions

Before designing the workflow, these questions need answers:

### 1. Current Specification Format
**What does your spec handoff look like today?** For example:
- Do you have a template or standard format?
- Is it a document, ticket, conversation?
- What information do you typically include (DDL, column mappings, source-to-target, business keys, etc.)?

### 2. Design Input Granularity
**When you make a design decision, what's the typical scope?**
- A single hub/link/satellite addition?
- A complete subject area (e.g., "Provider Agreement" with multiple entities)?
- A full model refactor?

### 3. Source Information
**Where does source system knowledge live?**
- Do you have documented source schemas?
- Business key definitions?
- Existing staging layer that feeds the raw vault?

### 4. Current Review/Validation
**How do you currently validate that the code matches the design?**
- Manual code review against the diagram?
- Testing conventions (e.g., dbt tests)?
- Specific acceptance criteria you check?

### 5. Lucidchart Usage
**How structured are your Lucidchart diagrams?**
- Do you use consistent shapes/naming conventions for hubs, links, satellites?
- Could you export to CSV or some structured format?
- Or are they more freeform visual artifacts?

---

## Next Steps

Once the clarifying questions are answered, proceed to:
1. **Phase 2**: Real-World Process Specification
2. **Phase 3**: Agent/Human Allocation
3. **Phase 4**: Agentic Workflow Specification

Reference prompt: `@agentflow` (ai-resources/prompts/workflows/agentflow-workflow-designer.md)

