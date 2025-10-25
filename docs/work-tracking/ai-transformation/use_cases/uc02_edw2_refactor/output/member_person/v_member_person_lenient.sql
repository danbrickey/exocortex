{{
    config(
        materialized='view',
        tags=['curation', 'member', 'person', 'crosswalk', 'lenient']
    )
}}

/*
Curation Layer View: Member Person Crosswalk - Lenient Matching
Purpose: Provides member-to-person constituent ID mapping for internal and business partner use
Matching Strategy: Lenient - includes EXRM person ID type for broader internal matching
Use Cases: Internal reporting, business partner data sharing, analytics
Legacy Source: HDSVault.biz.v_FacetsMemberUMI_current
Note: For external/member portal use cases requiring strict matching, use v_member_person_strict
*/

with

-- import CTEs
current_member as (
    select
        member_bk,
        subscriber_bk,
        group_bk,
        member_suffix,
        member_first_name,
        member_last_name,
        member_sex,
        member_birth_dt,
        member_ssn,
        source,
        edp_record_source,
        edp_start_dt,
        cdc_timestamp
    from {{ ref('current_member') }}
),

current_subscriber as (
    select
        subscriber_bk,
        subscriber_id,
        source
    from {{ ref('current_subscriber') }}
),

current_group as (
    select
        group_bk,
        group_id,
        source
    from {{ ref('current_group') }}
),

member_person_bridge as (
    select
        member_bk,
        person_id,
        person_id_type,
        source_code
    from {{ ref('br_member_person') }}
    where person_id_type = 'EXRM'  -- lenient matching: external member type only
),

-- logical CTEs
join_member_dimensions as (
    select
        m.member_bk,
        m.subscriber_bk,
        m.group_bk,
        s.subscriber_id,
        g.group_id,
        m.member_suffix,
        m.member_first_name,
        m.member_last_name,
        m.member_sex,
        m.member_birth_dt,
        m.member_ssn,
        m.source,
        m.edp_record_source,
        m.edp_start_dt,
        m.cdc_timestamp
    from current_member m
    inner join current_subscriber s
        on m.subscriber_bk = s.subscriber_bk
        and m.source = s.source
    inner join current_group g
        on m.group_bk = g.group_bk
        and m.source = g.source
),

apply_business_filters as (
    select
        member_bk,
        subscriber_bk,
        group_bk,
        subscriber_id,
        group_id,
        member_suffix,
        member_first_name,
        member_last_name,
        member_sex,
        member_birth_dt,
        member_ssn,
        source,
        edp_record_source,
        edp_start_dt,
        cdc_timestamp
    from join_member_dimensions
    where subscriber_id not like 'PROXY%'  -- exclude proxy subscribers
),

add_person_id as (
    select
        m.member_bk,
        m.group_id,
        m.subscriber_id,
        m.member_suffix,
        m.member_first_name,
        m.member_last_name,
        m.member_sex,
        m.member_birth_dt,
        m.member_ssn,
        p.person_id as constituent_id,
        m.source as source_code,
        m.edp_record_source,
        m.edp_start_dt,
        m.cdc_timestamp
    from apply_business_filters m
    left join member_person_bridge p
        on m.member_bk = p.member_bk
        and m.source = p.source_code
),

final as (
    select
        constituent_id,
        member_bk,
        group_id,
        subscriber_id,
        member_suffix,
        member_first_name as first_name,
        member_last_name as last_name,
        member_sex as gender,
        member_birth_dt as birth_date,
        member_ssn as ssn,
        source_code,
        edp_record_source as dss_record_source,
        edp_start_dt as dss_load_date,
        edp_start_dt as dss_start_date,
        cdc_timestamp as dss_create_time
    from add_person_id
)

select * from final
