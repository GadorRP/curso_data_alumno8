WITH base_orders AS (
    SELECT * 
    FROM {{ ref("base_sql_server_dbo__orders") }}
    ),

silver_order_bridge AS (
    SELECT 
        order_id
        , shipping_cost
        , order_cost
        , order_total
    FROM base_orders
)

select * from silver_order_bridge