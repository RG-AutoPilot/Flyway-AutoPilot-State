# Scenario: Managing Indexes

**Difficulty:** 🟡 Intermediate  
**Time:** 30-35 minutes  
**Type:** Scenario Demonstration

## 🎯 Learning Objectives
By completing this scenario, you will learn:
- How to create clustered and non-clustered indexes
- How Flyway captures index definitions
- How Flyway deploys indexes across environments
- Index types: unique, filtered, included columns
- Performance considerations for indexing
- Modifying and dropping indexes

## 📖 Scenario Overview
Your application is experiencing slow query performance on `Sales.Orders` and `Sales.Customers` tables. You'll create various types of indexes to improve performance, capture them with Flyway, and deploy them to other environments. This demonstrates Flyway's comprehensive index handling capabilities.

---

## Part 1: Create the Scenario

### Step 1: Analyze Current Performance Issues

```sql
-- Connect to Development database

-- Slow query #1: Find orders by date range
SELECT OrderID, CustomerID, OrderDate, ShippedDate, Freight
FROM [Sales].[Orders]
WHERE OrderDate >= '2024-01-01' AND OrderDate < '2025-01-01';

-- Slow query #2: Find customers by city
SELECT CustomerID, CompanyName, ContactName, City, Country
FROM [Sales].[Customers]
WHERE City = 'London';

-- Slow query #3: Find orders with freight over $100
SELECT OrderID, CustomerID, OrderDate, Freight
FROM [Sales].[Orders]
WHERE Freight > 100.00;

-- Check existing indexes
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique,
    i.is_primary_key
FROM sys.indexes i
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'Sales'
    AND OBJECT_NAME(i.object_id) IN ('Orders', 'Customers')
ORDER BY TableName, IndexName;
```

### Step 2: Create Non-Clustered Indexes

```sql
-- Index 1: Non-clustered index on OrderDate for date range queries
CREATE NONCLUSTERED INDEX [IX_Orders_OrderDate]
ON [Sales].[Orders] ([OrderDate])
INCLUDE ([CustomerID], [ShippedDate], [Freight]);
GO

-- Index 2: Non-clustered index on City for customer lookups
CREATE NONCLUSTERED INDEX [IX_Customers_City]
ON [Sales].[Customers] ([City])
INCLUDE ([CompanyName], [ContactName], [Country]);
GO

-- Index 3: Filtered index on high-value orders (freight > 100)
CREATE NONCLUSTERED INDEX [IX_Orders_HighFreight]
ON [Sales].[Orders] ([Freight])
WHERE [Freight] > 100.00;
GO
```

### Step 3: Create Unique Index

```sql
-- Ensure email addresses are unique (if Email column exists, or add it)
-- First, add Email column to Customers if it doesn't exist
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales.Customers') AND name = 'Email')
BEGIN
    ALTER TABLE [Sales].[Customers]
    ADD [Email] NVARCHAR(100) NULL;
END
GO

-- Create unique index on Email
CREATE UNIQUE NONCLUSTERED INDEX [UX_Customers_Email]
ON [Sales].[Customers] ([Email])
WHERE [Email] IS NOT NULL;  -- Filtered unique index (allows NULLs)
GO
```

### Step 4: Create Composite Index

```sql
-- Composite index for customer orders lookup
CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID_OrderDate]
ON [Sales].[Orders] ([CustomerID], [OrderDate] DESC)
INCLUDE ([OrderID], [ShippedDate], [Freight]);
GO
```

### Step 5: Create Index on Foreign Key Column

```sql
-- Index on CustomerID FK for join performance
-- (if it doesn't already exist)
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('Sales.Orders') AND name = 'IX_Orders_CustomerID')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID]
    ON [Sales].[Orders] ([CustomerID]);
END
GO

-- Index on EmployeeID FK
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID('Sales.Orders') AND name = 'IX_Orders_EmployeeID')
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_EmployeeID]
    ON [Sales].[Orders] ([EmployeeID]);
END
GO
```

### Step 6: Verify Indexes Created

```sql
-- View all indexes with details
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique,
    i.is_primary_key,
    i.filter_definition AS FilterDefinition,
    STUFF((
        SELECT ', ' + COL_NAME(ic.object_id, ic.column_id) + 
               CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
        FROM sys.index_columns ic
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') AS KeyColumns,
    STUFF((
        SELECT ', ' + COL_NAME(ic.object_id, ic.column_id)
        FROM sys.index_columns ic
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        ORDER BY ic.index_column_id
        FOR XML PATH('')
    ), 1, 2, '') AS IncludedColumns
FROM sys.indexes i
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'Sales'
    AND OBJECT_NAME(i.object_id) IN ('Orders', 'Customers')
    AND i.type_desc != 'HEAP'
ORDER BY TableName, IndexName;
```

**Expected Result:**
```
TableName   IndexName                         IndexType           is_unique  KeyColumns                  IncludedColumns
Customers   PK_Customers                      CLUSTERED           1          CustomerID                  NULL
Customers   IX_Customers_City                 NONCLUSTERED        0          City ASC                    CompanyName, ContactName, Country
Customers   UX_Customers_Email                NONCLUSTERED        1          Email ASC                   NULL
Orders      PK_Orders                         CLUSTERED           1          OrderID                     NULL
Orders      IX_Orders_OrderDate               NONCLUSTERED        0          OrderDate ASC               CustomerID, ShippedDate, Freight
Orders      IX_Orders_HighFreight             NONCLUSTERED        0          Freight ASC                 NULL
Orders      IX_Orders_CustomerID_OrderDate    NONCLUSTERED        0          CustomerID, OrderDate DESC  OrderID, ShippedDate, Freight
Orders      IX_Orders_CustomerID              NONCLUSTERED        0          CustomerID ASC              NULL
Orders      IX_Orders_EmployeeID              NONCLUSTERED        0          EmployeeID ASC              NULL
```

### Step 7: Test Performance Improvement

```sql
-- Enable execution plan (SSMS: Ctrl+M or Query menu)

-- Test query 1 (should use IX_Orders_OrderDate)
SELECT OrderID, CustomerID, OrderDate, ShippedDate, Freight
FROM [Sales].[Orders]
WHERE OrderDate >= '2024-01-01' AND OrderDate < '2025-01-01';

-- Test query 2 (should use IX_Customers_City)
SELECT CustomerID, CompanyName, ContactName, City, Country
FROM [Sales].[Customers]
WHERE City = 'London';

-- Test query 3 (should use IX_Orders_HighFreight)
SELECT OrderID, CustomerID, OrderDate, Freight
FROM [Sales].[Orders]
WHERE Freight > 100.00;

-- Review execution plans to confirm index usage
```

---

## Part 2: Capture with Flyway

### Step 8: Capture Using Flyway Desktop

```
1. Open Flyway Desktop
2. Select Development environment
3. Navigate to Diff tab
4. Compare: Development → schemaModel

Expected differences:
- Modified table: Sales.Customers (added Email column, UX_Customers_Email index)
- Modified table: Sales.Orders (multiple new indexes)
- Index definitions captured
```

**Apply to Schema Model:**
```
1. Select all changes
2. Click "Apply to Schema Model"
3. Review generated files
```

### Step 9: Or Capture Using Flyway CLI

```powershell
# Create diff artifact
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="$env:TEMP\Artifacts\Index-Changes-Diff.zip" `
  -schemaModelLocation=".\schema-model"

# Capture to schema model
flyway model `
  -model.artifactFilename="$env:TEMP\Artifacts\Index-Changes-Diff.zip" `
  -workingDirectory="."
```

### Step 10: Review Schema Model Files

```powershell
# Check updated files
git status
```

**Expected schema model updates:**

**schema-model/Tables/Sales.Customers.sql** (modified):
```sql
CREATE TABLE [Sales].[Customers] (
    [CustomerID] NCHAR(5) NOT NULL,
    [CompanyName] NVARCHAR(40) NOT NULL,
    [ContactName] NVARCHAR(30) NULL,
    [City] NVARCHAR(15) NULL,
    [Country] NVARCHAR(15) NULL,
    [Email] NVARCHAR(100) NULL,  -- NEW COLUMN
    -- ... other columns ...
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID])
);

-- NON-CLUSTERED INDEX on City with included columns
CREATE NONCLUSTERED INDEX [IX_Customers_City]
ON [Sales].[Customers] ([City])
INCLUDE ([CompanyName], [ContactName], [Country]);

-- UNIQUE INDEX on Email (filtered)
CREATE UNIQUE NONCLUSTERED INDEX [UX_Customers_Email]
ON [Sales].[Customers] ([Email])
WHERE [Email] IS NOT NULL;
```

**schema-model/Tables/Sales.Orders.sql** (modified):
```sql
CREATE TABLE [Sales].[Orders] (
    [OrderID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] NCHAR(5) NULL,
    [EmployeeID] INT NULL,
    [OrderDate] DATETIME NULL,
    [ShippedDate] DATETIME NULL,
    [Freight] MONEY NULL,
    -- ... other columns ...
    CONSTRAINT [PK_Orders] PRIMARY KEY CLUSTERED ([OrderID])
);

-- INDEX 1: OrderDate with included columns
CREATE NONCLUSTERED INDEX [IX_Orders_OrderDate]
ON [Sales].[Orders] ([OrderDate])
INCLUDE ([CustomerID], [ShippedDate], [Freight]);

-- INDEX 2: Filtered index on high freight
CREATE NONCLUSTERED INDEX [IX_Orders_HighFreight]
ON [Sales].[Orders] ([Freight])
WHERE [Freight] > 100.00;

-- INDEX 3: Composite index on CustomerID and OrderDate (descending)
CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID_OrderDate]
ON [Sales].[Orders] ([CustomerID], [OrderDate] DESC)
INCLUDE ([OrderID], [ShippedDate], [Freight]);

-- INDEX 4: FK index on CustomerID
CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID]
ON [Sales].[Orders] ([CustomerID]);

-- INDEX 5: FK index on EmployeeID
CREATE NONCLUSTERED INDEX [IX_Orders_EmployeeID]
ON [Sales].[Orders] ([EmployeeID]);

-- Foreign keys
ALTER TABLE [Sales].[Orders]
ADD CONSTRAINT [FK_Orders_Customers]
FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]);
```

---

## Part 3: Understand Flyway's Index Handling

### Key Observations

1. **Indexes Stored with Table Definition**
   - Indexes are part of the table's schema model file
   - `CREATE INDEX` statements after `CREATE TABLE`
   - All index attributes captured (unique, filtered, included columns)

2. **Index Attributes Preserved**
   ```sql
   -- Flyway captures:
   - Index name
   - Index type (clustered/nonclustered)
   - Uniqueness (unique/non-unique)
   - Key columns (with ASC/DESC)
   - Included columns
   - Filter predicates (WHERE clause)
   ```

3. **Deployment Order**
   ```
   1. CREATE TABLE
   2. Add columns (if altering)
   3. CREATE PRIMARY KEY (clustered index)
   4. CREATE other indexes
   5. CREATE foreign keys
   ```

4. **Idempotent Index Creation**
   ```sql
   -- Flyway generates idempotent scripts:
   IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Name' AND object_id = OBJECT_ID('Table'))
   BEGIN
       CREATE INDEX IX_Name ON Table (Column);
   END
   ```

---

## Part 4: Deploy to Test Environment

### Step 11: Generate Deployment Script

```powershell
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$DEPLOY_SCRIPT = ".\Artifacts\Deploy-Indexes-Test-$TIMESTAMP.sql"
$UNDO_SCRIPT = ".\Artifacts\Undo-Indexes-Test-$TIMESTAMP.sql"

flyway prepare schemaModel Test `
  "-prepare.scriptFilename=$DEPLOY_SCRIPT" `
  "-prepare.undoScriptFilename=$UNDO_SCRIPT" `
  -workingDirectory="."
```

### Step 12: Review Deployment Script

```powershell
code $DEPLOY_SCRIPT
```

**Expected content:**

```sql
BEGIN TRANSACTION;

-- ============================================================================
-- ADD COLUMNS
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales.Customers') AND name = 'Email')
BEGIN
    ALTER TABLE [Sales].[Customers]
    ADD [Email] NVARCHAR(100) NULL;
    PRINT 'Added column Sales.Customers.Email';
END

-- ============================================================================
-- CREATE INDEXES
-- ============================================================================

-- Index 1: City index on Customers
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Customers_City' AND object_id = OBJECT_ID('Sales.Customers'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Customers_City]
    ON [Sales].[Customers] ([City])
    INCLUDE ([CompanyName], [ContactName], [Country]);
    PRINT 'Created index IX_Customers_City';
END

-- Index 2: Unique Email index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'UX_Customers_Email' AND object_id = OBJECT_ID('Sales.Customers'))
BEGIN
    CREATE UNIQUE NONCLUSTERED INDEX [UX_Customers_Email]
    ON [Sales].[Customers] ([Email])
    WHERE [Email] IS NOT NULL;
    PRINT 'Created unique index UX_Customers_Email';
END

-- Index 3: OrderDate index on Orders
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_OrderDate' AND object_id = OBJECT_ID('Sales.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_OrderDate]
    ON [Sales].[Orders] ([OrderDate])
    INCLUDE ([CustomerID], [ShippedDate], [Freight]);
    PRINT 'Created index IX_Orders_OrderDate';
END

-- Index 4: Filtered high freight index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_HighFreight' AND object_id = OBJECT_ID('Sales.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_HighFreight]
    ON [Sales].[Orders] ([Freight])
    WHERE [Freight] > 100.00;
    PRINT 'Created filtered index IX_Orders_HighFreight';
END

-- Index 5: Composite CustomerID + OrderDate index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_CustomerID_OrderDate' AND object_id = OBJECT_ID('Sales.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID_OrderDate]
    ON [Sales].[Orders] ([CustomerID], [OrderDate] DESC)
    INCLUDE ([OrderID], [ShippedDate], [Freight]);
    PRINT 'Created composite index IX_Orders_CustomerID_OrderDate';
END

-- Index 6: CustomerID FK index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_CustomerID' AND object_id = OBJECT_ID('Sales.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_CustomerID]
    ON [Sales].[Orders] ([CustomerID]);
    PRINT 'Created index IX_Orders_CustomerID';
END

-- Index 7: EmployeeID FK index
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE name = 'IX_Orders_EmployeeID' AND object_id = OBJECT_ID('Sales.Orders'))
BEGIN
    CREATE NONCLUSTERED INDEX [IX_Orders_EmployeeID]
    ON [Sales].[Orders] ([EmployeeID]);
    PRINT 'Created index IX_Orders_EmployeeID';
END

COMMIT TRANSACTION;
PRINT 'Index deployment completed successfully.';
```

### Step 13: Validate and Deploy

```powershell
# Pre-deployment snapshot
flyway snapshot Test -snapshot.filename="Pre-Index-Changes"

# Validate
flyway check -changes -code -drift Test

# Deploy
flyway deploy Test "-deploy.scriptFilename=$DEPLOY_SCRIPT"

# Post-deployment snapshot
flyway snapshot Test -snapshot.filename="Post-Index-Changes"
```

---

## Part 5: Verify Indexes in Test

### Step 14: Verify Indexes Deployed

```sql
-- Connect to Test database

-- Check all indexes created
SELECT 
    OBJECT_NAME(i.object_id) AS TableName,
    i.name AS IndexName,
    i.type_desc AS IndexType,
    i.is_unique,
    i.filter_definition AS FilterDefinition,
    STUFF((
        SELECT ', ' + COL_NAME(ic.object_id, ic.column_id) + 
               CASE WHEN ic.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END
        FROM sys.index_columns ic
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 0
        ORDER BY ic.key_ordinal
        FOR XML PATH('')
    ), 1, 2, '') AS KeyColumns,
    STUFF((
        SELECT ', ' + COL_NAME(ic.object_id, ic.column_id)
        FROM sys.index_columns ic
        WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id AND ic.is_included_column = 1
        ORDER BY ic.index_column_id
        FOR XML PATH('')
    ), 1, 2, '') AS IncludedColumns
FROM sys.indexes i
WHERE OBJECT_SCHEMA_NAME(i.object_id) = 'Sales'
    AND OBJECT_NAME(i.object_id) IN ('Orders', 'Customers')
    AND i.type_desc != 'HEAP'
    AND i.name LIKE 'IX_%' OR i.name LIKE 'UX_%'
ORDER BY TableName, IndexName;
```

### Step 15: Test Index Usage in Test

```sql
-- Test queries in Test database with execution plan enabled

-- Should use IX_Orders_OrderDate
SELECT OrderID, CustomerID, OrderDate, ShippedDate, Freight
FROM [Sales].[Orders]
WHERE OrderDate >= '2024-01-01' AND OrderDate < '2025-01-01';

-- Should use IX_Customers_City
SELECT CustomerID, CompanyName, ContactName, City, Country
FROM [Sales].[Customers]
WHERE City = 'London';

-- Should use IX_Orders_CustomerID_OrderDate
SELECT OrderID, OrderDate, ShippedDate, Freight
FROM [Sales].[Orders]
WHERE CustomerID = 'ALFKI'
ORDER BY OrderDate DESC;
```

---

## ✅ Success Criteria

- ✅ Created various index types (non-clustered, unique, filtered, composite)
- ✅ Captured index definitions to schema model
- ✅ Flyway preserved all index attributes (columns, filters, included columns)
- ✅ Deployed indexes to Test environment successfully
- ✅ Verified indexes exist and are used by queries
- ✅ Understood Flyway's index handling capabilities

---

## 🎓 Key Learnings

### Index Types Flyway Handles

1. **Clustered Indexes**
   - Primary key (usually clustered)
   - Only one per table
   - Determines physical row order

2. **Non-Clustered Indexes**
   - Multiple allowed per table
   - Separate structure from table data
   - Can include columns

3. **Unique Indexes**
   - Enforces uniqueness
   - Can be clustered or non-clustered
   - Supports filtered uniqueness

4. **Filtered Indexes**
   - `WHERE` clause limits indexed rows
   - Smaller, more efficient
   - Great for subset queries

5. **Composite Indexes**
   - Multiple key columns
   - Column order matters!
   - Can specify ASC/DESC per column

6. **Covering Indexes**
   - `INCLUDE` non-key columns
   - Query can be satisfied entirely by index
   - Avoid key lookups

### How Flyway Stores Indexes

```
schema-model/Tables/TableName.sql contains:
1. CREATE TABLE statement
2. CREATE INDEX statements (all types)
3. ALTER TABLE (FKs, constraints)

Indexes are part of table definition, not separate files.
```

---

## 💡 Best Practices

### Index Naming Convention ✅
```
IX_TableName_Column(s)        - Standard index
UX_TableName_Column(s)        - Unique index
PK_TableName                  - Primary key (clustered)
CIX_TableName_Column(s)       - Clustered index (non-PK)
```

### When to Create Indexes ✅
```
✅ Columns in WHERE clauses
✅ Columns in JOIN conditions
✅ Foreign key columns
✅ Columns in ORDER BY clauses
✅ Frequently searched columns

❌ Small tables (<1000 rows)
❌ Columns with low selectivity
❌ Frequently updated columns (write overhead)
```

### Included Columns ✅
```sql
-- Include columns frequently selected with key columns
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON Orders (CustomerID)
INCLUDE (OrderDate, ShippedDate, Freight);  -- Covering index

-- Query uses index without key lookups:
SELECT OrderDate, ShippedDate, Freight
FROM Orders
WHERE CustomerID = 'ALFKI';
```

### Filtered Indexes ✅
```sql
-- Index only active orders
CREATE NONCLUSTERED INDEX IX_Orders_Active
ON Orders (OrderDate)
WHERE ShippedDate IS NULL;

-- Smaller index, faster queries for active orders
SELECT * FROM Orders
WHERE ShippedDate IS NULL AND OrderDate > '2024-01-01';
```

---

## 🚀 Advanced Scenarios

### Modifying an Existing Index

```sql
-- You cannot ALTER an index - must DROP and recreate
DROP INDEX [IX_Orders_OrderDate] ON [Sales].[Orders];

CREATE NONCLUSTERED INDEX [IX_Orders_OrderDate]
ON [Sales].[Orders] ([OrderDate] DESC)  -- Changed to descending
INCLUDE ([CustomerID], [ShippedDate], [Freight], [OrderID]);  -- Added OrderID

-- Capture with Flyway - it will detect the modification
```

### Removing an Index

```sql
-- Drop index in Development
DROP INDEX [IX_Orders_HighFreight] ON [Sales].[Orders];

-- Capture with Flyway
-- Deploy to Test → index will be removed
```

### Online Index Operations (Enterprise Edition)

```sql
-- Create index with ONLINE option (no table locking)
CREATE NONCLUSTERED INDEX IX_Orders_CustomerID
ON Orders (CustomerID)
WITH (ONLINE = ON);

-- Flyway captures this option
```

---

## 📚 Performance Tips

### Monitor Index Usage

```sql
-- Check index usage statistics
SELECT 
    OBJECT_NAME(s.object_id) AS TableName,
    i.name AS IndexName,
    s.user_seeks,
    s.user_scans,
    s.user_lookups,
    s.user_updates,
    s.last_user_seek,
    s.last_user_scan
FROM sys.dm_db_index_usage_stats s
INNER JOIN sys.indexes i ON s.object_id = i.object_id AND s.index_id = i.index_id
WHERE OBJECT_SCHEMA_NAME(s.object_id) = 'Sales'
ORDER BY TableName, IndexName;
```

### Find Missing Indexes

```sql
-- SQL Server suggests missing indexes
SELECT 
    OBJECT_NAME(d.object_id) AS TableName,
    d.equality_columns,
    d.inequality_columns,
    d.included_columns,
    s.avg_user_impact,
    s.user_seeks + s.user_scans AS TotalSeeks
FROM sys.dm_db_missing_index_details d
INNER JOIN sys.dm_db_missing_index_groups g ON d.index_handle = g.index_handle
INNER JOIN sys.dm_db_missing_index_group_stats s ON g.index_group_handle = s.group_handle
WHERE OBJECT_SCHEMA_NAME(d.object_id) = 'Sales'
ORDER BY s.avg_user_impact DESC;
```

---

## 📚 Related Quests

- **Scenario: Foreign Key** - Indexing FK columns for join performance
- **Scenario: Cross-Dependency** - Complex dependencies and index considerations
- **Developer Quest 06:** Modify Existing Object - Modifying indexed tables

---

**Congratulations!** 🎉 You've mastered how Flyway handles database indexes!
