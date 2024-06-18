-- select count of rows table.

SELECT COUNT(*) AS users_count
FROM users;

SELECT COUNT(*) AS addresses_count
FROM addresses;

SELECT COUNT(*) AS orders_count
FROM orders;

-- select users have more than order;

SELECT o.customer_id, COUNT(o.customer_id) AS total_orders
FROM users u LEFT JOIN orders o ON u.user_id = o.customer_id
group by o.customer_id
having count(o.customer_id) =0;


select  count(*) from orders where customer_id=44546;
