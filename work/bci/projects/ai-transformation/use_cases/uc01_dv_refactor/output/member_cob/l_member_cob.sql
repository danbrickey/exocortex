-- l_member_cob.sql
-- Link: Member COB
-- Description: Links members to their COB indicator configurations
-- Parent Hubs: h_member, h_cob_indicator

{{ config(
    materialized='incremental',
    unique_key='member_cob_hk',
    tags=['link', 'member_cob']
) }}

WITH source_gemstone AS (
    SELECT
        member_cob_hk,
        member_hk,
        cob_indicator_hk,
        source_system,
        load_dtm
    FROM {{ ref('stg_member_cob_gemstone_facets') }}
    {% if is_incremental() %}
    WHERE load_dtm > (SELECT MAX(load_dtm) FROM {{ this }})
    {% endif %}
),

source_legacy AS (
    SELECT
        member_cob_hk,
        member_hk,
        cob_indicator_hk,
        source_system,
        load_dtm
    FROM {{ ref('stg_member_cob_legacy_facets') }}
    {% if is_incremental() %}
    WHERE load_dtm > (SELECT MAX(load_dtm) FROM {{ this }})
    {% endif %}
),

all_sources AS (
    SELECT * FROM source_gemstone
    UNION ALL
    SELECT * FROM source_legacy
),

deduplicated AS (
    SELECT
        member_cob_hk,
        member_hk,
        cob_indicator_hk,
        source_system,
        load_dtm,
        ROW_NUMBER() OVER (
            PARTITION BY member_cob_hk
            ORDER BY load_dtm ASC
        ) AS row_num
    FROM all_sources
    {% if is_incremental() %}
    WHERE member_cob_hk NOT IN (SELECT DISTINCT member_cob_hk FROM {{ this }})
    {% endif %}
)

SELECT
    member_cob_hk,
    member_hk,
    cob_indicator_hk,
    source_system AS src_source_system,
    load_dtm AS src_load_dtm
FROM deduplicated
WHERE row_num = 1;
