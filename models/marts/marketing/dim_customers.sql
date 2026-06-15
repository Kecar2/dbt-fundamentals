with customers as (

    select *
    from {{ ref('stg_jaffle_shop__customers') }}

),

orders as (

    select *
    from {{ ref('stg_jaffle_shop__orders') }}

),

customer_orders as (

    select
        customer_id,
        min(order_date) as first_order_date,
        max(order_date) as most_recent_order_date,
        count(order_id) as number_of_orders

    from orders

    group by customer_id

),

customer_payments as (

    select
        o.customer_id,
        sum(p.amount) as total_amount

    from orders o

    left join {{ ref('stg_stripe__payments') }} p
        on p.orderid = o.order_id

    group by o.customer_id

),

final as (

    select
        c.customer_id,
        c.first_name,
        c.last_name,
        co.first_order_date,
        co.most_recent_order_date,
        coalesce(co.number_of_orders, 0) as number_of_orders,
        coalesce(cp.total_amount, 0) as total_amount

    from customers c

    left join customer_orders co
        on co.customer_id = c.customer_id

    left join customer_payments cp
        on cp.customer_id = c.customer_id

)

select *
from final