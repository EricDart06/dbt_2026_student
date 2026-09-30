{#
  TOGETHER (session 4): dim_products
  We write this one as a class. Fill in each TODO as we go.

  One row is: a product, with an ENGLISH category name.

  The category names in stg_products are in Portuguese. The translations are in a SEED:
  a small CSV in dbt/seeds/ that dbt loads for us. dbt made it, so we reach it with
  ref(), the same as a model. (Raw tables dbt didn't make use source().)

  Check it with the Preview button. Done when this passes:

      uv run dbt build -s dim_products
#}

-- 1. The products, from staging. (Done for you.)
with products as (

    select * from {{ ref('stg_products') }}

),

-- 2. The translations, from the seed.
translations as (

    -- TODO: select everything from the seed named  product_category_name_translation.
    --       Use ref(), exactly like the products CTE above.

)

-- 3. Every product, plus its English category name.
select
    products.product_id,

    -- TODO: the English category name, called category_name. Three cases, in order:
    --   1. there's a translation                 -> translations.product_category_name_english
    --   2. no translation, but a Portuguese name -> products.category_name_pt
    --   3. no category at all (610 products)     -> 'unknown'
    --   coalesce(a, b, c) returns the first one that isn't null. Don't forget the comma!

    products.category_name_pt,

    products.name_length,
    products.description_length,
    products.photo_count,
    products.weight_g,
    products.length_cm,
    products.height_cm,
    products.width_cm,
    products.volume_cm3

from products
-- TODO: LEFT JOIN translations, matching products.category_name_pt
--       to translations.product_category_name.
--       Why LEFT and not a plain (inner) join? An inner join keeps only products that
--       HAVE a translation, so the 610 products with no category would disappear.
