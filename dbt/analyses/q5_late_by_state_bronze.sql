-- BRONZE. Run it: uv run dbt show -s q5_late_by_state_bronze --limit 10
-- Question: which customer states get late deliveries most often?
--
-- THE TRAP. Orders that haven't been delivered yet aren't "on time", they're unknown: count them in the denominator and
-- the late rate comes out too low. Only delivered orders can be late or on time.

with delivered as (

    select
        c.customer_state as state,
        -- compare DATES: the estimate is always midnight, so comparing timestamps
        -- would call a same-day delivery late
        cast(o.order_delivered_customer_date as date)
            > cast(o.order_estimated_delivery_date as date) as is_late

    from {{ source('olist', 'orders') }}    as o
    join {{ source('olist', 'customers') }} as c
        on o.customer_id = c.customer_id

    where o.order_delivered_customer_date is not null

)

select
    state,
    count(*)                                         as delivered_orders,
    round(avg(case when is_late then 1.0 else 0 end), 3) as late_rate

from delivered
group by state
order by late_rate desc, state
