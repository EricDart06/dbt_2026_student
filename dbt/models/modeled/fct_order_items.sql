{#
  GRAIN: one row per item in an order.

  The most detailed fact: this is where "revenue by product category" or "by seller"
  comes from, because an order can mix products and sellers (1,278 orders have more
  than one seller).
#}

with items as (

    select * from {{ ref('stg_order_items') }}

),

orders as (

    select order_id, customer_id, purchase_date, order_status, is_sale from {{ ref('stg_orders') }}

),

customers as (

    select customer_id, customer_unique_id from {{ ref('stg_customers') }}

)

select
    items.order_item_key,
    items.order_id,       -- degenerate dimension: no dim_order table, just the id
    items.item_number,

    -- foreign keys to the dimensions
    items.product_id,
    items.seller_id,
    customers.customer_unique_id,
    orders.purchase_date,

    orders.order_status,
    orders.is_sale,

    -- measures
    items.price,
    items.freight_value,
    items.item_total

from items
inner join orders
    on items.order_id = orders.order_id
inner join customers
    on orders.customer_id = customers.customer_id
