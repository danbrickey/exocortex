-- s_member_cob_gemstone_facets.sql
-- Effectivity Satellite: Member COB (Gemstone Facets)
-- Description: Tracks effectivity periods and descriptive attributes for member COB relationships
-- Attached to: l_member_cob
-- Source: gemstone_facets.dbo.cmc_mecb_cob

{{ config(
    materialized='incremental',
    unique_key=['member_cob_hk', 'effective_dt'],
    tags=['satellite', 'effectivity', 'member_cob', 'gemstone_facets']
) }}

WITH source_data AS (
    SELECT
        member_cob_hk,
        effective_dt,
        termination_dt,
        termination_reason_cd,
        group_bk,
        carrier_id,
        policy_id,
        medicare_secondary_payer_type_cd,
        rx_coverage_type_cd,
        rx_bin_nbr,
        rx_pcn_nbr,
        rx_group_nbr,
        rx_id,
        last_verification_dt,
        last_verification_nm,
        verification_method_cd,
        loi_start_dt,
        primary_holder_last_nm,
        primary_holder_first_nm,
        primary_holder_id,
        lock_token_nbr,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,
        source_system,
        load_dtm
    FROM {{ ref('stg_member_cob_gemstone_facets') }}
    {% if is_incremental() %}
    WHERE load_dtm > (SELECT MAX(src_load_dtm) FROM {{ this }})
    {% endif %}
),

with_hash_diff AS (
    SELECT
        *,
        {{ dbt_utils.generate_surrogate_key([
            'termination_dt',
            'termination_reason_cd',
            'group_bk',
            'carrier_id',
            'policy_id',
            'medicare_secondary_payer_type_cd',
            'rx_coverage_type_cd',
            'rx_bin_nbr',
            'rx_pcn_nbr',
            'rx_group_nbr',
            'rx_id',
            'last_verification_dt',
            'last_verification_nm',
            'verification_method_cd',
            'loi_start_dt',
            'primary_holder_last_nm',
            'primary_holder_first_nm',
            'primary_holder_id',
            'lock_token_nbr',
            'attachment_source_id',
            'last_update_dtm',
            'last_update_user_id',
            'last_update_db_user_id'
        ]) }} AS hash_diff
    FROM source_data
),

{% if is_incremental() %}
filtered AS (
    SELECT
        s.*
    FROM with_hash_diff s
    LEFT JOIN {{ this }} t
        ON s.member_cob_hk = t.member_cob_hk
        AND s.effective_dt = t.src_eff
        AND s.hash_diff = t.hash_diff
    WHERE t.member_cob_hk IS NULL
),
{% else %}
filtered AS (
    SELECT * FROM with_hash_diff
),
{% endif %}

final AS (
    SELECT
        member_cob_hk AS src_pk,
        effective_dt AS src_eff,
        effective_dt AS src_start_date,
        termination_dt AS src_end_date,
        hash_diff,

        -- Descriptive Attributes
        termination_dt,
        termination_reason_cd,
        group_bk,
        carrier_id,
        policy_id,
        medicare_secondary_payer_type_cd,
        rx_coverage_type_cd,
        rx_bin_nbr,
        rx_pcn_nbr,
        rx_group_nbr,
        rx_id,
        last_verification_dt,
        last_verification_nm,
        verification_method_cd,
        loi_start_dt,
        primary_holder_last_nm,
        primary_holder_first_nm,
        primary_holder_id,
        lock_token_nbr,
        attachment_source_id,

        -- System Columns
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,

        -- Source System Metadata
        source_system AS src_source_system,
        load_dtm AS src_load_dtm
    FROM filtered
)

SELECT * FROM final;
