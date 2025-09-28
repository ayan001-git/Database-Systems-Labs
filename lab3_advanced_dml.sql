-- ==========================================
-- Lab 3 – Advanced DML Operations
-- ==========================================

-- ==========================================
-- Part A. Database and Table Setup

CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    dept_id INT,
    salary NUMERIC(10,2),
    hire_date DATE DEFAULT CURRENT_DATE,
    status VARCHAR(20) DEFAULT 'Active'
);

CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(100) NOT NULL,
    budget NUMERIC(12,2),
    manager_id INT
);

CREATE TABLE projects (
    project_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INT REFERENCES departments(dept_id),
    start_date DATE,
    end_date DATE,
    budget NUMERIC(12,2)
);

-- ==========================================
-- Part B. Advanced INSERT Operations
-- ==========================================
INSERT INTO employees (full_name, dept_id, salary)
VALUES ('Alice Johnson', 1, 3500.00);

INSERT INTO employees (full_name, salary)
VALUES ('Bob Smith', 4200.00);  -- dept_id = NULL

INSERT INTO employees (full_name, dept_id, salary, hire_date, status)
VALUES
('Charlie Adams', 2, 5000.00, '2024-05-01', DEFAULT),
('Diana Miller', 1, 4800.00, '2023-11-15', 'Inactive');

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
('IT', 100000, 1),
('HR', 50000, 2),
('Finance', 75000, 3);

INSERT INTO projects (project_name, dept_id, start_date, budget)
SELECT dept_name || ' Project', dept_id, CURRENT_DATE, budget/2
FROM departments;

-- ==========================================
-- Part C. Advanced UPDATE Operations
-- ==========================================
UPDATE employees
SET salary = salary * 1.1
WHERE dept_id = 1;

UPDATE employees
SET status = 'Unassigned'
WHERE dept_id IS NULL;

-- ==========================================
-- Part D. Advanced DELETE Operations
-- ==========================================
DELETE FROM employees
WHERE salary < 3000;

DELETE FROM projects
WHERE dept_id IS NULL;

-- ==========================================
-- Part E. Handling NULLs
-- ==========================================
UPDATE employees
SET dept_id = 99
WHERE dept_id IS NULL;

-- ==========================================
-- Part F. RETURNING clause
-- ==========================================
DELETE FROM employees
WHERE status = 'Inactive'
RETURNING emp_id, full_name;

-- ==========================================
-- Part G. Advanced DML Patterns
-- ==========================================
INSERT INTO projects (project_name, dept_id, start_date, budget)
SELECT 'Special Project', 1, CURRENT_DATE, 20000
WHERE NOT EXISTS (
    SELECT 1 FROM projects WHERE project_name = 'Special Project'
);

UPDATE departments
SET budget = budget - 5000
WHERE dept_id = 1;

UPDATE departments
SET budget = budget + 5000
WHERE dept_id = 2;

UPDATE employees
SET status = 'Terminated'
WHERE dept_id = 2;
SELECT * FROM departments;
