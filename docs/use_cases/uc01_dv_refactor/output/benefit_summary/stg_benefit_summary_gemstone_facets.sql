{{
    config(
        materialized='view',
        tags=['staging', 'gemstone_facets']
    )
}}

with source as (

    select * from {{ ref('stg_benefit_summary_gemstone_facets_rename') }}

),

hashed as (

    {{
        automate_dv.stage(
            include_source_columns=true,
            source_model='source',
            hashed_columns={
                'benefit_summary_type_hk': 'benefit_summary_type_bk',
                'product_prefix_hk': 'product_prefix_bk',
                'benefit_summary_product_prefix_lk': ['benefit_summary_type_bk', 'product_prefix_bk'],
                'benefit_summary_hashdiff': {
                    'is_hashdiff': true,
                    'columns': [
                        'benefit_summary_desc',
                        'lock_token',
                        'attachment_source_id',
                        'last_update_dtm',
                        'last_update_user_id',
                        'last_update_db_user_id'
                    ]
                }
            },
            ranked_columns={
                'benefit_summary_rank': {
                    'partition_by': ['benefit_summary_type_bk', 'product_prefix_bk'],
                    'order_by': 'load_datetime'
                }
            }
        )
    }}

)

select * from hashed
