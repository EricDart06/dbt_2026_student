-- A singular test: any rows this query returns are failures.
-- After cleaning, no seller city should still contain a '/', a digit, or an '@'.

select seller_id, city
from {{ ref('stg_sellers') }}
where regexp_like(city, '.*[/0-9@].*')
