{# GRAIN: one row per payment. #}

with payments as (

    select * from {{ ref('stg_order_payments') }}

),

orders as (

    select order_id, purchase_date from {{ ref('stg_orders') }}

)

select
    payments.order_payment_key,
    payments.order_id,    -- degenerate dimension
    payments.payment_number,
    orders.purchase_date,

    payments.payment_type,
    payments.installments,
    payments.amount

from payments
inner join orders
    on payments.order_id = orders.order_id
