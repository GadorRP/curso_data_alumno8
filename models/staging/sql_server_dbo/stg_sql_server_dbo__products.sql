WITH src_users AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'products') }}
    ),

silver_products AS (
    SELECT
        
    FROM src_products
    
    )

SELECT * FROM silver_products