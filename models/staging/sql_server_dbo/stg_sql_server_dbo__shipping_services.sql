WITH src_orders AS (
    SELECT *
    FROM {{ ref("base_sql_server_dbo__orders") }}
    ),

shipping_services AS (
    SELECT 
        distinct shipping_service as description
    FROM src_orders
    ),

silver_shipping_services as (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['description']) }} as shipping_service_id
        , description as name
    FROM shipping_services
    
)

SELECT * FROM silver_shipping_services