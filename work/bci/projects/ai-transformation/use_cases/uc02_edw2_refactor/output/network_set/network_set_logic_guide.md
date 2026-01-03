---
title: "Network Set Logic Guide"
document_type: "logic_guide"
industry_vertical: "Healthcare Payer"
business_domain: ["provider", "membership", "product", "network-management"]
edp_layer: "business_vault"
technical_topics: ["network-management", "effectivity-satellite", "data-vault-2.0", "temporal-joins", "provider-networks", "member-eligibility"]
audience: ["executive-leadership", "management-product", "business-analyst", "engineering"]
status: "draft"
last_updated: "2025-12-11"
version: "1.0"
author: "Dan Brickey"
description: "Comprehensive guide for network set dimension and temporal member/provider network assignment tracking supporting claims processing, provider directories, and compliance reporting."
related_docs:
  - "network_set_business_rules.md"
  - "docs/architecture/overview/edp-platform-architecture.md"
  - "docs/engineering-knowledge-base/data-vault-2.0-guide.md"
model_name: "bv_s_network_set, bv_s_member_network_set_business, bv_sprovider_network_set_business"
legacy_source: "EDW2 HDSVault.biz.dimNetworkSet stored procedures (14 procedures + views)"
source_code_type: "SQL"
---

# Network Set – Logic Guide

## Executive Summary

The Network Set system ensures accurate healthcare network assignments for members and providers, directly protecting the organization from improper claims payments and member grievances. This logic determines which providers are "in-network" for each member's benefit plan at any point in time, controlling payment rates and member cost-sharing for claims. By consolidating network definitions from legacy FACETS systems and modern Master Data Management platforms while maintaining complete temporal history, the system enables claims adjudication accuracy, supports provider directory tools used by members and service representatives, and produces network adequacy reports required for state and federal regulatory compliance. The implementation processes network configurations from multiple source systems, creates time-accurate member-to-network assignments based on eligibility and plan relationships, and maintains historical provider network participation records covering over a decade of healthcare delivery.

### Key Terms

**Temporal Effectivity**: The practice of maintaining non-overlapping date ranges that track exactly when specific network assignments were valid, enabling point-in-time network status determination for any historical date needed for claims appeals or audits.

**Network Set Prefix**: A short alphanumeric code (such as 'BCI', 'ABC', or 'XYZ') that identifies a grouping of provider networks defining which providers members can access under specific benefit plans, with different prefixes representing different network configurations across product lines.

## Management Overview

- **Three Interconnected Components**: Provides master network set definitions (dimension table), temporal member network assignments (member network set assignments), and temporal provider network participation tracking (provider network set assignments), all synchronized to ensure consistent network status determination across claims, directories, and reporting systems.

- **Multi-Source Data Consolidation**: Integrates network data from Legacy and Gemstone FACETS operational systems and BCI MDM into a single authoritative source, using MDM-captured flags to track data governance maturity while maintaining backward compatibility with historical legacy system data.

- **Claims Processing Enablement**: Supports claims processing by determining network status for each claim line, directly impacting payment amounts, member cost-sharing calculations, and provider reimbursement rates, with errors potentially causing significant financial exposure and member complaints.

- **Provider Directory Accuracy**: Feeds member-facing provider directory tools and service representative lookup systems that display current network participation, enabling members to find in-network providers and avoid unexpected out-of-network costs, critical for member satisfaction and network adequacy compliance.

- **Historical Date Range Management**: Network Set dimension excludes networks terminated before January 1, 2016; Member network assignments track eligibility terminating on or after January 1, 2017; Provider network participation establishes baseline as of January 1, 2003, balancing storage costs against business requirements for historical analysis and appeals processing.

- **Daily Incremental Updates**: Refreshes with each data warehouse load (typically daily) to capture network changes from source systems, with current record indicators enabling instant filtering for active-as-of-today relationships while maintaining complete historical versions for audit trails and retrospective analysis.

- **Complex Temporal Join Logic**: Member network assignments use sophisticated algorithm spanning 9 staging procedures to handle overlapping date ranges across eligibility periods, plan assignments, and network set validity windows, creating discrete non-overlapping date ranges representing exactly when each network assignment was valid.

- **Known Limitations and Dependencies**: Member network assignments limited to medical product category only (dental and vision excluded); recursive consolidation logic capped at 99 levels to prevent infinite loops; requires synchronized data from eligibility systems, plan configuration, and provider contracting with failures or delays in upstream systems directly impacting network assignment accuracy and downstream claims processing.

## Analyst Detail

### Key Business Rules

**Network Set Historical Cutoff**: When `nwst.nwst_term_dt >= '01/01/2016'`, include the network set in the dimension, except when `nwst.nwst_pfx IS NULL`. This excludes obsolete historical networks that are no longer operationally relevant while maintaining sufficient history for current analysis, appeals, and regulatory reporting needs.

**Network Name Source Resolution**: When `bkcc_providernetworksetprefix = 'FCT'` (legacy FACETS source), use `nwnw.nwnw_name` from network master table, except when source is not FCT then use `pdpx.pdpx_desc` from product component where `pdbc_type = 'NWST'`. This handles different naming conventions between legacy operational systems and modern standardized product components.

**MDM Integration Rule**: When network source is from raw vault tables, set `MDMCaptured = 'N'` and use original `dss_record_source`, except when source is from `ref.ProviderNetwork_MDM` then set `MDMCaptured = 'Y'` and use `dss_record_source = 'bci-mdm.ref.providernetwork'`. This tracks which networks have been validated and managed through the Master Data Management governance process.

**Member Eligibility Filtering**: When `MEPE_ELIG_IND = 'Y'` AND `cspd_cat = 'M'` (medical product category) AND `MEPE_TERM_DT >= '01/01/2017'`, include the member eligibility record for network assignment processing, except when `bkcc_member IS NULL`. This ensures only active medical eligibility records with recent termination dates are processed for network assignment.

**Temporal Plan-to-Eligibility Join**: When `cspi_eff_dt <= mepe_term_dt` AND `cspi_term_dt >= mepe_eff_dt`, include the plan-member relationship in network assignment logic. This ensures the plan coverage period overlaps with the member's eligibility period, preventing invalid network assignments where plan and eligibility don't align temporally.

**Temporal Network-to-Plan Join**: When `nwst_eff_dt <= cspi_term_dt` AND `nwst_term_dt >= cspi_eff_dt` AND `nwst_eff_dt <= mepe_term_dt` AND `nwst_term_dt >= mepe_eff_dt`, assign the network set to the member for the overlapping period. This triple-temporal join ensures network assignments only exist when all three date ranges (eligibility, plan, network) overlap simultaneously.

**Member Date Boundary Collection**: Collect potential start dates from `mepe_eff_dt`, `cspi_eff_dt`, `nwst_eff_dt`, and `DATEADD(DAY, 1, term_dt)` for non-high-date terminators, except when termination date is `'12/31/9999'` then keep as-is. Collect potential end dates from `mepe_term_dt`, `cspi_term_dt`, `nwst_term_dt`, and `DATEADD(DAY, -1, eff_dt)`. This creates comprehensive set of date boundaries for discrete range generation.

**Member Date Range Pairing**: When pairing from_dates with thru_dates, select the thru_date where `DATEDIFF(DAY, from_date, thru_date) >= 0`, using `ROW_NUMBER()` ordered by `DATEDIFF(DAY, from_date, thru_date) ASC` to find the nearest matching thru_date, keeping only `rownum = 1`. This creates discrete non-overlapping date ranges spanning the full period where network assignments could exist.

### Data Flow & Transformations

The Network Set logic implements a three-component transformation pipeline processing network definitions, member assignments, and provider participation through distinct staging procedures in the EDW2 business vault layer.

**Component 1: Network Set Dimension Creation** begins with view `v_NetworkSet_Union` that unions two sources: raw vault network sets from `v_providernetworksetextended_combined_current` joined with network names from `v_providernetwork_combined_current` and product component descriptions from `v_productcomponent_combined_current`, plus MDM provider networks from `ref.ProviderNetwork_MDM` with standardized attributes. The staging procedure `update_NetworkSet_NonDV_01` applies deduplication using `ROW_NUMBER()` partitioned by `NetworkSet` and `NetworkID`, ordering by `SourceCode DESC` to prioritize certain source systems. For legacy FACETS records (source = 'FCT'), network names come from the network master table; for other sources, names derive from product component descriptions where component type equals 'NWST':

```sql
-- Network set union and name resolution
SELECT
    nwst.bkcc_providernetworksetprefix AS SourceCode,
    nwst.nwst_pfx NetworkSet,
    nwst.nwst_pfx NetworkCode,
    CASE
        WHEN nwst.bkcc_providernetworksetprefix = 'FCT'
            THEN nwnw.nwnw_name
        ELSE pdpx.pdpx_desc
    END NetworkName,
    nwst.nwnw_id NetworkID,
    'N' MDMCaptured,
    nwst.dss_record_source
FROM HDSVault.biz.v_providernetworksetextended_combined_current nwst
JOIN HDSVault.biz.v_providernetwork_combined_current nwnw
    ON nwnw.nwnw_id = nwst.nwnw_id
LEFT JOIN HDSVault.biz.v_productcomponent_combined_current pdpx
    ON nwst.NWST_PFX = pdpx.PDBC_PFX
    AND pdpx.PDBC_TYPE = 'NWST'
WHERE nwst.nwst_term_dt >= '01/01/2016'
    AND nwst.nwst_pfx IS NOT NULL
```

**Component 2: Member Network Assignment** employs a sophisticated temporal effectivity algorithm spanning six staging procedures. Procedure `update_MemberNetworkSetLookup_NonDV_01` filters active medical eligibility where `MEPE_ELIG_IND = 'Y'` and `cspd_cat = 'M'` and `MEPE_TERM_DT >= '01/01/2017'`. Procedure `update_MemberNetworkSetLookup_NonDV_02` joins eligibility to group plan assignments and network sets using temporal overlap conditions, capturing all the component dates. Procedure `update_MemberNetworkSetLookup_NonDV_03` collects all potential "from" boundary dates by unioning effective dates, termination dates, and day-after-termination dates (except for high date `'12/31/9999'` which stays unchanged). Procedure `update_MemberNetworkSetLookup_NonDV_04` similarly collects all potential "thru" boundary dates by unioning termination dates and day-before-effective dates. Procedure `update_MemberNetworkSetLookup_NonDV_05` pairs each from_date with the nearest thru_date using `ROW_NUMBER()` ordered by date difference, creating discrete non-overlapping date ranges:

```sql
-- Date range pairing logic from NonDV_05
INSERT INTO HDSVault.biz.MemberNetworkSetLookup_NonDV_05
(SourceCode, meme_ck, FromDate, ThruDate)
SELECT
    MemberNetworkSetLookup_NonDV_03.SourceCode,
    MemberNetworkSetLookup_NonDV_03.meme_ck,
    MemberNetworkSetLookup_NonDV_03.FromDate,
    MemberNetworkSetLookup_NonDV_04.ThruDate
FROM HDSVault.biz.MemberNetworkSetLookup_NonDV_03
INNER JOIN HDSVault.biz.MemberNetworkSetLookup_NonDV_04
    ON MemberNetworkSetLookup_NonDV_03.SourceCode = MemberNetworkSetLookup_NonDV_04.SourceCode
    AND MemberNetworkSetLookup_NonDV_03.meme_ck = MemberNetworkSetLookup_NonDV_04.meme_ck
WHERE DATEDIFF(DAY, FromDate, ThruDate) >= 0
```

For each discrete date range, procedure `update_MemberNetworkSetLookup_NonDV_06` identifies which network assignment is valid by checking if the range's start date falls within all three temporal windows (eligibility, plan, network), using `nwst_seq_no` to prioritize when multiple networks qualify. The final output includes enrichment with `grgr_id` from group table, `sbsb_id` from subscriber table, and `meme_sfx` from member table.

**Component 3: Provider Network Participation** processes provider-network relationships through staging procedure `update_NetworkSet_NonDV_02`. The logic first handles overlapping effective dates in source data from `v_providernetworkrelational_combined_current` by using window functions to detect when consecutive records have identical effective dates, then adjusting later records to start the day after the prior record's termination. The transformation tracks prior and next dates using `LAG()` and `LEAD()` window functions to determine participation status ('Active' when no subsequent record exists, 'InActive' otherwise). It enriches provider-network relationships with network names from `v_providernetwork_combined_current`, network type descriptions from `v_userdefinedcodetranslations_combined_current`, and prefix descriptions from `v_productcomponent_combined_current`, applying special handling for the 'BCI' prefix which uses the literal string 'BCI' instead of a product component lookup.

```sql
-- Provider network deduplication with row numbering
SELECT
    v_NetworkSet_Union.SourceCode,
    v_NetworkSet_Union.NetworkCode,
    v_NetworkSet_Union.NetworkName,
    v_NetworkSet_Union.NetworkID,
    v_NetworkSet_Union.NetworkSet,
    v_NetworkSet_Union.MDMCaptured,
    ROW_NUMBER() OVER (
        PARTITION BY NetworkSet, NetworkID
        ORDER BY SourceCode DESC
    ) RowNum,
    v_NetworkSet_Union.dss_record_source
FROM HDSVault.biz.v_NetworkSet_Union
```

### Validation & Quality Checks

**Network Set Uniqueness Check**: Verify all combinations of `NetworkSet` and `NetworkID` appear exactly once in the dimension after deduplication. Query: `SELECT NetworkSet, NetworkID, COUNT(*) FROM biz.dimNetworkSet_Base WHERE dss_current_flag = 'Y' GROUP BY NetworkSet, NetworkID HAVING COUNT(*) > 1` should return zero rows, ensuring no duplicate network definitions exist in active records.

**Member Network Temporal Integrity**: Verify no overlapping date ranges exist for the same member and network combination. Query: `SELECT a.meme_ck FROM biz.MemberNetworkSetLookup_Base a JOIN biz.MemberNetworkSetLookup_Base b ON a.meme_ck = b.meme_ck AND a.nwst_pfx = b.nwst_pfx WHERE a.EndDate >= b.StartDate AND a.StartDate <= b.EndDate AND a.StartDate <> b.StartDate` should return zero rows, confirming clean temporal boundaries.

**Member Eligibility Grain Check**: Verify member network staging tables maintain correct grain throughout transformation pipeline. Query: `SELECT SourceCode, meme_ck, FromDate, COUNT(*) FROM biz.MemberNetworkSetLookup_NonDV_03 GROUP BY SourceCode, meme_ck, FromDate HAVING COUNT(*) > 1` should be empty, ensuring no duplicate date boundaries per member.

**Provider Network Gap Detection**: Verify provider-network-prefix combinations have contiguous date ranges with no unexpected gaps in participation history. Query: `SELECT prpr_id, nwnw_id, nwpr_pfx FROM biz.NetworkSet_NonDV_02 a WHERE EXISTS (SELECT 1 FROM biz.NetworkSet_NonDV_02 b WHERE a.prpr_id = b.prpr_id AND a.nwnw_id = b.nwnw_id AND a.nwpr_pfx = b.nwpr_pfx AND DATEADD(DAY, 1, a.end_date) < b.start_date)` identifies gaps in provider participation.

**Referential Integrity Check**: Verify all network IDs in member and provider assignments exist in the network set dimension. Query: `SELECT DISTINCT nwnw_id FROM biz.MemberNetworkSetLookup_Base WHERE nwnw_id NOT IN (SELECT NetworkID FROM biz.dimNetworkSet_Base WHERE dss_current_flag = 'Y')` should return zero rows, ensuring all referenced networks are defined.

**MDM Capture Flag Validation**: Verify MDM records properly flagged and distinct from raw vault records. Query: `SELECT MDMCaptured, COUNT(*) FROM biz.dimNetworkSet_Base WHERE dss_current_flag = 'Y' GROUP BY MDMCaptured` should show appropriate distribution between 'Y' (MDM) and 'N' (raw vault) values.

### Example Scenario

**Scenario**: Member M12345 enrolls in employer group G98765's medical plan with network set 'BCI' effective January 1, 2024. On April 1, 2024, the employer switches the entire group to network set 'XYZ' while the member remains continuously enrolled. On July 31, 2024, the member's eligibility terminates.

**Input Data**:
- `v_membereligibilityextended_combined_current`: meme_ck='M12345', mepe_elig_ind='Y', cspd_cat='M', mepe_eff_dt='2024-01-01', mepe_term_dt='2024-07-31', grgr_ck='G98765'
- `v_groupplaneligibility_combined_current` (plan 1): grgr_ck='G98765', cspi_eff_dt='2024-01-01', cspi_term_dt='2024-03-31', nwst_pfx='BCI', nwst_seq_no=1
- `v_groupplaneligibility_combined_current` (plan 2): grgr_ck='G98765', cspi_eff_dt='2024-04-01', cspi_term_dt='9999-12-31', nwst_pfx='XYZ', nwst_seq_no=1
- `v_providernetworksetextended_combined_current` (BCI): nwst_pfx='BCI', nwst_eff_dt='2020-01-01', nwst_term_dt='9999-12-31', nwnw_id='100'
- `v_providernetworksetextended_combined_current` (XYZ): nwst_pfx='XYZ', nwst_eff_dt='2023-06-01', nwst_term_dt='9999-12-31', nwnw_id='200'

**Transformation Logic**: Procedure NonDV_01 filters the active medical eligibility. Procedure NonDV_02 joins to both group plans using temporal overlap conditions, finding that BCI plan overlaps 2024-01-01 to 2024-03-31 and XYZ plan overlaps 2024-04-01 to 2024-07-31 with eligibility. Procedure NonDV_03 collects from_dates: 2024-01-01 (elig_eff + cspi_eff for BCI), 2024-04-01 (cspi_eff for XYZ), 2024-08-01 (day after elig_term). Procedure NonDV_04 collects thru_dates: 2024-03-31 (cspi_term for BCI), 2024-07-31 (elig_term), 2024-12-31 (high date), plus day-before-effective dates. Procedure NonDV_05 pairs dates creating discrete ranges: 2024-01-01 to 2024-03-31, 2024-04-01 to 2024-07-31. For first range starting 2024-01-01, the algorithm finds BCI network set valid (all three date windows overlap). For second range starting 2024-04-01, it finds XYZ network set valid. Procedure NonDV_06 enriches with grgr_id, sbsb_id, meme_sfx from member/group/subscriber tables.

**Output Data**:
- `biz.MemberNetworkSetLookup_Base`: SourceCode='GEM', meme_ck='M12345', grgr_id='G98765', nwst_pfx='BCI', nwnw_id='100', StartDate='2024-01-01', EndDate='2024-03-31'
- `biz.MemberNetworkSetLookup_Base`: SourceCode='GEM', meme_ck='M12345', grgr_id='G98765', nwst_pfx='XYZ', nwnw_id='200', StartDate='2024-04-01', EndDate='2024-07-31'

## Engineering Reference

### Technical Architecture

The Network Set implementation follows a multi-stage SQL Server stored procedure architecture within the EDW2 HDSVault business layer:

**Integration Layer (Raw Vault Views)**:
- Source views: `v_providernetworksetextended_combined_current`, `v_providernetwork_combined_current`, `v_membereligibilityextended_combined_current`, `v_groupplaneligibility_combined_current`, `v_providernetworkrelational_combined_current`, `v_productcomponent_combined_current`, `v_userdefinedcodetranslations_combined_current`, `v_member_combined_current`, `v_group_combined_current`, `v_subscriber_combined_current`
- Reference data: `ref.ProviderNetwork_MDM`

**Business Vault Layer (Dimension and Staging Tables)**:
- `biz.v_NetworkSet_Union`: View unioning raw vault and MDM network sources
- `biz.NetworkSet_NonDV_01`: Staging table with row numbering for deduplication
- `biz.NetworkSet_NonDV_02`: Final staging with hash calculations
- `biz.dimNetworkSet_NonDV`: Non-DV dimension staging
- `biz.dimNetworkSet_Base`: Type 2 SCD dimension table with history
- `biz.MemberNetworkSetLookup_NonDV_01` through `_06`: Six-stage member assignment pipeline
- `biz.MemberNetworkSetLookup_Base`: Final member-network assignments

**Pipeline DAG (Execution Order)**:
1. `update_NetworkSet_NonDV_01` → `update_NetworkSet_NonDV_02` → `update_dimNetworkSet_NonDV` → `update_dimNetworkSet_Base`
2. `update_MemberNetworkSetLookup_NonDV_01` → `_02` → `_03` → `_04` → `_05` → `_06` → `update_MemberNetworkSetLookup_Base`
3. Pipeline orchestrated by WhereScape RED scheduler with dependency management

**Materialization Strategy**:
- Views: Lightweight transformation layer with no storage (`v_NetworkSet_Union`)
- Staging tables: TRUNCATE and full reload on each execution (all `NonDV_*` tables)
- Base tables: Type 2 SCD with incremental merge logic using hash comparison (`dimNetworkSet_Base`)

### Critical Implementation Details

**Incremental Logic**: The `dimNetworkSet_Base` table uses Type 2 SCD pattern with hash-based change detection. The `update_dimNetworkSet_Base` procedure compares `NKHash` (natural key hash) between incoming `dimNetworkSet_NonDV` staging and existing `dimNetworkSet_Base` records. When hashes differ, it expires the old record by setting `dss_end_date = GETDATE() - 0.00000005` and `dss_current_flag = 'N'`, then inserts new record with `dss_start_date = GETDATE()` and incremented `dss_version`. New network sets get `dss_start_date = '01-JAN-1900'` and `dss_version = 1`.

**Join Strategy**:
- Network Set: Simple inner joins with 1:1 cardinality between network_set and network (one network per network set prefix), LEFT JOIN to product component (may not exist for all sources)
- Member Network: Complex many-to-many resolved through temporal filtering and six-stage transformation (one eligibility can have multiple plans, one plan can have multiple network sets, creating cartesian product requiring sophisticated date pairing logic)
- Provider Network: 1:many relationship between provider and networks (one provider participates in multiple networks over time)

**Filters**: Critical WHERE clauses include `nwst_term_dt >= '01/01/2016'` (network set historical cutoff), `MEPE_ELIG_IND = 'Y'` (active eligibility only), `cspd_cat = 'M'` (medical product category), `MEPE_TERM_DT >= '01/01/2017'` (member eligibility cutoff), `nwst_pfx IS NOT NULL` (data quality), and all joins require matching source codes (`bkcc_*` columns).

**Aggregations**: Network set dimension uses `GROUP BY` with `ROW_NUMBER()` for deduplication partitioned by `NetworkSet, NetworkID` ordered by `SourceCode DESC`. Member date boundary collection uses `UNION` to combine multiple date sources, then `GROUP BY` to deduplicate. Date range pairing uses `DATEDIFF(DAY, from_date, thru_date)` calculation for matching logic.

**Change Tracking**: Dimension table implements Type 2 SCD with `dss_start_date`, `dss_end_date`, `dss_current_flag`, `dss_version` for historical tracking. Hash columns `NKHash` (natural key) and `Type1Hash` (attributes) detect changes. Member network assignments use StartDate/EndDate columns as temporal effectivity ranges without versioning.

**Performance Considerations**:
- Staging tables use `WITH (TABLOCK)` hint for bulk insert performance
- All staging procedures include `SET NOCOUNT ON` to reduce network traffic
- TRUNCATE TABLE used instead of DELETE for faster staging table cleanup
- Row numbering window functions partition data to reduce sort memory requirements
- Views with `WITH (NOLOCK)` hints prevent blocking in read-heavy staging queries

### Code Examples

**Complex Type 2 SCD Logic: Network Set Dimension Update**:
```sql
-- Purpose: Implement Type 2 SCD pattern with hash-based change detection
-- Critical: Maintains full history while marking only latest version as current

-- Update expiring rows: records that changed attributes
UPDATE HDSVault.biz.dimNetworkSet_Base WITH (TABLOCK)
SET dss_end_date = @v_current_date - 0.00000005,
    dss_current_flag = 'N',
    dss_update_time = @v_current_datetime
FROM (
    -- Find records in staging that differ from current dimension
    SELECT dimNetworkSet_NonDV.NetworkSet, NetworkCode, NetworkName,
           NetworkID, MDMCaptured, SourceCode, dss_record_source,
           NKHash, Type1Hash
    FROM HDSVault.biz.dimNetworkSet_NonDV
    EXCEPT
    SELECT dimNetworkSet_Base.NetworkSet, NetworkCode, NetworkName,
           NetworkID, MDMCaptured, SourceCode, dss_record_source,
           NKHash, Type1Hash
    FROM HDSVault.biz.dimNetworkSet_Base
    WHERE dss_current_flag = 'Y'
) AS changes
WHERE dimNetworkSet_Base.NetworkSet = changes.NetworkSet
  AND dimNetworkSet_Base.NetworkID = changes.NetworkID
  AND dimNetworkSet_Base.dss_current_flag = 'Y'
  -- Hash comparison detects attribute changes
  AND (dimNetworkSet_Base.NKHash <> changes.NKHash
       OR (dimNetworkSet_Base.NKHash IS NULL AND changes.NKHash IS NOT NULL)
       OR (dimNetworkSet_Base.NKHash IS NOT NULL AND changes.NKHash IS NULL))
```

**Critical Transformation: Member Network Temporal Date Pairing**:
```sql
-- Purpose: Pair from_dates with nearest thru_dates to create discrete ranges
-- Critical: Eliminates overlaps and gaps in member network assignment periods

INSERT INTO HDSVault.biz.MemberNetworkSetLookup_NonDV_05
(SourceCode, meme_ck, FromDate, ThruDate, dss_create_time, dss_update_time)
SELECT
    from_dates.SourceCode,
    from_dates.meme_ck,
    from_dates.FromDate,
    thru_dates.ThruDate,
    @v_dss_create_time,
    @v_dss_update_time
FROM (
    -- All potential start dates from eligibility, plan, and network set
    SELECT SourceCode, meme_ck, mepe_eff_dt as FromDate
    FROM MemberNetworkSetLookup_NonDV_02
    UNION
    SELECT SourceCode, meme_ck, cspi_eff_dt
    FROM MemberNetworkSetLookup_NonDV_02
    UNION
    SELECT SourceCode, meme_ck, nwst_eff_dt
    FROM MemberNetworkSetLookup_NonDV_02
    UNION
    -- Day after termination could be a new from_date
    SELECT SourceCode, meme_ck,
        CASE WHEN mepe_term_dt = '12/31/9999'
             THEN mepe_term_dt
             ELSE DATEADD(DAY, 1, mepe_term_dt)
        END
    FROM MemberNetworkSetLookup_NonDV_02
    -- Additional unions for cspi_term_dt and nwst_term_dt...
) as from_dates
INNER JOIN (
    -- All potential end dates from eligibility, plan, and network set
    SELECT SourceCode, meme_ck, mepe_term_dt as ThruDate
    FROM MemberNetworkSetLookup_NonDV_02
    UNION
    SELECT SourceCode, meme_ck, cspi_term_dt
    FROM MemberNetworkSetLookup_NonDV_02
    -- Additional unions and day-before-effective logic...
) as thru_dates
    ON from_dates.SourceCode = thru_dates.SourceCode
    AND from_dates.meme_ck = thru_dates.meme_ck
WHERE DATEDIFF(DAY, from_dates.FromDate, thru_dates.ThruDate) >= 0
```

**Deduplication Logic: Network Set Row Numbering**:
```sql
-- Purpose: Apply deduplication to network sets from multiple sources
-- Critical: Prioritizes source systems when same network exists in multiple sources

INSERT INTO HDSVault.biz.NetworkSet_NonDV_01
(SourceCode, NetworkCode, NetworkName, NetworkID, NetworkSet,
 MDMCaptured, RowNum, dss_record_source)
SELECT
    v_NetworkSet_Union.SourceCode,
    v_NetworkSet_Union.NetworkCode,
    v_NetworkSet_Union.NetworkName,
    v_NetworkSet_Union.NetworkID,
    v_NetworkSet_Union.NetworkSet,
    v_NetworkSet_Union.MDMCaptured,
    -- Deduplication using row numbering
    ROW_NUMBER() OVER (
        PARTITION BY NetworkSet, NetworkID
        ORDER BY SourceCode DESC
    ) RowNum,
    v_NetworkSet_Union.dss_record_source
FROM HDSVault.biz.v_NetworkSet_Union
```

### Common Issues & Troubleshooting

**Issue**: Duplicate NetworkSet-NetworkID combinations in dimNetworkSet_Base with dss_current_flag = 'Y'
**Cause**: Deduplication logic in NetworkSet_NonDV_01 failed to properly assign RowNum, or subsequent procedure NetworkSet_NonDV_02 didn't filter to RowNum = 1
**Resolution**: Query staging table to diagnose: `SELECT NetworkSet, NetworkID, RowNum, COUNT(*) FROM biz.NetworkSet_NonDV_01 GROUP BY NetworkSet, NetworkID, RowNum HAVING COUNT(*) > 1`. If duplicates exist with same RowNum, investigate ROW_NUMBER() partition/order logic. Check that NetworkSet_NonDV_02 includes `WHERE RowNum = 1` filter.
**Prevention**: Add data quality check in NetworkSet_NonDV_02 procedure to validate uniqueness before inserting into dimNetworkSet_NonDV: `IF EXISTS (SELECT 1 FROM staging GROUP BY NetworkSet, NetworkID HAVING COUNT(*) > 1) RAISERROR('Duplicate network sets detected', 16, 1)`

**Issue**: Member network assignment query timeout in update_MemberNetworkSetLookup_NonDV_05 exceeding 30 minutes
**Cause**: Cartesian product explosion in from_dates/thru_dates INNER JOIN when member has many eligibility, plan, and network set combinations (10+ plan changes creating 100+ date boundaries)
**Resolution**: Add diagnostic query to check date boundary volume: `SELECT meme_ck, COUNT(*) as boundary_count FROM MemberNetworkSetLookup_NonDV_03 GROUP BY meme_ck ORDER BY boundary_count DESC`. For members with >500 boundaries, consider adding WHERE clause to limit date range or process in batches. Increase SQL Server query timeout setting temporarily or add index on (SourceCode, meme_ck, FromDate) to NonDV_03 and NonDV_04 tables.
**Prevention**: Monitor CTE row counts in execution plan; alert when NonDV_03 exceeds 50k rows per batch run. Consider redesigning to process member segments by eligibility year rather than all members simultaneously.

**Issue**: Member network assignments showing gaps in date ranges (EndDate + 1 <> next StartDate)
**Cause**: Date pairing logic in NonDV_05 failed to find valid thru_date for some from_dates, or network assignment filtering in NonDV_06 excluded some date ranges because no network qualified during that period
**Resolution**: Query NonDV_05 to find gaps: `SELECT a.meme_ck, a.ThruDate, b.FromDate, DATEDIFF(DAY, a.ThruDate, b.FromDate) as gap_days FROM MemberNetworkSetLookup_NonDV_05 a JOIN MemberNetworkSetLookup_NonDV_05 b ON a.meme_ck = b.meme_ck WHERE b.FromDate > DATEADD(DAY, 1, a.ThruDate)`. If gaps exist, check if those periods have valid network set assignments in NonDV_02. Gaps may be valid if member had eligibility but no plan assignment during that period.
**Prevention**: Document expected behavior that gaps can occur when member has eligibility but no plan assignment. Add business rule validation to identify members with eligibility>30 days but no network assignment for stakeholder review.

**Issue**: Network set dimension missing records expected from MDM
**Cause**: MDM records filtered out by deduplication logic (RowNum > 1) due to matching non-MDM record with higher priority SourceCode in ORDER BY
**Resolution**: Check deduplication: `SELECT NetworkSet, NetworkID, SourceCode, MDMCaptured, ROW_NUMBER() OVER (PARTITION BY NetworkSet, NetworkID ORDER BY SourceCode DESC) as RowNum FROM biz.v_NetworkSet_Union WHERE NetworkSet = 'ABC'`. If MDM record (SourceCode = 'MDM') has RowNum > 1, a raw vault record took precedence. Review if `ORDER BY SourceCode DESC` prioritization is correct for business requirements (may need to prioritize MDM over legacy sources).
**Prevention**: Add reconciliation report comparing MDM record count to final dimension record count: `SELECT MDMCaptured, COUNT(*) FROM dimNetworkSet_Base WHERE dss_current_flag = 'Y' GROUP BY MDMCaptured`. Alert when MDM percentage drops below expected threshold.

**Issue**: Type 2 SCD dimension shows multiple current versions for same network set
**Cause**: Update logic failed to properly expire old record before inserting new version, or transaction rollback left partial updates
**Resolution**: Identify duplicate currents: `SELECT NetworkSet, NetworkID, COUNT(*) FROM dimNetworkSet_Base WHERE dss_current_flag = 'Y' GROUP BY NetworkSet, NetworkID HAVING COUNT(*) > 1`. Manually expire incorrect current record: `UPDATE dimNetworkSet_Base SET dss_current_flag = 'N', dss_end_date = DATEADD(DAY, -1, (SELECT MIN(dss_start_date) FROM dimNetworkSet_Base b WHERE b.NetworkSet = dimNetworkSet_Base.NetworkSet AND b.NetworkID = dimNetworkSet_Base.NetworkID AND b.dss_version > dimNetworkSet_Base.dss_version)) WHERE NetworkSetPK = <incorrect_pk>`.
**Prevention**: Wrap entire update_dimNetworkSet_Base procedure in explicit transaction with comprehensive error handling. Add pre-execution validation to check staging data won't create duplicates before beginning updates.

**Issue**: Member network assignment procedure update_MemberNetworkSetLookup_NonDV_06 returns zero rows despite NonDV_05 having data
**Cause**: WHERE clause `WHERE 1 = 0` in procedure disables actual execution, relying on external custom stored procedure `biz.spMemberNetworkSetLookup_DateRanges` to populate the table (as noted in code comment)
**Resolution**: This is intentional design per code comment "This table is populated by a custom stored proc: biz.spMemberNetworkSetLookup_DateRanges". The NonDV_06 procedure structure exists for WhereScape RED framework compatibility but actual logic is in separate custom procedure. Verify custom procedure executed successfully and check its output.
**Prevention**: Document that NonDV_06 is placeholder only. Ensure job scheduling includes custom procedure execution after NonDV_05 completes. Consider refactoring to move custom procedure logic into NonDV_06 to consolidate pipeline.

### Testing & Validation

**Unit Test Scenarios**:

1. **Single Network, Continuous Period**: Member with one eligibility period 2024-01-01 to 2024-12-31, one plan 2024-01-01 to 2024-12-31, one network set 'BCI' 2020-01-01 to 9999-12-31. Expected: One output record with StartDate='2024-01-01', EndDate='2024-12-31', nwst_pfx='BCI'.

2. **Plan Change Mid-Period**: Member with eligibility 2024-01-01 to 2024-12-31, plan ABC 2024-01-01 to 2024-06-30, plan XYZ 2024-07-01 to 2024-12-31. Expected: Two records: ABC 2024-01-01 to 2024-06-30, XYZ 2024-07-01 to 2024-12-31 with no gaps or overlaps.

3. **Network Set Date Range Subset**: Member with eligibility 2024-01-01 to 2024-12-31, plan 2024-01-01 to 2024-12-31, network set 2024-03-01 to 2024-09-30. Expected: One record with StartDate='2024-03-01', EndDate='2024-09-30', constrained by network set validity period.

4. **Multiple Overlapping Dates**: Member with eligibility 2024-01-01 to 2024-12-31, plan changes every quarter, network set changes mid-year. Expected: Date pairing logic creates discrete ranges at each boundary with correct network assignment per period.

5. **Type 2 SCD Attribute Change**: Network set 'ABC' exists with NetworkName='Old Name', then MDM updates to 'New Name'. Expected: Old record gets dss_end_date set to update time and dss_current_flag='N', new record inserted with incremented dss_version and dss_current_flag='Y'.

**Data Quality Checks**:

```sql
-- Row count validation: Dimension should have reasonable record count
SELECT COUNT(*) as total_records,
    COUNT(DISTINCT NetworkSet) as distinct_networks,
    SUM(CASE WHEN dss_current_flag = 'Y' THEN 1 ELSE 0 END) as current_records,
    SUM(CASE WHEN MDMCaptured = 'Y' THEN 1 ELSE 0 END) as mdm_records
FROM biz.dimNetworkSet_Base;
-- Alert if total_records drops >10% from previous run or mdm_records = 0

-- Null check: Critical business keys should never be null
SELECT COUNT(*) as null_count
FROM biz.dimNetworkSet_Base
WHERE NetworkSet IS NULL
   OR NetworkID IS NULL
   OR dss_record_source IS NULL;
-- Expect: 0

-- Type 2 SCD validation: Each natural key should have exactly one current record
SELECT NetworkSet, NetworkID, COUNT(*) as current_count
FROM biz.dimNetworkSet_Base
WHERE dss_current_flag = 'Y'
GROUP BY NetworkSet, NetworkID
HAVING COUNT(*) > 1;
-- Expect: 0 rows (no duplicate currents)

-- Member network temporal overlap check: No overlapping ranges
SELECT a.meme_ck, a.nwst_pfx, a.nwnw_id,
    a.StartDate as a_start, a.EndDate as a_end,
    b.StartDate as b_start, b.EndDate as b_end
FROM biz.MemberNetworkSetLookup_Base a
JOIN biz.MemberNetworkSetLookup_Base b
    ON a.SourceCode = b.SourceCode
    AND a.meme_ck = b.meme_ck
    AND a.nwst_pfx = b.nwst_pfx
    AND a.nwnw_id = b.nwnw_id
    AND a.StartDate < b.StartDate
    AND a.EndDate >= b.StartDate;
-- Expect: 0 rows (no overlaps for same member-network)

-- Historical cutoff validation: Verify date filters applied correctly
SELECT COUNT(*) as pre_2016_networks
FROM biz.dimNetworkSet_Base
WHERE dss_start_date < '2016-01-01'
  AND dss_current_flag = 'Y';
-- Should be small count (only networks with term_dt >= 2016-01-01)

SELECT COUNT(*) as pre_2017_members
FROM biz.MemberNetworkSetLookup_Base
WHERE EndDate < '2017-01-01';
-- Should be zero (all assignments should have term_dt >= 2017-01-01)
```

**Regression Tests**:

When modifying temporal join logic, validate:
- Total record count in MemberNetworkSetLookup_Base remains within 5% of baseline
- Distinct member count (meme_ck) unchanged unless eligibility data changed
- No new null values introduced in required fields (nwst_pfx, nwnw_id, StartDate, EndDate)
- Maximum date range length per member-network remains reasonable (<10 years for continuous enrollment)
- Average number of network assignment ranges per member stays consistent (typically 1-3 for stable members)

When modifying deduplication logic, validate:
- Network set dimension record count change aligns with MDM prioritization intent
- No NetworkSet-NetworkID duplicates in current records (dss_current_flag='Y')
- MDM captured flag distribution matches expectations (track % of records with MDMCaptured='Y')
- Version numbering sequential for each natural key (no gaps in dss_version)

### Dependencies & Risks

**Upstream Dependencies**:
- `v_membereligibilityextended_combined_current`: Daily refresh from eligibility system; SLA 6am CT; delays prevent member network assignment processing blocking claims adjudication
- `v_providernetworksetextended_combined_current`: Daily refresh from plan configuration system; SLA 5am CT; stale data causes incorrect network assignments for new/changed plans
- `v_providernetworkrelational_combined_current`: Daily refresh from provider contracting; SLA 7am CT; delays cause provider directory inaccuracy showing wrong network participation
- `v_groupplaneligibility_combined_current`: Daily refresh from group plan system; critical for member network assignment temporal joins
- `ref.ProviderNetwork_MDM`: Weekly refresh from BCI MDM; SLA Monday 8am CT; failures prevent MDM network updates and delay data governance improvements

**Downstream Impacts**:
- Claims adjudication system queries dimNetworkSet_Base and MemberNetworkSetLookup_Base for in-network determination; failures cause claims to pend requiring manual intervention and delaying provider payments
- Provider directory application queries provider network participation for member-facing tools; stale or incorrect data causes members to visit wrong providers incurring unexpected out-of-network costs and generating complaints
- Network adequacy reporting consumes all three artifacts for state/federal submissions; failures block regulatory reporting potentially causing compliance violations
- Financial reporting uses network assignments for cost analysis and trend reporting; incorrect assignments skew utilization metrics and financial forecasts
- Care management uses member network assignments to coordinate care with correct in-network providers; wrong assignments cause care coordination failures

**Data Quality Risks**:
- Source systems may have overlapping date ranges requiring resolution logic; if resolution logic fails or encounters unexpected patterns, duplicates propagate to business vault causing downstream query errors
- Member eligibility and plan assignments may have temporal gaps (member not covered for periods); gap removal logic eliminates these periods but may create appearance of missing data requiring business user education
- MDM integration incomplete; some networks captured in MDM while others remain in raw vault creating inconsistent governance and data quality across network set records
- Historical cutoff dates (2016 for networks, 2017 for members) may exclude records needed for long-running claims appeals or regulatory audits requiring ad-hoc historical data restoration
- Network set prefix naming not standardized across source systems; different sources may use different codes for same network requiring manual mapping and reconciliation

**Performance Risks**:
- Member network temporal join can produce cartesian product for members with 10+ plan changes; six-stage transformation pipeline may timeout on default SQL Server query timeout settings requiring timeout extensions
- Date boundary collection and pairing (NonDV_03, _04, _05) can generate millions of intermediate rows when processing full member population; requires adequate tempdb space and memory allocation
- Type 2 SCD dimension update uses EXCEPT operator comparing full record sets; performance degrades as dimension grows beyond 100k records potentially requiring partitioning strategy
- TRUNCATE and full reload strategy for staging tables causes table locks; concurrent queries on staging tables may block requiring read-uncommitted isolation level or query retry logic
- WhereScape RED framework overhead adds procedural wrapper code; direct SQL execution would be faster but loses audit trail and error handling features requiring trade-off evaluation
