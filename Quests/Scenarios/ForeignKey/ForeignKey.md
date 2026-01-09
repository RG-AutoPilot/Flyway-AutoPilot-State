# Scenario: Managing Foreign Key Constraints

**Difficulty:** 🟡 Intermediate  
**Time:** 30-35 minutes  
**Type:** Scenario Demonstration

## 🎯 Learning Objectives
By completing this scenario, you will learn:
- How to create tables with foreign key relationships
- How Flyway captures FK constraints
- How Flyway handles FK dependency order during deployment
- Adding/removing foreign keys to existing tables
- Managing circular dependencies

## 📖 Scenario Overview
You're building a loyalty program feature that requires foreign key relationships between `Sales.LoyaltyProgram` and `Sales.Customers`. This scenario demonstrates how Flyway intelligently handles FK constraints, dependency ordering, and deployment across environments.

---

## Part 1: Create the Scenario

### Step 1: Connect to Development Database

```powershell
# Open SSMS or Azure Data Studio
# Connect to Development environment
# Database: AutopilotDev
```

### Step 2: Create Tables with Foreign Keys

```sql
-- Scenario: Loyalty Program with Customer relationships

-- Create LoyaltyTier lookup table
CREATE TABLE [Sales].[LoyaltyTier] (
    [TierID] INT IDENTITY(1,1) NOT NULL,
    [TierName] NVARCHAR(50) NOT NULL,
    [MinimumSpend] DECIMAL(18, 2) NOT NULL,
    [DiscountPercentage] DECIMAL(5, 2) NOT NULL,
    CONSTRAINT [PK_LoyaltyTier] PRIMARY KEY CLUSTERED ([TierID])
);
GO

-- Insert tier data
INSERT INTO [Sales].[LoyaltyTier] (TierName, MinimumSpend, DiscountPercentage)
VALUES 
    ('Bronze', 0.00, 5.00),
    ('Silver', 1000.00, 10.00),
    ('Gold', 5000.00, 15.00),
    ('Platinum', 10000.00, 20.00);
GO

-- Update existing Customers table to add LoyaltyTierID
ALTER TABLE [Sales].[Customers]
ADD [LoyaltyTierID] INT NULL;
GO

-- Add foreign key from Customers to LoyaltyTier
ALTER TABLE [Sales].[Customers]
ADD CONSTRAINT [FK_Customers_LoyaltyTier]
FOREIGN KEY ([LoyaltyTierID]) REFERENCES [Sales].[LoyaltyTier]([TierID]);
GO

-- Update existing LoyaltyProgram table to add CustomerID FK
ALTER TABLE [Sales].[LoyaltyProgram]
ADD [CustomerID] NCHAR(5) NULL;
GO

-- Add foreign key from LoyaltyProgram to Customers
ALTER TABLE [Sales].[LoyaltyProgram]
ADD CONSTRAINT [FK_LoyaltyProgram_Customers]
FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]);
GO

-- Create rewards tracking table with multiple FKs
CREATE TABLE [Sales].[LoyaltyRewards] (
    [RewardID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] NCHAR(5) NOT NULL,
    [TierID] INT NOT NULL,
    [PointsEarned] INT NOT NULL,
    [PointsRedeemed] INT NOT NULL DEFAULT 0,
    [EarnedDate] DATE NOT NULL,
    [ExpirationDate] DATE NOT NULL,
    CONSTRAINT [PK_LoyaltyRewards] PRIMARY KEY CLUSTERED ([RewardID]),
    CONSTRAINT [FK_LoyaltyRewards_Customers] 
        FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]),
    CONSTRAINT [FK_LoyaltyRewards_LoyaltyTier] 
        FOREIGN KEY ([TierID]) REFERENCES [Sales].[LoyaltyTier]([TierID])
);
GO
```

### Step 3: Verify Foreign Keys Created

```sql
-- View all foreign keys in Sales schema
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'Sales'
    AND fk.name IN ('FK_Customers_LoyaltyTier', 'FK_LoyaltyProgram_Customers', 'FK_LoyaltyRewards_Customers', 'FK_LoyaltyRewards_LoyaltyTier')
ORDER BY TableName, ForeignKeyName;
```

**Expected Result:**
```
ForeignKeyName                  TableName       ColumnName      ReferencedTable  ReferencedColumn
FK_Customers_LoyaltyTier        Customers       LoyaltyTierID   LoyaltyTier      TierID
FK_LoyaltyProgram_Customers     LoyaltyProgram  CustomerID      Customers        CustomerID
FK_LoyaltyRewards_Customers     LoyaltyRewards  CustomerID      Customers        CustomerID
FK_LoyaltyRewards_LoyaltyTier   LoyaltyRewards  TierID          LoyaltyTier      TierID
```

### Step 4: Test Foreign Key Constraints

```sql
-- This should work (valid TierID)
UPDATE [Sales].[Customers]
SET [LoyaltyTierID] = 1  -- Bronze tier
WHERE CustomerID = 'ALFKI';

-- This should FAIL (invalid TierID)
UPDATE [Sales].[Customers]
SET [LoyaltyTierID] = 999  -- Non-existent tier
WHERE CustomerID = 'ALFKI';
-- Error: FK constraint violation

-- This should work (insert reward for existing customer)
INSERT INTO [Sales].[LoyaltyRewards] (CustomerID, TierID, PointsEarned, EarnedDate, ExpirationDate)
VALUES ('ALFKI', 1, 100, GETDATE(), DATEADD(YEAR, 1, GETDATE()));

-- This should FAIL (non-existent customer)
INSERT INTO [Sales].[LoyaltyRewards] (CustomerID, TierID, PointsEarned, EarnedDate, ExpirationDate)
VALUES ('XXXXX', 1, 100, GETDATE(), DATEADD(YEAR, 1, GETDATE()));
-- Error: FK constraint violation
```

---

## Part 2: Capture with Flyway

### Step 5: Capture Using Flyway Desktop

```
1. Open Flyway Desktop
2. Select Development environment
3. Navigate to Diff tab
4. Compare: Development → schemaModel

Expected differences:
- New table: Sales.LoyaltyTier
- New table: Sales.LoyaltyRewards
- Modified table: Sales.Customers (added LoyaltyTierID column + FK)
- Modified table: Sales.LoyaltyProgram (added CustomerID column + FK)
- New foreign keys: 4 constraints
```

**Apply to Schema Model:**
```
1. Select all changes
2. Click "Apply to Schema Model"
3. Review generated files
```

### Step 6: Or Capture Using Flyway CLI

```powershell
# Create diff artifact
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="$env:TEMP\Artifacts\FK-Changes-Diff.zip" `
  -schemaModelLocation=".\schema-model"

# Capture to schema model
flyway model `
  -model.artifactFilename="$env:TEMP\Artifacts\FK-Changes-Diff.zip" `
  -workingDirectory="."
```

### Step 7: Review Schema Model Files

```powershell
# Check updated files
git status
```

**Expected changes:**

**schema-model/Tables/Sales.LoyaltyTier.sql** (new file):
```sql
CREATE TABLE [Sales].[LoyaltyTier] (
    [TierID] INT IDENTITY(1,1) NOT NULL,
    [TierName] NVARCHAR(50) NOT NULL,
    [MinimumSpend] DECIMAL(18, 2) NOT NULL,
    [DiscountPercentage] DECIMAL(5, 2) NOT NULL,
    CONSTRAINT [PK_LoyaltyTier] PRIMARY KEY CLUSTERED ([TierID])
);
```

**schema-model/Tables/Sales.Customers.sql** (modified):
```sql
CREATE TABLE [Sales].[Customers] (
    [CustomerID] NCHAR(5) NOT NULL,
    [CompanyName] NVARCHAR(40) NOT NULL,
    [ContactName] NVARCHAR(30) NULL,
    -- ... existing columns ...
    [LoyaltyTierID] INT NULL,  -- NEW COLUMN
    CONSTRAINT [PK_Customers] PRIMARY KEY CLUSTERED ([CustomerID])
);

-- NEW FOREIGN KEY
ALTER TABLE [Sales].[Customers]
ADD CONSTRAINT [FK_Customers_LoyaltyTier]
FOREIGN KEY ([LoyaltyTierID]) REFERENCES [Sales].[LoyaltyTier]([TierID]);
```

**schema-model/Tables/Sales.LoyaltyProgram.sql** (modified):
```sql
CREATE TABLE [Sales].[LoyaltyProgram] (
    [LoyaltyID] INT IDENTITY(1,1) NOT NULL,
    [ProgramName] NVARCHAR(100) NOT NULL,
    -- ... existing columns ...
    [CustomerID] NCHAR(5) NULL,  -- NEW COLUMN
    CONSTRAINT [PK_LoyaltyProgram] PRIMARY KEY CLUSTERED ([LoyaltyID])
);

-- NEW FOREIGN KEY
ALTER TABLE [Sales].[LoyaltyProgram]
ADD CONSTRAINT [FK_LoyaltyProgram_Customers]
FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]);
```

**schema-model/Tables/Sales.LoyaltyRewards.sql** (new file):
```sql
CREATE TABLE [Sales].[LoyaltyRewards] (
    [RewardID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] NCHAR(5) NOT NULL,
    [TierID] INT NOT NULL,
    [PointsEarned] INT NOT NULL,
    [PointsRedeemed] INT NOT NULL DEFAULT 0,
    [EarnedDate] DATE NOT NULL,
    [ExpirationDate] DATE NOT NULL,
    CONSTRAINT [PK_LoyaltyRewards] PRIMARY KEY CLUSTERED ([RewardID])
);

-- FOREIGN KEYS
ALTER TABLE [Sales].[LoyaltyRewards]
ADD CONSTRAINT [FK_LoyaltyRewards_Customers] 
    FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]);

ALTER TABLE [Sales].[LoyaltyRewards]
ADD CONSTRAINT [FK_LoyaltyRewards_LoyaltyTier] 
    FOREIGN KEY ([TierID]) REFERENCES [Sales].[LoyaltyTier]([TierID]);
```

---

## Part 3: Understand Flyway's FK Handling

### Key Observation: Deployment Order Matters

Flyway must deploy objects in the correct order to satisfy FK dependencies:

```
Correct order:
1. CREATE TABLE Sales.LoyaltyTier (parent)
2. CREATE TABLE Sales.Customers (if not exists)
3. ALTER TABLE Sales.Customers ADD LoyaltyTierID column
4. ALTER TABLE Sales.Customers ADD FK to LoyaltyTier
5. ALTER TABLE Sales.LoyaltyProgram ADD CustomerID column
6. ALTER TABLE Sales.LoyaltyProgram ADD FK to Customers
7. CREATE TABLE Sales.LoyaltyRewards (with FKs to both)

Wrong order would cause:
❌ Cannot create FK to table that doesn't exist yet
❌ Cannot reference column that doesn't exist yet
```

**How Flyway Handles This:**
- ✅ Analyzes FK dependencies automatically
- ✅ Sorts tables by dependency graph
- ✅ Creates parent tables before child tables
- ✅ Creates tables before adding FKs
- ✅ Wraps in transactions for safety

---

## Part 4: Deploy to Test Environment

### Step 8: Generate Deployment Script

```powershell
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$DEPLOY_SCRIPT = ".\Artifacts\Deploy-FK-Test-$TIMESTAMP.sql"
$UNDO_SCRIPT = ".\Artifacts\Undo-FK-Test-$TIMESTAMP.sql"

flyway prepare schemaModel Test `
  "-prepare.scriptFilename=$DEPLOY_SCRIPT" `
  "-prepare.undoScriptFilename=$UNDO_SCRIPT" `
  -workingDirectory="."
```

### Step 9: Review Deployment Script - Notice the Order!

```powershell
code $DEPLOY_SCRIPT
```

**Expected deployment order (Flyway handles this automatically):**

```sql
BEGIN TRANSACTION;

-- ============================================================================
-- STEP 1: Create parent table (LoyaltyTier)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LoyaltyTier' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[LoyaltyTier] (
        [TierID] INT IDENTITY(1,1) NOT NULL,
        [TierName] NVARCHAR(50) NOT NULL,
        [MinimumSpend] DECIMAL(18, 2) NOT NULL,
        [DiscountPercentage] DECIMAL(5, 2) NOT NULL,
        CONSTRAINT [PK_LoyaltyTier] PRIMARY KEY CLUSTERED ([TierID])
    );
    PRINT 'Created table Sales.LoyaltyTier';
END

-- ============================================================================
-- STEP 2: Alter existing Customers table (add column)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales.Customers') AND name = 'LoyaltyTierID')
BEGIN
    ALTER TABLE [Sales].[Customers]
    ADD [LoyaltyTierID] INT NULL;
    PRINT 'Added column Sales.Customers.LoyaltyTierID';
END

-- ============================================================================
-- STEP 3: Add FK from Customers to LoyaltyTier
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Customers_LoyaltyTier')
BEGIN
    ALTER TABLE [Sales].[Customers]
    ADD CONSTRAINT [FK_Customers_LoyaltyTier]
    FOREIGN KEY ([LoyaltyTierID]) REFERENCES [Sales].[LoyaltyTier]([TierID]);
    PRINT 'Created FK: FK_Customers_LoyaltyTier';
END

-- ============================================================================
-- STEP 4: Alter LoyaltyProgram table (add column)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales.LoyaltyProgram') AND name = 'CustomerID')
BEGIN
    ALTER TABLE [Sales].[LoyaltyProgram]
    ADD [CustomerID] NCHAR(5) NULL;
    PRINT 'Added column Sales.LoyaltyProgram.CustomerID';
END

-- ============================================================================
-- STEP 5: Add FK from LoyaltyProgram to Customers
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_LoyaltyProgram_Customers')
BEGIN
    ALTER TABLE [Sales].[LoyaltyProgram]
    ADD CONSTRAINT [FK_LoyaltyProgram_Customers]
    FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]);
    PRINT 'Created FK: FK_LoyaltyProgram_Customers';
END

-- ============================================================================
-- STEP 6: Create child table with multiple FKs
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LoyaltyRewards' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[LoyaltyRewards] (
        [RewardID] INT IDENTITY(1,1) NOT NULL,
        [CustomerID] NCHAR(5) NOT NULL,
        [TierID] INT NOT NULL,
        [PointsEarned] INT NOT NULL,
        [PointsRedeemed] INT NOT NULL DEFAULT 0,
        [EarnedDate] DATE NOT NULL,
        [ExpirationDate] DATE NOT NULL,
        CONSTRAINT [PK_LoyaltyRewards] PRIMARY KEY CLUSTERED ([RewardID])
    );
    PRINT 'Created table Sales.LoyaltyRewards';
    
    -- Add FKs to newly created table
    ALTER TABLE [Sales].[LoyaltyRewards]
    ADD CONSTRAINT [FK_LoyaltyRewards_Customers] 
        FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID]);
    
    ALTER TABLE [Sales].[LoyaltyRewards]
    ADD CONSTRAINT [FK_LoyaltyRewards_LoyaltyTier] 
        FOREIGN KEY ([TierID]) REFERENCES [Sales].[LoyaltyTier]([TierID]);
    
    PRINT 'Created FKs for Sales.LoyaltyRewards';
END

COMMIT TRANSACTION;
PRINT 'Foreign key deployment completed successfully.';
```

### Step 10: Validate and Deploy

```powershell
# Pre-deployment snapshot
flyway snapshot Test -snapshot.filename="Pre-FK-Changes"

# Validate
flyway check -changes -code -drift Test

# Deploy
flyway deploy Test "-deploy.scriptFilename=$DEPLOY_SCRIPT"

# Post-deployment snapshot
flyway snapshot Test -snapshot.filename="Post-FK-Changes"
```

---

## Part 5: Verify Foreign Keys

### Step 11: Verify in Test Database

```sql
-- Connect to Test database

-- Verify all FKs created
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS TableName,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ColumnName,
    OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ReferencedColumn,
    fk.is_disabled
FROM sys.foreign_keys fk
INNER JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'Sales'
    AND OBJECT_NAME(fk.parent_object_id) IN ('Customers', 'LoyaltyProgram', 'LoyaltyRewards')
ORDER BY TableName, ForeignKeyName;
```

### Step 12: Test FK Constraints in Test

```sql
-- Should succeed
UPDATE [Sales].[Customers]
SET [LoyaltyTierID] = 2  -- Silver tier
WHERE CustomerID = 'ALFKI';

-- Should fail (referential integrity)
DELETE FROM [Sales].[LoyaltyTier]
WHERE TierID = 2;
-- Error: Cannot delete because FK constraint exists
```

---

## ✅ Success Criteria

- ✅ Created tables with foreign key relationships
- ✅ Captured FK constraints to schema model
- ✅ Flyway correctly ordered deployment script
- ✅ Deployed FK changes to Test successfully
- ✅ Verified FK constraints enforce referential integrity
- ✅ Understood Flyway's dependency handling

---

## 🎓 Key Learnings

### How Flyway Handles Foreign Keys

1. **Automatic Dependency Resolution**
   - Analyzes FK relationships between tables
   - Builds dependency graph
   - Deploys in topologically sorted order
   - Parents before children

2. **Idempotent FK Creation**
   ```sql
   IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Name')
   BEGIN
       ALTER TABLE ... ADD CONSTRAINT FK_Name FOREIGN KEY ...
   END
   ```

3. **FK Storage in Schema Model**
   - FKs stored with the child table definition
   - `ALTER TABLE` statements after `CREATE TABLE`
   - Clearly shows table relationships

4. **Transaction Safety**
   - All FK changes wrapped in transactions
   - If any FK fails, entire deployment rolls back
   - Prevents partial FK deployments

---

## 💡 Best Practices

### Naming FK Constraints ✅
```sql
-- Good naming convention
FK_ChildTable_ParentTable

Examples:
FK_Customers_LoyaltyTier
FK_LoyaltyProgram_Customers
FK_LoyaltyRewards_Customers
```

### Nullable vs. NOT NULL FK Columns ✅
```sql
-- Optional relationship (nullable)
ALTER TABLE [Sales].[Customers]
ADD [LoyaltyTierID] INT NULL;  -- Customer might not have a tier yet

-- Required relationship (not null)
ALTER TABLE [Sales].[LoyaltyRewards]
ADD [CustomerID] NCHAR(5) NOT NULL;  -- Reward MUST belong to a customer
```

### Cascading Actions ✅
```sql
-- Cascade delete (use with caution!)
ALTER TABLE [Sales].[LoyaltyRewards]
ADD CONSTRAINT [FK_LoyaltyRewards_Customers]
FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID])
ON DELETE CASCADE;  -- Delete rewards when customer deleted

-- Cascade update
ON UPDATE CASCADE;  -- Update FK when parent PK changes
```

### Testing FK Constraints ✅
```sql
-- Always test in Development:
-- 1. Valid inserts should succeed
-- 2. Invalid inserts should fail
-- 3. Deleting referenced rows should fail (or cascade)
```

---

## 🚀 Advanced Scenarios

### Removing Foreign Keys

```sql
-- Drop FK constraint
ALTER TABLE [Sales].[Customers]
DROP CONSTRAINT [FK_Customers_LoyaltyTier];

-- Capture to schema model with Flyway
-- Deploy will remove FK from other environments
```

### Circular Dependencies

```sql
-- Problem: Table A references Table B, Table B references Table A
-- Solution: Create tables first, add FKs after

-- Step 1: Create tables without FKs
CREATE TABLE TableA (ID INT PRIMARY KEY, BID INT NULL);
CREATE TABLE TableB (ID INT PRIMARY KEY, AID INT NULL);

-- Step 2: Add FKs after both tables exist
ALTER TABLE TableA ADD CONSTRAINT FK_A_B FOREIGN KEY (BID) REFERENCES TableB(ID);
ALTER TABLE TableB ADD CONSTRAINT FK_B_A FOREIGN KEY (AID) REFERENCES TableA(ID);
```

Flyway handles this by separating table creation from FK creation!

---

## 📚 Related Quests

- **Scenario: New Schema** - Schema creation and organization
- **Scenario: Cross-Dependency** - Complex dependency management
- **Scenario: Index** - Indexing foreign key columns for performance

---

**Congratulations!** 🎉 You've mastered how Flyway handles foreign key constraints and dependency management!
