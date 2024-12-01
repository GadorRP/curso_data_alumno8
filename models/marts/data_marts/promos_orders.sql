{{ 
    config(
    materialized='view',
    ) 
}}

-- vista que muestra la eficiencia de las promociones y 
-- cual ha sido el porcentaje de descuento medio en los pedidos

WITH dim_promos as (
    SELECT 
        *
    FROM {{ ref('dim_promos') }}
),

fct_products_in_order as (
    SELECT 
        *
    FROM {{ ref('fct_products_in_order')}}
),

promos_orders as (
    SELECT 
        pro.description as promotion
        , max(pro.discount) as discount_applied
        , COUNT(*) as num_orders 
        , descuento_aplicado * num_pedidos as total_discounted
        , ROUND(AVG(order_cost),2) as avg_order_cost
        , ROUND(AVG(discount / order_cost * 100),2) as percentage_discount
    FROM fct_products_in_order ord 
    JOIN dim_promos pro
    ON ord.promo_id = pro.promo_id
    WHERE description != 'sin_promo'
    GROUP BY pro.description
)

SELECT * FROM promos_orders