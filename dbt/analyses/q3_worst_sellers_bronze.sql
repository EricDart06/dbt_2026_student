-- SESSION 4: the BRONZE way. Run it: uv run dbt show -s q3_worst_sellers_bronze --limit 10
-- Question: which sellers (with at least 30 orders) have the worst average review?
--
-- THE TRAP. Joining order_items straight to order_reviews counts each review once
-- PER ITEM (an order with 3 items counts its review 3 times), and 547 orders have
-- more than one review, so those get double-counted as well. To get it right you must:
--   1. pick one review per order,
--   2. roll items up to one row per (seller, order),
--   3. only then join and average.

with one_review_per_order as (

    select order_id, cast(review_score as integer) as review_score
    from {{ source('olist', 'order_reviews') }}
    qualify row_number() over (
        partition by order_id
        order by cast(review_answer_timestamp as timestamp) desc, review_id
    ) = 1

),

seller_orders as (

    select distinct i.seller_id, i.order_id
    from {{ source('olist', 'order_items') }} as i
    join {{ source('olist', 'orders') }}      as o on i.order_id = o.order_id
    where o.order_status not in ('canceled', 'unavailable')

)

select
    so.seller_id,
    count(*)                        as order_count,
    round(avg(r.review_score), 2)   as avg_review_score

from seller_orders as so
left join one_review_per_order as r
    on so.order_id = r.order_id

group by so.seller_id
having count(*) >= 30
order by avg_review_score, so.seller_id
