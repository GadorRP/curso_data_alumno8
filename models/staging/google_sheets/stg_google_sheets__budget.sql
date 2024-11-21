

WITH src_budget AS (
    SELECT * 
    FROM {{ source('google_sheets', 'budget') }}
    ),

renamed_casted AS (
    SELECT
          _row as budget_id
        , product_id
        , CASE WHEN quantity = null THEN 0 
               WHEN quantity < 0 THEN abs(quantity)
               ELSE quantity END as quantity
        , convert_timezone('UTC', month) as month_utc
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_budget
    )

SELECT * FROM renamed_casted