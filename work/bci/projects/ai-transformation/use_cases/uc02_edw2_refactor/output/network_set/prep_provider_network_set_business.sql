{{
    config(
        materialized='view'
    )
}}

with providernetwork_nondv_01 as
(
select source
       ,provider_bk
	   ,network_bk
	   ,provider_network_prefix_bk
	   ,start_date
	   ,case
	       when lead(start_date,1,null) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by start_date) is null
		      then
			     --max(provider_network_term_dt)
				 dateadd(day,1,dateadd(day,-1,lead(start_date,1,max(provider_network_term_dt)) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by start_date)))
		   else 
	          dateadd(day,-1,lead(start_date,1,max(provider_network_term_dt)) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by start_date))
	   end end_date
	   ,case
	       when lead(start_date,1,null) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by start_date) is null
		      then 'Active'
		   else
		      'InActive'
	   end network_participation_status
       ,edp_record_source
from
(
select source
       ,provider_bk
	   ,network_bk
	   ,provider_network_prefix_bk
	   ,provider_network_eff_dt
	   ,provider_network_term_dt
	   ,prior_provider_network_eff_dt
	   ,next_provider_network_eff_dt
	   ,prior_provider_network_term_dt
	   ,next_provider_network_term_dt
	   ,cast(case when prior_provider_network_eff_dt = '1900-01-01' then provider_network_eff_dt else cast(provider_network_eff_dt as date) end as timestamp_ntz) start_date
       ,edp_record_source
from
(
select  source
        ,provider_bk
	    ,network_bk
	    ,provider_network_prefix_bk
	    ,provider_network_eff_dt
        ,provider_network_term_dt
	    ,prior_provider_network_eff_dt
	    ,next_provider_network_eff_dt
	    ,prior_provider_network_term_dt
	    ,next_provider_network_term_dt
	    ,row_number () over (partition by source, provider_bk, network_bk, provider_network_prefix_bk, provider_network_eff_dt order by provider_network_term_dt) rownum
        ,edp_record_source
from
(
select source
       ,provider_bk
	   ,network_bk
	   ,provider_network_prefix_bk
	   ,provider_network_eff_dt
	   ,max(provider_network_term_dt) as provider_network_term_dt
	   ,lag(provider_network_eff_dt,1,null) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by max(provider_network_term_dt), provider_network_eff_dt) prior_provider_network_eff_dt
	   ,lead(provider_network_eff_dt,1,null) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by max(provider_network_term_dt), provider_network_eff_dt) next_provider_network_eff_dt
	   ,lag(max(provider_network_term_dt),1,null) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by max(provider_network_term_dt), provider_network_eff_dt) prior_provider_network_term_dt
	   ,lead(max(provider_network_term_dt),1,null) over (partition by source, provider_bk, network_bk, provider_network_prefix_bk order by max(provider_network_term_dt), provider_network_eff_dt) next_provider_network_term_dt
       ,edp_record_source
from
(
select
    source,
    provider_bk,
    network_bk,
    provider_network_prefix_bk,
    case
        when provider_network_eff_dt = lag(provider_network_eff_dt, 1, null) 
             over (partition by source, provider_bk, network_bk, provider_network_prefix_bk 
                   order by provider_network_eff_dt, provider_network_term_dt)
        then dateadd(
                 day, 1, lag(provider_network_term_dt, 1, null) 
                 over (partition by source, provider_bk, network_bk, provider_network_prefix_bk 
                       order by provider_network_eff_dt, provider_network_term_dt)
             )
        else provider_network_eff_dt
    end as provider_network_eff_dt,
    provider_network_term_dt,
    edp_record_source
from (
    select 
        source,
        upper(provider_bk) as provider_bk,
        trim(network_bk) as network_bk,
        trim(provider_network_prefix_bk) as provider_network_prefix_bk,
        provider_network_eff_dt,
        provider_network_term_dt,
        edp_record_source
    from {{ ref('current_provider_network_relational') }}  a
    where provider_network_eff_dt <> provider_network_term_dt
        and edp_record_status = 'Y'
        --and trim(provider_bk) = '21971'
    group by 
        source,
        upper(provider_bk),
        trim(network_bk),
        trim(provider_network_prefix_bk),
        provider_network_eff_dt,
        provider_network_term_dt,
        edp_record_source
    union

    select 
        source,
        upper(provider_bk) as provider_bk,
        trim(network_bk) as network_bk,
        trim(provider_network_prefix_bk) as provider_network_prefix_bk,
        '2003-01-01'::date as provider_network_eff_dt,
        dateadd(day, -1, min(provider_network_eff_dt)) as provider_network_term_dt,
        edp_record_source
    from {{ ref('current_provider_network_relational') }} a
    where provider_network_eff_dt <> provider_network_term_dt
        and edp_record_status = 'Y'
        --and trim(provider_bk) = '21971'
    group by 
        source,
        upper(provider_bk),
        trim(network_bk),
        trim(provider_network_prefix_bk),
        edp_record_source
    having min(provider_network_eff_dt) > '2003-01-01'
) pnr
) prn2
group by source
       ,provider_bk
	   ,network_bk
	   ,provider_network_prefix_bk
	   ,provider_network_eff_dt
       ,edp_record_source
) a
) b
where rownum = 1
) c
group by source
         ,provider_bk
	     ,network_bk
	     ,provider_network_prefix_bk
	     ,provider_network_eff_dt
	     ,start_date
         ,edp_record_source
),
providernetwork_nondv_02 as
(
select
    upper(rtrim(ltrim(nwpr.provider_bk))) provider_bk,
    rtrim(ltrim(nwpr.network_bk)) network_bk,
    nwnw.network_name,
    case 
        when rtrim(ltrim(nwpr.provider_network_prefix_bk)) = 'BCI'
            then 'BCI' else pdpx.component_prefix_description
    end component_prefix_description,
    case 
        when coalesce(nwnw.network_type, '') = ''
            then 'PRE'
        else nwnw.network_type
    end nwnw_mctr_type,
    rtrim(ltrim(nwpr.provider_network_prefix_bk)) provider_network_prefix_bk,
    case 
        when coalesce(nwnw.network_type, '') = '' 
            then 'Prior to network type being required'
        when mctr.user_defined_code_description = 'Health Maintenance Organizatio'
            then 'Health Maintenance Organization'
        else mctr.user_defined_code_description
    end nwnw_mctr_type_description,
    nwpr.network_participation_status,
    nwpr.start_date provider_network_eff_dt,
    nwpr.end_date provider_network_term_dt,
    nwpr.start_date start_date,
    nwpr.end_date end_date,
    nwnw.source,
    nwnw.tenant_id,
    nwpr.edp_record_source
from providernetwork_nondv_01 nwpr -- cmc_nwpr_relation -- dev_int_db.dv_raw_vault.current_provider_network_relational
    join {{ ref('current_network') }} nwnw -- cmc_nwnw_network --dev_int_db.dv_raw_vault.current_network
        on rtrim(ltrim(nwpr.network_bk)) = rtrim(ltrim(nwnw.network_bk))
        and nwpr.source = nwnw.source
    left join {{ ref('current_user_defined_code_translations') }} mctr -- cmc_mctr_cd_trans --current_user_defined_code_translations
        on nwnw.network_type = mctr.user_defined_code_bk
        and nwnw.source = mctr.source
        and mctr.user_defined_codes_entity_bk = 'NWNW'
        and mctr.user_defined_code_type_bk = 'TYPE'
    left join {{ ref('current_product_component') }} pdpx-- cmc_component_prefix_description -- dev_int_db.dv_raw_vault.current_network
        on rtrim(ltrim(nwpr.provider_network_prefix_bk)) = rtrim(ltrim(pdpx.component_prefix_bk))
        and nwpr.source = pdpx.source
        and pdpx.component_type_bk = 'NWPR'
where nwnw.edp_record_status = 'Y'
    and mctr.edp_record_status = 'Y'
    and pdpx.edp_record_status = 'Y'
group by 
    upper(rtrim(ltrim(nwpr.provider_bk))),
    rtrim(ltrim(nwpr.network_bk)),
    nwnw.network_name,
    rtrim(ltrim(nwpr.provider_network_prefix_bk)),
    case 
        when rtrim(ltrim(nwpr.provider_network_prefix_bk)) = 'BCI' 
           then 'BCI'
        else pdpx.component_prefix_description 
    end,
    case 
        when coalesce(nwnw.network_type, '') = '' 
            then 'PRE'
        else nwnw.network_type
    end,
    case 
        when coalesce(nwnw.network_type, '') = '' 
            then 'Prior to network type being required'
        when mctr.user_defined_code_description = 'Health Maintenance Organizatio' 
            then 'Health Maintenance Organization'
        else mctr.user_defined_code_description
    end,
    nwpr.start_date,
    nwpr.end_date,
    nwpr.network_participation_status,
    nwnw.source,
    nwnw.tenant_id,
    nwpr.edp_record_source
),
providernetwork_nondv_03 as
(
select 
    pnn2.source,
    pnn2.tenant_id,
    h_provider.provider_hk,
    pnn2.provider_bk,
    pnn2.network_bk,
    pnn2.network_name,
    pnn2.component_prefix_description,
    pnn2.nwnw_mctr_type,
    pnn2.provider_network_prefix_bk,
    pnn2.nwnw_mctr_type_description,
    pnn2.network_participation_status,
    pnn2.provider_network_eff_dt,
    pnn2.provider_network_term_dt,
    pnn2.start_date,
    pnn2.end_date,
    dim_network_set.hk_network_set,
    h_provider.rownum,
    pnn2.edp_record_source
from providernetwork_nondv_02 pnn2
     left join (select h_provider.provider_hk, h_provider.source, h_provider.provider_bk, row_number () over (partition by h_provider.source, h_provider.provider_bk order by h_provider.load_datetime desc, h_provider.provider_hk) rownum
                from {{ ref('h_provider') }} ) h_provider
        on h_provider.source = pnn2.source
        and h_provider.provider_bk = pnn2.provider_bk
     left join {{ ref('dim_network_set') }} dim_network_set
        on dim_network_set.network_set = pnn2.provider_network_prefix_bk
        and dim_network_set.network_id = pnn2.network_bk
),
providernetwork_nondv_04 as
(
select 
    tenant_id, source, provider_bk, network_bk, provider_network_prefix_bk,
    min(provider_network_eff_dt) as min_provider_network_eff_dt,
    max(provider_network_eff_dt) as max_provider_network_eff_dt
from providernetwork_nondv_03
where rownum = 1
group by tenant_id, source, provider_bk, network_bk, provider_network_prefix_bk
)

select 
    a.tenant_id,
    a.source,
    a.provider_bk as provider_id,
    a.network_bk as network_id,
    a.network_name as network_description,
    a.provider_network_prefix_bk as network_prefix,
    a.component_prefix_description as network_prefix_description,
    a.nwnw_mctr_type as network_type,
    a.nwnw_mctr_type_description as network_type_description,
    a.provider_network_eff_dt as network_effective_date,
    a.provider_network_term_dt as network_term_date,
    a.network_participation_status,
    case 
        when a.provider_network_eff_dt = b.min_provider_network_eff_dt
            then 
                cast('1900-01-01' as date)
        else cast(a.provider_network_eff_dt as date)
    end dss_start_date,
    case 
        when a.provider_network_eff_dt = b.max_provider_network_eff_dt
            then cast('2999-12-31' as date)
        else
            cast(
            lead (a.provider_network_eff_dt, 1, a.provider_network_term_dt)
            over (partition by a.tenant_id, a.source, a.provider_bk, a.network_bk, a.provider_network_prefix_bk
            order by a.provider_network_eff_dt)
            as date) - 1
    end dss_end_date,
    case when getdate() between dss_start_date and dss_end_date then '1' else '0' end is_current,
    a.edp_record_source as dss_record_source,
    getdate() dss_create_time,
    getdate() dss_update_time,
    a.provider_hk,
    a.hk_network_set 
from providernetwork_nondv_03 a
    inner join providernetwork_nondv_04 b
        on a.tenant_id = b.tenant_id
        and a.source = b.source
        and a.provider_bk = b.provider_bk
        and a.network_bk = b.network_bk
        and a.provider_network_prefix_bk = b.provider_network_prefix_bk
where rownum = 1