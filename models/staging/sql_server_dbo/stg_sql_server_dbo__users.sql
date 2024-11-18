WITH src_users AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'users') }}
    ),

silver_users AS (
    SELECT
          user_id
        , convert_timezone('UTC', updated_at) as updated_at_utc
        , address_id
        , last_name
        , convert_timezone('UTC', created_at) as created_at_utc
        , phone_number
        , first_name
        , email
        , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_users
    
    )

SELECT * FROM silver_users