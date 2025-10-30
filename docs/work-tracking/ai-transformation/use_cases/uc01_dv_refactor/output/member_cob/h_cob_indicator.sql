-- h_cob_indicator.sql
-- Hub: COB Indicator
-- Description: Represents unique COB indicator configurations (insurance type, order, and supplemental drug type)
-- Composite Business Key: insurance_type_cd, insurance_order_cd, supp_drug_type_cd

{{ config(
    materialized='incremental',
    unique_key='cob_indicator_hk',
    tags=['hub', 'member_cob']
) }}

WITH source_gemstone AS (
    SELECT
        cob_indicator_hk,
        insurance_type_cd,
        insurance_order_cd,
        supp_drug_type_cd,
        source_system,
        load_dtm
    FROM {{ ref('stg_member_cob_gemstone_facets') }}
    {% if is_incremental() %}
    WHERE load_dtm > (SELECT MAX(load_dtm) FROM {{ this }})
    {% endif %}
),

source_legacy AS (
    SELECT
        cob_indicator_hk,
        insurance_type_cd,
        insurance_order_cd,
        supp_drug_type_cd,
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
        cob_indicator_hk,
        insurance_type_cd,
        insurance_order_cd,
        supp_drug_type_cd,
        source_system,
        load_dtm,
        ROW_NUMBER() OVER (
            PARTITION BY cob_indicator_hk
            ORDER BY load_dtm ASC
        ) AS row_num
    FROM all_sources
    {% if is_incremental() %}
    WHERE cob_indicator_hk NOT IN (SELECT DISTINCT cob_indicator_hk FROM {{ this }})
    {% endif %}
)

SELECT
    cob_indicator_hk,
    insurance_type_cd,
    insurance_order_cd,
    supp_drug_type_cd,
    source_system AS src_source_system,
    load_dtm AS src_load_dtm
FROM deduplicated
WHERE row_num = 1;
