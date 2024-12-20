{{ 
    config(
    materialized='incremental',
    unique_key = 'order_id'
    ) 
}}


WITH base_orders AS (
    SELECT * 
    FROM {{ ref("base_sql_server_dbo__orders") }}
    ),

silver_orders AS (
    SELECT 
    order_id
        , {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} as shipping_service_id
        , address_id
        , created_at_utc
        , promo_id
        , shipping_cost
        , order_cost
        , order_total
        , estimated_delivery_at_utc
        , user_id
        , delivered_at_utc
        , tracking_id
        , status
        , is_deleted
        , date_load_utc
    FROM base_orders
)

select * from silver_orders

{% if is_incremental() %}

    where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}