WITH stg_addresses as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__addresses') }}
),

dim_addresses as (
    SELECT
        address_id
        , zipcode
        , country
        , address
        , state
        , is_deleted
        , date_load_utc
    FROM stg_addresses
)

SELECT * FROM dim_addresses