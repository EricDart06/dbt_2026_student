# Sandbox Data

Two small, fun, single-table datasets for **SQL practice** (session 2), before we touch
the Olist project. One table each, no joins needed, so you can focus on
`SELECT` → `WHERE` → `GROUP BY` → CTE.

They're already loaded in Snowflake (`DBT_LABS_DB.PUBLIC.KIDSFEET` and `.OLYMPICS`).
Practice in the sandbox files, which read them for you:

| Table | Sandbox file | Questions |
|---|---|---|
| kidsfeet | `dbt/models/sandbox/kidsfeet_sandbox.sql` | [docs/sql_practice.md](../../docs/sql_practice.md), Part A |
| olympics | `dbt/models/sandbox/olympics_sandbox.sql` | [docs/sql_practice.md](../../docs/sql_practice.md), Part B |

---

## `kidsfeet` — 39 rows

Measurements of the feet of 39 fourth-graders (from the R package `mosaicData`).
**One row is:** one child.

| Column | Type | Meaning | Example |
|---|---|---|---|
| `name` | text | Child's first name | `David` |
| `birthmonth` | int | Month of birth (1–12) | `5` |
| `birthyear` | int | Year of birth, **two digits** (87 or 88 = 1987/1988) | `88` |
| `length` | decimal | Length of the longer foot, cm | `24.4` |
| `width` | decimal | Width of the longer foot at its widest, cm | `8.4` |
| `sex` | text | `B` = boy, `G` = girl | `B` |
| `biggerfoot` | text | Which foot is bigger: `L` or `R` | `L` |
| `domhand` | text | Dominant hand: `L` or `R` | `R` |

**Good first questions:** Do boys have longer feet than girls? Is the bigger foot usually
on the same side as the dominant hand? Who has the widest foot?

---

## `olympics` — 271,116 rows

Every athlete in every event of the modern Olympics, **1896–2016**, Summer and Winter
(the "120 years of Olympic history" dataset, via TidyTuesday).
**One row is:** one athlete **in one event** at one Games. An athlete who swam 4 events
at 2 Olympics has 8 rows.

| Column | Type | Meaning | Example |
|---|---|---|---|
| `id` | int | Athlete id. Same across all their rows (135,571 athletes) | `1` |
| `name` | text | Athlete's full name | `A Dijiang` |
| `sex` | text | `M` or `F` | `M` |
| `age` | int | Age at the Games. Null for ~9,500 rows | `24` |
| `height` | int | Height in cm. Null for ~60,000 rows | `180` |
| `weight` | decimal | Weight in kg. Null for ~63,000 rows | `80` |
| `team` | text | Team name (sometimes a club, e.g. `Denmark/Sweden`) | `China` |
| `noc` | text | 3-letter National Olympic Committee code: use this for "country" | `CHN` |
| `games` | text | Year + season | `1992 Summer` |
| `year` | int | Year of the Games | `1992` |
| `season` | text | `Summer` or `Winter` | `Summer` |
| `city` | text | Host city | `Barcelona` |
| `sport` | text | Sport | `Basketball` |
| `event` | text | Specific event | `Basketball Men's Basketball` |
| `medal` | text | `Gold`, `Silver`, `Bronze`, or **null** (no medal: 85% of rows) | `Gold` |

**Watch out:** in **team events every team member gets a row**, so counting medal rows
counts a basketball gold 12 times. A great "what does one row mean?" lesson.

**Good first questions:** Which country has the most gold medals? How has the average
age of athletes changed over time? Which sport has the tallest athletes? When did women
first compete in each sport?
