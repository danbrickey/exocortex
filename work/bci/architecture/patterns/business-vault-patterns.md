---
title: "Business Vault Implementation Patterns"
document_type: "pattern"
business_domain: ["cross-domain"]  # Applies to all domains
edp_layer: "curation"
technical_topics: ["data-vault-2.0", "business-vault", "dbt", "calculations", "business-rules"]
audience: ["architects", "engineers", "analysts"]
status: "active"
last_updated: "2025-10-24"
version: "1.0"
author: "Dan Brickey"
description: "Business Vault layer implementation standards for Data Vault 2.0 curation layer including naming conventions, business logic patterns, and healthcare-specific implementations"
related_docs:
  - "../edp-layer-architecture-detailed.md"
  - "../edp_platform_architecture.md"
  - "../../engineering-knowledge-base/data-vault-2.0-guide.md"
related_business_rules:
  - "../rules/membership/README.md"
  - "../rules/provider/README.md"
  - "../rules/claims/README.md"
---

# Business Vault Implementation Patterns

## Analytical Overview 📊
*Audience: Business Analysts, Project Managers, Product Owners (5-7 min read)*

**Purpose**: The Business Vault layer implements calculated fields, business rules, and derived insights on top of the Raw Vault foundation. This follows Data Vault 2.0 methodology for the curation layer in our medallion architecture.

**Functional Capabilities**:
- **Business Calculations**: Computed metrics, financial calculations, derived KPIs
- **Business Rules**: Compliance rules, eligibility logic, validation rules, classification logic
- **Cross-Entity Relationships**: Complex associations, temporal relationships, hierarchical structures
- **Point-in-Time Analysis**: Historical snapshots for business state reconstruction

**Business Value**:
- Separates business logic from raw data, enabling independent evolution
- Provides auditability for calculations and business rule changes
- Supports complex healthcare domain requirements (eligibility, claims processing, risk scoring)
- Enables consistent business definitions across consumption layers

---

## Technical Architecture 🔧
*Audience: Data Engineers, Solution Architects, Technical Leads (10-15 min read)*

### Naming Conventions

#### Business Vault Entities
- **Business Hubs**: `bv_h_<entity>_<purpose>`
- **Business Satellites - Calculations**: `bv_s_<entity>_calculations`
- **Business Satellites - Business Rules**: `bv_s_<entity>_business_rules`
- **Business Satellites - Mixed Logic**: `bv_s_<entity>_business`
- **Bridge Tables**: `bridge_<entity>_<purpose>`
- **Point-In-Time Tables**: `pit_<entity>_<purpose>`
- **Reference Tables**: `bv_r_<entity>`

#### Rate of Change Suffixes
When splitting data by rate of change, append:
- `*_hroc` - High rate of change (frequent updates)
- `*_mroc` - Medium rate of change (moderate updates)
- `*_lroc` - Low rate of change (infrequent updates)

### Business Logic Categories

#### 1. Calculations (`bv_s_<entity>_calculations`)
**Purpose**: Computed metrics and derived values

**Examples**:
- **Financial Calculations**: Premium computations, claim reserves, actuarial calculations
- **Derived Metrics**: Member tenure, provider performance scores, utilization rates
- **Aggregations**: Rolling totals, year-to-date amounts, trend calculations
- **Business KPIs**: Quality measures, risk scores, efficiency metrics

**Implementation Pattern**:
```sql
-- Example: Business calculations satellite
{{ automate_dv.sat(
    src_pk='member_hk',
    src_hashdiff='member_business_hashdiff',
    src_payload=['member_tenure_months', 'total_claims_ytd', 'avg_monthly_premium'],
    src_eff='effective_datetime',
    src_ldts='load_datetime',
    src_source='business_vault',
    source_model='stg_member_business_calculations'
) }}
```

#### 2. Business Rules (`bv_s_<entity>_business_rules`)
**Purpose**: Compliance, validation, and classification logic

**Examples**:
- **Compliance Rules**: HIPAA requirements, regulatory compliance flags
- **Eligibility Logic**: Coverage determination, benefit calculations
- **Validation Rules**: Data quality checks, business constraint validation
- **Classification Logic**: Risk categories, member segments, provider tiers

**Documentation Requirements**:
For each business rule satellite, document:
1. **Business Purpose**: Why this rule exists
2. **Source Logic**: Which Raw Vault entities provide input
3. **Rule Definition**: Specific business logic and conditions
4. **Validation Rules**: Expected ranges, constraints, quality checks
5. **Refresh Frequency**: How often business logic should recalculate

#### 3. Cross-Entity Relationships (`bridge_<entity>_<purpose>`)
**Purpose**: Complex associations requiring business logic

**Examples**:
- **Complex Associations**: Many-to-many relationships with business context
- **Temporal Relationships**: Time-based associations with effective periods
- **Hierarchical Structures**: Organizational hierarchies, product families
- **Network Analysis**: Provider networks, referral patterns

#### 4. Point-In-Time Tables (`pit_<entity>_<purpose>`)
**Purpose**: Snapshot business state at specific points in time

**Use Cases**:
- Member eligibility at claim date
- Provider status at service date
- Historical business state reconstruction

**Implementation Pattern**:
Join Raw Vault data with business effective dates to create temporal snapshots.

### Data Sources and Context

#### Legacy System Integration
Reference the `code/repositories/legacy_data_dictionary.csv` for business context:
- **BPA Tables**: Business Process Application rules and configurations
- **Entity Descriptions**: Original business purpose and usage
- **Column Meanings**: Business definitions and calculation logic
- **Data Relationships**: Cross-table dependencies and joins

#### Key Business Entities from Legacy Data
- **Rule Groups** (`bpa_brgr_rul_grp_r`): Business process rules and configurations
- **Service Categories** (`bpa_dpsc_svc_cat_a`): Healthcare service classification
- **Data States** (`bpa_dsas_data_state`): Entity lifecycle and status tracking
- **Conditions** (`bpa_dscr_cond_r`): Business conditions and qualifiers

---

## Implementation Details 💻
*Audience: Data Engineers, Developers (Detailed technical specifications)*

### Development Workflow

1. **Identify Business Need**: What business question needs answering?
2. **Map Raw Vault Sources**: Which hubs/links/satellites provide data?
3. **Define Business Logic**: Document calculations and rules clearly
4. **Create Business Vault Models**: Implement using automate_dv patterns
5. **Test Business Rules**: Validate calculations against known scenarios
6. **Document for Consumption**: Prepare for Information Mart layer

### Healthcare-Specific Business Logic Patterns

#### Member-Related Business Vault
- **Member Tenure Calculations**: Coverage duration, gaps in coverage
- **Risk Scoring**: Health risk assessments, predictive modeling
- **Eligibility Rules**: Coverage determination logic, benefit calculations
- **Utilization Metrics**: Healthcare usage patterns, cost trends

**Related Business Rules**: See [Membership Business Rules](../rules/membership/README.md)

#### Provider-Related Business Vault
- **Network Status**: In-network vs out-of-network determination
- **Performance Metrics**: Quality scores, efficiency measures
- **Credentialing Status**: License validation, specialty certification
- **Payment Calculations**: Fee schedules, reimbursement rates

**Related Business Rules**: See [Provider Business Rules](../rules/provider/README.md)

#### Claims-Related Business Vault
- **Claim Processing Rules**: Adjudication logic, approval workflows
- **Medical Necessity**: Coverage determination, prior authorization
- **Fraud Detection**: Anomaly detection, suspicious pattern identification
- **Cost Management**: Cost sharing calculations, benefit limits

**Related Business Rules**: See [Claims Business Rules](../rules/claims/README.md)

### Quality and Testing Standards

#### Business Rule Validation
- Validate calculations against known test scenarios
- Document expected results for regression testing
- Implement data quality checks on derived values
- Monitor business rule execution performance

#### Documentation Standards
For each Business Vault object, maintain:
1. **Business Purpose**: Why this calculation/rule exists (link to business rules docs if applicable)
2. **Source Logic**: Which Raw Vault entities provide input
3. **Calculation Method**: Specific formulas and business rules
4. **Validation Rules**: Expected ranges, constraints, quality checks
5. **Refresh Frequency**: How often business logic should recalculate
6. **Change History**: Track business rule changes over time

### Performance Considerations

- Use incremental loading with appropriate lookback windows
- Optimize PIT table joins with proper clustering
- Monitor calculation complexity and execution time
- Consider rate-of-change splitting for large satellites

---

## Reference Files

- **Platform Architecture**: [EDP Platform Architecture](../edp_platform_architecture.md)
- **Layer Architecture**: [EDP Layer Architecture](../edp-layer-architecture-detailed.md)
- **Data Vault Guide**: [Data Vault 2.0 Implementation Guide](../../engineering-knowledge-base/data-vault-2.0-guide.md)
- **Legacy Dictionary**: `code/repositories/legacy_data_dictionary.csv`
- **Business Rules**: [Architecture Rules Index](../rules/README.md)
