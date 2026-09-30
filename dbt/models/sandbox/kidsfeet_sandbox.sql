-- SQL SANDBOX: kidsfeet (39 fourth-graders and their feet)
-- Columns: name, birthmonth, birthyear, length, width, sex, biggerfoot, domhand
--          (details in data/sandbox/README.md)
--
-- Write your query inside `kidsfeet_sandbox` below, then run it with the Run/Preview
-- button above the CTE, or in the terminal:
--
--     uv run dbt show -s kidsfeet_sandbox
--     uv run dbt show -s kidsfeet_sandbox --limit 50     (more rows)
--
-- Nothing is saved to the database, so break it as often as you like.

-- 1. Get the data. Leave this one alone.
with kidsfeet as (

    select * from {{ source('sandbox', 'kidsfeet') }}

),

-- 2. YOUR QUERY GOES HERE. Always select `from kidsfeet`.
--    Practice questions: docs/sql_practice.md

kidsfeet_sandbox as (

    select *
    from kidsfeet

)

select * from kidsfeet_sandbox
