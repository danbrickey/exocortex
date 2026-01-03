# Gemstone Legacy Data Dictionary - Domain-Specific Files

## Overview
The legacy data dictionary has been split into domain-specific files for easier consumption and focused context during AI-assisted development. Each file maintains table-level integrity and includes the original CSV header.

## File Organization

### CMC (Claims Management Core) Files
| File | Lines | Description | Primary Use Cases |
|------|-------|-------------|-------------------|
| `legacy_data_dictionary_cmc_claims.csv` | 4,921 | Claims processing, billing, resolution | Claims Data Vault modeling, claims fact tables |
| `legacy_data_dictionary_cmc_business_process.csv` | 2,358 | Business process rules, printing/reporting | Business rules extraction, report migration |
| `legacy_data_dictionary_cmc_members.csv` | 1,618 | Member management, coordination | Member hub/satellite design, eligibility logic |
| `legacy_data_dictionary_cmc_utilization.csv` | 1,270 | Utilization management, service authorization | UM business rules, service fact modeling |
| `legacy_data_dictionary_cmc_system.csv` | 1,221 | Interface tables, system operations | Data integration patterns, system interfaces |
| `legacy_data_dictionary_cmc_providers.csv` | 1,159 | Provider data, network management | Provider hub design, network relationships |
| `legacy_data_dictionary_cmc_financial.csv` | 1,357 | Accounting, financial processing | Financial fact tables, payment processing |
| `legacy_data_dictionary_cmc_misc.csv` | 18,661 | All other CMC tables | Data integration, miscellaneous entities |

### Non-CMC System Files
| File | Lines | Description | Primary Use Cases |
|------|-------|-------------|-------------------|
| `legacy_data_dictionary_pub.csv` | 5,802 | Publication and reporting systems | Report migration, data mart design |
| `legacy_data_dictionary_cds.csv` | 2,599 | Clinical Data Services | Clinical data modeling, quality measures |
| `legacy_data_dictionary_network.csv` | 1,631 | Network management (NWX) | Provider network modeling, contracts |
| `legacy_data_dictionary_enrollment.csv` | 1,439 | Member enrollment (CER) | Enrollment processing, member lifecycle |
| `legacy_data_dictionary_other.csv` | 33,237 | All remaining systems | Supporting systems, reference data |

## Usage Guidelines

### For Data Vault Modeling
1. **Start with Claims**: Use `cmc_claims.csv` for core claims entities
2. **Add Members**: Reference `cmc_members.csv` for member hub design
3. **Include Providers**: Use `cmc_providers.csv` for provider relationships
4. **Business Logic**: Reference `cmc_business_process.csv` for rules extraction

### For Domain-Specific Work
- **Claims Processing**: `cmc_claims.csv` + `cmc_utilization.csv`
- **Member Management**: `cmc_members.csv` + `enrollment.csv`
- **Provider Operations**: `cmc_providers.csv` + `network.csv`
- **Financial Processing**: `cmc_financial.csv` + `cmc_business_process.csv`

### File Size Considerations
- **Focused Work**: Use individual domain files (1K-5K lines)
- **Cross-Domain**: Combine 2-3 related files as needed
- **Comprehensive**: Reference multiple files but load selectively
- **Context Management**: Each file leaves room for other context documents

## Column Structure
All files maintain the original CSV structure:
- `source_schema` - Database schema (typically 'dbo')
- `source_table` - Table name with domain prefix
- `source_column` - Column name
- `table_description` - Business description of table purpose
- `column_description` - Business description of column usage
- `column_data_type` - SQL Server data type

## Integration with EDP Architecture
These files support the WhereScape to dbt migration by providing:
- **Business Context**: Understanding original table purposes
- **Relationship Mapping**: Identifying foreign key patterns
- **Business Key Strategy**: Finding stable identifiers across systems
- **Domain Boundaries**: Natural groupings for Data Vault design

## Reference Files
- **Platform Architecture**: `../edp_platform_architecture.md` - Target naming conventions
- **Main Dictionary**: `../legacy_data_dictionary.csv` - Original complete file
- **CLAUDE Context**: Various `CLAUDE.md` files reference these domain files