{% docs __overview__ %}

# Olist E-Commerce Warehouse

About **100,000 real orders** from Olist, a Brazilian online marketplace, placed between
September 2016 and October 2018. Olist connects small shops (**sellers**) to shoppers
(**customers**), and one order can contain several items from different sellers.

## The layers

| Layer | Folder | What it's for |
|---|---|---|
| **Raw** (bronze) | *sources* | The data exactly as it arrived, in `DBT_LABS_DB.PUBLIC`. dbt reads it with `source()` but never changes it. |
| **Staging** (silver) | `staging/` | One model per raw table: **rename, cast, clean, dedup**. Nothing is combined yet. |
| **Modeled** (gold) | `modeled/` | The **star schema**. `dim_` tables describe things (customers, products, sellers, dates); `fct_` tables record events (orders, items, payments). |
| **Marts** | `marts/` | One table per business question, ready for a dashboard. |

## Where to start

- **"How much did we sell?"** → `fct_order_items` joined to `dim_products`, `dim_sellers`, `dim_date`.
- **"How are orders going?"** (delivery, lateness, reviews) → `fct_orders`.
- **"How do people pay?"** → `fct_order_payments`.
- **Already answered:** `mart_monthly_category_sales`, `mart_seller_performance`.

## Three rules for this project

1. **Know the grain.** Every model's description starts with *one row is...*. Joining two
   tables with different grains multiplies rows (a **fan-out**) and inflates every sum.
2. **Facts don't join facts.** To combine two facts, roll each up to the same grain
   first, then join (a **drill-across**).
3. **A person is `customer_unique_id`, not `customer_id`.** Olist issues a new
   `customer_id` for every order.

Click **the blue button at the bottom right** to see the lineage graph.

{% enddocs %}


{# ---------------- shared column definitions ---------------- #}

{% docs order_id %}
Unique id of an order. In the facts it's a **degenerate dimension**: an identifier with
no dimension table behind it. Several facts carry it so they can be lined up at order
grain, but **never join one fact to another on it directly**. Roll up first.
{% enddocs %}

{% docs customer_id %}
Customer id **for one order**. Olist issues a new one for every order, so it does
**not** identify a person. Use it only to join `stg_orders` to `stg_customers`, then
switch to `customer_unique_id`.
{% enddocs %}

{% docs customer_unique_id %}
The actual **person**. Stays the same across all of their orders. 96,096 people placed
99,441 orders; 2,997 of them ordered more than once. Joins to `dim_customers`.
{% enddocs %}

{% docs product_id %}
Unique id of a product. Joins to `dim_products`.
{% enddocs %}

{% docs seller_id %}
Unique id of a seller (a shop selling on Olist). Joins to `dim_sellers`.
{% enddocs %}

{% docs zip_code_prefix %}
First 5 digits of a Brazilian zip code (CEP). Kept as **text** so leading zeros survive
(`01003`, not `1003`).
{% enddocs %}

{% docs state %}
Two-letter Brazilian state code, e.g. `SP` (São Paulo), `RJ` (Rio de Janeiro),
`MG` (Minas Gerais).
{% enddocs %}

{% docs order_status %}
Where the order is in its life cycle. One of: `created`, `approved`, `invoiced`,
`processing`, `shipped`, `delivered` (97% of orders), `canceled`, `unavailable`.
{% enddocs %}

{% docs is_sale %}
`true` if the order counts as a sale, meaning it is **not** `canceled` or `unavailable`.
**The** business rule for "did we sell something?", defined once in `stg_orders`.
Filter on this flag instead of re-typing the status list.
{% enddocs %}

{% docs is_delivered %}
`true` if `order_status` is `delivered`. (8 delivered orders have no delivery date.)
{% enddocs %}

{% docs purchase_date %}
The date the customer placed the order. Joins to `dim_date.date_day`.
{% enddocs %}

{% docs price %}
Price of one item, in Brazilian reais (R$), **excluding** shipping. **Revenue** in this
project means `sum(price)`.
{% enddocs %}

{% docs freight_value %}
Shipping cost charged for one item, in R$.
{% enddocs %}

{% docs item_total %}
`price + freight_value` for one item: what the customer paid for it, including shipping.
{% enddocs %}

{% docs item_number %}
The item's **position** within its order: 1, 2, 3... (up to 21). In the raw data this
column is called `order_item_id`, which is misleading because it is not unique on its own.
{% enddocs %}

{% docs order_item_key %}
Unique key for one item: `order_id` + `-` + `item_number`. A one-column key for a
two-column grain, so other tables can point at a single item.
{% enddocs %}

{% docs order_payment_key %}
Unique key for one payment: `order_id` + `-` + `payment_number`.
{% enddocs %}

{% docs payment_number %}
1 for the first payment on an order, 2 for the second, and so on. Most orders have one;
some are split across a card and vouchers.
{% enddocs %}

{% docs payment_type %}
How this payment was made: `credit_card` (74%), `boleto` (a Brazilian bank slip, paid
in cash or online), `voucher`, `debit_card`, or `not_defined` (3 rows).
{% enddocs %}

{% docs installments %}
Number of monthly installments the customer chose. Brazilian card purchases are
commonly split into installments. 1 = paid all at once.
{% enddocs %}

{% docs amount %}
Amount of this payment in R$. Can include installment interest, so an order's payments
don't always add up exactly to its items + freight.
{% enddocs %}

{% docs review_score %}
Customer satisfaction score from the post-delivery survey: 1 (worst) to 5 (best).
{% enddocs %}

{% docs category_name_pt %}
Product category **in Portuguese**, as Olist stores it (e.g. `beleza_saude`).
Null for 610 products that have no category.
{% enddocs %}

{% docs city %}
City name, lowercase.
{% enddocs %}
