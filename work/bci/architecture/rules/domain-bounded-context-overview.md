---
title: "EDP Business Domain and Bounded Context Overview"
author: "Dan Brickey"
created: "2025-10-23"
last_updated: "2025-10-23"
version: "1.1.0"
status: "draft-for-business-review"
audience: ["business-leaders", "domain-experts", "data-architects", "edp-team"]
purpose: "Define business domains and bounded contexts for domain-driven data architecture"
related_documents:
  - "docs/architecture/edp_platform_architecture.md"
  - "docs/architecture/edp-layer-architecture-detailed.md"
tags: ["domain-driven-design", "business-domains", "bounded-contexts", "data-architecture"]
---

# EDP Business Domain and Bounded Context Overview

## Purpose

This document defines the business domains and their bounded contexts for the Enterprise Data Platform (EDP). It serves as a **working document** to align business ownership, identify domain experts, and establish clear boundaries for data architecture and governance.

**This is a STARTER document** - bounded context assignments, ownership, and boundaries should be validated and refined with business department leaders.

---

## Domain Overview

The EDP organizes data around **nine core business domains**:

| Domain | Primary Purpose | Business Department(s) |
|--------|----------------|------------------------|
| **Provider** | Managing healthcare provider relationships, networks, credentials, and contracts | Network Management, Provider Relations |
| **Membership** | Managing member enrollment, eligibility, coverage, and demographics | Enrollment, Member Services |
| **Broker** | Managing broker/agent relationships, commissions, and sales channels | Sales, Broker Relations |
| **Claims** | Processing payment requests for healthcare services | Claims Operations, Claims Adjustment, Customer Service |
| **Financial** | Managing financial transactions, accounting, billing, and reporting | Finance, Accounting, Premium Billing |
| **Product** | Defining insurance products, benefit structures, and plan designs | Product Development, Actuarial |
| **Clinical** | Managing medical necessity, care coordination, and quality programs | Medical Management, Care Management, Quality, Government Programs, Risk/STARS |
| **Legal & Compliance** | Managing regulatory compliance, fraud prevention, legal matters, and risk management | Legal & Compliance |
| **HR** | Managing internal employee data, benefits, and human resources | Human Resources, Payroll |

---

## Domain Definitions

### 1. PROVIDER DOMAIN

**Domain Purpose**: Manage all aspects of healthcare provider relationships including credentialing, network participation, contracting, and directory services.

#### Bounded Contexts

##### 1.1 Provider Directory
**Purpose**: Maintain searchable provider information for members and internal use

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Provider demographic data management
- Provider search and directory publishing
- Specialty/taxonomy classification
- Provider location and contact information maintenance

**Data Categories**:
- Provider identifiers (NPI, Tax ID, State License)
- Provider demographics (name, address, phone, email)
- Provider type, specialty, taxonomy codes
- Practice/facility affiliations
- Languages spoken, accessibility features

##### 1.2 Network Management
**Purpose**: Manage provider network participation and status

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Network enrollment/termination
- In-network vs out-of-network status determination
- Network tier assignment
- Accepting new patients status tracking

**Data Categories**:
- Network participation status
- Network tier (if applicable)
- Effective dates, termination dates
- Network assignment by product/geography
- Panel status (open/closed to new patients)

##### 1.3 Provider Credentialing
**Purpose**: Verify and maintain provider qualifications and credentials

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Initial credentialing verification
- Re-credentialing (typically every 2-3 years)
- License verification and expiration tracking
- Sanction monitoring (OIG, state medical boards)
- Quality assessment

**Data Categories**:
- License numbers, expiration dates, verification dates
- Board certifications
- DEA registration (for prescribers)
- Malpractice insurance coverage
- Hospital privileges
- Quality scores, sanctions, disciplinary actions
- Credentialing application documents

##### 1.4 Provider Contracting
**Purpose**: Manage provider contracts, fee schedules, and reimbursement terms

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Contract negotiation and execution
- Fee schedule maintenance
- Contract renewal and amendments
- Performance guarantee tracking
- Contract compliance monitoring

**Data Categories**:
- Contract ID, type (FFS, capitation, value-based)
- Contract effective/termination dates
- Fee schedules, reimbursement rates (by CPT/DRG)
- Performance guarantees, quality metrics
- Auto-renewal clauses, contract terms
- Capitation rates (if applicable)

#### Data Sources
- **Provider enrollment applications**: Initial provider demographic and credential data
- **CAQH (Council for Affordable Quality Healthcare)**: Centralized credentialing data
- **State licensing boards**: License verification
- **OIG/SAM exclusion lists**: Sanction monitoring
- **NPPES (National Plan and Provider Enumeration System)**: NPI registry data
- **Contract management systems**: Fee schedules, contract terms
- **Internal provider portals**: Provider self-service updates

#### Integration Points with Other Domains
- **Claims Domain**: Claims reference provider for adjudication, network status, fee schedules
- **Member Domain**: Members search provider directory, select PCPs
- **Clinical Domain**: Prior authorizations reference provider credentials
- **Financial Domain**: Provider payments based on contracts
- **Product Domain**: Network design tied to product definitions

#### Example Use Cases

**Operational**:
- Member searches for in-network primary care physician near their zip code
- Claims system validates rendering provider is credentialed and contracted before paying claim
- Credentialing team receives alert that provider license expires in 60 days

**Analytical**:
- Network adequacy analysis: Do we have sufficient PCPs within 10 miles of all member zip codes?
- Provider cost efficiency: Which orthopedic surgeons have lowest cost per knee replacement?
- Contract optimization: Compare our contracted rates vs regional benchmarks to identify negotiation opportunities

---

### 2. MEMBERSHIP DOMAIN

**Domain Purpose**: Manage member enrollment, eligibility, coverage determination, and demographic information throughout the member lifecycle.

#### Bounded Contexts

##### 2.1 Member Demographics
**Purpose**: Maintain member identifying and demographic information

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Member registration and ID assignment
- Demographic data capture and updates
- Subscriber vs dependent relationships
- Contact information maintenance
- Member matching and deduplication

**Data Categories**:
- Member ID, Subscriber ID
- Name, date of birth, gender
- SSN (if collected)
- Address, phone, email
- Relationship to subscriber (self, spouse, child)
- Language preference

##### 2.2 Eligibility & Coverage
**Purpose**: Determine member eligibility status and coverage periods

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Enrollment period tracking
- Coverage effective date determination
- Retroactive eligibility adjustments
- Coverage termination
- COBRA continuation eligibility
- Real-time eligibility verification (270/271 transactions)

**Data Categories**:
- Enrollment status (active, terminated, pending)
- Coverage effective date, termination date
- Eligibility segments (periods of coverage)
- Coverage type (medical, dental, vision, pharmacy)
- Subscriber vs dependent coverage
- Coordination of benefits (COB) information

##### 2.3 Group Administration
**Purpose**: Manage employer groups and group-level configuration

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Group enrollment and setup
- Group billing configuration
- Group-level product assignment
- Employer contribution rules
- Group termination

**Data Categories**:
- Group ID, group name
- Group size (subscriber count)
- Employer contact information
- SIC code, industry classification
- Group effective/termination dates
- Fully-insured vs self-funded indicator
- Contribution rules (employer/employee premium split)

##### 2.4 Member Lifecycle Management
**Purpose**: Track member journey and lifecycle events

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- New member onboarding
- Qualifying life events (marriage, birth, job loss)
- Open enrollment processing
- Coverage changes
- Member reinstatement
- Disenrollment

**Data Categories**:
- Lifecycle events (enrollment, change, termination)
- Event dates and reasons
- Qualifying life event documentation
- Enrollment channel (employer, marketplace, direct)
- Member tenure, retention metrics

#### Data Sources
- **Employer group feeds (834 files)**: Enrollment, eligibility, demographic updates
- **Health insurance marketplaces**: ACA exchange enrollments
- **Member portals**: Self-service demographic updates
- **Customer service systems**: Phone/email enrollment and changes
- **Broker enrollment systems**: Agent-submitted enrollments
- **Government sources**: Medicare, Medicaid eligibility files

#### Integration Points with Other Domains
- **Claims Domain**: Eligibility verification before claim payment
- **Financial Domain**: Premium billing based on enrollment
- **Product Domain**: Member coverage tied to product benefit design
- **Clinical Domain**: Care management programs reference member demographics
- **Provider Domain**: PCP assignment, provider directory access
- **Broker Domain**: Broker commissions based on member enrollment

#### Example Use Cases

**Operational**:
- Process new hire enrollment from employer 834 file
- Verify member eligibility in real-time for pharmacy claim
- Add newborn to family coverage following birth notification
- Terminate coverage for member who left employer

**Analytical**:
- Member retention analysis: What percentage of members renew annually by product/group?
- Demographics analysis: Age/gender distribution of membership
- Enrollment trends: Growth rate by enrollment channel (employer, marketplace, direct)
- PMPM cost analysis: Average cost per member per month by demographic segment

---

### 3. BROKER DOMAIN

**Domain Purpose**: Manage broker/agent relationships, commissions, sales performance, and broker-driven enrollments.

#### Bounded Contexts

##### 3.1 Broker/Agent Management
**Purpose**: Maintain broker/agent information and credentials

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Broker contracting and onboarding
- License verification and renewal tracking
- Broker hierarchy management (agencies, sub-agents)
- Broker termination
- Broker portal access management

**Data Categories**:
- Broker ID, NPN (National Producer Number)
- Broker/agency name, contact information
- License number, state, expiration date
- Broker type (individual, agency, general agent)
- Contracting status, effective dates
- Assigned territory/market

##### 3.2 Broker Commissions
**Purpose**: Calculate and track broker commissions

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Commission structure setup (rates, tiers, overrides)
- Commission calculation based on enrollment/premium
- Commission payment processing
- Commission adjustments (chargebacks for member terminations)
- Commission statement generation
- 1099 tax reporting

**Data Categories**:
- Commission structure (rates by product, market, term)
- Commission transactions (member, premium, commission amount)
- Commission payments (payment date, amount, method)
- Chargebacks (reversals for terminated members)
- Year-to-date commission totals
- Tax reporting data

##### 3.3 Broker Sales & Performance
**Purpose**: Track broker sales activity and performance metrics

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Sales activity tracking (quotes, enrollments)
- Performance reporting
- Sales goal tracking
- Broker training and certification tracking
- Broker satisfaction measurement

**Data Categories**:
- Sales metrics (enrollments, premium sold, retention)
- Quote activity
- Performance against goals
- Training completion, certification status
- Broker satisfaction scores

##### 3.4 Broker Enrollments
**Purpose**: Process and track broker-submitted enrollments

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Broker portal enrollment submission
- Paper application processing
- Enrollment validation and underwriting
- Broker of record (BOR) changes
- Commission attribution

**Data Categories**:
- Enrollment applications (pending, approved, denied)
- Broker of record for each member/group
- Enrollment channel (broker portal, paper, phone)
- Application status and timestamps
- Underwriting decisions

#### Data Sources
- **Broker portals**: Broker self-service data entry and enrollment submissions
- **Producer licensing databases**: State DOI license verification
- **Broker management systems**: Commission structures, contracts
- **CRM systems**: Broker relationship and sales activity data
- **Enrollment systems**: Broker-submitted applications
- **Payment systems**: Commission payment processing

#### Integration Points with Other Domains
- **Membership Domain**: Broker enrollments create member records, broker of record tracked
- **Financial Domain**: Commission payments, premium attribution
- **Product Domain**: Brokers sell specific products, commission rates vary by product
- **HR Domain**: Internal broker relationship managers (if applicable)

#### Example Use Cases

**Operational**:
- Broker submits small group enrollment through broker portal
- Calculate monthly commissions for all active brokers based on October enrollments
- Alert broker that their state license expires in 30 days
- Process broker of record change request from competing broker

**Analytical**:
- Broker performance scorecard: Sales, retention, member satisfaction by broker
- Commission expense analysis: Total commission spend by product/market
- Broker productivity: Which brokers drive highest enrollment volume?
- Broker channel analysis: What percentage of new enrollments come through brokers vs direct?

---

### 4. CLAIMS DOMAIN

**Domain Purpose**: Process, adjudicate, and pay claims for healthcare services rendered to members.

#### Bounded Contexts

##### 4.1 Medical Claims Processing
**Purpose**: Adjudicate and pay professional and institutional medical claims

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Claim receipt and intake (837P, 837I)
- Claim validation (member eligibility, provider participation)
- Claim pricing (fee schedule, DRG, per diem)
- Benefit adjudication (deductible, coinsurance, copay, out-of-pocket max)
- Claim payment or denial
- EOB (Explanation of Benefits) generation
- Claim finalization and check issuance

**Data Categories**:
- Claim header (claim ID, member, provider, dates of service, diagnoses)
- Claim lines (procedures, charges, allowed, paid amounts)
- Adjudication details (deductible applied, coinsurance, copay, denial reason)
- Claim status (received, pended, paid, denied, adjusted)
- Payment information (check number, payment date, payee)

##### 4.2 Pharmacy Claims Processing
**Purpose**: Adjudicate and pay pharmacy benefit claims

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Real-time adjudication at point of sale (NCPDP transactions)
- Formulary checking
- Prior authorization verification (for specialty drugs)
- Drug pricing (AWP, MAC pricing)
- Quantity limits, days supply validation
- Pharmacy network validation
- Reversal processing

**Data Categories**:
- Prescription claim (member, pharmacy, prescriber, drug NDC)
- Drug information (NDC, drug name, quantity, days supply, DAW code)
- Formulary tier, prior authorization status
- Pricing (ingredient cost, dispensing fee, patient pay, plan pay)
- Claim status (paid, rejected, reversed)

##### 4.3 Dental/Vision Claims Processing
**Purpose**: Process dental and vision benefit claims

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Dental claim adjudication (CDT procedure codes)
- Vision claim adjudication (materials, exams)
- Benefit frequency limits (1 eye exam per year, etc.)
- Orthodontic lifetime maximum tracking

**Data Categories**:
- Similar structure to medical claims but with dental/vision-specific codes and benefits

##### 4.4 Claims Adjustment
**Purpose**: Handle claim reprocessing, adjustments, appeals, and corrections

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Claim adjustment requests (provider, member, internal)
- Claim reprocessing
- Void and replace
- Appeal processing
- Overpayment recovery
- Adjustment reason tracking

**Data Categories**:
- Original claim reference
- Adjustment reason codes
- Adjustment type (void, replacement, supplemental)
- Adjusted amounts (difference from original)
- Adjustment status and timestamps

##### 4.5 Coordination of Benefits (COB)
**Purpose**: Coordinate payment when member has multiple insurance coverages

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Primary/secondary payer determination
- COB claim adjudication
- Other carrier payment tracking
- COB recoveries

**Data Categories**:
- Other coverage information (carrier, policy number, priority)
- Primary payer payment amount
- Secondary adjudication (reduced payment)
- COB savings

#### Data Sources
- **Provider claim submissions**: 837P (professional), 837I (institutional), NCPDP (pharmacy)
- **Clearinghouses**: Claim routing and formatting
- **Member eligibility systems**: Real-time eligibility verification
- **Provider network systems**: Network status, fee schedules
- **Prior authorization systems**: Auth verification
- **Pharmacy benefit managers (PBMs)**: Pharmacy claim processing (if outsourced)

#### Integration Points with Other Domains
- **Membership Domain**: Eligibility verification, COB information
- **Provider Domain**: Provider network status, credentials, fee schedules
- **Clinical Domain**: Prior authorization status, medical policies
- **Financial Domain**: Claim payments, reserves, accounting entries
- **Product Domain**: Benefit plan rules for adjudication

#### Example Use Cases

**Operational**:
- Adjudicate medical claim for office visit: verify eligibility, apply $25 copay, pay remaining allowed amount
- Real-time pharmacy claim rejection: member reached quantity limit for opioid prescription
- Process claim appeal: member disputes denied MRI, medical director reviews and approves
- Reprocess claim after eligibility correction: member retroactively reinstated, reprocess denied claims

**Analytical**:
- Claims processing metrics: Average days to payment, claim backlog, auto-adjudication rate
- Denial analysis: Top denial reasons, denial overturn rate on appeal
- Cost trend analysis: PMPM medical costs trending up 8% year-over-year
- High-cost claimant identification: Members with >$100K paid claims for care management outreach

---

### 5. FINANCIAL DOMAIN

**Domain Purpose**: Manage financial transactions, premium billing, accounting, payment processing, and financial reporting.

#### Bounded Contexts

##### 5.1 Premium Billing
**Purpose**: Bill and collect premium payments from members and groups

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Premium rate calculation
- Invoice generation (group and individual)
- Payment processing (ACH, check, credit card)
- Payment application to member accounts
- Grace period and termination for non-payment
- Premium refunds and adjustments

**Data Categories**:
- Premium invoices (invoice ID, member/group, billing period, amount due)
- Premium payments (payment date, amount, method, applied to which invoice)
- Premium receivables (outstanding balances)
- Premium adjustments (rate changes, retroactive corrections)
- Payment plans, grace periods

##### 5.2 Payment Processing
**Purpose**: Issue payments to providers, brokers, and other payees

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Provider claim payment (check, EFT)
- 835 remittance advice generation
- Broker commission payments
- Vendor payments
- Payment reconciliation
- Stop payments and reissues

**Data Categories**:
- Payment transactions (payee, amount, method, date)
- Check numbers, EFT trace numbers
- Remittance details (which claims/invoices paid)
- Payment status (issued, cleared, voided, reissued)

##### 5.3 Financial Accounting
**Purpose**: Maintain general ledger, financial books, and accounting records

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- General ledger posting
- Revenue recognition (premium revenue)
- Expense recognition (claims expense, administrative expense)
- Month-end/year-end close
- Financial statement preparation
- Reconciliation (bank, subsidiary ledgers)

**Data Categories**:
- GL accounts, chart of accounts
- Journal entries
- Account balances
- Financial periods (month, quarter, year)
- Trial balance

##### 5.4 Reserves & Actuarial
**Purpose**: Calculate and maintain claim reserves and actuarial estimates

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- IBNR (Incurred But Not Reported) reserve calculation
- Claim liability estimation
- Premium deficiency reserve
- Reserve adequacy testing
- Trend analysis for reserving

**Data Categories**:
- Reserve estimates by product/line of business
- IBNR amounts
- Claim lag reports (development triangles)
- Reserve adjustments

##### 5.5 Reinsurance
**Purpose**: Manage reinsurance contracts and recoveries

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Reinsurance contract management
- Large claim notification to reinsurer
- Reinsurance recovery calculation
- Reinsurance premium payment
- Reinsurance settlement

**Data Categories**:
- Reinsurance contracts (attachment point, coinsurance %)
- Large claims subject to reinsurance
- Reinsurance recoverable amounts
- Reinsurance payments received

#### Data Sources
- **Membership systems**: Member/group enrollment for billing
- **Claims systems**: Claims paid data for expense accounting
- **Payment systems**: Payment transaction data
- **Banking systems**: Bank account transactions, cleared checks
- **Actuarial systems**: Reserve calculations, trend analysis
- **Reinsurance platforms**: Reinsurer data exchange

#### Integration Points with Other Domains
- **Membership Domain**: Premium billing based on enrollment
- **Claims Domain**: Claim payments drive expense accounting
- **Provider Domain**: Provider payment processing
- **Broker Domain**: Broker commission payments
- **Product Domain**: Premium rates by product
- **Compliance Domain**: Financial regulatory reporting

#### Example Use Cases

**Operational**:
- Generate monthly premium invoice for employer group with 500 employees
- Post claim payment batch to general ledger as medical expense
- Calculate IBNR reserve for Q4 based on claim lag patterns
- Process reinsurance recovery for $500K transplant claim

**Analytical**:
- Cash flow forecasting: Projected premium revenue vs claim expense
- Medical loss ratio (MLR) analysis: Ratio of claims paid to premium revenue by product
- Days sales outstanding: Average time to collect premium receivables
- Reserve adequacy: Compare actual claim emergence to prior reserve estimates

---

### 6. PRODUCT DOMAIN

**Domain Purpose**: Define insurance products, benefit structures, plan designs, rating methodology, and product catalog.

#### Bounded Contexts

##### 6.1 Product Catalog
**Purpose**: Maintain portfolio of insurance products offered

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Product definition and setup
- Product versioning (annual benefit changes)
- Product effective dating
- Product approval and filing
- Product retirement/discontinuation

**Data Categories**:
- Product ID, product name
- Product type (HMO, PPO, EPO, HDHP)
- Market segment (individual, small group, large group, Medicare, Medicaid)
- Product effective/termination dates
- Product status (active, discontinued, grandfathered)
- Service area (counties/zip codes where offered)

##### 6.2 Benefit Design
**Purpose**: Define benefit structures and coverage rules

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Benefit plan design (deductible, coinsurance, copays, out-of-pocket max)
- Covered services definition
- Exclusions and limitations
- Preventive care benefits (ACA-mandated)
- Network tier benefits (in vs out-of-network)
- Benefit plan versioning

**Data Categories**:
- Benefit plan ID
- Deductible (individual, family)
- Out-of-pocket maximum (individual, family)
- Coinsurance percentages
- Copays by service type (PCP, specialist, ER, urgent care, Rx)
- Coverage rules (prior auth required, step therapy, quantity limits)
- Covered services, exclusions
- Benefit year definition

##### 6.3 Rating & Pricing
**Purpose**: Calculate premium rates for products

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Rate development (actuarial analysis)
- Underwriting rules and rate adjustments
- Age/gender rating factors
- Geographic area factors
- Tobacco surcharges
- Group size rating
- Rate filing with regulators
- Rate renewal calculations

**Data Categories**:
- Base rates by product/plan
- Rating factors (age, gender, geography, tobacco)
- Composite rates (family, employee+spouse, etc.)
- Rate effective dates
- Rate version history
- Underwriting adjustments

##### 6.4 Plan Documents
**Purpose**: Maintain product legal documents and member communications

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Summary of Benefits and Coverage (SBC) generation
- Evidence of Coverage (EOC) / Certificate of Coverage
- Schedule of Benefits
- Formulary publication
- Provider directory publication
- Document versioning and archiving

**Data Categories**:
- Document templates
- Document versions (by product, effective date)
- Document distribution tracking

#### Data Sources
- **Actuarial systems**: Rate development and pricing models
- **Regulatory filing systems**: State insurance department filings
- **Product management systems**: Product configuration
- **Document management systems**: Plan documents, SBCs
- **Benefit configuration systems**: Claims system benefit setup

#### Integration Points with Other Domains
- **Membership Domain**: Member enrollment tied to specific product/plan
- **Claims Domain**: Benefit rules from Product domain drive claim adjudication
- **Financial Domain**: Premium rates from Product domain used for billing
- **Provider Domain**: Network design tied to product
- **Legal & Compliance Domain**: Product regulatory filings and compliance

#### Example Use Cases

**Operational**:
- Configure new PPO product for 2026: define benefits, set rates, create plan documents
- Update formulary for existing products to add new specialty drug tier
- Calculate renewal rates for all small group products: trend claims, apply rate increase caps

**Analytical**:
- Product profitability analysis: Compare premium revenue vs claims expense by product
- Benefit richness comparison: How do our deductibles/out-of-pocket maxes compare to competitors?
- Product mix analysis: What percentage of membership is in HDHP vs traditional plans?
- Rate competitiveness: Compare our rates to market benchmarks by age/geography

---

### 7. CLINICAL DOMAIN

**Domain Purpose**: Manage medical necessity determinations, care coordination, quality programs, and clinical data to improve health outcomes and ensure appropriate care.

#### Bounded Contexts

##### 7.1 Utilization Management
**Purpose**: Ensure medical services are medically necessary and appropriate

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Prior authorization (pre-service review)
- Concurrent review (inpatient stays)
- Retrospective review
- Medical necessity determinations
- Appeal processing (clinical denials)

**Data Categories**:
- Authorization requests (service, diagnosis, clinical justification)
- Medical policies/clinical criteria
- Authorization decisions (approved, denied, modified, pended)
- Auth status (active, expired, exhausted)
- Appeals (appeal request, outcome, reviewer notes)

##### 7.2 Care Management / Case Management
**Purpose**: Coordinate care for members with complex/chronic conditions

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Case identification (high utilizers, chronic conditions)
- Care plan creation
- Member outreach and engagement
- Care coordination
- Disease management programs (diabetes, asthma, CHF, COPD)
- Transition of care (hospital discharge planning)

**Data Categories**:
- Care management enrollment (member, program, enrollment date)
- Care plans (goals, interventions, barriers)
- Member interactions (calls, notes, outcomes)
- Barriers to care (social determinants)
- Clinical assessments, health risk assessments
- Gaps in care

##### 7.3 Quality Measurement
**Purpose**: Measure and improve quality of care delivered to members

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- HEDIS measure calculation (colorectal screening, diabetes care, etc.)
- Stars ratings (Medicare Advantage)
- Quality gap identification
- Quality improvement interventions
- Provider quality profiling
- NCQA accreditation

**Data Categories**:
- Quality measure results (numerator, denominator, rate)
- Member-level measure compliance
- Gaps in care lists
- Quality intervention tracking
- Provider quality scores

##### 7.4 Clinical Data Repository
**Purpose**: Centralized repository of member clinical information

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Clinical data ingestion (HL7, FHIR, claims)
- Data normalization and standardization
- Longitudinal member clinical record assembly
- Clinical data retrieval for care management/UM

**Data Categories**:
- Lab results (test, value, date, reference range)
- Vital signs (BP, weight, BMI)
- Diagnoses (problem lists, encounter diagnoses)
- Medications (prescription history)
- Procedures (surgical history)
- Immunizations
- Allergies
- Clinical observations (progress notes)
- Social/family history

##### 7.5 Medical Policy Management
**Purpose**: Define and maintain clinical guidelines for coverage decisions

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Medical policy authoring
- Policy review and updates
- Evidence-based medicine review
- Policy versioning
- Policy distribution to UM staff

**Data Categories**:
- Medical policies (clinical criteria, covered conditions)
- Policy effective dates, version history
- Evidence citations
- Policy-to-procedure code mappings

##### 7.6 Population Health Management
**Purpose**: Analyze and improve health of defined member populations

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Risk stratification (predictive modeling)
- Cohort definition (diabetics, depression, etc.)
- Health risk assessment administration
- Population health outcome tracking
- Social determinants of health (SDOH) intervention

**Data Categories**:
- Risk scores (predictive model outputs)
- Cohort membership
- Health risk assessment responses
- Population-level metrics (avg HbA1c, hospitalization rates)
- SDOH data (housing, food security, transportation)

#### Data Sources
- **HL7 feeds from providers**: ADT, lab results, medications, clinical observations
- **FHIR APIs**: Modern clinical data exchange
- **Claims systems**: Diagnoses, procedures (limited clinical detail)
- **Pharmacy claims**: Medication fills
- **Electronic health records (EHRs)**: Direct integration or data exchange
- **Health Information Exchanges (HIEs)**: Regional data sharing
- **Lab vendors**: Quest, LabCorp direct feeds
- **Member portals**: Health risk assessments, self-reported data
- **Chart abstraction**: Manual medical record review (for quality measures)

#### Integration Points with Other Domains
- **Claims Domain**: Clinical uses claims diagnoses/procedures; claims checks prior auth before payment
- **Membership Domain**: Clinical programs reference member demographics, eligibility
- **Provider Domain**: Clinical data includes rendering provider; care managers coordinate with network
- **Pharmacy Domain**: Medication adherence uses pharmacy fills
- **Legal & Compliance Domain**: Quality measure results feed regulatory reporting (HEDIS, Stars)
- **Product Domain**: Medical policies align with benefit coverage rules

#### Example Use Cases

**Operational**:
- Process prior authorization request for spinal surgery: review medical records, apply clinical criteria, approve with specific conditions
- Identify diabetic members with HbA1c >9% for care management outreach
- Calculate HEDIS colorectal cancer screening measure: identify eligible members, check for screening claims/lab results

**Analytical**:
- Prior auth approval rate trending: Are we approving fewer MRIs this year vs last?
- Care management ROI: Compare hospitalization rates for enrolled vs non-enrolled high-risk members
- Quality performance trending: HEDIS measure scores year-over-year, gap to national benchmarks
- Population health analysis: Prevalence of chronic conditions, risk distribution, social determinant impacts

---

### 8. LEGAL & COMPLIANCE DOMAIN

**Domain Purpose**: Ensure regulatory compliance, prevent fraud and abuse, manage legal matters, and oversee enterprise risk across all health plan operations.

#### Bounded Contexts

##### 8.1 Regulatory Reporting & Compliance
**Purpose**: Submit required regulatory reports and maintain compliance with federal, state, and accreditation requirements

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- State insurance department reporting (annual statements, quarterly filings)
- CMS reporting (Medicare Advantage, Medicaid managed care)
- HEDIS submission to NCQA
- Stars ratings submission
- MLR (Medical Loss Ratio) calculation and rebate processing
- ACA marketplace reporting (risk adjustment, reinsurance, risk corridors)
- Network adequacy reporting
- Solvency and financial reporting
- Market conduct examinations

**Data Categories**:
- Regulatory filing submissions (filing type, date, status, acknowledgment)
- MLR calculation components (premium, claims, quality improvement, administrative costs)
- Network adequacy metrics (provider counts, time/distance standards, compliance status)
- Financial solvency metrics (RBC - Risk-Based Capital, reserves)
- Examination findings and remediation tracking
- Regulatory correspondence and notices
- Filing deadlines and compliance calendars

##### 8.2 Audit Management
**Purpose**: Manage internal and external audits, ensure audit readiness, track findings and remediation

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- External audit coordination (CMS, state DOI, NCQA, financial audits)
- Internal audit planning and execution
- Audit document request management
- Audit finding tracking and remediation
- Corrective action plan (CAP) development and monitoring
- Audit report management
- Self-audit programs (RADV - Risk Adjustment Data Validation prep)

**Data Categories**:
- Audit schedules (auditor, type, dates, scope)
- Document requests and responses
- Audit findings (finding ID, category, severity, responsible party)
- Corrective action plans (action items, due dates, status, evidence)
- Audit reports and management responses
- Remediation validation evidence

##### 8.3 Fraud, Waste & Abuse (FWA)
**Purpose**: Detect, investigate, and prevent fraud, waste, and abuse by providers, members, and employees

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Fraud detection (analytics, tips, referrals)
- Case investigation (provider fraud, member fraud, internal fraud)
- Special Investigations Unit (SIU) case management
- Overpayment identification and recovery
- Provider sanctions and terminations
- Referrals to law enforcement / OIG / state fraud units
- FWA reporting (CMS, state)
- Employee fraud, waste, abuse training

**Data Categories**:
- Fraud cases (case ID, subject, allegation type, status)
- Investigation details (investigators, evidence, interviews, findings)
- Fraud analytics alerts (unusual billing patterns, high-risk providers)
- Overpayment amounts and recovery status
- Sanctions (provider exclusions, terminations)
- Fraud hotline tips and reports
- Law enforcement referrals
- Recoveries and settlements

##### 8.4 Privacy & Security Compliance (HIPAA)
**Purpose**: Ensure HIPAA compliance, manage privacy incidents, protect member and employee data

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Privacy incident investigation and reporting
- Breach notification (to members, HHS, media if required)
- HIPAA risk assessments
- Business associate agreement (BAA) management
- Privacy and security training
- Access audit logging and monitoring
- Patient rights requests (access, amendment, accounting of disclosures, restrictions)
- Minimum necessary determinations

**Data Categories**:
- Privacy incidents (incident ID, type, date discovered, affected individuals, PHI involved)
- Breach determinations (risk assessment, breach/no breach decision, notification required)
- Breach notifications (members notified, HHS report, media notice if >500 individuals)
- Business associate agreements (BA name, services, effective dates, audit results)
- Patient rights requests (request type, date, response, fulfillment)
- Privacy training completion tracking
- Access logs (who accessed what PHI, when, purpose)

##### 8.5 Enterprise Risk Management
**Purpose**: Identify, assess, and mitigate enterprise risks across the organization

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Enterprise risk assessment
- Risk register maintenance
- Risk mitigation planning
- Risk monitoring and reporting
- Business continuity planning (BCP)
- Disaster recovery planning (DRP)
- Incident response planning
- Vendor risk assessment
- Cybersecurity risk management

**Data Categories**:
- Risk register (risk ID, category, description, likelihood, impact, owner)
- Risk mitigation plans (controls, responsible parties, timelines)
- Risk appetite and tolerance statements
- Business continuity plans
- Disaster recovery plans
- Incident response playbooks
- Vendor risk assessments
- Risk reporting to board/committees

##### 8.6 Legal Matters & Contracts
**Purpose**: Manage legal cases, litigation, contracts, and legal advice

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Litigation management (lawsuits, disputes)
- Contract review and negotiation (vendor, provider, broker, reinsurance)
- Legal holds and e-discovery
- Subpoenas and legal requests
- Regulatory inquiries and investigations
- Settlement negotiations
- Legal advice and opinions
- Corporate governance (board resolutions, bylaws, corporate actions)

**Data Categories**:
- Legal cases (case number, parties, court, status, counsel)
- Litigation reserves (estimated exposure)
- Contracts (contract type, parties, effective dates, terms, auto-renewal)
- Legal holds (matter, custodians, date imposed, date released)
- Subpoenas (requesting party, subject matter, response deadline, response)
- Regulatory inquiries (agency, subject, documents requested, response)
- Settlements (amount, terms, confidentiality)
- Legal spend (outside counsel, costs)

##### 8.7 Accreditation Management
**Purpose**: Achieve and maintain accreditation from NCQA, URAC, and other accrediting bodies

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Accreditation application and renewal
- Readiness assessment (gap analysis)
- Evidence collection and documentation
- On-site survey coordination
- Accreditation finding remediation
- Accreditation status maintenance
- Performance improvement projects (PIPs) for accreditation

**Data Categories**:
- Accreditation status (organization, accrediting body, level, expiration date)
- Standards compliance assessment (standard, compliance level, gaps)
- Evidence documentation (standard, evidence type, location)
- Survey findings (finding, category, response, remediation)
- PIPs (project, aim, measures, interventions, results)
- Accreditation reports

##### 8.8 Policy & Procedure Management
**Purpose**: Maintain enterprise policies and procedures to ensure consistent operations and compliance

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Policy authoring and review
- Policy approval workflow
- Policy publication and distribution
- Policy version control
- Attestation tracking (employees acknowledge policies)
- Policy retirement
- Regulatory alignment (map policies to regulatory requirements)

**Data Categories**:
- Policies and procedures (policy ID, title, category, version, effective date)
- Policy approval workflow (author, reviewers, approvers, dates)
- Policy attestations (employee, policy, attestation date)
- Regulatory mappings (policy to regulation/standard)
- Policy review schedule (due dates, owners)

#### Data Sources
- **Regulatory reporting systems**: State DOI portals, CMS HPMS (Health Plan Management System), NCQA IDSS
- **Audit management platforms**: Internal audit software, external auditor document portals
- **Fraud detection analytics**: Claims analytics, predictive models, third-party fraud detection vendors
- **Case management systems**: SIU case tracking, legal matter management
- **Privacy incident tracking**: HIPAA incident management systems
- **Risk management platforms**: GRC (Governance, Risk, Compliance) software
- **Contract management systems**: Legal contract repositories
- **Policy management systems**: PolicyTech, Compliance 360, SharePoint
- **Business associate databases**: BAA tracking
- **Document management systems**: Evidence libraries for accreditation/audits

#### Integration Points with Other Domains
- **Clinical Domain**: HEDIS/Stars data from Clinical feeds regulatory reporting; medical policy compliance
- **Claims Domain**: Claims data drives MLR calculation, fraud detection, audit samples
- **Financial Domain**: Financial data for solvency reporting, MLR, audit
- **Membership Domain**: Member data for privacy incidents (affected individuals), network adequacy
- **Provider Domain**: Provider sanctions, fraud cases, network adequacy reporting, provider contracts
- **Product Domain**: Product filings, rate approvals, benefit compliance with regulations (ACA, state mandates)
- **HR Domain**: Employee training compliance, background checks, internal fraud cases
- **Broker Domain**: Broker contracts, commission compliance, broker licensing

#### Example Use Cases

**Operational**:
- Submit annual MLR report to CMS: calculate premium, claims, quality improvement expenses, determine if rebates owed
- Investigate fraud case: Provider billing for services not rendered, coordinate with SIU, recover overpayment, refer to OIG
- Respond to HIPAA breach: Employee accessed ex-spouse's PHI inappropriately, conduct risk assessment, notify member, report to HHS
- Prepare for NCQA accreditation survey: Collect evidence for 50+ standards, coordinate on-site visit, remediate findings

**Analytical**:
- Fraud analytics: Identify providers with unusual billing patterns (e.g., 30+ office visits per day)
- Audit trending: Track audit findings by category over time, identify systemic issues
- Privacy incident analysis: Root cause analysis of breaches, identify training gaps
- Risk dashboard: Heatmap of enterprise risks by likelihood and impact
- Regulatory compliance scorecard: Percentage of filings submitted on time, compliance with network adequacy standards

---

### 9. HR DOMAIN

**Domain Purpose**: Manage internal employee data, benefits, payroll, and human resources information.

**Note**: This domain manages **internal employees** of the health plan organization, distinct from the Membership domain which manages **health plan members** (customers).

#### Bounded Contexts

##### 8.1 Employee Management
**Purpose**: Maintain employee demographic and employment information

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Employee onboarding
- Employee demographic data maintenance
- Employment status tracking (active, leave, terminated)
- Organizational hierarchy (manager relationships)
- Job classification and titles
- Performance review tracking

**Data Categories**:
- Employee ID, SSN
- Employee demographics (name, address, DOB, contact)
- Hire date, termination date
- Employment status
- Job title, department, cost center
- Manager/supervisor
- Employment type (full-time, part-time, contractor)

##### 8.2 Payroll
**Purpose**: Process employee compensation and payroll

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Payroll processing
- Time and attendance tracking
- Salary/wage administration
- Tax withholding
- Direct deposit
- Payroll tax filing
- W-2 generation

**Data Categories**:
- Employee compensation (salary, hourly rate)
- Pay periods, pay dates
- Hours worked, PTO taken
- Gross pay, net pay
- Tax withholdings (federal, state, FICA)
- Deductions (benefits, 401k)
- Payment method (direct deposit, check)
- YTD earnings

##### 8.3 Employee Benefits
**Purpose**: Manage employee benefit enrollment and administration

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Benefits enrollment (open enrollment, new hire)
- Benefits eligibility determination
- Benefits election tracking
- Benefits billing and payroll deductions
- COBRA administration (for terminated employees)
- Benefits vendor coordination

**Data Categories**:
- Benefit plans offered to employees
- Employee benefit elections (medical, dental, vision, life, disability, 401k)
- Enrollment effective dates
- Benefit costs (employer/employee contribution)
- Dependent coverage
- Beneficiary designations

**Integration with Membership Domain**:
When employees of the health plan enroll in the company's health insurance, they become **both** employees (HR domain) **and** members (Membership domain). This is a key integration point.

##### 8.4 Talent Management
**Purpose**: Manage recruiting, training, and development

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- Recruiting and applicant tracking
- New hire onboarding
- Training and certification tracking
- Performance management
- Succession planning
- Employee development plans

**Data Categories**:
- Job requisitions
- Applicant data
- Interview tracking
- Training courses, completion dates
- Certifications (required for role, expiration dates)
- Performance review scores, goals
- Development plans

##### 8.5 Employee Compliance
**Purpose**: Track HR-related compliance requirements

**Ownership**: *[To be confirmed with business]*

**Domain Experts**: *[To be identified]*

**Key Processes**:
- I-9 verification
- Background check tracking
- Compliance training (HIPAA, compliance, harassment prevention)
- License/credential tracking (for clinical staff)
- Disciplinary action tracking

**Data Categories**:
- I-9 documentation
- Background check results
- Required training completion
- License numbers, expiration dates (nurses, care managers)
- Disciplinary actions, warnings

#### Data Sources
- **HRIS (Human Resource Information System)**: Workday, ADP, UltiPro, etc.
- **Payroll systems**: Integrated with HRIS or standalone
- **Time and attendance systems**: Timeclock, time tracking
- **Benefits administration platforms**: Enrollment systems
- **Applicant tracking systems (ATS)**: Recruiting data
- **Learning management systems (LMS)**: Training tracking

#### Integration Points with Other Domains
- **Membership Domain**: Employees who enroll in company health plan become members (dual identity)
- **Financial Domain**: Payroll expense accounting, benefits expense
- **Legal & Compliance Domain**: HR compliance reporting (EEO, ACA employer mandate)
- **Clinical Domain**: Clinical staff (nurses, care managers) credentials tracked in HR

#### Example Use Cases

**Operational**:
- Process new employee onboarding: collect I-9, setup payroll, enroll in benefits, provision systems
- Run bi-weekly payroll for all employees
- Process open enrollment: employees elect medical/dental/401k for next year
- Track HIPAA training compliance: identify employees with expired training

**Analytical**:
- Headcount reporting: Employee count by department, job title, employment status
- Turnover analysis: Attrition rate by department, tenure, reasons for leaving
- Payroll expense analysis: Total compensation costs by department/cost center
- Benefits participation: What percentage of employees elect HDHP vs PPO?

---

## Domain Ownership & Governance

### Ownership Model

For each bounded context, identify:

1. **Business Owner**: Department/team with primary accountability for business processes and decisions
2. **Data Domain Expert(s)**: Subject matter experts who understand data definitions, business rules, quality requirements
3. **Shared Ownership**: Cases where multiple departments have joint responsibility

### Next Steps

1. **Review with Business Leaders**: Validate bounded context assignments with each department
2. **Identify Domain Experts**: Populate domain expert names for each bounded context
3. **Refine Boundaries**: Adjust bounded contexts based on actual organizational structure and process ownership
4. **Document Business Rules**: For each bounded context, document detailed business rules in subfolder structure
5. **Establish Data Governance**: Define data stewardship, data quality ownership, and data access policies per domain

---

## Document Change Log

| Date | Version | Author | Changes |
|------|---------|--------|---------|
| 2025-10-23 | 1.0.0 | Dan Brickey | Initial document creation with 8 domain definitions |
| 2025-10-23 | 1.1.0 | Dan Brickey | Added Legal & Compliance domain (9th domain) with 8 bounded contexts based on business structure |

---

## References

- Domain-Driven Design (Eric Evans)
- Healthcare payer industry best practices
- EDP Platform Architecture documentation
- EDP Layer Architecture documentation
