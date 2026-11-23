USE chinook;

-- What is the total revenue?
SELECT SUM(Total) FROM invoice;

-- Which city has the highest number of invoices?
SELECT BillingCity, SUM(Total) FROM Invoice
GROUP BY BillingCity
ORDER BY SUM(Total) DESC
LIMIT 1;

-- Top 10 countries with most sales
SELECT BillingCountry, SUM(Total) FROM invoice
GROUP BY BillingCountry
ORDER BY SUM(Total) DESC
LIMIT 10;

-- Customer with most number of orders
SELECT CustomerId, COUNT(CustomerId) as TotalOrders
FROM invoice
GROUP BY CustomerId
ORDER BY COUNT(CustomerId) DESC
LIMIT 1;

-- Which customer has spent the most money at the music store?
SELECT CustomerId, SUM(Total) FROM Invoice
GROUP BY CustomerId
ORDER BY SUM(Total) DESC
LIMIT 1;

-- Top 5 customers by total spending
SELECT c.FirstName, c.LastName, SUM(i.Total)
FROM Invoice as i
INNER JOIN customer as c
ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
ORDER BY SUM(i.Total) DESC
LIMIT 5;

-- Which music genre generates the highest revenue?
SELECT g.Name AS GenreName, SUM( i.quantity) AS TotalQuantity, SUM(i.quantity*i.unitprice) AS Revenue 
FROM genre AS g
INNER JOIN track as t
ON g.GenreId = t.genreId
INNER JOIN invoiceline AS i
ON i.TrackId = t.TrackId
GROUP BY g.Name 
ORDER BY SUM(i.quantity*i.unitprice) DESC
LIMIT 1;

-- Write query to return the email, first name, last name of all Rock Music listeners.
SELECT DISTINCT c.Email, c.FirstName, c.LastName FROM customer AS c
INNER JOIN invoice AS i
ON c.CustomerId = i.CustomerId
INNER JOIN invoiceline as il
ON i.InvoiceId = il.InvoiceId
WHERE il.TrackId IN (
    SELECT t.TrackId FROM track AS t
    INNER JOIN Genre AS g ON t.GenreId = g.GenreId
    WHERE g.name LIKE 'Rock'
)
ORDER BY c.email; 

-- Which artist generates the highest revenue for the music store?
SELECT a.Name AS ArtistName, SUM(il.quantity*il.unitprice) AS Revenue FROM artist AS a
INNER JOIN album AS al
ON a.ArtistId = al.ArtistId
INNER JOIN track AS t
ON t.AlbumId = al.AlbumID
INNER JOIN invoiceline as il
ON il.TrackId = t.TrackId
GROUP BY ArtistName, a.ArtistId
ORDER BY Revenue DESC
LIMIT 1;

-- Write a query to find out the month with highest revenue
SELECT MONTH(InvoiceDate) AS Month, SUM(Total) AS HighestRevenue FROM invoice
GROUP BY MONTH(InvoiceDate)
ORDER BY HighestRevenue DESC
LIMIT 1;

-- How does revenue change month by month across different years?
SELECT YEAR(InvoiceDate) AS Year, MONTH(InvoiceDate) AS Month, SUM(Total) AS HighestRevenue FROM invoice
GROUP BY YEAR(InvoiceDate), MONTH(InvoiceDate)
ORDER BY HighestRevenue DESC
LIMIT 5;

-- Return the track names that have a song length longer than the average song length
SELECT AlbumId, Name, Milliseconds FROM track
WHERE Milliseconds > (
    SELECT AVG(milliseconds) AS avg_track_length
    FROM track
)
ORDER BY Milliseconds DESC;

-- Find customers who have placed more than 5 orders.
SELECT c.CustomerId, c.FirstName, c.LastName, COUNT(i.CustomerId) AS Totalorders FROM customer AS C
INNER JOIN invoice AS i
ON c.CustomerId = i.CustomerId
GROUP BY c.CustomerId, c.FirstName, c.LastName
HAVING COUNT(i.CustomerId) > 5;

-- Find customers whose total spending is greater than $40.
SELECT c.CustomerId, c.FirstName, c.LastName, SUM(i.Total) AS TotalSpending FROM customer AS c
INNER JOIN invoice AS i
ON c.CustomerId = i.CustomerId
GROUP BY i.CustomerId, c.FirstName, c.LastName 
HAVING TotalSpending > 40;

-- Identify the total amount each customer has spent on each artist. Return the customer’s name, artist’s name, and total amount spent.
SELECT c.CustomerId, c.FirstName, c.LastName, a.Name,WITH best_selling_artist AS (
	SELECT artist.artisid AS artist_id, artist.name AS artist_name, SUM(invoice_line.unit_price * invoice_line.quantity) AS total_sales
	FROM invoice_line
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN album ON album.album_id = track.album_id
	JOIN artist ON artist.artist_id = album.artist_id
	GROUP BY artist.artist_id, artist.name
)
SELECT c.customer_id, c.FirstName, c.LastName, a.Name, SUM(il.unit_price * il.quantity) AS amount_spent
FROM invoice AS i
JOIN customer AS c ON c.customer_id = i.customer_id
JOIN invoiceline AS il ON il.InvoiceId = i.InvoiceId
JOIN track AS t ON t.TrackId = il.TrackId
JOIN album AS alb ON alb.AlbumId = t.AlbumId
JOIN artist AS a ON a.ArtistId = alb.ArtistId
GROUP BY c.CustomerId, c.FirstName, c.LastName, a.Name
ORDER BY amount_spent DESC;