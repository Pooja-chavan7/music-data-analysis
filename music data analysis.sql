CREATE DATABASE music_database;

use music_database;

select * from album2;

 -- Q1 Who is the senior most employee based on job title?
 
 select * from employee
 order by levels DESC
 LIMIT 1;
 
 -- Q2 Which countries have the most Invoices?
 
SELECT billing_country, count(*) FROM invoice
GROUP BY billing_country
limit 1;

 -- Q3 What are top 3 values of total invoice? 
 
 select * from invoice;
 
 select * from invoice
 order by total desc
 limit 3;
 
 
-- Q4 Which city has the best customers? We would like to throw a promotional Music 
-- Festival in the city we made the most money. Write a query that returns one city that 
-- has the highest sum of invoice totals. Return both the city name & sum of all invoice totals


select customer_id, billing_city, sum(total) as total_invoice from invoice
group by customer_id, billing_city
order by total_invoice;

-- Q5 Who is the best customer? The customer who has spent the most money will be 
-- declared the best customer. Write a query that returns the person who has spent the 
-- most money


select * from invoice;
select * from customer;

select invoice.customer_id, round(SUM(invoice.total),3) as total, customer.first_name, customer.last_name
from invoice
join customer 
on invoice.customer_id = customer.customer_id
group by invoice.customer_id, customer.first_name, customer.last_name
order by total
LIMIT 1; 

-- Q6 Write query to return the email, first name, last name, & Genre of all Rock Music
-- listeners. Return your list ordered alphabetically by email starting with A


select * from genre;
select * from customer;

SELECT DISTINCT
    customer.email,
    customer.first_name,
    customer.last_name,
    genre.name
FROM
    customer
        JOIN
    invoice ON customer.customer_id = invoice.customer_id
        JOIN
    invoice_line ON invoice.invoice_id = invoice_line.invoice_id
        JOIN
    track ON invoice_line.track_id = track.track_id
        JOIN
    genre ON track.genre_id = genre.genre_id
WHERE
    genre.name = 'rock'
ORDER BY email
;


-- Q7 Let's invite the artists who have written the most rock music in our dataset. Write a
-- query that returns the Artist name and total track count of the top 10 rock bands

select * from artist;
select * from album2;
select * from track;
select * from genre;

select artist.artist_id, artist.name, count(artist.artist_id) as total_track
from artist
join album2 
on artist.artist_id = album2.artist_id
join track
on album2.album_id = track.album_id
where track.genre_id = "1"
group by artist.artist_id, artist.name
order by total_track desc
limit 10;

-- Q8 Return all the track names that have a song length longer than the average song length.
-- Return the Name and Milliseconds for each track. Order by the song length with the
-- longest songs listed first

select * from track;

SELECT name, milliseconds
from track
where milliseconds > (select avg(milliseconds) from track)
group by name, milliseconds
order by milliseconds desc;

-- Q9 Find how much amount spent by each customer on artists? Write a query to return
-- customer name, artist name and total spent

select * from invoice_line;
select * from invoice;
select * from customer;


WITH best_selling_artist as (SELECT artist.name, SUM(invoice_line.unit_price*invoice_line.quantity) as total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album2 ON track.album_id = album2.album_id
JOIN artist ON album2.artist_id = artist.artist_id
GROUP BY artist.name
ORDER BY total_spent desc
limit 1)
SELECT customer.first_name, customer.last_name, artist.name, round(SUM(invoice_line.unit_price*invoice_line.quantity),3) as total_spent
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoice_line ON invoice.invoice_id = invoice_line.invoice_id
JOIN track ON invoice_line.track_id = track.track_id
JOIN album2 ON track.album_id = album2.album_id
JOIN artist ON album2.artist_id = artist.artist_id
JOIN best_selling_artist ON artist.name = best_selling_artist.name
GROUP BY customer.first_name, customer.last_name, artist.name
ORDER BY total_spent desc;

-- Q10 We want to find out the most popular music Genre for each country. We determine the
-- most popular genre as the genre with the highest amount of purchases. Write a query
-- that returns each country along with the top Genre. For countries where the maximum
-- number of purchases is shared return all Genres

select * from genre;
select * from customer;

WITH high_purchase as(select customer.country, genre.name, count(invoice_line.quantity) as total_count,
row_number() OVER(partition by customer.country order by count(invoice_line.quantity) DESC) as ranking
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
join track on invoice_line.track_id = track.track_id
join genre on track.genre_id = genre.genre_id
group by customer.country, genre.name)
select * from high_purchase 
where ranking = 1
order by total_count desc;


-- Write a query that determines the customer that has spent the most on music for each
-- country. Write a query that returns the country along with the top customer and how
-- much they spent. For countries where the top amount spent is shared, provide all
-- customers who spent this amount

select * from customer;
select * from invoice;

with premium_customer as (select customer.first_name, customer.last_name, customer.country, round(SUM(invoice.total),3) as total_spend,
row_number() OVER(partition by customer.country order by SUM(invoice.total) desc) as high_purchase
from customer
join invoice on customer.customer_id = invoice.customer_id
join invoice_line on invoice.invoice_id = invoice_line.invoice_id
group by customer.first_name, customer.last_name, customer.country)
select * from premium_customer 
where high_purchase = 1;














