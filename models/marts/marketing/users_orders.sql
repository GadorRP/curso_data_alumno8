WITH dim_addresses as (
    SELECT   *
    FROM {{ ref('dim_addresses') }}
),

dim_users as (
    SELECT  *
    FROM {{ref('dim_users')}}
),

dim_promos as (
    SELECT  *
    FROM {{ref('dim_promos')}}
),

fct_products_in_order as (
    SELECT  *
    FROM {{ref('fct_products_in_order')}}
),

grouped_orders as (
    select 
        user_id
        , count(*) as total_number_orders
        , sum(quantity) as total_products
        , count(distinct product_id) as total_diff_products
        , sum(order_total) as total_order_cost
        , sum(order_shipping_cost) as total_shipping_cost
        , sum(discount) as total_discount
    from fct_products_in_order ord
    join dim_promos pro 
    on ord.promo_id = pro.promo_id
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
    from dim_users us
    join dim_addresses ad
    on us.address_id = ad.address_id
    join grouped_orders gord
    on us.user_id = gord.user_id
)

select * from users_orders