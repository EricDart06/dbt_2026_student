-- SESSION 4: the GOLD way. Run it: uv run dbt show -s q3_worst_sellers_gold --limit 10
-- Question: which sellers (with at least 30 orders) have the worst average review?
--
-- The mart already did the hard grain work. This is a filter and a sort.

select seller_id, order_count, avg_review_score
from {{ ref('mart_seller_performance') }}
where order_count >= 30
order by avg_review_score, seller_id
