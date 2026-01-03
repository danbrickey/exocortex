# Data Vault 2.0 Terminology Glossary

Common Data Vault 2.0 concepts and terminology explained for non-technical audiences, sorted by frequency of use.

## Core Building Blocks

**Hub**
A table storing unique business identifiers that represent important business concepts like customers, products, or transactions. Think of it as a master list of unique things your business tracks.

**Link**
A table connecting two or more hubs together to show relationships, like "customer bought product" or "employee works on project." Links record how business concepts relate to each other.

**Satellite**
A table storing descriptive details about a hub or link, tracking all changes over time. If a customer changes their address, the satellite keeps both the old and new address with dates, maintaining complete history.

**Business Key**
The natural identifier your business uses to recognize something, like a customer number, product code, or invoice ID. Unlike system-generated IDs, these are meaningful identifiers people understand.

**Hash Key**
A computer-generated code that uniquely represents business keys, making data processing faster and more reliable across different technology platforms. Similar to a barcode that represents product information.

## Data Layers & Organization

**Raw Vault**
The foundation layer storing all data exactly as received from source systems without any business rules or calculations applied. This ensures you always have the original facts.

**Business Vault**
The layer where business rules, calculations, and interpretations are applied to raw data. This is where "revenue calculations" or "customer lifetime value" metrics are computed.

**Integration Layer**
The area where data from multiple source systems is combined using common business keys, creating a unified view across different systems and departments.

**Curation Layer**
The refined layer where data is shaped for specific business purposes like reports, dashboards, or machine learning models, making it ready for decision-making.

**Medallion Architecture**
A layered approach organizing data by quality and refinement: Raw (bronze), Integration (silver), and Curation (gold). Each layer serves a different purpose from storage to analysis.

## History & Change Tracking

**Time Travel**
The ability to look at your data as it existed at any past date, like viewing a snapshot of your customer list from last year exactly as it was then.

**Load Date**
The timestamp recording when data was received and stored, creating an audit trail showing when information entered the system.

**Effective Date**
The date when a piece of information became true in the real world, which may differ from when it was loaded into the system.

**Point-in-Time (PIT) Table**
A specially organized table making it easy to see how all related information looked at a specific moment in history, useful for historical reporting and compliance.

**Historical Tracking**
Maintaining a complete record of all changes to data over time rather than overwriting old values, ensuring nothing is ever lost or forgotten.

## Relationships & Connections

**Hub-and-Spoke Design**
The fundamental pattern where hubs (business concepts) sit at the center with links (relationships) and satellites (details) radiating outward, like spokes on a wheel.

**Many-to-Many Relationship**
A connection where multiple items can relate to multiple other items, like customers buying many products and products being bought by many customers.

**Foreign Key**
A reference pointing from one table to another, like a satellite pointing to its parent hub, establishing connections between related information.

**Bridge Table**
A helper table resolving complex many-to-many relationships to make reporting and analysis simpler for business users.

**Cross-System Consistency**
Using the same business identifiers across different computer systems so the same customer or product is recognized everywhere.

## Business Rules & Processing

**Hard Rules**
Technical processing rules that don't change the meaning of data, like ensuring dates are formatted consistently or removing duplicate records.

**Soft Rules**
Business interpretation rules that add meaning or change how data is understood, like calculating totals, standardizing addresses, or determining customer segments.

**Calculated Field**
A value computed from other data fields, like total revenue (price × quantity) or customer age (today - birth date), rather than directly recorded.

**Data Transformation**
The process of converting data from one format or structure to another, like turning raw transactions into monthly summaries for executives.

**Business Logic**
The rules and calculations that reflect how your organization operates, like discount policies, eligibility requirements, or performance metrics.

## Data Quality & Governance

**Record Source**
The identification of where data originally came from, like "billing system" or "customer portal," ensuring you can trace information back to its origin.

**Data Lineage**
The complete journey showing where data came from, what happened to it along the way, and where it ended up, like a family tree for your information.

**Auditability**
The ability to trace and verify every piece of data and change made, important for compliance, troubleshooting, and building trust in your data.

**Immutable Storage**
Storing data in a way that preserves original information permanently without modification, like a permanent record you can always refer back to.

**Data Stewardship**
The responsibility for ensuring data quality, proper usage, and governance, typically assigned to business experts who know what the data means.

## Technical Implementation

**Hash Function**
A mathematical formula converting business keys into standardized codes, ensuring consistent identification across systems and improving processing speed.

**Composite Key**
A unique identifier made up of multiple fields combined together, like "state + county + city" uniquely identifying a location.

**Grain**
The level of detail at which data is stored, like individual transactions (fine grain) versus daily summaries (coarse grain). Defines what each row represents.

**Micro-Partition**
Small, organized chunks of data stored efficiently for faster access, similar to organizing a filing cabinet by labeled sections rather than one big pile.

**Metadata**
Information describing your data, like column names, data types, and definitions, essentially "data about data" helping people understand what they're looking at.

## Architecture Patterns

**Scale-Free Architecture**
A design that can grow indefinitely without requiring structural changes, like adding new rooms to a house without changing the foundation.

**MPP (Massively Parallel Processing)**
Technology allowing many computers to work together simultaneously on large data tasks, dramatically speeding up processing like having many workers instead of one.

**Change Data Capture (CDC)**
Technology automatically detecting and capturing only the data that changed since last time, avoiding the need to reprocess everything.

**Real-Time Integration**
Continuously processing data as it arrives rather than in batches, providing up-to-the-minute information for time-sensitive decisions.

**NoSQL Platform**
Modern database technologies designed for flexible, large-scale data storage beyond traditional row-and-column databases, supporting diverse data types.

## Dimensional Modeling

**Dimensional Model**
A reporting-friendly structure organizing data into facts (measurements) and dimensions (descriptive categories) like sales amounts by product, region, and time.

**Star Schema**
A dimensional model layout where a central fact table connects to surrounding dimension tables, resembling a star shape when visualized.

**Fact Table**
A table storing measurable business events and metrics like sales transactions, website visits, or insurance claims with numeric values.

**Dimension Table**
A table storing descriptive attributes for analyzing facts, like customer details, product categories, or date information used for filtering and grouping.

**Information Mart**
A focused collection of data organized for specific business area analysis, like a "sales mart" or "customer mart" serving particular reporting needs.

## Agile Delivery Terms

**Sprint**
A short, focused work period (typically 2-3 weeks) where the team delivers specific, measurable improvements to the data platform.

**Work Breakdown Structure (WBS)**
A hierarchical decomposition of project work into smaller, manageable tasks that can be estimated, assigned, and tracked.

**Data Breakdown Structure (DBS)**
A hierarchical mapping of data entities and their relationships, showing how business concepts connect and flow through the system.

**Pattern-Based Delivery**
Using proven, standardized approaches repeatedly rather than custom-building everything, like using templates to ensure consistency and speed.

**Technical Debt**
Shortcuts or compromises made during development that need to be addressed later, like quick fixes that should eventually be replaced with proper solutions.

## Team Roles

**Data Architect**
The person designing the overall structure and organization of data across the enterprise, ensuring consistency and alignment with business strategy.

**Data Engineer**
The technical specialist building and maintaining data pipelines that move, transform, and prepare data for analysis.

**Business Analyst**
The bridge between business needs and technical implementation, translating requirements into specifications the technical team can build.

**Data Steward**
The business expert responsible for data quality, definitions, and proper usage within their domain, ensuring data serves business needs correctly.

**Scrum Master**
The facilitator ensuring the team follows agile practices, removing obstacles, and coordinating work across team members.

## Quality & Process

**Unit Test**
Verification that individual components work correctly in isolation before being combined with other parts, catching errors early.

**User Acceptance Test (UAT)**
Final validation where business users confirm the delivered solution meets their needs and requirements before production deployment.

**Data Validation**
Checks ensuring data is accurate, complete, and conforms to expected patterns and business rules before being used for decisions.

**Regression Testing**
Verifying that new changes didn't break existing functionality, ensuring the system continues working as expected after updates.

**Deployment**
The process of moving completed work from development through testing to production where business users can access it.

## Common Data Vault Terms

**Raw Data**
Information stored exactly as received from source systems without any modifications, preserving the original facts for reference and compliance.

**Staging Area**
A temporary workspace where data is initially landed from sources before being processed and loaded into the vault structure.

**Load Process**
The automated procedure moving data from source systems through staging into the hub, link, and satellite structures maintaining consistency.

**Insert-Only Pattern**
The practice of only adding new records without updating or deleting existing ones, preserving complete history and simplifying recovery.

**Business Event**
A significant occurrence worth tracking, like a customer purchase, policy change, or shipment, represented as data in the system.

**Source System**
The operational application or database where data originates, like a billing system, CRM, or claims processing application.

**Cross-Platform Compatibility**
The ability for data structures and processes to work across different technology platforms (SQL databases, cloud storage, NoSQL systems).

**Automation**
Using software to perform repetitive tasks consistently without manual intervention, reducing errors and increasing delivery speed.

**Enterprise Integration**
Connecting and coordinating data across the entire organization rather than isolated systems, creating a unified view of the business.

**Data-Driven Decision Making**
Using factual information and analysis rather than intuition alone to make business choices, enabled by reliable, accessible data.
