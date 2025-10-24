# Unified C4-DDD Architecture Guide
*Combining C4 Diagramming with Domain-Driven Design for Data, Process, and System Architecture*

## Executive Summary

This guide integrates the C4 Model's clear visual hierarchy with Domain-Driven Design's business-aligned modeling approach, creating a unified framework for enterprise architecture that works across data modeling, process modeling, and system architecture.

**The Core Insight:** Both C4 and DDD move from strategic business concerns down to tactical implementation details. By aligning these approaches, we create consistency across all architectural artifacts and ensure business alignment at every level.

## Framework Overview

### Level Alignment Matrix

| C4 Level | DDD Level | Scope | Audience | Key Artifacts |
|----------|-----------|-------|----------|---------------|
| **C1: System Context** | **Enterprise/Business Domain** | Industry positioning & major business areas | C-Suite, Business Strategy | Context maps, Domain landscapes, Value streams |
| **C2: Container** | **Bounded Context** | Business capabilities & their technical implementations | Department heads, Solution architects | Service maps, Process flows, Data flows |
| **C3: Component** | **Aggregate** | Business concepts & their technical components | Team leads, Senior developers | Component diagrams, Data models, Process details |
| **C4: Code** | **Entity/Value Object** | Implementation details | Developers, Data analysts | Class diagrams, Database schemas, API specs |

---

## Level 1: System Context / Enterprise Domain

**Purpose:** Show how your organization fits within the industry ecosystem and identify major business domains.

### Data Modeling at C1 Level
**Focus:** Information domains and external data relationships

**Artifacts:**
- **Information Architecture Map:** Shows major categories of information (Customer, Product, Financial, Operational)
- **External Data Ecosystem:** Third-party data sources, regulatory reporting, industry standards
- **Data Domain Boundaries:** High-level information territories and ownership

**Example - Healthcare Insurance Company:**
```
External Data Sources:
├── Provider Networks (Credentialing data)
├── Government Systems (Eligibility, Claims)
├── Pharmacy Networks (Drug pricing, formularies)
├── Banking Systems (Premium payments, Claims payments)
└── Third-Party Administrators (Secondary coverage)

Internal Data Domains:
├── Member Domain (Enrollment, demographics, coverage)
├── Provider Domain (Contracts, credentials, payments)
├── Claims Domain (Medical, pharmacy, dental processing)
├── Financial Domain (Premiums, reserves, reporting)
└── Regulatory Domain (Compliance, audit, reporting)
```

### Process Modeling at C1 Level
**Focus:** Core value streams and external process interactions

**Artifacts:**
- **Value Stream Map:** End-to-end business value delivery
- **External Process Integration:** How organization processes interact with industry processes
- **Business Capability Model:** What the organization does (not how)

**Example - Healthcare Insurance Value Streams:**
```
Member Lifecycle:
Prospect → Enrollment → Coverage → Renewal/Termination

Provider Lifecycle:  
Recruitment → Contracting → Credentialing → Payment → Performance Management

Claims Lifecycle:
Service Delivery → Claims Processing → Payment → Quality Assurance
```

### System Architecture at C1 Level
**Focus:** How your technical ecosystem fits within industry technology landscape

**Artifacts:**
- **Technology Context Diagram:** Your systems and key external systems
- **Integration Architecture:** Major data exchanges and process integrations
- **Technology Domain Map:** High-level technical capabilities

---

## Level 2: Container / Bounded Context

**Purpose:** Show business capabilities and their supporting technology containers, with clear ownership boundaries.

### Data Modeling at C2 Level
**Focus:** Data ownership, integration patterns, and service boundaries

**Artifacts:**
- **Data Ownership Map:** Which context owns which data aggregates
- **Data Integration Architecture:** How data flows between contexts
- **Data Product Interfaces:** APIs and events that contexts expose

**Example - Provider Domain Containers:**
```
Provider Domain
├── Provider Contracting Service (PostgreSQL + REST API)
│   └── Owns: Contract terms, rates, negotiations
├── Provider Credentialing Service (MongoDB + Event Stream)
│   └── Owns: License verification, specialty validation
├── Provider Payment Service (SQL Server + Batch Processing)
│   └── Owns: Payment calculations, check printing
└── Provider Directory Service (ElasticSearch + GraphQL)
    └── Owns: Provider search, location data
```

### Process Modeling at C2 Level
**Focus:** Business processes within bounded contexts and cross-context orchestration

**Artifacts:**
- **Context Process Maps:** Key processes owned by each bounded context
- **Cross-Context Choreography:** How processes span multiple contexts through events
- **Service Responsibility Matrix:** Which context handles which business processes

**Example - Claims Processing Choreography:**
```
Claims Submission Process:
1. Member Portal (Submit Claim) → ClaimSubmitted Event
2. Claims Processing Context (Validate Claim) → ClaimValidated Event  
3. Provider Context (Verify Provider) → ProviderVerified Event
4. Benefits Context (Check Coverage) → CoverageVerified Event
5. Payment Context (Process Payment) → PaymentProcessed Event
6. Member Context (Send Notification) → NotificationSent Event
```

### System Architecture at C2 Level
**Focus:** Technology containers, their responsibilities, and communication patterns

**Artifacts:**
- **Container Diagram:** Applications, databases, message queues
- **Technology Stack Map:** What technologies each container uses
- **Integration Patterns:** Sync/async, events, APIs, batch processes

---

## Level 3: Component / Aggregate

**Purpose:** Show the internal structure of business capabilities and their supporting technical components.

### Data Modeling at C3 Level
**Focus:** Business data concepts and their relationships within contexts

**Artifacts:**
- **Aggregate Design:** Groups of related entities that change together
- **Domain Model Diagrams:** Entities, value objects, and their relationships
- **Data Consistency Boundaries:** Transaction and consistency rules

**Example - Order Management Aggregate:**
```
Order Aggregate:
├── Order Entity (Order ID, Status, Total)
├── OrderLine Entity (Product, Quantity, Price)
├── ShippingInfo Value Object (Address, Method, Cost)
├── PaymentInfo Value Object (Method, Authorization)
└── OrderHistory Entity (Status changes, timestamps)

Business Rules:
- Order lines can only be modified if Order.Status = "Draft"
- Payment must be authorized before Order.Status = "Confirmed"
- All changes to aggregate must happen in single transaction
```

### Process Modeling at C3 Level
**Focus:** Detailed business processes and workflows within components

**Artifacts:**
- **Process Component Diagrams:** How business logic components interact
- **Workflow Specifications:** Detailed process flows with decision points
- **Business Rule Documentation:** Domain logic and constraints

**Example - Order Processing Component Flow:**
```
Order Processing Workflow:
1. Order Validation Component
   ├── Validates customer information
   ├── Checks inventory availability  
   └── Verifies payment method
2. Price Calculation Component
   ├── Applies customer discounts
   ├── Calculates shipping costs
   └── Computes taxes
3. Order Fulfillment Component
   ├── Reserves inventory
   ├── Initiates payment processing
   └── Triggers shipping workflow
```

### System Architecture at C3 Level
**Focus:** Internal components of containers and their technical interactions

**Artifacts:**
- **Component Architecture Diagrams:** Classes, modules, services within containers
- **API Specifications:** Internal and external interfaces
- **Data Access Patterns:** How components interact with data stores

---

## Level 4: Code / Entity-Value Object

**Purpose:** Implementation-level details for developers and data analysts.

### Data Modeling at C4 Level
**Focus:** Detailed data structures, schemas, and implementation specifics

**Artifacts:**
- **Entity Relationship Diagrams:** Database table structures
- **API Schema Definitions:** JSON schemas, GraphQL types
- **Data Validation Rules:** Field constraints, business rule implementations

### Process Modeling at C4 Level
**Focus:** Detailed algorithm specifications and implementation logic

**Artifacts:**
- **Algorithm Specifications:** Step-by-step process implementations
- **State Machine Definitions:** Detailed status transitions
- **Exception Handling Specifications:** Error conditions and recovery processes

### System Architecture at C4 Level
**Focus:** Code-level architecture and detailed technical specifications

**Artifacts:**
- **Class Diagrams:** Object-oriented design details
- **Database Schema:** Table structures, indexes, constraints
- **Interface Specifications:** Method signatures, parameters, return types

---

## Practical Application Guidelines

### For Project Planning and Estimation

**Level 1 Activities (ECC - Estimating Council):**
- Business case development and strategic alignment assessment
- High-level domain impact analysis and regulatory considerations
- Industry positioning and competitive analysis for rural health insurance market
- Executive budget approval for detailed research phase
- Estimated 5-10% of total project effort

**Level 2 Activities (ARB - Architectural Review Board):**
- Architecture planning and technology selection decisions
- Service boundary definition and integration design
- Security architecture and HIPAA compliance planning  
- Technology stack approval and contract definition
- Estimated 15-20% of total project effort

**Level 3-4 Activities (Feature Teams & Engineering):**
- Detailed design and component specification (Level 3)
- Development, testing, and deployment (Level 4)
- Database design and API implementation
- Unit testing, integration testing, and quality assurance
- Estimated 70-80% of total project effort

### For Communication and Documentation

**ECC (Estimating Council) Presentations:**
- Use Level 1 (Context/Domain) artifacts exclusively
- Focus on business value, regulatory compliance, and strategic market positioning
- Show rural health insurance ecosystem positioning and competitive advantages
- Emphasize regulatory risk mitigation and compliance benefits

**ARB (Architectural Review Board) Reviews:**
- Use Level 2 (Container/Bounded Context) artifacts as primary focus
- Include Level 3 (Component/Aggregate) details for high-risk or brand-new components
- Focus on system integration patterns, security architecture, and technology choices
- Show service boundaries, data ownership, and cross-system data flows
- Address HIPAA compliance, scalability, and operational considerations

**Feature Team Planning:**
- Use Level 3 (Component/Aggregate) artifacts for roadmap and sprint planning
- Focus on component interactions, business logic organization, and development task boundaries
- Show data dependencies and testing strategies
- Include lifecycle progress indicators for tracking development phases

**Engineering Team Implementation:**
- Use Level 4 (Code/Entity) artifacts for detailed development work
- Focus on code interaction mapping, data structure specifications, and integration details
- Include progress tracking with Design ⟨D⟩, Build ⟨B⟩, Test ⟨T⟩, Deploy ⟨P⟩ indicators
- Show technical dependencies and unit testing specifications

### Lifecycle Progress Tracking System

**Visual Progress Indicators:**
- **⟨D⟩ Design Phase:** Requirements analysis, technical specification, architecture decisions
- **⟨B⟩ Build Phase:** Active development, code implementation, database creation
- **⟨T⟩ Test Phase:** Unit testing, integration testing, user acceptance testing
- **⟨P⟩ Production Phase:** Deployed, operational, monitored in production

**Application Across Levels:**
- **Level 2:** Track bounded context implementation progress
- **Level 3:** Track aggregate and component development phases  
- **Level 4:** Track individual entity, API, and database schema progress

**Benefits:**
- Visual understanding of project progress across all architectural levels
- Clear identification of dependencies and blocking issues
- Consistent progress reporting from engineering teams to ARB and ECC
- Early identification of components that may impact project timelines

### For Organizational Alignment

**Conway's Law Optimization:**
Align team structures with bounded context boundaries:
- Each bounded context should ideally have a dedicated team
- Cross-context coordination through well-defined events and APIs
- Team autonomy within context boundaries

**Change Management:**
When business processes change:
1. **Level 1-2:** Update domain and context mappings first
2. **Level 3:** Refactor affected aggregates and components  
3. **Level 4:** Implement detailed code and data changes
4. This creates predictable change propagation patterns

---

## Integration with Existing Enterprise Architecture

### Alignment with TOGAF/Zachman
- **Level 1:** Aligns with TOGAF Business Architecture
- **Level 2:** Maps to TOGAF Application and Data Architecture  
- **Level 3-4:** Covers TOGAF Technology Architecture details

### Alignment with Agile/DevOps
- **Bounded Contexts** become natural microservice boundaries
- **Aggregates** define API and database boundaries
- **Events** enable loose coupling and independent deployment
- **Domain teams** align with DevOps team topologies

### Tool Integration Recommendations
- **Level 1-2:** Archimate, LucidChart, or Miro for strategic modeling
- **Level 3:** Enterprise Architect, draw.io, or PlantUML for technical design
- **Level 4:** IDE tools, database design tools, API documentation tools

---

---

## AI Assistant Integration Framework

### Context for AI Architect Sub-Agent

**Industry Domain Knowledge:**
- **Health Insurance Payer Organization:** Mid-sized rural market, complex regulatory environment
- **Key Regulations:** HIPAA, ACA, CMS guidelines, State insurance regulations
- **Business Model:** Premium collection, claims processing, provider network management, member services
- **Rural Challenges:** Network adequacy, provider recruitment, telehealth integration, member travel distances

**Technical Architecture Principles:**
- **Data Vault 2.0:** All data modeling follows hub/link/satellite patterns with full historization
- **Event-Driven Architecture:** Bounded contexts communicate through events and APIs
- **Microservices Pattern:** Each bounded context typically maps to one or more microservices
- **HIPAA Compliance:** All data handling must maintain audit trails and access controls
- **Scalability Requirements:** Support for seasonal enrollment periods and claim volume spikes

**Diagram Generation Standards:**
```json
{
  "visual_standards": {
    "colors": {
      "regulatory_systems": "#FF6B6B",
      "clinical_systems": "#4ECDC4", 
      "financial_systems": "#45B7D1",
      "operational_systems": "#96CEB4",
      "external_systems": "#FECA57"
    },
    "shapes": {
      "bounded_context": "rectangle_rounded",
      "external_system": "rectangle_sharp",
      "database": "cylinder",
      "message_queue": "diamond",
      "api_endpoint": "circle"
    },
    "lifecycle_indicators": {
      "design": "⟨D⟩",
      "build": "⟨B⟩", 
      "test": "⟨T⟩",
      "production": "⟨P⟩"
    }
  }
}
```

### Context for AI Presentation Specialist Sub-Agent

**Audience-Specific Formatting:**

**ECC (Estimating Council) - Level C1:**
- **Slide Count:** 5-7 slides maximum
- **Content Focus:** Business impact, regulatory compliance, strategic positioning
- **Visual Style:** Executive summary graphics, minimal technical detail
- **Key Messages:** ROI, risk mitigation, competitive advantage, regulatory alignment
- **Language:** Business terminology, avoid technical jargon

**ARB (Architectural Review Board) - Level C2-C3:**
- **Slide Count:** 15-20 slides for standard review, 25-30 for high-risk items
- **Content Focus:** Technical architecture, integration patterns, security, scalability
- **Visual Style:** Detailed system diagrams, architecture patterns, data flows
- **Key Messages:** Technical decisions, integration complexity, performance implications
- **Language:** Technical architecture terminology, specific technology choices

**Engineering Teams - Level C4:**
- **Format:** Technical documentation, not slide presentations
- **Content Focus:** Implementation specifications, code interactions, database schemas
- **Visual Style:** Detailed technical diagrams, ERDs, API specifications, DAG workflows
- **Key Messages:** Development guidance, technical dependencies, implementation standards
- **Language:** Development terminology, specific technical specifications

**Universal Presentation Standards:**
- Include company branding and style guidelines
- Use consistent color coding across all diagram levels
- Show clear relationships between different architectural levels
- Include progress tracking where applicable
- Provide clear legends for all diagrams

### Data Structure Templates for AI Consumption

**Project Context Template:**
```json
{
  "project_name": "string",
  "project_type": "enhancement|new_development|integration|regulatory",
  "target_audience": "ECC|ARB|feature_teams|engineering",
  "scope": "enterprise|domain|bounded_context|component|implementation",
  "regulatory_impact": "high|medium|low|none",
  "business_domains_affected": ["array", "of", "domain", "names"],
  "timeline": {
    "research_phase": "date_range",
    "architecture_phase": "date_range", 
    "development_phase": "date_range",
    "deployment_phase": "date_range"
  }
}
```

**Diagram Generation Request Template:**
```json
{
  "diagram_type": "C1_context|C2_container|C3_component|C4_table|C4_dag",
  "output_format": "mermaid|plantuml|draw.io|lucidchart", 
  "audience": "ECC|ARB|feature_teams|engineering",
  "focus_area": "string_description",
  "include_lifecycle_phases": true|false,
  "include_data_flows": true|false,
  "include_security_boundaries": true|false,
  "business_context": {
    "domains": ["list", "of", "affected", "domains"],
    "processes": ["list", "of", "business", "processes"],
    "regulations": ["list", "of", "applicable", "regulations"]
  }
}
```

### Quality Assurance Guidelines for AI

**Diagram Validation Checklist:**
- [ ] All external systems properly labeled with integration type
- [ ] Business domains clearly distinguished from technical components  
- [ ] Data flows show direction and include data types/volumes where relevant
- [ ] Security boundaries and HIPAA compliance considerations visible
- [ ] Lifecycle phases accurately reflect current project status
- [ ] Consistent naming conventions used throughout
- [ ] All acronyms defined in legend or glossary
- [ ] Diagram complexity appropriate for target audience

**Documentation Standards:**
- Include business context for all technical decisions
- Reference applicable regulations and compliance requirements  
- Provide clear traceability between architectural levels
- Include change management and impact assessment considerations
- Document assumptions and constraints clearly
- Reference industry best practices and standards where applicable