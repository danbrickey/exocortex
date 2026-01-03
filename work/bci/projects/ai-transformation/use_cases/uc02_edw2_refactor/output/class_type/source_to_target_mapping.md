# Class Type - Source to Target Mapping

**Purpose**: Complete mapping of EDW2 source columns to EDW3 target columns
**Version**: 1.0
**Date**: 2025-10-12

---

## Overview

This document provides a comprehensive mapping from the legacy EDW2 SQL Server implementation to the new EDW3 Snowflake implementation. Use this for data validation, reconciliation testing, and understanding the transformation lineage.

---

## Source System Mapping

### EDW2 Raw Vault → EDW3 Raw Vault

| EDW2 Table | EDW3 Table | EDW2 Column | EDW3 Column | Transformation |
|------------|------------|-------------|-------------|----------------|
| v_group_combined_current | current_group | grgr_id | group_id | Direct mapping |
| v_group_combined_current | current_group | grgr_ck | group_bk | Direct mapping |
| v_group_combined_current | current_group | BKCC_Group | source | Direct mapping |
| v_groupclass_combined_current | current_class_group | cscs_id | class_bk | Direct mapping |
| v_groupclass_combined_current | current_class_group | cscs_desc | class_description | Direct mapping |
| v_groupclass_combined_current | current_class_group | GRGR_CK | group_bk | Direct mapping |
| v_groupclass_combined_current | current_class_group | BKCC_class | source | Direct mapping |
| v_r_SourceBKCCLookup | r_source_system | SourceID | source | Direct mapping |
| v_r_SourceBKCCLookup | r_source_system | SourceDescription | source_description | Direct mapping |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | GroupID | group_id | Direct mapping |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | ClassID | class_bk | Direct mapping |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | BKCC_Class | source | Direct mapping |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | EffectiveFromDate | effective_from | Direct mapping |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | EffectiveToDate | effective_to | Direct mapping |
| v_s_classtypeassignment_mroc_bcidaho_current | r_class_type_assignment | DescriptionPK | description_key | Direct mapping |
| v_s_classtypedescription_mroc_bcidaho_current | r_class_type_assignment | DescriptionPK | description_key | Merged into assignment table |
| v_s_classtypedescription_mroc_bcidaho_current | r_class_type_assignment | description | description | Merged into assignment table |
| v_s_classtypedescription_mroc_bcidaho_current | r_class_type_assignment | BKCC_ClassType | source | Merged into assignment table |

---

## Business Vault Hub Mapping

### bv_h_class_type

| Target Column | Source Table(s) | Source Column(s) | Transformation |
|---------------|-----------------|------------------|----------------|
| class_type_hk | Calculated | - | SHA1_BINARY(UPPER(TRIM(class_type_bk)) \|\| '\|\|' \|\| UPPER(TRIM(source))) |
| class_type_bk | current_group, current_class_group | group_id, class_bk | RTRIM(group_id) \|\| LTRIM(class_bk) |
| record_source | current_group | source | Direct mapping |
| load_datetime | current_group, current_class_group | load_datetime | GREATEST(group.load_datetime, class.load_datetime) |

---

## Business Vault Satellite Mapping

### bv_s_class_type_business

| Target Column | Source Table(s) | Source Column(s) | Transformation |
|---------------|-----------------|------------------|----------------|
| class_type_hk | Calculated | - | SHA1_BINARY(UPPER(TRIM(class_type_bk)) \|\| '\|\|' \|\| UPPER(TRIM(source))) |
| load_datetime | current_group, current_class_group | load_datetime | GREATEST(group.load_datetime, class.load_datetime) |
| load_end_datetime | - | - | NULL (default for current records) |
| hashdiff | Calculated | Multiple | See Hash Diff Calculation below |
| class_type_bk | current_group, current_class_group | group_id, class_bk | RTRIM(group_id) \|\| LTRIM(class_bk) |
| group_id | current_group | group_id | Direct mapping |
| class_bk | current_class_group | class_bk | Direct mapping |
| class_description | current_class_group | class_description | Direct mapping |
| class_type_description | r_class_type_assignment | description | COALESCE(description, '') with max(effective_to) logic |
| dual_eligible | current_class_group | class_bk | CASE WHEN SUBSTRING(class_bk,1,1)='M' THEN 'Yes' ELSE 'No' END |
| on_exchange | current_group, current_class_group | group_id, class_bk | Complex CASE logic (see Business Rules) |
| effective_from_date | r_class_type_assignment | effective_from | COALESCE(effective_from, '2002-01-01') |
| effective_to_date | r_class_type_assignment | effective_to | COALESCE(effective_to, '2199-12-31') |
| source | current_group | source | Direct mapping |
| source_description | r_source_system | source_description | Direct mapping |

#### Hash Diff Calculation

```sql
SHA1_BINARY(
    COALESCE(TRIM(class_type_description), 'null') || '||' ||
    COALESCE(TRIM(class_bk), 'null') || '||' ||
    COALESCE(TRIM(class_description), 'null') || '||' ||
    COALESCE(TRIM(dual_eligible), 'null') || '||' ||
    COALESCE(TRIM(on_exchange), 'null') || '||' ||
    COALESCE(TRIM(source_description), 'null') || '||' ||
    COALESCE(TO_CHAR(effective_from_date, 'YYYY-MM-DD'), 'null') || '||' ||
    COALESCE(TO_CHAR(effective_to_date, 'YYYY-MM-DD'), 'null')
)
```

---

## Dimensional Model Mapping

### dim_class_type

| Target Column | Source Model | Source Column(s) | Transformation |
|---------------|--------------|------------------|----------------|
| class_type_key | Calculated | - | dbt_utils.generate_surrogate_key([class_type_bk, source, version_number]) |
| class_type_id | bv_s_class_type_business | class_type_bk | Direct mapping |
| class_type_description | bv_s_class_type_business | class_type_description | Direct mapping |
| class_id | bv_s_class_type_business | class_bk | Direct mapping |
| class_description | bv_s_class_type_business | class_description | Direct mapping |
| dual_eligible | bv_s_class_type_business | dual_eligible | Direct mapping |
| on_exchange | bv_s_class_type_business | on_exchange | Direct mapping |
| source_id | bv_s_class_type_business | source | Direct mapping |
| source_description | bv_s_class_type_business | source_description | Direct mapping |
| type1_hash | bv_s_class_type_business | hashdiff | Direct mapping |
| create_date | bv_s_class_type_business | load_datetime | Direct mapping (first version) |
| update_date | bv_s_class_type_business | load_datetime | Direct mapping (current version) |
| dss_start_date | bv_s_class_type_business | load_datetime | load_datetime::DATE |
| dss_end_date | Calculated | - | LEAD window function or '2999-12-31' |
| dss_current_flag | Calculated | - | 'Y' if no next version, else 'N' |
| dss_version | Calculated | - | ROW_NUMBER() over partition by class_type_bk, source |
| dss_create_time | - | - | CURRENT_TIMESTAMP() |
| dss_update_time | - | - | CURRENT_TIMESTAMP() |

---

## Legacy Staging Table Mapping

### ClassType_NonDV_01 → Business Vault Components

| EDW2 Column | Target Model | Target Column | Notes |
|-------------|--------------|---------------|-------|
| SourceID | bv_s_class_type_business | source | Direct mapping |
| SourceDescription | bv_s_class_type_business | source_description | Via r_source_system join |
| grgr_id | bv_s_class_type_business | group_id | Direct mapping |
| cscs_id | bv_s_class_type_business | class_bk | Direct mapping |
| cscs_desc | bv_s_class_type_business | class_description | Direct mapping |

### ClassType_NonDV_02 → Business Vault Components

| EDW2 Column | Target Model | Target Column | Notes |
|-------------|--------------|---------------|-------|
| GroupIDClassID | bv_s_class_type_business | class_type_bk | RTRIM(grgr_id) + LTRIM(cscs_id) |
| DualEligible | bv_s_class_type_business | dual_eligible | Business rule applied |
| OnExchange | bv_s_class_type_business | on_exchange | Business rule applied |
| description | bv_s_class_type_business | class_type_description | From reference lookup |
| effectivefromdate | bv_s_class_type_business | effective_from_date | With default '2002-01-01' |
| effectivetodate | bv_s_class_type_business | effective_to_date | With default '2199-12-31' |
| SourceID | bv_s_class_type_business | source | Direct mapping |
| SourceDescription | bv_s_class_type_business | source_description | Direct mapping |
| cscs_id | bv_s_class_type_business | class_bk | Direct mapping |
| cscs_desc | bv_s_class_type_business | class_description | Direct mapping |
| dss_create_time | bv_s_class_type_business | load_datetime | Renamed |
| dss_update_time | - | - | Not used in satellite |

### dimClassType_NonDV → Business Vault Components

| EDW2 Column | Target Model | Target Column | Notes |
|-------------|--------------|---------------|-------|
| ClassTypeID | dim_class_type | class_type_id | Via business vault |
| ClassTypeDescription | dim_class_type | class_type_description | Via business vault |
| ClassID | dim_class_type | class_id | Via business vault |
| ClassDescription | dim_class_type | class_description | Via business vault |
| DualEligible | dim_class_type | dual_eligible | Via business vault |
| OnExchange | dim_class_type | on_exchange | Via business vault |
| NKHash | bv_h_class_type | class_type_hk | Renamed, different calculation |
| Type1Hash | dim_class_type | type1_hash | Via business vault hashdiff |
| CreateDate | dim_class_type | create_date | Via business vault |
| UpdateDate | dim_class_type | update_date | Via business vault |
| SourceID | dim_class_type | source_id | Via business vault |
| SourceDescription | dim_class_type | source_description | Via business vault |

### dimClassType_Base → dim_class_type

| EDW2 Column | EDW3 Column | Notes |
|-------------|-------------|-------|
| ClassTypePK | class_type_key | Different key generation method |
| ClassTypeID | class_type_id | Direct mapping concept |
| ClassTypeDescription | class_type_description | Direct mapping |
| ClassID | class_id | Direct mapping |
| ClassDescription | class_description | Direct mapping |
| DualEligible | dual_eligible | Direct mapping |
| OnExchange | on_exchange | Direct mapping |
| NKHash | - | Not in EDW3 dimension (in hub instead) |
| Type1Hash | type1_hash | Direct mapping |
| CreateDate | create_date | Direct mapping |
| UpdateDate | update_date | Direct mapping |
| SourceID | source_id | Direct mapping |
| SourceDescription | source_description | Direct mapping |
| dss_current_flag | dss_current_flag | Direct mapping |
| dss_version | dss_version | Direct mapping |
| dss_start_date | dss_start_date | Direct mapping |
| dss_end_date | dss_end_date | Direct mapping |
| dss_update_time | dss_update_time | Direct mapping |
| dss_create_time | dss_create_time | Direct mapping |

---

## Hash Key Comparison

### EDW2 NKHash (Natural Key Hash)

**EDW2 Logic**:
```sql
HASHBYTES('sha1',
    RTRIM(COALESCE(CAST(GroupIDClassID AS VARCHAR(MAX)), 'null')) + '||' +
    RTRIM(COALESCE(CAST(SourceID AS VARCHAR(MAX)), 'null'))
)
```

**EDW3 Equivalent (class_type_hk)**:
```sql
SHA1_BINARY(
    CONCAT(
        COALESCE(UPPER(TRIM(class_type_bk)), 'null'), '||',
        COALESCE(UPPER(TRIM(source)), 'null')
    )
)
```

**Differences**:
- Function: HASHBYTES vs SHA1_BINARY
- Case handling: EDW3 adds UPPER() for consistency
- Input values should produce same hash if normalized properly

### EDW2 Type1Hash

**EDW2 Logic**:
```sql
HASHBYTES('sha1',
    LTRIM(RTRIM(COALESCE(CAST(description AS VARCHAR(MAX)), 'null'))) + '||' +
    LTRIM(RTRIM(COALESCE(CAST(cscs_id AS VARCHAR(MAX)), 'null'))) + '||' +
    LTRIM(RTRIM(COALESCE(CAST(cscs_desc AS VARCHAR(MAX)), 'null'))) + '||' +
    LTRIM(RTRIM(COALESCE(CAST(DualEligible AS VARCHAR(MAX)), 'null'))) + '||' +
    LTRIM(RTRIM(COALESCE(CAST(OnExchange AS VARCHAR(MAX)), 'null'))) + '||' +
    LTRIM(RTRIM(COALESCE(CAST(SourceDescription AS VARCHAR(MAX)), 'null')))
)
```

**EDW3 Equivalent (hashdiff)**:
```sql
SHA1_BINARY(
    CONCAT(
        COALESCE(TRIM(class_type_description), 'null'), '||',
        COALESCE(TRIM(class_bk), 'null'), '||',
        COALESCE(TRIM(class_description), 'null'), '||',
        COALESCE(TRIM(dual_eligible), 'null'), '||',
        COALESCE(TRIM(on_exchange), 'null'), '||',
        COALESCE(TRIM(source_description), 'null'), '||',
        COALESCE(TO_CHAR(effective_from_date, 'YYYY-MM-DD'), 'null'), '||',
        COALESCE(TO_CHAR(effective_to_date, 'YYYY-MM-DD'), 'null')
    )
)
```

**Differences**:
- Function: HASHBYTES vs SHA1_BINARY
- EDW3 includes effective dates (not in EDW2 Type1Hash)
- Otherwise same attribute list

---

## Data Type Mapping

| EDW2 Data Type | EDW3 Data Type | Notes |
|----------------|----------------|-------|
| VARCHAR(50) | VARCHAR(50) | Direct mapping |
| VARCHAR(128) | VARCHAR(200) | Increased size for safety |
| VARCHAR(MAX) | VARCHAR(500) | Reasonable size limit |
| BINARY(20) | BINARY(20) | Direct mapping (SHA1 output) |
| DATETIME | TIMESTAMP_NTZ | Snowflake standard |
| DATE | DATE | Direct mapping |
| CHAR(1) | CHAR(1) | Direct mapping |
| INTEGER | NUMBER(38,0) | Snowflake default for integers |

---

## Reconciliation Queries

### Row Count Comparison

**EDW2**:
```sql
-- Total records in dimension
SELECT COUNT(*) FROM dimClassType_Base

-- Current records only
SELECT COUNT(*) FROM dimClassType_Base WHERE dss_current_flag = 'Y'
```

**EDW3**:
```sql
-- Total records in dimension
SELECT COUNT(*) FROM dim_class_type

-- Current records only
SELECT COUNT(*) FROM dim_class_type WHERE dss_current_flag = 'Y'
```

### Business Key Comparison

**EDW2 to EDW3 Cross-Check**:
```sql
-- Find class types in EDW2 but not EDW3
SELECT edw2.ClassTypeID, edw2.SourceID
FROM [EDW2].[dbo].[dimClassType_Base] edw2
WHERE edw2.dss_current_flag = 'Y'
  AND NOT EXISTS (
      SELECT 1 FROM dim_class_type edw3
      WHERE edw3.class_type_id = edw2.ClassTypeID
        AND edw3.source_id = edw2.SourceID
        AND edw3.dss_current_flag = 'Y'
  )

-- Find class types in EDW3 but not EDW2
SELECT edw3.class_type_id, edw3.source_id
FROM dim_class_type edw3
WHERE edw3.dss_current_flag = 'Y'
  AND NOT EXISTS (
      SELECT 1 FROM [EDW2].[dbo].[dimClassType_Base] edw2
      WHERE edw2.ClassTypeID = edw3.class_type_id
        AND edw2.SourceID = edw3.source_id
        AND edw2.dss_current_flag = 'Y'
  )
```

### Attribute Comparison

**Compare Business Rule Results**:
```sql
SELECT
    edw2.ClassTypeID,
    edw2.SourceID,
    edw2.DualEligible AS edw2_dual_eligible,
    edw3.dual_eligible AS edw3_dual_eligible,
    edw2.OnExchange AS edw2_on_exchange,
    edw3.on_exchange AS edw3_on_exchange
FROM [EDW2].[dbo].[dimClassType_Base] edw2
INNER JOIN dim_class_type edw3
    ON edw2.ClassTypeID = edw3.class_type_id
    AND edw2.SourceID = edw3.source_id
    AND edw2.dss_current_flag = edw3.dss_current_flag
WHERE edw2.dss_current_flag = 'Y'
  AND (edw2.DualEligible != edw3.dual_eligible
       OR edw2.OnExchange != edw3.on_exchange)
```

---

## Validation Checklist

- [ ] Row counts match between EDW2 and EDW3
- [ ] All EDW2 business keys present in EDW3
- [ ] No unexpected business keys in EDW3
- [ ] Business rule calculations produce same results (DualEligible, OnExchange)
- [ ] Hash keys are consistent (after normalization)
- [ ] Type 2 SCD version counts match
- [ ] Effective date ranges align
- [ ] Unknown records present in both systems
- [ ] Source system distributions match
- [ ] Description lookups return same values

---

**Document Version**: 1.0
**Last Updated**: 2025-10-12
