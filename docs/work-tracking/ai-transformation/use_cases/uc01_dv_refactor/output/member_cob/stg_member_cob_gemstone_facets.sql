-- stg_member_cob_gemstone_facets.sql
-- Stage 2: Generate hash keys for Data Vault 2.0 structures
-- Source: gemstone_facets.dbo.cmc_mecb_cob
-- Entity: member_cob (Member COB Profile)

WITH renamed_source AS (
    SELECT * FROM {{ ref('stg_member_cob_gemstone_facets_rename') }}
),

hashed AS (
    SELECT
        -- Hash Keys
        {{ dbt_utils.generate_surrogate_key(['member_bk']) }} AS member_hk,
        {{ dbt_utils.generate_surrogate_key([
            'insurance_type_cd',
            'insurance_order_cd',
            'supp_drug_type_cd'
        ]) }} AS cob_indicator_hk,
        {{ dbt_utils.generate_surrogate_key([
            'member_bk',
            'insurance_type_cd',
            'insurance_order_cd',
            'supp_drug_type_cd'
        ]) }} AS member_cob_hk,

        -- Business Keys
        member_bk,
        insurance_type_cd,
        insurance_order_cd,
        supp_drug_type_cd,

        -- Descriptive Attributes
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

        -- System Columns
        last_update_dtm,
        last_update_user_id,
        last_update_db_user_id,

        -- Source System Metadata
        source_system,
        load_dtm

    FROM renamed_source
)

SELECT * FROM hashed;
