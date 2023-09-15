/* We have tables four tables:
1. Books
2. Customers
3. Orders
4. order_Items
*/
/*Retrieve all books with a price greater than $10. */
select title
from Books
where price > 10

/*Find the total amount spent by each customer in descending order.*/
select name, sum(total_amount) as amount_spent
from Customers c
join Orders o on c.customer_id =o.customer_id
group by name

/*Retrieve the top 3 best-selling books based on the total quantity sold.*/
select i.book_id, sum(quantity) as total_quantity
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
group by i.book_id

/*Find the average price of books in the Fiction genre.*/
select avg(b.price)
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
join Books b on i.book_id = b.book_id
where b.genre = 'Fiction'

/*Find the total revenue generated from book sales.*/
select sum(o.total_amount)
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
join Books b on i.book_id = b.book_id

/*Retrieve the books with titles containing the word “and” (case-insensitive).*/
select b.title
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
join Books b on i.book_id = b.book_id
where b.title like '%and%'

/*Find the customers who have placed orders worth more than $50.*/
select c.name, sum(o.total_amount) as amount
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
join Books b on i.book_id = b.book_id
group by c.name
having sum(o.total_amount) >50

/*Retrieve the book titles and their corresponding authors sorted in alphabetical order by author.*/
select b.title, b.author
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
join Books b on i.book_id = b.book_id
group by b.author, b.title
order by b.author asc

/*Find the customers who have not placed any orders*/
select c.name
from Customers c
join Orders o on c.customer_id =o.customer_id
join Order_Items i on o.order_id = i.order_id
join Books b on i.book_id = b.book_id
where i.quantity = 0
