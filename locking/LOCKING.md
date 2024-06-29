
# PostgreSQL Locks Guide

This guide provides an overview of various types of locks in PostgreSQL, including examples and tasks for each lock type. It helps in managing concurrent access to data, ensuring data integrity and consistency.

## 1. Row-Level Locks

### Write Locks (`FOR UPDATE`)

**Description**: 
- `FOR UPDATE` locks the selected rows from being updated or deleted by other transactions. Other transactions can still read the locked rows but cannot modify them.

**Example**:
```sql
BEGIN;

-- Lock the row for writing
SELECT * FROM Products WHERE product_id = 1 FOR UPDATE;

-- Perform update operation
UPDATE Products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

COMMIT;
```

**Task**: Prevent overselling of a product by ensuring only one transaction can update the stock quantity at a time.

### Read Locks (`FOR SHARE`)

**Description**: 
- `FOR SHARE` locks the selected rows from being updated or deleted, but allows other transactions to read the rows.

**Example**:
```sql
BEGIN;

-- Lock the row for reading
SELECT * FROM Products WHERE product_id = 1 FOR SHARE;

-- Perform read operation
SELECT stock_quantity FROM Products WHERE product_id = 1;

COMMIT;
```

**Task**: Ensure consistent read of a product’s stock quantity while preventing other transactions from modifying it during the read.

## 2. Table-Level Locks

### Exclusive Lock (`LOCK TABLE ... IN EXCLUSIVE MODE`)

**Description**: 
- This lock mode prevents other transactions from acquiring locks that conflict with the exclusive lock. Other transactions can still read the table.

**Example**:
```sql
BEGIN;

-- Lock the entire table for exclusive access
LOCK TABLE Products IN EXCLUSIVE MODE;

-- Perform update operation
UPDATE Products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

COMMIT;
```

**Task**: Perform a bulk update on the `Products` table, ensuring no other transactions can modify the table during the update.

## 3. Advisory Locks

**Description**: 
- Advisory locks are application-level locks that are not tied to specific rows or tables. They are used to control access to resources in a more flexible manner.

**Example**:
```sql
-- Acquire an advisory lock
SELECT pg_advisory_lock(1);

-- Perform operations (read or write)
-- Example: Read product stock
SELECT stock_quantity FROM Products WHERE product_id = 1;

-- Example: Update product stock
UPDATE Products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

-- Release the advisory lock
SELECT pg_advisory_unlock(1);
```

**Task**: Ensure a task such as processing an order or updating a resource is performed without interference from other transactions.

## 4. Transaction Locks

**Description**: 
- Transaction-level locks ensure that only one transaction can hold a particular lock on a resource. This includes read and write locks acquired during the transaction’s operations.

**Example**:
```sql
BEGIN;

-- Perform multiple operations within a transaction
-- Acquire a row-level write lock
SELECT * FROM Products WHERE product_id = 1 FOR UPDATE;

-- Perform read operation
SELECT stock_quantity FROM Products WHERE product_id = 1;

-- Perform write operation
UPDATE Products
SET stock_quantity = stock_quantity - 1
WHERE product_id = 1;

COMMIT;
```

**Task**: Process an order by reading the current stock, updating the stock quantity, and ensuring these operations are atomic and isolated.

## 5. Deadlock Prevention and Monitoring

**Description**: 
- Deadlocks occur when two or more transactions hold locks that the other transactions need to proceed. PostgreSQL detects and resolves deadlocks by aborting one of the transactions.

**Example**:
```sql
-- Transaction 1
BEGIN;

-- Acquire lock on product 1
SELECT * FROM Products WHERE product_id = 1 FOR UPDATE;

-- Simulate some processing time
-- Then, try to acquire lock on product 2
SELECT * FROM Products WHERE product_id = 2 FOR UPDATE;

-- Transaction 2
BEGIN;

-- Acquire lock on product 2
SELECT * FROM Products WHERE product_id = 2 FOR UPDATE;

-- Simulate some processing time
-- Then, try to acquire lock on product 1
SELECT * FROM Products WHERE product_id = 1 FOR UPDATE;
```

**Task**: Monitor and manage deadlocks to ensure smooth operation of concurrent transactions.

## Summary of Lock Types and Examples

1. **Row-Level Locks**:
   - **Write Lock**: `SELECT ... FOR UPDATE`
   - **Read Lock**: `SELECT ... FOR SHARE`
2. **Table-Level Locks**:
   - **Exclusive Lock**: `LOCK TABLE ... IN EXCLUSIVE MODE`
3. **Advisory Locks**:
   - Application-level locking with `pg_advisory_lock` and `pg_advisory_unlock`
4. **Transaction Locks**:
   - Combination of multiple operations within a transaction block.
5. **Deadlock Prevention and Monitoring**:
   - Handle deadlocks by ensuring proper transaction ordering and monitoring.

These locks help manage concurrent access, ensuring data integrity and consistency while preventing conflicts and deadlocks.