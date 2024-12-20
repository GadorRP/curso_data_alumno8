{{
    config(
        materialized='incremental',
        unique_key='order_id',
    )
}}

WITH src_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

silver_orders AS (
    SELECT
        order_id
        , {{ replace_with('shipping_service', '', 'unassigned', true)}} as shipping_service
        , shipping_cost
        , address_id
        , convert_timezone('UTC',created_at) as created_at_utc
        , lower({{replace_with('promo_id','','sin_promo',true)}}) AS promo_id
        , convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at_utc
        , order_cost
        , user_id
        , order_total
        , convert_timezone('UTC', delivered_at) as delivered_at_utc
        , {{replace_with('tracking_id','','unnasigned',true)}} as tracking_id
        , status
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_orders
    ),

hash_orders AS (
    SELECT 
    order_id
        , shipping_service
        , shipping_cost
        , address_id
        , created_at_utc
        , {{ dbt_utils.generate_surrogate_key(['promo_id']) }} as promo_id
        , estimated_delivery_at_utc
        , order_cost
        , user_id
        , order_total
        , delivered_at_utc
        , tracking_id
        , status
        , is_deleted
        , date_load_utc
    FROM silver_orders
)

select * from hash_orders

{% if is_incremental() %}

    where date_load_utc >= (select max(date_load_utc) from {{ this }} )

{% endif %}