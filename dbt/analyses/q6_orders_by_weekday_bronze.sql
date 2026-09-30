-- BRONZE. Run it: uv run dbt show -s q6_orders_by_weekday_bronze
-- Question: do people shop more on weekends?
--
-- Not a trap, just friction: work out the weekday name (Snowflake only gives 'Mon'),
-- and the weekday NUMBER so the days sort Monday to Sunday instead of alphabetically.
-- Every analyst writes this date math slightly differently.

select
    dayname(order_purchase_timestamp)                as day_name,
    dayofweekiso(order_purchase_timestamp) in (6, 7) as is_weekend,
    count(*) as order_count

from {{ source('olist', 'orders') }}
group by
    dayname(order_purchase_timestamp),
    dayofweekiso(order_purchase_timestamp)
order by dayofweekiso(order_purchase_timestamp)
