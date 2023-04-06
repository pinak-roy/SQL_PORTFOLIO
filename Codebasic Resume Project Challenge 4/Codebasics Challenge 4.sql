/*Provide the list of markets in which customer "Atliq Exclusive" operates its
business in the APAC region.*/
-- 
select market 
from dim_customer dc
where customer like 'Atliq Exclusive' and region like 'APAC';

/*What is the percentage of unique product increase in 2021 vs. 2020? The
final output contains these fields,
unique_products_2020
unique_products_2021
percentage_chg*/
-- 
with  products as (
  select fiscal_year, count(distinct product_code) as 'product_count'
  from fact_sales_monthly fsm
  where fiscal_year  in (2020, 2021)
  group by fiscal_year 
)
select p1.product_count as unique_products_2020,
       p2.product_count as unique_products_2021,
       ROUND((p2.product_count - p1.product_count) / CAST(p1.product_count AS FLOAT) * 100, 0) as percentage_chg
from products p1
join products p2 on p1.fiscal_year = 2020 and p2.fiscal_year = 2021;

/*Provide a report with all the unique product counts for each segment and
sort them in descending order of product counts. The final output contains
2 fields,
segment
product_count*/
-- 
select segment, count(distinct(product_code)) as 'product_count' 
from dim_product dp 
group by segment
order by 'product_count' desc;

/*Follow-up: Which segment had the most increase in unique products in
2021 vs 2020? The final output contains these fields,
segment
product_count_2020
product_count_2021
difference*/
with products as (
   select dp.segment, fsm.fiscal_year, count(distinct(dp.product_code)) as 'product_count'
   from dim_product dp 
   join fact_sales_monthly fsm on dp.product_code = fsm.product_code 
   where fsm.fiscal_year in (2020,2021)
   group by dp.segment, fsm.fiscal_year
)
select p2.segment,p1.product_count as product_count_2020 ,
       p2.product_count as product_count_2021,
       (p2.product_count - p1.product_count) AS 'difference'
from products p1
join products p2 on p1.fiscal_year = 2020 and p2.fiscal_year = 2021
group by p2.segment, p1.product_count, p2.product_count
order by 'difference' desc;
/*Get the products that have the highest and lowest manufacturing costs.
The final output should contain these fields,
product_code
product
manufacturing_cost*/
-- 
with product_info as (
  select dp.product_code, dp.product, fmc.manufacturing_cost 
  from fact_manufacturing_cost fmc 
  join dim_product dp on fmc.product_code = dp.product_code
)
select product_code, product, manufacturing_cost
from product_info
where manufacturing_cost = (
  select max(manufacturing_cost) from product_info
)
or manufacturing_cost = (
  select min(manufacturing_cost) from product_info
);

/*Generate a report which contains the top 5 customers who received an
average high pre_invoice_discount_pct for the fiscal year 2021 and in the
Indian market. The final output contains these fields,
customer_code
customer
average_discount_percentage*/
-- 
select top 5 dc.customer_code, dc.customer, avg(fpid.pre_invoice_discount_pct)*100 as 'average_discount_percentage'
from fact_pre_invoice_deductions fpid 
join dim_customer dc on fpid.customer_code = dc.customer_code 
where dc.market like 'India' and fpid.fiscal_year = '2021'
group by dc.customer_code, dc.customer
order by 'average_discount_percentage' desc

/*Get the complete report of the Gross sales amount for the customer “Atliq
Exclusive” for each month . This analysis helps to get an idea of low and
high-performing months and take strategic decisions.
The final report contains these columns:
Month
Year
Gross sales Amount*/
-- 
with months_name as (select fsm.[date] ,  DATENAME(month, fsm.[date]) as 'month_name'
from fact_sales_monthly fsm
)
select months_name.month_name as 'Month', fgp.fiscal_year as 'Year', sum(fgp.gross_price*fsm.sold_quantity) as 'Gross sales Amount'
from fact_gross_price fgp 
join fact_sales_monthly fsm on fgp.product_code = fsm.product_code
join months_name on fsm.[date]  = months_name.[date]
join dim_customer dc on fsm.customer_code = dc.customer_code 
where dc.customer like 'Atliq Exclusive'
group by months_name.month_name, fgp.fiscal_year;

/*In which quarter of 2020, got the maximum total_sold_quantity? The final
output contains these fields sorted by the total_sold_quantity,
Quarter
total_sold_quantity*/
with sales_table as (SELECT *, 
    CASE 
        WHEN MONTH(fsm.[date]) BETWEEN 9 AND 11 THEN 'Q1'
        WHEN MONTH(fsm.[date]) BETWEEN 12 AND 2 THEN 'Q2'
        WHEN MONTH(fsm.[date]) BETWEEN 3 AND 5 THEN 'Q3'
        ELSE 'Q4'
    END as quar_ter
FROM fact_sales_monthly fsm
)
select st.quar_ter, sum(st.sold_quantity) as 'sumation'
from sales_table st
group by st.quar_ter

/*Which channel helped to bring more gross sales in the fiscal year 2021
and the percentage of contribution? The final output contains these fields,
channel
gross_sales_mln
percentage*/
-- 
WITH ta_bale as (SELECT SUM(fsm.sold_quantity* fgp.gross_price) as 'gross_sales_mln', dc.channel as 'channel' 
FROM fact_gross_price fgp 
JOIN fact_sales_monthly fsm on fgp.product_code = fsm.product_code 
JOIN dim_customer dc on fsm.customer_code = dc.customer_code
WHERE fsm.fiscal_year = '2021'
GROUP BY dc.channel 
)
SELECT *, gross_sales_mln/(SELECT SUM(tb.gross_sales_mln) from ta_bale tb)*100 as 'percentage' 
FROM ta_bale tb;

/*Get the Top 3 products in each division that have a high
total_sold_quantity in the fiscal_year 2021? The final output contains these
fields,
division
product_code
 product
total_sold_quantity
rank_order*/

