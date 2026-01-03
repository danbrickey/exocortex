---
title: "Architecture Prompt Templates"
author: "Dan Brickey"
last_updated: "2025-10-25"
version: "1.0.0"
category: "prompt-templates"
tags: ["templates", "architecture", "documentation", "diagrams", "reusable"]
status: "active"
purpose: "Reusable templates for creating domain-specific architecture prompts"
---

# Architecture Prompt Templates

This directory contains **generalized templates** for creating domain-specific architecture prompts. Each template extracts common patterns from successful specialized prompts and makes them reusable across different domains, technologies, and projects.

## 📋 Available Templates

### 1. [General Architecture Expert](general-architecture-expert.md)
**Based on**: [@architect](../architect-data-vault.md) (Data Vault & Dimensional Modeling specialist)

**Purpose**: Create expert architecture advisors for any architecture domain

**Use this when you need**:
- Software/application architecture expert
- Cloud architecture specialist
- Enterprise architecture advisor
- Solution architecture consultant
- Network architecture expert
- Security architecture specialist

**What it provides**:
- Expert persona structure with core competencies
- Domain context gathering framework
- Working style and response format guidelines
- Decision framework for architectural choices
- Pattern library and anti-pattern identification
- Quality attribute optimization
- Architecture review checklist

**Customization effort**: 30-60 minutes to create a domain-specific instance

---

### 2. [Technical Documentation Architect](technical-documentation-architect.md)
**Based on**: [@arcdoc](../../documentation/arcdoc-documentation-architect.md) (EDP Documentation Architect)

**Purpose**: Create documentation management systems for any technical project

**Use this when you need**:
- Architecture documentation assistant
- Technical documentation manager
- Knowledge management system
- Multi-audience documentation layering
- Documentation discovery and organization

**What it provides**:
- Four operational modes (Interview, Braindump Processing, Discovery, Organization)
- Multi-audience layering framework (Executive → Analytical → Technical → Implementation)
- Content routing and classification system
- Sensitive data protection guidelines
- Documentation quality standards
- File system approval workflow

**Customization effort**: 60-90 minutes to adapt for a specific project

---

### 3. [Visual Architecture Specialist](visual-architecture-specialist.md)
**Based on**: [@drawio](../drawio-diagram-specialist.md) (Draw.io Diagram Specialist)

**Purpose**: Create diagram specialists for any visualization tool and domain

**Use this when you need**:
- Draw.io/diagrams.net specialist
- Mermaid diagram generator
- PlantUML expert
- Multi-tool diagram assistant
- Domain-specific visualization expert

**What it provides**:
- Multi-tool support framework (Draw.io, Mermaid, PlantUML, Excalidraw, ASCII)
- Visual standards (color coding, typography, lifecycle indicators)
- Stakeholder-appropriate detail levels
- Domain pattern examples
- Compliance visualization guidelines
- Output format templates
- Quality checklist

**Customization effort**: 45-75 minutes to create a tool/domain-specific instance

---

## 🎯 How to Use These Templates

### Step 1: Choose Your Template
Select the template that matches your need:
- **Architecture expert advisor** → General Architecture Expert
- **Documentation system** → Technical Documentation Architect
- **Diagram/visualization tool** → Visual Architecture Specialist

### Step 2: Copy and Customize
1. Copy the template file to your target location
2. Rename it appropriately (e.g., `cloud-architect.md`, `api-documentation-manager.md`)
3. Search for all `[PLACEHOLDER]` markers
4. Replace each with your domain-specific content
5. Remove or adapt sections that don't apply
6. Add domain-specific sections as needed

### Step 3: Review Customization Guide
Each template includes a "Template Customization Guide" section at the bottom with:
- Step-by-step customization instructions
- What to replace in each section
- Recommended content for your domain
- Example instantiations

### Step 4: Test and Refine
1. Test your new prompt with representative questions
2. Refine based on response quality
3. Add domain-specific examples and patterns
4. Document any custom sections you added

### Step 5: Register Your New Prompt
1. Add proper frontmatter with metadata
2. Update the main [prompts README](../../README.md) to include your new prompt
3. Consider adding a mnemonic for quick access
4. Document relationship to source template in frontmatter

---

## 📐 Template Design Principles

All templates follow these design principles:

### 1. **Generalized but Specific**
- Extract common patterns, but leave room for domain specificity
- Use `[PLACEHOLDERS]` for required customization
- Provide examples to guide customization

### 2. **Self-Documenting**
- Include customization guides within templates
- Show example instantiations
- Explain design decisions and trade-offs

### 3. **Progressive Disclosure**
- Start with high-level structure
- Allow deepening of detail in specific areas
- Support multi-audience use cases

### 4. **Modular & Composable**
- Sections can be removed if not needed
- New sections can be added for specific domains
- Templates can be combined (e.g., Architecture Expert + Visual Specialist)

### 5. **Quality-Focused**
- Include quality checklists
- Define best practices and anti-patterns
- Establish clear standards

---

## 🔄 Relationship to Specialized Prompts

These templates are **extracted patterns** from successful specialized prompts. The relationship is:

```
Template (Generalized)  →  Specialized Instance (Domain-Specific)
────────────────────────────────────────────────────────────────

General Architecture     →  @architect (Data Vault specialist)
Expert Template          →  @cloud (Cloud/AWS/Azure/GCP expert)
                         →  @api (REST/GraphQL/gRPC expert)
                         →  @security (Zero-trust/compliance expert)

Technical Documentation  →  @arcdoc (EDP documentation architect)
Architect Template       →  [Your API documentation system]
                         →  [Your project documentation manager]

Visual Architecture      →  @drawio (Draw.io specialist)
Specialist Template      →  [Your Mermaid diagram generator]
                         →  [Your multi-tool visualizer]
```

**Key Point**: The specialized prompts remain valuable as **ready-to-use tools** for specific domains. The templates provide **reusable patterns** for creating new prompts in other domains.

---

## 🛠️ When to Use Templates vs. Specialized Prompts

### Use Existing Specialized Prompts When:
- ✅ Your need exactly matches the specialized domain
- ✅ You want immediate, ready-to-use functionality
- ✅ You don't need customization beyond what the prompt offers

**Example**: Need Data Vault architecture guidance? Use [@architect](../architect-data-vault.md) directly.

### Use Templates When:
- ✅ You need similar functionality in a different domain
- ✅ Your project has unique requirements not covered by existing prompts
- ✅ You're building organization-specific prompts
- ✅ You want to create a family of related prompts

**Example**: Need a Kubernetes architecture expert? Use [General Architecture Expert](general-architecture-expert.md) template and customize for Kubernetes.

---

## 📚 Template Metadata

### Frontmatter Standards for Template-Based Prompts

When creating a new prompt from a template, include this frontmatter:

```yaml
---
title: "[Your Prompt Title]"
author: "[Your Name]"
last_updated: "YYYY-MM-DD"
version: "1.0.0"
category: "[category]"
tags: ["[relevant tags]"]
status: "active"
based_on_template: "architecture/templates/[template-name].md"
template_version: "1.0.0"
audience: ["[target audiences]"]
mnemonic: "@[shortcut]"  # Optional, for quick access
---
```

This metadata helps:
- Track template lineage
- Identify prompts created from templates
- Update prompts when templates evolve
- Discover related prompts

---

## 🔍 Template Evolution

### Version Control
Templates are versioned independently:
- **Template versions** track changes to the template itself
- **Instance versions** track changes to prompts created from templates
- When templates are updated, instances *may* want to incorporate improvements

### Proposing Template Improvements
If you create a specialized prompt and discover patterns that should be in the template:
1. Document the pattern or improvement
2. Consider if it generalizes beyond your specific domain
3. Propose adding it to the relevant template
4. Update template version and changelog

### Creating New Templates
If you identify a new common pattern across 2-3 prompts:
1. Extract the common structure
2. Create a new template in this directory
3. Add `[PLACEHOLDERS]` for customization
4. Write a customization guide
5. Update this README to document the new template

---

## 📖 Examples: From Template to Specialized Prompt

### Example 1: Cloud Architecture Expert

**Starting from**: [General Architecture Expert](general-architecture-expert.md)

**Customizations**:
- `[ARCHITECTURE_DOMAIN]` → "Cloud"
- `[PRIMARY_FOCUS_AREAS]` → "AWS, Azure, and GCP cloud platforms"
- Add sections for:
  - Multi-cloud strategies
  - Cloud cost optimization
  - Cloud-native patterns (serverless, containers, managed services)
  - Well-Architected Framework principles

**Result**: A cloud architecture expert that understands cloud platforms, cost optimization, and cloud-native design patterns.

---

### Example 2: API Documentation Manager

**Starting from**: [Technical Documentation Architect](technical-documentation-architect.md)

**Customizations**:
- `[PROJECT_NAME]` → "API Platform"
- `[TECHNICAL_DOMAIN]` → "REST/GraphQL API design"
- Define domains: Authentication, Data Models, Endpoints, SDKs, Webhooks
- Content types: OpenAPI specs, SDK documentation, Integration guides
- Add sections for:
  - OpenAPI/Swagger spec generation
  - Code sample generation
  - Postman collection creation

**Result**: An API documentation system that manages OpenAPI specs, generates SDKs docs, and creates integration guides.

---

### Example 3: Mermaid Diagram Specialist

**Starting from**: [Visual Architecture Specialist](visual-architecture-specialist.md)

**Customizations**:
- `[DIAGRAM_TOOL/FORMAT]` → "Mermaid"
- Focus on text-based diagram generation
- Add Mermaid syntax examples for:
  - Flowcharts
  - Sequence diagrams
  - Class diagrams
  - Entity-relationship diagrams
  - State diagrams
  - Gantt charts
- Include Mermaid theming and styling

**Result**: A Mermaid specialist that generates markdown-embeddable diagrams with proper syntax and styling.

---

## 🎓 Learning Resources

To make the most of these templates, understand:

1. **Prompt Engineering Patterns**: See [meta/prompting-pattern-library/](../../meta/prompting-pattern-library/) for advanced techniques
2. **Meta-Prompt Engineer**: Use [@meta](../../meta/meta-prompt-engineer.md) to help create high-quality prompts from templates
3. **Prompt Librarian**: Use [@librarian](../../meta/librarian-prompt-management.md) to organize your template-based prompts

---

## 📊 Template Usage Matrix

| Template | Best For | Complexity | Time to Customize | Skills Needed |
|----------|----------|------------|-------------------|---------------|
| General Architecture Expert | Technical experts in specific domains | Medium | 30-60 min | Architecture knowledge |
| Technical Documentation Architect | Project documentation systems | High | 60-90 min | Documentation, taxonomy |
| Visual Architecture Specialist | Diagram/visualization tools | Medium | 45-75 min | Diagramming, visual design |

---

## 🤝 Contributing

If you create a valuable specialized prompt from these templates:
1. Consider whether the pattern should be added back to the template
2. Share your customization approach to help others
3. Document any challenges or improvements
4. Update this README with your example (optional)

---

## 📞 Getting Help

- **Creating a new prompt**: Use [@meta](../../meta/meta-prompt-engineer.md) for guidance
- **Organizing prompts**: Use [@librarian](../../meta/librarian-prompt-management.md)
- **Finding the right template**: Use [@nav](../../meta/nav-resource-navigator.md)
- **Understanding patterns**: See [prompting-pattern-library](../../meta/prompting-pattern-library/)

---

**Version History**
- v1.0.0 (2025-10-25): Initial template library with 3 core templates extracted from @architect, @arcdoc, and @drawio
