-- Reconciliation: the mart's total revenue must equal the fact table's.
-- If a join in the mart drops or duplicates rows, the totals drift apart.

with mart as (
    select sum(revenue) as revenue from {{ ref('mart_monthly_category_sales') }}
),

facts as (
    select sum(price) as revenue
    from {{ ref('fct_order_items') }}
    where is_sale
)

select mart.revenue as mart_revenue, facts.revenue as fact_revenue
from mart, facts
where mart.revenue <> facts.revenue
