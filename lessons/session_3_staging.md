# Session 3 — Medallion architecture + staging (semester week 5)

**Goal:** understand *why* we clean data in layers, and build the first layer: staging.

**You leave with:** two staging models of your own in Snowflake, `stg_customers` and
`stg_sellers`, both passing their tests.

**Files you write this week:**

| | File | How |
|---|---|---|
| See one | `stg_order_reviews.sql` | the instructor walks through it (already finished) |
| **Build one together** | `dbt/models/staging/stg_customers.sql` | TODOs, filled in as a class |
| **Build one alone** | `dbt/models/staging/stg_sellers.sql` | TODOs, with hints |

---

## Before class

Pull the latest version of your fork (VS Code: **Source Control → … → Pull**), then run
`uv run dbt debug` to make sure you're still connected.

---

## The hour

| Min | What we do |
|---|---|
| 0–10 | **Bronze vs. gold:** the same question answered from raw data and from a finished table |
| 10–20 | **The medallion layers** + `source()` vs. `ref()` |
| 20–25 | **See one:** walk through `stg_order_reviews` |
| 25–40 | **Build one together:** `stg_customers` |
| 40–55 | **Build one alone:** `stg_sellers` |
| 55–60 | `dbt build`, then look at your views in Snowflake and at the lineage graph |

---

## Step by step

### 0–10 · Bronze vs. gold
Open both files in `dbt/analyses/` and run them:
```bash
uv run dbt show -s q1_top_categories_bronze --limit 5
uv run dbt show -s q1_top_categories_gold --limit 5
```
Same answer: watches_gifts, bed_bath_table, health_beauty. The bronze query needs four
raw tables, a translation table, and the rule that canceled orders don't count. The gold
query is four lines. **Which one could you explain to your manager?** That gap is what the
layers are for.

### 10–20 · The medallion layers
```
RAW (bronze)  ──►  STAGING (silver)  ──►  MODELED (gold)  ──►  MARTS
loaded for you     cleaned & renamed      star schema          answers
```
- Tour the folders: `models/staging/`, `models/modeled/`, `models/marts/`.
- **`source()`** points at data dbt *didn't* make (the raw tables in `PUBLIC`).
  **`ref()`** points at something dbt *did* make (a model or a seed).
- Every staging model has the **same four CTEs**, always in this order:

| CTE | Job |
|---|---|
| `source` | load the raw table, nothing else |
| `renamed` | rename, cast, clean |
| `deduplicated` | one row per key |
| `derived` | add columns you can compute |

### 20–25 · See one: `stg_order_reviews`
Open `dbt/models/staging/stg_order_reviews.sql`. It's the example where every stage has
real work to do:
- **renamed:** `review_answer_timestamp` becomes `answered_at`, and blank comments become null.
- **deduplicated:** 547 orders have more than one review, so we *choose* one per order,
  the most recent answer. The `order by` needs a tie-breaker (`review_id`) so the choice
  is the same every run.
- **derived:** `is_negative` = score of 2 or less.

### 25–40 · Build one together: `stg_customers`
Open `dbt/models/staging/stg_customers.sql` and fill in the TODOs as a class:
1. **source:** copy the source line from `stg_orders.sql` and change `'orders'` to `'customers'`.
2. **renamed:** five columns. Cast every one, even if it's already text: the casts are the
   model's promise about its types. Zip codes stay `varchar` (leading zeros!). City gets
   `lower(trim(...))`, state gets `upper(trim(...))`.
3. **deduplicated:** `customer_id` is already unique, but we keep the stage anyway so
   every staging model looks the same.
4. **derived:** nothing to add.

Check it with **Preview**, then:
```bash
uv run dbt build -s stg_customers
```
That builds the view **and** runs its tests (`unique` + `not_null` on `customer_id`...).

> **Watch for the trap:** `customer_id` is a new id **for every order**. The real person is
> `customer_unique_id`. It matters in session 4.

### 40–55 · Build one alone: `stg_sellers`
Open `dbt/models/staging/stg_sellers.sql`. It's the same shape as `stg_customers`, plus
one cleanup: a few sellers typed junk into their city.

| Raw `seller_city` | Should become |
|---|---|
| `campinas` | `campinas` |
| `auriflama/sp` | `auriflama` (keep the part before `/`) |
| `04482255` | null (a zip code, not a city) |
| `vendas@creditparts.com.br` | null (an email) |

The hints in the file give you each piece (`split_part`, `regexp_like`, `case when`).
Preview it and look for any city that still has a `/`, a digit, or an `@`.

### 55–60 · Build and look
```bash
uv run dbt build -s staging
```
Then, in Snowsight, open `DBT_LABS_DB → STAGING`: your views are there with your name on
them. Finally, see the lineage graph:
```bash
uv run dbt docs generate
uv run dbt docs serve
```

---

## Definition of done

- [ ] `uv run dbt build -s staging` shows **no ERROR**
- [ ] The test `assert_seller_cities_are_clean` passes (it's part of that build)

---

## Stuck?

| Error | Fix |
|---|---|
| `syntax error ... unexpected 'from'` | a comma after the **last** column in `select`, or a TODO still empty |
| `invalid identifier` | a column name typo: compare against [docs/data_dictionary.md](../docs/data_dictionary.md) |
| `assert_seller_cities_are_clean` fails | a city still has `/`, a digit, or `@`: check the `case when` |
| `unique_stg_sellers_seller_id` fails | the `deduplicated` CTE was changed; it should `qualify row_number() ... = 1` |

---

## Homework before session 4

Read the "One row is..." line for every table in [docs/data_dictionary.md](../docs/data_dictionary.md)
and look at the ERD at the top. Next week starts with joins.
