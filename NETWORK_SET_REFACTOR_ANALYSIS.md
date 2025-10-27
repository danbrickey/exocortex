# EDW2 to EDW3 Refactor Analysis: network_set Entity

## Executive Summary

This document provides a comprehensive analysis of the EDW2 to EDW3 refactoring of the `network_set` entity. The refactor decomposes a monolithic dimensional model (`dimNetworkSet`) into a modern Data Vault 2.0 architecture consisting of business vault satellites, staging models, and prep models. The analysis covers entity definition, business rules, date logic, surrogate key generation, join patterns, data quality rules, and the overall decomposition strategy.

---

## 1. Entity Definition & Business Purpose

### 1.1 What is Network_Set?

**Network Set** represents a configured set of healthcare provider networks at a specific point in time. It is a business concept that links provider networks to products, members, and providers with effective and termination dates indicating the period during which the network is active or available.

Key aspects:
- **Business Domain**: Provider Network Management
- **Core Concept**: A named collection or package of healthcare providers organized for business purposes
- **Primary Use**: Network eligibility determination for members and provider participation tracking
- **Source Systems**: 
  - Legacy FACETS system (primary source for most network sets)
  - MDM (Master Data Management) system (secondary source for some network definitions)
  - Current_Provider_Network_Relational (for provider-specific network participation)

### 1.2 Business Purpose

Network Sets serve multiple critical business functions:

1. **Member Eligibility**: Determines which networks a member can access based on plan enrollment
2. **Provider Participation**: Identifies which networks a provider participates in and during what periods
3. **Product Configuration**: Maps networks to insurance products and plan categories
4. **Network Availability**: Tracks when network sets are effective and when they expire
5. **Multi-Source Reconciliation**: Reconciles network definitions from FACETS and MDM systems

---

## 2. Grain & Dimensionality

### 2.1 Primary Grain

**One row = One unique network_set identifier (network_set_prefix + network_id) combination at a point in time**

The original dimension table (`dimNetworkSet_Base`) contains:
- One row per distinct network set prefix code
- One row per network ID
- No temporal dimension within the base table (uses effective/term dates as attributes)
- Surrogate key (`NetworkSetPK`) for fact table joining

### 2.2 Refined Grain in Business Vault

The refactoring introduces multiple grains:

#### Grain 2a: Network Set Core Attributes
- **Model**: `bv_s_network_set` (Non-temporal satellite)
- **Grain**: One row per unique network_set identifier
- **Change tracking**: Type-1 changes (overwrite)

#### Grain 2b: Member Network Set Business Rules  
- **Model**: `bv_s_member_network_set_business` (Effective-dated satellite)
- **Grain**: One row per member-network_set-time_period combination
- **Time sensitivity**: Full temporal tracking with start_date and end_date

#### Grain 2c: Provider Network Set Business Rules
- **Model**: `bv_s_provider_network_set_business` (Effective-dated satellite)
- **Grain**: One row per provider-network_set-time_period combination
- **Time sensitivity**: Full temporal tracking with start_date and end_date

---

## 3. Source Data Architecture

### 3.1 Source Tables (EDW2 Legacy)

Primary sources:
- `v_providernetworksetextended_combined_current`: Network set definitions with dates
- `v_providernetwork_combined_current`: Network reference data
- `v_productcomponent_combined_current`: Product component descriptions
- `ProviderNetwork_MDM`: Master Data Management network definitions
- `current_provider_network_relational`: Provider-network relationships

### 3.2 Key Join Logic

Network Set definition requires joining:
1. Network set table (network_set_prefix, network_id, dates)
2. Network table (for network descriptive attributes)
3. Product component table (for human-readable names)
4. Union with MDM for alternate source

---

## 4. Key Business Rules & Transformations

### 4.1 Network Name Derivation

**Rule**: Network name is determined by source system:

```sql
CASE 
  WHEN LOWER(source) = 'legacy_facets'
    THEN network_name              -- Use network name for FACETS
  ELSE component_prefix_description -- Use component description for others
END AS network_name
```

**Business Logic**:
- FACETS networks use provider network name
- Other networks use product component registry description
- Provides source-specific naming conventions

### 4.2 Source Code Classification

**Values**:
- `'legacy_facets'` = Legacy FACETS system
- `'mdm'` = Master Data Management system

Determines naming convention and data quality expectations.

### 4.3 MDM Capture Flag

```sql
'N' mdm_captured  -- For legacy_facets
'Y' mdm_captured  -- For MDM system
```

Identifies networks managed through modern MDM systems.

### 4.4 Effective/Term Date Filtering

Only network sets with termination date >= 2016-01-01:
```sql
WHERE network_set_term_dt >= '01/01/2016'
```

Aligns with data governance scope.

### 4.5 Network Set Prefix Validation

Network set prefix must not be NULL:
```sql
WHERE network_set_prefix IS NOT NULL
```

Network prefix is the key identifier.

---

## 12. Use Case Examples

### 12.1 Member Network Eligibility Query

"Which networks can member M123 access on 2024-10-01?"

```sql
SELECT DISTINCT ns.network_set, ns.network_name, ns.network_id
FROM bv_s_network_set ns
INNER JOIN bv_s_member_network_set_business mnb
  ON ns.hk_network_set = mnb.hk_network_set
WHERE mnb.member_bk = 'M123'
  AND CAST('2024-10-01' AS DATE) 
      BETWEEN mnb.dss_start_date AND mnb.dss_end_date
ORDER BY ns.network_set
```

### 12.2 Provider Network Participation Query

"What is provider P456 participation in network NET001 on 2024-10-01?"

```sql
SELECT pnb.network_participation_status, pnb.network_type_description,
       pnb.dss_start_date, pnb.dss_end_date
FROM bv_s_provider_network_set_business pnb
WHERE pnb.provider_id = 'P456'
  AND pnb.network_id = 'NET001'
  AND CAST('2024-10-01' AS DATE)
      BETWEEN pnb.dss_start_date AND pnb.dss_end_date
```

---

## 13. Glossary of Terms

| Term | Definition |
|------|-----------|
| **network_set** | Business identifier for configured network set |
| **network_set_prefix** | Code designating the network set |
| **network_id** | Identifier of underlying provider network |
| **source** | Origin system (legacy_facets or mdm) |
| **mdm_captured** | Flag: Y=MDM, N=FACETS |
| **dss_start/end_date** | Business Vault validity period |
| **is_current** | 1=current period, 0=historical |
| **hashdiff** | MD5 hash of payload for change detection |

---

**Document Version**: 1.0
**Last Updated**: October 27, 2025
**Status**: Complete Analysis
