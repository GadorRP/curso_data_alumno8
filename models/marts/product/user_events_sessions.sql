{{ 
    config(
    materialized='view',
    ) 
}}

{% set event_types = obtener_valores(ref('stg_sql_server_dbo__events'),'event_type') %}

WITH dim_users as (
    SELECT  *
    FROM {{ref('dim_users')}}
),

fct_events as (
    SELECT *
    FROM {{ref('fct_events')}}
),


first_last_event_time AS (
    select 
        session_id
        , user_id
        , min(created_at_utc) as first_event_time_utc
        , max(created_at_utc) as last_event_time_utc
    from fct_events
    group by session_id, user_id
),


events_int as (
    select 
    session_id
    , user_id
    , event_type
    , {%- for event_type in event_types   %}
            CASE WHEN event_type = '{{event_type}}' THEN 1 ELSE 0 END as {{event_type}}
            {%- if not loop.last %},{% endif -%}
    {% endfor %}
    from fct_events ev
),

num_events as (
    SELECT
    session_id
    , user_id
    , sum(page_view) as page_view
    , sum(add_to_cart) as add_to_cart
    , sum(checkout) as checkout
    , sum(package_shipped) as package_shipped
    from events_int
    group by session_id, user_id
),

user_events_sessions as (
    select 
    num.session_id
    , num.user_id
    , first_name
    , email
    , first_event_time_utc
    , last_event_time_utc
    , TIMESTAMPDIFF(MINUTE, first_event_time_utc, last_event_time_utc) as session_lenght_minutes
    , page_view
    , add_to_cart
    , checkout
    , package_shipped
    from num_events num
    join first_last_event_time fl
    on fl.session_id = num.session_id
    join dim_users users
    on users.user_id = num.user_id
)

select * from user_events_sessions
    
 
