-- 5. Write SQL Query to Retrieve the total number of products in each category.
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id
ORDER BY category_id;

-- 6. Write SQL Query to Find the top customers by total spending.
SELECT
    c.user_id,
    c.first_name,
    c.last_name,
    SUM(od.quantity * p.price) AS "Total Amount Spent"
FROM users c
JOIN orders o ON c.user_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE c.role = 'CUSTOMER'
GROUP BY c.user_id, c.first_name, c.last_name
ORDER BY SUM(od.quantity * p.price) DESC
LIMIT 10;

-- 7. Write SQL Query to Retrieve the most recent orders with customer information with 1000 orders.
SELECT
    o.order_id,
    o.order_date,
    c.user_id,
    c.first_name,
    c.last_name
FROM orders o
JOIN users c ON o.customer_id = c.user_id
ORDER BY o.order_date DESC
LIMIT 1000;

-- 8. Write SQL Query to List products that have low stock quantities of less than 10 quantities.
SELECT *
FROM products
WHERE stock_quantity < 10;

-- 9. Write SQL Query to Calculate the revenue generated from each product category.
SELECT
    c.name AS "Category",
    SUM(od.quantity * p.price) AS "Total Revenue"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name;

-- from point 5 to 9 write the queries and then use the Explain analyze plan and then optimize the Queries So i need to create table with the following columns
-- Simple Query
-- Execution Time Before Optimization
-- Optimization Technique
-- Rewrite Query
-- Execution Time After Optimization

-- see optimization in the next file
\i ../indexing/indexing.sql
\i ../query_optimization_techinques/query_optimization.sql
