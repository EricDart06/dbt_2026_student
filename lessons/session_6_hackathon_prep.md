# Session 6 — Buffer + hackathon prep (semester week 8)

**Goal:** everyone's project builds, and everyone knows where to look for answers in
the warehouse before the hackathon.

**You leave with:** a green `dbt build`, and practice answering a business question from
the finished tables.

**Files you write this week:** none. Catch up, then practice.

---

## Before class

Pull the latest version of your fork and run `uv run dbt build`. Note anything that
fails; we fix those first.

---

## The hour

| Min | What we do |
|---|---|
| 0–5 | **Warm-up W6:** a CTE, one last time |
| 5–20 | **Buffer:** everyone gets to a green `uv run dbt build` |
| 20–35 | **Tour the marts** and the "which table do I use?" map |
| 35–55 | **Hackathon warm-up:** answer a question from gold, then look at the bronze trap |
| 55–60 | Hackathon logistics |

---

## Step by step

### 0–5 · Warm-up W6
Open `dbt/models/sandbox/olympics_sandbox.sql` and try this on your own before we start. Answers after 5 minutes.

> Using a CTE: which 5 countries won the most gold medals at the 2016 Olympics, counting **one medal per event**?

(All warm-ups: [docs/sql_practice.md, Part C](../docs/sql_practice.md#part-c--warm-ups-5-minutes-at-the-start-of-each-session).)

### 5–20 · Buffer
Same order as last week: staging → dimensions → tests. Help your neighbor.

### 20–35 · Tour the marts
- `mart_monthly_category_sales`: one row per (month, category). Revenue questions.
- `mart_seller_performance`: one row per seller. Sales, late deliveries, reviews.

Which table for which question (also the front page of `dbt docs serve`):

| Question type | Start from |
|---|---|
| "How much did we sell?" | `fct_order_items` + `dim_products` / `dim_sellers` / `dim_date` |
| "How are orders going?" (delivery, lateness, reviews) | `fct_orders` |
| "How do people pay?" | `fct_order_payments` |
| Already answered | the two marts |

### 35–55 · Hackathon warm-up
In pairs, pick one question. Write the **gold** version yourself (in a sandbox-style
CTE, or with `uv run dbt show --inline "..."`), then compare with the file in
`dbt/analyses/`, and read the trap at the top of the **bronze** file.

| # | Question | The trap in the raw data |
|---|---|---|
| q2 | What % of customers buy again? | counting `customer_id` gives 0% |
| q4 | Average order value by payment type? | joining items to payments multiplies rows |
| q5 | Which states get the most late deliveries? | undelivered orders counted as on time |
| q6 | Do people shop more on weekends? | date math on every query |

```bash
uv run dbt show -s q2_repeat_customers_gold
uv run dbt show -s q2_repeat_customers_bronze
```

### 55–60 · Hackathon logistics
Teams, time, and what to bring.

---

## Definition of done

- [ ] `uv run dbt build`: no ERROR, no FAIL, no SKIP
- [ ] You answered one warm-up question from the gold tables
