
----------------------- Users ---------------------------------
-- Unique index on email in Users table
DROP INDEX IF EXISTS idx_unique_email;
CREATE UNIQUE INDEX idx_unique_email ON users(email);

DROP INDEX IF EXISTS idx_user_role;
CREATE INDEX idx_user_role ON users(role);
------------------------ Addresses ----------------------------
CREATE INDEX idx_user_id ON addresses(user_id);

------------------------ Products ------------------------------------

--create/drop index on foreign key category_id.
DROP INDEX IF EXISTS idx_products_category_id;
CREATE INDEX idx_products_category_id ON products(category_id);

-- create /drop index on foreign key seller_id.
DROP INDEX IF EXISTS idx_seller_id;
CREATE INDEX idx_seller_id ON products(seller_id);

-- create /drop index on text field name .
DROP INDEX IF EXISTS idx_product_name;
CREATE INDEX idx_product_name ON products(name);


----------------------------- Orders --------------------------------
-- create / drop index on foreign key customer_id.
DROP INDEX IF EXISTS idx_orders_customer_id;
CREATE INDEX idx_orders_customer_id ON orders(customer_id);

-- create/drop brin index for order_date. (for interval filter).
DROP INDEX IF EXISTS idx_order_date_brin;
CREATE INDEX idx_order_date_brin ON orders using brin(order_date);

-- create b-tree index for sorting.
DROP INDEX IF EXISTS idx_order_date_btree;
CREATE INDEX idx_order_date_btree ON orders USING btree(order_date);


------------------------------ orderDetails --------------------------
-- create/drop index on foreign key order_id.
DROP INDEX IF EXISTS idx_order_details_order_id;
CREATE INDEX idx_order_details_order_id ON order_details(order_id);

-- create/drop index on foreign key products_id;
DROP INDEX IF EXISTS idx_order_details_product_id;
CREATE INDEX idx_order_details_product_id ON order_details(product_id);

------------------------------ Carts ----------------------------
-- create/drop index on foreign key customer_d ;
DROP INDEX IF EXISTS idx_cart_customer_id;
CREATE INDEX idx_cart_customer_id ON carts(customer_id);


----------------------- CartItems -------------------------------
--create/drop index on foreign key cart_id;
DROP INDEX IF EXISTS idx_cart_item_cart_id;
CREATE INDEX idx_cart_id ON cart_items(cart_id);

--create/drop index on foreign key product_id;
DROP INDEX IF EXISTS idx_cart_item_product_id;
CREATE INDEX idx_cart_item_product_id ON cart_items(product_id);

-- create/drop brin index on added_date
DROP INDEX IF EXISTS idx_cart_item_added_date;
CREATE INDEX idx_cart_item_added_date ON cart_items using brin(added_date)

