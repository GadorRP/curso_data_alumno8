WITH stg_promos as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__promos') }}
),

dim_promos as (
    SELECT
    promo_id
    , description
    , discount
    , status_id
    , is_deleted
    , date_load_utc
    FROM stg_promos
)

SELECT * FROM dim_promos