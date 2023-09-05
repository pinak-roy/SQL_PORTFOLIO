/*Find the total cost of each customer's orders. Output customer's id, first name, and the total order cost. Order records by customer's first name alphabetically. */

select c.id, c.first_name, sum(o.total_order_cost) as cost
from customers c 
left join orders o on c.id = o.cust_id
group by c.id, c.first_name
order by c. first_name asc


/*Find the number of apartments per nationality that are owned by people under 30 years old. Output the nationality along with the number of apartments. Sort records by the apartments count in descending order.*/

select x.nationality, count(distinct y.unit_id) as counted
from airbnb_hosts x
join airbnb_units y on x.host_id = y.host_id
where x.age < 30 and y.unit_type = 'Apartment'
group by 1

/*Find the number of rows for each review score earned by 'Hotel Arena'. Output the hotel name (which should be 'Hotel Arena'), review score along with the corresponding number of rows with that score for the specified hotel.*/
select hotel_name, reviewer_score, count(*)
from hotel_reviews
where hotel_name = 'Hotel Arena'
group by hotel_name, reviewer_score