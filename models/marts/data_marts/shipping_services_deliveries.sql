{{ 
    config(
    materialized='view',
    ) 
}}

-- vista que muestra si las entregas realizadas se han hecho a tiempo,
-- ademas de mostrar el promedio de dias de retraso  o adelanto 
-- desglosando por shipping service

WITH dim_shipping_services as (
    SELECT   *
    FROM {{ ref('dim_shipping_services') }}
),

dim_deliveries as (
    SELECT *
    FROM {{ ref('dim_deliveries')}}
),

fct_products_in_order_grouped as (
    SELECT 
        order_id
        , shipping_service_id
        , delivery_id
    FROM {{ ref('fct_products_in_order')}}
    GROUP BY order_id, shipping_service_id,delivery_id
),

calculate_deliverys as (
    SELECT 
        shipping_service_id
        , CASE WHEN delivery_status = 'day_estimated' then 1
        ELSE 0 END as deliverys_in_day 
        , CASE WHEN delivery_status = 'before_estimated' then 1
            ELSE 0 END as deliverys_before
        , CASE WHEN delivery_status = 'after_estimated' then 1
            ELSE 0 END as deliverys_after 
        , CASE WHEN delivery_status = 'before_estimated' then days_variation_from_estimated
            ELSE NULL END as days_before
        , CASE WHEN delivery_status = 'after_estimated' then days_variation_from_estimated
            ELSE NULL END as days_after
    FROM fct_products_in_order_grouped ord 
    JOIN dim_deliveries del
    ON ord.delivery_id = del.delivery_id
    WHERE delivery_status != 'not_delivered'
),

shipping_services_deliveries as (
    SELECT 
        name as shipping_service
        , SUM(deliverys_in_day) as deliveries_in_day
        , SUM(deliverys_before) as deliveries_before_estimated
        , SUM(deliverys_after) as deliveries_after_estimated
        , AVG(days_after) as average_days_after
        , AVG(days_before) as average_days_before
    FROM calculate_deliverys cal
    JOIN dim_shipping_services shi
    ON cal.shipping_service_id = shi.shipping_service_id
    GROUP BY shipping_service
)

SELECT * FROM shipping_services_deliveries