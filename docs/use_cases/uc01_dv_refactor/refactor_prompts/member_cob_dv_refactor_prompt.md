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

### Prior dbt Model Code

```sql
{{
    config(
        unique_key=''member_cob_ik'',
        merge_exclude_columns = [''create_dtm'']
    )
}}

{% set schemas = ["legacy_bcifacets_hist","gemstone_facets_hist"]%}
{% for schema in schemas %}
    {%- if schema in ["legacy_bcifacets_hist"] -%}
        {%- set source_system = var(''legacy_source_system'') -%}
        {%- set ref_file = "stg_legacy_bcifacets_hist__dbo_cmc_mecb_cob" -%}
    {%- else -%}
        {%- set source_system = var(''gemstone_source_system'') -%}
        {%- set ref_file = "stg_gemstone_facets_hist__dbo_cmc_mecb_cob" -%}
    {%- endif -%}

    select
        {{dbt_utils.generate_surrogate_key([''1'',"''" ~ source_system ~ "''",''src.meme_ck'',''src.mecb_insur_type'',''src.mecb_insur_order'',''src.mecb_mctr_styp'',''src.mecb_eff_dt'']) }} as member_cob_ik,
        ''1'' as tenant_id,
        ''{{source_system}}'' as source_system,
        {{dbt_utils.generate_surrogate_key([''1'',"''" ~ source_system ~ "''",''src.meme_ck'']) }} as member_ik,
        src.meme_ck as member_bk,
        src.mecb_insur_type as cob_insurance_type,
        src.mecb_insur_order as cob_insurance_order,
        src.mecb_mctr_styp as cob_supp_drug_type,
        src.mecb_eff_dt as member_cob_eff_dt,
        case
            when lead(src.mecb_eff_dt) over (
                    partition by src.meme_ck,src.mecb_insur_type,src.mecb_insur_order,src.mecb_mctr_styp
                    order by src.mecb_eff_dt) < src.mecb_term_dt
                then dateadd(day,-1,lead(src.mecb_eff_dt) over (
                    partition by src.meme_ck,src.mecb_insur_type,src.mecb_insur_order,src.mecb_mctr_styp
                    order by src.mecb_eff_dt))
            when src.mecb_term_dt::date = ''1753-01-01'' then ''2199-12-31''
            else  src.mecb_term_dt
        end as member_cob_term_dt, -- windowed function to eliminate overlapping date ranges from the source
        src.mecb_mctr_trsn as member_cob_term_reason,
        src.mcre_id as cob_carrier_id,
        src.mecb_policy_id as cob_policy_id,
        src.edp_start_dt as edp_start_dt,
        src.edp_end_dt as edp_end_dt,
        src.edp_record_status as edp_record_status,
        lower(src.edp_record_source) as edp_record_source,
        getdate() as create_dtm,
        getdate() as update_dtm
    from {{ ref( ''enterprise_data_platform'',ref_file ) }} src
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where src.edp_start_dt >= (select dateadd(dd,-3,coalesce(max(edp_start_dt), ''1900-01-01'')) from {{ this }})
    {% endif %}
    qualify member_cob_eff_dt < member_cob_term_dt
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```
