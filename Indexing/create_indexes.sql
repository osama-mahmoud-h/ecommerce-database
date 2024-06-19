
----------------------- Users ---------------------------------
-- Unique index on email in Users table
CREATE UNIQUE INDEX idx_unique_email ON users(email);


------------------------ Addresses ----------------------------
CREATE INDEX idx_user_id ON addresses(user_id);


------------------------ Products ------------------------------------
CREATE INDEX idx_category_id ON products(category_id);
CREATE INDEX idx_seller_id ON products(seller_id);
CREATE INDEX idx_product_name ON products(name);


----------------------------- Orders --------------------------------
CREATE INDEX idx_customer_id ON orders(customer_id);
DROP INDEX IF EXISTS idx_customer_id;

-- create brin index for order_date.
CREATE INDEX idx_order_date ON orders using brin(order_date);
DROP INDEX IF EXISTS idx_order_date;

-- create b-tree index for sorting
CREATE INDEX idx_order_date_btree ON orders USING btree(order_date);
DROP INDEX IF EXISTS idx_order_date_btree;


------------------------------ OrderDetails --------------------------
CREATE INDEX idx_order_id ON order_details(order_id);
DROP INDEX IF EXISTS idx_order_id;

DROP INDEX IF EXISTS idx_product_id;
CREATE INDEX idx_product_id ON order_details(product_id);

------------------------------ Carts ----------------------------
CREATE INDEX idx_cart_customer_id ON carts(customer_id);


----------------------- CartItems -------------------------------
CREATE INDEX idx_cart_id ON cart_items(cart_id);
CREATE INDEX idx_cart_product_id ON cart_items(product_id);
-- create brin index on added_date
CREATE INDEX idx_cart_item_added_date ON cart_items using brin(added_date)

