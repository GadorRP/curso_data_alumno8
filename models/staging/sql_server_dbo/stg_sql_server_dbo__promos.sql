
WITH src_promo AS (
    SELECT * 
    FROM {{ source('sql_server_dbo', 'promos') }}
    ),

silver_promo AS (
    SELECT
        promo_id
	    , discount
	    , status
	    , _fivetran_deleted
        , _fivetran_synced as date_load
    FROM src_promo
    )

SELECT * FROM silver_promo