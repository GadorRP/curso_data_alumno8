WITH src_products AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'products') }}
    ),

silver_products AS (
    SELECT
        product_id
        , price
        , lower(name) as description
        , inventory
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_products
    
    )

SELECT * FROM silver_products