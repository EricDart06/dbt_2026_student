{#
  GRAIN: one row per order.

  Items, payments and reviews are all "many per order", so each is rolled up to one
  row per order BEFORE joining. Join them raw and you get a FAN-OUT: an order with
  3 items and 2 payments turns into 6 rows, and every sum is wrong.

  ROLE-PLAYING DATES: purchase_date, delivered_date and estimated_delivery_date all
  join to the same dim_date. One dimension, three roles.

  order_id is a DEGENERATE DIMENSION: an identifier with no dimension table behind
  it. fct_order_items and fct_order_payments carry it too. That lets you line the
  facts up at order grain later, but facts never join each other directly: roll
  each one up to the same grain first (see mart_seller_performance).
#}

with orders as (

    select * from {{ ref('stg_orders') }}

),

customers as (

    select customer_id, customer_unique_id from {{ ref('stg_customers') }}

),

items_per_order as (

    select
        order_id,
        count(*)           as item_count,
        sum(price)         as items_subtotal,
        sum(freight_value) as freight_total

    from {{ ref('stg_order_items') }}
    group by order_id

),

payments_per_order as (

    select
        order_id,
        count(*)    as payment_count,
        sum(amount) as payment_total

    from {{ ref('stg_order_payments') }}
    group by order_id

),

reviews as (

    -- Already one row per order (see stg_order_reviews), so no roll-up needed.
    select order_id, review_score from {{ ref('stg_order_reviews') }}

)

select
    orders.order_id,
    customers.customer_unique_id,
    orders.order_status,
    orders.is_sale,

    -- dates (each one joins to dim_date.date_day)
    orders.purchase_date,
    orders.delivered_date,
    orders.estimated_delivery_date,

    -- measures. Orders that were canceled before any item was added have no items:
    -- count them as 0, not null.
    coalesce(items_per_order.item_count, 0)     as item_count,
    coalesce(items_per_order.items_subtotal, 0) as items_subtotal,
    coalesce(items_per_order.freight_total, 0)  as freight_total,
    coalesce(items_per_order.items_subtotal, 0)
        + coalesce(items_per_order.freight_total, 0) as order_total,
    coalesce(payments_per_order.payment_count, 0)  as payment_count,
    coalesce(payments_per_order.payment_total, 0)  as payment_total,
    reviews.review_score,

    -- delivery performance (null until the order is delivered)
    datediff(day, orders.purchase_date, orders.delivered_date)    as days_to_deliver,
    orders.delivered_date > orders.estimated_delivery_date        as is_late,
    orders.is_delivered

from orders
inner join customers
    on orders.customer_id = customers.customer_id
left join items_per_order
    on orders.order_id = items_per_order.order_id
left join payments_per_order
    on orders.order_id = payments_per_order.order_id
left join reviews
    on orders.order_id = reviews.order_id
