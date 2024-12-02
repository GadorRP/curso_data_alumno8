{{ 
    config(
    materialized='view',
    ) 
}}

-- vista que muestra las ventas de los productos,
-- y el pedido en el presupuesto por mes 

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

fct_budget as (
    SELECT
        *
    FROM {{ ref('fct_budget')}}
),

dim_date as (
    SELECT 
        *
    FROM {{ ref('dim_date')}}
),

filter_date as (
    SELECT 
        year_number
        , month_name
        , month_of_year
    FROM dim_date
    WHERE year_number = 2021 
    GROUP BY year_number, month_name, month_of_year
    ORDER BY 3
),

products_sold as (
    SELECT 
        year_number as year
        , month_name as month
        , month_of_year as month_number
        , pro.product_id as product_id
        , pro.description as producto
        , SUM(quantity) as unidades_vendidas
    FROM fct_products_in_order ord 
    JOIN dim_products pro
    ON ord.product_id = pro.product_id
    RIGHT JOIN filter_date dat 
    ON year(created_at_utc) = dat.year_number 
    AND month(created_at_utc) = dat.month_of_year 
    GROUP BY year, month, month_of_year,pro.product_id, pro.description
    ORDER BY 1,3
),

budget_inventory as (
    SELECT 
        year 
        , month
        , month_number
        , producto as product
        , unidades_vendidas as units_sold
        , quantity as units_budget
    FROM products_sold pro
    LEFT JOIN fct_budget bud 
    ON pro.year = year(bud.month_utc)
    AND pro.month_number = month(bud.month_utc)
    AND pro.product_id = bud.product_id
    ORDER BY 1,3,5
)

SELECT * FROM budget_inventory