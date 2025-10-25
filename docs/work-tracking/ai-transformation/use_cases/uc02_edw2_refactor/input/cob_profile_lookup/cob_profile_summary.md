# COB Profile Lookup - Analysis Summary

## Purpose

The COB (Coordination of Benefits) Profile Lookup creates a temporally accurate lookup table that tracks:
- Which insurance coverage is primary, secondary, or tertiary for each member
- Coverage type (Medical, Dental, Drug/Pharmacy)
- Whether Blue Cross Idaho is the primary, secondary, or tertiary payer
- "Two Blues" scenarios (when member has multiple Blues plans)
- Special Medicare Part D handling

## Business Problem

When a member has multiple insurance coverages, the system needs to determine:
1. **Which insurer pays first** (Primary), second (Secondary), or third (Tertiary)
2. **Coverage periods** - COB status changes over time as member gains/loses coverage
3. **Blue Cross Idaho's position** in the payer order for billing and claims adjudication
4. **Two Blues detection** - Special handling when member has multiple Blues products

## Key Business Rules

### 1. **Discrete Date Range Construction**
- Creates non-overlapping time periods based on ALL eligibility and COB effective/term dates
- Uses a sophisticated date-spine approach:
  - Collects all `FromDates`: eligibility eff dates, COB eff dates, day after term dates
  - Collects all `ThruDates`: eligibility term dates, COB term dates, day before eff dates
  - Cross-joins to create all possible date intervals
  - Selects shortest valid interval for each member (de-duplication via `ROW_NUMBER`)

### 2. **Coverage Type Determination**
Based on `CSPD_CAT` (Coverage/Service Product Category) and `MEPE_ELIG_IND`:
- **Medical ('M')**: Medical/hospital coverage
- **Dental ('D')**: Dental coverage
- **Drug/Pharmacy ('M' or 'R')**: Pharmacy benefit (often tied to medical)

### 3. **COB Order Logic** (Priority Waterfall)

The logic applies updates in sequence:

#### Step 1: **Default to Primary** (if member has coverage)
- Medical and Drug default to 'Primary' if medical eligibility exists
- Dental defaults to 'Primary' if dental eligibility exists

#### Step 2: **Primary COB Detection**
- Looks for COB records with insurance order NOT 'U' (Unknown) or 'P' (Primary elsewhere)
- Excludes dental-only COB (`MECB_INSUR_TYPE <> 'D'`) from medical
- Excludes Medicare Part D special codes (drug-only)
- Sets `MedicalCOBOrder = 'Primary'` and `DrugCOBOrder = 'Primary'`
- Detects "Two Blues" via MCRE_ID matching against hardcoded list

#### Step 3: **Secondary COB Override**
- Looks for COB with `MECB_INSUR_ORDER = 'P'` (BCI is secondary, other insurer is primary)
- Overrides prior 'Primary' determination → sets to 'Secondary'
- Updates Two Blues flags

#### Step 4: **Tertiary COB Override**
- Looks for COB with `MECB_INSUR_ORDER = 'S'` (BCI is tertiary)
- Only applies if current order is already 'Secondary'
- Sets to 'Tertiary'

### 4. **Special Rules**

#### Medicare Part D Handling
- **Primary List**: Certain MCRE_IDs mean "no other drug coverage" → BCI is primary
  - Codes: `COBLTRSNT`, `COBLTRSND`, `MEDPARTD`, `NO COB`, `COBINV`
- **Secondary List**: Certain MCRE_IDs mean BCI is always secondary for drugs
  - Codes: `0948`, `BCI2`, `0958`, `BCI3`, `COBLTRSNT`, `COBLTRSND`, `FEP2`, `Host2`, `MA2`, `MEDPARTD`, `NO COB`, `COBINV`

#### Two Blues Detection
- Large hardcoded list of MCRE_IDs representing Blue Cross/Blue Shield plans
- Examples: `0908`, `0948`, `0958`, `1782`, `0142`, `MA1`, `MA2`, `MA3`, `BCI1`, `BCI2`, `BCI3`, `FEP1`, `FEP2`, `FEP3`, etc.
- Sets flags: `Medical2Blues`, `Dental2Blues`, `Drug2Blues`

#### Drug Coverage Exclusion
- Identifies members with Medical ('M') or Pharmacy ('R') eligibility
- Members without these categories → `DrugCoverage = 'No'`

### 5. **Data Cleanup**
- Removes date ranges with NO coverage (no medical, dental, or drug)
- Excludes invalid future dates (`9999-12-31`, `2200-01-01`)

## Output Structure

One row per member per discrete date range with:
- **Member Identifiers**: SourceID, MEME_CK, GRGR_ID, SBSB_ID, MEME_SFX
- **Date Range**: StartDate, EndDate
- **Medical COB**: Coverage (Yes/No), HasCOB, COBOrder (Primary/Secondary/Tertiary), IsBCIPrimary/Secondary/Tertiary, 2Blues flag, MCRE_ID
- **Dental COB**: (same structure)
- **Drug COB**: (same structure)

## Raw Vault Sources

| EDW2 Table | Purpose |
|------------|---------|
| `v_membereligibilityextended_combined_current` | Medical and Dental eligibility periods (MEPE_EFF_DT, MEPE_TERM_DT) |
| `v_membercobextended_combined_current` | COB insurance information (MECB_EFF_DT, MECB_TERM_DT, MCRE_ID, MECB_INSUR_ORDER) |
| `v_member_combined_current` | Member demographics and keys |
| `v_subscriber_combined_current` | Subscriber relationship |
| `v_group_combined_current` | Group relationship |

## Complexity Considerations

1. **Temporal Accuracy**: The date-spine logic ensures no gaps or overlaps in coverage periods
2. **Sequential Updates**: COB order determined through cascading UPDATE statements (Primary → Secondary → Tertiary)
3. **Hard-Coded Business Rules**: Medicare Part D lists and Two Blues MCRE_IDs are embedded in code
4. **Performance**: Multiple self-joins and PATINDEX operations on large eligibility tables

## EDW3 Refactoring Recommendations

1. **Externalize Reference Data**: Move MCRE_ID lists to seed/reference tables
2. **CTE-Based Logic**: Replace UPDATE cascade with window functions and CASE expressions
3. **Date Spine Optimization**: Use Snowflake date generation functions
4. **Incremental Processing**: Track changed members rather than full refresh

## Next Steps

1. Complete the column mappings in [cob_profile_mappings.csv](cob_profile_mappings.csv)
2. Extract reference data (Two Blues list, Medicare Part D lists) to seed files
3. Recommend business vault structure (likely a computed effectivity satellite)
4. Generate dbt model with modern SQL patterns
