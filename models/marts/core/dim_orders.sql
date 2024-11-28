WITH stg_orders as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

stg_status_orders as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__status_orders') }}
),

dim_orders as (
    SELECT
        order_id
        , shipping_service_id
        , address_id
        , created_at_utc
        , promo_id
        , user_id
        , estimated_delivery_at_utc
        , delivered_at_utc
        , tracking_id
        , description as status_order
        , is_deleted
        , date_load_utc
    FROM stg_orders ord
    JOIN stg_status_orders status ON
    ord.status_id = status.status_id
)

SELECT * FROM dim_orders