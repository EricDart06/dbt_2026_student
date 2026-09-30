-- Grain check: each fact must have exactly one row per row of the staging table it
-- is built from. An inner join that drops rows, or a join that fans them out,
-- both fail here. Returns one row per fact that doesn't match.

with counts as (

    select 'fct_orders' as fact,
        (select count(*) from {{ ref('stg_orders') }})      as staged,
        (select count(*) from {{ ref('fct_orders') }})      as modeled
    union all
    select 'fct_order_items',
        (select count(*) from {{ ref('stg_order_items') }}),
        (select count(*) from {{ ref('fct_order_items') }})
    union all
    select 'fct_order_payments',
        (select count(*) from {{ ref('stg_order_payments') }}),
        (select count(*) from {{ ref('fct_order_payments') }})

)

select * from counts
where staged <> modeled
