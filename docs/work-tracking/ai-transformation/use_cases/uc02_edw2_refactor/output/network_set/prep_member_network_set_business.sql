{{
    config(
        materialized='view'
    )
}}

with membernetworksetlookup_nondv_01 as
(
  select 
    current_member_eligibility.source as source,
    current_member_eligibility.tenant_id as tenant_id,
    current_member_eligibility.member_bk as member_bk,
    current_member_eligibility.group_bk as group_bk,
    current_member_eligibility.class_bk as class_bk,
    current_member_eligibility.plan_bk as plan_bk,
    current_member_eligibility.product_bk as product_bk,
    current_member_eligibility.elig_eff_dt as elig_eff_dt,
    current_member_eligibility.elig_term_dt as elig_term_dt,
    current_member_eligibility.edp_record_source as dss_record_source
  from {{ ref('current_member_eligibility') }} current_member_eligibility
  where current_member_eligibility.eligibility_ind = 'Y'
  	and current_member_eligibility.product_category_bk = 'M'
  	and current_member_eligibility.elig_term_dt >= '01/01/2017'
    and not current_member_eligibility.source is null
    and current_member_eligibility.edp_record_status = 'Y'
),
membernetworksetlookup_nondv_02 as 
(
  select
    current_member.source as source,
    current_member.tenant_id as tenant_id,
    current_member.member_bk as member_bk,
    current_network_set.network_set_prefix as network_set_prefix,
    current_network_set.network_set_seq_no as network_set_seq_no,
    current_network_set.network_id as network_id,
    membernetworksetlookup_nondv_01.elig_eff_dt as elig_eff_dt,
    membernetworksetlookup_nondv_01.elig_term_dt as elig_term_dt,
    current_group_plan_eligibility.plan_eff_dt as plan_eff_dt,
    current_group_plan_eligibility.plan_term_dt as plan_term_dt,
    current_network_set.network_set_eff_dt as network_set_eff_dt,
    current_network_set.network_set_term_dt as network_set_term_dt,
    membernetworksetlookup_nondv_01.dss_record_source,
    max(current_product_component.component_type_bk) as component_type_bk
  from {{ ref('current_member') }} current_member
       inner join membernetworksetlookup_nondv_01 membernetworksetlookup_nondv_01
          on membernetworksetlookup_nondv_01.source = current_member.source
          and membernetworksetlookup_nondv_01.member_bk = current_member.member_bk
       inner join {{ ref('current_group_plan_eligibility') }} current_group_plan_eligibility
          on current_group_plan_eligibility.source = membernetworksetlookup_nondv_01.source
          and membernetworksetlookup_nondv_01.group_bk = current_group_plan_eligibility.group_bk
          and membernetworksetlookup_nondv_01.class_bk = current_group_plan_eligibility.class_bk
          and current_group_plan_eligibility.plan_category_bk = 'M'
          and membernetworksetlookup_nondv_01.plan_bk = current_group_plan_eligibility.plan_bk
          and (current_group_plan_eligibility.plan_eff_dt <= membernetworksetlookup_nondv_01.elig_term_dt)
          and (current_group_plan_eligibility.plan_term_dt >= membernetworksetlookup_nondv_01.elig_eff_dt)
          and membernetworksetlookup_nondv_01.product_bk = current_group_plan_eligibility.prod_id
       inner join {{ ref('current_network_set') }} current_network_set
          on current_network_set.source = current_group_plan_eligibility.source
          and current_network_set.network_set_prefix = current_group_plan_eligibility.network_set_prefix
          and (current_network_set.network_set_eff_dt <= current_group_plan_eligibility.plan_term_dt)
          and (current_network_set.network_set_term_dt >= current_group_plan_eligibility.plan_eff_dt)
          and (current_network_set.network_set_eff_dt <= membernetworksetlookup_nondv_01.elig_term_dt)
          and (current_network_set.network_set_term_dt >= membernetworksetlookup_nondv_01.elig_eff_dt)
       inner join {{ ref('current_product_component') }} current_product_component
          on current_product_component.source = current_network_set.source
          and current_product_component.component_prefix_bk = current_network_set.network_set_prefix
          and current_product_component.component_type_bk = 'NWST'
  where current_member.edp_record_status = 'Y'
        and current_group_plan_eligibility.edp_record_status = 'Y'
        and current_network_set.edp_record_status = 'Y'
        and current_product_component.edp_record_status = 'Y'
  group by 
  	current_member.source 
    ,current_member.tenant_id
  	,current_member.member_bk
  	,current_network_set.network_set_prefix
  	,current_network_set.network_set_seq_no
  	,current_network_set.network_id
  	,membernetworksetlookup_nondv_01.elig_eff_dt
  	,membernetworksetlookup_nondv_01.elig_term_dt
  	,current_group_plan_eligibility.plan_eff_dt
  	,current_group_plan_eligibility.plan_term_dt
  	,current_network_set.network_set_eff_dt
  	,current_network_set.network_set_term_dt
    ,membernetworksetlookup_nondv_01.dss_record_source
),
membernetworksetlookup_nondv_03 as
(
  select
    membernetworksetlookup_nondv_02.source source,
    membernetworksetlookup_nondv_02.tenant_id,
    membernetworksetlookup_nondv_02.member_bk member_bk,
    membernetworksetlookup_nondv_02.from_date from_date,
    membernetworksetlookup_nondv_02.dss_record_source
  from  
  (
  select n.source, n.member_bk, n.elig_eff_dt from_date, n.dss_record_source, n.tenant_id
  from membernetworksetlookup_nondv_02 n
  group by n.source, n.member_bk, n.elig_eff_dt, n.dss_record_source, n.tenant_id  
  union
  select n.source, n.member_bk, n.plan_eff_dt from_date, n.dss_record_source, n.tenant_id 
  from membernetworksetlookup_nondv_02 n
  group by n.source, n.member_bk, n.plan_eff_dt, n.dss_record_source, n.tenant_id  
  union
  select n.source, n.member_bk,n.network_set_eff_dt from_date, n.dss_record_source, n.tenant_id 
  from membernetworksetlookup_nondv_02 n
  group by n.source, n.member_bk, n.network_set_eff_dt, n.dss_record_source, n.tenant_id  
  union
  ---- day after a thru date could be a from date
  select n.source, n.member_bk, case when n.elig_term_dt = '12/31/9999' then n.elig_term_dt else dateadd(day,1,n.elig_term_dt) end from_date, n.dss_record_source, n.tenant_id
  from membernetworksetlookup_nondv_02 n
  group by n.source, n.member_bk, case when n.elig_term_dt = '12/31/9999' then n.elig_term_dt else dateadd(day,1,n.elig_term_dt) end, n.dss_record_source, n.tenant_id 
  union
  select n.source, n.member_bk, case when n.network_set_term_dt = '12/31/9999' then n.network_set_term_dt else dateadd(day,1,n.network_set_term_dt) end from_date, n.dss_record_source, n.tenant_id
  from membernetworksetlookup_nondv_02 n
  group by n.source, n.member_bk, case when n.network_set_term_dt = '12/31/9999' then n.network_set_term_dt else dateadd(day,1,n.network_set_term_dt) end, n.dss_record_source, n.tenant_id
  union
  select n.source, n.member_bk, case when n.network_set_term_dt = '12/31/9999' then n.network_set_term_dt else dateadd(day,1,n.network_set_term_dt) end from_date, n.dss_record_source, n.tenant_id
  from membernetworksetlookup_nondv_02 n
  group by n.source, n.member_bk,case when n.network_set_term_dt = '12/31/9999' then n.network_set_term_dt else dateadd(day,1,n.network_set_term_dt) end, n.dss_record_source, n.tenant_id
  ) membernetworksetlookup_nondv_02
),
membernetworksetlookup_nondv_04 as
(
  select
    membernetworksetlookup_nondv_02.source source,
    membernetworksetlookup_nondv_02.tenant_id,
    membernetworksetlookup_nondv_02.member_bk member_bk,
    membernetworksetlookup_nondv_02.thru_date thru_date,
    membernetworksetlookup_nondv_02.dss_record_source
  from  
  (
  select n.source, n.member_bk, n.elig_term_dt thru_date, n.dss_record_source, n.tenant_id 
  from membernetworksetlookup_nondv_02 n  
  group by n.source, n.member_bk, n.elig_term_dt, n.dss_record_source, n.tenant_id 
  	union			
  select n.source, n.member_bk, n.plan_term_dt thru_date, n.dss_record_source, n.tenant_id 
  from membernetworksetlookup_nondv_02 n  
  group by n.source, n.member_bk, n.plan_term_dt, n.dss_record_source, n.tenant_id 
  	union			
  select n.source, n.member_bk, n.network_set_term_dt thru_date, n.dss_record_source, n.tenant_id 
  from membernetworksetlookup_nondv_02 n  
  group by n.source, n.member_bk, n.network_set_term_dt, n.dss_record_source, n.tenant_id 
  	union
  ---- day before a from date could be a thru date
  select n.source, n.member_bk, dateadd(day,-1,n.elig_eff_dt) from_date, n.dss_record_source, n.tenant_id  
  from membernetworksetlookup_nondv_02 n  
  group by n.source, n.member_bk, dateadd(day,-1,n.elig_eff_dt), n.dss_record_source, n.tenant_id
  	union
  select n.source, n.member_bk, dateadd(day,-1,n.plan_eff_dt) from_date, n.dss_record_source, n.tenant_id  
  from membernetworksetlookup_nondv_02 n  
  group by n.source, n.member_bk, dateadd(day,-1,n.plan_eff_dt), n.dss_record_source, n.tenant_id
  	union
  select n.source, n.member_bk, dateadd(day,-1,n.network_set_eff_dt) from_date, n.dss_record_source, n.tenant_id  
  from membernetworksetlookup_nondv_02 n  
  group by n.source, n.member_bk, dateadd(day,-1,n.network_set_eff_dt), n.dss_record_source, n.tenant_id
  ) membernetworksetlookup_nondv_02
),
membernetworksetlookup_nondv_05 as
(
  select
    membernetworksetlookup_nondv_03.source source,
    membernetworksetlookup_nondv_03.tenant_id tenant_id,
    membernetworksetlookup_nondv_03.member_bk member_bk,
    membernetworksetlookup_nondv_03.from_date from_date,
    membernetworksetlookup_nondv_03.dss_record_source,
    membernetworksetlookup_nondv_04.thru_date thru_date,
    row_number() over (
 partition by 
  membernetworksetlookup_nondv_03.source,
  membernetworksetlookup_nondv_03.tenant_id,
  membernetworksetlookup_nondv_03.member_bk, 
  membernetworksetlookup_nondv_03.from_date,
  membernetworksetlookup_nondv_03.dss_record_source
 order by 
  datediff(
   day,
   membernetworksetlookup_nondv_03.from_date,
   membernetworksetlookup_nondv_04.thru_date) asc
  ) rownum,
    datediff(
 day,
 membernetworksetlookup_nondv_03.from_date,
 membernetworksetlookup_nondv_04.thru_date
) daysinterval
  from  
   membernetworksetlookup_nondv_03 membernetworksetlookup_nondv_03 -- from_dates			
   inner join membernetworksetlookup_nondv_04 membernetworksetlookup_nondv_04 -- thru_dates
    on membernetworksetlookup_nondv_04.member_bk = membernetworksetlookup_nondv_03.member_bk
     and membernetworksetlookup_nondv_04.source = membernetworksetlookup_nondv_03.source
  where 
   datediff(
    day,
    membernetworksetlookup_nondv_03.from_date, 
    membernetworksetlookup_nondv_04.thru_date
   ) >= 0
),
membernetworksetlookup_nondv_06 as
(
--create table of discrete date range combinations
	select
		membernetworksetlookup_nondv_05.source,
        membernetworksetlookup_nondv_05.tenant_id,
		membernetworksetlookup_nondv_05.member_bk,
		null group_id, 
		null subscriber_id, 
		null member_suffix,
		null network_set_prefix,
		null network_id, 
		membernetworksetlookup_nondv_05.from_date start_date,
		membernetworksetlookup_nondv_05.thru_date end_date,
        membernetworksetlookup_nondv_05.dss_record_source
	from membernetworksetlookup_nondv_05 membernetworksetlookup_nondv_05
	where membernetworksetlookup_nondv_05.rownum = 1
		and membernetworksetlookup_nondv_05.from_date <> '9999-12-31' 
		and membernetworksetlookup_nondv_05.from_date <> '2200-01-01'
),
membernetworksetlookup_nondv_07 as
(
-- get attributes for each range  
select membernetworksetlookup_nondv_06.source,
       membernetworksetlookup_nondv_06.tenant_id,
       membernetworksetlookup_nondv_06.member_bk,
       membernetworksetlookup_nondv_06.group_id,
       membernetworksetlookup_nondv_06.subscriber_id,
       membernetworksetlookup_nondv_06.member_suffix,
       n.network_set_prefix,
       n.network_id,
       membernetworksetlookup_nondv_06.start_date,
       membernetworksetlookup_nondv_06.end_date,
       membernetworksetlookup_nondv_06.dss_record_source
from membernetworksetlookup_nondv_06 
	  inner join (select 
	                row_number () over (partition by n.source, n.member_bk, r.start_date order by n.network_set_seq_no) rownum,
	                r.start_date,
	                n.*
	              from membernetworksetlookup_nondv_06 r
	                   inner join membernetworksetlookup_nondv_02 n 
	                      on n.source = r.source
	                      and n.member_bk = r.member_bk
                where r.start_date between n.elig_eff_dt and n.elig_term_dt
	                    and r.start_date between n.plan_eff_dt and n.plan_term_dt
	 		                and r.start_date between n.network_set_eff_dt and n.network_set_term_dt
	            ) n
	  on n.source = membernetworksetlookup_nondv_06.source
		and n.member_bk = membernetworksetlookup_nondv_06.member_bk
		and n.start_date = membernetworksetlookup_nondv_06.start_date
		and rownum = 1
),
membernetworksetlookup_nondv_08 as
(
-- remove gap rows
select membernetworksetlookup_nondv_07.source,
       membernetworksetlookup_nondv_07.tenant_id,
       membernetworksetlookup_nondv_07.member_bk,
       membernetworksetlookup_nondv_07.group_id,
       membernetworksetlookup_nondv_07.subscriber_id,
       membernetworksetlookup_nondv_07.member_suffix,
       membernetworksetlookup_nondv_07.network_set_prefix,
       membernetworksetlookup_nondv_07.network_id,
       membernetworksetlookup_nondv_07.start_date,
       membernetworksetlookup_nondv_07.end_date,
       membernetworksetlookup_nondv_07.dss_record_source
from membernetworksetlookup_nondv_07
where network_set_prefix is not null and network_id is not null
)
,
membernetworksetlookup_nondv_09 as
(
-- get member business keys for each range
select r.source,
       r.tenant_id,
       r.member_bk,
       grgr.group_id group_id,
       sbsb.subscriber_identifier subscriber_id,
       meme.member_suffix member_suffix,
       r.network_set_prefix,
       r.network_id,
       r.start_date,
       r.end_date,
       r.dss_record_source
from membernetworksetlookup_nondv_08 r
     inner join {{ ref('current_member') }} meme
		    on r.member_bk = meme.member_bk
			  and r.source = meme.source
 	   inner join {{ ref('current_group') }} grgr
		    on meme.employer_group_bk = grgr.group_bk
			  and meme.source = grgr.source   
	   inner join {{ ref('current_subscriber') }} sbsb
		    on meme.subscriber_bk = sbsb.subscriber_bk
			  and sbsb.group_bk = grgr.group_bk
			  and meme.source = sbsb.source
        and sbsb.source = grgr.source
where meme.edp_record_status = 'Y'
      and grgr.edp_record_status = 'Y'
      and sbsb.edp_record_status = 'Y'
),
date_contig as
(
-- roll up date ranges
select a.source,
       a.tenant_id,
       a.member_bk,
       a.group_id,
       a.subscriber_id,
       a.member_suffix,
       a.network_set_prefix,
       a.network_id,
       a.start_date,
       a.end_date,
       1 as current_level,
       a.dss_record_source
from membernetworksetlookup_nondv_09 a
			left join membernetworksetlookup_nondv_09 b
				on a.source = b.source
					and a.member_bk = b.member_bk
					and a.network_id = b.network_id
					and a.network_set_prefix = b.network_set_prefix
					and dateadd(day,-1,a.start_date) = b.end_date
where b.source is null 
union all
select a.source,
       a.tenant_id,
       a.member_bk,
       a.group_id,
       a.subscriber_id,
       a.member_suffix,
       a.network_set_prefix,
       a.network_id,
       a.start_date,
	   b.end_date,
	   a.current_level + 1 current_level,
       a.dss_record_source
		from 
			date_contig a
			inner join membernetworksetlookup_nondv_09 b
				on a.source = b.source
					and a.member_bk = b.member_bk
					and a.network_id = b.network_id
					and a.network_set_prefix = b.network_set_prefix
					and dateadd(day,-1,b.start_date) = a.end_date
		where  a.current_level < 99 
)

select 
			date_contig.source
            ,date_contig.tenant_id
			,date_contig.member_bk
			,date_contig.group_id
			,date_contig.subscriber_id
			,date_contig.member_suffix
			,date_contig.network_set_prefix
			,date_contig.network_id
            ,date_contig.dss_record_source
            ,getdate() dss_create_time
			,getdate() dss_update_time
			,date_contig.start_date as dss_start_date
			,max(date_contig.end_date) as dss_end_date
            ,case when getdate() between dss_start_date and dss_end_date then '1' else '0' end is_current
            ,h_member.member_hk hk_member
            ,dim_network_set.hk_network_set
from date_contig
     inner join {{ ref('h_member') }} h_member
        on h_member.source = date_contig.source
        and h_member.member_bk = date_contig.member_bk
     inner join {{ ref('dim_network_set') }} dim_network_set
        on dim_network_set.network_set = date_contig.network_set_prefix
        and dim_network_set.network_id = date_contig.network_id
group by
			date_contig.source
            ,date_contig.tenant_id
			,date_contig.member_bk
			,date_contig.group_id
			,date_contig.subscriber_id
			,date_contig.member_suffix
			,date_contig.network_set_prefix
			,date_contig.network_id
            ,date_contig.dss_record_source
			,date_contig.start_date
            ,h_member.member_hk
            ,dim_network_set.hk_network_set