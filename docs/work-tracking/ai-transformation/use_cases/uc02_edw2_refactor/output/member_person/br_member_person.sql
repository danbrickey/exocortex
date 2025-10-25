{{
    config(
        materialized='incremental',
        unique_key='member_person_bridge_key',
        on_schema_change='fail',
        tags=['business_vault', 'bridge', 'member', 'person']
    )
}}

/*
Business Vault Bridge: Member to Person Crosswalk
Purpose: General-purpose mapping of member business keys to person (constituent) IDs
         No filtering applied - suitable for reuse across multiple use cases
         Use case-specific views apply filtering criteria (e.g., person_id_type)
Legacy Source: HDSVault.biz.v_FacetsMemberUMI_current (partial)
*/

with

-- import CTEs
current_member as (
    select
        member_bk,
        person_bk,
        source,
        edp_record_source,
        edp_start_dt,
        cdc_timestamp
    from {{ ref('current_member') }}
    {% if is_incremental() %}
    where edp_start_dt > (select max(edp_start_dt) from {{ this }})
    {% endif %}
),

current_person as (
    select
        person_bk,
        person_id,
        person_id_type,
        source
    from {{ ref('current_person') }}
),

-- logical CTEs
member_person_join as (
    select
        m.member_bk,
        p.person_bk,
        p.person_id,
        p.person_id_type,
        m.source,
        m.edp_record_source,
        m.edp_start_dt,
        m.cdc_timestamp
    from current_member m
    left join current_person p
        on m.person_bk = p.person_bk
        and m.source = p.source
),

apply_source_translation as (
    select
        member_bk,
        person_bk,
        person_id,
        person_id_type,
        case
            when source = '1' then 'gemstone_facets'
            else 'legacy_facets'
        end as source_code,
        edp_record_source,
        edp_start_dt,
        cdc_timestamp
    from member_person_join
),

final as (
    select
        {{ dbt_utils.generate_surrogate_key(['member_bk', 'source_code', 'edp_start_dt']) }} as member_person_bridge_key,
        member_bk,
        person_bk,
        person_id,
        person_id_type,
        source_code,
        edp_record_source,
        edp_start_dt,
        current_timestamp() as edp_load_dt,
        cdc_timestamp
    from apply_source_translation
)

select * from final
