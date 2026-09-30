# Session 5 — Testing + buffer (semester week 7)

**Goal:** prove your tables are right instead of hoping, then catch up on anything
unfinished.

**You leave with:** tests and documentation on your `dim_sellers`, and a whole project that
builds with every test passing.

**Files you write this week:**

| | File | How |
|---|---|---|
| See one | the `dim_customers` block in `_modeled.yml` | the instructor walks through it |
| **Build one alone** | the `dim_sellers` block in `dbt/models/modeled/_modeled.yml` | TODO, with hints |

This week is short on new material on purpose: the second half is **buffer** time.

---

## Before class

Get this week's updates (**Sync fork → Update branch** on your fork's GitHub page, then **Pull** in VS Code (Source Control → … → Pull)), and make sure `uv run dbt build` runs with no
ERROR. If it doesn't, that's what the buffer time is for.

---

## The hour

| Min | What we do |
|---|---|
| 0–5 | **Warm-up W5:** two checks that turn out to be tests |
| 5–10 | **Why test:** a table can build fine and still be wrong |
| 10–20 | **See one:** the tests on `dim_customers`, plus breaking a test on purpose |
| 20–30 | **Build one alone:** the `dim_sellers` block |
| 30–60 | **Buffer:** catch up on sessions 2–4 |

---

## Step by step

### 0–5 · Warm-up W5
Open `dbt/models/sandbox/kidsfeet_sandbox.sql` and `olympics_sandbox.sql` and try this on your own before we start. Answers after 5 minutes.

> (a) Is `name` unique in kidsfeet? Find every name used more than once. (b) How many olympics rows are missing a `height`?

(All warm-ups: [docs/sql_practice.md, Part C](../docs/sql_practice.md#part-c--warm-ups-5-minutes-at-the-start-of-each-session).)

Keep your answers open: the next 5 minutes explain that you just wrote two dbt tests.

### 5–10 · Why test
`dbt build` succeeding only means the SQL ran. It doesn't mean the answer is right. A
test is a query that looks for bad rows: if it finds any, the test fails.

| Test | Checks | Why it matters |
|---|---|---|
| `unique` | no value appears twice | the table's grain: one row per ___ |
| `not_null` | no value is missing | every row has its key |
| `accepted_values` | only values from a list | e.g. `order_status` has 8 known values |
| `relationships` | every value exists in another table | every fact finds its dimension |

Tests live in YAML files next to the models: `_staging.yml`, `_modeled.yml`, `_marts.yml`.

### 10–20 · See one
Open `dbt/models/modeled/_modeled.yml` and read the `dim_customers` block:
```yaml
  - name: dim_customers
    description: >
      **One row is:** a person (`customer_unique_id`), NOT a customer_id. ...
    columns:
      - name: customer_unique_id
        description: "{{ doc('customer_unique_id') }}"
        data_tests: [unique, not_null]
```
Then break something on purpose. In `dim_customers.sql`, delete the four-line
`qualify row_number() over (...) = 1` in the `latest_location` CTE, and run `uv run dbt build -s dim_customers`: `unique_dim_customers_customer_unique_id`
fails, because people who ordered twice now appear twice. Put the lines back.

### 20–30 · Build one alone: the `dim_sellers` block
In the same file, find the TODO for `dim_sellers` and write its block, copying the shape
of `dim_customers`:
- a `description` that starts with `**One row is:**`
- the `seller_id` column with `data_tests: [unique, not_null]`

YAML is picky: use **spaces, not tabs**, and line your `- name:` up exactly with the
`dim_customers` one. Then:
```bash
uv run dbt build
```

### 30–60 · Buffer
Catch up, in this order:
1. `stg_customers` and `stg_sellers` (session 3)
2. `dim_products` and `dim_sellers` (session 4)
3. the `dim_sellers` tests (today)

Done early? Open [docs/star_schema.md](../docs/star_schema.md) and read "Facts don't join
facts". It's the most common mistake in the hackathon.

---

## Definition of done

- [ ] `uv run dbt build`: **no ERROR, no FAIL, no SKIP**
- [ ] `unique_dim_sellers_seller_id` and `not_null_dim_sellers_seller_id` appear in the
      build output and pass
- [ ] `uv run dbt docs generate && uv run dbt docs serve` shows your description on `dim_sellers`

---

## Stuck?

| Error | Fix |
|---|---|
| `mapping values are not allowed here` / YAML parse error | indentation: spaces only, lined up with `dim_customers` |
| Your tests don't show up in the output | the `- name: dim_sellers` line is still commented out (`#`) |
| `unique_dim_sellers_seller_id` fails | check `stg_sellers` still has its `deduplicated` stage |
