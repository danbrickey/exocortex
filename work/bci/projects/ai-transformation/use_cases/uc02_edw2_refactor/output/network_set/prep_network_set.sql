{{
    config(
        materialized='view'
    )
}}

with v_networkset_union as
(
select
    nwnw.tenant_id,
	nwst.source,
	nwst.network_set_prefix network_set,
	nwst.network_set_prefix network_code,
    case 
	   when lower(nwst.source) = 'legacy_facets'
		  then
	         nwnw.network_name 
	      else
			 pdpx.component_prefix_description
	end network_name,
	nwst.network_id network_id,
	'N' mdm_captured,
	nwst.edp_record_source as dss_record_source
from {{ ref('current_network_set') }} nwst
	join {{ ref('current_network') }} nwnw 
		on nwnw.network_bk = nwst.network_id
			and nwnw.source = nwst.source
    left join {{ ref('current_product_component') }} pdpx
        on nwst.network_set_prefix = pdpx.component_prefix_bk
            and lower(pdpx.component_type_bk) = 'nwst'
            and nwst.source = pdpx.source
where nwst.network_set_term_dt >= '01/01/2016'
	and nwst.network_set_prefix is not null
group by nwnw.tenant_id, nwst.source,nwst.network_set_prefix,    
         case 
	        when lower(nwst.source) = 'legacy_facets'
		       then
	              nwnw.network_name 
	         else
			      pdpx.component_prefix_description
	     end,nwst.network_id,nwst.edp_record_source
union all
select
    mdm.tenant_id as tenant_id,
	lower(source_system) as source,
	facets_network_set as network_set,
	network_code as network_code, 
	network_name as network_name,
	facets_nwnw_id as network_id,
	'Y' as mdm_captured,
	'bci-mdm.ref.providernetwork' as dss_record_source
from {{ ref('r_provider_network_mdm') }} mdm        
),
networkset_nondv_01 as
(
select
    v_networkset_union.tenant_id,
    v_networkset_union.source,
    v_networkset_union.network_code,
    v_networkset_union.network_name,
    v_networkset_union.network_id,
    v_networkset_union.network_set,
    v_networkset_union.mdm_captured,
    row_number () over (partition by network_set, network_id order by source desc) row_num,
    v_networkset_union.dss_record_source,
    getdate() dss_create_time,
    getdate() dss_update_time
from v_networkset_union
)

select
    networkset_nondv_01.tenant_id,
    networkset_nondv_01.source,
    networkset_nondv_01.network_code,
    networkset_nondv_01.network_name,
    networkset_nondv_01.network_id,
    networkset_nondv_01.network_set,
    networkset_nondv_01.mdm_captured,
    networkset_nondv_01.dss_record_source,
    dss_create_time,
    dss_update_time
from networkset_nondv_01
where row_num = 1
order by network_set, network_id 