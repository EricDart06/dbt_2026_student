{#
  SESSION 4 - EXAMPLE (I do): the instructor walks through this one.

  One row per PERSON (customer_unique_id), not per customer_id.

  stg_customers has one row per customer_id, and Olist issues a new customer_id for
  every order. Build the dimension on customer_id and every shopper looks like a
  one-time buyer: repeat customers "disappear". So the dimension's grain is
  customer_unique_id, and fct_orders carries customer_unique_id to join to it.

  A person can order from more than one address (39 people changed states), so we
  take their location from their MOST RECENT order.
#}

with customers as (

    select * from {{ ref('stg_customers') }}

),

orders as (

    select order_id, customer_id, purchased_at from {{ ref('stg_orders') }}

),

customer_orders as (

    select
        customers.customer_unique_id,
        customers.zip_code_prefix,
        customers.city,
        customers.state,
        orders.purchased_at

    from customers
    inner join orders
        on customers.customer_id = orders.customer_id

),

latest_location as (

    select * from customer_orders
    qualify row_number() over (
        partition by customer_unique_id
        order by purchased_at desc
    ) = 1

)

select
    customer_unique_id,
    zip_code_prefix,
    city,
    state

from latest_location
