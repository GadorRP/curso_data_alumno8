{{ 
    config(
    materialized='incremental',
    unique_key = 'user_id'
    ) 
}}


WITH stg_users as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__users') }}
),

dim_users_historical as (
    SELECT
        user_id
        , updated_at_utc
        , address_id
        , last_name
        , created_at_utc
        , phone_number
        , first_name
        , email
        , is_deleted
        , date_load_utc
        , DBT_UPDATED_AT as updated_at
        , DBT_VALID_FROM as valid_from
        , DBT_VALID_TO as valid_to
    FROM stg_users
)

SELECT * FROM dim_users_historical

{% if is_incremental() %}

    where date_load_utc > (select max(date_load_utc) from {{ this }} )

{% endif %}