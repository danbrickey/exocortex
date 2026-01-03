{{
    config(
        materialized='view',
        tags=['prep', 'member_person', 'business_rules']
    )
}}

{#
    Prep model for member_person

    Purpose: Apply business rules and joins from legacy v_FacetsMemberUMI_current view

    Business Rules:
    1. Join member demographics with external person ID
    2. Use standardized source codes from current_person table
    3. Include subscriber and group relationships
    4. Filter out proxy subscribers (SBSB_ID NOT LIKE 'PROXY%')
    5. Only include records where external ID type = 'EXRM'

    Source Tables:
    - raw_vault.current_member (member demographics)
    - raw_vault.current_person (external person IDs)
    - raw_vault.current_subscriber (subscriber data)
    - raw_vault.current_group (group data)
#}

with current_member as (
    select
        member_bk,
        person_bk,
        subscriber_bk,
        member_suffix,
        member_first_name,
        member_last_name,
        member_sex,
        member_birth_dt,
        member_ssn,
        source as member_source,
        edp_record_source,
        edp_start_dt
    from {{ ref('current_member') }}
),

current_person as (
    select
        person_bk,
        person_id,
        source,
        person_id_type
    from {{ ref('current_person') }}
    where person_id_type = 'EXRM'  -- Only external reference member IDs
    and person_id is not null  -- Filter out null person IDs
),

current_subscriber as (
    select
        subscriber_bk,
        group_bk,
        subscriber_identifier,
        source as subscriber_source
    from {{ ref('current_subscriber') }}
    where subscriber_identifier not like 'PROXY%'  -- Filter out proxy subscribers
),

current_group as (
    select
        group_bk,
        group_id,
        source as group_source
    from {{ ref('current_group') }}
),

member_person_prep as (
    select
        -- External Person Identifier
        p.person_id,

        -- Member Keys
        m.member_bk,
        m.person_bk,
        s.group_bk,
        m.subscriber_bk,

        -- Member Demographics
        m.member_suffix,
        m.member_first_name,
        m.member_last_name,
        m.member_sex,
        m.member_birth_dt,
        m.member_ssn,

        -- Related Entity IDs
        g.group_id,
        s.subscriber_identifier,

        -- Source from person record (uses standardized source codes)
        p.source,

        -- Original source from member record
        m.member_source,

        -- Data Vault Metadata
        m.edp_record_source,
        m.edp_start_dt as load_date,
        m.edp_start_dt as start_date

    from current_member m

    -- INNER JOIN to person for external constituent ID
    -- (some members may not have external IDs)
    inner join current_person p
        on m.person_bk = p.person_bk
        and m.member_source = p.source
        and p.person_id is not null

    -- INNER JOIN to subscriber (must have valid subscriber)
    inner join current_subscriber s
        on m.subscriber_bk = s.subscriber_bk
        and m.member_source = s.subscriber_source

    -- INNER JOIN to group (must have valid group)
    inner join current_group g
        on g.group_bk = s.group_bk
        and m.member_source = g.group_source
)

select * from member_person_prep
