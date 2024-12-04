WITH stg_shipping_services as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__shipping_services') }}
),


dim_shipping_services as (
    SELECT
        shipping_service_id
        , name
    FROM stg_shipping_services
)

SELECT * FROM dim_shipping_services