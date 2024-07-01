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
-- Execution Time Before Optimization
-- Optimization Technique
-- Rewrite Query
-- Execution Time After Optimization

----------------------------------------- problem 5 -----------------------------------------
-- Execution Time Before Optimization:
EXPLAIN ANALYZE
    SELECT category_id, COUNT(product_id) AS "Total Number of Products"
    FROM products
    GROUP BY category_id
    ORDER BY category_id;
/*
Sort  (cost=304.82..305.57 rows=300 width=12) (actual time=4.363..4.381 rows=300 loops=1)
  Sort Key: category_id
  Sort Method: quicksort  Memory: 36kB
  ->  HashAggregate  (cost=289.48..292.48 rows=300 width=12) (actual time=4.238..4.271 rows=300 loops=1)
        Group Key: category_id
        Batches: 1  Memory Usage: 61kB
        ->  Seq Scan on products  (cost=0.00..234.65 rows=10965 width=8) (actual time=0.179..2.412 rows=11000 loops=1)
Planning Time: 2.708 ms
Execution Time: 5.000 ms
*/

-- Optimization Technique:
-- Create an index
CREATE INDEX idx_products_category_id ON products(category_id);

-- Update table statistics
VACUUM ANALYZE products;

-- Rerun the query to see the improvement
EXPLAIN ANALYZE
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id
ORDER BY category_id;

/*
Sort  (cost=305.34..306.09 rows=300 width=12) (actual time=4.704..4.723 rows=300 loops=1)
  Sort Key: category_id
  Sort Method: quicksort  Memory: 36kB
  ->  HashAggregate  (cost=290.00..293.00 rows=300 width=12) (actual time=4.586..4.635 rows=300 loops=1)
        Group Key: category_id
        Batches: 1  Memory Usage: 61kB
        ->  Seq Scan on products  (cost=0.00..235.00 rows=11000 width=8) (actual time=0.006..1.162 rows=11000 loops=1)
Planning Time: 0.248 ms
Execution Time: 4.770 ms
*/

-- you can also create a materialized view to store the results and refresh it periodically.
CREATE MATERIALIZED VIEW category_product_count AS
SELECT category_id, COUNT(product_id) AS "Total Number of Products"
FROM products
GROUP BY category_id;

-- Refresh the materialized view periodically
REFRESH MATERIALIZED VIEW category_product_count;

EXPLAIN ANALYZE
SELECT * FROM category_product_count;
/*
Seq Scan on category_product_count  (cost=0.00..30.40 rows=2040 width=12) (actual time=0.040..0.102 rows=300 loops=1)
Planning Time: 0.161 ms
Execution Time: 0.148 ms
*/

----------------------------------------- problem 6 -----------------------------------------
-- Execution Time Before Optimization:
EXPLAIN ANALYZE
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
/*
Limit  (cost=7257.12..7257.15 rows=10 width=65) (actual time=110.236..110.241 rows=10 loops=1)
  ->  Sort  (cost=7257.12..7299.62 rows=17000 width=65) (actual time=110.235..110.238 rows=10 loops=1)
        Sort Key: (sum(((od.quantity)::numeric * p.price))) DESC
        Sort Method: top-N heapsort  Memory: 26kB
        ->  HashAggregate  (cost=6677.26..6889.76 rows=17000 width=65) (actual time=106.773..109.043 rows=5536 loops=1)
              Group Key: c.user_id
              Batches: 1  Memory Usage: 3089kB
              ->  Hash Join  (cost=1849.16..6507.26 rows=17000 width=43) (actual time=23.644..92.963 rows=17000 loops=1)
                    Hash Cond: (od.product_id = p.product_id)
                    ->  Merge Join  (cost=1476.66..6090.11 rows=17000 width=41) (actual time=14.000..75.223 rows=17000 loops=1)
                          Merge Cond: (o.order_id = od.order_id)
                          ->  Nested Loop  (cost=0.86..419193.44 rows=1113600 width=37) (actual time=0.076..50.989 rows=11500 loops=1)
                                ->  Index Scan using orders_pkey on orders o  (cost=0.43..34968.43 rows=1113600 width=8) (actual time=0.027..4.363 rows=11500 loops=1)
                                ->  Memoize  (cost=0.43..0.46 rows=1 width=33) (actual time=0.004..0.004 rows=1 loops=11500)
                                      Cache Key: o.customer_id
                                      Cache Mode: logical
                                      Hits: 288  Misses: 11212  Evictions: 0  Overflows: 0  Memory Usage: 1466kB
                                      ->  Index Scan using users_pkey on users c  (cost=0.42..0.45 rows=1 width=33) (actual time=0.003..0.003 rows=1 loops=11212)
                                            Index Cond: (user_id = o.customer_id)
                                            Filter: ((role)::text = 'CUSTOMER'::text)
                          ->  Sort  (cost=1473.53..1516.03 rows=17000 width=12) (actual time=13.911..17.172 rows=17000 loops=1)
                                Sort Key: od.order_id
                                Sort Method: quicksort  Memory: 1433kB
                                ->  Seq Scan on order_details od  (cost=0.00..279.00 rows=17000 width=12) (actual time=0.016..6.133 rows=17000 loops=1)
                    ->  Hash  (cost=235.00..235.00 rows=11000 width=10) (actual time=9.622..9.622 rows=11000 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 601kB
                          ->  Seq Scan on products p  (cost=0.00..235.00 rows=11000 width=10) (actual time=0.015..5.184 rows=11000 loops=1)
Planning Time: 1.487 ms
Execution Time: 110.677 ms
*/

-- Optimization Technique:
-- Create an index
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_order_details_product_id ON order_details(product_id);

CREATE INDEX idx_orders_customer_id_include ON orders(customer_id, order_id);
CREATE INDEX idx_order_details_order_id_include ON order_details(order_id, product_id, quantity);

-- Update table statistics
VACUUM ANALYZE orders;
VACUUM ANALYZE order_details;

-- Rerun the query to see the improvement
EXPLAIN ANALYZE
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
/*
Limit  (cost=6626.73..6626.75 rows=10 width=65) (actual time=74.150..74.154 rows=10 loops=1)
  ->  Sort  (cost=6626.73..6669.23 rows=17000 width=65) (actual time=74.149..74.152 rows=10 loops=1)
        Sort Key: (sum(((od.quantity)::numeric * p.price))) DESC
        Sort Method: top-N heapsort  Memory: 26kB
        ->  HashAggregate  (cost=6046.86..6259.36 rows=17000 width=65) (actual time=71.027..73.067 rows=5536 loops=1)
              Group Key: c.user_id
              Batches: 1  Memory Usage: 3089kB
              ->  Hash Join  (cost=375.02..5876.86 rows=17000 width=43) (actual time=3.350..61.708 rows=17000 loops=1)
                    Hash Cond: (od.product_id = p.product_id)
                    ->  Merge Join  (cost=2.52..5459.72 rows=17000 width=41) (actual time=0.055..52.545 rows=17000 loops=1)
                          Merge Cond: (o.order_id = od.order_id)
                          ->  Nested Loop  (cost=0.86..412316.33 rows=1113600 width=37) (actual time=0.039..45.061 rows=11500 loops=1)
                                ->  Index Scan using orders_pkey on orders o  (cost=0.43..34968.43 rows=1113600 width=8) (actual time=0.017..3.384 rows=11500 loops=1)
                                ->  Memoize  (cost=0.43..0.46 rows=1 width=33) (actual time=0.003..0.003 rows=1 loops=11500)
                                      Cache Key: o.customer_id
                                      Cache Mode: logical
                                      Hits: 288  Misses: 11212  Evictions: 0  Overflows: 0  Memory Usage: 1466kB
                                      ->  Index Scan using users_pkey on users c  (cost=0.42..0.45 rows=1 width=33) (actual time=0.003..0.003 rows=1 loops=11212)
                                            Index Cond: (user_id = o.customer_id)
                                            Filter: ((role)::text = 'CUSTOMER'::text)
                          ->  Index Only Scan using idx_order_details_order_id_include on order_details od  (cost=0.29..527.29 rows=17000 width=12) (actual time=0.012..3.351 rows=17000 loops=1)
                                Heap Fetches: 0
                    ->  Hash  (cost=235.00..235.00 rows=11000 width=10) (actual time=3.281..3.281 rows=11000 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 601kB
                          ->  Seq Scan on products p  (cost=0.00..235.00 rows=11000 width=10) (actual time=0.008..1.793 rows=11000 loops=1)
Planning Time: 1.550 ms
Execution Time: 74.408 ms
*/

--- you can also create a materialized view to store the results and refresh it periodically.
CREATE MATERIALIZED VIEW top_customers_view AS
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
GROUP BY c.user_id, c.first_name, c.last_name;

-- Refresh the materialized view periodically
REFRESH MATERIALIZED VIEW top_customers_view;

EXPLAIN ANALYZE select * from top_customers_view;
/*
Seq Scan on top_customers_view  (cost=0.00..81.28 rows=1728 width=272) (actual time=0.006..0.363 rows=5536 loops=1)
Planning Time: 0.078 ms
Execution Time: 0.515 ms
*/

----------------------------------------- problem 7 -----------------------------------------
-- Execution Time Before Optimization:
EXPLAIN ANALYZE
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

/**
  Limit  (cost=43728.75..43845.42 rows=1000 width=41) (actual time=270.980..275.021 rows=1000 loops=1)
  ->  Gather Merge  (cost=43728.75..152002.97 rows=928000 width=41) (actual time=270.978..274.958 rows=1000 loops=1)
        Workers Planned: 2
        Workers Launched: 2
        ->  Sort  (cost=42728.72..43888.72 rows=464000 width=41) (actual time=266.939..266.987 rows=800 loops=3)
              Sort Key: o.order_date DESC
              Sort Method: top-N heapsort  Memory: 167kB
              Worker 0:  Sort Method: top-N heapsort  Memory: 166kB
              Worker 1:  Sort Method: top-N heapsort  Memory: 169kB
              ->  Parallel Hash Join  (cost=5409.08..17288.10 rows=464000 width=41) (actual time=35.244..209.457 rows=371200 loops=3)
                    Hash Cond: (o.customer_id = c.user_id)
                    ->  Parallel Seq Scan on orders o  (cost=0.00..10661.00 rows=464000 width=12) (actual time=0.007..46.664 rows=371200 loops=3)
                    ->  Parallel Hash  (cost=3938.48..3938.48 rows=117648 width=33) (actual time=34.240..34.241 rows=66667 loops=3)
                          Buckets: 262144  Batches: 1  Memory Usage: 16096kB
                          ->  Parallel Seq Scan on users c  (cost=0.00..3938.48 rows=117648 width=33) (actual time=0.020..11.943 rows=66667 loops=3)
Planning Time: 0.584 ms
Execution Time: 275.086 ms
*/

-- Optimization Technique:
-- Create an index
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_date_btree ON orders USING btree(order_date);

-- Update table statistics
VACUUM ANALYZE orders;

-- Rerun the query to see the improvement
EXPLAIN ANALYZE
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

/*
 Limit  (cost=0.86..385.42 rows=1000 width=41) (actual time=0.126..14.266 rows=1000 loops=1)
  ->  Nested Loop  (cost=0.86..428252.06 rows=1113600 width=41) (actual time=0.124..13.948 rows=1000 loops=1)
        ->  Index Scan Backward using idx_order_date_btree on orders o  (cost=0.43..44647.22 rows=1113600 width=12) (actual time=0.105..2.545 rows=1000 loops=1)
        ->  Memoize  (cost=0.43..0.46 rows=1 width=33) (actual time=0.010..0.010 rows=1 loops=1000)
              Cache Key: o.customer_id
              Cache Mode: logical
              Hits: 4  Misses: 996  Evictions: 0  Overflows: 0  Memory Usage: 131kB
              ->  Index Scan using users_pkey on users c  (cost=0.42..0.45 rows=1 width=33) (actual time=0.008..0.008 rows=1 loops=996)
                    Index Cond: (user_id = o.customer_id)
Planning Time: 1.070 ms
Execution Time: 14.799 ms
 */

--- you can also create a materialized view to store the results and refresh it periodically.
CREATE MATERIALIZED VIEW recent_orders_view AS
SELECT
    o.order_id,
    o.order_date,
    c.user_id,
    c.first_name,
    c.last_name
FROM orders o
JOIN users c ON o.customer_id = c.user_id
ORDER BY o.order_date DESC;

-- Refresh the materialized view periodically
REFRESH MATERIALIZED VIEW recent_orders_view;

EXPLAIN ANALYZE select * from recent_orders_view;

/*
 Seq Scan on recent_orders_view  (cost=0.00..21504.00 rows=1113600 width=41) (actual time=0.040..73.544 rows=1113600 loops=1)
Planning Time: 0.230 ms
Execution Time: 102.313 ms
 */
-- here we can see that materialized view is not helping in this case so we can use the index to optimize the query.
-- because index on order_date is already created so we can use that index to optimize the query.

----------------------------------------- problem 8 -----------------------------------------
-- Execution Time Before Optimization:
EXPLAIN ANALYZE
SELECT *
FROM products
WHERE stock_quantity < 10;

/*
Seq Scan on products  (cost=0.00..262.50 rows=1070 width=62) (actual time=0.009..1.419 rows=1095 loops=1)
  Filter: (stock_quantity < 10)
  Rows Removed by Filter: 9905
Planning Time: 0.159 ms
Execution Time: 1.471 ms
*/

-- Optimization Technique:
-- Create an index
CREATE INDEX idx_products_stock_quantity ON products(stock_quantity);

-- Update table statistics
VACUUM ANALYZE products;

-- Rerun the query to see the improvement
EXPLAIN ANALYZE
SELECT *
FROM products
WHERE stock_quantity < 10;

/*
Bitmap Heap Scan on products  (cost=16.58..154.95 rows=1070 width=62) (actual time=0.167..0.654 rows=1095 loops=1)
  Recheck Cond: (stock_quantity < 10)
  Heap Blocks: exact=125
  ->  Bitmap Index Scan on idx_products_stock_quantity  (cost=0.00..16.31 rows=1070 width=0) (actual time=0.128..0.129 rows=1095 loops=1)
        Index Cond: (stock_quantity < 10)
Planning Time: 0.287 ms
Execution Time: 0.767 ms
*/

-- ** note that index here may be impact write performance ,cuz quantity is frequently updated so we need to consider that.**

----------------------------------------- problem 9 -----------------------------------------
-- Execution Time Before Optimization:
EXPLAIN ANALYZE
SELECT
    c.name AS "Category",
    SUM(od.quantity * p.price) AS "Total Revenue"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name
LIMIT 100;
/*
Sort  (cost=924.73..924.98 rows=100 width=43) (actual time=46.722..46.750 rows=100 loops=1)
  Sort Key: c.name
  Sort Method: quicksort  Memory: 29kB
  ->  HashAggregate  (cost=920.16..921.41 rows=100 width=43) (actual time=46.449..46.508 rows=100 loops=1)
        Group Key: c.name
        Batches: 1  Memory Usage: 80kB
        ->  Hash Join  (cost=381.25..750.16 rows=17000 width=21) (actual time=6.674..29.173 rows=17000 loops=1)
              Hash Cond: (p.category_id = c.category_id)
              ->  Hash Join  (cost=372.50..696.15 rows=17000 width=14) (actual time=6.505..22.042 rows=17000 loops=1)
                    Hash Cond: (od.product_id = p.product_id)
                    ->  Seq Scan on order_details od  (cost=0.00..279.00 rows=17000 width=8) (actual time=0.005..2.991 rows=17000 loops=1)
                    ->  Hash  (cost=235.00..235.00 rows=11000 width=14) (actual time=6.478..6.484 rows=11000 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 644kB
                          ->  Seq Scan on products p  (cost=0.00..235.00 rows=11000 width=14) (actual time=0.005..3.228 rows=11000 loops=1)
              ->  Hash  (cost=5.00..5.00 rows=300 width=15) (actual time=0.158..0.171 rows=300 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 23kB
                    ->  Seq Scan on categories c  (cost=0.00..5.00 rows=300 width=15) (actual time=0.017..0.075 rows=300 loops=1)
Planning Time: 2.923 ms
Execution Time: 46.822 ms
*/

-- Optimization Technique:
-- Create an index
CREATE INDEX idx_products_category_id ON products(category_id);
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_order_details_product_id ON order_details(product_id);
CREATE INDEX idx_product_name ON products(name);
CREATE INDEX idx_categories_name ON categories(name);
-- Update table statistics
VACUUM ANALYZE products;
VACUUM ANALYZE order_details;
VACUUM ANALYZE categories;
-- Rerun the query to see the improvement

EXPLAIN ANALYZE
SELECT
    c.name AS "Category",
    SUM(od.quantity * p.price) AS "Total Revenue"
FROM products p
JOIN order_details od ON p.product_id = od.product_id
JOIN categories c ON p.category_id = c.category_id
GROUP BY c.name
ORDER BY c.name
LIMIT 100;
/*
Sort  (cost=924.73..924.98 rows=100 width=43) (actual time=35.738..35.744 rows=100 loops=1)
  Sort Key: c.name
  Sort Method: quicksort  Memory: 29kB
  ->  HashAggregate  (cost=920.16..921.41 rows=100 width=43) (actual time=35.553..35.577 rows=100 loops=1)
        Group Key: c.name
        Batches: 1  Memory Usage: 80kB
        ->  Hash Join  (cost=381.25..750.16 rows=17000 width=21) (actual time=3.091..21.876 rows=17000 loops=1)
              Hash Cond: (p.category_id = c.category_id)
              ->  Hash Join  (cost=372.50..696.15 rows=17000 width=14) (actual time=2.999..16.063 rows=17000 loops=1)
                    Hash Cond: (od.product_id = p.product_id)
                    ->  Seq Scan on order_details od  (cost=0.00..279.00 rows=17000 width=8) (actual time=0.002..2.480 rows=17000 loops=1)
                    ->  Hash  (cost=235.00..235.00 rows=11000 width=14) (actual time=2.985..2.986 rows=11000 loops=1)
                          Buckets: 16384  Batches: 1  Memory Usage: 644kB
                          ->  Seq Scan on products p  (cost=0.00..235.00 rows=11000 width=14) (actual time=0.003..1.535 rows=11000 loops=1)
              ->  Hash  (cost=5.00..5.00 rows=300 width=15) (actual time=0.085..0.085 rows=300 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 23kB
                    ->  Seq Scan on categories c  (cost=0.00..5.00 rows=300 width=15) (actual time=0.018..0.046 rows=300 loops=1)
Planning Time: 0.648 ms
Execution Time: 35.794 ms
*/

