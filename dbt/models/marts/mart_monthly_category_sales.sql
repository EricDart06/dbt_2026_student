{#
  QUESTION: Which product categories earn the most each month?

  GRAIN: one row per (month, category). Only orders that count as a sale
  (is_sale; defined once, in stg_orders).
#}

with items as (

    select * from {{ ref('fct_order_items') }}
    where is_sale

),

products as (

    select product_id, category_name from {{ ref('dim_products') }}

),

dates as (

    select date_day, year_month from {{ ref('dim_date') }}

)

select
    dates.year_month,
    products.category_name,

    count(distinct items.order_id) as order_count,
    count(*)                       as item_count,
    sum(items.price)               as revenue,
    sum(items.freight_value)       as freight,
    round(sum(items.price) / count(*), 2) as avg_item_price

from items
inner join products
    on items.product_id = products.product_id
inner join dates
    on items.purchase_date = dates.date_day

group by dates.year_month, products.category_name
