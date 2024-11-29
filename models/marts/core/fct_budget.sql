{{ 
    config(
    materialized='incremental',
    unique_key = 'budget_id'
    ) 
}}

WITH stg_budget as (
    SELECT   *
    FROM {{ ref('stg_google_sheets__budget') }}
),

fct_budget as (
    SELECT
        budget_id
        , product_id
        , quantity
        , month_utc
        , date_load_utc
    FROM stg_budget
)

SELECT * FROM fct_budget

{% if is_incremental() %}

    where date_load_utc >= (select max(date_load_utc) from {{ this }} )

{% endif %}