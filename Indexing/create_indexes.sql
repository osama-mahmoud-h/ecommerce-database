
----------------------- Users ---------------------------------
-- Unique index on email in Users table
CREATE UNIQUE INDEX idx_unique_email ON Users(email);


------------------------ Addresses ----------------------------
CREATE INDEX idx_user_id ON Addresses(user_id);


------------------------ Products ------------------------------------
CREATE INDEX idx_category_id ON Products(category_id);
CREATE INDEX idx_seller_id ON Products(seller_id);
CREATE INDEX idx_product_name ON Products(name);


----------------------------- Orders --------------------------------
CREATE INDEX idx_customer_id ON Orders(customer_id);
DROP INDEX IF EXISTS idx_customer_id;

-- create brin index for order_date.
CREATE INDEX idx_order_date ON Orders using brin(order_date);
DROP INDEX IF EXISTS idx_order_date;


------------------------------ OrderDetails --------------------------
CREATE INDEX idx_order_id ON OrderDetails(order_id);
CREATE INDEX idx_product_id ON OrderDetails(product_id);


------------------------------ Carts ----------------------------
CREATE INDEX idx_cart_customer_id ON Carts(customer_id);


----------------------- CartItems -------------------------------
CREATE INDEX idx_cart_id ON CartItems(cart_id);
CREATE INDEX idx_cart_product_id ON CartItems(product_id);
-- create brin index on added_date
CREATE INDEX idx_cart_item_added_date ON CartItems using brin(added_date)

