WITH stg_order_items as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__order_items') }}
),

fct_order_items as (
    SELECT
        order_item_id
        , order_id
        , product_id
        , quantity
        , is_deleted
        , date_load_utc
    FROM stg_order_items
)

SELECT * FROM fct_order_items