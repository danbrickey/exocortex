-- current_group_plan_eligibility.sql
-- Current view showing active group plan eligibility relationships from all sources

with

link as (
    select * from {{ ref('l_group_product_category_class_plan') }}
),

sat_legacy as (
    select
        group_product_category_class_plan_hk,
        load_datetime,
        load_end_datetime,
        source,

        -- payload columns
        product_id,
        plan_selectable_ind,
        plan_family_ind,
        rate_guarantee_dt,
        rate_guarantee_period_months,
        rate_guarantee_ind,
        age_vol_reduction_tbl_pfx,
        warning_message_seq_no,
        open_enroll_begin_mmdd,
        open_enroll_end_mmdd,
        group_admin_rules_id,
        its_prefix,
        premium_age_calc_method,
        member_id_card_stock,
        member_id_card_type,
        hedis_cont_enroll_break,
        hedis_cont_enroll_days,
        plan_year_begin_mmdd,
        network_set_pfx,
        plan_co_month,
        covering_provider_set_pfx,
        hra_admin_info_id,
        postponement_ind,
        debit_card_bank_rel_pfx,
        dental_util_edits_pfx,
        value_based_benefits_id,
        billing_strategy_id,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_dbuser_id,
        secondary_plan_cd,
        auth_cert_entity_id,
        its_account_exception,
        renewal_begin_mmdd,
        hios_id,
        its_pfx_account_id,
        patient_care_program_set_pfx,

        -- effectivity columns
        effective_from,
        start_date,
        end_date

    from {{ ref('s_group_plan_eligibility_legacy_facets') }}
    where load_end_datetime is null
),

sat_gemstone as (
    select
        group_product_category_class_plan_hk,
        load_datetime,
        load_end_datetime,
        source,

        -- payload columns
        product_id,
        plan_selectable_ind,
        plan_family_ind,
        rate_guarantee_dt,
        rate_guarantee_period_months,
        rate_guarantee_ind,
        age_vol_reduction_tbl_pfx,
        warning_message_seq_no,
        open_enroll_begin_mmdd,
        open_enroll_end_mmdd,
        group_admin_rules_id,
        its_prefix,
        premium_age_calc_method,
        member_id_card_stock,
        member_id_card_type,
        hedis_cont_enroll_break,
        hedis_cont_enroll_days,
        plan_year_begin_mmdd,
        network_set_pfx,
        plan_co_month,
        covering_provider_set_pfx,
        hra_admin_info_id,
        postponement_ind,
        debit_card_bank_rel_pfx,
        dental_util_edits_pfx,
        value_based_benefits_id,
        billing_strategy_id,
        lock_token,
        attachment_source_id,
        last_update_dtm,
        last_update_user_id,
        last_update_dbuser_id,
        secondary_plan_cd,
        auth_cert_entity_id,
        its_account_exception,
        renewal_begin_mmdd,
        hios_id,
        its_pfx_account_id,
        patient_care_program_set_pfx,

        -- effectivity columns
        effective_from,
        start_date,
        end_date

    from {{ ref('s_group_plan_eligibility_gemstone_facets') }}
    where load_end_datetime is null
),

final as (
    select
        l.group_product_category_class_plan_hk,
        l.group_hk,
        l.product_category_hk,
        l.class_hk,
        l.plan_hk,
        l.load_datetime as link_load_datetime,
        l.source as link_source,

        -- legacy facets satellite columns
        sl.load_datetime as legacy_sat_load_datetime,
        sl.source as legacy_source,
        sl.product_id as legacy_product_id,
        sl.plan_selectable_ind as legacy_plan_selectable_ind,
        sl.plan_family_ind as legacy_plan_family_ind,
        sl.rate_guarantee_dt as legacy_rate_guarantee_dt,
        sl.rate_guarantee_period_months as legacy_rate_guarantee_period_months,
        sl.rate_guarantee_ind as legacy_rate_guarantee_ind,
        sl.age_vol_reduction_tbl_pfx as legacy_age_vol_reduction_tbl_pfx,
        sl.warning_message_seq_no as legacy_warning_message_seq_no,
        sl.open_enroll_begin_mmdd as legacy_open_enroll_begin_mmdd,
        sl.open_enroll_end_mmdd as legacy_open_enroll_end_mmdd,
        sl.group_admin_rules_id as legacy_group_admin_rules_id,
        sl.its_prefix as legacy_its_prefix,
        sl.premium_age_calc_method as legacy_premium_age_calc_method,
        sl.member_id_card_stock as legacy_member_id_card_stock,
        sl.member_id_card_type as legacy_member_id_card_type,
        sl.hedis_cont_enroll_break as legacy_hedis_cont_enroll_break,
        sl.hedis_cont_enroll_days as legacy_hedis_cont_enroll_days,
        sl.plan_year_begin_mmdd as legacy_plan_year_begin_mmdd,
        sl.network_set_pfx as legacy_network_set_pfx,
        sl.plan_co_month as legacy_plan_co_month,
        sl.covering_provider_set_pfx as legacy_covering_provider_set_pfx,
        sl.hra_admin_info_id as legacy_hra_admin_info_id,
        sl.postponement_ind as legacy_postponement_ind,
        sl.debit_card_bank_rel_pfx as legacy_debit_card_bank_rel_pfx,
        sl.dental_util_edits_pfx as legacy_dental_util_edits_pfx,
        sl.value_based_benefits_id as legacy_value_based_benefits_id,
        sl.billing_strategy_id as legacy_billing_strategy_id,
        sl.lock_token as legacy_lock_token,
        sl.attachment_source_id as legacy_attachment_source_id,
        sl.last_update_dtm as legacy_last_update_dtm,
        sl.last_update_user_id as legacy_last_update_user_id,
        sl.last_update_dbuser_id as legacy_last_update_dbuser_id,
        sl.secondary_plan_cd as legacy_secondary_plan_cd,
        sl.auth_cert_entity_id as legacy_auth_cert_entity_id,
        sl.its_account_exception as legacy_its_account_exception,
        sl.renewal_begin_mmdd as legacy_renewal_begin_mmdd,
        sl.hios_id as legacy_hios_id,
        sl.its_pfx_account_id as legacy_its_pfx_account_id,
        sl.patient_care_program_set_pfx as legacy_patient_care_program_set_pfx,
        sl.effective_from as legacy_effective_from,
        sl.start_date as legacy_start_date,
        sl.end_date as legacy_end_date,

        -- gemstone facets satellite columns
        sg.load_datetime as gemstone_sat_load_datetime,
        sg.source as gemstone_source,
        sg.product_id as gemstone_product_id,
        sg.plan_selectable_ind as gemstone_plan_selectable_ind,
        sg.plan_family_ind as gemstone_plan_family_ind,
        sg.rate_guarantee_dt as gemstone_rate_guarantee_dt,
        sg.rate_guarantee_period_months as gemstone_rate_guarantee_period_months,
        sg.rate_guarantee_ind as gemstone_rate_guarantee_ind,
        sg.age_vol_reduction_tbl_pfx as gemstone_age_vol_reduction_tbl_pfx,
        sg.warning_message_seq_no as gemstone_warning_message_seq_no,
        sg.open_enroll_begin_mmdd as gemstone_open_enroll_begin_mmdd,
        sg.open_enroll_end_mmdd as gemstone_open_enroll_end_mmdd,
        sg.group_admin_rules_id as gemstone_group_admin_rules_id,
        sg.its_prefix as gemstone_its_prefix,
        sg.premium_age_calc_method as gemstone_premium_age_calc_method,
        sg.member_id_card_stock as gemstone_member_id_card_stock,
        sg.member_id_card_type as gemstone_member_id_card_type,
        sg.hedis_cont_enroll_break as gemstone_hedis_cont_enroll_break,
        sg.hedis_cont_enroll_days as gemstone_hedis_cont_enroll_days,
        sg.plan_year_begin_mmdd as gemstone_plan_year_begin_mmdd,
        sg.network_set_pfx as gemstone_network_set_pfx,
        sg.plan_co_month as gemstone_plan_co_month,
        sg.covering_provider_set_pfx as gemstone_covering_provider_set_pfx,
        sg.hra_admin_info_id as gemstone_hra_admin_info_id,
        sg.postponement_ind as gemstone_postponement_ind,
        sg.debit_card_bank_rel_pfx as gemstone_debit_card_bank_rel_pfx,
        sg.dental_util_edits_pfx as gemstone_dental_util_edits_pfx,
        sg.value_based_benefits_id as gemstone_value_based_benefits_id,
        sg.billing_strategy_id as gemstone_billing_strategy_id,
        sg.lock_token as gemstone_lock_token,
        sg.attachment_source_id as gemstone_attachment_source_id,
        sg.last_update_dtm as gemstone_last_update_dtm,
        sg.last_update_user_id as gemstone_last_update_user_id,
        sg.last_update_dbuser_id as gemstone_last_update_dbuser_id,
        sg.secondary_plan_cd as gemstone_secondary_plan_cd,
        sg.auth_cert_entity_id as gemstone_auth_cert_entity_id,
        sg.its_account_exception as gemstone_its_account_exception,
        sg.renewal_begin_mmdd as gemstone_renewal_begin_mmdd,
        sg.hios_id as gemstone_hios_id,
        sg.its_pfx_account_id as gemstone_its_pfx_account_id,
        sg.patient_care_program_set_pfx as gemstone_patient_care_program_set_pfx,
        sg.effective_from as gemstone_effective_from,
        sg.start_date as gemstone_start_date,
        sg.end_date as gemstone_end_date

    from link l
    left join sat_legacy sl
        on l.group_product_category_class_plan_hk = sl.group_product_category_class_plan_hk
        and l.source = sl.source
    left join sat_gemstone sg
        on l.group_product_category_class_plan_hk = sg.group_product_category_class_plan_hk
        and l.source = sg.source
)

select * from final
