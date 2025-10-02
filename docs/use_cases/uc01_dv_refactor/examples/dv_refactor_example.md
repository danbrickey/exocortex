# Example Code Refactor - class entity

## Input Model

### Prior dbt model SQL

```sql
{{
    config(
        unique_key=''class_ik'',
        merge_exclude_columns = [''create_dtm'']
    )
}}

{% set schemas = ["legacy_bcifacets_hist","gemstone_facets_hist"] %}

{% for schema in schemas %}
    {%- if schema in ["legacy_bcifacets_hist"] -%}
        {%- set source_system = var(''legacy_source_system'') -%}
        {%- set ref_file = "stg_legacy_bcifacets_hist__dbo_cmc_cscs_class" -%}
    {%- else -%}
        {%- set source_system = var(''gemstone_source_system'') -%}
        {%- set ref_file = "stg_gemstone_facets_hist__dbo_cmc_cscs_class" -%}
    {%- endif -%}

    select
        {{ dbt_utils.generate_surrogate_key([''1'',"''" ~ source_system ~ "''",''src.grgr_ck'',''src.cscs_id'']) }}  as class_ik,
        1 as tenant_id,
        ''{{source_system}}'' as source_system,
        cast(src.grgr_ck as varchar) as employer_group_bk,
        src.cscs_id as class_bk,
        src.cscs_desc as class_desc,
        src.edp_start_dt,
        src.edp_end_dt,
        src.edp_record_status,
        lower(src.edp_record_source) as edp_record_source,
        getdate() as create_dtm,
        getdate() as update_dtm
    from {{ ref( ''enterprise_data_platform'',ref_file ) }} src
    {% if is_incremental() %}
        -- this filter will only be applied on an incremental run
        where src.edp_start_dt >= (select dateadd(dd,-3,coalesce(max(edp_start_dt), ''1900-01-01'')) from {{ this }})
    {% endif %}
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```

## Output Requirements

- Please format the output as below with all the output generated at once without pausing to prompt or confirm.

### Staging Rename Views

**stg_class_gemstone_facets_rename.sql**:

```sql
with

source as (
    select * from {{ ref(''enterprise_data_platform'', ''stg_gemstone_facets_hist__dbo_cmc_cscs_class'' ) }}
),

renamed as (
    select
        ''{{ var(''gemstone_source_system'') }}'' as source,
        ''1'' as tenant_id,
        grgr_ck AS group_bk,
        cscs_id AS class_bk,
        cscs_desc AS class_description,
        tpct_pfx AS service_conversion_prefix,
        cscs_opts AS class_options,
        plpb_pfx AS partner_bank_prefix,
        cscs_lock_token AS lock_token,
        atxr_source_id AS attachment_source_id,
        sys_last_upd_dtm AS last_update_datetime,
        sys_usus_id AS last_update_user_id,
        sys_dbuser_id AS last_update_db_user_id,
        cscs_sp_nwst_pfx_nvl AS secondary_network_set,
        cscs_sp_pdpd_id_nvl AS secondary_product,
        cdc_timestamp,
        edp_start_dt,
        edp_record_status,
        edp_record_source,
        cdc_operation
    from source
)

select * from renamed
```

**stg_class_legacy_facets_rename.sql**:

```sql
with

source as (
    select * from {{ ref(''enterprise_data_platform'', ''stg_legacy_bcifacets_hist__dbo_cmc_cscs_class'' ) }}
),

renamed as (
    select
        ''{{ var(''legacy_source_system'') }}'' as source,
        ''1'' as tenant_id,
        grgr_ck AS group_bk,
        cscs_id AS class_bk,
        cscs_desc AS class_description,
        tpct_pfx AS service_conversion_prefix,
        cscs_opts AS class_options,
        plpb_pfx AS partner_bank_prefix,
        cscs_lock_token AS lock_token,
        atxr_source_id AS attachment_source_id,
        sys_last_upd_dtm AS last_update_datetime,
        sys_usus_id AS last_update_user_id,
        sys_dbuser_id AS last_update_db_user_id,
        cscs_sp_nwst_pfx_nvl AS secondary_network_set,
        cscs_sp_pdpd_id_nvl AS secondary_product,
        cdc_timestamp,
        edp_start_dt,
        edp_record_status,
        edp_record_source,
        cdc_operation
    from source
)

select * from renamed
```

### Data Vault Staging Views

**stg_class_legacy_facets.sql**:

```sql
{%- set yaml_metadata -%}
source_model: "stg_class_legacy_facets_rename"
derived_columns:
  source: "''{{ var(''legacy_source_system'') }}''"
  load_datetime: "edp_start_dt"
  group_bk: "cast(group_bk as varchar)"
  employer_group_ik: "{{ dbt_utils.generate_surrogate_key([''tenant_id'',''source'',''group_bk'']) }}"
  class_ik: "{{ dbt_utils.generate_surrogate_key([''tenant_id'',''source'',''group_bk'',''class_bk'']) }}"
hashed_columns:
  class_group_hk: ["source","class_bk","group_bk"]
  group_hk: ["source","group_bk"]
  class_hk: ["source","class_bk"]
  class_hashdiff:
    is_hashdiff: true
    columns:
        - "source"
        - "tenant_id"
        - "load_datetime"
        - "group_bk"
        - "class_bk"
        - "class_description"
        - "service_conversion_prefix"
        - "class_options"
        - "partner_bank_prefix"
        - "lock_token"
        - "attachment_source_id"
        - "last_update_datetime"
        - "last_update_user_id"
        - "last_update_db_user_id"
        - "secondary_network_set"
        - "secondary_product"
        - "cdc_timestamp"
        - "edp_start_dt"
        - "edp_record_status"
        - "edp_record_source"
        - "cdc_operation"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict[''source_model''],
                     derived_columns=metadata_dict[''derived_columns''],
                     null_columns=none,
                     hashed_columns=metadata_dict[''hashed_columns''],
                     ranked_columns=none) }}
```

**stg_class_gemstone_facets.sql**:

```sql
{%- set yaml_metadata -%}
source_model: "stg_class_gemstone_facets_rename"
derived_columns:
  load_datetime: "edp_start_dt"
  group_bk: "cast(group_bk as varchar)"
  employer_group_ik: "{{ dbt_utils.generate_surrogate_key([''tenant_id'',''source'',''group_bk'']) }}"
  class_ik: "{{ dbt_utils.generate_surrogate_key([''tenant_id'',''source'',''group_bk'',''class_bk'']) }}"
hashed_columns:
  class_group_hk: ["source","class_bk","group_bk"]
  group_hk: ["source","group_bk"]
  class_hk: ["source","class_bk"]
  class_hashdiff:
    is_hashdiff: true
    columns:
        - "source"
        - "tenant_id"
        - "load_datetime"
        - "group_bk"
        - "class_bk"
        - "class_description"
        - "service_conversion_prefix"
        - "class_options"
        - "partner_bank_prefix"
        - "lock_token"
        - "attachment_source_id"
        - "last_update_datetime"
        - "last_update_user_id"
        - "last_update_db_user_id"
        - "secondary_network_set"
        - "secondary_product"
        - "cdc_timestamp"
        - "edp_start_dt"
        - "edp_record_status"
        - "edp_record_source"
        - "cdc_operation"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.stage(include_source_columns=true,
                     source_model=metadata_dict[''source_model''],
                     derived_columns=metadata_dict[''derived_columns''],
                     null_columns=none,
                     hashed_columns=metadata_dict[''hashed_columns''],
                     ranked_columns=none) }}
```

### Data Vault 2.0 Hubs

**h_class.sql**:

```sql
{%- set yaml_metadata -%}
source_model:
    - stg_class_gemstone_facets
    - stg_class_legacy_facets
src_pk:
    - class_hk
src_nk:
    - source
    - class_bk
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

**l_class_group.sql**:

```sql
{%- set yaml_metadata -%}
source_model:
    - stg_class_gemstone_facets
    - stg_class_legacy_facets
src_pk: class_group_hk
src_fk:
    - class_hk
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

### Data Vault 2.0 Satellites

**s_class_group_gemstone_facets.sql**:

```sql
{%- set yaml_metadata -%}
source_model: "stg_class_gemstone_facets"
src_pk: "class_group_hk"
src_hashdiff:
  source_column: "class_hashdiff"
  alias: "hashdiff"
src_payload:
    - "source"
    - "tenant_id"
    - "load_datetime"
    - "group_bk"
    - "class_bk"
    - "class_description"
    - "service_conversion_prefix"
    - "class_options"
    - "partner_bank_prefix"
    - "lock_token"
    - "attachment_source_id"
    - "last_update_datetime"
    - "last_update_user_id"
    - "last_update_db_user_id"
    - "secondary_network_set"
    - "secondary_product"
    - "cdc_timestamp"
    - "edp_start_dt"
    - "edp_record_status"
    - "edp_record_source"
    - "cdc_operation"
    - "employer_group_ik"
    - "class_ik"
src_ldts: "load_datetime"
src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"])   }}
```

**s_class_group_legacy_facets.sql**:

```sql
{%- set yaml_metadata -%}
source_model: "stg_class_legacy_facets"
src_pk: "class_group_hk"
src_hashdiff:
  source_column: "class_hashdiff"
  alias: "hashdiff"
src_payload:
    - "source"
    - "tenant_id"
    - "load_datetime"
    - "group_bk"
    - "class_bk"
    - "class_description"
    - "service_conversion_prefix"
    - "class_options"
    - "partner_bank_prefix"
    - "lock_token"
    - "attachment_source_id"
    - "last_update_datetime"
    - "last_update_user_id"
    - "last_update_db_user_id"
    - "secondary_network_set"
    - "secondary_product"
    - "cdc_timestamp"
    - "edp_start_dt"
    - "edp_record_status"
    - "edp_record_source"
    - "cdc_operation"
    - "employer_group_ik"
    - "class_ik"
src_ldts: "load_datetime"
src_source: "source"
{%- endset -%}

{% set metadata_dict = fromyaml(yaml_metadata) %}

{{ automate_dv.sat(src_pk=metadata_dict["src_pk"],
                   src_hashdiff=metadata_dict["src_hashdiff"],
                   src_payload=metadata_dict["src_payload"],
                   src_eff=metadata_dict["src_eff"],
                   src_ldts=metadata_dict["src_ldts"],
                   src_source=metadata_dict["src_source"],
                   source_model=metadata_dict["source_model"])   }}
```

### Current Views

**cv_class.sql**:

```sql
{{
    config(
        materialized=''view''
    )
}}

{% set source_systems = ["legacy_facets","gemstone_facets"]%}
        {%- set hub_model1 = "h_class" -%}
        {%- set hub_key1   = "class_hk" -%}
        {%- set hub_model2 = "h_group" -%}
        {%- set hub_key2   = "group_hk" -%}
        {%- set link_model = "l_class_group" -%}
        {%- set link_key   = "class_group_hk" -%}
{% for source_system in source_systems %}
    {%- if source_system in ["legacy_facets"] -%}
        {%- set sat_model = "s_class_group_gemstone_facets" -%}
    {%- else -%}
        {%- set sat_model = "s_class_group_legacy_facets" -%}
    {%- endif -%}

    select
        1 as tenant_id,
        hub1.source,
        hub2.group_bk,
        hub1.class_bk,
        sat.class_description,
        sat.service_conversion_prefix,
        sat.class_options,
        sat.partner_bank_prefix,
        sat.lock_token,
        sat.attachment_source_id,
        sat.last_update_datetime,
        sat.last_update_user_id,
        sat.last_update_db_user_id,
        sat.secondary_network_set,
        sat.secondary_product,
        sat.cdc_timestamp,
        sat.cdc_operation,
        sat.edp_start_dt,
        sat.edp_record_status,
        lower(sat.edp_record_source) as edp_record_source,
        sat.load_datetime
    from {{ ref(link_model) }} as link
        join {{ ref(hub_model1) }} as hub1
            on link.{{ hub_key1 }} = hub1.{{ hub_key1 }}
        join {{ ref(hub_model2) }} as hub2
            on link.{{ hub_key2 }} = hub2.{{ hub_key2 }}
        join {{ ref(sat_model) }} as sat
            on link.{{ link_key }} = sat.{{ link_key }}
        join (
            select {{link_key}}, max(load_datetime) max_load_datetime
            from {{ ref(sat_model) }}
            group by {{ link_key }}) as latest
            on sat.{{ link_key }} = latest.{{ link_key }}
                and sat.load_datetime = latest.max_load_datetime
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```

### Backwards Compatible Views

**bwd_class.sql**:

```sql
{{
    config(
        materialized=''view''
    )
}}

{% set source_systems = ["legacy_facets","gemstone_facets"]%}
        {%- set hub_model1 = "h_class" -%}
        {%- set hub_key1   = "class_hk" -%}
        {%- set hub_model2 = "h_group" -%}
        {%- set hub_key2   = "group_hk" -%}
        {%- set link_model = "l_class_group" -%}
        {%- set link_key   = "class_group_hk" -%}
{% for source_system in source_systems %}
    {%- if source_system in ["legacy_facets"] -%}
        {%- set sat_model = "s_class_group_gemstone_facets" -%}
    {%- else -%}
        {%- set sat_model = "s_class_group_legacy_facets" -%}
    {%- endif -%}

    select
        sat.class_ik,
        1 as tenant_id,
        hub1.source as source_system,
        hub2.group_bk employer_group_bk,
        hub1.class_bk,
        sat.class_description as class_desc,
        sat.edp_start_dt,
        sat.edp_record_status,
        lower(sat.edp_record_source) as edp_record_source,
        sat.load_datetime as create_dtm,
        sat.load_datetime as update_dtm
    from {{ ref(link_model) }} as link
        join {{ ref(hub_model1) }} as hub1
            on link.{{ hub_key1 }} = hub1.{{ hub_key1 }}
        join {{ ref(hub_model2) }} as hub2
            on link.{{ hub_key2 }} = hub2.{{ hub_key2 }}
        join {{ ref(sat_model) }} as sat
            on link.{{ link_key }} = sat.{{ link_key }}
        join (
            select {{link_key}}, max(load_datetime) max_load_datetime
            from {{ ref(sat_model) }}
            group by {{ link_key }}) as latest
            on sat.{{ link_key }} = latest.{{ link_key }}
                and sat.load_datetime = latest.max_load_datetime
    {% if not loop.last %}
        union all
    {% endif %}
{% endfor %}
```
