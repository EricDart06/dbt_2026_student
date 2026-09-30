-- GOLD. Run it: uv run dbt show -s q4_order_value_by_payment_gold
-- Question: what's the average order value (items + freight) for each payment type?
--
-- A DRILL-ACROSS: two facts, combined. Facts never join each other directly, so
-- first bring payments to order grain (one row per order + payment type), THEN join
-- fct_orders, which is already one row per order, on the shared order_id.

with order_payment_types as (

    select distinct order_id, payment_type
    from {{ ref('fct_order_payments') }}

)

select
    pt.payment_type,
    count(*)                         as order_count,
    round(avg(o.order_total), 2)     as avg_order_value

from order_payment_types as pt
join {{ ref('fct_orders') }} as o
    on pt.order_id = o.order_id

where o.is_sale
  and o.item_count > 0
group by pt.payment_type
order by avg_order_value desc
