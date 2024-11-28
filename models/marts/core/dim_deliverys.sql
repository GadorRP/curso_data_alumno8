WITH stg_orders as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

dim_deliverys as (
    SELECT 
    tracking_id
    , estimated_delivery_at_utc
    , delivered_at_utc
    , TIMESTAMPDIFF(DAY,delivered_at_utc,estimated_delivery_at_utc) as tiempo_delay
    , status_id
    FROM stg_orders
    WHERE tracking_id != 'unnasigned'
)

select * from dim_deliverys