---
title: "Data Vault 2.0 & Architecture Modeling Guide"
author: "AI Expert Team Cabinet"
last_updated: "2024-12-09T17:30:00Z"
version: "1.0.0"
category: "engineering-guide"
tags: ["data-vault", "modeling", "architecture", "implementation"]
status: "active-reference"
audience: ["data-engineers", "architects", "developers"]
---

# Data Vault 2.0 & Architecture Modeling Guide
*A Comprehensive Reference for Data Modeling and Implementation Decisions*

---

## Table of Contents

1. [Data Vault 2.0 Fundamentals](#data-vault-20-fundamentals)
2. [Architecture Patterns & Layer Design](#architecture-patterns--layer-design)
3. [Data Vault Entity Design](#data-vault-entity-design)
4. [Business Rules & Data Processing](#business-rules--data-processing)
5. [Hash Keys & Technical Implementation](#hash-keys--technical-implementation)
6. [Agile Implementation Patterns](#agile-implementation-patterns)
7. [Team Roles & Collaboration](#team-roles--collaboration)
8. [Project Management Integration](#project-management-integration)
9. [Implementation Workflow Examples](#implementation-workflow-examples)

---

## Data Vault 2.0 Fundamentals

### Core Definition

**Data Vault 2.0** is a system of Business Intelligence comprised of three foundational pillars:

- **Model**: Flexible, scalable hub & spoke design based on set logic & MPP math
- **Methodology**: Consistent, repeatable, pattern-based approach
- **Architecture**: Multi-tier, scalable architecture supporting both relational and NoSQL platforms
- **Implementation**: Standardized patterns for automation and delivery

### Evolution from Data Vault 1.0

| **Data Vault 1.0** | **Data Vault 2.0** |
|---------------------|---------------------|
| Focused on modeling only | Comprehensive BI system |
| Relational data only | Includes big data, NoSQL platforms |
| Limited methodology | Full agile process, design, architecture |
| Basic hub & spoke | Enhanced with business vault, real-time processing |

### Data → Information → Knowledge Hierarchy

**Data Vault 2.0 Architecture** defines clear separation between data and information:

- **Data Layer (Raw Vault)**: Discrete elements and facts - immutable storage of business events
- **Information Layer (Business Vault)**: Processed data and perception - applied business rules and calculations  
- **Knowledge Layer (Dimensional Models)**: Mental application - analytical structures for decision making
- **Wisdom Layer**: Internalization - correct business choices based on knowledge

### Core Benefits

- **Scalability**: Handle growing data volumes and complexity
- **Flexibility**: Adapt to changing business requirements
- **Consistency**: Standardized modeling patterns across domains
- **Repeatability**: Automated, pattern-based delivery
- **Agility**: Rapid response to new requirements
- **Adaptability**: Support for both structured and unstructured data
- **Auditability**: Complete data lineage and change tracking

---

## Architecture Patterns & Layer Design

### Medallion Architecture Integration

**Our cloud platform follows medallion architecture principles with Data Vault methodology:**

#### Raw Layer (Bronze Equivalent)
- **Purpose**: Data lake with CDC-level activity from source systems
- **Content**: Files from vendors, business partners, external data sources
- **Data Vault Role**: Source data preparation for integration layer

#### Integration Layer (Silver Equivalent)  
- **Purpose**: Raw Vault following Data Vault 2.0 methodology
- **Content**: Hubs, links, and satellites describing data relationships
- **Function**: Integrate data into common data model with business keys

#### Curation Layer (Gold Equivalent)
- **Purpose**: Apply business rules to integrated Raw Vault data
- **Content**: 
  - Business Vault (calculated fields, business rules)
  - Kimball dimensional models (star schemas)
  - Fit-for-purpose data shapes (ML models, 3NF for applications)
  - Data shares and web portal extracts

#### Consumption Layer
- **Purpose**: Published selections from all previous layers
- **Consumers**: Extract services, applications, APIs, analytics, data science

### Layer Interaction Patterns

```
Sources → Staging → Raw Vault → Business Vault → Information Marts
    ↓         ↓         ↓            ↓              ↓
  Files    Hard      Hub &       Soft Rules    Dimensional
 & APIs    Rules    Spoke       Applied       Models &
           Only     Model                     Analytics
```

### Hard vs Soft Rules Placement

#### Staging Layer (Hard Rules Only)
- **Definition**: Rules that do NOT change content of individual fields or grain
- **Examples**:
  - Data type alignment
  - Normalization/denormalization  
  - Tagging (adding system fields)
  - De-duplication
  - Splitting by record structure

#### Business Vault (Soft Rules Applied)
- **Definition**: Rules that change or interpret data, or change grain of data
- **Examples**:
  - Concatenating name fields
  - Standardizing addresses
  - Computing monthly sales
  - Coalescing
  - Consolidation

---

## Data Vault Entity Design

### Three Basic Entity Types

#### 1. Hubs
- **Purpose**: Represent unique business concepts/entities
- **Content**: Business keys and metadata
- **Structure**:
  - Hash key (surrogate key)
  - Business key(s)
  - Load date timestamp
  - Record source

#### 2. Links  
- **Purpose**: Represent relationships between business concepts
- **Content**: Foreign key references to hubs
- **Structure**:
  - Hash key (based on related hub keys)
  - Hub hash key references
  - Load date timestamp
  - Record source

#### 3. Satellites
- **Purpose**: Store descriptive attributes and track changes over time
- **Content**: All non-key attributes with full history
- **Structure**:
  - Parent hash key (hub or link reference)
  - Load date timestamp (part of primary key)
  - Load end date timestamp
  - Descriptive attributes
  - Record source

### Hub & Spoke Design Benefits

- **Scale-Free Architecture**: Add new entities without affecting existing structures
- **Relationship Management**: Links enable complex many-to-many relationships  
- **Historical Tracking**: Satellites maintain complete change history
- **Cross-Platform Compatibility**: Hash keys work across NoSQL and RDBMS platforms

### Business Key Considerations

#### Business Key Identification
- **Stable Identifiers**: Keys that don't change over time
- **Cross-System Consistency**: Common keys across multiple source systems
- **Grain Definition**: Ensure keys match the intended level of detail
- **Composite Keys**: Multiple attributes may be required for uniqueness

#### Common Patterns
- **Customer Hub**: Customer ID, Customer Number, SSN
- **Product Hub**: Product Code, SKU, UPC
- **Transaction Hub**: Transaction ID, Invoice Number
- **Time Hub**: Date, Time Period identifiers

---

## Business Rules & Data Processing

### Business Vault Patterns

#### Calculated Fields
- **Revenue Calculations**: Sum of line items with tax and discount applications
- **Customer Metrics**: Lifetime value, recency, frequency calculations
- **Performance Indicators**: KPIs derived from multiple source systems

#### Point-in-Time (PIT) Tables
- **Purpose**: Provide consistent point-in-time views across multiple satellites
- **Use Cases**: Reporting as of specific dates, regulatory compliance
- **Structure**: Hub key + effective date + satellite load date references

#### Bridge Tables
- **Purpose**: Resolve many-to-many relationships for dimensional modeling
- **Examples**: Customer-Product relationships, Employee-Project assignments
- **Structure**: Dimension keys + effective dates + weighting factors

### Managed Self-Service BI Integration

#### Architecture Requirements
- **Direct access** to integrated information
- **Real-time updates** via change data capture
- **Write-back capability** for user modifications
- **Web & mobile accessibility** for business users
- **Visual lineage** showing data flow and transformations
- **Security controls** with role-based access

#### Risk Mitigation
- **Governance Framework**: Clear data ownership and stewardship
- **Metadata Management**: Comprehensive documentation of data definitions
- **Security Controls**: Row-level security and column masking
- **Modeling Standards**: Consistent dimensional and vault patterns
- **Controlled Deployment**: Automated testing and validation
- **Enterprise Vision**: Alignment with strategic data architecture

---

## Hash Keys & Technical Implementation

### Why Hash Keys in Data Vault 2.0?

#### Cross-Platform Compatibility
- **NoSQL Integration**: Hash keys work efficiently in both relational and NoSQL systems
- **Performance**: Consistent key structure improves join performance
- **Scalability**: Distribute data evenly across nodes in MPP systems

#### Implementation Benefits
- **Automation**: Hash generation enables automated model generation
- **Consistency**: Same business entity always generates same hash
- **Fault Tolerance**: Hash collisions are extremely rare with proper algorithms
- **Relationship Management**: Links use hash of combined business keys

### Common Hash Key Patterns

#### Hub Hash Keys
```sql
-- Customer Hub Example
SHA1(UPPER(TRIM(CUSTOMER_ID))) as CUSTOMER_HK

-- Product Hub Example  
SHA1(UPPER(TRIM(PRODUCT_CODE)) + '|' + UPPER(TRIM(VARIANT))) as PRODUCT_HK
```

#### Link Hash Keys
```sql
-- Customer-Product Link Example
SHA1(CUSTOMER_HK + '|' + PRODUCT_HK) as CUSTOMER_PRODUCT_LK
```

#### Satellite Dependencies
- Satellites reference parent hub or link hash keys
- No additional hash key generation required for satellites
- Composite primary key: Parent hash key + load date timestamp

---

## Agile Implementation Patterns

### Disciplined Agile Delivery Framework

#### Core Components
- **Sprint Plans**: 2-3 week delivery cycles with measurable outcomes
- **WBS (Work Breakdown Structure)**: Hierarchical task decomposition
- **OBS (Organizational Breakdown Structure)**: Roles and responsibilities
- **DBS (Data Breakdown Structure)**: Data entity mapping and lineage
- **PBS (Product Breakdown Structure)**: Deliverable components

#### Methodology Integration
- **SCRUM**: Sprint planning and daily coordination
- **CMMI Level 5**: Process maturity and continuous improvement
- **Six Sigma**: Quality measurement and defect reduction
- **TQM**: Total quality management principles
- **PMP**: Project management best practices

### Technical Numbering System

#### Purpose & Benefits
- **Optimization**: "We cannot optimize what we don't measure"
- **Measurement**: "We cannot measure what we don't identify"  
- **Identification**: "We cannot identify what we don't define"
- **Definition**: "We cannot define what we don't understand"

#### Application Areas
1. **Business Requirements** (B#.#)
2. **Technical Requirements** (T#.#)
3. **OBS - Roles & Responsibilities** (O#.#)
4. **PBS - Product Breakdown** (P#.#)
5. **DBS - Data Breakdown** (D#.#)
6. **WBS - Work Breakdown** (W#.#)
7. **Change Requests** (C#.#)

#### Sprint Plan Integration
Sprint plans serve as the "glue" linking all numbered documents together, providing traceability from requirements through implementation.

---

## Team Roles & Collaboration

### Typical Data Vault Team Structure

#### Core Team Members
- **Data Architect/EA**: Enterprise architecture and strategic guidance
- **Scrum/Agile Leader**: Process facilitation and team coordination
- **BI Specialist**: Analytics requirements and dimensional modeling
- **Data Integration Specialist**: ETL/ELT development and data pipeline management
- **Database Administrator**: Platform optimization and performance tuning

#### Extended Team Support
- **Business Sponsor**: Strategic direction and funding decisions
- **Technical Business Analyst**: Requirements gathering and validation
- **Quality Assurance**: Testing frameworks and data validation
- **Release Manager**: Deployment coordination and change management
- **Operations**: Production support and monitoring

### Technical Business Analyst Profile

#### Key Characteristics
- **Reports to Business**: Direct line to business stakeholders
- **Technical Skills**: Understanding of SQL and RDBMS concepts
- **Hands-On Approach**: Comfortable with data analysis and exploration
- **Collaborative**: Attends daily standups and works closely with IT
- **Problem Solving**: Escalates technical issues to business side
- **Answer-Oriented**: Focused on getting business questions answered

### Parallel Team Coordination

#### Enterprise Architecture Requirements
- **Standards**: Common modeling patterns and naming conventions
- **Templates**: Reusable design patterns and code structures
- **Guidelines**: Implementation best practices and quality criteria
- **Escalation Procedures**: Issue resolution and decision-making processes
- **Cross-Team Reviews**: Architecture validation and peer review
- **Small Scope**: Focused deliveries with clear boundaries
- **Enterprise Integration**: Alignment with broader architecture vision

#### Data Vault Model as Integration Point
- **Cross-over mechanism**: Teams integrate through shared Data Vault model
- **Link Tables**: Enable cross-functional data relationships
- **Common Business Keys**: Ensure consistent entity identification
- **Shared Hubs**: Reduce duplication across team implementations

---

## Project Management Integration

### Pattern Based Project Management (PBPM)

#### Required Standards Enforcement
**Technical Models**:
- Data modeling standards and conventions
- Process documentation and workflow patterns  
- Testing frameworks and validation procedures

**IT Processes**:
- Design review gates and approval criteria
- Build automation and code quality standards
- Deploy procedures and rollback processes
- Change management and version control

**Cultural Elements**:
- Escalation paths and decision-making authority
- Clear roles and responsibilities definition
- Skill level requirements and training plans
- Change management and communication protocols

### Team Rotation Strategy

#### Specialized Teams
- **Data Acquisition**: Source system integration and CDC implementation
- **Information Provisioning**: Business vault and dimensional model development
- **Data Exploration**: Analytics and self-service BI capabilities
- **Quality Assurance**: Testing frameworks and data validation
- **Change Management**: Deployment coordination and process improvement

#### Rotation Benefits
- **Knowledge Sharing**: Cross-training across domain areas
- **Risk Mitigation**: Reduced single points of failure
- **Skill Development**: Broader technical competency across teams
- **Innovation**: Fresh perspectives on established processes

---

## Implementation Workflow Examples

### Agile Delivery of Single Requirements (58 hours)

#### Phase 1: Scoping & Planning (1.5 hours)
1. **Choose Report to Produce** (0.5 hrs) - Define specific business requirement
2. **Estimate Work Effort** (0.5 hrs) - Size the implementation based on complexity  
3. **Fill in Risk Assessment** (0.5 hrs) - Identify potential challenges and mitigation

#### Phase 2: Source Analysis (4 hours)
4. **Identify Source/Stage Tables** (4 hrs) - Map source systems to requirements
   - Create Source to Requirements Matrix for traceability

#### Phase 3: Data Vault Design (8 hours)
5. **Design E-R Data Vault Model** (2 hrs) - Identify hubs, links, and relationships
6. **Add Attributes to ER Model** (6 hrs) - Define satellite structures and business rules

#### Phase 4: Raw Vault Implementation (4 hours)
7. **Create ETL Data Vault Loads** (4 hrs total):
   - Hub Loads (1 hr)
   - Link Loads (1 hr)  
   - Satellite Loads (2 hrs)

#### Phase 5: Business Vault & Dimensional Design (20 hours)
8. **Design Data Mart Model** (4 hrs) - Create dimensional model for analytics
9. **Create ETL Data Vault to Information Mart** (16 hrs):
   - Build Dimension Loads (8 hrs)
   - Build Fact Loads (8 hrs)

#### Phase 6: Validation & Documentation (13 hours)
10. **Build Report and Produce Output** (8 hrs) - Implement analytics layer
11. **Create Source-to-Target Report** (2 hrs) - Document data lineage
12. **Unit Test** (4 hrs) - Validate data quality and business rules
13. **Record Actual Effort** (0.5 hrs) - Capture metrics for estimation improvement

#### Phase 7: Deployment (5.5 hours)
14. **Sign-off** (1 hr) - Business acceptance and approval
15. **Deploy to Test Environment** (2 hrs) - Staging deployment and validation
16. **Run User Acceptance Test** (2 hrs) - Business user validation
17. **Deploy to Production** (1 hr) - Final production deployment

### Data Requirements Gathering Process

#### Step 1: Data Requirements
- **Scope Focus**: Model only what's in scope for rapid output  
- **Scope Reduction**: Minimize complexity for faster delivery
- **Raw Data Loading**: Load facts to EDW without transformation
- **Business Key Integration**: Integrate by common business keys

#### Step 2: Raw Mart Production  
- **No Business Rules**: Simple format conversion to dimensional model
- **Format Change Only**: Transform Data Vault to dimensional structure
- **Real-time Integration**: Use ESB for real-time data feeds

#### Step 3: Raw Reports
- **Good, Bad, and Ugly**: Include all data quality levels initially
- **Print Reports**: Generate initial output for business validation
- **Feedback Loop**: Use raw reports to refine requirements

---

## Architecture Components Summary

### Key Implementation Principles

1. **Automation Focus**: Agile methodology emphasizes repeatable, consistent, standardized patterns
2. **Architecture Benefits**: Enhanced de-coupling, low impact changes, managed self-service BI, hybrid platform support
3. **Scale-Free Model**: Hub and spoke design enables unlimited growth without structural changes
4. **Cross-Platform Compatibility**: Hash keys and standard patterns work across NoSQL and RDBMS platforms
5. **Quality Integration**: Built-in data lineage, change tracking, and audit capabilities

### Success Metrics

- **Delivery Speed**: 2-3 week sprint cycles with working software
- **Quality Measures**: Comprehensive testing and validation at each layer
- **Business Value**: Direct connection between technical implementation and business outcomes
- **Operational Excellence**: Managed, measured, optimized, controlled, and estimated processes
- **Team Effectiveness**: Clear roles, standard processes, and continuous improvement

---

*This guide serves as a comprehensive reference for data modeling and architecture decisions within our Data Vault 2.0 and medallion architecture implementation. Use it to guide design decisions, validate implementation approaches, and ensure consistency across the platform development.*