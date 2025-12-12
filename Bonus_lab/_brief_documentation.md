## Task 1: Transaction Management
### process_transfer() Function
**Error Codes:**
- ACC001: Source account not found
- ACC002: Source account not active
- ACC003: Destination account not found
- ACC004: Destination account not active
- CUST001: Customer not active
- RATE001: Exchange rate not found
- LIMIT001: Daily limit exceeded
- BAL001: Insufficient balance
---

## Task 2: Reporting Views
### View 1: customer_balance_summary
**Window Functions Used:**
- **RANK() OVER (ORDER BY total_balance_kzt DESC)**: Ranks customers by wealth
- Allows for ties (multiple customers with same balance get same rank)

### View 2: daily_transaction_report
**Aggregations:**
- **COUNT(*)**: Number of transactions per day/type
- **SUM(amount_kzt)**: Total transaction volume
- **AVG(amount_kzt)**: Average transaction size

**Window Functions:**
- **SUM() OVER (ORDER BY date)**: Running total of transaction volume
- **LAG()**: Retrieves previous day's volume for comparison

### View 3: suspicious_activity_view
**Implementation:**
- Uses UNION ALL to combine three detection patterns
- LAG() window function for sequential timing analysis
- DATE_TRUNC('hour', ...) for hourly grouping
---



## Task 3: Index Strategy
### Index 1: B-tree Composite Index
- Frequently query transactions by account and date
- DESC order matches typical "recent transactions" queries
- Composite index avoids separate lookups

### Index 2: Hash Index
- Account number lookups are always exact matches (no ranges)
- Hash indexes are faster than B-tree for equality
- Critical path in process_transfer() function

### Index 3: Partial Index
- Almost all queries only need active accounts
- Reduces index size by excluding closed accounts
- Faster maintenance and lower storage

### Index 4: Expression Index
- Email searches should be case-insensitive
- Without index, requires full table scan with LOWER() on every row
- Pre-computes LOWER() at index build time

### Index 5 & 6: GIN Indexes
- JSONB columns contain arbitrary keys
- GIN indexes all keys and values
- Enables fast containment queries (@>, ?, ?&)

### Index 7: Covering Index
- Common query: "Get all accounts for customer with balances"
- INCLUDE clause adds non-key columns to index
- Query satisfied entirely from index (index-only scan)



## Concurrent Transaction Testing
**Setup Two psql Sessions:**
**Session 1:**
```sql
BEGIN;
SELECT * FROM accounts WHERE account_number = 'KZ86125KZT5004400100' FOR UPDATE;
```

**Session 2:**
```sql
BEGIN;
SELECT process_transfer('KZ86125KZT5004400100', 'KZ86125KZT5004400200', 1000, 'KZT', 'Test');
-- This will wait for Session 1's lock
```

**Session 1:**
```sql
COMMIT; -- Release lock
```

**Session 2:**
```sql
-- Now completes immediately
COMMIT;
```

- Session 2 blocks until Session 1 commits
- No deadlock occurs
- Transaction completes successfully after lock release