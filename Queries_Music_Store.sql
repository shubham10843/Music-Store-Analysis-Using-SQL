create database music;
use music;


/*								Question Set 1 - Easy */


/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1;

/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC;

/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;



/* 								Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT artist.artist_id, artist.name,COUNT(artist.artist_id) AS number_of_songs
FROM track
JOIN album ON album.album_id = track.album_id
JOIN artist ON artist.artist_id = album.artist_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
GROUP BY artist.artist_id
ORDER BY number_of_songs DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name,miliseconds
FROM track
WHERE miliseconds > (
	SELECT AVG(miliseconds) AS avg_track_length
	FROM track )
ORDER BY miliseconds DESC;


/* 									Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? 
Write a query to return customer name, artist name and total spent */

SELECT * FROM invoice;
WITH CTE AS (
SELECT artist.artist_id, ROUND(sum(invoice_line.unit_price*invoice_line.quantity),4) from invoice_line
join track on track.track_id=invoice_line.Track_id
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
group by 1
order by 2 DESC
limit 1
)
SELECT invoice.customer_id, concat(customer.first_name,' ',customer.last_name) as Customer_Name, 
ROUND(sum(invoice_line.unit_price*invoice_line.quantity),4) as Total_Spend, artist.name Artist_Name
from customer
join invoice on customer.customer_id=invoice.customer_id
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.Track_id
join album2 on album2.album_id=track.album_id
join artist on artist.artist_id=album2.artist_id
group by invoice.customer_id,concat(customer.first_name,' ',customer.last_name), artist.name
order by 3 DESC;

/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

WITH CTE AS
(
SELECT invoice.billing_country, COUNT(invoice_line.track_id) as Purchase, 
genre.genre_id, genre.name, 
ROW_NUMBER() OVER (partition by invoice.billing_country order by COUNT(invoice_line.quantity) DESC ) as Row_NUM
from invoice
join invoice_line on invoice.invoice_id=invoice_line.invoice_id
join track on track.track_id=invoice_line.Track_id
join genre on track.genre_id=genre.genre_id
group by 1,3,4
order by 1 DESC , 2
)
select * from CTE
where Row_NUM <=1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH CTE AS
(
SELECT invoice.billing_country, customer.first_name,last_name, 
ROUND(sum(total),4) as Total_Spend,
ROW_NUMBER() OVER (partition by invoice.billing_country order by ROUND(sum(total),4) DESC ) as Row_NUM
from customer
join invoice on customer.customer_id= invoice.customer_id
group by 1,2,3
order by 1 DESC , 2
)
select * from CTE
where Row_NUM <=1
order by Total_Spend DESC;


SELECT * FROM customer;
SELECT * FROM TRACK;
SELECT * FROM invoice_line;
SELECT * FROM playlist;
SELECT * from playlist_track;