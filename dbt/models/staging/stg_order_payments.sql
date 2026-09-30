with source as (

    select * from {{ source('olist', 'order_payments') }}

),

renamed as (

    select
        cast(order_id             as varchar)        as order_id,
        -- 1 for the first payment on an order, 2 for the second...
        cast(payment_sequential   as integer)        as payment_number,
        cast(payment_type         as varchar)        as payment_type,
        cast(payment_installments as integer)        as installments,
        cast(payment_value        as decimal(10, 2)) as amount

    from source

),

-- One row per (order_id, payment_number). No-op on this data.
deduplicated as (

    select * from renamed
    qualify row_number() over (
        partition by order_id, payment_number
        order by amount desc
    ) = 1

),

derived as (

    select
        order_id || '-' || cast(payment_number as varchar) as order_payment_key,
        *

    from deduplicated

)

select * from derived
