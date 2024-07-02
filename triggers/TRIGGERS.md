
# PostgreSQL Triggers for E-commerce Platform

## Introduction

This document outlines the PostgreSQL triggers applied to an e-commerce platform schema. Triggers are used to automate actions based on specific events (INSERT, UPDATE, DELETE) to maintain data integrity and enforce business rules.

## Triggers

### 1. Update Stock Quantity on Order Creation

**Description:** Reduces the stock quantity of the ordered products when an order is created.

**Function:**

```sql
CREATE OR REPLACE FUNCTION update_stock_on_order()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**

```sql
CREATE TRIGGER trg_update_stock_on_order
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_stock_on_order();
```

### 2. Restore Stock Quantity on Order Deletion

**Description:** Restores the stock quantity of the ordered products when an order is deleted.

**Function:**

```sql
CREATE OR REPLACE FUNCTION restore_stock_on_order_delete()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Products
    SET stock_quantity = stock_quantity + OLD.quantity
    WHERE product_id = OLD.product_id;
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**

```sql
CREATE TRIGGER trg_restore_stock_on_order_delete
AFTER DELETE ON order_details
FOR EACH ROW
EXECUTE FUNCTION restore_stock_on_order_delete();
```

### 3. Update Order Date on Order Update

**Description:** Updates the `order_date` to the current date when an order is updated.

**Function:**

```sql
CREATE OR REPLACE FUNCTION update_order_date()
RETURNS TRIGGER AS $$
BEGIN
    NEW.order_date := CURRENT_DATE;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**

```sql
CREATE TRIGGER trg_update_order_date
BEFORE UPDATE ON Orders
FOR EACH ROW
EXECUTE FUNCTION update_order_date();
```


### 4. Prevent Duplicate Email Addresses

**Description:** Ensures that email addresses in the Users table are unique.

**Function:**

```sql
CREATE OR REPLACE FUNCTION prevent_duplicate_emails()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (SELECT 1 FROM Users WHERE email = NEW.email) THEN
        RAISE EXCEPTION 'Email address already exists';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**

```sql
CREATE TRIGGER trg_prevent_duplicate_emails
BEFORE INSERT OR UPDATE ON Users
FOR EACH ROW
EXECUTE FUNCTION prevent_duplicate_emails();
```
