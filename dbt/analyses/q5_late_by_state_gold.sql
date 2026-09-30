-- GOLD. Run it: uv run dbt show -s q5_late_by_state_gold --limit 10
-- Question: which customer states get late deliveries most often?
--
-- is_late is already computed, and it's null for undelivered orders, so they drop
-- out of the average on their own.
--
-- (Why a few counts differ from bronze: dim_customers places each person at their
-- LATEST address, while bronze uses the address on each order. 39 people moved states,
-- so a handful of orders land in a different state. Good discussion question: which
-- one is "right"? It depends on whether you're asking about the person or the delivery.)

select
    c.state,
    count(o.is_late)                               as delivered_orders,
    round(avg(cast(o.is_late as integer)), 3)      as late_rate

from {{ ref('fct_orders') }} as o
join {{ ref('dim_customers') }} as c
    on o.customer_unique_id = c.customer_unique_id

group by c.state
order by late_rate desc, c.state
