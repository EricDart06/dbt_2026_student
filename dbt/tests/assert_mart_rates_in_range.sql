-- Rates are between 0 and 1, and review scores between 1 and 5. Anything else is a bug.

select seller_id, late_delivery_rate, avg_review_score
from {{ ref('mart_seller_performance') }}
where late_delivery_rate not between 0 and 1
   or avg_review_score   not between 1 and 5
