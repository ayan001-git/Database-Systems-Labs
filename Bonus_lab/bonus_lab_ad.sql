-- Customers Table
CREATE TABLE customers (
    customer_id SERIAL PRIMARY KEY,
    iin VARCHAR(12) UNIQUE NOT NULL CHECK (iin ~ '^[0-9]{12}$'),
    full_name VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(255),
    status VARCHAR(20) NOT NULL CHECK (status IN ('active', 'blocked', 'frozen')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    daily_limit_kzt NUMERIC(15,2) DEFAULT 5000000.00
);

-- Accounts Table
CREATE TABLE accounts (
    account_id SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers(customer_id) ON DELETE CASCADE,
    account_number VARCHAR(34) UNIQUE NOT NULL,
    currency VARCHAR(3) NOT NULL CHECK (currency IN ('KZT', 'USD', 'EUR', 'RUB')),
    balance NUMERIC(15,2) DEFAULT 0.00 CHECK (balance >= 0),
    is_active BOOLEAN DEFAULT true,
    opened_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    closed_at TIMESTAMP WITH TIME ZONE
);

-- Transactions Table
CREATE TABLE transactions (
    transaction_id BIGSERIAL PRIMARY KEY,
    from_account_id INTEGER REFERENCES accounts(account_id),
    to_account_id INTEGER REFERENCES accounts(account_id),
    amount NUMERIC(15,2) NOT NULL CHECK (amount > 0),
    currency VARCHAR(3) NOT NULL,
    exchange_rate NUMERIC(10,6) DEFAULT 1.0,
    amount_kzt NUMERIC(15,2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('transfer', 'deposit', 'withdrawal')),
    status VARCHAR(20) NOT NULL CHECK (status IN ('pending', 'completed', 'failed', 'reversed')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    completed_at TIMESTAMP WITH TIME ZONE,
    description TEXT
);

-- Exchange Rates Table
CREATE TABLE exchange_rates (
    rate_id SERIAL PRIMARY KEY,
    from_currency VARCHAR(3) NOT NULL,
    to_currency VARCHAR(3) NOT NULL,
    rate NUMERIC(10,6) NOT NULL CHECK (rate > 0),
    valid_from TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    valid_to TIMESTAMP WITH TIME ZONE DEFAULT '9999-12-31 23:59:59',
    UNIQUE(from_currency, to_currency, valid_from)
);

-- Audit Log Table
CREATE TABLE audit_log (
    log_id BIGSERIAL PRIMARY KEY,
    table_name VARCHAR(100) NOT NULL,
    record_id BIGINT,
    action VARCHAR(10) NOT NULL CHECK (action IN ('INSERT', 'UPDATE', 'DELETE')),
    old_values JSONB,
    new_values JSONB,
    changed_by VARCHAR(255) DEFAULT CURRENT_USER,
    changed_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    ip_address INET
);

-- Insert Customers
INSERT INTO customers (iin, full_name, phone, email, status, daily_limit_kzt) VALUES
('123456789012', 'Alexander Petrov', '+77001234567', 'alexander.petrov@gmail.com', 'active', 10000000),
('234567890123', 'Victoria Ivanova', '+77052345678', 'victoria.ivanova@outlook.com', 'active', 5000000),
('345678901234', 'Michael Sidorov', '+77073456789', 'michael.sidorov@mail.kz', 'active', 15000000),
('456789012345', 'Elizabeth Kozlova', '+77094567890', 'elizabeth.kozlova@gmail.com', 'blocked', 3000000),
('567890123456', 'Nicholas Sokolov', '+77005678901', 'nicholas.sokolov@outlook.com', 'active', 20000000),
('678901234567', 'Catherine Popova', '+77056789012', 'catherine.popova@mail.kz', 'active', 8000000),
('789012345678', 'Daniel Lebedev', '+77077890123', 'daniel.lebedev@gmail.com', 'frozen', 5000000),
('890123456789', 'Sophia Novikova', '+77098901234', 'sophia.novikova@outlook.com', 'active', 12000000),
('901234567890', 'Matthew Volkov', '+77009012345', 'matthew.volkov@mail.kz', 'active', 7000000),
('012345678901', 'Anna Fedorova', '+77050123456', 'anna.fedorova@gmail.com', 'active', 6000000),
('112345678901', 'Paul Dmitriev', '+77071123456', 'paul.dmitriev@outlook.com', 'active', 9000000),
('212345678901', 'Maria Andreeva', '+77092123456', 'maria.andreeva@mail.kz', 'active', 4000000);

-- Insert Accounts
INSERT INTO accounts (customer_id, account_number, currency, balance, is_active) VALUES
(1, 'KZ86125KZT5004400100', 'KZT', 5000000.00, true),
(1, 'KZ86125USD5004400101', 'USD', 10000.00, true),
(2, 'KZ86125KZT5004400200', 'KZT', 3000000.00, true),
(2, 'KZ86125EUR5004400201', 'EUR', 5000.00, true),
(3, 'KZ86125KZT5004400300', 'KZT', 8000000.00, true),
(4, 'KZ86125KZT5004400400', 'KZT', 1000000.00, false),
(5, 'KZ86125KZT5004400500', 'KZT', 15000000.00, true),
(5, 'KZ86125USD5004400501', 'USD', 25000.00, true),
(6, 'KZ86125KZT5004400600', 'KZT', 4000000.00, true),
(7, 'KZ86125RUB5004400700', 'RUB', 500000.00, true),
(8, 'KZ86125KZT5004400800', 'KZT', 6000000.00, true),
(9, 'KZ86125KZT5004400900', 'KZT', 3500000.00, true),
(10, 'KZ86125KZT5004401000', 'KZT', 2800000.00, true),
(11, 'KZ86125KZT5004401100', 'KZT', 5500000.00, true),
(12, 'KZ86125KZT5004401200', 'KZT', 2000000.00, true);

-- Insert Rates
INSERT INTO exchange_rates (from_currency, to_currency, rate, valid_from, valid_to) VALUES
('USD', 'KZT', 480.50, '2025-01-01', '9999-12-31'),
('EUR', 'KZT', 515.75, '2025-01-01', '9999-12-31'),
('RUB', 'KZT', 5.25, '2025-01-01', '9999-12-31'),
('KZT', 'USD', 0.00208117, '2025-01-01', '9999-12-31'),
('KZT', 'EUR', 0.00193933, '2025-01-01', '9999-12-31'),
('KZT', 'RUB', 0.19048, '2025-01-01', '9999-12-31'),
('USD', 'EUR', 0.93165, '2025-01-01', '9999-12-31'),
('EUR', 'USD', 1.07336, '2025-01-01', '9999-12-31'),
('USD', 'RUB', 91.52381, '2025-01-01', '9999-12-31'),
('RUB', 'USD', 0.01093, '2025-01-01', '9999-12-31'),
('EUR', 'RUB', 98.24, '2025-01-01', '9999-12-31'),
('RUB', 'EUR', 0.01018, '2025-01-01', '9999-12-31'),
('KZT', 'KZT', 1.0, '2025-01-01', '9999-12-31'),
('USD', 'USD', 1.0, '2025-01-01', '9999-12-31'),
('EUR', 'EUR', 1.0, '2025-01-01', '9999-12-31'),
('RUB', 'RUB', 1.0, '2025-01-01', '9999-12-31');

-- Insert Transactions
INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, created_at, completed_at, description) VALUES
-- Completed transfers
(1, 3, 500000, 'KZT', 1.0, 500000, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '5 days', CURRENT_TIMESTAMP - INTERVAL '5 days', 'Transfer: Payment for consulting services'),
(1, 5, 1000000, 'KZT', 1.0, 1000000, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '4 days', CURRENT_TIMESTAMP - INTERVAL '4 days', 'Transfer: Business partnership investment'),
(5, 9, 2000000, 'KZT', 1.0, 2000000, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '3 days', CURRENT_TIMESTAMP - INTERVAL '3 days', 'Transfer: Real estate down payment'),
-- Deposits
(NULL, 1, 300000, 'KZT', 1.0, 300000, 'deposit', 'completed', CURRENT_TIMESTAMP - INTERVAL '2 days', CURRENT_TIMESTAMP - INTERVAL '2 days', 'Deposit: Cash deposit at branch'),
(NULL, 11, 750000, 'KZT', 1.0, 750000, 'deposit', 'completed', CURRENT_TIMESTAMP - INTERVAL '1 day', CURRENT_TIMESTAMP - INTERVAL '1 day', 'Deposit: Wire transfer from abroad'),
-- Withdrawals
(9, NULL, 400000, 'KZT', 1.0, 400000, 'withdrawal', 'completed', CURRENT_TIMESTAMP - INTERVAL '12 hours', CURRENT_TIMESTAMP - INTERVAL '12 hours', 'Withdrawal: ATM cash withdrawal'),
(12, NULL, 150000, 'KZT', 1.0, 150000, 'withdrawal', 'completed', CURRENT_TIMESTAMP - INTERVAL '6 hours', CURRENT_TIMESTAMP - INTERVAL '6 hours', 'Withdrawal: Branch counter withdrawal'),
-- Pending transactions
(5, 8, 3000000, 'KZT', 1.0, 3000000, 'transfer', 'pending', CURRENT_TIMESTAMP - INTERVAL '3 hours', NULL, 'Transfer: Property purchase (pending verification)'),
(11, 12, 600000, 'KZT', 1.0, 600000, 'transfer', 'pending', CURRENT_TIMESTAMP - INTERVAL '2 hours', NULL, 'Transfer: Contract payment (awaiting approval)'),
-- Failed transactions
(12, 10, 8000000, 'KZT', 1.0, 8000000, 'transfer', 'failed', CURRENT_TIMESTAMP - INTERVAL '1 hour', NULL, 'Transfer: Failed due to insufficient balance'),
(NULL, 8, 500000, 'KZT', 1.0, 500000, 'deposit', 'failed', CURRENT_TIMESTAMP - INTERVAL '50 minutes', NULL, 'Deposit: Failed - invalid source verification'),
-- Reversed transaction (was completed but later reversed)
(1, 9, 6000000, 'KZT', 1.0, 6000000, 'transfer', 'reversed', CURRENT_TIMESTAMP - INTERVAL '30 minutes', CURRENT_TIMESTAMP - INTERVAL '28 minutes', 'Transfer: Large payment (reversed by customer request)'),
-- Additional completed transfers for testing
(11, 3, 550000, 'KZT', 1.0, 550000, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '15 minutes', CURRENT_TIMESTAMP - INTERVAL '15 minutes', 'Transfer: Monthly utility bill payment'),
(8, 11, 890000, 'KZT', 1.0, 890000, 'transfer', 'completed', CURRENT_TIMESTAMP - INTERVAL '10 minutes', CURRENT_TIMESTAMP - INTERVAL '10 minutes', 'Transfer: Freelance work payment'),
-- Withdrawal with failed status
(10, NULL, 1500000, 'KZT', 1.0, 1500000, 'withdrawal', 'failed', CURRENT_TIMESTAMP - INTERVAL '5 minutes', NULL, 'Withdrawal: Failed - daily ATM limit exceeded');



-- Task 1: Transaction Management --

CREATE OR REPLACE FUNCTION process_transfer(
    p_from_account_number VARCHAR,
    p_to_account_number VARCHAR,
    p_amount NUMERIC,
    p_currency VARCHAR,
    p_description TEXT
) RETURNS TEXT
LANGUAGE plpgsql
AS $$
DECLARE
    v_from_account_id INTEGER;
    v_to_account_id INTEGER;
    v_from_balance NUMERIC;
    v_from_currency VARCHAR(3);
    v_customer_id INTEGER;
    v_customer_status VARCHAR(20);
    v_daily_limit NUMERIC;
    v_used_today NUMERIC;
    v_exchange_rate NUMERIC;
    v_amount_kzt NUMERIC;
    v_transaction_id BIGINT;
    v_from_active BOOLEAN;
    v_to_active BOOLEAN;
BEGIN
    -- Validate and lock source account
    SELECT a.account_id, a.balance, a.currency, a.customer_id, a.is_active
    INTO v_from_account_id, v_from_balance, v_from_currency, v_customer_id, v_from_active
    FROM accounts a
    WHERE a.account_number = p_from_account_number
    FOR UPDATE;

    IF NOT FOUND THEN
        INSERT INTO audit_log (table_name, record_id, action, new_values)
        VALUES ('transactions', NULL, 'INSERT', jsonb_build_object('error', 'Source account not found'));
        RAISE EXCEPTION 'ERROR:ACC001: Source account not found' USING ERRCODE = '45001';
    END IF;

    IF NOT v_from_active THEN
        RAISE EXCEPTION 'ERROR:ACC002: Source account is not active' USING ERRCODE = '45002';
    END IF;

    -- Validate and lock destination account
    SELECT a.account_id, a.is_active
    INTO v_to_account_id, v_to_active
    FROM accounts a
    WHERE a.account_number = p_to_account_number
    FOR UPDATE;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'ERROR:ACC003: Destination account not found' USING ERRCODE = '45003';
    END IF;

    IF NOT v_to_active THEN
        RAISE EXCEPTION 'ERROR:ACC004: Destination account is not active' USING ERRCODE = '45004';
    END IF;

    -- Check customer status
    SELECT c.status, c.daily_limit_kzt
    INTO v_customer_status, v_daily_limit
    FROM customers c
    WHERE c.customer_id = v_customer_id;

    IF v_customer_status != 'active' THEN
        RAISE EXCEPTION 'ERROR:CUST001: Customer not active' USING ERRCODE = '45005';
    END IF;

    -- Get exchange rate
    IF p_currency = 'KZT' THEN
        v_exchange_rate := 1.0;
        v_amount_kzt := p_amount;
    ELSE
        SELECT rate INTO v_exchange_rate
        FROM exchange_rates
        WHERE from_currency = p_currency AND to_currency = 'KZT'
        AND CURRENT_TIMESTAMP BETWEEN valid_from AND valid_to
        ORDER BY valid_from DESC LIMIT 1;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'ERROR:RATE001: Exchange rate not found' USING ERRCODE = '45006';
        END IF;

        v_amount_kzt := p_amount * v_exchange_rate;
    END IF;

    -- Check daily limit
    SELECT COALESCE(SUM(amount_kzt), 0) INTO v_used_today
    FROM transactions
    WHERE from_account_id = v_from_account_id
    AND DATE(created_at) = CURRENT_DATE
    AND status = 'completed';

    IF (v_used_today + v_amount_kzt) > v_daily_limit THEN
        RAISE EXCEPTION 'ERROR:LIMIT001: Daily limit exceeded' USING ERRCODE = '45007';
    END IF;

    -- Check balance
    IF v_from_balance < p_amount THEN
        RAISE EXCEPTION 'ERROR:BAL001: Insufficient balance' USING ERRCODE = '45008';
    END IF;

    -- Perform transfer
    INSERT INTO transactions (from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, type, status, description)
    VALUES (v_from_account_id, v_to_account_id, p_amount, p_currency, v_exchange_rate, v_amount_kzt, 'transfer', 'completed', p_description)
    RETURNING transaction_id INTO v_transaction_id;

    -- Update account balances
    UPDATE accounts SET balance = balance - p_amount WHERE account_id = v_from_account_id;
    UPDATE accounts SET balance = balance + p_amount WHERE account_id = v_to_account_id;

    -- Log successful transaction
    INSERT INTO audit_log (table_name, record_id, action, new_values)
    VALUES ('transactions', v_transaction_id, 'INSERT', jsonb_build_object(
        'transaction_id', v_transaction_id,
        'amount', p_amount,
        'currency', p_currency,
        'status', 'completed'
    ));

    -- Return success message
    RETURN 'SUCCESS: Transaction ' || v_transaction_id || ' completed. Amount: ' || p_amount || ' ' || p_currency || ' (KZT equivalent: ' || v_amount_kzt || ')';

EXCEPTION WHEN OTHERS THEN
    -- Log the error
    INSERT INTO audit_log (table_name, record_id, action, new_values)
    VALUES ('transactions', NULL, 'INSERT', jsonb_build_object(
        'error_code', SQLSTATE,
        'error_message', SQLERRM,
        'account_from', p_from_account_number,
        'account_to', p_to_account_number,
        'amount', p_amount,
        'currency', p_currency
    ));

    -- Return failure message
    RETURN 'FAILED: ' || SQLERRM;
END;
$$;



-- Task 2: Views for Reporting --
-- View 1: customer_balance_summary
CREATE VIEW customer_balance_summary AS
WITH account_balances AS (
    SELECT
        c.customer_id,
        c.full_name,
        c.email,
        c.status,
        c.daily_limit_kzt,
        a.account_number,
        a.currency,
        a.balance,
        COALESCE(er.rate, 1.0) AS rate_to_kzt,
        a.balance * COALESCE(er.rate, 1.0) AS balance_kzt
    FROM customers c
    JOIN accounts a ON c.customer_id = a.customer_id
    LEFT JOIN exchange_rates er
        ON a.currency = er.from_currency
        AND er.to_currency = 'KZT'
        AND CURRENT_TIMESTAMP BETWEEN er.valid_from AND er.valid_to
    WHERE a.is_active = true
),
daily_usage AS (
    SELECT
        a.customer_id,
        COALESCE(SUM(t.amount_kzt), 0) AS used_today_kzt
    FROM accounts a
    LEFT JOIN transactions t
        ON a.account_id = t.from_account_id
        AND DATE(t.created_at) = CURRENT_DATE
        AND t.status = 'completed'
    GROUP BY a.customer_id
)
SELECT
    ab.customer_id,
    ab.full_name,
    ab.email,
    ab.status,
    SUM(ab.balance_kzt) AS total_balance_kzt,
    ab.daily_limit_kzt,
    du.used_today_kzt,
    ROUND((du.used_today_kzt / NULLIF(ab.daily_limit_kzt, 0)) * 100, 2) AS daily_limit_utilization_pct,
    RANK() OVER (ORDER BY SUM(ab.balance_kzt) DESC) AS balance_rank
FROM account_balances ab
JOIN daily_usage du ON ab.customer_id = du.customer_id
GROUP BY ab.customer_id, ab.full_name, ab.email, ab.status, ab.daily_limit_kzt, du.used_today_kzt;

-- View 2: daily_transaction_report
CREATE VIEW daily_transaction_report AS
WITH daily_aggregates AS (
    SELECT
        DATE(created_at) AS transaction_date,
        type,
        COUNT(*) AS transaction_count,
        SUM(amount_kzt) AS total_volume_kzt,
        AVG(amount_kzt) AS avg_amount_kzt
    FROM transactions
    WHERE status = 'completed'
    GROUP BY DATE(created_at), type
),
with_running_totals AS (
    SELECT
        transaction_date,
        type,
        transaction_count,
        total_volume_kzt,
        avg_amount_kzt,
        SUM(total_volume_kzt) OVER (PARTITION BY type ORDER BY transaction_date) AS running_total_kzt,
        LAG(total_volume_kzt) OVER (PARTITION BY type ORDER BY transaction_date) AS prev_day_volume
    FROM daily_aggregates
)
SELECT
    transaction_date,
    type,
    transaction_count,
    total_volume_kzt,
    avg_amount_kzt,
    running_total_kzt,
    CASE
        WHEN prev_day_volume IS NULL OR prev_day_volume = 0 THEN NULL
        ELSE ROUND(((total_volume_kzt - prev_day_volume) / prev_day_volume) * 100, 2)
    END AS day_over_day_growth_pct
FROM with_running_totals
ORDER BY transaction_date DESC, type;

-- View 3: suspicious_activity_view (WITH SECURITY BARRIER)
CREATE VIEW suspicious_activity_view WITH (security_barrier = true) AS
WITH large_transactions AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        a.account_number,
        c.customer_id,
        c.full_name,
        t.amount_kzt,
        t.created_at,
        'Large transaction (>5M KZT)' AS suspicion_reason
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.amount_kzt >= 5000000
        AND t.status = 'completed'
),
frequent_transactions AS (
    SELECT
        t.from_account_id,
        a.account_number,
        c.customer_id,
        c.full_name,
        DATE_TRUNC('hour', t.created_at) AS hour_window,
        COUNT(*) AS txn_count,
        'High frequency (>10 txn/hour)' AS suspicion_reason
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.status = 'completed'
    GROUP BY t.from_account_id, a.account_number, c.customer_id, c.full_name, DATE_TRUNC('hour', t.created_at)
    HAVING COUNT(*) > 10
),
rapid_sequential AS (
    SELECT
        t.transaction_id,
        t.from_account_id,
        a.account_number,
        c.customer_id,
        c.full_name,
        t.created_at,
        LAG(t.created_at) OVER (PARTITION BY t.from_account_id ORDER BY t.created_at) AS prev_txn_time,
        'Rapid sequential transfers (<1 min)' AS suspicion_reason
    FROM transactions t
    JOIN accounts a ON t.from_account_id = a.account_id
    JOIN customers c ON a.customer_id = c.customer_id
    WHERE t.status = 'completed'
)
SELECT
    customer_id, full_name, account_number, suspicion_reason,
    transaction_id, created_at
FROM large_transactions
UNION ALL
SELECT
    customer_id, full_name, account_number, suspicion_reason,
    NULL::bigint, NULL::timestamp with time zone
FROM frequent_transactions
UNION ALL
SELECT
    customer_id, full_name, account_number, suspicion_reason,
    transaction_id, created_at
FROM rapid_sequential
WHERE EXTRACT(EPOCH FROM (created_at - prev_txn_time)) < 60;



-- Task 3: Performance Optimization with Indexes --
-- Index 1: B-tree composite index on transactions
CREATE INDEX idx_transactions_customer_date 
ON transactions(from_account_id, created_at DESC);

EXPLAIN ANALYZE
SELECT transaction_id, amount, currency, status, created_at
FROM transactions
WHERE from_account_id = 5
AND created_at >= CURRENT_DATE - INTERVAL '7 days'
ORDER BY created_at DESC
LIMIT 10;

-- Index 2: Hash index on account_number (exact lookups)
CREATE INDEX idx_accounts_account_number_hash 
ON accounts USING HASH (account_number);

EXPLAIN ANALYZE
SELECT account_id, customer_id, balance, currency, is_active
FROM accounts
WHERE account_number = 'KZ86125KZT5004400100';

-- Index 3: Partial index for active accounts only
CREATE INDEX idx_accounts_active_only 
ON accounts(customer_id, balance) 
WHERE is_active = true;

EXPLAIN ANALYZE
SELECT account_id, customer_id, balance, currency
FROM accounts
WHERE customer_id = 1 AND is_active = true;

-- Test: Query that CANNOT use partial index (is_active = false)
EXPLAIN ANALYZE
SELECT account_id, customer_id, balance
FROM accounts
WHERE customer_id = 1 AND is_active = false;

-- Index 4: Expression index for case-insensitive email search
CREATE INDEX idx_customers_email_lower 
ON customers(LOWER(email));

EXPLAIN ANALYZE
SELECT customer_id, full_name, email, status
FROM customers
WHERE LOWER(email) = 'alexander.petrov@gmail.com';

-- Index 5: GIN index on JSONB columns in audit_log
CREATE INDEX idx_audit_log_new_values_gin 
ON audit_log USING GIN (new_values);

EXPLAIN ANALYZE
SELECT log_id, table_name, action, new_values, changed_at
FROM audit_log
WHERE new_values @> '{"transaction_id": 5}'
LIMIT 10;

CREATE INDEX idx_audit_log_old_values_gin 
ON audit_log USING GIN (old_values);

EXPLAIN ANALYZE
SELECT log_id, table_name, action, old_values, changed_at
FROM audit_log
WHERE old_values @> '{"balance": 5000000}'
LIMIT 5;

-- Index 6: Covering index with INCLUDE clause
CREATE INDEX idx_accounts_covering 
ON accounts(customer_id) 
INCLUDE (balance, currency, is_active);

EXPLAIN ANALYZE
SELECT account_id, balance, currency, is_active
FROM accounts
WHERE customer_id = 1;



-- Task 4: Advanced Procedure - Batch Processing --
CREATE OR REPLACE FUNCTION process_salary_batch(
    p_company_account_number VARCHAR,
    p_payments JSONB
) RETURNS JSONB
LANGUAGE plpgsql
AS $$
DECLARE
    v_company_account_id INTEGER;
    v_company_balance NUMERIC;
    v_total_amount NUMERIC;
    v_employee_iin VARCHAR;
    v_amount NUMERIC;
    v_description TEXT;
    v_employee_account_id INTEGER;
    v_successful_count INTEGER := 0;
    v_failed_count INTEGER := 0;
    v_failed_details JSONB := '[]'::JSONB;
    v_lock_acquired BOOLEAN;
    v_idx INTEGER;
    v_company_total_debit NUMERIC := 0;
    v_employee_account_ids INTEGER[] := '{}';
    v_employee_amounts NUMERIC[] := '{}';
    v_array_idx INTEGER;
    v_array_len INTEGER;
BEGIN
    -- Acquire advisory lock to prevent concurrent batch processing
    SELECT pg_try_advisory_lock(hashtext(p_company_account_number)) INTO v_lock_acquired;

    IF NOT v_lock_acquired THEN
        RETURN jsonb_build_object(
            'success', false,
            'message', 'Another batch is being processed for this company',
            'successful_count', 0,
            'failed_count', 0
        );
    END IF;

    BEGIN
        -- Get and lock company account to prevent concurrent modifications
        SELECT account_id, balance INTO v_company_account_id, v_company_balance
        FROM accounts
        WHERE account_number = p_company_account_number AND is_active = true
        FOR UPDATE;

        IF NOT FOUND THEN
            PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
            RETURN jsonb_build_object('success', false, 'message', 'Company account not found');
        END IF;

        -- Calculate total batch amount for validation
        v_total_amount := 0;
        FOR v_idx IN 0..jsonb_array_length(p_payments)-1 LOOP
            v_total_amount := v_total_amount + ((p_payments->v_idx)->>'amount')::NUMERIC;
        END LOOP;

        -- Validate that company has sufficient balance for entire batch
        IF v_company_balance < v_total_amount THEN
            PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
            RETURN jsonb_build_object(
                'success', false,
                'message', 'Insufficient balance for batch. Required: ' || v_total_amount || ', Available: ' || v_company_balance
            );
        END IF;

        -- Process each payment individually
        FOR v_idx IN 0..jsonb_array_length(p_payments)-1 LOOP
            v_employee_iin := (p_payments->v_idx)->>'iin';
            v_amount := ((p_payments->v_idx)->>'amount')::NUMERIC;
            v_description := (p_payments->v_idx)->>'description';

            BEGIN
                SELECT a.account_id INTO v_employee_account_id
                FROM accounts a
                JOIN customers c ON a.customer_id = c.customer_id
                WHERE c.iin = v_employee_iin AND a.currency = 'KZT' AND a.is_active = true
                LIMIT 1;

                IF NOT FOUND THEN
                    RAISE EXCEPTION 'Employee account not found for IIN %', v_employee_iin;
                END IF;

                INSERT INTO transactions (
                    from_account_id, to_account_id, amount, currency,
                    exchange_rate, amount_kzt, type, status, description
                ) VALUES (
                    v_company_account_id, v_employee_account_id, v_amount, 'KZT',
                    1.0, v_amount, 'transfer', 'completed', v_description
                );

                -- COLLECT balance change for atomic update later
                v_employee_account_ids := v_employee_account_ids || v_employee_account_id;
                v_employee_amounts := v_employee_amounts || v_amount;
                v_company_total_debit := v_company_total_debit + v_amount;

                v_successful_count := v_successful_count + 1;

            EXCEPTION WHEN OTHERS THEN
                -- Catch error for this individual payment
                -- Continue processing other payments
                v_failed_count := v_failed_count + 1;
                v_failed_details := v_failed_details || jsonb_build_object(
                    'iin', v_employee_iin,
                    'amount', v_amount,
                    'error', SQLERRM
                );
            END;
        END LOOP;

        -- Batch update of all balances at the end
        IF v_successful_count > 0 THEN
            -- Update company account: debit total amount in ONE operation
            UPDATE accounts
            SET balance = balance - v_company_total_debit
            WHERE account_id = v_company_account_id;

            -- Update all employee accounts: credit their amounts
            -- Loop through arrays and update each account
            IF array_length(v_employee_account_ids, 1) > 0 THEN
                v_array_len := array_length(v_employee_account_ids, 1);
                FOR v_array_idx IN 1..v_array_len LOOP
                    UPDATE accounts
                    SET balance = balance + v_employee_amounts[v_array_idx]
                    WHERE account_id = v_employee_account_ids[v_array_idx];
                END LOOP;
            END IF;
        END IF;

        -- Release the advisory lock
        PERFORM pg_advisory_unlock(hashtext(p_company_account_number));

        RETURN jsonb_build_object(
            'success', true,
            'successful_count', v_successful_count,
            'failed_count', v_failed_count,
            'failed_details', v_failed_details,
            'total_debited', v_company_total_debit
        );

    EXCEPTION WHEN OTHERS THEN
        -- Ensure lock is released even if error occurs
        PERFORM pg_advisory_unlock(hashtext(p_company_account_number));
        RAISE;
    END;
END;
$$;

-- Materialized view for batch summary report
CREATE MATERIALIZED VIEW batch_summary_report AS
SELECT
    DATE(t.completed_at) AS transaction_date,
    a.account_number AS company_account,
    c.full_name AS company_name,
    t.type AS transaction_type,
    COUNT(*) AS total_transactions,
    SUM(t.amount) AS total_amount,
    AVG(t.amount) AS avg_amount,
    MIN(t.created_at) AS batch_start_time,
    MAX(t.completed_at) AS batch_end_time
FROM transactions t
JOIN accounts a ON t.from_account_id = a.account_id
JOIN customers c ON a.customer_id = c.customer_id
WHERE t.status = 'completed'
GROUP BY DATE(t.completed_at), a.account_number, c.full_name, t.type
ORDER BY DATE(t.completed_at) DESC, a.account_number;



-- TEST CASES --

-- Display all customers
SELECT customer_id, full_name, email, status, daily_limit_kzt
FROM customers
ORDER BY customer_id;

-- Display all accounts with balances
SELECT a.account_id, a.account_number, c.full_name, a.currency, a.balance, a.is_active
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY a.account_id;


-- TEST 1: SUCCESSFUL TRANSFER - Same currency (KZT to KZT)

-- Before transfer
SELECT 'BEFORE Test 1' as test, a.account_number, a.balance
FROM accounts a
WHERE a.account_number IN ('KZ86125KZT5004400100', 'KZ86125KZT5004400200')
ORDER BY a.account_number;

-- Execute transfer
SELECT process_transfer(
    'KZ86125KZT5004400100',     -- Alexander's KZT account
    'KZ86125KZT5004400200',     -- Victoria's KZT account
    100000,                      -- 100,000 KZT
    'KZT',
    'Test 1: Successful same-currency transfer'
) AS result;

-- After transfer
SELECT 'AFTER Test 1' as test, a.account_number, a.balance
FROM accounts a
WHERE a.account_number IN ('KZ86125KZT5004400100', 'KZ86125KZT5004400200')
ORDER BY a.account_number;

-- Check transaction was recorded
SELECT transaction_id, from_account_id, to_account_id, amount, status, description
FROM transactions
WHERE description LIKE '%Test 1%'
ORDER BY transaction_id DESC LIMIT 1;


-- TEST 2: SUCCESSFUL TRANSFER - With currency conversion (USD to KZT)

-- Before transfer
SELECT 'BEFORE Test 2' as test, a.account_number, a.currency, a.balance
FROM accounts a
WHERE a.account_number IN ('KZ86125USD5004400101', 'KZ86125KZT5004400200')
ORDER BY a.account_number;

-- Show exchange rate
SELECT from_currency, to_currency, rate
FROM exchange_rates
WHERE (from_currency = 'USD' AND to_currency = 'KZT')
OR (from_currency = 'KZT' AND to_currency = 'USD')
LIMIT 1;

-- Execute transfer with currency conversion
SELECT process_transfer(
    'KZ86125USD5004400101',
    'KZ86125KZT5004400200',
    100,
    'USD',
    'Test 2: Successful transfer with currency conversion (USD to KZT)'
) AS result;

-- After transfer
SELECT 'AFTER Test 2' as test, a.account_number, a.currency, a.balance
FROM accounts a
WHERE a.account_number IN ('KZ86125USD5004400101', 'KZ86125KZT5004400200')
ORDER BY a.account_number;

-- Check transaction details
SELECT transaction_id, from_account_id, to_account_id, amount, currency, exchange_rate, amount_kzt, status
FROM transactions
WHERE description LIKE '%Test 2%'
ORDER BY transaction_id DESC LIMIT 1;


-- TEST 3: FAILED - Daily limit exceeded

-- Before attempt
SELECT 'BEFORE Test 3' as test, a.account_number, a.balance
FROM accounts a
WHERE a.account_number IN ('KZ86125KZT5004401200', 'KZ86125KZT5004400100')
ORDER BY a.account_number;

SELECT process_transfer(
    'KZ86125KZT5004401200',
    'KZ86125KZT5004400100',
    5000000,
    'KZT',
    'Test 3: Failed - insufficient balance'
) AS result;

-- After failed attempt (balances should be UNCHANGED)
SELECT 'AFTER Test 3' as test, a.account_number, a.balance
FROM accounts a
WHERE a.account_number IN ('KZ86125KZT5004401200', 'KZ86125KZT5004400100')
ORDER BY a.account_number;

-- Verify NO transaction was created
SELECT COUNT(*) as transaction_count
FROM transactions
WHERE description LIKE '%Test 3%' AND status = 'completed';


-- TEST 4: FAILED - Source account not found

-- Try to transfer from non-existent account
SELECT process_transfer(
    'KZ99999999999999999999',
    'KZ86125KZT5004400100',
    100000,
    'KZT',
    'Test 4: Failed - account not found'
) AS result;

-- Verify no transaction created
SELECT COUNT(*) as transaction_count
FROM transactions
WHERE description LIKE '%Test 4%';

-- Check audit log
SELECT new_values
FROM audit_log
WHERE new_values::text LIKE '%not found%'
ORDER BY log_id DESC LIMIT 1;


-- TEST 5: FAILED - Source account is inactive/closed

SELECT 'BEFORE Test 5' as test, a.account_number, a.is_active, c.status
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.account_number = 'KZ86125KZT5004400400';

-- Try to transfer from inactive account
SELECT process_transfer(
    'KZ86125KZT5004400400',
    'KZ86125KZT5004400100',
    100000,
    'KZT',
    'Test 5: Failed - account inactive'
) AS result;

-- Verify balances unchanged
SELECT 'AFTER Test 5' as test, a.account_number, a.balance
FROM accounts a
WHERE a.account_number = 'KZ86125KZT5004400400';


-- TEST 6: FAILED - Destination account not found

SELECT process_transfer(
    'KZ86125KZT5004400100',
    'KZ99999999999999999999',
    100000,
    'KZT',
    'Test 8: Failed - destination account not found'
) AS result;


-- TEST 7: FAILED - Destination account is inactive

SELECT process_transfer(
    'KZ86125KZT5004400100',
    'KZ86125KZT5004400400',
    100000,
    'KZT',
    'Test 9: Failed - destination account inactive'
) AS result;


-- TEST 8: FAILED - Exchange rate not available

-- Try to transfer in a currency with no exchange rate
SELECT process_transfer(
    'KZ86125KZT5004400100',
    'KZ86125KZT5004400200',
    100000,
    'XYZ',
    'Test 10: Failed - exchange rate not available'
) AS result;


-- TEST 9: SUCCESSFUL BATCH SALARY PROCESSING

-- Before batch
SELECT 'BEFORE Batch' as status,
    a.account_number,
    c.full_name,
    a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.account_number IN ('KZ86125KZT5004400500', 'KZ86125KZT5004400100', 'KZ86125KZT5004400200', 'KZ86125KZT5004400300')
ORDER BY a.account_number;

-- Execute salary batch
SELECT process_salary_batch(
    'KZ86125KZT5004400500',
    '[
        {"iin": "123456789012", "amount": 500000, "description": "December salary"},
        {"iin": "234567890123", "amount": 450000, "description": "December salary"},
        {"iin": "345678901234", "amount": 600000, "description": "December salary"}
    ]'::JSONB
) AS batch_result;

-- After batch
SELECT 'AFTER Batch' as status,
    a.account_number,
    c.full_name,
    a.balance
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
WHERE a.account_number IN ('KZ86125KZT5004400500', 'KZ86125KZT5004400100', 'KZ86125KZT5004400200', 'KZ86125KZT5004400300')
ORDER BY a.account_number;

-- Verify transactions were created
SELECT COUNT(*) as transactions_created,
    SUM(amount) as total_amount
FROM transactions
WHERE description LIKE '%December salary%' AND status = 'completed';


-- TEST 10: PARTIAL FAILURE IN BATCH PROCESSING

-- Execute batch with one invalid IIN
SELECT process_salary_batch(
    'KZ86125KZT5004400500',
    '[
        {"iin": "123456789012", "amount": 250000, "description": "Bonus December"},
        {"iin": "999999999999", "amount": 300000, "description": "Bonus December"},
        {"iin": "345678901234", "amount": 280000, "description": "Bonus December"}
    ]'::JSONB
) AS batch_result;

-- Check which succeeded and which failed
SELECT transaction_id, amount, description, status
FROM transactions
WHERE description LIKE '%Bonus December%'
ORDER BY transaction_id;


-- TEST 11: BATCH WITH INSUFFICIENT BALANCE

SELECT process_salary_batch(
    'KZ86125KZT5004400500',
    '[
        {"iin": "123456789012", "amount": 10000000, "description": "Large bonus"},
        {"iin": "234567890123", "amount": 15000000, "description": "Large bonus"},
        {"iin": "345678901234", "amount": 20000000, "description": "Large bonus"},
        {"iin": "567890123456", "amount": 8000000, "description": "Large bonus"}
    ]'::JSONB
) AS batch_result;


-- TEST 12: VIEW TESTING - Customer Balance Summary

-- Display customer balance summary with rankings
SELECT customer_id, full_name, email, status,
       total_balance_kzt, daily_limit_kzt, used_today_kzt,
       daily_limit_utilization_pct, balance_rank
FROM customer_balance_summary
ORDER BY balance_rank
LIMIT 5;


-- TEST 13: VIEW TESTING - Daily Transaction Report

-- Show daily transaction analysis
SELECT transaction_date, type, transaction_count,
       total_volume_kzt, avg_amount_kzt, running_total_kzt, day_over_day_growth_pct
FROM daily_transaction_report
ORDER BY transaction_date DESC
LIMIT 10;


-- TEST 14: VIEW TESTING - Suspicious Activity

-- Display suspicious transactions
SELECT customer_id, full_name, account_number, suspicion_reason, transaction_id, created_at
FROM suspicious_activity_view
LIMIT 10;


-- TEST 15: AUDIT LOG - Verify all operations are logged

-- Show recent audit log entries
SELECT log_id, table_name, action, new_values, changed_at
FROM audit_log
WHERE changed_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
ORDER BY log_id DESC
LIMIT 20;

-- Count failures vs successes
SELECT
    CASE
        WHEN new_values::text LIKE '%error%' THEN 'Failed'
        WHEN new_values::text LIKE '%completed%' THEN 'Successful'
        ELSE 'Unknown'
    END as operation_status,
    COUNT(*) as count
FROM audit_log
WHERE changed_at >= CURRENT_TIMESTAMP - INTERVAL '1 hour'
GROUP BY operation_status;


-- TEST 16: MATERIALIZED VIEW - Batch Summary Report

-- Refresh the materialized view to see latest data
REFRESH MATERIALIZED VIEW batch_summary_report;

-- Display batch summary
SELECT transaction_date, company_account, company_name, transaction_type,
       total_transactions, total_amount, avg_amount, batch_start_time, batch_end_time
FROM batch_summary_report
ORDER BY transaction_date DESC
LIMIT 10;


-- COMPREHENSIVE SUMMARY REPORT

-- Show final account balances
SELECT 'Final Account Status' as report_type,
    a.account_number,
    c.full_name,
    a.currency,
    a.balance,
    a.is_active,
    c.status
FROM accounts a
JOIN customers c ON a.customer_id = c.customer_id
ORDER BY a.account_id;

-- Show transaction statistics
SELECT 'Transaction Statistics' as report_type,
    type,
    status,
    COUNT(*) as count,
    SUM(amount_kzt) as total_kzt,
    AVG(amount_kzt) as avg_kzt
FROM transactions
GROUP BY type, status
ORDER BY type, status;

-- Show test results summary
SELECT 'Test Results Summary' as report_type,
    COUNT(*) as total_tests,
    SUM(CASE WHEN status = 'completed' THEN 1 ELSE 0 END) as successful_operations,
    SUM(CASE WHEN status IN ('failed', 'pending', 'reversed') THEN 1 ELSE 0 END) as failed_operations,
    SUM(amount_kzt) as total_volume_kzt
FROM transactions;
