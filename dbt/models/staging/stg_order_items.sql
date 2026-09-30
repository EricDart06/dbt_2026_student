with source as (

    select * from {{ source('olist', 'order_items') }}

),

renamed as (

    select
        cast(order_id   as varchar) as order_id,
        -- `order_item_id` sounds like a unique id, but it's the item's position in
        -- the order (1, 2, 3...). Rename it to say what it is.
        cast(order_item_id as integer) as item_number,
        cast(product_id as varchar) as product_id,
        cast(seller_id  as varchar) as seller_id,

        cast(shipping_limit_date as timestamp) as shipping_limit_at,

        -- Money is always decimal, never float: floats can't store 0.10 exactly.
        cast(price         as decimal(10, 2)) as price,
        cast(freight_value as decimal(10, 2)) as freight_value

    from source

),

-- One row per (order_id, item_number). Two columns make up the grain here.
-- No-op on this data; the unique test on order_item_key proves it.
deduplicated as (

    select * from renamed
    qualify row_number() over (
        partition by order_id, item_number
        order by shipping_limit_at desc
    ) = 1

),

derived as (

    select
        -- A one-column key for a two-column grain, so other tables can point at a
        -- single item.
        order_id || '-' || cast(item_number as varchar) as order_item_key,
        *,
        price + freight_value as item_total

    from deduplicated

)

select * from derived
