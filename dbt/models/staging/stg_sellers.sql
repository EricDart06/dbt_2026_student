{#
  ON YOUR OWN (session 3): stg_sellers
  One row per seller, cleaned up from the raw sellers table.

  Before you start, look at the raw columns in docs/data_dictionary.md -> sellers.
  Fill in the TODOs in step 2. Steps 1, 3 and 4 are done for you.

  Done when this passes (it also runs the tests that check your city cleaning):

      uv run dbt build -s staging

  Stuck? Look at stg_customers.sql, which we wrote together: this is the same shape
  plus one cleanup.
#}

-- 1. SOURCE: load it, and nothing else.
with source as (

    select * from {{ source('olist', 'sellers') }}

),

-- 2. RENAMED: rename + cast + clean. One line per column, separated by commas.
renamed as (

    select
        -- TODO: seller_id, cast as varchar. Keep the name seller_id.

        -- TODO: seller_zip_code_prefix, cast as varchar, renamed to zip_code_prefix.
        --       (Text, not a number: some zip codes start with 0!)

        -- TODO: seller_city, cleaned, renamed to city.
        --   A few sellers typed junk into their city. Two fixes:
        --     'auriflama/sp'                 -> keep the part before the '/'
        --                                       split_part(seller_city, '/', 1)
        --     '04482255', 'vendas@creditparts.com.br'  -> not a city at all, so null
        --                                       regexp_like(seller_city, '.*[0-9@].*')
        --                                       is true for these
        --   Combine them with   case when ... then null else ... end
        --   and wrap the city in lower(trim(...)) so they all look the same.

        -- TODO: seller_state, cleaned with upper(trim(...)), renamed to state.

    from source

),

-- 3. DEDUPLICATED: one row per seller. seller_id is already unique in the raw data,
--    but we keep the stage so every staging model has the same shape.
deduplicated as (

    select * from renamed
    qualify row_number() over (
        partition by seller_id
        order by zip_code_prefix
    ) = 1

),

-- 4. DERIVED: nothing to compute for sellers.
derived as (

    select * from deduplicated

)

select * from derived
