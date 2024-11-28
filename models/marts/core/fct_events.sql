WITH stg_events as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__events') }}
),

fct_events as (
    SELECT
        event_id
        , page_url
        , event_type_id
        , user_id
        , product_id
        , session_id
        , created_at_utc
        , order_id
        , is_deleted
        , date_load_utc
    FROM stg_events
)

SELECT * FROM fct_events