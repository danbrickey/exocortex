# Dan Brickey
## Curriculum Vitae

**Contact Information**
- Address: 16222 N Glacier Peak Dr, Nampa, ID 83651
- Phone: 208-286-8042
- Email: danbrickey@gmail.com

---

## Professional Summary

Data Platform Architect with 25+ years of progressive experience designing and implementing enterprise data solutions across healthcare, construction, and grant management sectors. Recognized expert in dimensional modeling (Kimball), Data Vault 2.0 methodology, and cloud-native data platform architecture. Currently leading Blue Cross of Idaho's strategic migration from on-premises SQL Server to a modern Snowflake-based Enterprise Data Platform while pioneering AI-enabled workflows for data engineering teams.

**Career Trajectory**: Evolved from hands-on ETL developer to enterprise architect, with deep technical expertise in data modeling, platform design, and team mentorship. Currently transitioning toward AI-native architecture roles, actively applying AI assistants (Claude Code, Microsoft Copilot) to accelerate documentation, code refactoring, and architectural decision-making. Pursuing Master's degree in Applied Artificial Intelligence (Fall 2026) to formalize AI capabilities and drive next-generation data platform innovation.

**Core Value Proposition**: Bridges traditional enterprise data architecture with modern AI-enabled practices. Capable of designing scalable data platforms while coaching teams to leverage AI for tactical work, enabling focus on higher-level architectural thinking and business value creation.

---

## Core Competencies

### Data Architecture & Methodology
- **Dimensional Modeling**: 20+ years Kimball methodology expertise; formal training with Margy Ross
- **Data Vault 2.0**: Extensive experience implementing Raw Vault, Business Vault, and Information Marts; trained by Dan Linstedt
- **Medallion Architecture**: Architecting multi-layer platforms (Raw → Integration → Curation → Consumption)
- **Master Data Management (MDM)**: Architecture and de-identification strategies
- **Data Privacy**: Multi-tenant privacy architecture for healthcare data exchanges

### Cloud & Modern Data Platforms
- **Snowflake**: Platform architecture, Cortex AI integration, performance optimization
- **dbt**: Transformation pipeline design, CI/CD implementation, testing frameworks
- **AWS**: S3-based data lakes, cloud-native ingestion patterns
- **GitLab**: Source control, collaboration workflows, CI/CD pipeline configuration

### Legacy & ETL Tools
- **WhereScape RED & 3D**: Advanced automation, metadata-driven development
- **SSIS, Informatica, Talend**: Enterprise ETL implementation
- **Custom ETL Frameworks**: Designed and implemented .NET-based ETL engines
- **MicroStrategy, Tableau, SSRS, SSAS**: Analytics and reporting layer design

### Database Platforms
- **SQL Server**: 25+ years; clustering, high-availability, performance tuning
- **Oracle**: Enterprise database administration, Unix environments
- **Snowflake**: 5+ years; data sharing, role-based access control (RBAC), cost optimization

### AI & Emerging Technologies
- **AI-Assisted Development**: Claude Code for documentation, refactoring, architectural analysis
- **Microsoft Copilot**: Code generation, team enablement, workflow acceleration
- **Snowflake Cortex AI**: Experimentation with ML-powered analytics
- **AI Strategy**: Training teams to use AI for tactical coding while elevating to architectural thinking

### Development & DevOps
- **Languages**: SQL (expert), Python, .NET/C#, Java, C
- **Source Control**: GitLab, GitHub, TFS
- **CI/CD**: Automated testing, deployment pipelines for dbt projects
- **SDLC**: Scrum, SAFe Agile, Kanban, Waterfall

### Domain Expertise
- Healthcare: Claims, enrollment, clinical (HL7/FHIR), pharmacy, provider networks
- Financial: Billing, grants management, fundraising analytics
- Retail: Point-of-sale, inventory, sales analytics
- Manufacturing: Production, materials management

### Leadership & Collaboration
- **Technical Mentorship**: 15+ years mentoring junior/mid-level engineers
- **Cross-Functional Engagement**: Translating business requirements into technical architecture
- **Standards Development**: Coding conventions, testing frameworks, documentation practices
- **Teaching**: 3 years adjunct professor (Boise State University) - Advanced Database Topics

---

## Professional Experience

### Blue Cross of Idaho | Meridian, ID
**Data & Solution Architect, Enterprise Data Platform** | March 2019 – Present

Returned to Blue Cross under new CIO leadership to lead two consecutive major platform transformations: (1) WhereScape/SQL Server rebuild of legacy EDW (2019-2022), compressing 10 years of work into 3-year timeline, and (2) Cloud migration to Snowflake-based Enterprise Data Platform (2023-present). Currently responsible for end-to-end architecture spanning 130+ data sources, Data Vault 2.0 modeling, dimensional analytics, and operational data pipelines serving internal analytics, external portals, API integrations, and regulatory reporting.

#### Platform Rebuild Phase: WhereScape/SQL Server EDW (2019-2022)

**Context & Challenge**
- Previous CIO postponed data warehouse rebuild decision, creating significant time pressure
- Legacy .NET-based EDW (built over 10 years) required complete reconstruction using modern tools
- Business demanded accelerated timeline: reproduce 10 years of development in 3 years
- Platform had to remain on-premises SQL Server (cloud migration not yet approved by leadership)

**Technical Leadership**
- **Lead Data Engineer**: Hands-on development role driving WhereScape RED implementation for Data Vault 2.0 modeling
- **Methodology**: Implemented proper Data Vault 2.0 structure (Raw Vault, Business Vault) to replace prior incomplete attempt
- **Platform Architecture**: SQL Server 3-node clustered HA environment; WhereScape RED for metadata-driven ETL automation
- **Intense Delivery**: Achieved 3-year rebuild timeline through combination of automation tooling, focused scope, and team dedication

**Outcomes**
- Successfully rebuilt enterprise data warehouse on modern tooling foundation
- Established proper Data Vault 2.0 patterns for future cloud migration
- Maintained business continuity throughout migration from legacy .NET platform
- Created foundation for subsequent cloud transformation

#### Cloud Migration Phase: Enterprise Data Platform on Snowflake (2023-Present)

**Transition & Architecture Evaluation (Mid-2022 to Late 2023)**
- **Enterprise Architecture Collaboration**: Participated in cross-functional evaluation of cloud platform options, tech stack decisions, and capability requirements alongside EA team
- **Technology Selection**: Contributed to decision analysis process for Snowflake (data platform), dbt (transformation), GitLab (source control), AWS S3 (data lake)
- **Official Transition**: Moved from WhereScape/SQL Server team to Enterprise Data Platform team in late 2023
- **Platform Standup**: Led initial Snowflake account configuration, dbt setup, security/RBAC implementation, tool integration

**Role Evolution (2023-Present)**
- **Late 2023 - Early 2024**: Lead Data Engineer driving initial migration pipelines and dbt framework
- **Mid-2024**: Transitioned to Data Architect role focusing on modeling and platform design
- **Late 2024 - Present**: Data & Solution Architect with expanded scope across technical architecture and business engagement

#### Platform Architecture & Design
- **Medallion Architecture Implementation**: Designed four-layer data platform (Raw → Integration → Curation → Consumption) supporting both analytical and operational use cases
- **Data Vault 2.0 Modeling**: Architected Raw Vault and Business Vault structures for 130+ source systems including 3-4 primary internal platforms (claims, enrollment, financial systems) plus government feeds, partner data, and file-based sources
- **Dimensional Model Design**: Created Kimball-style star schemas for key subject areas (claims, enrollment, provider networks, financials) enabling self-service analytics
- **Source System Complexity Management**: 80% of data volume from 4 core systems, enriched with 126+ external sources requiring diverse ingestion patterns

#### Technology Stack & Tools
- **Snowflake (AWS-hosted)**: Platform design, cost optimization, Cortex AI experimentation
- **dbt**: Transformation pipeline development, CI/CD integration, testing frameworks
- **GitLab**: Source control, collaboration, pipeline automation
- **Interop Partner Transition**: Architecting handoff of ingestion workloads to external partner while maintaining data lineage and quality controls
- **Legacy Migration**: Transitioning from SQL Server clustered HA environment (3-node cluster) with WhereScape RED to cloud-native dbt workflows

#### AI Enablement & Team Development
- **AI-Assisted Workflows**: Pioneered use of Claude Code (personal projects) and Microsoft Copilot (in-network) for documentation, code refactoring, and architectural analysis
- **Team AI Adoption**: Training 6-8 data engineers to leverage AI for code generation (80% usable starter code), testing, and documentation while elevating focus to architectural thinking
- **Workflow Acceleration**: Using AI to address documentation debt and enable "document as you work" practices without burning engineer time
- **Strategic Vision**: Preparing teams for future where AI handles tactical coding, enabling engineers to focus on pipeline optimization, cost management, and business value creation

#### Business Engagement & Standards
- **Subject Area Definition**: Partnering with business stakeholders to define data domains, business rules, and analytical requirements
- **Data Governance**: Establishing data quality frameworks, business glossary, and metadata management practices
- **Development Standards**: Created README-documented coding conventions and testing frameworks for dbt projects; actively working to expand documentation rigor
- **Mentorship**: Onboarding and skill development for 6-8 engineers across data modeling, SQL optimization, and architectural thinking

#### Measurable Outcomes
- **Platform Migration**: Successfully transitioning all enterprise analytics from on-prem to Snowflake, enabling retirement of legacy infrastructure
- **Operational Expansion**: Extending platform beyond analytics to support operational portals, APIs, partner data sharing, and government reporting
- **Cost Efficiency**: Offloading tedious ingestion work to interop partner, freeing engineering team to focus on business value and analytics
- **AI Readiness**: Building foundation for secure, governed AI/ML workloads using Snowflake Cortex and future LLM integrations

#### Technical Environment
- **Platforms**: Snowflake, AWS S3, GitLab, dbt Cloud
- **Methodologies**: Data Vault 2.0, Kimball Dimensional Modeling, Medallion Architecture
- **Data Volume**: Mid-sized healthcare payer (moderate volume, high complexity)
- **Team Structure**: Collaborative architecture role across multiple engineering teams (Admin, Ingestion, OneView, Extracts)

---

### Instant Health Analytics | Star, ID
**Data Warehouse Architect (Consultant)** | 2018 – 2019

Provided architecture and implementation consulting for healthcare and nonprofit clients, focusing on claims analytics, grant management, and healthcare interoperability standards. Gained exposure to multi-tenant privacy architecture and diverse data exchange formats (HL7, FHIR, EDI) while working across multiple concurrent engagements.

#### Client Engagements

**The PAN Foundation (Washington, DC)** | Grant Management & Claims Analytics
- **Client Context**: Nonprofit providing financial assistance for specific medical conditions; fundraising from pharmaceutical industry and other sources; business model requiring ability to scale operations (20-30 permanent employees, all IT/development outsourced to contractors)
- **Project Scope**: Designed and implemented data warehouse for analyzing claims, providers, patients, fundraising sources, and fund allocation
- **Data Modeling**: Created multiple fact tables measuring grant disbursements, fundraising effectiveness, and program outcomes by medical condition
- **Business Impact**: Enabled data-driven fund allocation and program performance tracking across earmarked condition-specific grants

**Idaho Health Data Exchange** | Multi-Payer Claims & Privacy Architecture
- **Client Context**: Independent healthcare information exchange supported by Idaho insurers (separate from state government and Department of Insurance)
- **Privacy Architecture**: Designed multi-tenant data protection strategies focused on individual patient privacy across multiple contributing payers (vs. single-company data protection)
- **EDI Integration**: Implemented claims data exchange workflows using EDI standards for secure multi-party data sharing
- **Technical Learning**: Deep exposure to healthcare interoperability challenges and privacy-first architecture patterns

**Internal Product Development** | Cloud-Based ETL Tool
- **Product Vision**: Designed architecture for cloud-native data transformation tool with native support for healthcare data standards
- **Format Support**: Specified capabilities for ingesting/exporting FHIR, HL7, and multiple EDI format families
- **Outcome**: Product development not completed; consulting company refocused on client services

#### Professional Insights & Career Direction
- **Consulting Experience**: Learned preference for depth over breadth; found rapid task-switching across mentally intensive projects frustrating vs. building deep expertise in single domain
- **Return to Blue Cross**: Chose to return after receiving 3 job offers; new CIO leadership and familiarity with team/culture made Blue Cross the best fit
- **Skills Gained**: Multi-tenant privacy patterns, healthcare interoperability standards, nonprofit analytics

**Technologies**: SQL Server, Oracle, HL7, FHIR, EDI standards, cloud data architecture patterns

---

### Blue Cross of Idaho | Meridian, ID
**Senior Data Warehouse Developer / Architect** | January 2006 – 2018

Progressed from senior developer to technical architect role over 12-year tenure, leading a 5-person EDW team (4 engineers + architect) through major platform builds and business-critical analytics initiatives. Balanced architectural leadership with hands-on development, operational data engineering, and extensive cross-functional project work outside core EDW scope.

#### Career Progression
- **2006-2012**: Senior Data Warehouse Developer (hands-on Kimball implementation, architectural discussions)
- **2012-2018**: Architect, Enterprise Data Warehouse (informal title; formal Blue Cross IT title remained "IT Engineer" with progressive pay grades)

#### Architectural Leadership (2012-2018)
- **Team Leadership**: Technical lead (non-managerial) for 5-person EDW team; separate BI team handled reporting/analytics
- **Platform Focus**: Kimball-based analytical platform; limited operational use cases during this period
- **Methodology Expertise**: Engaged in deep technical debates across Kimball, Inmon, and Data Vault (Linstedt) methodologies; forged custom solutions for edge cases not covered by standard patterns
- **Mentorship Culture**: Worked with architect mentors who involved entire team in design process; fostered collaborative decision-making and methodology discussions

#### Platform & Technologies
- **Custom ETL Engine**: Implemented (did not author) .NET-based ETL framework built in Visual Studio prior to tenure; no GUI, focused on functional data pipeline execution
- **Software Engineering Exposure**: Learned Agile software engineering practices through participation in ETL product team; gained perspectives on building engineered products vs. pure data engineering
- **Primary Stack**: SQL Server, .NET/Visual Studio, custom ETL framework
- **Architecture Assessment**: Custom ETL not recommended approach, but experience provided valuable cross-functional software engineering insights rare for data engineers

#### Operational & Special Projects
- **Beyond EDW Scope**: Led numerous operational data engineering projects outside core analytical platform
- **Operational Systems Design**: Built third-normal-form databases with stored procedures for specific business processes
- **Data Flows & Extracts**: Created custom data pipelines for business needs not suited to dimensional model
- **Cross-Functional Impact**: Delivered solutions across claims operations, enrollment, finance, and regulatory reporting

#### Team Development
- **Mentorship**: Onboarded and trained 6-8 developers throughout Blue Cross career (first and second tenure combined)
- **Skills Transfer**: Cross-trained team members on data modeling, SQL optimization, business requirement interpretation
- **Collaborative Culture**: Established pattern of whiteboarding sessions, methodology debates, and team-based design

#### Business Impact
- **Requirement Translation**: Interpreted complex business requirements within source system constraints
- **Cohesive Architecture**: Designed unified decision support architecture across disparate data sources
- **Dimensional Modeling**: Created logical and physical models enabling self-service analytics
- **Stakeholder Collaboration**: Partnered across functional areas to define solutions for business initiatives

**Technologies**: SQL Server, .NET/C#, Visual Studio, custom ETL frameworks, Kimball methodology, third-normal-form operational databases

**Reason for Departure**: Frustration with CIO leadership (innovation-focused but lacking execution capability); pursued consulting opportunity before returning in 2019 under new leadership

---

### Boise State University | Boise, ID
**Adjunct Instructor** | 2004 – 2007

Taught evening section of "Advanced Database Topics" (400-level course) for IT majors in Data & Analytics track. Course designed to transition students from Microsoft Access to enterprise relational database engines (Oracle, SQL Server, Sybase) in preparation for corporate data engineering roles.

#### Course Design & Delivery
- **Target Audience**: Senior-year students with prior Access experience; typically final database course before graduation
- **Platform**: Oracle database on Unix; students received individual database instances for hands-on work
- **Curriculum Focus**: Enterprise database concepts not covered in Access-centric coursework

#### Topics Covered
- **Advanced Indexing**: Clustering schemes, index optimization, performance implications
- **Relational Design**: Third-normal-form design, referential integrity, constraint management
- **Storage Management**: Disk allocation, tablespace configuration, I/O optimization
- **Performance Tuning**: Memory management, buffer cache optimization, query execution plans
- **Scalability**: Concepts for supporting thousands of concurrent users vs. single-user Access databases
- **Enterprise Operations**: Backup/recovery, transaction management, concurrency control

#### Teaching Philosophy & Impact
- **Accessibility**: Made complex enterprise database concepts approachable for students transitioning from desktop tools
- **Real-World Preparation**: Focused on concepts students would encounter in corporate data teams post-graduation
- **Student Engagement**: Helped students experience excitement of mastering new technical domains

#### Motivation & Career Context
- **Family Influence**: Father and uncle both professional educators; desire to experience teaching firsthand
- **Mentorship Alignment**: Teaching complemented natural mentorship inclinations in professional roles
- **Work-Life Balance**: Ended adjunct work in 2007 due to increasing demands at Blue Cross, young children at home, and IT department consolidation reducing adjunct needs

**Impact**: Prepared 3 cohorts of students for enterprise data careers; reinforced personal passion for making technical concepts accessible (skill now applied to team mentorship and cross-functional stakeholder engagement)

---

### Building Materials Holding Company (BMHC) | Boise, ID
**Data Warehouse Developer → Senior Database Programmer → Data Integration Lead** | 1997 – 2006

Started career at corporate headquarters of regional building materials company (BMC West lumber yards, truss plants, door shops across Intermountain West) after 3 years of branch-level work during college. Progressed from application development to founding member of company's first data warehouse team, gaining deep expertise in Kimball methodology and leading team through successful platform implementation.

#### Career Progression

**1994-1997: Branch Operations (During College)**
- Hired as forklift driver at Utah Valley lumber yard; quickly moved to computer-centric roles due to technical aptitude
- **Estimating & CAD Work**: Measured blueprints, created material quotes, engineered floor joist plans using CAD software with embedded engineering calculations
- **Systems Integration**: Built Microsoft Access-based interface between estimating software and point-of-sale system (first exposure to data integration challenges)

**1997-1999: Estimating Program Administrator (Corporate HQ)**
- Moved to Boise corporate office after earning BS in Information Technology (Utah Valley University, 1997)
- **Training & Support**: Managed estimating software for 20-30 branch estimators across BMC West locations
- **Interface Redesign**: Learned Access limitations; rebuilt estimating-to-POS interface in VB.NET for scalability
- **First Data Engineering**: Automated FTP-based data exchange between estimating system and point-of-sale servers; packaged executable for distribution
- **Skills Developed**: Multi-user application design, data format translation, deployment practices

**1999-2000: Point-of-Sale Customization Lead**
- Led transition from legacy "Dimensions" POS to new "NextTrend" platform
- **Team Leadership**: Supervised 3 programmers building custom menus and functions using NextTrend's programming hooks
- **Training & Enablement**: Attended vendor training; brought team up to speed rapidly; engineers performed at high level within 1 year

**2000-2006: Data Warehouse Team (Founding Member)**
- Joined newly formed in-house data warehouse team after dissatisfaction with consultant-built foundation
- **Team Structure**: Architect, DBA, and Dan (point-of-sale subject matter expert enabling source system extracts and business context)
- **Kimball Training**: Attended formal Kimball training and conferences; read ETL Toolkit thoroughly (published ~1995)
- **Collaborative Culture**: Extensive whiteboarding, methodology debates, team-based design process; highly engaged and passionate team
- **Long Hours, High Impact**: Intense work schedule building foundational analytics platform during company growth phase

#### Platform & Technologies
- **Primary Platform**: Oracle database on Unix
- **Methodology**: Kimball dimensional modeling
- **Subject Areas**: Point-of-sale, inventory, purchasing, financial analytics, external market data
- **Market Intelligence**: Integrated external construction market data with internal sales for market penetration analysis and trend forecasting

#### Business Impact & Market Insights
- **Growth Phase Analytics**: Supported company expansion and acquisitions in mid-2000s building boom
- **Market Downturn Signals (2005-2006)**: Data warehouse surfaced external signals of declining builder confidence, reduced contracts, and slowing home sales
- **Forecasting Accuracy**: Team identified early indicators of construction market downturn using combined internal/external data
- **Leadership Disconnect**: Company leadership ignored warning signals, preferring optimistic data interpretation; political use of analytics frustrated technical team
- **Career Decision**: Left for Blue Cross of Idaho in 2006; ~1 year later, construction market collapsed (2008 housing crisis), validating team's analysis

#### Professional Development
- **Foundational Skills**: Mastered dimensional modeling, ETL design, source system analysis, business requirement translation
- **Team Dynamics**: Learned collaborative design, technical debate, whiteboarding-driven architecture
- **Business Acumen**: Developed ability to read market signals and translate data into business insights (even when leadership doesn't listen)
- **Frustration with Politics**: Learned importance of data-driven culture and leadership receptive to analytical insights

**Technologies**: Oracle, Unix, VB.NET, Microsoft Access, point-of-sale systems (Dimensions, NextTrend), Kimball methodology

**Industry Context**: Low-tech industry (construction materials) with limited technology understanding among non-IT leadership; challenging environment for demonstrating analytics value

**Reason for Departure**: Frustration with leadership's unwillingness to act on data-driven market insights; entire team seeking opportunities as market signals deteriorated

---

## Education

### Utah Valley University | Orem, UT
**Bachelor of Science, Technology Management** | 1997

**Program Focus**: Engineering-oriented curriculum emphasizing systems thinking, optimization, and technical problem-solving across multiple disciplines

**Coursework Highlights**:
- **Electrical Engineering & Electronics**: Circuit design, systems analysis, signal processing fundamentals
- **Engineering Technology**: Applied engineering principles, technical specification, constraint optimization
- **Studio Engineering & Acoustics**: Audio signal processing, physics of acoustics and speech, sound system design
- **Technology Management**: Bridging technical depth with business application

**Academic Context**: Earned degree while working full-time at BMC West branch (1994-1997); hands-on experience with estimating software, CAD engineering, and systems integration directly complemented coursework

**Engineering Mindset**: Originally pursued audio engineering career path; discovered strong aptitude for data systems during early career. Engineering foundation—decomposing complex problems, optimizing within constraints, understanding signal flow and transformation—directly translates to data architecture work: modeling data domains, optimizing pipelines, and designing efficient transformation systems. This systems-level thinking approach differentiates problem-solving style and architectural decision-making throughout career.

---

## Continuing Education & Professional Training

### Formal Methodology Training
- **Kimball Dimensional Modeling** (Kimball Group) | Taught by Margy Ross (co-author, Kimball Toolkit)
- **Kimball ETL Toolkit** (Kimball Group) | Taught by Bob Becker; focus on systems architecture for ETL processes
- **Data Vault 2.0** (Multiple Instructors) | Training with Dan Linstedt and other Data Vault thought leaders at data conferences

### Cloud & Modern Platforms
- **Snowflake Fundamentals** | Basic technical course
- **Snowflake Architecture** | Platform design and optimization

### Professional Development
- **WhereScape RED & 3D** | Metadata-driven automation training
- **Multiple Industry Conferences** | Kimball Group, Data Vault Alliance, data architecture summits

**Certification Status**: Holds training certificates from Kimball Group, Data Vault courses, and Snowflake; no formal industry certifications (Snowflake SnowPro, AWS, etc.) at this time

---

## Graduate Education (Planned)

### Utah Valley University | Orem, UT
**Master of Science, Applied Artificial Intelligence** | Expected Start: Fall 2026

**Program Structure**:
- **Format**: Fully remote, designed for working professionals
- **Duration**: 5 semesters (continuous enrollment)
- **Cohort Model**: Scripted curriculum with fixed cohort through graduation
- **Location Advantage**: Now residing in Utah, a few miles from UVU campus (same university as undergraduate degree)

**Career Motivation**: Formalizing hands-on AI experience (Claude Code, Microsoft Copilot, Snowflake Cortex) with academic credentials to transition into AI-native data architecture roles. Goal is to combine 25+ years of enterprise data platform expertise with cutting-edge AI capabilities to drive next-generation analytics and intelligent automation.

---

## Technical Skills Summary

### Data Modeling & Architecture
- **Dimensional Modeling**: 20+ years (Kimball star schema, snowflake schema, conformed dimensions)
- **Data Vault 2.0**: Hubs, Links, Satellites, Business Vault, Information Marts
- **Third Normal Form**: OLTP database design, stored procedure development
- **Medallion Architecture**: Multi-layer platform design (Raw/Bronze, Integration/Silver, Curation/Gold, Consumption/Platinum)

### Cloud Data Platforms
- **Snowflake**: 5+ years (data sharing, RBAC, cost optimization, Cortex AI)
- **AWS**: S3-based data lakes, cloud-native ingestion
- **dbt**: Transformation development, testing, CI/CD integration

### ETL & Data Integration
- **WhereScape RED & 3D**: Metadata-driven automation
- **SSIS, Informatica, Talend**: Enterprise ETL tools
- **Custom Frameworks**: .NET-based ETL engines, VB.NET integration applications

### Analytics & BI
- **MicroStrategy, Tableau**: Analytics layer design
- **SSRS, SSAS**: SQL Server reporting and OLAP cubes
- **Self-Service Analytics**: Dimensional model design for business user accessibility

### Databases
- **SQL Server**: 25+ years (clustering, HA, performance tuning, administration)
- **Oracle**: 10+ years (Unix environments, enterprise operations)
- **Snowflake**: 5+ years (modern cloud data warehouse)
- **Sybase**: Historical experience

### Development Languages
- **SQL**: Expert level (T-SQL, PL/SQL, ANSI SQL)
- **Python**: Data engineering, automation
- **.NET/C#**: Application development, ETL frameworks
- **Java, C**: Earlier career experience

### DevOps & Source Control
- **GitLab**: Primary tool (source control, CI/CD, collaboration)
- **GitHub**: Personal projects, open-source exposure
- **TFS**: Legacy enterprise source control

### AI & Emerging Technologies
- **Claude Code**: Documentation generation, code refactoring, architectural analysis
- **Microsoft Copilot**: Code generation, team enablement
- **Snowflake Cortex AI**: ML-powered analytics experimentation
- **AI Strategy**: Training teams to elevate from tactical coding to architectural thinking

### Data Governance & Quality
- **Data Cleansing & Matching**: FirstLogic, custom solutions
- **De-identification**: Healthcare data privacy, HIPAA compliance
- **Master Data Management**: MDM architecture patterns
- **Data Quality Tools**: Anomalo (modern observability), DQS, MDS (SQL Server)

### Domain Expertise
- **Healthcare**: Claims (medical, pharmacy, dental), enrollment, provider networks, clinical data (HL7, FHIR)
- **Financial Services**: Billing, grants management, fundraising analytics
- **Retail & Manufacturing**: Point-of-sale, inventory, materials management, production analytics
- **Construction**: Market analysis, sales forecasting, operational analytics

### SDLC & Methodologies
- **Agile**: Scrum (daily standups, sprints, retrospectives), SAFe (scaled agile)
- **Kanban**: Work-in-progress management, continuous delivery
- **Waterfall**: Traditional SDLC (requirements, design, build, test, deploy)

---

## Professional Affiliations & Thought Leadership

### Industry Engagement
- **Kimball Group Alumni**: Trained directly by Margy Ross and Bob Becker
- **Data Vault Community**: Trained by Dan Linstedt; active in Data Vault 2.0 practitioner community
- **Snowflake Community**: Engaged in cloud data warehouse best practices

### Teaching & Mentorship
- **Adjunct Professor**: Boise State University (2004-2007), Advanced Database Topics
- **Career Mentorship**: 15+ years mentoring junior and mid-level data engineers
- **Knowledge Sharing**: Establishing documentation practices and architectural decision records

---

## Career Narrative & Future Direction

### Professional Evolution
Dan Brickey's 25-year career reflects a consistent progression from hands-on data engineering to enterprise architecture, with an emerging focus on AI-enabled data platforms. Starting with desktop integration challenges (Access-to-POS interfaces), he moved through enterprise ETL development, dimensional modeling, Data Vault implementation, and now cloud-native platform architecture. Each role built on the previous, creating a unique blend of tactical execution capability and strategic architectural thinking.

### AI Adoption Journey
Over the past year, Dan has proactively adopted AI tools (Claude Code, Microsoft Copilot, Snowflake Cortex AI) to accelerate workflows in documentation, code refactoring, and architectural analysis. This hands-on experience revealed AI's potential to handle tactical coding work, freeing engineers to focus on higher-value activities like pipeline optimization, cost management, and business value creation. He's now training data engineering teams to work in this new paradigm: AI generates starter code (~80% usable), engineers review/test/refine, and teams elevate to architectural thinking.

### Pursuit of Master's in Applied AI
Dan is pursuing a Master's degree in Applied Artificial Intelligence (Utah Valley University, Fall 2026 start) to formalize his hands-on AI experience with academic credentials. This reflects a strategic career pivot: combining 25+ years of enterprise data platform expertise with cutting-edge AI capabilities to become an AI-native data architect. The goal is to design next-generation platforms where AI agents handle data engineering tasks, humans provide oversight and strategic direction, and organizations achieve unprecedented agility and insight.

### Unique Value Proposition
Dan offers a rare combination:
- **Deep Technical Credibility**: 25+ years of hands-on data engineering, ETL development, and platform architecture
- **Methodology Expertise**: Formal training from industry legends (Margy Ross, Dan Linstedt, Bob Becker)
- **Business Acumen**: Proven ability to translate data into business insights (correctly forecasted 2008 housing crash)
- **AI Enablement**: Actively using AI tools to accelerate work; training teams to adopt AI-first workflows
- **Teaching & Mentorship**: 3 years adjunct professor + 15 years team mentorship = ability to make complex topics accessible
- **Enterprise Migration Leadership**: Leading real-world cloud migration (on-prem SQL Server → Snowflake) with 130+ data sources

### Target Roles & Industries
- **AI-Native Data Architect**: Designing platforms where AI agents handle tactical work, humans provide strategic oversight
- **Principal Data Engineer**: Leading teams in AI-enabled workflows, modern data stacks, and cloud-native architectures
- **Data Platform Strategist**: Advising organizations on AI readiness, platform modernization, and team capability development
- **Healthcare Data Leader**: Leveraging deep healthcare domain expertise (claims, clinical, privacy) in AI-forward organizations
- **Consulting/Advisory**: Sharing enterprise migration expertise and AI adoption strategies with multiple organizations

### Geographic Flexibility
- **Current Location**: Nampa, Idaho (Greater Boise area); recently relocated closer to family in Utah
- **Remote Work**: Extensive experience with remote collaboration tools and distributed teams
- **Relocation**: Open to opportunities requiring relocation for right role
- **Hybrid/On-site**: Comfortable with flexible work arrangements

---

## Additional Information

### Work Authorization
- **Status**: U.S. Citizen
- **Security Clearance**: None currently; open to pursuing if required

### References
Available upon request. References include:
- Current and former Blue Cross of Idaho leadership (CIO, Directors, Architects)
- Instant Health Analytics colleagues (consulting peers)
- BMHC/BMC West team members (data warehouse team)
- Boise State University IT Department (teaching references)

### Professional Interests
- AI agent frameworks for data engineering automation
- Semantic layer design for LLM-powered analytics
- Ethical AI and data privacy in healthcare
- Dimensional modeling for AI/ML feature stores
- AI-assisted documentation and knowledge management

### Personal Context
- **Family**: Married with children (balances career ambition with family priorities)
- **Continuous Learning**: Actively experimenting with Claude Code, LLMs, and AI-assisted workflows outside work hours
- **Community Engagement**: Previously taught university courses; interested in future teaching/speaking opportunities

---

**Document Version**: 1.0
**Last Updated**: January 2025
**Format**: Comprehensive CV (for detailed review; can be condensed to 2-3 page resume for applications)

