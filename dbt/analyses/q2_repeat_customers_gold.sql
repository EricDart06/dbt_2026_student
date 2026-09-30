-- GOLD. Run it: uv run dbt show -s q2_repeat_customers_gold
-- Question: what % of customers come back and buy again?
--
-- fct_orders already carries customer_unique_id, so the trap is gone: the person is
-- the only customer column there is.

with orders_per_person as (

    select customer_unique_id, count(*) as order_count
    from {{ ref('fct_orders') }}
    group by customer_unique_id

)

select
    count(*)                                   as customers,
    count_if(order_count > 1)                  as repeat_customers,
    round(100.0 * count_if(order_count > 1) / count(*), 2) as repeat_pct

from orders_per_person
