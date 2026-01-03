with

h_member as (

    select * from {{ ref('h_member') }}

),

h_medicare_event as (

    select * from {{ ref('h_medicare_event') }}

),

l_member_medicare_event as (

    select * from {{ ref('l_member_medicare_event') }}

),

s_member_medicare_event_legacy_facets as (

    select * from {{ ref('s_member_medicare_event_legacy_facets') }}

),

s_member_medicare_event_gemstone_facets as (

    select * from {{ ref('s_member_medicare_event_gemstone_facets') }}

),

-- get the latest satellite record per link key per source
current_legacy_facets as (

    select
        s.*
    from s_member_medicare_event_legacy_facets s
    qualify row_number() over (
        partition by s.member_medicare_event_lk
        order by s.load_datetime desc
    ) = 1

),

current_gemstone_facets as (

    select
        s.*
    from s_member_medicare_event_gemstone_facets s
    qualify row_number() over (
        partition by s.member_medicare_event_lk
        order by s.load_datetime desc
    ) = 1

),

-- union all sources
unioned_satellites as (

    select
        member_medicare_event_lk,
        load_datetime,
        source,
        hashdiff,
        hcfa_eff_dt,
        hcfa_term_dt,
        group_ck,
        input_dt,
        event_eff_dt,
        event_term_dt,
        medicare_state,
        medicare_county,
        health_ins_claim_number,
        benefit_group_ck,
        pipdcg_category,
        risk_adj_part_a_factor,
        risk_adj_part_b_factor,
        risk_adj_part_d_factor,
        risk_adj_factor_type,
        election_type,
        medicare_plan_benefit_pkg,
        segment_id,
        premium_withhold_option,
        part_c_premium,
        part_d_premium,
        prior_commercial_override,
        enrollment_source,
        uncovered_months,
        part_d_id,
        medicare_rx_group_id,
        medicare_rxbin,
        medicare_rxpcn,
        secondary_drug_ins_flag,
        secondary_drug_ins_id,
        secondary_drug_ins_group,
        secondary_drug_ins_bin,
        secondary_drug_ins_pcn,
        part_d_subsidy,
        copay_category,
        low_income_premium_subsidy,
        late_enrollment_penalty,
        late_enrollment_penalty_waived,
        late_enrollment_penalty_subsidy,
        aged_disabled_msp_status,
        risk_adj_part_d_fctr_type,
        lock_token,
        attachment_source_id,
        ic_model_flag,
        ic_model_benefit_status_cd,
        ic_model_end_date_reason,
        preferred_language,
        accessible_format,
        medicare_sep_reason,
        medicare_enrollee_relation,
        national_producer_number,
        signature_dt,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from current_legacy_facets

    union all

    select
        member_medicare_event_lk,
        load_datetime,
        source,
        hashdiff,
        hcfa_eff_dt,
        hcfa_term_dt,
        group_ck,
        input_dt,
        event_eff_dt,
        event_term_dt,
        medicare_state,
        medicare_county,
        health_ins_claim_number,
        benefit_group_ck,
        pipdcg_category,
        risk_adj_part_a_factor,
        risk_adj_part_b_factor,
        risk_adj_part_d_factor,
        risk_adj_factor_type,
        election_type,
        medicare_plan_benefit_pkg,
        segment_id,
        premium_withhold_option,
        part_c_premium,
        part_d_premium,
        prior_commercial_override,
        enrollment_source,
        uncovered_months,
        part_d_id,
        medicare_rx_group_id,
        medicare_rxbin,
        medicare_rxpcn,
        secondary_drug_ins_flag,
        secondary_drug_ins_id,
        secondary_drug_ins_group,
        secondary_drug_ins_bin,
        secondary_drug_ins_pcn,
        part_d_subsidy,
        copay_category,
        low_income_premium_subsidy,
        late_enrollment_penalty,
        late_enrollment_penalty_waived,
        late_enrollment_penalty_subsidy,
        aged_disabled_msp_status,
        risk_adj_part_d_fctr_type,
        lock_token,
        attachment_source_id,
        ic_model_flag,
        ic_model_benefit_status_cd,
        ic_model_end_date_reason,
        preferred_language,
        accessible_format,
        medicare_sep_reason,
        medicare_enrollee_relation,
        national_producer_number,
        signature_dt,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from current_gemstone_facets

),

-- get the most recent record per link key across all sources
current_satellite as (

    select
        s.*
    from unioned_satellites s
    qualify row_number() over (
        partition by s.member_medicare_event_lk
        order by s.load_datetime desc
    ) = 1

),

final as (

    select
        -- link key
        l.member_medicare_event_lk,

        -- hub keys
        l.member_hk,
        l.medicare_event_hk,

        -- business keys from hubs
        hm.member_bk,
        hme.medicare_event_bk,

        -- satellite attributes
        s.hcfa_eff_dt,
        s.hcfa_term_dt,
        s.group_ck,
        s.input_dt,
        s.event_eff_dt,
        s.event_term_dt,
        s.medicare_state,
        s.medicare_county,
        s.health_ins_claim_number,
        s.benefit_group_ck,
        s.pipdcg_category,
        s.risk_adj_part_a_factor,
        s.risk_adj_part_b_factor,
        s.risk_adj_part_d_factor,
        s.risk_adj_factor_type,
        s.election_type,
        s.medicare_plan_benefit_pkg,
        s.segment_id,
        s.premium_withhold_option,
        s.part_c_premium,
        s.part_d_premium,
        s.prior_commercial_override,
        s.enrollment_source,
        s.uncovered_months,
        s.part_d_id,
        s.medicare_rx_group_id,
        s.medicare_rxbin,
        s.medicare_rxpcn,
        s.secondary_drug_ins_flag,
        s.secondary_drug_ins_id,
        s.secondary_drug_ins_group,
        s.secondary_drug_ins_bin,
        s.secondary_drug_ins_pcn,
        s.part_d_subsidy,
        s.copay_category,
        s.low_income_premium_subsidy,
        s.late_enrollment_penalty,
        s.late_enrollment_penalty_waived,
        s.late_enrollment_penalty_subsidy,
        s.aged_disabled_msp_status,
        s.risk_adj_part_d_fctr_type,
        s.lock_token,
        s.attachment_source_id,
        s.ic_model_flag,
        s.ic_model_benefit_status_cd,
        s.ic_model_end_date_reason,
        s.preferred_language,
        s.accessible_format,
        s.medicare_sep_reason,
        s.medicare_enrollee_relation,
        s.national_producer_number,
        s.signature_dt,
        s.edp_start_dt,
        s.edp_end_dt,
        s.edp_record_status,
        s.edp_record_source,

        -- metadata
        s.load_datetime,
        s.source

    from l_member_medicare_event l
    inner join h_member hm
        on l.member_hk = hm.member_hk
    inner join h_medicare_event hme
        on l.medicare_event_hk = hme.medicare_event_hk
    left join current_satellite s
        on l.member_medicare_event_lk = s.member_medicare_event_lk
    where s.edp_record_status = 'ACTIVE'

)

select * from final
