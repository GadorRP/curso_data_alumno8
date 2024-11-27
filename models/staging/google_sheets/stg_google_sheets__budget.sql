

WITH src_budget AS (
    SELECT * 
    FROM {{ source('google_sheets', 'budget') }}
    ),

renamed_casted AS (
    SELECT
        {{ dbt_utils.generate_surrogate_key(['_row','product_id','month']) }} as budget_id
        , product_id
        , {{ set_positive_values('quantity') }} as quantity
        , convert_timezone('UTC', month) as month_utc
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_budget
    )

SELECT * FROM renamed_casted