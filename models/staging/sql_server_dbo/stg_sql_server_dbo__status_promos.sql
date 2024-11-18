WITH src_promo AS (
    FROM {{ source('sql_server_dbo', 'promos') }}
    ),

silver_status_promos AS (
    SELECT 
        distinct status as description
    FROM src_promo
    )

SELECT 
    {{ dbt_utils.generate_surrogate_key(['description']) }} as status_id
    , description
FROM silver_status_promos