# SQL Practice — session 2 + warm-ups

Parts A and B are session 2: we work through them **together**. Part C has a 5-minute
warm-up for the start of sessions 3–6. Open the sandbox file, write the query
inside the second CTE, and run it with the **Preview** button above the CTE (or
`uv run dbt show -s kidsfeet_sandbox` in the terminal).

```sql
with kidsfeet as (                 -- 1. gets the data. Leave it alone.
    select * from {{ source('sandbox', 'kidsfeet') }}
),

kidsfeet_sandbox as (              -- 2. YOUR QUERY GOES HERE
    select *
    from kidsfeet
)

select * from kidsfeet_sandbox
```

Column notes for both tables: [data/sandbox/README.md](../data/sandbox/README.md).

---

## Part A — kidsfeet: pick columns, filter, sort, make new columns

File: `dbt/models/sandbox/kidsfeet_sandbox.sql`. 39 fourth-graders, one row per kid.

**K1.** Show every column and every row. How many kids are in the table?


**K2.** Show only each kid's name, sex, and foot length.


**K3.** Show only the girls.


**K4.** Which kids have feet 25 cm or longer? Longest first.


**K5.** Show the boys whose bigger foot is the left one.


**K6.** Who has the 5 widest feet?


### New columns

**K7.** Add a new column: foot length in **inches** (1 inch = 2.54 cm), rounded to 1 decimal.


**K8.** Add a column `foot_ratio` = length ÷ width. Who has the skinniest foot (highest ratio)?


**K9.** Add a column `foot_size` that says `'big'` for 25 cm or longer and `'small'` otherwise.


**K10.** Whose bigger foot is on the same side as their dominant hand?


---

## Part B — olympics: group, count, and summarize

File: `dbt/models/sandbox/olympics_sandbox.sql`. Every athlete in every event, 1896–2016.

**O1.** Look at 10 rows with just `name, sex, age, sport, year, medal`. What does an empty medal mean? Why is Christine in 6 rows?


**O2.** How many rows are there? How many *different* athletes?


**O3.** How many gold, silver, and bronze rows are there?


**O4.** Which 10 countries (`noc`) have the most gold rows? *(Remember this answer for O10.)*


**O5.** How many athletes went to each **Summer** Games?


**O6.** Who are the top 10 gold medalists of all time?


**O7.** Which sports have the tallest athletes? Only include sports with at least 1,000 measured heights.


**O8.** What were the youngest and oldest ages of a medalist in each sport?


**O9.** What percent of athletes at each Summer Games were women?


### CTEs: one step at a time

When a question needs **two steps** (first build something, then summarize it), add a
new CTE between the data CTE and your sandbox CTE. Each CTE reads from the one above it:

```sql
with olympics as (        -- 1. the data
    ...
),

my_step as (              -- 2. NEW: do the first step
    select ... from olympics
),

olympics_sandbox as (     -- 3. finish the answer, reading from YOUR step
    select ... from my_step
)

select * from olympics_sandbox
```

This is exactly how every dbt model in this project is written: a chain of small,
named steps.

**O10.** **CTE.** O4 said USA has 2,638 gold rows, but in a team event every player gets a row. A basketball gold counts 12 times! Count **one gold per event** instead.


**O11.** **CTE.** Who went to the most different Olympic Games?


**O12.** **CTE.** In which year did the most countries go to their *first* Olympics?


---

## Part C — Warm-ups: 5 minutes at the start of each session

So SQL doesn't get rusty: one short challenge at the start of sessions 3–6, in the
sandbox file it names. Each one previews that day's topic.

**W3. Session 3 (staging).** **kidsfeet.** Show the girls' names in CAPITAL LETTERS as `kid_name`, and their foot length in inches as `length_inches` (rounded to 1 decimal), longest first.


**W4. Session 4 (star schema).** **olympics.** In 2016, which 5 sports had the most athletes? Show the number of athletes *and* the number of events for each.


**W5. Session 5 (testing).** **Two checks.** (a) Is `name` unique in kidsfeet? Find every name used more than once. (b) How many olympics rows are missing a `height`?


**W6. Session 6 (hackathon prep).** **olympics, with a CTE.** Which 5 countries won the most gold medals at the 2016 Olympics, counting **one medal per event**?

