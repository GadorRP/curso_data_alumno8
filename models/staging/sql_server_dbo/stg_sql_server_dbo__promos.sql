
WITH src_promo AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'promos') }}
    ),

silver_promo AS (
    SELECT
        lower(promo_id) as description
	    , coalesce(discount,0) as discount
	    , status
	    , _fivetran_deleted as is_deleted
        , convert_timezone('UTC', _fivetran_synced) as date_load_utc
    FROM src_promo
    union all
    SELECT 
        'sin_promo'
        , 0
        , 'active'
        , null
        , convert_timezone('UTC', current_timestamp()) --incluimos la fecha de carga del momento actual
    )

SELECT 
      {{ dbt_utils.generate_surrogate_key(['description']) }} as promo_id
    , description
    , discount
    , status
    , is_deleted
    , date_load_utc
FROM silver_promo