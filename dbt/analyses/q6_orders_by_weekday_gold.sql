-- GOLD. Run it: uv run dbt show -s q6_orders_by_weekday_gold
-- Question: do people shop more on weekends?
--
-- dim_date already knows every day's name, number, and whether it's a weekend.
-- This is why a date dimension exists.

select
    d.day_name,
    d.is_weekend,
    count(*) as order_count

from {{ ref('fct_orders') }} as o
join {{ ref('dim_date') }} as d
    on o.purchase_date = d.date_day

group by d.day_name, d.is_weekend, d.day_of_week
order by d.day_of_week
