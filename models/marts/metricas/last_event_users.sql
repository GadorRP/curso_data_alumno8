WITH fct_events as (
    SELECT   *
    FROM {{ ref('fct_events') }}
),

dim_users as (
    SELECT  *
    FROM {{ref('dim_users')}}
),

ranked_events AS (
    select 
        session_id
        , user_id
        , event_type
        , page_url
        , created_at_utc
        , ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY created_at_utc ) AS event_rank
    from fct_events
),

event_durations AS (
    SELECT 
        a.USER_ID,
        a.SESSION_ID,
        a.EVENT_TYPE AS event_start,
        b.EVENT_TYPE AS event_end,
        DATEDIFF('MINUTE', a.CREATED_AT_UTC, b.CREATED_AT_UTC) AS time_difference_seconds
    FROM ranked_events a
    JOIN ranked_events b
        ON a.USER_ID = b.USER_ID 
        AND a.SESSION_ID = b.SESSION_ID
        AND a.event_rank = b.event_rank - 1
),

last_event_users as (
    SELECT 
        event_start,
        event_end,
        AVG(time_difference_seconds) AS avg_time_seconds
    FROM event_durations
    GROUP BY event_start, event_end
)

select * from last_event_users