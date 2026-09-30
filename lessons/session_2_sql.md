# Session 2 — Setup check + SQL crash course (semester week 4)

**Goal:** everyone's connection works, and everyone can read and write a CTE, which is
all a dbt model is.

**You leave with:** a green `dbt debug`, and the sandbox queries you wrote in class.

**Files you write this week:** none to hand in. You practice in the two sandbox files.

---

## Before class

- Finish [getting-started.md](../setup/getting-started.md) Parts 5–6: `uv run dbt debug`
  should say **All checks passed!** If it doesn't, come a few minutes early.
- The DataCamp SQL homework from session 1.

---

## The hour

| Min | What we do | Where |
|---|---|---|
| 0–15 | **Setup check.** Everyone runs `uv run dbt debug`. Fix anyone who's red. | terminal, in `dbt/` |
| 15–20 | **Tour the sandbox.** Two CTEs: the first gets the data, you write in the second. Run it with **Preview**. | `dbt/models/sandbox/kidsfeet_sandbox.sql` |
| 20–35 | **Kidsfeet, together:** questions K1–K10. | [docs/sql_practice.md](../docs/sql_practice.md) Part A |
| 35–50 | **Olympics, together:** questions O1–O12, ending with CTEs. | Part B, `olympics_sandbox.sql` |
| 50–60 | **Running SQL vs. building tables.** | terminal + Snowsight |

---

## Step by step

### 0–15 · Setup check
From the `dbt` folder:
```bash
cd dbt
uv run dbt debug
```
Most failures are one of: the `profiles.yml` is in the wrong folder, the key path is
wrong, or the path uses backslashes. The error table is in
[getting-started.md](../setup/getting-started.md#part-6--test-your-connection).
Also confirm everyone's `schema:` is `lastname_firstname` and that no two people match.

### 15–20 · The sandbox
Open `dbt/models/sandbox/kidsfeet_sandbox.sql`:

```sql
with kidsfeet as (              -- 1. gets the data. Leave it alone.
    select * from {{ source('sandbox', 'kidsfeet') }}
),

kidsfeet_sandbox as (           -- 2. YOUR QUERY GOES HERE
    select *
    from kidsfeet
)

select * from kidsfeet_sandbox
```

- Click **Preview** above the second CTE. If the buttons are missing, run
  **Developer: Reload Window** (Ctrl/Cmd + Shift + P).
- The same thing from the terminal: `uv run dbt show -s kidsfeet_sandbox`.
- Nothing is saved. Break it as often as you like.

### 20–35 · Kidsfeet (Part A)
One question at a time: read it aloud, everyone writes it, then someone shares.
- **K1–K6:** `select` columns, `where`, `and`, `order by`, `limit`. At K6, stop on the
  tie: three kids have a 9.8 cm foot, so who makes the "top 5"?
- **K7–K10:** new columns: math with `as`, `round()`, `case when`, comparing two columns.

### 35–50 · Olympics (Part B)
- **O1 first, and slowly:** *what is one row?* One athlete **in one event**. Everything
  after depends on it.
- **O2–O9:** `count` vs. `count(distinct)`, `group by`, `having` vs. `where`, `min`/`max`,
  `count_if`.
- **O10–O12: CTEs.** Add a step between the data CTE and your sandbox CTE. O10 is the
  payoff: USA has **2,638** gold *rows* but **1,131** real gold medals, because every
  player on a team gets a row.

### 50–60 · Running SQL vs. building tables
- Preview / `dbt show` runs SQL and shows results. **Nothing is saved.**
- `uv run dbt build -s stg_orders` creates a **real view** in Snowflake. Open Snowsight,
  go to `DBT_LABS_DB → STAGING`, and find `LASTNAME_FIRSTNAME__STG_ORDERS`: your name is
  on it, so nobody overwrites anyone.

| Command | What it does |
|---|---|
| `uv run dbt debug` | checks your connection |
| `uv run dbt show -s <model>` | runs a model and prints results; builds nothing |
| `uv run dbt build` | builds and tests models in Snowflake |

---

## Definition of done

- [ ] `uv run dbt debug` → **All checks passed!**
- [ ] Preview on `kidsfeet_sandbox` shows rows
- [ ] You wrote at least one query with a second CTE (O10–O12)

---

## Stuck?

| Problem | Try |
|---|---|
| No Preview buttons | **Developer: Reload Window**, then open the file again |
| `invalid identifier 'X'` | a typo in a column name; check the column list at the top of the file |
| `'G'` vs. `"G"` | text values use **single** quotes |
| `... is not a valid group by expression` | every column in `select` must be in `group by` or inside `count`/`sum`/`avg`... |
| Filtering on `count(*)` fails in `where` | use `having`: `where` filters rows, `having` filters groups |

---

## Homework before session 3

Try two olympics questions of your own in the sandbox. Ideas: which sport has the
oldest athletes? When did your country first win a gold?
