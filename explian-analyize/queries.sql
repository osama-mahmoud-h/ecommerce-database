
EXPLAIN ANALYZE SELECT *
                FROM orders o JOIN users u on o.customer_id = u.user_id
                WHERE customer_id = 44546;
