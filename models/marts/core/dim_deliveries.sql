{{ 
    config(
    materialized='incremental',
    unique_key = 'delivery_id'
    ) 
}}


WITH stg_orders as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__orders') }}
),

calculo_envio as (
    SELECT 
        tracking_id
        , TIMESTAMPDIFF(DAY,delivered_at_utc,estimated_delivery_at_utc) as tiempo_delay
    FROM stg_orders ord
    WHERE status != 'preparing'
),

dim_deliverys as (
    SELECT
        ord.tracking_id as delivery_id
        , estimated_delivery_at_utc
        , delivered_at_utc
        , abs(tiempo_delay) as days_variation_from_estimated
        , CASE WHEN tiempo_delay < 0 THEN 'before_estimated'
            WHEN tiempo_delay = 0 THEN 'day_estimated'
            WHEN tiempo_delay IS NULL THEN 'not_delivered'
            ELSE 'after_estimated' END as delivery_status
        , is_deleted
        , date_load_utc
    FROM calculo_envio env 
    JOIN stg_orders ord ON 
    env.tracking_id = ord.tracking_id
)

SELECT * FROM dim_deliverys

{% if is_incremental() %}

    where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}

