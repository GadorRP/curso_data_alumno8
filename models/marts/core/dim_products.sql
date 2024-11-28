WITH stg_products as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__products') }}
),

dim_products as (
    SELECT
        product_id
        , price
        , description
        , inventory
        , is_deleted
        , date_load_utc
    FROM stg_products
)

SELECT * FROM dim_products