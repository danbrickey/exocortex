# Subscriber Warning Message - Data Vault 2.0 Refactor

This directory contains all the dbt models and documentation for refactoring the subscriber_warning_msg entity to Data Vault 2.0 structure.

## Source Information

- **Source Table**: `dbo.cmc_sbwm_sb_msg`
- **Source Systems**: legacy_facets, gemstone_facets
- **Data Dictionary**: [dbo_cmc_sbwm_sb_msg.csv](../../../sources/facets/dbo_cmc_sbwm_sb_msg.csv)

## Entity Overview

The subscriber_warning_msg entity captures subscriber-level warning messages with temporal tracking. This entity:
- Attaches to the existing `h_subscriber` hub
- Tracks warning messages over time with effective and termination dates
- Supports multiple warning messages per subscriber (differentiated by message_id and effective dates)
- Uses effectivity satellites to handle temporal aspects

## Files Created

### Staging Models

#### Rename Views
- [`stg_subscriber_warning_msg_gemstone_facets_rename.sql`](stg_subscriber_warning_msg_gemstone_facets_rename.sql) - Maps source columns to standard naming for gemstone_facets
- [`stg_subscriber_warning_msg_legacy_facets_rename.sql`](stg_subscriber_warning_msg_legacy_facets_rename.sql) - Maps source columns to standard naming for legacy_facets

#### Staging with Hashing
- [`stg_subscriber_warning_msg_gemstone_facets.sql`](stg_subscriber_warning_msg_gemstone_facets.sql) - Creates hash keys and hashdiffs for gemstone_facets
- [`stg_subscriber_warning_msg_legacy_facets.sql`](stg_subscriber_warning_msg_legacy_facets.sql) - Creates hash keys and hashdiffs for legacy_facets

### Satellites

#### Effectivity Satellites
- [`s_subscriber_warning_msg_gemstone_facets.sql`](s_subscriber_warning_msg_gemstone_facets.sql) - Effectivity satellite for gemstone_facets source
- [`s_subscriber_warning_msg_legacy_facets.sql`](s_subscriber_warning_msg_legacy_facets.sql) - Effectivity satellite for legacy_facets source

### Current Views
- [`current_subscriber_warning_msg.sql`](current_subscriber_warning_msg.sql) - Current view that unions both sources and filters to latest records

### Documentation
- [`engineering_spec_subscriber_warning_msg.md`](engineering_spec_subscriber_warning_msg.md) - Detailed engineering specification
- [`subscriber_warning_msg_user_story.md`](subscriber_warning_msg_user_story.md) - User story with acceptance criteria

## Column Mappings

| Source Column | Renamed Column | Description |
|--------------|----------------|-------------|
| sbsb_ck | subscriber_bk | Subscriber Business Key (hub key) |
| sbwm_eff_dt | warning_msg_eff_dt | Warning Message Effective Date |
| wmds_seq_no | message_id | Message ID |
| sbwm_term_dt | warning_msg_term_dt | Warning Message Termination Date |
| sbwm_mctr_trsn | termination_reason_cd | Termination Reason Code |
| grgr_ck | group_bk | Group Business Key |
| sbwm_lock_token | lock_token_nbr | Lock Token Number |
| atxr_source_id | attachment_source_id | Attachment Source ID |

## Key Design Decisions

1. **Hub Relationship**: Attaches directly to existing `h_subscriber` hub using `subscriber_hk`
2. **Satellite Type**: Effectivity satellites used to track temporal aspects
3. **Effectivity Dates**:
   - `src_eff`: warning_msg_eff_dt
   - `src_start_date`: warning_msg_eff_dt
   - `src_end_date`: warning_msg_term_dt
4. **No Link Required**: This entity doesn't create relationships between hubs
5. **Multi-Source**: Separate satellites for legacy_facets and gemstone_facets
6. **Current View**: Unions both sources and filters to latest version per subscriber_hk and warning_msg_eff_dt

## Next Steps

1. Copy SQL files to appropriate directories in the edp_data_domains repository:
   - Rename views → `models/integration/raw_vault/staging/subscriber_warning_msg/`
   - Staging models → `models/integration/raw_vault/staging/subscriber_warning_msg/`
   - Satellites → `models/integration/raw_vault/satellites/effectivity/`
   - Current view → `models/integration/current_views/`

2. Create schema.yml files with:
   - Model descriptions
   - Column documentation
   - Data lineage (refs)
   - dbt tests

3. Run dbt build and validate all models

4. Create pull request following the guidelines in the user story

## References

- [Engineering Specification](engineering_spec_subscriber_warning_msg.md)
- [User Story](subscriber_warning_msg_user_story.md)
- [Source Data Dictionary](../../../sources/facets/dbo_cmc_sbwm_sb_msg.csv)
