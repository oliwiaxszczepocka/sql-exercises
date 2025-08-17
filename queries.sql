------------------------------------------1. Customers and Sales
-- Get the list of customers from Toronto who placed orders
SELECT c.id_, c.name_, c.surname, c.city, c.e_mail, o.id_ 
FROM customers c JOIN orders o ON c.id_ = o.id_client
WHERE c.city = 'Toronto'
ORDER BY c.surname ASC, c.name_ ASC;

-- Count how many orders customers from each city have placed
SELECT c.city, COUNT(o.id_) orders_count
FROM customers c JOIN orders o ON c.id_ = o.id_client
GROUP BY c.city;

-- Find the customer with the highest number of orders
SELECT c.id_, c.name_, c.surname, c.city, c.e_mail, COUNT(o.id_) orders_count
FROM customers c LEFT JOIN orders o ON c.id_ = o.id_client
GROUP BY c.id_, c.name_, c.surname, c.city, c.e_mail
ORDER BY COUNT(o.id_) DESC
LIMIT 1;

-- Check customers with no orders
SELECT c.id_, c.name_, c.surname, c.city, c.e_mail, COUNT(o.id_) orders_count
FROM customers c LEFT JOIN orders o ON c.id_ = o.id_client
WHERE o.id_client IS NULL
GROUP BY c.id_, c.name_, c.surname, c.city, c.e_mail;

------------------------------------------2. Products and prices
-- List the 5 most expensive products in the store
SELECT id_, name_, category, price
FROM products
ORDER BY price DESC
LIMIT 5;

-- Calculate the average price of products in each category
SELECT category, TRUNC(AVG(price),2) avg_price
FROM products
GROUP BY category;

-- Show the category with the most products
SELECT category, COUNT(name_)
FROM products
GROUP BY category
ORDER BY COUNT(name_) DESC
LIMIT 1;

------------------------------------------3. Orders
-- Calculate the value of each order (quantity × price)
SELECT o.id_, COALESCE(SUM(p.price * d.quantity), 0) AS cost_
FROM orders o LEFT JOIN details d ON d.id_order = o.id_ LEFT JOIN products p ON d.id_product = p.id_
GROUP BY o.id_
ORDER BY o.id_;

-- List the 10 largest orders by value
SELECT o.id_, COALESCE(SUM(p.price * s.quantity), 0) AS cost_
FROM orders o LEFT JOIN details s ON s.id_order = o.id_ LEFT JOIN products p ON s.id_product = p.id_
GROUP BY o.id_
ORDER BY cost_ DESC
LIMIT 10;

-- Check the average order value for customers from each city
WITH order_values AS (
    SELECT 
        o.id_ AS order_id,
        o.id_client,
        SUM(p.price * d.quantity) AS order_cost
    FROM orders o
    LEFT JOIN details d ON d.id_order = o.id_
    LEFT JOIN products p ON d.id_product = p.id_
    GROUP BY o.id_
)
SELECT 
    c.city,
    TRUNC(AVG(o.order_cost),2) AS avg_cost
FROM order_values o
JOIN customers c ON o.id_client = c.id_
GROUP BY c.city
ORDER BY avg_cost DESC;

-- Count how many orders are in each status (e.g., completed, pending)
SELECT status, COUNT(id_)
FROM orders
GROUP BY status;

------------------------------------------4. Business analysis
-- Top 5 customers by total purchase value
SELECT c.id_ client_id, c.name_, c.surname, SUM(p.price*s.quantity) cost_
FROM customers c JOIN orders o ON c.id_ = o.id_client JOIN details s ON o.id_ = s.id_order JOIN products p ON s.id_product = p.id_
GROUP BY c.id_, c.name_, c.surname
ORDER BY cost_ DESC, surname ASC
LIMIT 5;

-- Show the most frequently purchased product category
SELECT category, SUM(quantity) total_count
FROM details s JOIN products p ON p.id_ = s.id_product JOIN orders o ON s.id_order = o.id_
GROUP BY category;

-- Calculate the total revenue of the store
SELECT SUM(p.price*s.quantity)
FROM details s JOIN products p ON s.id_product = p.id_;

-- Check products that were never sold
SELECT p.id_, p.name_, category, price
FROM products p LEFT JOIN details s ON p.id_ = s.id_product
WHERE s.id_product IS NULL;

------------------------------------------5. Harder exercices 
-- Find the customer who spent the most on a single order
SELECT c.id_ client_id, c.name_, c.surname, SUM(p.price*s.quantity) cost_
FROM customers c JOIN orders o ON c.id_ = o.id_client JOIN details s ON o.id_ = s.id_order JOIN products p ON s.id_product = p.id_
GROUP BY c.id_, c.name_, c.surname, o.id_
ORDER BY cost_ DESC, surname ASC
LIMIT 1;

-- Rank cities by total order value
SELECT c.city, SUM(p.price*s.quantity) cost_
FROM customers c JOIN orders o ON c.id_=o.id_client JOIN details s ON o.id_ = s.id_order JOIN products p ON s.id_product = p.id_
GROUP BY c.city
ORDER BY cost_ DESC;

-- Calculate the average price of products bought in Toronto vs New York
SELECT c.city, TRUNC(AVG(p.price),2) avg_price
FROM customers c JOIN orders o ON c.id_ = o.id_client JOIN details s ON o.id_ = s.id_order JOIN products p ON s.id_product = p.id_
WHERE c.city IN ('Toronto','New York')
GROUP BY c.city;
