-- Create Users table
CREATE TABLE IF NOT EXISTS Users (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    password VARCHAR(100),
    role VARCHAR(50) CHECK (role IN ('CUSTOMER', 'SELLER'))
);

-- Create Addresses table with cascading delete and update
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

-- Create Categories table
CREATE TABLE IF NOT EXISTS Categories (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

-- Create Products table with cascading delete and update
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

-- Create Orders table with cascading delete and update
CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create OrderDetails table with cascading delete and update
CREATE TABLE IF NOT EXISTS OrderDetails (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create Carts table with cascading delete and update
CREATE TABLE IF NOT EXISTS Carts (
    cart_id SERIAL PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES Users(user_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- Create CartItems table with cascading delete and update
CREATE TABLE IF NOT EXISTS CartItems (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT,
    added_date DATE,
    FOREIGN KEY (cart_id) REFERENCES Carts(cart_id) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (product_id) REFERENCES Products(product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

