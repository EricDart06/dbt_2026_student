{#
  ON YOUR OWN (session 4): dim_sellers
  A DIMENSION describes a thing. One row here is: one seller.

  Your stg_sellers already did the hard work (clean, one row per seller), so this file
  is short. dim_products.sql, which we wrote together, shows the idea: yours is even
  simpler, because it needs no join.

  Done when the whole project builds:

      uv run dbt build
#}

-- TODO: select seller_id, zip_code_prefix, city, and state from YOUR staging model.
--       Use {{ ref('stg_sellers') }}, not source(): dbt built stg_sellers, so it's a ref.
