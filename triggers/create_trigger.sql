-- Update Stock Quantity on Order Creation

CREATE OR REPLACE FUNCTION update_stock_on_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_update_stock_on_order
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_stock_on_order();


-- Restore Stock Quantity on Order Deletion

CREATE OR REPLACE FUNCTION restore_stock_on_order_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER trg_restore_stock_on_order_delete
AFTER DELETE ON order_details
FOR EACH ROW
EXECUTE FUNCTION restore_stock_on_order_delete();


-- Update Order Date on Order Update

CREATE OR REPLACE FUNCTION update_order_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_date := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_order_date
BEFORE UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_order_date();

----------------------- Trigger: ---------------------



---- Prevent Duplicate Email Addresses

CREATE OR REPLACE FUNCTION prevent_duplicate_emails()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'Email address already exists';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_prevent_duplicate_emails
BEFORE INSERT OR UPDATE ON Users
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_emails();
