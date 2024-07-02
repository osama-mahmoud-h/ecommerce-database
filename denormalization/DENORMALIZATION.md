
# Denormalization for E-commerce Platform

## Introduction

This document describes the denormalization applied to the e-commerce platform schema to improve read performance by reducing the need for frequent joins. 

## Existing Schema with Denormalized Changes

### 1. Users Table

```sql
CREATE TABLE IF NOT EXISTS Users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    password VARCHAR(100),
    role VARCHAR(50) CHECK (role IN ('CUSTOMER', 'SELLER')),
    default_address_id INT
);
```

### 2. Addresses Table

```sql
CREATE TABLE IF NOT EXISTS Addresses (
    address_id SERIAL PRIMARY KEY,
    user_id INT,
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

### 3. Categories Table

```sql
CREATE TABLE IF NOT EXISTS Categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);
```

### 4. Products Table

```sql
CREATE TABLE IF NOT EXISTS Products (
    product_id SERIAL PRIMARY KEY,
    category_id INT,
    seller_id INT,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES Categories(category_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (seller_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

### 5. Orders Table

```sql
CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    total_price DECIMAL(10, 2),
    total_items INT,
    FOREIGN KEY (customer_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

### 6. order_details Table

```sql
CREATE TABLE IF NOT EXISTS order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    product_name VARCHAR(100),
    product_description TEXT,
    product_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

### 7. Carts Table

```sql
CREATE TABLE IF NOT EXISTS Carts (
    cart_id SERIAL PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

### 8. CartItems Table

```sql
CREATE TABLE IF NOT EXISTS CartItems (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT,
    added_date DATE,
    product_name VARCHAR(100),
    product_price DECIMAL(10, 2),
    FOREIGN KEY (cart_id) REFERENCES Carts(cart_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);
```

## Denormalized Triggers

### 1. Add Product Information to order_details Table

**Trigger Function:**

```sql
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
```

**Trigger:**

```sql
CREATE TRIGGER trg_add_order_detail_with_product_info
AFTER INSERT ON order_details
FOR EACH ROW
EXECUTE FUNCTION add_order_detail_with_product_info();
```

### 2. Add Product Information to CartItems Table

**Trigger Function:**

```sql
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
```

**Trigger:**

```sql
CREATE TRIGGER trg_add_cart_item_with_product_info
AFTER INSERT ON CartItems
FOR EACH ROW
EXECUTE FUNCTION add_cart_item_with_product_info();
```

### 3. User's Default Address

**Trigger Function:**

```sql
CREATE OR REPLACE FUNCTION set_default_address()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE Users
    SET default_address_id = NEW.address_id
    WHERE user_id = NEW.user_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

**Trigger:**

```sql
CREATE TRIGGER trg_set_default_address
AFTER INSERT ON Addresses
FOR EACH ROW
EXECUTE FUNCTION set_default_address();
```

### 4. Order Summary in Orders Table

**Trigger Function:**

```sql
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
```

**Trigger:**

```sql
CREATE TRIGGER trg_update_order_summary
AFTER INSERT OR UPDATE ON order_details
FOR EACH ROW
EXECUTE FUNCTION update_order_summary();
```

## Conclusion

These denormalization changes aim to improve the read performance of the e-commerce platform by reducing the need for frequent joins and aggregate calculations, while also ensuring data consistency through the use of triggers.