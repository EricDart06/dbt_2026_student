with source as (

    select * from {{ source('olist', 'products') }}

),

renamed as (

    select
        cast(product_id            as varchar) as product_id,
        cast(product_category_name as varchar) as category_name_pt,

        -- The source misspells "length" as "lenght". Fix it here, once, so nobody
        -- downstream has to remember the typo.
        cast(product_name_lenght        as integer) as name_length,
        cast(product_description_lenght as integer) as description_length,
        cast(product_photos_qty         as integer) as photo_count,

        cast(product_weight_g  as integer) as weight_g,
        cast(product_length_cm as integer) as length_cm,
        cast(product_height_cm as integer) as height_cm,
        cast(product_width_cm  as integer) as width_cm

    from source

),

-- One row per product. Already unique in the source; kept as the pattern.
deduplicated as (

    select * from renamed
    qualify row_number() over (
        partition by product_id
        order by category_name_pt
    ) = 1

),

derived as (

    select
        *,
        length_cm * height_cm * width_cm as volume_cm3

    from deduplicated

)

select * from derived
