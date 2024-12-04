{{
    config(
        materialized='incremental',
        unique_key='event_id',
    )
}}

WITH src_events AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'events') }}
    ),

silver_events AS (
    SELECT 
        event_id
        , page_url
        , event_type
        , user_id
        , coalesce(product_id,'') as product_id
        , session_id
        , convert_timezone('UTC', created_at) as created_at_utc
        , coalesce(order_id,'') as order_id
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_events
    )

SELECT 
    event_id
        , page_url
        , event_type
        , user_id
        , {{replace_with('product_id', '','sin_producto',true)}} as product_id
        , session_id
        , created_at_utc
        , {{replace_with('order_id', '','sin pedido',true)}} as order_id
        , is_deleted
        , date_load_utc
FROM silver_events

{% if is_incremental() %}

    where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}