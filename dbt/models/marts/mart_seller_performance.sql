{#
  QUESTION: Which sellers sell the most, deliver on time, and keep customers happy?

  GRAIN: one row per seller.

  This is a DRILL-ACROSS: it combines two facts. Facts never join each other
  directly. Items are per item, but reviews and lateness are per ORDER, so joining
  fct_order_items straight to fct_orders would count a 3-item order's review 3 times.

  The drill-across recipe:
    1. roll fct_order_items up to one row per (seller, order)
    2. now both sides have order grain: attach fct_orders on the shared order_id
    3. roll up to one row per seller
#}

with seller_orders as (

    select
        seller_id,
        order_id,
        count(*)   as item_count,
        sum(price) as revenue

    from {{ ref('fct_order_items') }}
    where is_sale
    group by seller_id, order_id

),

orders as (

    select order_id, review_score, is_late, is_delivered, days_to_deliver
    from {{ ref('fct_orders') }}

),

sellers as (

    select * from {{ ref('dim_sellers') }}

),

-- Both sides are at order grain now, so this join can't fan out.
seller_order_facts as (

    select
        seller_orders.*,
        orders.review_score,
        orders.is_late,
        orders.is_delivered,
        orders.days_to_deliver

    from seller_orders
    inner join orders
        on seller_orders.order_id = orders.order_id

)

select
    sellers.seller_id,
    sellers.city,
    sellers.state,

    count(*)                         as order_count,
    sum(seller_order_facts.item_count) as item_count,
    sum(seller_order_facts.revenue)    as revenue,

    round(avg(seller_order_facts.review_score), 2) as avg_review_score,
    round(avg(seller_order_facts.days_to_deliver), 1) as avg_days_to_deliver,

    -- Late rate only counts delivered orders: an order in transit isn't late yet.
    round(
        avg(case when seller_order_facts.is_delivered
                 then cast(seller_order_facts.is_late as integer) end),
        3
    ) as late_delivery_rate

from seller_order_facts
inner join sellers
    on seller_order_facts.seller_id = sellers.seller_id

group by sellers.seller_id, sellers.city, sellers.state
