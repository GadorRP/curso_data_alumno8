{% snapshot products_snp %}

{{
    config(
        target_schema='snapshots',
        unique_key='product_id',
        strategy='timestamp',
        updated_at='_fivetran_synced'
    )
}}

SELECT
    product_id
    , name
    , price
    , inventory
    , _fivetran_deleted 
    , _fivetran_synced
FROM {{ source('sql_server_dbo', 'products') }}

{% endsnapshot %}