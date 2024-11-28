WITH stg_users as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__users') }}
),

dim_users as (
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
    FROM stg_users
)

SELECT * FROM dim_users