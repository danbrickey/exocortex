-- stg_member_cob_gemstone_facets_rename.sql
-- Stage 1: Rename columns from source system to standardized names
-- Source: gemstone_facets.dbo.cmc_mecb_cob
-- Entity: member_cob (Member COB Profile)

WITH source_data AS (
    SELECT
        -- Business Keys
        meme_ck AS member_bk,
        mecb_insur_type AS insurance_type_cd,
        mecb_insur_order AS insurance_order_cd,
        mecb_mctr_styp AS supp_drug_type_cd,

        -- Descriptive Attributes
        mecb_eff_dt AS effective_dt,
        mecb_term_dt AS termination_dt,
        mecb_mctr_trsn AS termination_reason_cd,
        grgr_ck AS group_bk,
        mcre_id AS carrier_id,
        mecb_policy_id AS policy_id,
        mecb_mctr_msp AS medicare_secondary_payer_type_cd,
        mecb_mctr_ptyp AS rx_coverage_type_cd,
        mecb_rxbin AS rx_bin_nbr,
        mecb_rxpcn AS rx_pcn_nbr,
        mecb_rx_group AS rx_group_nbr,
        mecb_rx_id AS rx_id,
        mecb_last_ver_dt AS last_verification_dt,
        mecb_last_ver_name AS last_verification_nm,
        mecb_mctr_vmth AS verification_method_cd,
        mecb_loi_start_dt AS loi_start_dt,
        mecb_prim_last_nm AS primary_holder_last_nm,
        mecb_prim_first_nm AS primary_holder_first_nm,
        mecb_prim_id AS primary_holder_id,
        mecb_lock_token AS lock_token_nbr,
        atxr_source_id AS attachment_source_id,

        -- System Columns
        sys_last_upd_dtm AS last_update_dtm,
        sys_usus_id AS last_update_user_id,
        sys_dbuser_id AS last_update_db_user_id,

        -- Source System Metadata
        'gemstone_facets' AS source_system,
        CURRENT_TIMESTAMP AS load_dtm

    FROM gemstone_facets.dbo.cmc_mecb_cob
)

SELECT * FROM source_data;
