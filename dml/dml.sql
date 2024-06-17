-- Function to create dummy data for Users table
CREATE OR REPLACE FUNCTION insert_dummy_users(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Users (first_name, last_name, email, password, role)
        VALUES (
            'FirstName' || i,
            'LastName' || i,
            'user' || i || '@example.com',
            'password' || i,
            CASE WHEN i % 2 = 0 THEN 'CUSTOMER' ELSE 'CUSTOMER' END
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Addresses table
CREATE OR REPLACE FUNCTION insert_dummy_addresses(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Addresses (user_id, street, city, state, zip_code, country)
        VALUES (
            (SELECT user_id FROM Users ORDER BY RANDOM() LIMIT 1),
            'Street ' || i,
            'City ' || i,
            'State ' || i,
            'ZipCode' || i,
            'Country ' || i
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Categories table
CREATE OR REPLACE FUNCTION insert_dummy_categories(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Categories (name)
        VALUES ('Category ' || i);
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Products table
CREATE OR REPLACE FUNCTION insert_dummy_products(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Products (category_id, seller_id, name, description, price, stock_quantity)
        VALUES (
            (SELECT category_id FROM Categories ORDER BY RANDOM() LIMIT 1),
            (SELECT user_id FROM Users WHERE role = 'SELLER' ORDER BY RANDOM() LIMIT 1),
            'Product ' || i,
            'Description for Product ' || i,
            ROUND(CAST(RANDOM() * 100 AS numeric), 2),
            (RANDOM() * 100)::INT
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Orders table
CREATE OR REPLACE FUNCTION insert_dummy_orders(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Orders (customer_id, order_date, total_amount)
        VALUES (
            (SELECT user_id FROM Users WHERE role = 'CUSTOMER' ORDER BY RANDOM() LIMIT 1),
            CURRENT_DATE - (RANDOM() * 365)::INT,
            ROUND(CAST(RANDOM() * 500 AS NUMERIC), 2)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Order_Details table
CREATE OR REPLACE FUNCTION insert_dummy_order_details(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Order_Details (order_id, product_id, quantity, unit_price)
        VALUES (
            (SELECT order_id FROM Orders ORDER BY RANDOM() LIMIT 1),
            (SELECT product_id FROM Products ORDER BY RANDOM() LIMIT 1),
            (RANDOM() * 10)::INT + 1,
            ROUND(CAST(RANDOM() * 100 AS NUMERIC), 2)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Cart table
CREATE OR REPLACE FUNCTION insert_dummy_cart(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Cart (customer_id)
        VALUES (
            (SELECT user_id FROM Users WHERE role = 'CUSTOMER' ORDER BY RANDOM() LIMIT 1)
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Cart_Items table
CREATE OR REPLACE FUNCTION insert_dummy_cart_items(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Cart_Items (cart_id, product_id, quantity, added_date)
        VALUES (
            (SELECT cart_id FROM Cart ORDER BY RANDOM() LIMIT 1),
            (SELECT product_id FROM Products ORDER BY RANDOM() LIMIT 1),
            (RANDOM() * 10)::INT + 1,
            CURRENT_DATE - (RANDOM() * 30)::INT
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Function to create dummy data for Sale_History table
CREATE OR REPLACE FUNCTION insert_dummy_sale_history(num_records INT) RETURNS VOID AS $$
BEGIN
    FOR i IN 1..num_records LOOP
        INSERT INTO Sale_History (order_id, sale_date, customer_id, product_id, total_amount, quantity)
        VALUES (
            (SELECT order_id FROM Orders ORDER BY RANDOM() LIMIT 1),
            CURRENT_DATE - (RANDOM() * 365)::INT,
            (SELECT user_id FROM Users WHERE role = 'CUSTOMER' ORDER BY RANDOM() LIMIT 1),
            (SELECT product_id FROM Products ORDER BY RANDOM() LIMIT 1),
            ROUND(CAST(RANDOM() * 500 AS  NUMERIC), 2),
            (RANDOM() * 10)::INT + 1
        );
    END LOOP;
END;
$$ LANGUAGE plpgsql;

-- Example usage to insert dummy data
-- Call the functions with the desired number of records

--SELECT insert_dummy_users(100000);
--SELECT insert_dummy_addresses(100000);
--SELECT insert_dummy_categories(100);

--SELECT insert_dummy_products(10000);
--SELECT insert_dummy_orders(500);
--SELECT insert_dummy_order_details(1000);
--SELECT insert_dummy_cart(100000);
--SELECT insert_dummy_cart_items(1000000);
--SELECT insert_dummy_sale_history(1000);