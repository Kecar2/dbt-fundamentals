with orders as (
select 
    customer_id,
    order_id
from {{ ref('stg_jaffle_shop__orders') }}
),
customer as (
select
    customer_id
from {{ ref('stg_jaffle_shop__customers') }}
),
amount_ as (
select
    orderid as order_id,
    amount
from {{ ref('stg_stripe__payments') }} 
),
union_table as (
select 
    o.order_id,
    c.customer_id,
    a.amount
from orders o
left join customer c on c.customer_id = o.customer_id
left join amount_ a on a.order_id = o.order_id
)
select * from union_table