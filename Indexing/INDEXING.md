
# Database Indexes

This document provides an overview of the indexes created for the various tables in the database schema. Indexes are used to improve the performance of queries by providing quick access to the rows in the database.

## Index Overview

Indexes are database objects that improve the speed of data retrieval operations on a table. They work by creating a data structure (like a B-tree or BRIN) that allows for faster searches, lookups, and retrievals compared to scanning the entire table.

### Types of Indexes

1. **B-tree Index**: The default indexing method in PostgreSQL. Effective for equality and range queries.
2. **BRIN (Block Range INdex)**: Suitable for large tables where values are correlated with their physical location within the table (e.g., dates).
3. **Unique Index**: Ensures that the indexed column contains unique values, enforcing uniqueness constraints.
4. **Hash Index**: Efficient for equality comparisons but not for range queries (less common in modern PostgreSQL versions).

## Indexes and Join Algorithms

Indexes play a crucial role in the efficiency of join algorithms, which are used to combine rows from two or more tables based on related columns.

### Types of Join Algorithms

1. **Nested Loop Join**: Iterates over each row in the outer table and for each row, it scans the entire inner table to find matching rows. Indexes on the join columns can significantly speed up the inner table scans.
2. **Hash Join**: Builds a hash table on the join column of the smaller table and then scans the larger table, probing the hash table to find matches. Indexes are less critical here, but having an index on the smaller table can still improve performance.
3. **Merge Join**: Requires both input tables to be sorted on the join column. It then merges the sorted rows. Indexes can provide the necessary ordering, and index scans can replace sorting steps, thus improving performance.

### Example

Consider a query joining the `orders` and `users` tables on the `customer_id` column:
```sql
EXPLAIN ANALYZE SELECT o.*
FROM orders o
JOIN users u ON o.customer_id = u.user_id
WHERE customer_id = 44546;
```

#### Before Creating an Index on `orders(customer_id)`

```sql
Nested Loop  (cost=0.42..38.21 rows=2 width=12) (actual time=0.916..0.935 rows=2 loops=1)
  ->  Index Only Scan using users_pkey on users u  (cost=0.42..8.44 rows=1 width=4) (actual time=0.494..0.495 rows=1 loops=1)
        Index Cond: (user_id = 44546)
        Heap Fetches: 0
  ->  Seq Scan on orders o  (cost=0.00..29.75 rows=2 width=12) (actual time=0.420..0.437 rows=2 loops=1)
        Filter: (customer_id = 44546)
        Rows Removed by Filter: 1498
Planning Time: 3.473 ms
Execution Time: 1.040 ms

```

#### After Creating an Index on `orders(customer_id)`

```sql

Nested Loop  (cost=4.71..18.22 rows=2 width=12) (actual time=0.121..0.127 rows=2 loops=1)
  ->  Index Only Scan using users_pkey on users u  (cost=0.42..8.44 rows=1 width=4) (actual time=0.025..0.026 rows=1 loops=1)
        Index Cond: (user_id = 44546)
        Heap Fetches: 0
  ->  Bitmap Heap Scan on orders o  (cost=4.29..9.76 rows=2 width=12) (actual time=0.091..0.094 rows=2 loops=1)
        Recheck Cond: (customer_id = 44546)
        Heap Blocks: exact=2
        ->  Bitmap Index Scan on idx_customer_id  (cost=0.00..4.29 rows=2 width=0) (actual time=0.062..0.062 rows=2 loops=1)
              Index Cond: (customer_id = 44546)
Planning Time: 0.453 ms
Execution Time: 0.181 ms

```

By creating an index on the `customer_id` column in the `orders` table, we can see a significant improvement in query performance. The execution time decreased from 1.040 ms to 0.181 ms.

## Users Table

### Unique Index on Email
```sql
DROP INDEX IF EXISTS idx_unique_email;
CREATE UNIQUE INDEX idx_unique_email ON users(email);
```

### Index on Role
```sql
DROP INDEX IF EXISTS idx_user_role;
CREATE INDEX idx_user_role ON users(role);
```

## Addresses Table

### Index on User ID
```sql
CREATE INDEX idx_user_id ON addresses(user_id);
```

## Products Table

### Index on Foreign Key Category ID
```sql
DROP INDEX IF EXISTS idx_category_id;
CREATE INDEX idx_category_id ON products(category_id);
```

### Index on Foreign Key Seller ID
```sql
DROP INDEX IF EXISTS idx_seller_id;
CREATE INDEX idx_seller_id ON products(seller_id);
```

### Index on Text Field Name
```sql
DROP INDEX IF EXISTS idx_product_name;
CREATE INDEX idx_product_name ON products(name);
```

## Orders Table

### Index on Foreign Key Customer ID
```sql
DROP INDEX IF EXISTS idx_orders_customer_id;
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
```

### BRIN Index on Order Date (for Interval Filter)
```sql
DROP INDEX IF EXISTS idx_order_date_brin;
CREATE INDEX idx_order_date_brin ON orders using brin(order_date);
```

### B-tree Index on Order Date (for Sorting)
```sql
DROP INDEX IF EXISTS idx_order_date_btree;
CREATE INDEX idx_order_date_btree ON orders USING btree(order_date);
```

## Order Details Table

### Index on Foreign Key Order ID
```sql
DROP INDEX IF EXISTS idx_order_details_order_id;
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
```

### Index on Foreign Key Product ID
```sql
DROP INDEX IF EXISTS idx_order_details_product_id;
CREATE INDEX idx_order_details_product_id ON order_details(product_id);
```

## Carts Table

### Index on Foreign Key Customer ID
```sql
DROP INDEX IF EXISTS idx_cart_customer_id;
CREATE INDEX idx_cart_customer_id ON carts(customer_id);
```

## Cart Items Table

### Index on Foreign Key Cart ID
```sql
DROP INDEX IF EXISTS idx_cart_item_cart_id;
CREATE INDEX idx_cart_id ON cart_items(cart_id);
```

### Index on Foreign Key Product ID
```sql
DROP INDEX IF EXISTS idx_cart_item_product_id;
CREATE INDEX idx_cart_item_product_id ON cart_items(product_id);
```

### BRIN Index on Added Date
```sql
DROP INDEX IF EXISTS idx_cart_item_added_date;
CREATE INDEX idx_cart_item_added_date ON cart_items using brin(added_date);
```


## Index info: 
### How to see index information (name, type) on table ?
    
```sql
SELECT indexname, indexdef
FROM
pg_indexes
WHERE
tablename = 'users'
AND schemaname = 'public';
```

## Notes

- The `DROP INDEX IF EXISTS` statements ensure that any existing index with the same name is removed before creating a new one. This prevents errors if the index already exists.
- `BRIN` (Block Range Index) indexes are particularly useful for columns with large ranges of values and are efficient for range queries.
- `B-tree` indexes are the default index type in PostgreSQL and are effective for equality and range queries.

Make sure to run these index creation statements in your database management system to improve the performance of your queries.