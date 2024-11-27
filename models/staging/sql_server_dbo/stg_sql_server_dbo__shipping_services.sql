WITH src_orders AS (
    SELECT *
    FROM {{ ref("base_sql_server_dbo__orders") }}
    ),

silver_status_orders AS (
    SELECT 
        distinct shipping_service as description
    FROM src_orders
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(['description']) }} as shipping_service_id
    , description
FROM silver_status_orders