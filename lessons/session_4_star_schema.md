# Session 4 — Joins + star schema (semester week 6)

**Goal:** read a join off the ERD, then turn staging into a star schema: dimensions
(things) and facts (events).

**You leave with:** two dimensions of your own, `dim_products` and `dim_sellers`, and a
whole project that builds.

**Files you write this week:**

| | File | How |
|---|---|---|
| See one | `dim_customers.sql` | the instructor walks through it (already finished) |
| **Build one together** | `dbt/models/modeled/dim_products.sql` | TODOs, filled in as a class |
| **Build one alone** | `dbt/models/modeled/dim_sellers.sql` | TODOs, with hints |

---

## Before class

- Get this week's updates: **Sync fork → Update branch** on your fork's GitHub page, then **Pull** in VS Code (Source Control → … → Pull).
- Your `stg_customers` and `stg_sellers` from session 3 must build:
  `uv run dbt build -s staging`. If not, finish them first: everything this week is
  built on top of them.

---

## The hour

| Min | What we do |
|---|---|
| 0–5 | **Start `uv run dbt build`**, then do **warm-up W4** while it runs |
| 5–15 | **The ERD and joins** |
| 15–20 | **The star schema** + bronze vs. gold, round two |
| 20–30 | **See one:** walk through `dim_customers` |
| 30–45 | **Build one together:** `dim_products` |
| 45–55 | **Build one alone:** `dim_sellers` |
| 55–60 | `dbt build` the whole project, then follow your path through the lineage |

---

## Step by step

### 0–5 · Build everything provided, then warm-up W4
```bash
uv run dbt build
```
It takes about 30 seconds. You'll see **ERROR** on `dim_products` and `dim_sellers` (still
TODOs) and **SKIP** on the marts that need them. That's the lineage graph at work: dbt
won't build anything whose inputs are broken. Everything else builds.

While it runs, open `dbt/models/sandbox/olympics_sandbox.sql` and try:

> In 2016, which 5 sports had the most athletes? Show the number of athletes *and* the
> number of events for each.

(All warm-ups: [docs/sql_practice.md, Part C](../docs/sql_practice.md#part-c--warm-ups-5-minutes-at-the-start-of-each-session).)

### 5–15 · The ERD and joins
Open the ERD in [docs/data_dictionary.md](../docs/data_dictionary.md).
- A join matches rows from two tables on a shared column: `orders.customer_id = customers.customer_id`.
- `||--o{` means "one to many": one order has many items.
- **inner join** keeps only rows that match on both sides. **left join** keeps every row
  from the left table, with nulls where there's no match.
- Read the joins in `dbt/analyses/q1_top_categories_bronze.sql` box by box on the ERD:
  items → orders, items → products, products → translation.

### 15–20 · The star schema
Open [docs/star_schema.md](../docs/star_schema.md): first the single-fact picture, then the
full star.
- **Facts** are events you count and add up: orders, items, payments.
- **Dimensions** are things you filter and group by: customers, products, sellers, dates.

Bronze vs. gold, round two:
```bash
uv run dbt show -s q3_worst_sellers_bronze --limit 5
uv run dbt show -s q3_worst_sellers_gold --limit 5
```
The gold version reads from `mart_seller_performance`, which is built on the
`dim_sellers` you're about to write.

### 20–25 · See one: `dim_customers`
Open `dbt/models/modeled/dim_customers.sql`.
- **The grain is the person** (`customer_unique_id`), not `customer_id`, which is new for
  every order. Build it on `customer_id` and every shopper looks like a one-time buyer.
- It joins `stg_customers` to `stg_orders` to find each person's **most recent** order,
  and takes their city and state from it.

### 30–45 · Build one together: `dim_products`
Open `dbt/models/modeled/dim_products.sql` and fill in the TODOs as a class:
1. **translations CTE:** read the **seed** `product_category_name_translation` with `ref()`.
   A seed is a small CSV in `dbt/seeds/` that dbt loads itself, so it's a `ref`, not a `source`.
2. **category_name:** `coalesce(english name, Portuguese name, 'unknown')` returns the first
   one that isn't null.
3. **the join:** a **left** join on `category_name_pt = product_category_name`. With an
   inner join, the 610 products with no category would disappear.

Check it with **Preview**, then `uv run dbt build -s dim_products`. Its tests check that
every product is there once and that no `category_name` is null.

### 45–55 · Build one alone: `dim_sellers`
Open `dbt/models/modeled/dim_sellers.sql`. One row per seller: select four columns from
`{{ ref('stg_sellers') }}`. Your staging model already did the hard work, so this one is
short.

### 55–60 · Build and follow the lineage
```bash
uv run dbt build
uv run dbt docs generate
uv run dbt docs serve
```
In the lineage graph, follow your path: `sellers` (source) → `stg_sellers` →
`dim_sellers` → `mart_seller_performance`.

---

## Definition of done

- [ ] `uv run dbt build` shows **no ERROR and no SKIP**
- [ ] You can explain why `dim_customers` is one row per `customer_unique_id`

---

## Stuck?

| Error | Fix |
|---|---|
| `Model depends on a node named '...' which was not found` | a typo inside `ref('...')` |
| `not_null_dim_products_category_name` fails | the `coalesce` is missing its `'unknown'` fallback |
| `dim_products` has fewer than 32,951 rows | the join is `inner`; it should be `left` |
| `dim_sellers` errors but your SQL looks right | build `stg_sellers` first: `uv run dbt build -s stg_sellers` |

---

## Homework before session 5

Open `dbt/models/modeled/_modeled.yml` and read the tests on `dim_customers`. Next week
you write that block for `dim_sellers`.
