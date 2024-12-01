WITH stg_products as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__products') }}
),

dim_products as (
    SELECT
        product_id
        , description
        , price
        , CASE WHEN price < 30 THEN 'low'
            WHEN price < 70 THEN 'medium'
            ELSE 'high' END AS price_category 
        , inventory
        , CASE WHEN inventory < 30 THEN 'low'
            WHEN inventory < 70 THEN 'medium'
            ELSE 'high' END AS inventory_category
        , is_deleted
        , date_load_utc
    FROM stg_products
)

SELECT * FROM dim_products