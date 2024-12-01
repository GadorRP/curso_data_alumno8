{{ 
    config(
    materialized='view',
    ) 
}}


{% set event_types = obtener_valores(ref('stg_sql_server_dbo__events'),'event_type') %}

WITH fct_events as (
    SELECT   *
    FROM {{ ref('fct_events') }}
),

dim_users as (
    SELECT  *
    FROM {{ref('dim_users')}}
),

-- enumeramos dentro de cada sesion los eventos que se han producido
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

last_event_users AS (
    SELECT 
        user_id
        , session_id
        , event_type
        , max(event_rank) as max_event
    FROM ranked_events eve
    GROUP BY user_id, session_id, event_type
),

last_event_users_count as (
    SELECT 
        event_type
        , max_event
        , {%- for event_type in event_types   %}
            CASE WHEN event_type = '{{event_type}}' THEN 1 ELSE 0 END as {{event_type}}
            {%- if not loop.last %},{% endif -%}
         {% endfor %}
        
    FROM last_event_users
),

last_event_users_grouped as (
    SELECT 
        sum(page_view) as users_last_event_page_view
        , sum(add_to_cart) as users_last_event_add_to_cart
        , sum(checkout) as users_last_event_checkout
        , sum(package_shipped) as users_last_event_package_shipped
    FROM last_event_users_count
),

conversion_rates as (
    SELECT 
        users_last_event_page_view
        , ROUND((users_last_event_add_to_cart * 1.0 / users_last_event_page_view) * 100, 2) 
            AS conversion_page_to_cart
        , users_last_event_add_to_cart
        , ROUND((users_last_event_checkout * 1.0 / users_last_event_add_to_cart) * 100, 2) 
            AS conversion_cart_to_checkout
        , users_last_event_checkout
        , ROUND((users_last_event_package_shipped * 1.0 / users_last_event_checkout) * 100, 2) 
            AS conversion_checkout_to_shipped
        , users_last_event_package_shipped
    FROM last_event_users_grouped
)


select * from conversion_rates