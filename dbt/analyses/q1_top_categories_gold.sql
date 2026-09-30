-- SESSION 3: the GOLD way. Same question, same answer.
-- Run it: uv run dbt show -s q1_top_categories_gold --limit 5
-- Question: which 5 product categories earned the most in November 2017 (Black Friday)?

select category_name, revenue
from {{ ref('mart_monthly_category_sales') }}
where year_month = '2017-11'
order by revenue desc
