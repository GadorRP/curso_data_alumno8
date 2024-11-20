WITH src_orders AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

silver_status_orders AS (
    SELECT 
        distinct shipping_service as description
    FROM src_orders
    WHERE shipping_service != ''
    UNION ALL
    SELECT 'unassigned'
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(['description']) }} as shipping_service_id
    , description
FROM silver_status_orders