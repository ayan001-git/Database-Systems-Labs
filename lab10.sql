DROP TABLE IF EXISTS accounts CASCADE;
DROP TABLE IF EXISTS products CASCADE;

CREATE TABLE accounts (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    balance DECIMAL(10, 2) DEFAULT 0.00
);

CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    shop VARCHAR(100) NOT NULL,
    product VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL
);

INSERT INTO accounts (name, balance) VALUES
    ('Alice', 1000.00),
    ('Bob', 500.00),
    ('Wally', 750.00);

INSERT INTO products (shop, product, price) VALUES
    ('Joe''s Shop', 'Coke', 2.50),
    ('Joe''s Shop', 'Pepsi', 3.00);

-------------------------------------------------------
-- TASK 3.2 – Basic Transaction with COMMIT
-------------------------------------------------------

BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name = 'Alice';
UPDATE accounts SET balance = balance + 100 WHERE name = 'Bob';
COMMIT;

SELECT * FROM accounts;

-------------------------------------------------------
-- TASK 3.3 – ROLLBACK Example
-------------------------------------------------------

BEGIN;
UPDATE accounts SET balance = balance - 500 WHERE name='Alice';
SELECT * FROM accounts WHERE name='Alice';
ROLLBACK;
SELECT * FROM accounts WHERE name='Alice';

-------------------------------------------------------
-- TASK 3.4 – SAVEPOINT Example
-------------------------------------------------------

BEGIN;
UPDATE accounts SET balance = balance - 100 WHERE name='Alice';
SAVEPOINT my_savepoint;

UPDATE accounts SET balance = balance + 100 WHERE name='Bob';

ROLLBACK TO my_savepoint;

UPDATE accounts SET balance = balance + 100 WHERE name='Wally';

COMMIT;

SELECT * FROM accounts;

-------------------------------------------------------
-- INDEPENDENT EXERCISE 1
-- Transfer 200 from Bob to Wally (only if sufficient)
-------------------------------------------------------

BEGIN;

DO $$
DECLARE bal DECIMAL;
BEGIN
    SELECT balance INTO bal FROM accounts WHERE name='Bob' FOR UPDATE;
    IF bal < 200 THEN
        RAISE EXCEPTION 'Bob has insufficient funds';
    END IF;
END $$;

UPDATE accounts SET balance = balance - 200 WHERE name='Bob';
UPDATE accounts SET balance = balance + 200 WHERE name='Wally';

COMMIT;

SELECT * FROM accounts;

-------------------------------------------------------
-- INDEPENDENT EXERCISE 2 – Multiple SAVEPOINTS
-------------------------------------------------------

BEGIN;

INSERT INTO products (shop, product, price)
VALUES ('Joe''s Shop', 'Tea', 2.00);

SAVEPOINT sp1;

UPDATE products SET price = 3.00 WHERE product='Tea';

SAVEPOINT sp2;

DELETE FROM products WHERE product='Tea';

ROLLBACK TO sp1;

COMMIT;

SELECT * FROM products;

-------------------------------------------------------
-- INDEPENDENT EXERCISE 4 – MAX < MIN anomaly demo
-------------------------------------------------------

-- BAD VERSION (no transaction)
SELECT MAX(price) FROM products WHERE shop='Joe''s Shop';
-- imagine deletion here
SELECT MIN(price) FROM products WHERE shop='Joe''s Shop';

-- FIXED VERSION WITH TRANSACTION
BEGIN;
SELECT MAX(price) FROM products WHERE shop='Joe''s Shop';
SELECT MIN(price) FROM products WHERE shop='Joe''s Shop';
COMMIT;