-- SQL SANDBOX: olympics (every athlete in every event, 1896-2016)
-- Columns: id, name, sex, age, height, weight, team, noc, games, year, season,
--          city, sport, event, medal       (details in data/sandbox/README.md)
-- One row is one athlete in ONE event, so the same person shows up many times.
--
-- Write your query inside `olympics_sandbox` below, then run it with the Run/Preview
-- button above the CTE, or in the terminal:
--
--     uv run dbt show -s olympics_sandbox
--     uv run dbt show -s olympics_sandbox --limit 50     (more rows)
--
-- Nothing is saved to the database, so break it as often as you like.

-- 1. Get the data. Leave this one alone.
with olympics as (

    select * from {{ source('sandbox', 'olympics') }}

),

-- 2. YOUR QUERY GOES HERE. Always select `from olympics`.
--    Practice questions: docs/sql_practice.md
olympics_sandbox as (

    select *
    from olympics

)

select * from olympics_sandbox
