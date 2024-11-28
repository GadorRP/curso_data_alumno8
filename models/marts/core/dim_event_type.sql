WITH stg_event_type as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__event_type') }}
),

dim_event_type as (
    SELECT
        event_type_id
        , description
    FROM stg_event_type
)

SELECT * FROM dim_event_type