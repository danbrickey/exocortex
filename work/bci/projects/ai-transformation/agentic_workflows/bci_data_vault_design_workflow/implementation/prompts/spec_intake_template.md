# Spec Intake Template

Copy this template, fill in the fields, then paste into Amazon Q with the @spec-generator prompt.

---

## Entity Request

**Entity Name**: 
**Entity Type**: [hub / link / satellite / hub+satellites / SAL]

## Business Keys

| Key Column | Description |
|------------|-------------|
|  |  |
|  |  |

## Source Models

| Source Model | System | Notes |
|--------------|--------|-------|
|  | gemstone / legacy |  |
|  | gemstone / legacy |  |

## Staging Join Logic

```sql
-- How do sources join together? (optional - leave blank if simple)

```

## Design Decision

**Hub(s)**: 
**Satellite(s)**: 
**Link(s) / SAL(s)**: 

## Column Mappings (Key Payload Columns)

| Source Column | Target Column | Notes |
|---------------|---------------|-------|
|  |  |  |
|  |  |  |
|  |  |  |

## Additional Notes

<!-- Any special logic, identity resolution, or business rules -->


---

## Quick Fill Example

**Entity Name**: claim_line
**Entity Type**: hub+satellites

| Key Column | Description |
|------------|-------------|
| claim_id | Claim header identifier |
| claim_line_number | Line number within claim |

| Source Model | System | Notes |
|--------------|--------|-------|
| stg_gemstone_facets_hist__dbo_cmc_cdml_claim_line | gemstone | Primary |
| stg_legacy_bcifacets_hist__dbo_cmc_cdml_claim_line | legacy | Legacy system |

**Hub(s)**: h_claim_line
**Satellite(s)**: s_claim_line_gemstone_facets, s_claim_line_legacy_facets
**Link(s) / SAL(s)**: sal_claim_line_facets (identity resolution)

