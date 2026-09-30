-- SESSION 3: the BRONZE way.
-- Run it: uv run dbt show -s q1_top_categories_bronze --limit 5
-- Question: which 5 product categories earned the most in November 2017 (Black Friday)?
--
-- Straight from RAW, with the raw table and column names. You need four tables, and you have to know that canceled orders don't count, that the
-- category names are in Portuguese, and that some products have no category.

select
    coalesce(t.product_category_name_english, p.product_category_name, 'unknown') as category,
    sum(cast(i.price as decimal(10, 2))) as revenue

from {{ source('olist', 'order_items') }} as i
join {{ source('olist', 'orders') }}      as o on i.order_id = o.order_id
join {{ source('olist', 'products') }}    as p on i.product_id = p.product_id
left join {{ ref('product_category_name_translation') }} as t
    on p.product_category_name = t.product_category_name

where o.order_status not in ('canceled', 'unavailable')
  and cast(o.order_purchase_timestamp as timestamp) >= timestamp '2017-11-01'
  and cast(o.order_purchase_timestamp as timestamp) <  timestamp '2017-12-01'

group by 1
order by revenue desc
