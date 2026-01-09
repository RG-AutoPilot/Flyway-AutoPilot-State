**RUN THE SQL SCRIPT FIRST TO CREATE THE NEEDED QUEST ITEMS**

# Developer Quest - Dependancy Tracking

**Difficulty:** 🟢 Beginner  
**Time:** 20-25 minutes  
**Prerequisites:** Basic Flyway Desktop knowledge, SQL understanding

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to create views that depend on tables
- How Flyway automatically detects object dependencies
- How Flyway updates dependent views when base tables change
- Why dependency scanning saves development time and prevents errors

## 📖 Scenario
You've created a view that reports on customer orders. When you later need to add a new column to the underlying `Orders` table, you might forget to update all dependent views. This quest demonstrates how Flyway automatically detects these dependencies and regenerates dependent objects for you, ensuring consistency across your schema.

## 🎯 Your Mission
Create a view dependent on a table, modify the table, and see how Flyway automatically handles the dependency for you.

---

## Part 1: Create a View on an Existing Table

### Step 1: Connect to Development Database

Open your preferred SQL client and connect to **AutopilotDev** database.

### Step 2: Create a Dependent View

Run the following SQL to create a view based on the `Sales.Orders` table:

```sql
-- Create a simple reporting view
CREATE VIEW [Sales].[OrderSummary] AS
SELECT 
    o.OrderID,
    o.CustomerID,
    o.EmployeeID,
    o.OrderDate,
    o.ShippedDate,
    c.CompanyName,
    c.ContactName
FROM 
    [Sales].[Orders] o
    INNER JOIN [Sales].[Customers] c ON o.CustomerID = c.CustomerID;
GO

-- Test the view
SELECT TOP 10 * FROM [Sales].[OrderSummary];
GO
```

**Expected Result**: You should see order data combined with customer information.

---

## Part 2: Capture the View with Flyway

### Step 3: Capture to Schema Model (Flyway Desktop)

1. Open **Flyway Desktop**
2. Select your **Development** environment
3. Click the **Diff** tab
4. Compare: **Development → schemaModel**
5. You should see the new view: `Sales.OrderSummary`
6. Click **"Apply to Schema Model"**

### Step 4: Review the Generated File

Navigate to `schema-model/Views/` and open `Sales.OrderSummary.sql`:

```sql
CREATE VIEW [Sales].[OrderSummary] AS
SELECT 
    o.OrderID,
    o.CustomerID,
    o.EmployeeID,
    o.OrderDate,
    o.ShippedDate,
    c.CompanyName,
    c.ContactName
FROM 
    [Sales].[Orders] o
    INNER JOIN [Sales].[Customers] c ON o.CustomerID = c.CustomerID;
GO
```

**Key Point**: Flyway has captured the view definition in your schema model.

---

## Part 3: Alter the Base Table

### Step 5: Add a Column to the Orders Table

Back in your SQL client, add a new column to the `Sales.Orders` table:

```sql
-- Add a new column to track order priority
ALTER TABLE [Sales].[Orders]
ADD [Priority] NVARCHAR(20) NULL DEFAULT 'Standard';
GO

-- Update some sample data
UPDATE [Sales].[Orders]
SET [Priority] = 'High'
WHERE DATEDIFF(day, OrderDate, ShippedDate) <= 1;
GO
```

---

## Part 4: Re-Capture and See Flyway's Magic

### Step 6: Capture Changes Again (Flyway Desktop)

1. Return to **Flyway Desktop**
2. Click the **Diff** tab again
3. Compare: **Development → schemaModel**
4. Notice what Flyway detected:
   - ✅ **Modified Table**: `Sales.Orders` (new `Priority` column)
   - ✅ **Modified View**: `Sales.OrderSummary` (automatically flagged as needing regeneration!)

### Step 7: Apply Changes to Schema Model

1. Click **"Apply to Schema Model"**
2. Review the changes:

**schema-model/Tables/Sales.Orders.sql** - Updated with new column:
```sql
CREATE TABLE [Sales].[Orders] (
    -- ... existing columns ...
    [Priority] NVARCHAR(20) NULL DEFAULT 'Standard'  -- NEW COLUMN
);
```

**schema-model/Views/Sales.OrderSummary.sql** - Regenerated automatically:
```sql
-- Flyway regenerated this view definition because the base table changed
CREATE VIEW [Sales].[OrderSummary] AS
SELECT 
    o.OrderID,
    o.CustomerID,
    o.EmployeeID,
    o.OrderDate,
    o.ShippedDate,
    c.CompanyName,
    c.ContactName
FROM 
    [Sales].[Orders] o
    INNER JOIN [Sales].[Customers] c ON o.CustomerID = c.CustomerID;
GO
```

---

## 🔍 Why This Matters

### Without Dependency Scanning
Without Flyway's automatic dependency detection, you would need to:
1. ❌ Manually remember which views depend on `Sales.Orders`
2. ❌ Manually update each dependent view
3. ❌ Risk missing views, leading to runtime errors
4. ❌ Spend time searching for dependencies across your codebase

### With Flyway's Dependency Scanning
Flyway automatically:
1. ✅ **Scans all database objects** for dependencies
2. ✅ **Detects when a base table changes** that affects views, procedures, or functions
3. ✅ **Regenerates dependent objects** to keep them consistent
4. ✅ **Saves you time** and prevents deployment errors
5. ✅ **Ensures consistency** across all environments

---

## 🎓 Key Learnings

### Flyway Dependancy Tracking Features

1. **Automatic Dependency Graph**
   - Flyway builds a dependency graph of all database objects
   - Understands relationships: Tables → Views → Stored Procedures → Functions

2. **Smart Change Detection**
   - When you modify a base object (like a table)
   - Flyway knows which dependent objects need to be regenerated
   - Flags them in the diff view

3. **Regeneration vs. Manual Updates**
   - Flyway regenerates the entire view definition
   - Keeps schema model in sync with the actual database
   - Prevents "drift" between environments

4. **Deployment Order**
   - Flyway deploys objects in dependency order
   - Tables before views, views before procedures
   - Prevents deployment failures

---

## 💡 Best Practices

### When Working with Dependencies ✅

```sql
-- Good: Simple views that select from tables
CREATE VIEW Sales.CustomerOrders AS
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Sales.Customers c
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- Flyway handles this automatically!
```

### Use Schema Binding for Critical Views (Optional) ✅

```sql
-- Schema binding prevents accidental table changes
CREATE VIEW Sales.CustomerOrders WITH SCHEMABINDING AS
SELECT c.CustomerID, c.CompanyName, o.OrderID, o.OrderDate
FROM Sales.Customers c
INNER JOIN Sales.Orders o ON c.CustomerID = o.CustomerID;

-- You cannot ALTER or DROP base tables without first dropping the view
```

---

## ✅ Success Criteria

- ✅ Created a view `Sales.OrderSummary` dependent on `Sales.Orders`
- ✅ Captured the view to schema model with Flyway
- ✅ Modified the base table `Sales.Orders` by adding a `Priority` column
- ✅ Re-captured changes and observed Flyway flagging both table AND view
- ✅ Understood how Flyway's dependency scanning saves time
- ✅ Schema model now contains updated table and regenerated view

---

## 🔧 Alternative: Using Flyway CLI

If you prefer CLI over Desktop:

```powershell
# After creating the view in Step 2
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="Artifacts\initial-view.zip"

flyway model `
  -model.artifactFilename="Artifacts\initial-view.zip"

# After altering the table in Step 5
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="Artifacts\table-and-view-update.zip"

flyway model `
  -model.artifactFilename="Artifacts\table-and-view-update.zip"
```

---

## 🚀 Advanced Challenge (Optional)

1. Create a stored procedure that queries `Sales.OrderSummary`
2. Modify the view to include the `Priority` column
3. Capture changes and see how Flyway handles the three-level dependency:
   - Table → View → Stored Procedure

---

## 🎉 Congratulations!

You've learned how Flyway's dependency scanning automatically detects and manages object relationships. This feature:
- **Saves development time** by eliminating manual dependency tracking
- **Prevents errors** by ensuring dependent objects stay in sync
- **Improves deployment reliability** by handling deployment order automatically

**Next Quest**: Try **Stored Procedures** to learn how Flyway manages procedural code!
