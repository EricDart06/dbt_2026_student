{#
  STAGING MODEL: four stages, always in this order.

    1. source         load it, and nothing else
    2. renamed        rename + cast + clean. No new logic.
    3. deduplicated   establish the grain: one row per order
    4. derived        add columns we can compute
#}

with source as (

    select * from {{ source('olist', 'orders') }}

),

renamed as (

    select
        cast(order_id     as varchar) as order_id,
        cast(customer_id  as varchar) as customer_id,
        cast(order_status as varchar) as order_status,

        -- The raw names say "timestamp", "_at" and "_date" for the same kind of
        -- thing. Staging picks one convention: `_at` for a timestamp, `_date` for a date.
        cast(order_purchase_timestamp      as timestamp) as purchased_at,
        cast(order_approved_at             as timestamp) as approved_at,
        cast(order_delivered_carrier_date  as timestamp) as shipped_at,
        cast(order_delivered_customer_date as timestamp) as delivered_at,
        cast(order_estimated_delivery_date as date)      as estimated_delivery_date

    from source

),

-- One row per order. The source is already unique on order_id (the source test
-- proves it), so this is a no-op kept as the pattern: if a re-sent file ever
-- duplicates an order, this line keeps the most recent one.
deduplicated as (

    select * from renamed
    qualify row_number() over (
        partition by order_id
        order by purchased_at desc
    ) = 1

),

derived as (

    select
        *,
        cast(purchased_at as date) as purchase_date,
        cast(delivered_at as date) as delivered_date,
        order_status = 'delivered'  as is_delivered,

        -- THE business rule for "did this order count as a sale?", defined ONCE.
        -- Canceled and unavailable orders sold nothing. Every model and mart uses
        -- this flag instead of re-typing the status list.
        order_status not in ('canceled', 'unavailable') as is_sale

    from deduplicated

)

select * from derived
