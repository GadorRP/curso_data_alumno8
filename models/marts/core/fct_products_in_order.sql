{{ 
    config(
    materialized='incremental',
    unique_key = 'order_item_id'
    ) 
}}


WITH stg_orders AS (
    SELECT * 
    FROM {{ ref("stg_sql_server_dbo__orders") }}
    ),

stg_order_items AS (
    SELECT *
    FROM {{ ref("stg_sql_server_dbo__order_items")}}
),


fct_products_in_order AS (
    SELECT 
        order_item_id
        , ord.order_id
        , product_id
        , quantity
        -- orders as generate dimension
        , promo_id
        , user_id
        , shipping_service_id
        , address_id
        , created_at_utc
        , tracking_id as delivery_id
        , status
        , order_shipping_cost
        , order_cost
        , order_total
        , itm.is_deleted
        , itm.date_load_utc
    FROM stg_orders ord
    JOIN stg_order_items itm 
    ON ord.order_id = itm.order_id
)

select * from fct_products_in_order

{% if is_incremental() %}

    where date_load_utc >= (select max(date_load_utc) from {{ this }} )

{% endif %}