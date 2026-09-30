-- BRONZE. Run it: uv run dbt show -s q2_repeat_customers_bronze
-- Question: what % of customers come back and buy again?
--
-- THE TRAP. The obvious query counts orders per customer_id:
--
--     select customer_id, count(*) from orders group by customer_id
--
-- ...and every customer has exactly 1 order, so the repeat rate is 0%. That's because
-- Olist issues a NEW customer_id for every order. The real person is
-- customer_unique_id, which lives in a different table, so we have to join.

with orders_per_person as (

    select
        c.customer_unique_id,
        count(*) as order_count

    from {{ source('olist', 'orders') }}    as o
    join {{ source('olist', 'customers') }} as c
        on o.customer_id = c.customer_id

    group by c.customer_unique_id

)

select
    count(*)                                   as customers,
    count_if(order_count > 1)                  as repeat_customers,
    round(100.0 * count_if(order_count > 1) / count(*), 2) as repeat_pct

from orders_per_person
