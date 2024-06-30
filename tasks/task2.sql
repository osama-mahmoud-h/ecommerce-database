--  search for all products with the word "camera" in either the product name or description.
SELECT * FROM products
WHERE name ILIKE '%camera%' OR description ILIKE '%camera%';

-- select popular products;
SELECT
    p.product_id,
    p.name,
    SUM(od.quantity) AS "Total Quantity Sold"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.name
ORDER BY SUM(od.quantity) DESC;

-- 1:Write a trigger to Create a sale history [Above customer, product], when a new order is made in the "Orders" table, automatically generates a sale history record for that order, capturing details such as the order date, customer, product,
--     , total amount, and quantity. The trigger should be triggered on Order insertion.
CREATE OR REPLACE FUNCTION create_sale_history() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO sale_history(order_date, customer_id, product_id, total_amount, quantity)
    VALUES (NEW.order_date, NEW.customer_id, NEW.product_id, NEW.total_amount, NEW.quantity);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- in products:
-- 1- Write a transaction query to lock the field quantity with product id= 211 from being updated.
BEGIN;
SELECT * FROM products WHERE product_id = 211 FOR UPDATE;
COMMIT ;

-- 2- Write a transaction query to lock row with product id= 211 from being updated.
BEGIN TRANSACTION;
SELECT * FROM products WHERE product_id = 211 FOR UPDATE;
COMMIT TRANSACTION;
