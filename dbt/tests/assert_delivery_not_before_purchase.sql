-- An order can't arrive before it was bought. Returns any order that did.

select order_id, purchase_date, delivered_date, days_to_deliver
from {{ ref('fct_orders') }}
where days_to_deliver < 0
