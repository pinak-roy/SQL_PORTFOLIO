-- Who is the senior most employee based on the job title
SELECT TOP 1 CONCAT(first_name,' ',last_name) as 'Full Name', levels  
FROM employee e 
order by levels DESC 

-- Which Countries have the most invoices
SELECT billing_country, COUNT(billing_country) as 'Count of Country'
FROM invoice i 
group by billing_country 
order by 'Count of Country' DESC;

-- What are the top 3 values of total invoices
SELECT TOP 3 invoice_id, total as 'D_TOTAL' 
FROM invoice i 
order by 'D_TOTAL' DESC 

/*Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals*/
SELECT billing_city, SUM(total) as 'SUM'
FROM invoice i 
group by billing_city 
order by 'SUM' DESC;

/*Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/
SELECT TOP 1 c.customer_id, c.first_name, c.last_name, SUM(total) as 'SUM'
FROM customer c
JOIN invoice i on c.customer_id = i.customer_id 
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY 'SUM' DESC

/*Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */
SELECT c.first_name, c.last_name, c.email, g.name  
FROM customer c 
JOIN invoice i on c.customer_id = i.customer_id 
JOIN  invoice_line il on i.invoice_id = il.invoice_id 
JOIN track t on il.track_id = t.track_id 
JOIN genre g on t.genre_id = g.genre_id
ORDER BY email;

/*Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */
SELECT a.name, COUNT(a.name) as 'num of songs'
FROM artist a 
JOIN album a2 on a.artist_id = a2.artist_id 
JOIN track t on a2.album_id = t.album_id 
JOIN genre g  on t.genre_id  = g.genre_id 
WHERE g.name LIKE 'Rock'
group BY a.name 
ORDER BY 'num of songs' DESC 

/*Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */
SELECT name, milliseconds as 'length'
FROM track t 
WHERE milliseconds > (
      SELECT AVG(milliseconds)
      from track t2 
      )
order by  'length'   DESC ;


/*Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

WITH best_selling_artist AS (
                             SELECT TOP 1 a2.artist_id, a2.name as 'artist_name', SUM(il.unit_price*il.quantity) as 'Total Sales' 
                             FROM invoice_line il 
                             JOIN track t on il.track_id = t.track_id 
                             JOIN album a on t.album_id = a.album_id 
                             JOIN artist a2 on a.artist_id = a2.artist_id 
                             GROUP BY  a2.artist_id , a2.name
                             ORDER BY 'Total Sales' DESC 
                             )                             
SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unit_price*il.quantity) AS 'amount_spent'
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY c.customer_id, c.first_name, c.last_name, bsa.artist_name
ORDER BY 'amount_spent' DESC 


/*We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. 
For countries where the maximum number of purchases is shared return all Genres. */

SELECT g.name,c.country, COUNT(il.quantity) as 'count',
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS 'RowNo'
FROM customer c 
JOIN invoice i on c.customer_id = i.customer_id 
JOIN invoice_line il on i.invoice_id = il.invoice_id 
JOIN track t on il.track_id = t.track_id 
JOIN genre g on t.genre_id = g.genre_id
GROUP BY g.name, c.country 
ORDER BY 'count' DESC, 'RowNo' ASC

---
WITH Customter_with_country AS (
		SELECT TOP 100 percent customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY customer.customer_id,first_name,last_name,billing_country
		ORDER BY billing_country ASC,total_spending DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
      
      
     

