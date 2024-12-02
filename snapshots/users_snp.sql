{% snapshot users_snp %}

{{
    config(
        target_schema='snapshots',
        unique_key='user_id',
        strategy='timestamp',
        updated_at='_fivetran_synced'
    )
}}

SELECT
    user_id
    , updated_at
    , address_id
    , last_name
    , created_at
    , phone_number
    , first_name 
    , email
    , _fivetran_deleted
    , _fivetran_synced
FROM {{ source('sql_server_dbo', 'users') }}

{% endsnapshot %}