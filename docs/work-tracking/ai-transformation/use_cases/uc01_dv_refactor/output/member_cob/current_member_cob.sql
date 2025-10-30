-- current_member_cob.sql
-- Current View: Member COB Profile
-- Description: Provides the current state of member COB relationships by combining data from both source systems
-- Business Logic: Applies effectivity logic using effective_dt and termination_dt to determine active records

{{ config(
    materialized='view',
    tags=['current_view', 'member_cob']
) }}

WITH link_data AS (
    SELECT
        l.member_cob_hk,
        l.member_hk,
        l.cob_indicator_hk,
        l.src_source_system AS link_source_system,
        l.src_load_dtm AS link_load_dtm
    FROM {{ ref('l_member_cob') }} l
),

gemstone_sat AS (
    SELECT
        src_pk AS member_cob_hk,
        src_eff AS effective_dt,
        src_start_date,
        src_end_date,
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
        src_source_system,
        src_load_dtm,
        ROW_NUMBER() OVER (
            PARTITION BY src_pk
            ORDER BY src_eff DESC
        ) AS row_num
    FROM {{ ref('s_member_cob_gemstone_facets') }}
    WHERE CURRENT_DATE BETWEEN COALESCE(src_start_date, '1900-01-01')
                           AND COALESCE(src_end_date, '9999-12-31')
),

legacy_sat AS (
    SELECT
        src_pk AS member_cob_hk,
        src_eff AS effective_dt,
        src_start_date,
        src_end_date,
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
        src_source_system,
        src_load_dtm,
        ROW_NUMBER() OVER (
            PARTITION BY src_pk
            ORDER BY src_eff DESC
        ) AS row_num
    FROM {{ ref('s_member_cob_legacy_facets') }}
    WHERE CURRENT_DATE BETWEEN COALESCE(src_start_date, '1900-01-01')
                           AND COALESCE(src_end_date, '9999-12-31')
),

combined_sat AS (
    SELECT * FROM gemstone_sat WHERE row_num = 1
    UNION ALL
    SELECT * FROM legacy_sat WHERE row_num = 1
),

prioritized_sat AS (
    SELECT
        *,
        ROW_NUMBER() OVER (
            PARTITION BY member_cob_hk
            ORDER BY
                CASE src_source_system
                    WHEN 'gemstone_facets' THEN 1
                    WHEN 'legacy_facets' THEN 2
                    ELSE 3
                END,
                src_load_dtm DESC
        ) AS priority_row_num
    FROM combined_sat
),

hub_member AS (
    SELECT
        member_hk,
        member_bk
    FROM {{ ref('h_member') }}
),

hub_cob_indicator AS (
    SELECT
        cob_indicator_hk,
        insurance_type_cd,
        insurance_order_cd,
        supp_drug_type_cd
    FROM {{ ref('h_cob_indicator') }}
),

final AS (
    SELECT
        -- Link Identifiers
        l.member_cob_hk,
        l.member_hk,
        l.cob_indicator_hk,

        -- Member Business Key
        hm.member_bk,

        -- COB Indicator Business Keys
        hc.insurance_type_cd,
        hc.insurance_order_cd,
        hc.supp_drug_type_cd,

        -- Effectivity Attributes
        s.effective_dt,
        s.termination_dt,

        -- Descriptive Attributes
        s.termination_reason_cd,
        s.group_bk,
        s.carrier_id,
        s.policy_id,
        s.medicare_secondary_payer_type_cd,
        s.rx_coverage_type_cd,
        s.rx_bin_nbr,
        s.rx_pcn_nbr,
        s.rx_group_nbr,
        s.rx_id,
        s.last_verification_dt,
        s.last_verification_nm,
        s.verification_method_cd,
        s.loi_start_dt,
        s.primary_holder_last_nm,
        s.primary_holder_first_nm,
        s.primary_holder_id,
        s.lock_token_nbr,
        s.attachment_source_id,

        -- System Columns
        s.last_update_dtm,
        s.last_update_user_id,
        s.last_update_db_user_id,

        -- Source System Metadata
        s.src_source_system,
        l.link_source_system,
        s.src_load_dtm,
        l.link_load_dtm

    FROM link_data l
    INNER JOIN hub_member hm
        ON l.member_hk = hm.member_hk
    INNER JOIN hub_cob_indicator hc
        ON l.cob_indicator_hk = hc.cob_indicator_hk
    LEFT JOIN prioritized_sat s
        ON l.member_cob_hk = s.member_cob_hk
        AND s.priority_row_num = 1
)

SELECT * FROM final;
