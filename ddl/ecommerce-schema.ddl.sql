-- Create User table
CREATE TABLE IF NOT EXISTS User (
    user_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    password VARCHAR(100),
    role VARCHAR(50) CHECK (role IN ('CUSTOMER', 'SELLER')) -- Role must be either 'customer' or 'seller'
);

-- Create Address table
CREATE TABLE IF NOT EXISTS Address (
    address_id SERIAL PRIMARY KEY,
    user_id INT,
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    zip_code VARCHAR(10),
    country VARCHAR(50),
    FOREIGN KEY (user_id) REFERENCES User(user_id)
);

-- Create Category table
CREATE TABLE IF NOT EXISTS Category (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50)
);

-- Create Product table
CREATE TABLE IF NOT EXISTS Product (
    product_id SERIAL PRIMARY KEY,
    category_id INT,
    seller_id INT,
    name VARCHAR(100),
    description TEXT,
    price DECIMAL(10, 2),
    stock_quantity INT,
    FOREIGN KEY (category_id) REFERENCES Category(category_id),
    FOREIGN KEY (seller_id) REFERENCES User(user_id)
);

-- Create Orders table
CREATE TABLE IF NOT EXISTS Orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    order_date DATE,
    FOREIGN KEY (customer_id) REFERENCES User(user_id)
);

-- Create Order Detail table
CREATE TABLE IF NOT EXISTS Order_Detail (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INT,
    product_id INT,
    quantity INT,
    unit_price DECIMAL(10, 2),
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Create Cart table
CREATE TABLE IF NOT EXISTS Cart (
    cart_id SERIAL PRIMARY KEY,
    customer_id INT,
    FOREIGN KEY (customer_id) REFERENCES User(user_id)
);

-- Create Cart Item table
CREATE TABLE IF NOT EXISTS Cart_Item (
    cart_item_id SERIAL PRIMARY KEY,
    cart_id INT,
    product_id INT,
    quantity INT,
    added_date DATE,
    FOREIGN KEY (cart_id) REFERENCES Cart(cart_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);

-- Create Sale History table
CREATE TABLE IF NOT EXISTS Sale_History (
    sale_id SERIAL PRIMARY KEY,
    order_id INT,
    sale_date DATE,
    customer_id INT,
    product_id INT,
    total_amount DECIMAL(10, 2),
    quantity INT,
    FOREIGN KEY (order_id) REFERENCES Orders(order_id),
    FOREIGN KEY (customer_id) REFERENCES User(user_id),
    FOREIGN KEY (product_id) REFERENCES Product(product_id)
);
