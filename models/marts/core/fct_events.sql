{{ 
    config(
    materialized='incremental',
    unique_key = 'event_id'
    ) 
}}

WITH stg_events as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__events') }}
),


fct_events as (
    SELECT
        event_id
        , page_url
        , event_type
        , user_id
        , product_id
        , session_id
        , created_at_utc
        , order_id
        , ev.is_deleted
        , ev.date_load_utc
    FROM stg_events ev
)

SELECT * FROM fct_events

{% if is_incremental() %}

    where date_load_utc >= (select max(date_load_utc) from {{ this }} )

{% endif %}