{{
    config(
        materialized='view',
        tags=['current_view', 'benefit_summary_text']
    )
}}

-- Current view for benefit_summary_text entity
-- Unions across all source systems and shows the most recent record per business key

with link_base as (
    select
        benefit_summary_text_lk,
        product_prefix_hk,
        benefit_summary_type_hk,
        benefit_summary_text_sequence_hk,
        load_datetime,
        source
    from {{ ref('l_benefit_summary_text_product_prefix') }}
),

hub_sequence as (
    select
        benefit_summary_text_sequence_hk,
        benefit_summary_text_seq_no,
        load_datetime as hub_load_datetime
    from {{ ref('h_benefit_summary_text_sequence') }}
),

sat_legacy as (
    select
        benefit_summary_text_lk,
        load_datetime as sat_load_datetime,
        hashdiff,
        product_prefix,
        benefit_summary_type,
        benefit_summary_text_seq_no,
        benefit_summary_text,
        lock_token,
        attachment_source_id,
        source,
        row_number() over (
            partition by benefit_summary_text_lk
            order by load_datetime desc
        ) as row_num
    from {{ ref('s_benefit_summary_text_legacy_facets') }}
),

sat_gemstone as (
    select
        benefit_summary_text_lk,
        load_datetime as sat_load_datetime,
        hashdiff,
        product_prefix,
        benefit_summary_type,
        benefit_summary_text_seq_no,
        benefit_summary_text,
        lock_token,
        attachment_source_id,
        source,
        row_number() over (
            partition by benefit_summary_text_lk
            order by load_datetime desc
        ) as row_num
    from {{ ref('s_benefit_summary_text_gemstone_facets') }}
),

-- Union the latest records from each source
sat_union as (
    select * from sat_legacy where row_num = 1
    union all
    select * from sat_gemstone where row_num = 1
),

-- Get the overall latest record per business key across all sources
sat_latest as (
    select
        benefit_summary_text_lk,
        sat_load_datetime,
        hashdiff,
        product_prefix,
        benefit_summary_type,
        benefit_summary_text_seq_no,
        benefit_summary_text,
        lock_token,
        attachment_source_id,
        source,
        row_number() over (
            partition by benefit_summary_text_lk
            order by sat_load_datetime desc
        ) as final_row_num
    from sat_union
),

final as (
    select
        -- link keys
        l.benefit_summary_text_lk,
        l.product_prefix_hk,
        l.benefit_summary_type_hk,
        l.benefit_summary_text_sequence_hk,

        -- hub attributes
        h.benefit_summary_text_seq_no as hub_benefit_summary_text_seq_no,

        -- satellite attributes
        s.product_prefix,
        s.benefit_summary_type,
        s.benefit_summary_text_seq_no,
        s.benefit_summary_text,
        s.lock_token,
        s.attachment_source_id,

        -- metadata
        s.hashdiff,
        l.load_datetime as link_load_datetime,
        h.hub_load_datetime,
        s.sat_load_datetime,
        s.source,
        'BCI' as tenant_id

    from link_base l
    inner join hub_sequence h
        on l.benefit_summary_text_sequence_hk = h.benefit_summary_text_sequence_hk
    left join sat_latest s
        on l.benefit_summary_text_lk = s.benefit_summary_text_lk
        and s.final_row_num = 1
)

select * from final
