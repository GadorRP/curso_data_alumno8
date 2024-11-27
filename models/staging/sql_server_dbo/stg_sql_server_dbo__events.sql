WITH src_events AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'events') }}
    ),

silver_events AS (
    SELECT 
        event_id
        , page_url
        , {{ dbt_utils.generate_surrogate_key(['event_type']) }} as event_type_id
        , user_id
        , CASE WHEN product_id = null THEN ''
            ELSE product_id END as product_id
        , session_id
        , convert_timezone('UTC', created_at) as created_at_utc
        , CASE WHEN order_id = null THEN ''
            ELSE order_id END as order_id
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_events
    )

SELECT * FROM silver_events