Please follow the project guidelines and generate the refactored code for the group_plan_eligibility entity

### Expected Output Summary

I expect that the Raw Vault artifacts generated will include:

- Data Dictionary source_table Name
  - cmc_cspi_cs_plan
- Rename Views (1 per source)
  - stg_group_plan_eligibility_legacy_facets_rename.sql
  - stg_group_plan_eligibility_gemstone_facets_rename.sql
- Staging Views (1 per source)
  - stg_group_plan_eligibility_legacy_facets.sql
  - stg_group_plan_eligibility_gemstone_facets.sql
- Link
  - l_group_plan_eligibility.sql
    - business Keys:
      - group_hk (from source column: grgr_ck)
      - product_category_hk (from source column: cspd_cat)
      - class_hk (from source column: cscs_id)
      - plan_hk (from source column: cspi_id)
- Effectivity Satellites (1 per source)
  - For each satellite:
    - src_eff: cspi_eff_dt from source
    - src_start_date: cspi_eff_dt from source
    - src_end_date: cspi_term_dt from source
  - s_group_plan_eligibility_legacy_facets.sql
  - s_group_plan_eligibility_gemstone_facets.sql
- Current View
  - cv_group_plan_eligibility.sql
- Backward Compatible View
  - bwd_group_plan_eligibility.sql

### Data Dictionary

- Use this information to map source view references in the prior model code back to the source solumns, and rename columns in the rename views:

```csv
source_schema,source_table, source_column, table_description, column_description, column_data_type
dbo,cmc_cspi_cs_plan,grgr_ck,Plan/Product Linking Data Table,Class/Plan Group Contrived Key,int
dbo,cmc_cspi_cs_plan,cscs_id,Plan/Product Linking Data Table,Class ID,char
dbo,cmc_cspi_cs_plan,cspd_cat,Plan/Product Linking Data Table,Class/Plan Product Category,char
dbo,cmc_cspi_cs_plan,cspi_id,Plan/Product Linking Data Table,Plan ID,char
dbo,cmc_cspi_cs_plan,cspi_eff_dt,Plan/Product Linking Data Table,Class/Plan Effective Date,datetime
dbo,cmc_cspi_cs_plan,cspi_term_dt,Plan/Product Linking Data Table,Class/Plan Termination Date,datetime
dbo,cmc_cspi_cs_plan,pdpd_id,Plan/Product Linking Data Table,Product ID,char
dbo,cmc_cspi_cs_plan,cspi_sel_ind,Plan/Product Linking Data Table,Class/Plan Selectable Indicator,char
dbo,cmc_cspi_cs_plan,cspi_fi,Plan/Product Linking Data Table,Class/Plan Family Indicator,char
dbo,cmc_cspi_cs_plan,cspi_guar_dt,Plan/Product Linking Data Table,Class/Plan Rate Guarantee Date,datetime
dbo,cmc_cspi_cs_plan,cspi_guar_per_mos,Plan/Product Linking Data Table,Class/Plan Rate Guarantee Period Months,smallint
dbo,cmc_cspi_cs_plan,cspi_guar_ind,Plan/Product Linking Data Table,Class/Plan Rate Guarantee Indicator,char
dbo,cmc_cspi_cs_plan,pmar_pfx,Plan/Product Linking Data Table,Class/Plan Age Volume Reduction Table Prefix,char
dbo,cmc_cspi_cs_plan,wmds_seq_no,Plan/Product Linking Data Table,Class/Plan User Warning Message,smallint
dbo,cmc_cspi_cs_plan,cspi_open_beg_mmdd,Plan/Product Linking Data Table,Class/Plan Open Enrollment Begin Period,smallint
dbo,cmc_cspi_cs_plan,cspi_open_end_mmdd,Plan/Product Linking Data Table,Class/Plan Open Enrollment End Period,smallint
dbo,cmc_cspi_cs_plan,gpai_id,Plan/Product Linking Data Table,Class/Plan Group Administration Rules ID,char
dbo,cmc_cspi_cs_plan,cspi_its_prefix,Plan/Product Linking Data Table,ITS Prefix,char
dbo,cmc_cspi_cs_plan,cspi_age_calc_meth,Plan/Product Linking Data Table,Premium Age Calculation Method,char
dbo,cmc_cspi_cs_plan,cspi_card_stock,Plan/Product Linking Data Table,Member ID Card Stock,char
dbo,cmc_cspi_cs_plan,cspi_mctr_ctyp,Plan/Product Linking Data Table,Product Member ID Card Type,char
dbo,cmc_cspi_cs_plan,cspi_hedis_cebreak,Plan/Product Linking Data Table,HEDIS Continuous Enrollment Break,char
dbo,cmc_cspi_cs_plan,cspi_hedis_days,Plan/Product Linking Data Table,HEDIS Continuous Enrollment Days,smallint
dbo,cmc_cspi_cs_plan,cspi_pdpd_beg_mmdd,Plan/Product Linking Data Table,Plan Year Begin Date,smallint
dbo,cmc_cspi_cs_plan,nwst_pfx,Plan/Product Linking Data Table,Network Set Prefix,char
dbo,cmc_cspi_cs_plan,cspi_pdpd_co_mnth,Plan/Product Linking Data Table, ,smallint
dbo,cmc_cspi_cs_plan,cvst_pfx,Plan/Product Linking Data Table,Covering Provider Set Prefix,char
dbo,cmc_cspi_cs_plan,hsai_id,Plan/Product Linking Data Table,HRA Administrative Information ID,char
dbo,cmc_cspi_cs_plan,cspi_postpone_ind,Plan/Product Linking Data Table, Postponement Indicator,char
dbo,cmc_cspi_cs_plan,grdc_pfx,Plan/Product Linking Data Table, Debit Card/Bank Relationship Prefix,char
dbo,cmc_cspi_cs_plan,uted_pfx,Plan/Product Linking Data Table,Dental Utilization Edits Prefix,char
dbo,cmc_cspi_cs_plan,vbbr_id,Plan/Product Linking Data Table,Value Based Benefits Parms ID,char
dbo,cmc_cspi_cs_plan,svbl_id,Plan/Product Linking Data Table,Billing Strategy (Vision Only),char
dbo,cmc_cspi_cs_plan,cspi_lock_token,Plan/Product Linking Data Table,Lock Token,smallint
dbo,cmc_cspi_cs_plan,atxr_source_id,Plan/Product Linking Data Table,Attachment Source Id,datetime
dbo,cmc_cspi_cs_plan,sys_last_upd_dtm,Plan/Product Linking Data Table,Last Update Datetime,datetime
dbo,cmc_cspi_cs_plan,sys_usus_id,Plan/Product Linking Data Table,Last Update User ID,varchar
dbo,cmc_cspi_cs_plan,sys_dbuser_id,Plan/Product Linking Data Table,Last Update DBMS User ID,varchar
dbo,cmc_cspi_cs_plan,cspi_sec_plan_cd_nvl,Plan/Product Linking Data Table,Secondary Plan Processing code,char
dbo,cmc_cspi_cs_plan,mcre_id_nvl,Plan/Product Linking Data Table,Authorization/Certification Related Entity ID,char
dbo,cmc_cspi_cs_plan,cspi_its_acct_excp_nvl,Plan/Product Linking Data Table, ITS Account Exception,char
dbo,cmc_cspi_cs_plan,cspi_ren_beg_mmdd_nvl,Plan/Product Linking Data Table, Policy Issuance or Renewal Begins Date,smallint
dbo,cmc_cspi_cs_plan,cspi_hios_id_nvl,Plan/Product Linking Data Table, Health Insurance Oversight System Identifier,varchar
dbo,cmc_cspi_cs_plan,cspi_itspfx_acctid_nvl,Plan/Product Linking Data Table, ITS Prefix Account ID,varchar
dbo,cmc_cspi_cs_plan,pgps_pfx,Plan/Product Linking Data Table,Patient Care Program Set,varchar
```

### Prior dbt Model Code

```sql
{{
    config(
        unique_key='group_plan_eligibility_ik',
        merge_exclude_columns = ['create_dtm']
    )
}}

{% set schemas = ["legacy_bcifacets_hist","gemstone_facets_hist"] %}
{% for schema in schemas %}
    {%- if schema in ["legacy_bcifacets_hist"] -%}
        {%- set source_system = var('legacy_source_system') -%}
        {%- set ref_file = "stg_legacy_bcifacets_hist__dbo_cmc_cspi_cs_plan" -%}
    {%- else -%}
        {%- set source_system = var('gemstone_source_system') -%}
        {%- set ref_file = "stg_gemstone_facets_hist__dbo_cmc_cspi_cs_plan" -%}
    {%- endif -%}

    select
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.grgr_ck','src.cspd_cat','src.cscs_id','src.cspi_id','src.cspi_eff_dt']) }} as group_plan_eligibility_ik,
        1 as tenant_id,
        '{{ source_system }}' as source_system,
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.grgr_ck']) }} as employer_group_ik,
        cast(src.grgr_ck as varchar) as employer_group_bk,
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.cspd_cat']) }} as plan_category_ik,
        src.cspd_cat as plan_category_bk,
        src.cspi_eff_dt as plan_eff_date,
        case
            when lead(src.cspi_eff_dt) over (partition by src.edp_record_status,src.grgr_ck,src.cspd_cat,src.cscs_id,src.cspi_id order by src.cspi_eff_dt) < src.cspi_term_dt
                then dateadd(day,-1,lead(src.cspi_eff_dt) over (partition by src.edp_record_status,src.grgr_ck,src.cspd_cat,src.cscs_id,src.cspi_id order by src.cspi_eff_dt))
            else cspi_term_dt
        end as plan_term_date, -- windowed function to eliminate overlapping date ranges from the source
        src.pdpd_id as product_bk,
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.grgr_ck','src.cscs_id']) }} as class_ik,
        src.cscs_id as class_bk,
        {{ dbt_utils.generate_surrogate_key(['1',"'" ~ source_system ~ "'",'src.cspi_id']) }} as plan_ik,
        src.cspi_id as plan_bk,
        src.cspi_its_prefix as its_prefix,
        src.nwst_pfx as network_set_prefix,
        src.cspi_hios_id_nvl as hios_id,
        src.edp_start_dt,
        src.edp_end_dt,
        src.edp_record_status as edp_record_status,
        lower(src.edp_record_source) as edp_record_source,
        getdate() as create_dtm,
        getdate() as update_dtm
    from {{ ref( 'enterprise_data_platform',ref_file ) }} as src
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where src.edp_start_dt >= (select dateadd(dd,-3,coalesce(max(edp_start_dt), '1900-01-01')) from {{ this }})
    {% endif %}
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```
