WITH src_events AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'events') }}
    ),

silver_event_type AS (
    SELECT 
        distinct event_type as description
    FROM src_events
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(['description']) }} as event_type_id
    , description
FROM silver_event_type