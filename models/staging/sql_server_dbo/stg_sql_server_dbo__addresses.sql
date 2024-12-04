{{ 
    config(
    materialized='incremental',
    unique_key = 'address_id'
    ) 
}}

WITH src_addresses AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'addresses') }}
    ),

silver_addresses AS (
    SELECT
        address_id
        ,  zipcode
        ,  lower(country) as country
        ,  lower(address) as address
        ,  lower(state) as state
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_addresses
    )

SELECT * FROM silver_addresses

{% if is_incremental() %}

    where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}