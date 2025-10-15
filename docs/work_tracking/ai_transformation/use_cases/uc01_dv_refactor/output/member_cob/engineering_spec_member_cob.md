Data Vault Engineering Spec – Member COB
🧱 Artifact Summary
Entity Type: Link + Effectivity Satellites
Hub Name: h_cob_indicator
Link Name: l_member_cob
Satellite(s):

- s_member_cob_legacy_facets
- s_member_cob_gemstone_facets
  Current View: cv_member_cob
  Backward Compatible View: bwd_member_cob
  Staging Model(s):
- stg_member_cob_legacy_facets
- stg_member_cob_gemstone_facets
  Source System(s): legacy_facets, gemstone_facets

🔄 Rename Views
select
'{{ var('*_source_system') }}' as source,
'1' as tenant_id,
meme_ck as member_bk,
mecb_insur_type as insurance_type_cd,
mecb_insur_order as insurance_order_cd,
mecb_mctr_styp as supp_drug_type_cd,
mecb_eff_dt as effective_dt,
mecb_term_dt as termination_dt,
mecb_mctr_trsn as termination_reason_cd,
grgr_ck as group_bk,
mcre_id as carrier_id,
mecb_policy_id as policy_id,
mecb_mctr_msp as medicare_secondary_payer_type_cd,
mecb_mctr_ptyp as rx_coverage_type_cd,
mecb_rxbin as rx_bin_nbr,
mecb_rxpcn as rx_pcn_nbr,
mecb_rx_group as rx_group_nbr,
mecb_rx_id as rx_id,
mecb_last_ver_dt as last_verification_dt,
mecb_last_ver_name as last_verification_nm,
mecb_mctr_vmth as verification_method_cd,
mecb_loi_start_dt as loi_start_dt,
mecb_prim_last_nm as primary_holder_last_nm,
mecb_prim_first_nm as primary_holder_first_nm,
mecb_prim_id as primary_holder_id,
mecb_lock_token as lock_token_nbr,
atxr_source_id as attachment_source_id,
sys_last_upd_dtm as last_update_dtm,
sys_usus_id as last_update_user_id,
sys_dbuser_id as last_update_db_user_id,
edp_start_dt,
edp_end_dt,
edp_record_status,
edp_record_source

🧱 Staging Models
derived_columns:
source: "source"
load_datetime: "edp_start_dt"
effective_from: "effective_dt"
effective_to: "case
when lead(effective_dt) over (partition by member_bk, insurance_type_cd, insurance_order_cd, supp_drug_type_cd
order by effective_dt) < termination_dt
then dateadd(day,-1,lead(effective_dt) over (partition by member_bk, insurance_type_cd, insurance_order_cd, supp_drug_type_cd
order by effective_dt))
when termination_dt::date = '1753-01-01' then '2199-12-31'
else termination_dt end"

hashed_columns:
member_cob_hk: - "source" - "member_bk" - "insurance_type_cd" - "insurance_order_cd" - "supp_drug_type_cd"
member_hk: - "source" - "member_bk"
cob_indicator_hk: - "source" - "insurance_type_cd" - "insurance_order_cd" - "supp_drug_type_cd"
member_cob_hashdiff:
is_hashdiff: true
columns: - "tenant_id" - "carrier_id" - "policy_id" - "medicare_secondary_payer_type_cd" - "rx_coverage_type_cd" - "rx_bin_nbr" - "rx_pcn_nbr" - "rx_group_nbr" - "rx_id" - "last_verification_dt" - "last_verification_nm" - "verification_method_cd" - "loi_start_dt" - "primary_holder_last_nm" - "primary_holder_first_nm" - "primary_holder_id"

🏛️ Hub
h_cob_indicator.sql

source_model: stg_member_cob_legacy_facets
src_pk: cob_indicator_hk
src_nk:

- insurance_type_cd
- insurance_order_cd
- supp_drug_type_cd
  src_ldts: load_datetime
  src_source: source

🔗 Link
l_member_cob.sql

source_model: stg_member_cob_legacy_facets
src_pk: member_cob_hk
src_fk:

- member_hk
- cob_indicator_hk
  src_ldts: load_datetime
  src_source: source

🛰️ Effectivity Satellites
source_model: stg_member_cob_legacy_facets
src_pk: member_cob_hk
src_hashdiff: member_cob_hashdiff
src_payload:

- tenant_id
- carrier_id
- policy_id
- medicare_secondary_payer_type_cd
- rx_coverage_type_cd
- rx_bin_nbr
- rx_pcn_nbr
- rx_group_nbr
- rx_id
- last_verification_dt
- last_verification_nm
- verification_method_cd
- loi_start_dt
- primary_holder_last_nm
- primary_holder_first_nm
- primary_holder_id
  src_eff: effective_from
  src_ldts: load_datetime
  src_source: source

📄 Current View
base_model: l_member_cob
satellite_models:

- s_member_cob_legacy_facets
- s_member_cob_gemstone_facets
  enable_current_flag: true

📄 Backward Compatible View
with current_records as (
select
cv.\*,
{{dbt_utils.generate_surrogate_key(['1', 'cv.source', 'cv.member_bk', 'cv.insurance_type_cd',
                                          'cv.insurance_order_cd', 'cv.supp_drug_type_cd', 'cv.effective_from'])}}
as member_cob_ik
from {{ ref('cv_member_cob') }} cv
)

select
member_cob_ik,
tenant_id,
source as source_system,
{{dbt_utils.generate_surrogate_key(['1', 'source', 'member_bk'])}} as member_ik,
member_bk,
insurance_type_cd as cob_insurance_type,
insurance_order_cd as cob_insurance_order,
supp_drug_type_cd as cob_supp_drug_type,
effective_from as member_cob_eff_dt,
effective_to as member_cob_term_dt,
termination_reason_cd as member_cob_term_reason,
carrier_id as cob_carrier_id,
policy_id as cob_policy_id,
load_datetime as edp_start_dt,
'2199-12-31' as edp_end_dt,
'A' as edp_record_status,
lower(source) as edp_record_source,
current_timestamp() as create_dtm,
current_timestamp() as update_dtm
from current_records

⏱️ Recommended Tests

- Unique combination of business keys (member_bk, insurance_type_cd, insurance_order_cd, supp_drug_type_cd)
- Not null member_bk
- Not null insurance_type_cd
- Not null insurance_order_cd
- Not null effective_from
- Effective dates are valid (effective_from ≤ effective_to)
- No gaps in effective dates for same business key combination
- No overlapping effective date ranges for same business key combination
- Valid references to h_member
- Valid references to h_cob_indicator
- Referential integrity between link and satellites
