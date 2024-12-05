{{ 
    config(
    materialized='incremental',
    unique_key = 'DBT_SCD_ID'
    ) 
}}

WITH src_users AS (
    SELECT * 
    FROM {{ ref('users_snp') }}
    ),

silver_users AS (
    SELECT
          user_id
        , convert_timezone('UTC', updated_at) as updated_at_utc
        , address_id
        , lower(last_name) as last_name
        , convert_timezone('UTC', created_at) as created_at_utc
        , phone_number
        , lower(first_name) as first_name
        , email
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
        , DBT_SCD_ID 
        , DBT_UPDATED_AT
        , DBT_VALID_FROM
        , DBT_VALID_TO
    FROM src_users
    
    )

SELECT * FROM silver_users

{% if is_incremental() %}

    where DBT_UPDATED_AT > (select max(DBT_UPDATED_AT) from {{ this }} )

{% endif %}