
-- Denormalization SQL Script

-- 1. Add product information to OrderDetails table
ALTER TABLE order_details
ADD COLUMN product_name VARCHAR(100),
ADD COLUMN product_description TEXT,
ADD COLUMN product_price DECIMAL(10, 2);

CREATE OR REPLACE FUNCTION add_order_detail_with_product_info()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO order_details (order_id, product_id, quantity, unit_price, product_name, product_description, product_price)
    VALUES (NEW.order_id, NEW.product_id, NEW.quantity, NEW.unit_price,
            (SELECT name FROM Products WHERE product_id = NEW.product_id),
            (SELECT description FROM Products WHERE product_id = NEW.product_id),
            (SELECT price FROM Products WHERE product_id = NEW.product_id));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_order_detail_with_product_info
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION add_order_detail_with_product_info();

-- 2. Add product information to CartItems table
ALTER TABLE CartItems
ADD COLUMN product_name VARCHAR(100),
ADD COLUMN product_price DECIMAL(10, 2);

CREATE OR REPLACE FUNCTION add_cart_item_with_product_info()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO CartItems (cart_id, product_id, quantity, added_date, product_name, product_price)
    VALUES (NEW.cart_id, NEW.product_id, NEW.quantity, NEW.added_date,
            (SELECT name FROM Products WHERE product_id = NEW.product_id),
            (SELECT price FROM Products WHERE product_id = NEW.product_id));
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_add_cart_item_with_product_info
AFTER INSERT ON CartItems
FOR EACH ROW
EXECUTE FUNCTION add_cart_item_with_product_info();

-- 3. Add default address ID to Users table
ALTER TABLE Users
ADD COLUMN default_address_id INT;

CREATE OR REPLACE FUNCTION set_default_address()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Users
    SET default_address_id = NEW.address_id
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_set_default_address
AFTER INSERT ON Addresses
FOR EACH ROW
EXECUTE FUNCTION set_default_address();

-- 4. Add order summary fields to Orders table
ALTER TABLE Orders
ADD COLUMN total_price DECIMAL(10, 2),
ADD COLUMN total_items INT;

CREATE OR REPLACE FUNCTION update_order_summary()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Orders
    SET total_price = (SELECT SUM(unit_price * quantity) FROM order_details WHERE order_id = NEW.order_id),
        total_items = (SELECT COUNT(*) FROM order_details WHERE order_id = NEW.order_id)
    WHERE order_id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_order_summary
AFTER INSERT OR UPDATE ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_order_summary();