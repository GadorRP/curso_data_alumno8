{{ 
    config(
    materialized='view',
    ) 
}}

WITH fct_events as (
    SELECT   *
    FROM {{ ref('fct_events') }}
),

dim_users as (
    SELECT  *
    FROM {{ref('dim_users_current')}}
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
        rank_a.user_id
        , rank_a.session_id
        , rank_a.event_type AS first_event
        , rank_b.event_type AS second_event
        , DATEDIFF('minute', rank_a.created_at_utc, rank_b.created_at_utc) AS minutos_pasados
    FROM ranked_events rank_a
    JOIN ranked_events rank_b 
    ON rank_a.session_id = rank_b.session_id
        AND rank_a.event_rank = rank_b.event_rank - 1
),

difference_between_events as (
    SELECT 
        first_event
        , second_event
        , AVG(minutos_pasados) AS avg_minutes
    FROM event_durations
    GROUP BY first_event, second_event
)

select * from difference_between_events