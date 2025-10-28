{{
    config(
        materialized='table',
        tags=['crosswalk', 'cob', 'member', 'lookup']
    )
}}

/*
    Crosswalk Table: Member COB Profile

    Purpose: Provides a lookup table for member Coordination of Benefits (COB)
    profiles across discrete date ranges. Used by claims processing and reporting
    to determine who pays first/second/third for member claims.

    Business Use:
    - Lookup member's coverage status (Medical, Dental, Drug) for any date
    - Determine COB order (Primary, Secondary, Tertiary) for billing/claims adjudication
    - Identify "Two Blues" scenarios requiring special BCBS network processing
    - Support COB-related reporting and data quality monitoring

    Source: bv_s_member_cob_profile (Business Vault)
    Legacy Equivalent: HDSVault.biz.r_COBProfileLookup
    Grain: One row per member per discrete date range

    Lookup Pattern:
    - Input: member_bk + service_date
    - Output: COB status and order for that member on that date
*/

with

-- Import CTE
bv_member_cob_profile as (
    select * from {{ ref('bv_s_member_cob_profile') }}
),

-- Logical CTE - calculate derived flags for easier lookup
final as (
    select
        -- Natural business keys (lookup keys)
        source as source_id,
        member_bk,
        start_date,
        end_date,
        group_id,
        subscriber_id,
        member_suffix,
        group_bk,
        subscriber_bk,
        member_first_name,

        -- Coverage identifiers
        coverage_id_medical,
        coverage_id_dental,

        -- Medical coverage
        medical_coverage,
        has_medical_cob,
        medical_cob_order,
        case when medical_cob_order = 'Primary' then 'Yes' else 'No' end as medical_is_bci_primary,
        case when medical_cob_order = 'Secondary' then 'Yes' else 'No' end as medical_is_bci_secondary,
        case when medical_cob_order = 'Tertiary' then 'Yes' else 'No' end as medical_is_bci_tertiary,
        medical_2blues,

        -- Dental coverage
        dental_coverage,
        has_dental_cob,
        dental_cob_order,
        case when dental_cob_order = 'Primary' then 'Yes' else 'No' end as dental_is_bci_primary,
        case when dental_cob_order = 'Secondary' then 'Yes' else 'No' end as dental_is_bci_secondary,
        case when dental_cob_order = 'Tertiary' then 'Yes' else 'No' end as dental_is_bci_tertiary,
        dental_2blues,

        -- Drug coverage
        drug_coverage,
        has_drug_cob,
        drug_cob_order,
        case when drug_cob_order = 'Primary' then 'Yes' else 'No' end as drug_is_bci_primary,
        case when drug_cob_order = 'Secondary' then 'Yes' else 'No' end as drug_is_bci_secondary,
        case when drug_cob_order = 'Tertiary' then 'Yes' else 'No' end as drug_is_bci_tertiary,
        drug_2blues,

        -- Audit columns
        edp_record_source,
        create_date as dss_load_date,
        create_date as dss_create_time,
        create_date as dss_update_time

    from bv_member_cob_profile
)

select * from final
