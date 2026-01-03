# PCP Attribution Business Vault Recommendations

## Executive Summary

The PCP Attribution pipeline follows a multi-stage calculation process to assign each member to their Primary Care Provider based on claim utilization patterns. The legacy code uses 12 sequential staging tables (`NonDV_01` through `NonDV_12`) to progressively filter and aggregate data.

For EDW3, we recommend consolidating this into **3-4 key business vault artifacts** that can be materialized and reused across multiple dimensional models.

---

## Recommended Business Vault Artifacts

### 1. **Computed Satellite: `cs_provider_pcp_eligibility`**

**Purpose**: Determines which providers are eligible to be attributed as PCPs

**Grain**: One row per provider per evaluation date

**Key Business Rules**:
- Providers must have eligible specialty codes (from reference data)
- Exclude institutional providers (GOVH, HOSP, INDH, PUBH, TPLH)
- Must be entity type 'P' (person) for specialists
- PCPs must have active network relationships during evaluation window
- Calculates provider's group-level Tax ID (prioritizes group over individual)

**Source**:
- Raw vault: `current_provider`, `current_provider_affiliation`, `current_provider_network_relational`
- Reference: Provider specialty seed
- Replaces: `PCPAttribution_02_NonDV_02_ProviderSet`, `v_PCPAttribution_02_EligibleProvider`

**Columns**:
```sql
-- Hub keys
hub_provider_key
hub_evaluation_period_key  -- New hub for evaluation period tracking

-- Descriptive attributes
source_code
provider_id
provider_npi
tax_id_group_then_individual
pcp_indicator               -- 'PCP' or 'Specialist'
provider_specialty_code
current_eval_date
term_date

-- Metadata
load_date
record_source
```

**Materialization**: Should be **materialized** as this eligibility logic is complex and reusable

---

### 2. **Computed Satellite: `cs_member_pcp_attribution_eligibility`**

**Purpose**: Identifies members eligible for PCP attribution during the evaluation period

**Grain**: One row per member per evaluation date

**Key Business Rules**:
- Member must have active medical eligibility during evaluation window
- Must have primary medical COB (Coordination of Benefits)
- Joins to constituent crosswalk for MDM identifier
- Geocodes member address to FIPS county for regional reporting

**Source**:
- Raw vault: `current_member`, `current_member_eligibility`, `current_subscriber`, `current_subscriber_address`, `current_group`
- Dependencies: COB Profile Lookup, Member Constituent Crosswalk
- Reference: Zip code Melissa, Idaho adjacent county
- Replaces: `PCPAttribution_02_NonDV_03_EligibleMembers`, `PCPAttribution_02_NonDV_04_MemberInfo`, `PCPAttribution_02_NonDV_04a_MemberAddressHistory`, `PCPAttribution_02_NonDV_05_MemberSet`

**Columns**:
```sql
-- Hub keys
hub_member_key
hub_subscriber_key
hub_group_key
hub_evaluation_period_key

-- Descriptive attributes
source_code
member_bk
current_eval_date
constituent_id              -- MDM identifier
group_id
subscriber_id
member_suffix
zip_code
state_id
fips_county_code
fips_code

-- Metadata
load_date
record_source
```

**Materialization**: Should be **materialized** - complex member eligibility and geocoding logic

---

### 3. **Computed Satellite: `cs_member_provider_visit_aggregation`**

**Purpose**: Aggregates claim visit patterns between members and providers to calculate attribution

**Grain**: One row per member-provider-evaluation date combination

**Key Business Rules**:
- Only includes claims with status '02' (paid) or '91' (adjudicated)
- Excludes denied procedures (pscd_id = '20')
- Identifies E&M (Evaluation & Management) visits via:
  - CMS RVU reference (procedure has RVU value)
  - OR BIHC codes (Behavioral Integrated Health)
- Calculates unique visit count (distinct combination of provider, date, member)
- Tracks last visit date
- Sums total RVU values

**Source**:
- Raw vault: `current_claim_medical_header`, `current_claim_medical_line`, `current_claim_medical_procedure`
- Reference: CMS RVU, BIHC codes
- Replaces: `PCPAttribution_02_NonDV_06_Claims`, `PCPAttribution_02_NonDV_07_Procedures`, `PCPAttribution_02_NonDV_08_ClaimSet`, `PCPAttribution_02_NonDV_09_ProviderRankByMember`

**Columns**:
```sql
-- Hub/Link keys
hub_member_key
hub_provider_key
hub_evaluation_period_key
link_member_provider_key    -- May need new link

-- Metrics
unique_visit_count          -- Distinct provider + date + member combinations
last_visit_date
rvu_total
pcp_indicator               -- From provider eligibility

-- Provider attributes (denormalized for performance)
provider_npi
tax_id_group_then_individual

-- Member attributes
constituent_id

-- Metadata
current_eval_date
load_date
record_source
```

**Materialization**: Should be **materialized** - expensive aggregation with claim detail

---

### 4. **Computed Satellite: `cs_member_pcp_attribution_final`**

**Purpose**: Applies final attribution logic to assign each member to their attributed PCP

**Grain**: One row per member per evaluation date (the "calculated PCP")

**Key Business Rules**:
- Ranks providers by member using window functions on:
  1. PCP indicator (PCP wins over Specialist)
  2. Unique visit count (descending)
  3. Last visit date (most recent wins)
  4. RVU total (highest wins)
  5. Provider NPI (tie-breaker)
- Uses clinic-level attribution logic (groups by Tax ID)
- Selects only the #1 ranked provider (AttributedRow = 1)

**Source**:
- Business vault: `cs_member_provider_visit_aggregation`
- Replaces: `PCPAttribution_02_NonDV_10_ProviderIDByMember`, `PCPAttribution_02_NonDV_11_HighClinic`, `v_PCPAttribution_02_MemberClinicListing`, `v_PCPAttribution_02_ProviderRankByMemberRollup`, `PCPAttribution_02_NonDV_12_CalculatedPCP`

**Columns**:
```sql
-- Hub keys
hub_member_key
hub_provider_key
hub_evaluation_period_key

-- Attribution details
constituent_id              -- Member MDM ID
provider_npi                -- Attributed PCP NPI
tax_id_group_then_individual
current_eval_date

-- Supporting metrics (for auditing)
unique_visit_count
last_visit_date
rvu_total
attribution_rank            -- Always 1 in final output
pcp_indicator

-- Metadata
load_date
record_source
```

**Materialization**: Should be **materialized** - this is the "controller" for the dimensional model

---

## Additional Artifacts to Consider

### Hub: `hub_evaluation_period`

**Purpose**: Track evaluation periods as a business entity

**Why**: PCP attribution runs periodically (e.g., monthly, quarterly) and the evaluation window (18 months of claims) is a key business concept

**Business Key**: `current_eval_date` or combination of `evaluation_period_id`

**Columns**:
```sql
hub_evaluation_period_key
evaluation_period_bk        -- e.g., '2025-01' or specific date
load_date
record_source
```

### Link: `link_member_provider` (if doesn't exist)

**Purpose**: Capture the many-to-many relationship between members and providers

**Why**: Members see multiple providers; providers see multiple members. This is a natural link.

**Business Keys**: `hub_member_key` + `hub_provider_key`

---

## Dimensional Model Target

### Fact Table: `fact_member_pcp_attribution`

**Purpose**: The final dimensional fact table for reporting PCP attribution

**Grain**: One row per member per evaluation period (or as-of date for SCD2 handling)

**Source**: `cs_member_pcp_attribution_final` + dimension lookups

**Columns**:
```sql
-- Dimension foreign keys
dim_member_key
dim_provider_key            -- Attributed PCP
dim_date_key                -- Evaluation date or attribution effective date
dim_evaluation_period_key   -- If you create this dimension

-- Degenerate dimensions
constituent_id
tax_id_group_then_individual

-- Measures (from cs_member_pcp_attribution_final for auditing)
unique_visit_count
rvu_total

-- Attributes
pcp_indicator
last_visit_date

-- Metadata
load_date
record_source
```

**Type**: Periodic snapshot fact (one snapshot per evaluation period)

---

## Materialization Strategy

| Artifact | Materialization | Refresh Pattern | Reasoning |
|----------|----------------|-----------------|-----------|
| `cs_provider_pcp_eligibility` | Materialized Table | Incremental (new eval periods) | Complex specialty filtering, network date logic |
| `cs_member_pcp_attribution_eligibility` | Materialized Table | Incremental (new eval periods) | COB lookup, address geocoding, constituent crosswalk |
| `cs_member_provider_visit_aggregation` | Materialized Table | Incremental (18-month rolling window) | Expensive claim aggregation, RVU calculations |
| `cs_member_pcp_attribution_final` | Materialized Table | Full refresh per eval period | Ranking logic, final controller for dimension |
| `fact_member_pcp_attribution` | Materialized Table | Incremental (append new periods) | Final dimensional fact |

---

## Data Flow Summary

```
Raw Vault → Business Vault → Dimensional Model

┌─────────────────────────────────────────────────────────┐
│ RAW VAULT (Integration Layer)                          │
├─────────────────────────────────────────────────────────┤
│ • current_provider                                      │
│ • current_provider_affiliation                          │
│ • current_provider_network_relational                   │
│ • current_member                                        │
│ • current_member_eligibility                            │
│ • current_subscriber                                    │
│ • current_subscriber_address                            │
│ • current_group                                         │
│ • current_claim_medical_header                          │
│ • current_claim_medical_line                            │
│ • current_claim_medical_procedure                       │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│ BUSINESS VAULT (Curation Layer)                        │
├─────────────────────────────────────────────────────────┤
│ 1. cs_provider_pcp_eligibility                         │
│    ↓                                                    │
│ 2. cs_member_pcp_attribution_eligibility               │
│    ↓                                                    │
│ 3. cs_member_provider_visit_aggregation                │
│    ↓                                                    │
│ 4. cs_member_pcp_attribution_final                     │
└─────────────────────────────────────────────────────────┘
                      ↓
┌─────────────────────────────────────────────────────────┐
│ DIMENSIONAL MODEL (Curation Layer)                     │
├─────────────────────────────────────────────────────────┤
│ • fact_member_pcp_attribution                          │
│ • dim_member (existing)                                │
│ • dim_provider (existing)                              │
│ • dim_date (existing)                                  │
│ • dim_evaluation_period (optional, new)                │
└─────────────────────────────────────────────────────────┘
```

---

## Load Order

1. Dependencies (blocking):
   - COB Profile Lookup
   - Member Constituent Crosswalk
   - Reference data seeds

2. Business Vault (sequential):
   - `cs_provider_pcp_eligibility`
   - `cs_member_pcp_attribution_eligibility`
   - `cs_member_provider_visit_aggregation`
   - `cs_member_pcp_attribution_final`

3. Dimensional Model:
   - `fact_member_pcp_attribution`

---

## Performance Considerations

1. **Evaluation Window**: The 18-month rolling window for claims requires careful date filtering. Consider partitioning by `current_eval_date`.

2. **Claim Volume**: Medical claims are high-volume. The visit aggregation step should use Snowflake clustering on `member_bk` and `service_date`.

3. **Incremental Loading**: All computed satellites should support incremental loading based on `current_eval_date` to avoid full refreshes.

4. **Window Functions**: The final ranking logic uses window functions which Snowflake handles well, but ensure proper partitioning for performance.

---

## Next Steps

1. **Review and Approve**: Confirm these business vault artifacts align with your enterprise data model
2. **Check Dependencies**: Verify COB Profile and Member Constituent exist or plan their refactoring
3. **Gather Reference Data**: Collect seed files for specialty codes, BIHC codes, CMS RVU, Idaho counties
4. **Generate dbt Models**: Proceed to create dbt SQL for each business vault artifact
5. **Testing Strategy**: Define data quality tests for each artifact
