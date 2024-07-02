## Tasks / Challenges.

## SQL Challenges - Task 1

### 1. Generate a daily report of the total revenue for a specific date.

```sql
SELECT
    order_date,
    SUM(od.quantity * p.price) AS Total_Revenue
FROM orders o
JOIN order_details od ON o.order_id = od.order_id
JOIN products p ON od.product_id = p.product_id
WHERE order_date = '2023-10-01'
GROUP BY o.order_date;
```

### 2. Generate a monthly report of the top-selling products in a given month.

```sql
SELECT
    p.product_id, p.name,
    SUM(od.quantity) AS "Total Quantity Sold"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN orders o ON od.order_id = o.order_id
WHERE EXTRACT(MONTH FROM o.order_date) = 10
GROUP BY p.product_id, p.name
ORDER BY SUM(od.quantity) DESC;
```

### 3. Retrieve a list of customers who have placed orders totaling more than $500 in the past month.

```sql
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
```


## SQL Challenges - Task 2

### 1. Search for all products with the word "camera" in either the product name or description.

```sql
SELECT * FROM products
WHERE name ILIKE '%camera%' OR description ILIKE '%camera%';
```

### 2. Select popular products.

```sql
SELECT
    p.product_id,
    p.name,
    SUM(od.quantity) AS "Total Quantity Sold"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
GROUP BY p.product_id, p.name
ORDER BY SUM(od.quantity) DESC;
```

### 3. Write a trigger to create a sale history when a new order is made in the "Orders" table.

```sql
CREATE OR REPLACE FUNCTION create_sale_history() RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO sale_history(order_date, customer_id, product_id, total_amount, quantity)
    VALUES (NEW.order_date, NEW.customer_id, NEW.product_id, NEW.total_amount, NEW.quantity);
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 4. Write a transaction query to lock the field quantity with product id= 211 from being updated.

```sql
BEGIN;
SELECT * FROM products WHERE product_id = 211 FOR UPDATE;
COMMIT;
```

### 5. Write a transaction query to lock row with product id= 211 from being updated.

```sql
BEGIN TRANSACTION;
SELECT * FROM products WHERE product_id = 211 FOR UPDATE;
COMMIT TRANSACTION;
```

## SQL Challenges - Task 3

### 1. Write database functions to insert data in the product table around 10k rows

```sql
-- Function to insert data into the product table
-- path to previously created files
SOURCE ../ddl/create_procedure.sql;
SOURCE ../dml/dml.sql;

```

### 2. Write database functions to insert data in customer tables around 100k rows

```sql
-- Function to insert data into the customers table
-- path to previously created files
SOURCE ../ddl/create_procedure.sql;
SOURCE ../dml/dml.sql;
```

### 3. Write database function to insert data in categories table around 100 rows

```sql
-- Function to insert data into the categories table
-- path to previously created files
SOURCE ../ddl/create_procedure.sql;
SOURCE ../dml/dml.sql;
```

### 4. Write database functions to insert data in order, order details tables around 100K rows based on the inserted data in customers and products

```sql
-- Function to insert data into the orders table
-- path to previously created files
SOURCE ../ddl/create_procedure.sql;
SOURCE ../dml/dml.sql;
```

-- Path to previously created files
```sql
\i ../ddl/create_procedure.sql;
\i ../dml/dml.sql;
```


## SQL Challenges - Task 4

### 1. Write SQL Query to Retrieve the total number of products in each category.

```sql
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id
ORDER BY category_id;
```

### 2. Write SQL Query to Find the top customers by total spending.

```sql
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
```

### 3. Write SQL Query to Retrieve the most recent orders with customer information with 1000 orders.

```sql
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
```

### 4. Write SQL Query to List products that have low stock quantities of less than 10 quantities.

```sql
SELECT *
FROM products
WHERE stock_quantity < 10;
```

### 5. Write SQL Query to Calculate the revenue generated from each product category.

```sql
SELECT
    c.name AS "Category",
    SUM(od.quantity * p.price) AS "Total Revenue"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name;
```

## Optimization and Execution Plan Analysis

### 1. Retrieve the total number of products in each category

**Execution Time Before Optimization:**

```sql
EXPLAIN ANALYZE
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id
ORDER BY category_id;
```

```
Sort  (cost=304.82..305.57 rows=300 width=12) (actual time=4.363..4.381 rows=300 loops=1)
  Sort Key: category_id
  Sort Method: quicksort  Memory: 36kB
  ->  HashAggregate  (cost=289.48..292.48 rows=300 width=12) (actual time=4.238..4.271 rows=300 loops=1)
        Group Key: category_id
        Batches: 1  Memory Usage: 61kB
        ->  Seq Scan on products  (cost=0.00..234.65 rows=10965 width=8) (actual time=0.179..2.412 rows=11000 loops=1)
Planning Time: 2.708 ms
Execution Time: 5.000 ms
```

**Optimization Technique:**

- Create an index
- Update table statistics

```sql
CREATE INDEX idx_products_category_id ON products(category_id);

VACUUM ANALYZE products;
```

**Rewrite Query:**

```sql
EXPLAIN ANALYZE
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id
ORDER BY category_id;
```

**Execution Time After Optimization:**

```
Sort  (cost=305.34..306.09 rows=300 width=12) (actual time=4.704..4.723 rows=300 loops=1)
  Sort Key: category_id
  Sort Method: quicksort  Memory: 36kB
  ->  HashAggregate  (cost=290.00..293.00 rows=300 width=12) (actual time=4.586..4.635 rows=300 loops=1)
        Group Key: category_id
        Batches: 1  Memory Usage: 61kB
        ->  Seq Scan on products  (cost=0.00..235.00 rows=11000 width=8) (actual time=0.006..1.162 rows=11000 loops=1)
Planning Time: 0.248 ms
Execution Time: 4.770 ms
```

- Create a materialized view to store the results and refresh it periodically.

```sql
CREATE MATERIALIZED VIEW category_product_count AS
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id;

REFRESH MATERIALIZED VIEW category_product_count;

EXPLAIN ANALYZE
SELECT * FROM category_product_count;
```

**Execution Time:**

```
Seq Scan on category_product_count  (cost=0.00..30.40 rows=2040 width=12) (actual time=0.040..0.102 rows=300 loops=1)
Planning Time: 0.161 ms
Execution Time: 0.148 ms
```

### 2. Find the top customers by total spending.
```sql
--for more details goto:
SOURCE .task4.sql
```

### 3. Retrieve the most recent orders with customer information with 1000 orders.
```sql
--for more details goto:
SOURCE .task4.sql
```

### 4. List products that have low stock quantities of less than 10 quantities.
```sql
--for more details goto:
SOURCE .task4.sql
```


### 5. Calculate the revenue generated from each product category.
```sql
--for more details goto:
SOURCE .task4.sql
````
