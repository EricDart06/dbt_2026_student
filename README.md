# E-Commerce Analytics Engineering — a dbt Training Project

A hands-on introduction to **analytics engineering with dbt on Snowflake**, built on the
[Brazilian E-Commerce dataset by Olist](https://www.kaggle.com/datasets/olistbr/brazilian-ecommerce)
(~100k real, anonymized orders from 2016–2018).

Students start from raw tables that are already loaded into Snowflake and, one layer at a
time, turn them into a clean, tested, easy-to-query warehouse:

```
  RAW (bronze)  ──►  STAGING (silver)  ──►  MODELED (gold: facts + dims)  ──►  MARTS
  loaded for you     cleaned & renamed      star schema                         answers
```

Each week adds one step to the lineage graph, until a hard question about the business
becomes an easy query.

---

## Schedule at a glance

We meet **one hour per week**. The training runs in semester weeks 3–8, and the
**hackathon is week 9**, so everything a team needs to use the warehouse is covered by then.

| Session | Semester week | Topic | Files you write | Lesson plan |
|---|---|---|---|---|
| 1 | 3 | Setup | — | [session 1](lessons/session_1_setup.md) |
| 2 | 4 | Setup check + SQL crash course | — (practice in the sandbox) | [session 2](lessons/session_2_sql.md) |
| 3 | 5 | Medallion architecture + staging | `stg_customers` (together), `stg_sellers` (alone) | [session 3](lessons/session_3_staging.md) |
| 4 | 6 | Joins + star schema | `dim_products` (together), `dim_sellers` (alone) | [session 4](lessons/session_4_star_schema.md) |
| 5 | 7 | Testing + **buffer** | tests for `dim_sellers` (alone) | [session 5](lessons/session_5_testing.md) |
| 6 | 8 | **Buffer** + hackathon prep | — | [session 6](lessons/session_6_hackathon_prep.md) |
| — | 9 | **Hackathon** | — | — |

Each lesson plan has the minute-by-minute hour, step-by-step instructions, a
definition of done, and a "Stuck?" table of common errors.

### See one, build one together, build one alone

Every building session works the same way:

| Step | What happens | Staging (session 3) | Star schema (session 4) |
|---|---|---|---|
| **See one** | The instructor walks through a finished model. | `stg_order_reviews` | `dim_customers` |
| **Build one together** | A file full of TODOs, filled in as a class. | `stg_customers` | `dim_products` |
| **Build one alone** | A file full of TODOs and hints, on your own. | `stg_sellers` | `dim_sellers` |

The files you build alone follow **one table, sellers**, all the way from raw to tested:

```
source('olist', 'sellers')  ──►  stg_sellers  ──►  dim_sellers  ──►  tests
        (raw, provided)          session 3         session 4        session 5
```

Everything else in the project is already built, so it always runs end to end and
shows you what the finished version looks like.

> **About the buffer weeks.** Sessions 5 and 6 are intentionally left open. If a topic
> feels rushed, say so: we'll slow down and use the buffer rather than leave anyone
> behind.

---

## Session 1 — Setup (semester week 3)

**Full lesson plan: [lessons/session_1_setup.md](lessons/session_1_setup.md)**

Follow **[setup/getting-started.md](setup/getting-started.md)** step by step.

**Goal:** everyone has VS Code, Git, and [uv](https://docs.astral.sh/uv/) installed, has
made their Snowflake key, and can log in to Snowflake. uv installs Python and dbt for
you, so every student ends up on the same versions.

**Homework before session 2:**
- Join the [class DataCamp group](https://www.datacamp.com/groups/shared_links/95e4f07f7af720aba23dbded5a2dba284eecbf3cd1853aeb5b76a5eedb5dde9f)
  and take [Introduction to SQL](https://app.datacamp.com/learn/courses/introduction-to-sql).
- Watch the assigned SQL tutorials (SELECT → WHERE → GROUP BY → CTE).
- Practice with a chatbot: ask it to explain each query you write, and to quiz you on
  the difference between `WHERE` and `HAVING`.

---

## Session 2 — Setup check + SQL crash course (semester week 4)

**Full lesson plan: [lessons/session_2_sql.md](lessons/session_2_sql.md)**

**Goal:** every `profiles.yml` works *before* the real project starts, and everyone
understands a CTE well enough to read a dbt model.

| Min | Activity |
|---|---|
| 0–15 | **Setup check.** Everyone runs `uv run dbt debug` until it's green. Confirm your `schema:` name (see *Naming* below). |
| 15–20 | **The sandbox.** Open `dbt/models/sandbox/kidsfeet_sandbox.sql`. The first CTE gets the data; you write in the second. Run it with the **Preview** button above the CTE. |
| 20–35 | **Kidsfeet, together** ([docs/sql_practice.md](docs/sql_practice.md) Part A): pick columns, `WHERE`, `ORDER BY`, `LIMIT`, and making new columns (math, `CASE`). |
| 35–50 | **Olympics, together** (Part B, `olympics_sandbox.sql`): `GROUP BY`, `COUNT`/`AVG`/`MIN`/`MAX`, `HAVING`, and finally **CTEs**: adding a step between the data and your answer. Every dbt model is just a chain of CTEs like this. |
| 50–60 | **Running SQL vs. building tables.** Preview shows results and saves nothing. `uv run dbt build -s stg_orders` creates a real view in Snowflake with your name on it; find it in Snowsight. |

Joins wait until session 4, where the first dimensions need them.

**dbt commands introduced** (full list in [cheatsheet.md](cheatsheet.md)):

| Command | What it does |
|---|---|
| `dbt debug` | Checks your connection and `profiles.yml` |
| `dbt show -s <model>` | Runs a model and prints the results. Builds nothing. (Same as the Preview button.) |
| `dbt run` | Builds models as tables/views in Snowflake |
| `dbt test` | Runs data tests |
| `dbt build` | `run` + `test` (+ seeds) in dependency order |

**Definition of done:** `dbt debug` passes and Preview on `kidsfeet_sandbox` shows rows.

---

## Session 3 — Medallion architecture + staging (semester week 5)

**Full lesson plan: [lessons/session_3_staging.md](lessons/session_3_staging.md)**

**Goal:** understand *why* we layer data, and build the first layer ourselves.

| Min | Activity |
|---|---|
| 0–10 | **Bronze vs. gold.** Two queries answer "top 5 categories in Nov 2017" and get the same answer: `dbt/analyses/q1_top_categories_bronze.sql` (4 raw tables, a seed, casts and filters) vs. `q1_…_gold.sql` (one table, four lines). *Which one could you explain to your manager?* |
| 10–20 | **Medallion overview** + a quick tour of the dbt folders (`staging/`, `modeled/`, `marts/`). **`source()` vs. `ref()`**: `source()` points at data dbt *didn't* create (the raw tables); `ref()` points at something dbt *did* create (a model or a seed). |
| 20–25 | **See one:** walk through `stg_order_reviews`, where every stage has real work, including the dedup. |
| 25–40 | **Build one together:** `stg_customers` (rename, cast, `lower`/`upper` cleaning). |
| 40–55 | **Build one alone:** `stg_sellers`, the same shape plus cleaning junk out of the city names (`auriflama/sp`, a zip code, an email address). |
| 55–60 | `uv run dbt build -s staging`, find your views in Snowflake, then `dbt docs generate && dbt docs serve` to see the lineage. |

### The staging pattern: four CTEs, always in this order

```sql
with source as (           -- 1. load it, and nothing else
    select * from {{ source('olist', 'order_reviews') }}
),

renamed as (               -- 2. rename + cast + clean. No new logic.
    select
        cast(review_id    as varchar)   as review_id,
        cast(order_id     as varchar)   as order_id,
        cast(review_score as integer)   as review_score,
        cast(review_answer_timestamp as timestamp) as answered_at
    from source
),

deduplicated as (          -- 3. establish the grain: one row per ORDER
    select * from renamed
    qualify row_number() over (
        partition by order_id
        order by answered_at desc, review_id   -- tie-break: which duplicate wins?
    ) = 1
),

derived as (               -- 4. add columns you can compute
    select
        *,
        review_score <= 2 as is_negative_review
    from deduplicated
)

select * from derived
```

| Stage | What it does | Olist examples |
|---|---|---|
| **Rename** | Fix names that are unclear or wrong. Don't rename on principle. | `product_name_lenght` → `name_length` (typo in the source) |
| **Cast** | Write down the type of every column, even if it's already right. This is the model's contract. | `order_item_id` → `integer`; zip codes stay `varchar` (leading zeros!) |
| **Clean** | Standardize values. | seller city `auriflama/sp` → `auriflama`; blank review comments → null |
| **Dedup** | `qualify row_number()` so the table has one row per key. The `order by` must be deterministic. | `order_reviews`: neither `review_id` nor `order_id` is unique, so we *choose* one review per order |

Why this order: you cast before dedup because the dedup's `order by` needs the right
type, and you dedup before deriving so you don't compute columns for rows you're about
to throw away. If a stage has nothing to do, keep it and leave a comment saying *why*.

**Definition of done:** `uv run dbt build -s staging` succeeds.

---

## Session 4 — Joins + star schema (semester week 6)

**Full lesson plan: [lessons/session_4_star_schema.md](lessons/session_4_star_schema.md)**

**Goal:** read a join off the ERD, then model the staging layer into something easy to query.

| Min | Activity |
|---|---|
| 0–5 | `uv run dbt build`: everything provided builds; your two TODO files ERROR and the marts that need them SKIP. |
| 5–15 | **The ERD and joins.** Walk through [docs/data_dictionary.md](docs/data_dictionary.md): what one row of each table means and how they connect. `inner` vs. `left` join. Read the joins in the q1 bronze query box by box on the ERD. |
| 15–20 | **The star schema** ([docs/star_schema.md](docs/star_schema.md)) + bronze vs. gold again: `q3_worst_sellers_bronze.sql` vs. `q3_…_gold.sql`, which reads from the mart built on `dim_sellers`. |
| 20–30 | **See one:** walk through `dim_customers` (the `customer_id` vs. `customer_unique_id` trap). |
| 30–45 | **Build one together:** `dim_products` (join the translation **seed** with `ref()`, `coalesce`, and why it's a `left` join). |
| 45–55 | **Build one alone:** `dim_sellers`, one row per seller from `ref('stg_sellers')`. |
| 55–60 | `uv run dbt build`, then the lineage: follow your path raw → `stg_sellers` → `dim_sellers` → `mart_seller_performance`. |

**Provided:** `dim_date`, `fct_orders`, `fct_order_items`, `fct_order_payments`.

**Definition of done:** `uv run dbt build` succeeds for the whole project.

---

## Session 5 — Testing + buffer (semester week 7)

**Full lesson plan: [lessons/session_5_testing.md](lessons/session_5_testing.md)**

**Goal:** prove the tables are right, instead of hoping.

| Min | Activity |
|---|---|
| 0–10 | **Why test.** A table can build and still be wrong. `unique`, `not_null`, `accepted_values`, `relationships`. |
| 10–20 | **See one:** the tests on `dim_customers` in `_modeled.yml`. Break one on purpose and watch the build catch it. |
| 20–30 | **Build one alone:** the `dim_sellers` block in `models/modeled/_modeled.yml`: a description ("One row is...") and `unique` + `not_null` on `seller_id`. |
| 30–60 | **Buffer:** catch up on anything unfinished, then `uv run dbt build` for the whole project. |

**Definition of done:** `uv run dbt build` passes everything, including your tests.

---

## Session 6 — Buffer + hackathon prep (semester week 8)

**Full lesson plan: [lessons/session_6_hackathon_prep.md](lessons/session_6_hackathon_prep.md)**

1. Catch up on anything unfinished.
2. **Tour the marts:** `mart_monthly_category_sales` and `mart_seller_performance`. The
   second is a good grain lesson (per-item vs. per-order).
3. **Hackathon warm-up:** the other bronze vs. gold pairs in `dbt/analyses/`
   (q2 repeat customers, q4 order value by payment type, q5 late deliveries by state,
   q6 weekday shopping). Each bronze file explains its trap at the top.

---

## Naming: don't overwrite each other

Everyone shares one Snowflake database and the same two schemas, so dbt puts **your
name on each table**. You set it once, as `schema:` in `profiles.yml`
(`schema: smith_john`):

```
DBT_LABS_DB
├── PUBLIC      ← raw Olist + sandbox tables. Shared, read-only, loaded by the instructor.
├── STAGING     ← SMITH_JOHN__STG_ORDERS, SMITH_JOHN__STG_SELLERS, ...
└── MODELED     ← SMITH_JOHN__DIM_SELLERS, SMITH_JOHN__FCT_ORDERS, SMITH_JOHN__MART_..., ...
```

In your SQL, model names stay clean: `ref('stg_orders')` works the same for everyone,
and dbt adds your name for you (`dbt/macros/generate_names.sql`). The solution's own
tables are named `EXAMPLE__...`, so you can peek at the finished versions in Snowflake.

---

## Repo layout

```
pyproject.toml      Python + dbt versions; `uv sync` installs everything
cheatsheet.md       common dbt commands
docs/
  data_dictionary.md  every raw table and column + the raw ERD
  star_schema.md      the modeled tables + the star-schema ERD
  sql_practice.md     the session 2 kidsfeet + olympics questions
lessons/            one lesson plan per session
data/ecommerce/     Olist CSVs (gitignored; loaded into Snowflake by the instructor)
data/sandbox/       kidsfeet + olympics notes (CSVs gitignored; loaded into Snowflake)
setup/              getting-started guide + profiles.example.yml
dbt/                the dbt project
  models/
    staging/        stg_*       views    + _sources.yml + tests
    modeled/        dim_*/fct_* tables   + tests
    marts/          mart_*      tables   + tests (built into MODELED)
    sandbox/        kidsfeet_sandbox + olympics_sandbox: write SQL in the 2nd CTE. Never built.
  analyses/         six bronze vs. gold query pairs (q1-q6)
  macros/           generate_names.sql: puts your name on your tables
  seeds/            product_category_name_translation.csv
  tests/            singular tests (grain, reconciliation, range checks)
```
