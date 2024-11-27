WITH stg_event as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__events') }}
),

stg_event_type as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__event_type')}}
),

stg_users as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__users')}}
),

first_last_event_time AS (
    select 
        session_id
        , user_id
        , min(created_at_utc) as first_event_time_utc
        , max(created_at_utc) as last_event_time_utc
    from stg_event
    group by session_id, user_id
),


events_int as (
    select 
    session_id
    , user_id
    , description as event_type
    , CASE WHEN description = 'checkout' then 1
        ELSE 0 END as checkout 
    , CASE WHEN description = 'package_shipped' then 1
        ELSE 0 END as package_shipped
    , CASE WHEN description = 'add_to_cart' then 1
        ELSE 0 END as add_to_cart
    , CASE WHEN description = 'page_view' then 1
        ELSE 0 END as page_view 
    from stg_event ev
    join stg_event_type et
    on ev.event_type_id = et.event_type_id
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
    join stg_users users
    on users.user_id = num.user_id
)

select * from user_events_sessions
    
 
