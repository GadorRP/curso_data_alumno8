WITH stg_orders as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

dim_orders as (
    SELECT
        order_id
        , shipping_service_id
        , address_id
        , created_at_utc
        , promo_id
        , estimated_delivery_at_utc
        , user_id
        , delivered_at_utc
        , tracking_id
        , status_id
        , is_deleted
        , date_load_utc
    FROM stg_orders
)

SELECT * FROM dim_orders