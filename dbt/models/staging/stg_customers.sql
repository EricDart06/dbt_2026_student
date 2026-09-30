{#
  TOGETHER (session 3): stg_customers
  We write this one as a class. Fill in each TODO as we go.

  One row is: a customer ON ONE ORDER. (Olist gives the same person a new customer_id
  for every order. The real person is customer_unique_id. Remember that for session 4!)

  Check it with the Preview button. Done when this passes:

      uv run dbt build -s stg_customers
#}

-- 1. SOURCE: load it, and nothing else.
with source as (

    -- TODO: select everything from the raw customers table.
    --       Copy the source line from stg_orders.sql and change 'orders' to 'customers'.

),

-- 2. RENAMED: rename + cast + clean. One line per column, separated by commas.
--    Cast every column, even if it's already the right type: the casts are this
--    model's promise about what its columns are.
renamed as (

    select
        -- TODO: customer_id, cast as varchar. Keep the name.

        -- TODO: customer_unique_id, cast as varchar. Keep the name.

        -- TODO: customer_zip_code_prefix, cast as varchar, renamed to zip_code_prefix.
        --       (Text, not a number: as a number, 01003 would lose its leading zero.)

        -- TODO: customer_city, cleaned with lower(trim(...)), renamed to city.

        -- TODO: customer_state, cleaned with upper(trim(...)), renamed to state.

    from source

),

-- 3. DEDUPLICATED: one row per customer_id.
deduplicated as (

    -- TODO: keep one row per customer_id. customer_id is already unique here, but every
    --       staging model keeps this stage so they all look the same:
    --
    --       select * from renamed
    --       qualify row_number() over (
    --           partition by customer_id
    --           order by customer_unique_id
    --       ) = 1

),

-- 4. DERIVED: nothing to compute for customers.
derived as (

    select * from deduplicated

)

select * from derived
