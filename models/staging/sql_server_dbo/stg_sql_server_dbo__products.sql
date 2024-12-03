{{ 
    config(
    materialized='incremental',
    unique_key = 'product_id'
    ) 
}}


WITH src_products AS (
    SELECT * 
    FROM {{ ref('products_snp') }}
    ),

silver_products AS (
    SELECT
        product_id
        , {{ set_positive_values('price')}} as price
        , lower(name) as description
        , inventory
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
        , DBT_SCD_ID 
        , DBT_UPDATED_AT
        , DBT_VALID_FROM
        , DBT_VALID_TO
    FROM src_products
    )

SELECT * FROM silver_products

{% if is_incremental() %}

    where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}