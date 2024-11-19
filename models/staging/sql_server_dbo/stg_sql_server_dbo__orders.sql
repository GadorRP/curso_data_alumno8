WITH src_orders AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'orders') }}
    ),

silver_orders AS (
    SELECT
        address_id
        ,  lower(zipcode) as zipcode
        ,  lower(country) as country
        ,  lower(address) as address
        ,  lower(state) as state
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_orders
    )

SELECT * FROM silver_orders