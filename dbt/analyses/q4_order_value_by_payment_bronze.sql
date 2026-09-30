-- BRONZE. Run it: uv run dbt show -s q4_order_value_by_payment_bronze
-- Question: what's the average order value (items + freight) for each payment type?
--
-- THE TRAP. Joining order_items to order_payments on order_id FANS OUT: an order
-- with 3 items and 2 payments becomes 3 x 2 = 6 rows, and sum(price) counts every
-- item twice. The fix is to shrink both sides to one row per order (per type) first.

with order_totals as (

    select
        order_id,
        sum(cast(price as decimal(10, 2)) + cast(freight_value as decimal(10, 2))) as order_total
    from {{ source('olist', 'order_items') }}
    group by order_id

),

order_payment_types as (

    -- One row per (order, payment type). An order paid by card + voucher counts
    -- once under each type.
    select distinct order_id, payment_type
    from {{ source('olist', 'order_payments') }}

)

select
    pt.payment_type,
    count(*)                    as order_count,
    round(avg(t.order_total), 2) as avg_order_value

from order_payment_types as pt
join order_totals as t
    on pt.order_id = t.order_id
join {{ source('olist', 'orders') }} as o
    on pt.order_id = o.order_id

where o.order_status not in ('canceled', 'unavailable')
group by pt.payment_type
order by avg_order_value desc
