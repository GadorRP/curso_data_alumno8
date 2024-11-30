WITH stg_orders as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

stg_shipping_services as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__shipping_services') }}
),


calculo_envio as (
    SELECT 
        order_id
        , TIMESTAMPDIFF(DAY,delivered_at_utc,estimated_delivery_at_utc) as tiempo_delay
    FROM stg_orders ord
    WHERE tracking_id != 'unnasigned'
),

dim_orders as (
    SELECT
        ord.order_id
        , created_at_utc
        , promo_id
        , user_id
        , tracking_id
        , address_id
        , name as shipping_service
        , estimated_delivery_at_utc
        , delivered_at_utc
        , abs(tiempo_delay) as delivery_variation
        , CASE WHEN tiempo_delay < 0 THEN 'adelantado'
            WHEN tiempo_delay = 0 THEN 'mismo_dia'
            WHEN tiempo_delay IS NULL THEN 'no entregado'
            ELSE 'retrasado' END as delivery_status
        , status
        , is_deleted
        , date_load_utc
    FROM calculo_envio env 
    JOIN stg_orders ord ON 
    env.order_id = ord.order_id
    JOIN stg_shipping_services ss ON
    ord.shipping_service_id = ss.shipping_service_id
)

SELECT * FROM dim_orders