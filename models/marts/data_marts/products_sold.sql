{{ 
    config(
    materialized='view',
    ) 
}}

-- vista que muestra las ventas de los productos,
-- el dinero obtenido por cada uno de ellos

WITH dim_products as (
    SELECT 
        *
    FROM {{ ref('dim_products') }}
),

fct_products_in_order as (
    SELECT 
        *
    FROM {{ ref('fct_products_in_order')}}
),

products_sold as (
    SELECT 
        pro.description as product
        , max(price) as price
        , COUNT(*) as num_orders
        , SUM(quantity) as units_sold
        , precio * unidades_vendidas as profits
        , max(price_category) as price_category
    FROM fct_products_in_order ord 
    JOIN dim_products pro
    ON ord.product_id = pro.product_id
    GROUP BY pro.description
    ORDER BY 4 DESC
)

SELECT * FROM products_sold