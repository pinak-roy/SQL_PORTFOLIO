/* We have 4 Data tables
1. customers
2. products
3. orders
4. order_items */

/* Which product has the highest price? Only return a single row. */
select product_name, max(price) as prices
from products
group by product_name
order by prices desc
limit 1

/* Which customer has made the most orders? */
select x.customer_id, max(y.quantity)
from orders x
join order_items y on x.order_id = y.order_id
group by 1
order by 2 desc
limit 1

/* What’s the total revenue per product? */
select p.product_name, sum(p.price*i.quantity) as sales_revenue
from products p
join order_items i on p.product_id=i.product_id
group by p.product_name 
order by sales_revenue desc


/* What’s the total revenue per product? */
select j.order_date, sum(p.price*i.quantity) as sales_revenue
from products p
join order_items i on p.product_id=i.product_id
join orders j on i.order_id=j.order_id
group by j.order_date 
order by sales_revenue desc
limit 1

/* Find the first order (by date) for each customer. */
select j.customer_id, j.order_date, row_number() over(partition by j.customer_id order by j.order_date)
from products p
join order_items i on p.product_id=i.product_id
join orders j on i.order_id=j.order_id

/* Which product has been bought the least in terms of quantity? */
select p.product_name , sum(i.quantity) as quan_tity
from products p
join order_items i on p.product_id=i.product_id
group by p.product_name
order by quan_tity asc

/* Find the top 3 customers who have ordered the most distinct products */
select j.customer_id, count(distinct p.product_name) as dis_product
from products p
join order_items i on p.product_id=i.product_id
join orders j on i.order_id=j.order_id
group by j.customer_id
order by dis_product desc
limit 3

/* What is the median order total? */
with abc as(
select  x.order_id, sum(y.quantity) as total_quantity
from orders x
join order_items y on x.order_id = y.order_id
group by x.order_id
  )
  
  select percentile_cont(0.5) within group (order by total_quantity) as median_order
  from abc

/* For each order, determine if it was ‘Expensive’ (total over 300), ‘Affordable’ (total over 100), or ‘Cheap’.*/
with sales_table as(
select i.order_id, sum(p.price*i.quantity) as sales_revenue
from products p
join order_items i on p.product_id=i.product_id
join orders j on i.order_id=j.order_id
group by i.order_id
  )
  
  select order_id, sales_revenue,
       case 
           when sales_revenue > 300 then 'Expensive'
           when sales_revenue > 100 then 'Affordable'
           else 'Cheap'
       end as order_category
  from sales_table

/* Find customers who have ordered the product with the highest price. */
select j.customer_id, p. price
from products p
join order_items i on p.product_id=i.product_id
join orders j on i.order_id=j.order_id
order by p.price desc
limit 2


