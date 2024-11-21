WITH stg_addresses as (
    SELECT   *
    FROM {{ ref('stg_sql_server_dbo__addresses') }}
),

stg_orders as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__orders')}}
),

stg_users as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__users')}}
),

stg_promos as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__promos')}}
),

stg_puente as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__order_bridge')}}
),

stg_order_items as (
    SELECT  *
    FROM {{ref('stg_sql_server_dbo__order_items')}}
),

grouped_orders as (
    select 
        user_id
        , count(*) as total_number_orders
        , sum(pu.order_total) as total_order_cost
        , sum(pu.shipping_cost) as total_shipping_cost
        , sum(discount) as total_discount
    from stg_orders ord
    join stg_puente pu 
    on ord.order_id = pu.order_id
    join stg_promos pro 
    on ord.promo_id = pro.promo_id
    group by user_id
),

grouped_order_items as (
    select 
        user_id
        , sum(quantity) as total_products
        , count(distinct product_id) as total_diff_products
    from stg_orders ord
    join stg_order_items ordi
    on ordi.order_id = ord.order_id
    group by user_id
),

users_orders as (
    select 
        us.user_id
        , us.first_name
        , us.last_name
        , us.email
        , us.phone_number
        , created_at_utc
        , updated_at_utc
        , ad.address
        , ad.zipcode
        , ad.state
        , ad.country
        , total_number_orders
        , total_order_cost
        , total_shipping_cost
        , total_discount
        , total_products
        , total_diff_products
    from stg_users us
    join stg_addresses ad
    on us.address_id = ad.address_id
    join grouped_orders gord
    on us.user_id = gord.user_id
    join grouped_order_items gitem
    on us.user_id = gitem.user_id
)

select * from users_orders