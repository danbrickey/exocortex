with legacy_facets as (
    select * from {{ ref('s_group_plan_eligibility_legacy_facets') }}
),

gemstone_facets as (
    select * from {{ ref('s_group_plan_eligibility_gemstone_facets') }}
),

unioned as (
    select * from legacy_facets
    union all
    select * from gemstone_facets
),

latest_records as (
    select *
    from unioned
    where termination_date > current_date()
)

select * from latest_records
