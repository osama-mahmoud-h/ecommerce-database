-- generate a daily report of the total revenue for a specific date.
SELECT
    order_date,
    SUM(od.quantity * p.price) AS Total_Revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE order_date = '2023-10-01'
GROUP BY o.order_date;

-- generate a monthly report of the top-selling products in a given month.
SELECT
    p.product_id,p.name,
    SUM(od.quantity) AS "Total Quantity Sold"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE EXTRACT(MONTH FROM o.order_date) = 10
GROUP BY p.product_id, p.name
ORDER BY SUM(od.quantity) DESC;

-- retrieve a list of customers who have placed orders totaling more than $500 in the past month.
SELECT
    c.user_id,
    c.first_name,
    c.last_name,
    SUM(od.quantity * p.price) AS "Total Amount Spent"
FROM users c
JOIN orders o ON c.user_id = o.customer_id
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE c.role = 'CUSTOMER' AND
          o.order_date >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '1 month')
          AND o.order_date < DATE_TRUNC('month', CURRENT_DATE)
GROUP BY c.user_id, c.first_name, c.last_name
HAVING SUM(od.quantity * p.price) > 500
ORDER BY SUM(od.quantity * p.price) DESC;