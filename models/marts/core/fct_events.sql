WITH stg_events as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__events') }}
),

stg_event_type as (
    SELECT 
        *
    FROM {{ ref('stg_sql_server_dbo__event_type')}}
),

fct_events as (
    SELECT
        event_id
        , page_url
        , evt.description as evento
        , user_id
        , product_id
        , session_id
        , created_at_utc
        , order_id
        , ev.is_deleted
        , ev.date_load_utc
    FROM stg_events ev
    JOIN stg_event_type evt 
    ON ev.event_type_id = evt.event_type_id   
)

SELECT * FROM fct_events