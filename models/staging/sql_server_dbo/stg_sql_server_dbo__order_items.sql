WITH src_order_items AS (
    SELECT *
    FROM {{ source('sql_server_dbo', 'order_items') }}
    ),

silver_order_items AS (
    SELECT 
        {{ dbt_utils.generate_surrogate_key(['order_id','product_id']) }} as order_item_id
        , order_id
        , product_id
        , CASE WHEN quantity < 0 THEN ABS(quantity)
            ELSE quantity END as quantity
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_order_items
    )

SELECT * FROM silver_order_items