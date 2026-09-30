{#
  One row per calendar day. A GENERATED dimension: it isn't loaded from any source.

  Why bother, when every fact already has a date? Because "sales by weekday" or
  "compare Q4 to Q3" then becomes a join and a group by, instead of every analyst
  re-writing date math slightly differently.

  Range covers all Olist activity (Sept 2016 to Oct 2018) with room on each side.
#}

with days as (

    -- generator() makes 1,096 empty rows (2016-01-01 through 2018-12-31);
    -- row_number() turns them into 0, 1, 2, ... days after the start date.
    select dateadd(day, row_number() over (order by seq4()) - 1, date '2016-01-01') as date_day
    from table(generator(rowcount => 1096))

)

select
    date_day,

    year(date_day)                    as year,
    quarter(date_day)                 as quarter,
    month(date_day)                   as month,
    to_char(date_day, 'MMMM')         as month_name,    -- 'January'
    to_char(date_day, 'YYYY-MM')      as year_month,
    cast(date_trunc('month', date_day) as date) as month_start,

    weekiso(date_day)                 as week_of_year,
    dayofweekiso(date_day)            as day_of_week,   -- 1 = Monday ... 7 = Sunday

    -- Snowflake's dayname() only gives 'Mon', 'Tue', ... so spell them out.
    decode(dayofweekiso(date_day),
        1, 'Monday', 2, 'Tuesday', 3, 'Wednesday', 4, 'Thursday',
        5, 'Friday', 6, 'Saturday', 7, 'Sunday') as day_name,

    dayofweekiso(date_day) in (6, 7)  as is_weekend

from days
