

-- run query after/before create index on orders(customer_id).
-- this query retrieve all orders for specific customer.
EXPLAIN ANALYZE SELECT o.*
                FROM orders o JOIN users u on o.customer_id = u.user_id
                WHERE customer_id = 44546;

-- before create index on orders(customer_id).
/*
Nested Loop  (cost=0.42..38.21 rows=2 width=12) (actual time=0.916..0.935 rows=2 loops=1)
  ->  Index Only Scan using users_pkey on users u  (cost=0.42..8.44 rows=1 width=4) (actual time=0.494..0.495 rows=1 loops=1)
        Index Cond: (user_id = 44546)
        Heap Fetches: 0
  ->  Seq Scan on orders o  (cost=0.00..29.75 rows=2 width=12) (actual time=0.420..0.437 rows=2 loops=1)
        Filter: (customer_id = 44546)
        Rows Removed by Filter: 1498
Planning Time: 3.473 ms
Execution Time: 1.040 ms
*/

-- after create index on orders(customer_id).
/*
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
*/

----------------------------------------------------------------------------------------------
EXPLAIN ANALYZE SELECT  *
                FROM orders o JOIN users u on o.customer_id = u.user_id
                JOIN order_details od on o.order_id = od.order_id
                WHERE customer_id = 44546;
-- before index order_details(order_id).
/*
Nested Loop  (cost=10.20..228.32 rows=15 width=112) (actual time=0.107..6.220 rows=20 loops=1)
  ->  Index Scan using users_pkey on users u  (cost=0.42..8.44 rows=1 width=78) (actual time=0.021..0.027 rows=1 loops=1)
        Index Cond: (user_id = 44546)
  ->  Hash Join  (cost=9.78..219.74 rows=15 width=34) (actual time=0.080..6.170 rows=20 loops=1)
        Hash Cond: (od.order_id = o.order_id)
        ->  Seq Scan on order_details od  (cost=0.00..181.00 rows=11000 width=22) (actual time=0.009..2.445 rows=11000 loops=1)
        ->  Hash  (cost=9.76..9.76 rows=2 width=12) (actual time=0.040..0.043 rows=2 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Bitmap Heap Scan on orders o  (cost=4.29..9.76 rows=2 width=12) (actual time=0.028..0.034 rows=2 loops=1)
                    Recheck Cond: (customer_id = 44546)
                    Heap Blocks: exact=2
                    ->  Bitmap Index Scan on idx_customer_id  (cost=0.00..4.29 rows=2 width=0) (actual time=0.016..0.016 rows=2 loops=1)
                          Index Cond: (customer_id = 44546)
Planning Time: 0.567 ms
Execution Time: 6.328 ms

*/
-- after index order_details(order_id)
/*
Nested Loop  (cost=9.05..70.02 rows=15 width=112) (actual time=0.092..0.221 rows=20 loops=1)
  ->  Nested Loop  (cost=4.71..18.22 rows=2 width=90) (actual time=0.038..0.046 rows=2 loops=1)
        ->  Index Scan using users_pkey on users u  (cost=0.42..8.44 rows=1 width=78) (actual time=0.014..0.016 rows=1 loops=1)
              Index Cond: (user_id = 44546)
        ->  Bitmap Heap Scan on orders o  (cost=4.29..9.76 rows=2 width=12) (actual time=0.019..0.023 rows=2 loops=1)
              Recheck Cond: (customer_id = 44546)
              Heap Blocks: exact=2
              ->  Bitmap Index Scan on idx_customer_id  (cost=0.00..4.29 rows=2 width=0) (actual time=0.010..0.010 rows=2 loops=1)
                    Index Cond: (customer_id = 44546)
  ->  Bitmap Heap Scan on order_details od  (cost=4.34..25.83 rows=7 width=22) (actual time=0.055..0.077 rows=10 loops=2)
        Recheck Cond: (o.order_id = order_id)
        Heap Blocks: exact=19
        ->  Bitmap Index Scan on idx_order_id  (cost=0.00..4.34 rows=7 width=0) (actual time=0.045..0.046 rows=10 loops=2)
              Index Cond: (order_id = o.order_id)
Planning Time: 0.736 ms
Execution Time: 0.272 ms

*/
-----------------------------------------------------------------------------------------------------------
-- query
EXPLAIN ANALYZE
    SELECT  u.user_id, u.first_name
                FROM orders o JOIN users u on o.customer_id = u.user_id
                JOIN order_details od on o.order_id = od.order_id
                JOIN products p on od.product_id = p.product_id
                WHERE customer_id = 44546;


explain analyze
    select * from orders o
             where o.order_date BETWEEN '2024-01-01' AND '2024-01-01'
            --- order by o.order_date
                           limit 10 ;



