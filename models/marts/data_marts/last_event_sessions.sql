{{ 
    config(
    materialized='view',
    ) 
}}


{% set event_types = obtener_valores(ref('fct_events'),'event_type') %}

WITH fct_events as (
    SELECT   *
    FROM {{ ref('fct_events') }}
),


total_sessions as (
    SELECT 
       COUNT(distinct session_id) as total_sessions
    FROM fct_events
),

-- enumeramos dentro de cada sesion los eventos que se han producido
ranked_events AS (
    select 
        session_id
        , user_id
        , event_type
        , page_url
        , created_at_utc
        , ROW_NUMBER() OVER (PARTITION BY session_id ORDER BY created_at_utc DESC) AS event_rank
    from fct_events
),

last_event_users_count as (
    SELECT 
        event_type
        , {%- for event_type in event_types   %}
            CASE WHEN event_type = '{{event_type}}' THEN 1 ELSE NULL END as {{event_type}}
            {%- if not loop.last %},{% endif -%}
         {% endfor %}
    FROM ranked_events
    WHERE event_rank = 1
),

last_event_users_grouped as (
    SELECT 
        sum(page_view) as last_event_page_view
        , sum(add_to_cart) as last_event_add_to_cart
        , sum(checkout) as last_event_checkout
        , sum(package_shipped) as last_event_package_shipped
    FROM last_event_users_count
),

conversion_rates as (
    SELECT 
        total_sessions
        , last_event_page_view
        , ROUND((last_event_page_view / total_sessions) * 100, 2) 
            AS percentage_end_page_view
        , last_event_add_to_cart
        , ROUND((last_event_add_to_cart / total_sessions) * 100, 2) 
            AS percentage_end_add_cart
        , last_event_checkout
        , ROUND((last_event_checkout / total_sessions) * 100, 2) 
            AS percentage_end_checkout
        , last_event_package_shipped
        , ROUND((last_event_package_shipped / total_sessions) * 100, 2) 
            AS percentage_end_package_shipped
    FROM last_event_users_grouped
    FULL JOIN total_sessions
)

select * from conversion_rates