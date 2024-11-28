WITH stg_orders AS (
    SELECT * 
    FROM {{ ref("stg_sql_server_dbo__orders") }}
    ),

fct_order_bridge AS (
    SELECT 
        order_id
        , shipping_cost
        , order_cost
        , order_total
    FROM stg_orders
)

select * from fct_order_bridge