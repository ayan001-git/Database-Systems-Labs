
-- =====================================
-- PART 1: CHECK Constraints
-- =====================================

-- Task 1.1
CREATE TABLE employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INTEGER CHECK (age BETWEEN 18 AND 65),
    salary NUMERIC CHECK (salary > 0)
);

INSERT INTO employees VALUES (1, 'John', 'Smith', 30, 5000);
INSERT INTO employees VALUES (2, 'Anna', 'Lee', 45, 7000);
-- Invalid: age below 18
-- INSERT INTO employees VALUES (3, 'Tom', 'Young', 17, 3000);
-- Invalid: salary <= 0
-- INSERT INTO employees VALUES (4, 'Jane', 'Doe', 40, 0);

-- Task 1.2
CREATE TABLE products_catalog (
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price > 0 AND discount_price < regular_price)
);

INSERT INTO products_catalog VALUES (1, 'Laptop', 1000, 800);
INSERT INTO products_catalog VALUES (2, 'Phone', 700, 600);
-- Invalid: discount >= regular
-- INSERT INTO products_catalog VALUES (3, 'Tablet', 500, 600);

-- Task 1.3
CREATE TABLE bookings (
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER CHECK (num_guests BETWEEN 1 AND 10),
    CHECK (check_out_date > check_in_date)
);

INSERT INTO bookings VALUES (1, '2025-10-01', '2025-10-05', 2);
INSERT INTO bookings VALUES (2, '2025-11-01', '2025-11-10', 4);
-- Invalid: check_out before check_in
-- INSERT INTO bookings VALUES (3, '2025-10-10', '2025-10-05', 2);

-- =====================================
-- PART 2: NOT NULL Constraints
-- =====================================

CREATE TABLE customers (
    customer_id INTEGER NOT NULL,
    email TEXT NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE inventory (
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO customers VALUES (1, 'a@gmail.com', '12345', '2025-10-01');
-- Invalid: NULL email
-- INSERT INTO customers VALUES (2, NULL, '67890', '2025-10-02');

INSERT INTO inventory VALUES (1, 'Monitor', 10, 200, NOW());
-- Invalid: negative quantity
-- INSERT INTO inventory VALUES (2, 'Keyboard', -5, 50, NOW());

-- =====================================
-- PART 3: UNIQUE Constraints
-- =====================================

CREATE TABLE users (
    user_id INTEGER,
    username TEXT UNIQUE,
    email TEXT UNIQUE,
    created_at TIMESTAMP
);

CREATE TABLE course_enrollments (
    enrollment_id INTEGER,
    student_id INTEGER,
    course_code TEXT,
    semester TEXT,
    CONSTRAINT unique_enrollment UNIQUE (student_id, course_code, semester)
);

ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

INSERT INTO users VALUES (1, 'alex', 'alex@mail.com', NOW());
-- Invalid: duplicate username
-- INSERT INTO users VALUES (2, 'alex', 'new@mail.com', NOW());

-- =====================================
-- PART 4: PRIMARY KEY Constraints
-- =====================================

CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY,
    dept_name TEXT NOT NULL,
    location TEXT
);

INSERT INTO departments VALUES (1, 'HR', 'Almaty');
INSERT INTO departments VALUES (2, 'IT', 'Astana');
INSERT INTO departments VALUES (3, 'Finance', 'Shymkent');
-- Invalid: duplicate dept_id
-- INSERT INTO departments VALUES (1, 'Sales', 'Atyrau');

CREATE TABLE student_courses (
    student_id INTEGER,
    course_id INTEGER,
    enrollment_date DATE,
    grade TEXT,
    PRIMARY KEY (student_id, course_id)
);

-- =====================================
-- PART 5: FOREIGN KEY Constraints
-- =====================================

CREATE TABLE employees_dept (
    emp_id INTEGER PRIMARY KEY,
    emp_name TEXT NOT NULL,
    dept_id INTEGER REFERENCES departments(dept_id),
    hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Ali', 1, '2025-10-01');
-- Invalid: non-existent dept_id
-- INSERT INTO employees_dept VALUES (2, 'Sara', 9, '2025-10-02');

CREATE TABLE authors (
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers (
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books (
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'Orwell', 'UK');
INSERT INTO publishers VALUES (1, 'Penguin', 'London');
INSERT INTO books VALUES (1, '1984', 1, 1, 1949, 'ISBN-123');

CREATE TABLE categories (
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk (
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders (
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL
);

CREATE TABLE order_items (
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

-- =====================================
-- PART 6: E-commerce Database Design
-- =====================================

CREATE TABLE customers_ecom (
    customer_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products_ecom (
    product_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC CHECK (price >= 0),
    stock_quantity INTEGER CHECK (stock_quantity >= 0)
);

CREATE TABLE orders_ecom (
    order_id SERIAL PRIMARY KEY,
    customer_id INTEGER REFERENCES customers_ecom(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC CHECK (total_amount >= 0),
    status TEXT CHECK (status IN ('pending','processing','shipped','delivered','cancelled'))
);

CREATE TABLE order_details (
    order_detail_id SERIAL PRIMARY KEY,
    order_id INTEGER REFERENCES orders_ecom(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_ecom(product_id),
    quantity INTEGER CHECK (quantity > 0),
    unit_price NUMERIC CHECK (unit_price > 0)
);

INSERT INTO customers_ecom (name, email, phone, registration_date) VALUES
('Ayan', 'ayan@mail.com', '12345', '2025-10-01'),
('Mira', 'mira@mail.com', '67890', '2025-10-02');

INSERT INTO products_ecom (name, description, price, stock_quantity) VALUES
('Laptop', 'Gaming laptop', 1200, 5),
('Mouse', 'Wireless', 50, 20);

INSERT INTO orders_ecom (customer_id, order_date, total_amount, status) VALUES
(1, '2025-10-10', 1250, 'pending'),
(2, '2025-10-11', 50, 'shipped');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 1200),
(1, 2, 1, 50),
(2, 2, 1, 50);
