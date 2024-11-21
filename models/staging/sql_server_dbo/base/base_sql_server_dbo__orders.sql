WITH src_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

silver_orders AS (
    SELECT
        order_id
        , CASE WHEN shipping_service = '' THEN 'unassigned'
            WHEN shipping_service = null THEN 'unassigned'
            ELSE shipping_service END AS shipping_service
        , shipping_cost
        , address_id
        , convert_timezone('UTC',created_at) as created_at_utc
        , CASE WHEN promo_id != null THEN promo_id
                ELSE 'sin_promo' END AS promo_id
        , convert_timezone('UTC', estimated_delivery_at) as estimated_delivery_at_utc
        , order_cost
        , user_id
        , order_total
        , convert_timezone('UTC', delivered_at) as delivered_at_utc
        , CASE WHEN tracking_id = '' THEN null
                ELSE tracking_id END AS tracking_id
        , status
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_orders
    ),

hash_orders AS (
    SELECT 
    order_id
        , {{ dbt_utils.generate_surrogate_key(['shipping_service']) }} as shipping_service_id
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
        , {{ dbt_utils.generate_surrogate_key(['status']) }} as status_id
        , is_deleted
        , date_load_utc
    FROM silver_orders
)

select * from hash_orders
