# Member COB Data Vault Refactoring - Complete Example
# Input Prompt Example

This document contains all artifacts related to the member_cob entity refactoring from 3NF to Data Vault 2.0 patterns.

---

## File: member_cob_dv_refactor_prompt.md
## docs\use_cases\uc01_dv_refactor\refactor_prompts\

Please follow the project guidelines and generate the refactored spec for the member_cob entity

### Expected Output Summary

- Data Dictionary source_table name:
  - cmc_mecb_cob

I expect that the Raw Vault artifacts will include:

- Rename Views (1 per source)
  - stg_member_cob_legacy_facets_rename.sql
  - stg_member_cob_gemstone_facets_rename.sql
- Staging Views (1 per source)
  - stg_member_cob_legacy_facets.sql
  - stg_member_cob_gemstone_facets.sql
- Hub
  - h_cob_indicator.sql
    - business Keys: cob_indicator_hk (composite key from source columns mecb_insur_type, mecb_insur_order, and mecb_mctr_styp)
- Link
  - l_member_cob.sql
    - business Keys: member_hk (from source column: meme_ck), cob_indicator_hk (composite key from source columns mecb_insur_type, mecb_insur_order, and mecb_mctr_styp)
- Effectivity Satellites (1 per source)
  - s_member_cob_legacy_facets.sql
  - s_member_cob_gemstone_facets.sql
- Current View
  - cv_member_cob.sql
- Backward Compatible View
  - bwd_member_cob.sql

### Data Dictionary

- Use this information to map source view references in the prior model code back to the source solumns, and rename columns in the rename views:

```csv
source_schema,source_table, source_column, table_description, column_description, column_data_type
dbo,cmc_mecb_cob,meme_ck,Member COB Information Data,Member Contrived Key,int
dbo,cmc_mecb_cob,mecb_insur_type,Member COB Information Data,Insurance Type,char
dbo,cmc_mecb_cob,mecb_insur_order,Member COB Information Data,Insurance Order,char
dbo,cmc_mecb_cob,mecb_mctr_styp,Member COB Information Data, Supplemental Drug Type,char
dbo,cmc_mecb_cob,mecb_eff_dt,Member COB Information Data,Coordination of Benefits Effective Date,datetime
dbo,cmc_mecb_cob,mecb_term_dt,Member COB Information Data,Termination Date,datetime
dbo,cmc_mecb_cob,mecb_mctr_trsn,Member COB Information Data,Termination Reason,char
dbo,cmc_mecb_cob,grgr_ck,Member COB Information Data,Group Contrived Key,int
dbo,cmc_mecb_cob,mcre_id,Member COB Information Data,Coordination of Benefits Carrier Identifier,char
dbo,cmc_mecb_cob,mecb_policy_id,Member COB Information Data,Policy Identifier,varchar
dbo,cmc_mecb_cob,mecb_mctr_msp,Member COB Information Data,Medicare Secondary Payer Type,char
dbo,cmc_mecb_cob,mecb_mctr_ptyp,Member COB Information Data,Prescription Drug Coverage Type,char
dbo,cmc_mecb_cob,mecb_rxbin,Member COB Information Data,Prescription Drug Bin Number,char
dbo,cmc_mecb_cob,mecb_rxpcn,Member COB Information Data,Prescription Drug PCN Number,varchar
dbo,cmc_mecb_cob,mecb_rx_group,Member COB Information Data,Prescription Drug Group Number,varchar
dbo,cmc_mecb_cob,mecb_rx_id,Member COB Information Data,Prescription Drug ID Number,varchar
dbo,cmc_mecb_cob,mecb_last_ver_dt,Member COB Information Data,Last Verification Date,datetime
dbo,cmc_mecb_cob,mecb_last_ver_name,Member COB Information Data,Last Verification Name,varchar
dbo,cmc_mecb_cob,mecb_mctr_vmth,Member COB Information Data,Last Verification Method,char
dbo,cmc_mecb_cob,mecb_loi_start_dt,Member COB Information Data,Claim LOI Start Date,datetime
dbo,cmc_mecb_cob,mecb_prim_last_nm,Member COB Information Data,Last Name of Primary COB holder,varchar
dbo,cmc_mecb_cob,mecb_prim_first_nm,Member COB Information Data,First Name of Primary COB holder,varchar
dbo,cmc_mecb_cob,mecb_prim_id,Member COB Information Data,ID of Primary COB holder,varchar
dbo,cmc_mecb_cob,mecb_lock_token,Member COB Information Data,Lock Token,smallint
dbo,cmc_mecb_cob,atxr_source_id,Member COB Information Data,Attachment Source Id,datetime
dbo,cmc_mecb_cob,sys_last_upd_dtm,Member COB Information Data,Last Update Datetime,datetime
dbo,cmc_mecb_cob,sys_usus_id,Member COB Information Data,Last Update User ID,varchar
dbo,cmc_mecb_cob,sys_dbuser_id,Member COB Information Data,Last Update DBMS User ID,varchar
```
---

# Output Example

## File: engineering_spec_member_cob.md
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

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

---

## File: stg_member_cob_gemstone_facets_rename.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_gemstone_facets_hist__dbo_cmc_mecb_cob') }}
),

renamed as (
    select
        '{{ var("gemstone_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        mecb_insur_type as cob_ins_type_bk,
        mecb_insur_order as cob_ins_order_bk,
        mecb_mctr_styp as cob_supp_drug_type_bk,
        mecb_eff_dt as cob_eff_dt,
        mecb_term_dt as cob_term_dt,
        mecb_mctr_trsn as cob_term_reason,
        grgr_ck as group_bk,
        mcre_id as cob_carrier_id,
        mecb_policy_id as cob_policy_id,
        mecb_mctr_msp as cob_msp_type,
        mecb_mctr_ptyp as cob_rx_coverage_type,
        mecb_rxbin as cob_rx_bin,
        mecb_rxpcn as cob_rx_pcn,
        mecb_rx_group as cob_rx_group,
        mecb_rx_id as cob_rx_id,
        mecb_last_ver_dt as cob_last_ver_dt,
        mecb_last_ver_name as cob_last_ver_name,
        mecb_mctr_vmth as cob_ver_method,
        mecb_loi_start_dt as cob_loi_start_dt,
        mecb_prim_last_nm as cob_prim_last_nm,
        mecb_prim_first_nm as cob_prim_first_nm,
        mecb_prim_id as cob_prim_id,
        mecb_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_dtm,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_db_user_id,

        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)

select * from renamed
```

---

## File: stg_member_cob_legacy_facets_rename.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
with source as (
    select *
    from {{ ref('enterprise_data_platform', 'stg_legacy_bcifacets_hist__dbo_cmc_mecb_cob') }}
),

renamed as (
    select
        '{{ var("legacy_source_system") }}' as source,
        '1' as tenant_id,
        meme_ck as member_bk,
        mecb_insur_type as cob_ins_type_bk,
        mecb_insur_order as cob_ins_order_bk,
        mecb_mctr_styp as cob_supp_drug_type_bk,
        mecb_eff_dt as cob_eff_dt,
        mecb_term_dt as cob_term_dt,
        mecb_mctr_trsn as cob_term_reason,
        grgr_ck as group_bk,
        mcre_id as cob_carrier_id,
        mecb_policy_id as cob_policy_id,
        mecb_mctr_msp as cob_msp_type,
        mecb_mctr_ptyp as cob_rx_coverage_type,
        mecb_rxbin as cob_rx_bin,
        mecb_rxpcn as cob_rx_pcn,
        mecb_rx_group as cob_rx_group,
        mecb_rx_id as cob_rx_id,
        mecb_last_ver_dt as cob_last_ver_dt,
        mecb_last_ver_name as cob_last_ver_name,
        mecb_mctr_vmth as cob_ver_method,
        mecb_loi_start_dt as cob_loi_start_dt,
        mecb_prim_last_nm as cob_prim_last_nm,
        mecb_prim_first_nm as cob_prim_first_nm,
        mecb_prim_id as cob_prim_id,
        mecb_lock_token as lock_token,
        atxr_source_id as attachment_source_id,
        sys_last_upd_dtm as last_update_dtm,
        sys_usus_id as last_update_user_id,
        sys_dbuser_id as last_update_db_user_id,
        edp_start_dt,
        edp_end_dt,
        edp_record_status,
        edp_record_source
    from source
)
select * from renamed
```

---

## File: stg_member_cob_gemstone_facets.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{% set yaml_metadata %}
source_model: "stg_member_cob_gemstone_facets_rename"

derived_columns:
  source: "'{{ var('gemstone_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"

hashed_columns:
  member_hk: ["source", "member_bk"]
  cob_indicator_hk: ["source", "cob_ins_type_bk", "cob_ins_order_bk", "cob_supp_drug_type_bk"]
  member_cob_hk: ["source", "member_bk", "cob_ins_type_bk", "cob_ins_order_bk", "cob_supp_drug_type_bk"]
  entity_address_group_hk : ["source", "group_bk", "cob_carrier_id"]
  group_hk : ["source", "group_bk"]
  entity_address_hk : ["source", "cob_carrier_id"]
  member_cob_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - member_bk
      - cob_ins_type_bk
      - cob_ins_order_bk
      - cob_supp_drug_type_bk
      - cob_eff_dt
      - cob_term_dt
      - cob_term_reason
      - group_bk
      - cob_carrier_id
      - cob_policy_id
      - cob_msp_type
      - cob_rx_coverage_type
      - cob_rx_bin
      - cob_rx_pcn
      - cob_rx_group
      - cob_rx_id
      - cob_last_ver_dt
      - cob_last_ver_name
      - cob_ver_method
      - cob_loi_start_dt
      - cob_prim_last_nm
      - cob_prim_first_nm
      - cob_prim_id
      - lock_token
      - attachment_source_id
      - last_update_dtm
      - last_update_user_id
      - last_update_db_user_id
      - edp_record_status
      - edp_record_source
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    null_columns=none,
    hashed_columns=metadata_dict['hashed_columns'],
    ranked_columns=none
) }}
```

---

## File: stg_member_cob_legacy_facets.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{% set yaml_metadata %}
source_model: "stg_member_cob_legacy_facets_rename"

derived_columns:
  source: "'{{ var('legacy_source_system') }}'"
  load_datetime: "edp_start_dt"
  edp_start_dt: "edp_start_dt"

hashed_columns:
  member_hk: ["source", "member_bk"]
  cob_indicator_hk: ["source", "cob_ins_type_bk", "cob_ins_order_bk", "cob_supp_drug_type_bk"]
  member_cob_hk: ["source", "member_bk", "cob_ins_type_bk", "cob_ins_order_bk", "cob_supp_drug_type_bk"]
  entity_address_group_hk : ["source", "group_bk", "cob_carrier_id"]
  group_hk : ["source", "group_bk"]
  entity_address_hk : ["source", "cob_carrier_id"]
  member_cob_hashdiff:
    is_hashdiff: true
    columns:
      - source
      - tenant_id
      - load_datetime
      - edp_start_dt
      - member_bk
      - cob_ins_type_bk
      - cob_ins_order_bk
      - cob_supp_drug_type_bk
      - cob_eff_dt
      - cob_term_dt
      - cob_term_reason
      - group_bk
      - cob_carrier_id
      - cob_policy_id
      - cob_msp_type
      - cob_rx_coverage_type
      - cob_rx_bin
      - cob_rx_pcn
      - cob_rx_group
      - cob_rx_id
      - cob_last_ver_dt
      - cob_last_ver_name
      - cob_ver_method
      - cob_loi_start_dt
      - cob_prim_last_nm
      - cob_prim_first_nm
      - cob_prim_id
      - lock_token
      - attachment_source_id
      - last_update_dtm
      - last_update_user_id
      - last_update_db_user_id
      - edp_record_status
      - edp_record_source
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(
    include_source_columns=true,
    source_model=metadata_dict['source_model'],
    derived_columns=metadata_dict['derived_columns'],
    null_columns=none,
    hashed_columns=metadata_dict['hashed_columns'],
    ranked_columns=none
) }}
```

---

### Data Vault 2.0 Hubs

## File: h_cob_indicator.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{%- set yaml_metadata -%}
source_model:
    - stg_member_cob_gemstone_facets
    - stg_member_cob_legacy_facets
src_pk:
    - cob_indicator_hk
src_nk:
    - source
    - cob_ins_type_bk
    - cob_ins_order_bk
    - cob_supp_drug_type_bk
src_ldts:
    - load_datetime
src_source:
    - source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.hub(src_pk=metadata_dict["src_pk"],
                   src_nk=metadata_dict["src_nk"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"]) }}
```

### Data Vault 2.0 Links

**l_member_cob_group.sql**:

```sql
{%- set yaml_metadata -%}
source_model:
    - stg_member_cob_gemstone_facets
    - stg_member_cob_legacy_facets
src_pk: member_cob_group_hk
src_fk:
    - member_cob_hk
    - group_hk
src_ldts: load_datetime
src_source: source
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(src_pk=metadata_dict["src_pk"],
                   src_fk=metadata_dict["src_fk"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"]) }}

```
---

## File: l_member_cob.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{% set yaml_metadata %}
source_model:
  - stg_member_cob_legacy_facets
  - stg_member_cob_gemstone_facets

src_pk: member_cob_hk

src_fk:
  - member_hk
  - cob_indicator_hk

src_ldts: load_datetime

src_source: source
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.link(
    src_pk=metadata_dict["src_pk"],
    src_fk=metadata_dict["src_fk"],
    src_ldts=metadata_dict["src_ldts"],
    src_source=metadata_dict["src_source"],
    source_model=metadata_dict["source_model"]
) }}
```

---

## File: s_member_cob_gemstone_facets.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{% set yaml_metadata %}
source_model: "stg_member_cob_gemstone_facets"

src_pk: "member_cob_hk"

src_dfk: "member_hk"

src_sfk: "cob_indicator_hk"

src_eff: "cob_eff_dt"

src_start_date: "cob_eff_dt"

src_end_date: "cob_term_dt"

src_hashdiff:
  source_column: "member_cob_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - member_bk
  - cob_ins_type_bk
  - cob_ins_order_bk
  - cob_supp_drug_type_bk
  - cob_eff_dt
  - cob_term_dt
  - cob_term_reason
  - group_bk
  - cob_carrier_id
  - cob_policy_id
  - cob_msp_type
  - cob_rx_coverage_type
  - cob_rx_bin
  - cob_rx_pcn
  - cob_rx_group
  - cob_rx_id
  - cob_last_ver_dt
  - cob_last_ver_name
  - cob_ver_method
  - cob_loi_start_dt
  - cob_prim_last_nm
  - cob_prim_first_nm
  - cob_prim_id
  - lock_token
  - attachment_source_id
  - last_update_dtm
  - last_update_user_id
  - last_update_db_user_id
  - edp_record_status
  - edp_record_source
  - member_hk
  - cob_indicator_hk

src_ldts: "load_datetime"

src_source: "source"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict["src_pk"],
    src_dfk=metadata_dict["src_dfk"],
    src_sfk=metadata_dict["src_sfk"],
    src_eff=metadata_dict["src_eff"],
    src_start_date=metadata_dict["src_start_date"],
    src_end_date=metadata_dict["src_end_date"],

    src_extra_columns=metadata_dict["src_extra_columns"],
    src_ldts=metadata_dict["src_ldts"],
    src_source=metadata_dict["src_source"],
    source_model=metadata_dict["source_model"]
) }}
```

---

## File: s_member_cob_legacy_facets.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{% set yaml_metadata %}
source_model: "stg_member_cob_legacy_facets"

src_pk: "member_cob_hk"
src_dfk: "member_hk"
src_sfk: "cob_indicator_hk"
src_eff: "cob_eff_dt"
src_start_date: "cob_eff_dt"
src_end_date: "cob_term_dt"
src_hashdiff:
  source_column: "member_cob_hashdiff"
  alias: "hashdiff"

src_extra_columns:
  - source
  - tenant_id
  - load_datetime
  - edp_start_dt
  - member_bk
  - cob_ins_type_bk
  - cob_ins_order_bk
  - cob_supp_drug_type_bk
  - cob_eff_dt
  - cob_term_dt
  - cob_term_reason
  - group_bk
  - cob_carrier_id
  - cob_policy_id
  - cob_msp_type
  - cob_rx_coverage_type
  - cob_rx_bin
  - cob_rx_pcn
  - cob_rx_group
  - cob_rx_id
  - cob_last_ver_dt
  - cob_last_ver_name
  - cob_ver_method
  - cob_loi_start_dt
  - cob_prim_last_nm
  - cob_prim_first_nm
  - cob_prim_id
  - lock_token
  - attachment_source_id
  - last_update_dtm
  - last_update_user_id
  - last_update_db_user_id
  - edp_record_status
  - edp_record_source
  - member_hk
  - cob_indicator_hk

src_ldts: "load_datetime"
src_source: "source"
{% endset %}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.eff_sat(
    src_pk=metadata_dict["src_pk"],
    src_dfk=metadata_dict["src_dfk"],
    src_sfk=metadata_dict["src_sfk"],
    src_eff=metadata_dict["src_eff"],
    src_start_date=metadata_dict["src_start_date"],
    src_end_date=metadata_dict["src_end_date"],
    src_extra_columns=metadata_dict["src_extra_columns"],
    src_ldts=metadata_dict["src_ldts"],
    src_source=metadata_dict["src_source"],
    source_model=metadata_dict["source_model"]
) }}
```

---

## File: current_member_cob.sql
## created in docs\use_cases\uc01_dv_refactor\output\member_cob

```sql
{{ config(materialized='view') }}

{% set source_systems = ["legacy_facets", "gemstone_facets"] %}
{% set hub_model_member = "h_member" %}
{% set hub_model_cob = "h_member_cob" %}
{% set link_model = "l_member_cob" %}
{% set link_key = "member_cob_hk" %}

{% for source_system in source_systems %}
  {% if source_system == "legacy_facets" %}
    {% set sat_model = "s_member_cob_legacy_facets" %}
  {% else %}
    {% set sat_model = "s_member_cob_gemstone_facets" %}
  {% endif %}

  select
    1 as tenant_id,
    hub_member.source,
    hub_member.member_bk,
    hub_cob.cob_ins_type_bk,
    hub_cob.cob_ins_order_bk,
    hub_cob.cob_supp_drug_type_bk,
    sat.cob_eff_dt,
    sat.cob_term_dt,
    sat.cob_term_reason,
    sat.group_bk,
    sat.cob_carrier_id,
    sat.cob_policy_id,
    sat.cob_msp_type,
    sat.cob_rx_coverage_type,
    sat.cob_rx_bin,
    sat.cob_rx_pcn,
    sat.cob_rx_group,
    sat.cob_rx_id,
    sat.cob_last_ver_dt,
    sat.cob_last_ver_name,
    sat.cob_ver_method,
    sat.cob_loi_start_dt,
    sat.cob_prim_last_nm,
    sat.cob_prim_first_nm,
    sat.cob_prim_id,
    sat.lock_token,
    sat.attachment_source_id,
    sat.last_update_dtm,
    sat.last_update_user_id,
    sat.last_update_db_user_id,
    sat.edp_record_status,
    lower(sat.edp_record_source) as edp_record_source,
    sat.load_datetime as create_dtm,
    sat.load_datetime as update_dtm
  from {{ ref(link_model) }} as link
  join {{ ref(hub_model_member) }} as hub_member
    on link.member_hk = hub_member.member_hk
  join {{ ref(hub_model_cob) }} as hub_cob
    on link.cob_indicator_hk = hub_cob.cob_indicator_hk
  join {{ ref(sat_model) }} as sat
    on link.member_cob_hk = sat.member_cob_hk
  join (
    select member_cob_hk, max(load_datetime) as max_load_datetime
    from {{ ref(sat_model) }}
    group by member_cob_hk
  ) as latest
    on sat.member_cob_hk = latest.member_cob_hk
   and sat.load_datetime = latest.max_load_datetime

  {% if not loop.last %}
    union all
  {% endif %}
{% endfor %}
```

---

## End of Document

This combined document includes all artifacts for the member_cob Data Vault refactoring pattern, showing the transformation from 3NF to Data Vault 2.0 architecture.
