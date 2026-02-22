create database itunes_db;
drop database itunes_db
use itunes_db;

CREATE TABLE artist (
artist_id INT,
name VARCHAR(255)
);

CREATE TABLE album (
album_id INT,
title VARCHAR(255),
artist_id INT
);

CREATE TABLE genre (
genre_id INT,
name VARCHAR(255)
);

CREATE TABLE media_type (
media_type_id INT,
name VARCHAR(255)
);

CREATE TABLE playlist (
playlist_id INT,
name VARCHAR(255)
);

CREATE TABLE track (
track_id INT,
name VARCHAR(255),
album_id INT,
media_type_id INT,
genre_id INT,
composer VARCHAR(255),
milliseconds INT,
bytes INT,
unit_price DECIMAL(10,2)
);

CREATE TABLE customer (
customer_id INT,
first_name VARCHAR(100),
last_name VARCHAR(100),
company VARCHAR(255),
address VARCHAR(255),
city VARCHAR(100),
state VARCHAR(100),
country VARCHAR(100),
postal_code VARCHAR(20),
phone VARCHAR(50),
fax VARCHAR(50),
email VARCHAR(150),
support_rep_id INT
);

CREATE TABLE employee (
employee_id INT,
last_name VARCHAR(100),
first_name VARCHAR(100),
title VARCHAR(150),
reports_to INT,
levels VARCHAR(20),
birthdate DATETIME,
hire_date DATETIME,
address VARCHAR(255),
city VARCHAR(100),
state VARCHAR(100),
country VARCHAR(100),
postal_code VARCHAR(20),
phone VARCHAR(50),
fax VARCHAR(50),
email VARCHAR(150)
);

CREATE TABLE invoice (
invoice_id INT,
customer_id INT,
invoice_date DATETIME,
billing_address VARCHAR(255),
billing_city VARCHAR(100),
billing_state VARCHAR(100),
billing_country VARCHAR(100),
billing_postal_code VARCHAR(20),
total DECIMAL(10,2)
);

CREATE TABLE invoice_line (
invoice_line_id INT,
invoice_id INT,
track_id INT,
unit_price DECIMAL(10,2),
quantity INT
);

CREATE TABLE playlist_track (
playlist_id INT,
track_id INT
);

show tables

select * from playlist_track;

ALTER TABLE artist ADD PRIMARY KEY (artist_id);
ALTER TABLE album ADD PRIMARY KEY (album_id);
ALTER TABLE genre ADD PRIMARY KEY (genre_id);
ALTER TABLE media_type ADD PRIMARY KEY (media_type_id);
ALTER TABLE playlist ADD PRIMARY KEY (playlist_id);
ALTER TABLE employee ADD PRIMARY KEY (employee_id);
ALTER TABLE customer ADD PRIMARY KEY (customer_id);
ALTER TABLE track ADD PRIMARY KEY (track_id);
ALTER TABLE invoice ADD PRIMARY KEY (invoice_id);
ALTER TABLE invoice_line ADD PRIMARY KEY (invoice_line_id);
ALTER TABLE playlist_track ADD PRIMARY KEY (playlist_id, track_id);

ALTER TABLE album
ADD CONSTRAINT fk_album_artist
FOREIGN KEY (artist_id)
REFERENCES artist(artist_id);

ALTER TABLE track
ADD CONSTRAINT fk_track_album
FOREIGN KEY (album_id)
REFERENCES album(album_id);

ALTER TABLE track
ADD CONSTRAINT fk_track_media
FOREIGN KEY (media_type_id)
REFERENCES media_type(media_type_id);

ALTER TABLE track
ADD CONSTRAINT fk_track_genre
FOREIGN KEY (genre_id)
REFERENCES genre(genre_id);

ALTER TABLE customer
ADD CONSTRAINT fk_customer_employee
FOREIGN KEY (support_rep_id)
REFERENCES employee(employee_id);

ALTER TABLE employee
ADD CONSTRAINT fk_employee_manager
FOREIGN KEY (reports_to)
REFERENCES employee(employee_id);

ALTER TABLE invoice
ADD CONSTRAINT fk_invoice_customer
FOREIGN KEY (customer_id)
REFERENCES customer(customer_id);

ALTER TABLE invoice_line
ADD CONSTRAINT fk_invoice_line_invoice
FOREIGN KEY (invoice_id)
REFERENCES invoice(invoice_id);

ALTER TABLE invoice_line
ADD CONSTRAINT fk_invoice_line_track
FOREIGN KEY (track_id)
REFERENCES track(track_id);

ALTER TABLE playlist_track
ADD CONSTRAINT fk_playlist_track_playlist
FOREIGN KEY (playlist_id)
REFERENCES playlist(playlist_id);

ALTER TABLE playlist_track
ADD CONSTRAINT fk_playlist_track_track
FOREIGN KEY (track_id)
REFERENCES track(track_id);


set foreign_key_checks = 0;
truncate table invoice_line;
truncate table invoice;
set foreign_key_checks = 1;
select sum(total) from invoice;
select count(*) from invoice_line;
SELECT COUNT(*) FROM artist;
SELECT COUNT(*) FROM album;
SELECT COUNT(*) FROM track;
SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM media_type;
SELECT COUNT(*) FROM customer;
SELECT COUNT(*) FROM invoice;
SELECT COUNT(*) FROM invoice_line;
SELECT COUNT(*) FROM playlist;
SELECT COUNT(*) FROM playlist_track;

SELECT COUNT(*) FROM invoice WHERE total IS NULL;
SELECT COUNT(*) FROM invoice WHERE customer_id IS NULL;
SELECT COUNT(*) FROM invoice_line WHERE track_id IS NULL;
SELECT COUNT(*) FROM track WHERE album_id IS NULL;

SELECT COUNT(*) 
FROM invoice i
LEFT JOIN customer c ON i.customer_id = c.customer_id
WHERE c.customer_id IS NULL;

SELECT COUNT(*) 
FROM invoice_line il
LEFT JOIN invoice i ON il.invoice_id = i.invoice_id
WHERE i.invoice_id IS NULL;

SELECT COUNT(*) 
FROM invoice_line il
LEFT JOIN track t ON il.track_id = t.track_id
WHERE t.track_id IS NULL;

show variables like 'local_infile';
select count(*) from invoice_line;
SELECT COUNT(*) FROM invoice;
SELECT ROUND(SUM(total), 2) FROM invoice;
SELECT invoice_id, billing_country, total FROM invoice LIMIT 5;
SELECT 
    billing_country,
    ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;


SELECT ROUND(SUM(total), 2) FROM invoice;


------------------------------------------------------------------------
------------------------------------------------------------------------
Top 10 Customer by revenue

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;
---------------------------------------------------------------------------
Revenue by country

SELECT 
    billing_country,
    ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC;

select distinct billing_country from invoice;
select count(*) from invoice;

describe invoice;

select invoice_id, billing_country, total from invoice limit 10;
select count(*) from invoice where billing_country = 'None';
update invoice set billing_country = null where billing_country = 'None';
--------------------------------------------------------------------------------
Monthly Revenue Trend

SELECT 
    DATE_FORMAT(invoice_date, '%Y-%m') AS month,
    ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY month
ORDER BY month;

----------------------------------------------------------------------------------
Top 5 Revenue Generating Countries

SELECT 
    billing_country,
    ROUND(SUM(total), 2) AS revenue
FROM invoice
GROUP BY billing_country
ORDER BY revenue DESC
LIMIT 5;

-------------------------------------------------------------------
Top 10 customer by Revenue

SELECT 
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 10;

--------------------------------------------------------------------------------

Most sold Tracks

SELECT 
    t.name AS track_name,
    COUNT(il.track_id) AS times_sold
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
GROUP BY t.track_id
ORDER BY times_sold DESC
LIMIT 10;

------------------------------------------------------------------------
Most Popular Genres

SELECT 
    g.name AS genre,
    COUNT(il.track_id) AS purchases
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.genre_id
ORDER BY purchases DESC;

-----------------------------------------------------------------------------
Revenue By Genre

SELECT 
    g.name AS genre,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN genre g ON t.genre_id = g.genre_id
GROUP BY g.genre_id
ORDER BY revenue DESC;

-----------------------------------------------------------------------------
Average Order Value

SELECT 
    ROUND(AVG(total), 2) AS avg_order_value
FROM invoice;

---------------------------------------------------------------------------------------
Customer Lifetime Value

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(i.total), 2) AS lifetime_value
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY lifetime_value DESC;

-------------------------------------------------------------------------------
SELECT 
    CASE 
        WHEN SUM(i.total) > 100 THEN 'High Value'
        WHEN SUM(i.total) BETWEEN 50 AND 100 THEN 'Medium Value'
        ELSE 'Low Value'
    END AS segment,
    COUNT(*) AS customers
FROM customer c
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id;
------------------------------------------------------------------------------------
Repeat Purchase Behaviour

SELECT 
    customer_id,
    COUNT(invoice_id) AS number_of_orders
FROM invoice
GROUP BY customer_id
HAVING COUNT(invoice_id) > 1
ORDER BY number_of_orders DESC;
--------------------------------------------------------------------------------
SELECT 
    ROUND(
        SUM(CASE WHEN order_count > 1 THEN 1 ELSE 0 END) 
        / COUNT(*) * 100, 2
    ) AS repeat_customer_percentage
FROM (
    SELECT customer_id, COUNT(*) AS order_count
    FROM invoice
    GROUP BY customer_id
) t;
--------------------------------------------------------------------------------------

Revenue Concentration

SELECT 
    ROUND(SUM(total), 2) AS total_revenue
FROM invoice;

----------------------------------------------------------------------------------
SELECT 
    ROUND(SUM(total_spent), 2) AS top10_revenue
FROM (
    SELECT 
        SUM(i.total) AS total_spent
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
    ORDER BY total_spent DESC
    LIMIT 10
) t;

----------------------------------------------------------------------------------------
Most Profitable Media Type

SELECT 
    m.name AS media_type,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS revenue
FROM invoice_line il
JOIN track t ON il.track_id = t.track_id
JOIN media_type m ON t.media_type_id = m.media_type_id
GROUP BY m.media_type_id
ORDER BY revenue DESC;
-----------------------------------------------------------------------------------

Employee Performance
SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS employee,
    ROUND(SUM(i.total), 2) AS revenue_generated
FROM employee e
JOIN customer c ON e.employee_id = c.support_rep_id
JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY revenue_generated DESC;
--------------------------------------------------------------------------------------

Rank Customers by Revenue

SELECT 
    customer_name,
    lifetime_value,
    RANK() OVER (ORDER BY lifetime_value DESC) AS revenue_rank
FROM (
    SELECT 
        CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
        SUM(i.total) AS lifetime_value
    FROM customer c
    JOIN invoice i ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) t;

------------------------------------------------------------------------------
Running Revenue Over Time
SELECT 
    invoice_date,
    SUM(total) AS daily_revenue,
    SUM(SUM(total)) OVER (ORDER BY invoice_date) AS cumulative_revenue
FROM invoice
GROUP BY invoice_date
ORDER BY invoice_date;
------------------------------------------------------------------------------------

Revenue Contribution % per country

SELECT 
    billing_country,
    ROUND(SUM(total),2) AS country_revenue,
    ROUND(
        SUM(total) / SUM(SUM(total)) OVER () * 100, 2
    ) AS contribution_percent
FROM invoice
GROUP BY billing_country
ORDER BY country_revenue DESC;
----------------------------------------------------------------------------

Top Track per Genre
SELECT *
FROM (
    SELECT 
        g.name AS genre,
        t.name AS track_name,
        COUNT(il.track_id) AS purchases,
        RANK() OVER (PARTITION BY g.genre_id ORDER BY COUNT(il.track_id) DESC) AS genre_rank
    FROM invoice_line il
    JOIN track t ON il.track_id = t.track_id
    JOIN genre g ON t.genre_id = g.genre_id
    GROUP BY g.genre_id, t.track_id
) ranked
WHERE genre_rank = 1;
********************************************************************************************
--------------------------------------------------------------------------------------------
●	Which customers have spent the most money on music?

    SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id
ORDER BY total_spent DESC
LIMIT 1;

Answer :- The customer who has spent the most on music is František Wichterlová, with a total spending of $144.54. This customer represents the highest individual revenue contributor in the dataset.
----------------------------------------------------------------------------------------------------------------------------
●	What is the average customer lifetime value?

SELECT ROUND(SUM(total), 2) AS total_revenue FROM invoice;
SELECT COUNT(*) AS total_customers FROM customer;
SELECT 
    ROUND(SUM(total) / 
    (SELECT COUNT(*) FROM customer), 2) 
AS avg_customer_lifetime_value
FROM invoice;

Answer :- The average customer lifetime value is 79.82.
-------------------------------------------------------------------------------------------------
●	How many customers have made repeat purchases versus one-time purchases?

SELECT 
    CASE 
        WHEN invoice_count = 1 THEN 'One-Time'
        ELSE 'Repeat'
    END AS customer_type,
    COUNT(*) AS total_customers
FROM (
    SELECT customer_id, COUNT(*) AS invoice_count
    FROM invoice
    GROUP BY customer_id
) AS customer_orders
GROUP BY customer_type;

Answer:- All 59 customers are repeat customers. There are no one-time purchase customers in the dataset.
-----------------------------------------------------------------------------------------------------
●	Which country generates the most revenue per customer?

SELECT 
    billing_country,
    ROUND(SUM(total) / COUNT(DISTINCT customer_id), 2) AS revenue_per_customer
FROM invoice
GROUP BY billing_country
ORDER BY revenue_per_customer DESC;

Answer:- The Czech Republic generates the highest revenue per customer at 136.62.
----------------------------------------------------------------------------------------
●	Which customers haven't made a purchase in the last 6 months?'

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    MAX(i.invoice_date) AS last_purchase_date
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
HAVING MAX(i.invoice_date) < (
    SELECT DATE_SUB(MAX(invoice_date), INTERVAL 6 MONTH)
    FROM invoice
);

Answer:-  16 customers have not made a purchase in the last 6 months. These customers are considered inactive.
----------------------------------------------------------------------------------------------
●	What are the monthly revenue trends for the last two years?

SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    ROUND(SUM(total), 2) AS monthly_revenue
FROM invoice
WHERE invoice_date >= DATE_SUB(
    (SELECT MAX(invoice_date) FROM invoice),
    INTERVAL 2 YEAR
)
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY year, month;

Answer:- Monthly revenue shows a rising trend in the early months of the year, peaking around March, followed by a gradual decline in the following months.
------------------------------------------------------------------------------------------------------------
●	What is the average value of an invoice (purchase)?

SELECT 
    ROUND(AVG(total), 2) AS avg_invoice_value
FROM invoice;

Answer:- The average invoice value is 7.67.
--------------------------------------------------------------------------------------------------------
●	Which payment methods are used most frequently?

Payment method data is not available in this dataset. The invoice table does not contain any payment method information, so this analysis cannot be performed.
-----------------------------------------------------------------------------------------------------------
●	How much revenue does each sales representative contribute?

SELECT 
    CONCAT(e.first_name, ' ', e.last_name) AS sales_rep,
    ROUND(SUM(i.total), 2) AS revenue_contributed
FROM employee e
JOIN customer c 
    ON e.employee_id = c.support_rep_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id
ORDER BY revenue_contributed DESC;

Answer:- Margaret Park generated 1289.97 in revenue, followed by Jane Peacock with 1184.04 and Steve Johnson with 1043.46.
-----------------------------------------------------------------------------------------------------
●	Which months or quarters have peak music sales?

SELECT 
    YEAR(invoice_date) AS year,
    MONTH(invoice_date) AS month,
    ROUND(SUM(total), 2) AS monthly_revenue
FROM invoice
GROUP BY YEAR(invoice_date), MONTH(invoice_date)
ORDER BY monthly_revenue DESC;

Answer:- January 2018 recorded the highest monthly revenue at 183.15. Overall, Q1 (January–March) tends to generate the strongest sales performance.
--------------------------------------------------------------------------------------------------------------------------
●	Which tracks generated the most revenue?

SELECT 
    t.name AS track_name,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS track_revenue
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
GROUP BY t.track_id, t.name
ORDER BY track_revenue DESC
LIMIT 10;

Answer:- The track “War Pigs” generated the highest revenue (30.69), followed by “Highway Chile” and “Are You Experienced?” (13.86 each).
----------------------------------------------------------------------------------------------
●	Which albums or playlists are most frequently included in purchases?

SELECT 
    a.title AS album_name,
    COUNT(il.invoice_line_id) AS purchase_count
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN album a 
    ON t.album_id = a.album_id
GROUP BY a.album_id, a.title
ORDER BY purchase_count DESC
LIMIT 10;

SELECT 
    p.name AS playlist_name,
    COUNT(il.invoice_line_id) AS purchase_count
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN playlist_track pt 
    ON t.track_id = pt.track_id
JOIN playlist p 
    ON pt.playlist_id = p.playlist_id
GROUP BY p.playlist_id, p.name
ORDER BY purchase_count DESC
LIMIT 10;

Answer:- The most frequently purchased album is “Are You Experienced?” with 187 purchases. The most frequently included playlist is “Music” (4754), followed by “90’s Music” (1852).
----------------------------------------------------------------------------------------------------------------------------
●	Are there any tracks or albums that have never been purchased?

SELECT 
    t.track_id,
    t.name AS track_name
FROM track t
LEFT JOIN invoice_line il
    ON t.track_id = il.track_id
WHERE il.track_id IS NULL;

SELECT 
    a.album_id,
    a.title AS album_name
FROM album a
LEFT JOIN track t 
    ON a.album_id = t.album_id
LEFT JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY a.album_id, a.title
HAVING COUNT(il.invoice_line_id) = 0

Answer:- There are tracks and albums in the dataset that have never been purchased. Several tracks show zero sales, and multiple albums (such as "BackBeat Soundtrack" and "Da Lama Ao Caos") have no associated purchase records. This indicates the presence of underperforming or non-performing content in the catalog.
-------------------------------------------------------------------------------------------------------
●	What is the average price per track across different genres?

SELECT 
    g.name AS genre_name,
    ROUND(AVG(il.unit_price), 2) AS avg_selling_price
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY g.genre_id, g.name
ORDER BY avg_selling_price DESC;

Answer:- The average selling price per track across all genres is $0.99, indicating a standardized pricing model. Revenue variation across genres is therefore driven primarily by purchase volume rather than price differences.
-----------------------------------------------------------------------------------------------------------------------------
●	How many tracks does the store have per genre and how does it correlate with sales?

SELECT 
    g.name AS genre_name,
    COUNT(DISTINCT t.track_id) AS total_tracks,
    COUNT(il.invoice_line_id) AS total_purchases,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM genre g
LEFT JOIN track t 
    ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;

Answer:- There is a positive relationship between catalog size and revenue, particularly evident in the Rock genre. However, some genres such as Latin show high supply but relatively low demand, indicating potential catalog optimization opportunities. Conversely, R&B/Soul demonstrates high sales efficiency despite a smaller catalog, suggesting growth potential.
-----------------------------------------------------------------------------------------------------------------------
●	Who are the top 5 highest-grossing artists?

SELECT 
    ar.name AS artist_name,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN album al 
    ON t.album_id = al.album_id
JOIN artist ar 
    ON al.artist_id = ar.artist_id
GROUP BY ar.artist_id, ar.name
ORDER BY total_revenue DESC
LIMIT 5;

Answer:- The top five highest-grossing artists are Jimi Hendrix, Queen, Red Hot Chili Peppers, Nirvana, and Pearl Jam. Revenue is moderately concentrated among rock artists, reinforcing the genre’s dominant contribution to overall sales.
-------------------------------------------------------------------------------------------------------------------

●	Which music genres are most popular in terms of:
○	Number of tracks sold
○	Total revenue

SELECT 
    g.name AS genre_name,
    SUM(il.quantity) AS total_tracks_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM invoice_line il
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY g.genre_id, g.name
ORDER BY total_revenue DESC;

Answer:- Rock is the most popular genre in terms of both tracks sold and total revenue, significantly outperforming all other categories. Given the standardized pricing model, genre performance is directly driven by purchase volume. This suggests customer preference is strongly concentrated in rock-oriented genres.
----------------------------------------------------------------------------------------------------------------
●	Are certain genres more popular in specific countries?

SELECT 
    i.billing_country,
    g.name AS genre_name,
    SUM(il.quantity) AS total_tracks_sold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS total_revenue
FROM invoice i
JOIN invoice_line il 
    ON i.invoice_id = il.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN genre g 
    ON t.genre_id = g.genre_id
GROUP BY i.billing_country, g.genre_id, g.name
ORDER BY i.billing_country, SUM(il.quantity) DESC;

Answer:- Genre popularity varies across countries. For example, Alternative & Punk is the top-performing genre in Argentina, whereas globally Rock remains dominant. This suggests regional differences in musical preferences and supports the need for localized content strategies
-------------------------------------------------------------------------------------------------------------
●	Which employees (support representatives) are managing the highest-spending customers?

SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS support_rep,
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    ROUND(SUM(i.total), 2) AS total_spent
FROM customer c
JOIN employee e 
    ON c.support_rep_id = e.employee_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id, support_rep, c.customer_id, customer_name
ORDER BY total_spent DESC;

SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS support_rep,
    ROUND(SUM(i.total), 2) AS total_customer_revenue_managed
FROM customer c
JOIN employee e 
    ON c.support_rep_id = e.employee_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id, support_rep
ORDER BY total_customer_revenue_managed DESC;

Answer:- Among support representatives, Margaret Park manages the highest total customer revenue ($1289.97), followed by Jane Peacock and Steve Johnson. This suggests that Margaret’s customer portfolio contains higher-value clients or demonstrates stronger revenue performance.
-----------------------------------------------------------------------------------------------------------------
●	What is the average number of customers per employee?

SELECT 
    ROUND(AVG(customer_count), 2) AS avg_customers_per_employee
FROM (
    SELECT 
        support_rep_id,
        COUNT(customer_id) AS customer_count
    FROM customer
    GROUP BY support_rep_id
) AS rep_customer_counts;

Answer:- Each support representative manages an average of 14.75 customers, indicating a relatively balanced customer distribution across employees.
--------------------------------------------------------------------------------------------------------------
●	Which employee regions bring in the most revenue?

SELECT 
    e.employee_id,
    CONCAT(e.first_name, ' ', e.last_name) AS support_rep,
    i.billing_country AS region,
    ROUND(SUM(i.total), 2) AS total_revenue
FROM employee e
JOIN customer c 
    ON e.employee_id = c.support_rep_id
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY e.employee_id, support_rep, i.billing_country
ORDER BY total_revenue DESC;

Answer:- The USA is the highest revenue-generating region, led primarily by Margaret Park as the top-performing support representative.
--------------------------------------------------------------------------------------------------
●	Which countries or cities have the highest number of customers?

SELECT 
    country,
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY country
ORDER BY total_customers DESC;

SELECT 
    city,
    COUNT(customer_id) AS total_customers
FROM customer
GROUP BY city
ORDER BY total_customers DESC;

Answer:- The USA has the highest number of customers (13), and Mountain View is the top city with the most customers.
---------------------------------------------------------------------------------------------
●	How does revenue vary by region?

SELECT 
    billing_country AS region,
    ROUND(SUM(total), 2) AS total_revenue
FROM invoice
GROUP BY billing_country
ORDER BY total_revenue DESC;

Answer:- Revenue is highest in the USA (1040.49), followed by Canada (535.59), while other countries contribute significantly lower revenue in comparison.
---------------------------------------------------------------------------------------------------------------
●	Are there any underserved geographic regions (high users, low sales)?

SELECT 
    c.country,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(SUM(i.total), 2) AS total_revenue,
    ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) AS revenue_per_customer
FROM customer c
JOIN invoice i 
    ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY revenue_per_customer ASC;

Answer:- Yes — Canada shows relatively high customers (8) but moderate revenue per customer compared to some smaller countries, indicating potential under-monetization despite a strong user base.
-----------------------------------------------------------------------------------------------------------------
●	What is the distribution of purchase frequency per customer?

SELECT 
    purchase_count,
    COUNT(*) AS number_of_customers
FROM (
    SELECT 
        customer_id,
        COUNT(invoice_id) AS purchase_count
    FROM invoice
    GROUP BY customer_id
) t
GROUP BY purchase_count
ORDER BY purchase_count;

Answer:- Most customers are repeat buyers, with the highest concentration around 9–10 purchases (12 customers each), indicating strong customer retention and recurring purchase behavior.
---------------------------------------------------------------------------------------------------------------
●	How long is the average time between customer purchases?

SELECT 
    ROUND(AVG(days_between), 2) AS avg_days_between_purchases
FROM (
    SELECT 
        customer_id,
        DATEDIFF(
            invoice_date,
            LAG(invoice_date) OVER (
                PARTITION BY customer_id 
                ORDER BY invoice_date
            )
        ) AS days_between
    FROM invoice
) t
WHERE days_between IS NOT NULL;

Answer:- On average, customers make a repeat purchase approximately every 132 days, indicating a buying cycle of roughly four months.
-----------------------------------------------------------------------------------------------
●	What percentage of customers purchase tracks from more than one genre?

SELECT 
    ROUND(
        100 * SUM(CASE WHEN genre_count > 1 THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS percentage_multi_genre_customers
FROM (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT t.genre_id) AS genre_count
    FROM customer c
    JOIN invoice i 
        ON c.customer_id = i.customer_id
    JOIN invoice_line il 
        ON i.invoice_id = il.invoice_id
    JOIN track t 
        ON il.track_id = t.track_id
    GROUP BY c.customer_id
) x;

Answer:- 100% of customers have purchased tracks from more than one genre, indicating highly diverse listening preferences across the entire customer base.
------------------------------------------------------------------------------------------------------
●	What are the most common combinations of tracks purchased together?

SELECT 
    t1.name AS track_1,
    t2.name AS track_2,
    COUNT(*) AS times_purchased_together
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id
    AND il1.track_id < il2.track_id
JOIN track t1 
    ON il1.track_id = t1.track_id
JOIN track t2 
    ON il2.track_id = t2.track_id
GROUP BY t1.name, t2.name
ORDER BY times_purchased_together DESC
LIMIT 10;

Answer:- The most common track combinations are “Love Or Confusion” & “I Don’t Live Today” and “May This Be Love” & “Highway Chile” (9 times each), indicating strong co-purchase patterns among specific tracks from the same artist or album.
-------------------------------------------------------------------------------------------------------
●	Are there pricing patterns that lead to higher or lower sales?

SELECT 
    unit_price,
    SUM(quantity) AS total_tracks_sold,
    ROUND(SUM(unit_price * quantity), 2) AS total_revenue
FROM invoice_line
GROUP BY unit_price
ORDER BY unit_price;

Answer:- All tracks are sold at a uniform price of 0.99, indicating no pricing variation; therefore, sales patterns are driven by demand rather than price differences.
----------------------------------------------------------------------------------------------------------------
●	Which media types (e.g., MPEG, AAC) are declining or increasing in usage?

SELECT 
    mt.name AS media_type,
    YEAR(i.invoice_date) AS year,
    SUM(il.quantity) AS total_sold
FROM invoice_line il
JOIN invoice i 
    ON il.invoice_id = i.invoice_id
JOIN track t 
    ON il.track_id = t.track_id
JOIN media_type mt 
    ON t.media_type_id = mt.media_type_id
GROUP BY mt.name, YEAR(i.invoice_date)
ORDER BY mt.name, year;

Answer:- MPEG audio files dominate overall sales but show a slight decline over time, while AAC audio files have very low and inconsistent usage, indicating no strong growth trend in alternative media types.
-------------------------------------------------------------------------------------------------------------------------------