# dbt Command Cheatsheet

Run every command from the project's `dbt` folder, and start each one with `uv run`:

```bash
cd dbt
uv run dbt debug
```

(If you installed with pip instead of uv, leave off `uv run`.)

---

## The everyday commands

| Command | What it does |
|---|---|
| `uv run dbt debug` | Check your Snowflake connection and `profiles.yml` |
| `uv run dbt show -s <model>` | Run a model and **print the results**. Builds nothing. (The **Preview** button in VS Code does the same.) |
| `uv run dbt run` | Build all models as tables/views in Snowflake, with your name on them |
| `uv run dbt test` | Run all tests |
| `uv run dbt build` | Seed + run + test everything, in dependency order |
| `uv run dbt run -s <model>` | Build one model |
| `uv run dbt test -s <model>` | Test one model |
| `uv run dbt docs generate` then `uv run dbt docs serve` | Open the project docs and lineage graph in your browser |

> **You don't need `dbt seed`.** The raw Olist data is already loaded in Snowflake for
> you. The only seed in this project is the small category translation table
> (Portuguese → English product categories). Run `uv run dbt seed` only if you want
> English category names. `dbt build` also loads it automatically; it takes a second.

---

## Picking what to run: `-s` (select)

| You type | It runs |
|---|---|
| `-s stg_orders` | just `stg_orders` |
| `-s stg_orders+` | `stg_orders` **and everything downstream** of it |
| `-s +fct_orders` | `fct_orders` **and everything upstream** it depends on |
| `-s staging` | every model in the `models/staging/` folder |
| `-s staging modeled` | both folders |

Works with `run`, `test`, `build`, and `show`.

---

## `dbt show` options

```bash
uv run dbt show -s stg_orders --limit 20          # more rows (default is 5)
uv run dbt show --inline "select count(*) from {{ ref('stg_orders') }}"
```

`--inline` runs a one-off query without making a file. It's handy for quick checks.

---

## When things go wrong

| Problem | Try |
|---|---|
| A model fails | Read the error, fix the SQL, then `uv run dbt run -s <model>` again |
| A test fails | `uv run dbt test -s <model>` to see which test. The error message names the column. |
| "Weird" results after renaming files | `uv run dbt clean` then `uv run dbt run` |
| Can't connect | `uv run dbt debug`, then see Part 6 of [setup/getting-started.md](setup/getting-started.md) |

---

## Git basics (saving your work)

```bash
git status                     # what changed?
git add .                      # stage everything
git commit -m "Add stg_sellers"
git push                       # send it to your fork on GitHub
```

**Getting each week's updates:** on your fork's GitHub page, click **Sync fork → Update
branch**, then `git pull` (or **Pull** in VS Code). Commit your own work first.
