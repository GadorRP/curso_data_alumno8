WITH src_orders AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

silver_status_orders AS (
    SELECT 
        distinct status as description
    FROM src_orders
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(['description']) }} as status_id
    , description
FROM silver_status_orders