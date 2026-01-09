# Scenario: Managing Cross-Schema Dependencies

**Difficulty:** 🔴 Advanced  
**Time:** 35-45 minutes  
**Type:** Scenario Demonstration

## 🎯 Learning Objectives
By completing this scenario, you will learn:
- How to create objects with cross-schema dependencies
- How Flyway analyzes and handles complex dependency graphs
- Deployment ordering for multi-schema objects
- Managing circular dependencies
- Views, stored procedures, and functions across schemas
- Best practices for cross-schema design

## 📖 Scenario Overview
Your application needs a reporting layer that pulls data from multiple schemas (`Sales`, `Logistics`, `HR`). You'll create views, stored procedures, and functions that reference objects across schema boundaries. This demonstrates Flyway's sophisticated dependency resolution capabilities.

---

## Part 1: Create the Scenario

### Step 1: Connect to Development Database

```powershell
# Open SSMS or Azure Data Studio
# Connect to Development environment
# Database: AutopilotDev
```

### Step 2: Ensure Base Schemas and Tables Exist

```sql
-- Verify schemas exist
SELECT name FROM sys.schemas WHERE name IN ('Sales', 'Logistics', 'HR', 'Reporting');

-- Create Reporting schema if missing
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Reporting')
BEGIN
    CREATE SCHEMA [Reporting] AUTHORIZATION [dbo];
    PRINT 'Created Reporting schema';
END
GO

-- Verify key tables exist
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS TableName
FROM sys.tables
WHERE name IN ('Customers', 'Orders', 'Employees', 'Flight')
ORDER BY SchemaName, TableName;
```

### Step 3: Create Cross-Schema View (Sales + Logistics)

```sql
-- Reporting view joining Sales and Logistics data
CREATE VIEW [Reporting].[CustomerOrdersWithShipping]
AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.City AS CustomerCity,
    c.Country AS CustomerCountry,
    o.OrderID,
    o.OrderDate,
    o.ShippedDate,
    o.Freight,
    s.CompanyName AS ShipperName,
    DATEDIFF(DAY, o.OrderDate, o.ShippedDate) AS DaysToShip
FROM [Sales].[Customers] c
INNER JOIN [Sales].[Orders] o ON c.CustomerID = o.CustomerID
LEFT JOIN [Logistics].[Shippers] s ON o.ShipVia = s.ShipperID;
GO
```

**Dependency Graph:**
```
Reporting.CustomerOrdersWithShipping (VIEW)
  ↓ depends on
  ├── Sales.Customers (TABLE)
  ├── Sales.Orders (TABLE)
  └── Logistics.Shippers (TABLE)
```

### Step 4: Create Cross-Schema Function (Sales + HR)

```sql
-- Function to calculate employee sales commission
CREATE FUNCTION [Reporting].[fn_EmployeeSalesCommission]
(
    @EmployeeID INT,
    @StartDate DATE,
    @EndDate DATE
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    DECLARE @TotalSales DECIMAL(18, 2);
    DECLARE @CommissionRate DECIMAL(5, 2);
    DECLARE @Commission DECIMAL(18, 2);
    
    -- Get total sales for employee
    SELECT @TotalSales = SUM(od.UnitPrice * od.Quantity * (1 - od.Discount))
    FROM [Sales].[Orders] o
    INNER JOIN [Sales].[Order Details] od ON o.OrderID = od.OrderID
    WHERE o.EmployeeID = @EmployeeID
        AND o.OrderDate >= @StartDate
        AND o.OrderDate < @EndDate;
    
    -- Get employee commission rate (assume 5% for simplicity, or from HR.Employees if column exists)
    SET @CommissionRate = 0.05;
    
    -- Calculate commission
    SET @Commission = ISNULL(@TotalSales, 0) * @CommissionRate;
    
    RETURN @Commission;
END
GO
```

**Dependency Graph:**
```
Reporting.fn_EmployeeSalesCommission (FUNCTION)
  ↓ depends on
  ├── Sales.Orders (TABLE)
  └── Sales.[Order Details] (TABLE)
```

### Step 5: Create Cross-Schema Stored Procedure (Multi-Schema)

```sql
-- Procedure to generate monthly sales report across all schemas
CREATE PROCEDURE [Reporting].[usp_GenerateMonthlySalesReport]
    @Year INT,
    @Month INT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @StartDate DATE = DATEFROMPARTS(@Year, @Month, 1);
    DECLARE @EndDate DATE = DATEADD(MONTH, 1, @StartDate);
    
    -- Sales summary
    SELECT 
        'Sales Summary' AS ReportSection,
        c.CompanyName AS Customer,
        COUNT(DISTINCT o.OrderID) AS TotalOrders,
        SUM(od.UnitPrice * od.Quantity * (1 - od.Discount)) AS TotalSales,
        e.FirstName + ' ' + e.LastName AS SalesRep
    FROM [Sales].[Orders] o
    INNER JOIN [Sales].[Customers] c ON o.CustomerID = c.CustomerID
    INNER JOIN [Sales].[Order Details] od ON o.OrderID = od.OrderID
    LEFT JOIN [Operation].[Employees] e ON o.EmployeeID = e.EmployeeID
    WHERE o.OrderDate >= @StartDate AND o.OrderDate < @EndDate
    GROUP BY c.CompanyName, e.FirstName, e.LastName
    ORDER BY TotalSales DESC;
    
    -- Shipping summary
    SELECT 
        'Shipping Summary' AS ReportSection,
        s.CompanyName AS Shipper,
        COUNT(DISTINCT o.OrderID) AS OrdersShipped,
        SUM(o.Freight) AS TotalFreight,
        AVG(DATEDIFF(DAY, o.OrderDate, o.ShippedDate)) AS AvgDaysToShip
    FROM [Sales].[Orders] o
    INNER JOIN [Logistics].[Shippers] s ON o.ShipVia = s.ShipperID
    WHERE o.OrderDate >= @StartDate AND o.OrderDate < @EndDate
        AND o.ShippedDate IS NOT NULL
    GROUP BY s.CompanyName
    ORDER BY OrdersShipped DESC;
END
GO
```

**Dependency Graph:**
```
Reporting.usp_GenerateMonthlySalesReport (PROCEDURE)
  ↓ depends on
  ├── Sales.Orders (TABLE)
  ├── Sales.Customers (TABLE)
  ├── Sales.[Order Details] (TABLE)
  ├── Operation.Employees (TABLE)
  └── Logistics.Shippers (TABLE)
```

### Step 6: Create Complex Cross-Schema View (Uses Function)

```sql
-- View that uses the cross-schema function
CREATE VIEW [Reporting].[EmployeeCommissionReport]
AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    e.HireDate,
    [Reporting].[fn_EmployeeSalesCommission](e.EmployeeID, '2024-01-01', '2024-12-31') AS AnnualCommission2024,
    [Reporting].[fn_EmployeeSalesCommission](e.EmployeeID, '2025-01-01', '2025-12-31') AS AnnualCommission2025
FROM [Operation].[Employees] e
WHERE e.EmployeeID IN (
    SELECT DISTINCT EmployeeID FROM [Sales].[Orders]
);
GO
```

**Dependency Graph:**
```
Reporting.EmployeeCommissionReport (VIEW)
  ↓ depends on
  ├── Operation.Employees (TABLE)
  ├── Sales.Orders (TABLE) - used in WHERE subquery
  └── Reporting.fn_EmployeeSalesCommission (FUNCTION)
        ↓ which depends on
        ├── Sales.Orders (TABLE)
        └── Sales.[Order Details] (TABLE)
```

### Step 7: Create Circular Dependency Scenario (Advanced)

```sql
-- Table 1: Sales.Campaigns (references HR.Employees as campaign manager)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Campaigns' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[Campaigns] (
        [CampaignID] INT IDENTITY(1,1) NOT NULL,
        [CampaignName] NVARCHAR(100) NOT NULL,
        [ManagerEmployeeID] INT NULL,  -- References Operation.Employees
        [StartDate] DATE NOT NULL,
        [EndDate] DATE NULL,
        [Budget] DECIMAL(18, 2) NULL,
        CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignID])
    );
END
GO

-- Table 2: Operation.EmployeeCampaigns (join table creating circular dependency)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EmployeeCampaigns' AND schema_id = SCHEMA_ID('Operation'))
BEGIN
    CREATE TABLE [Operation].[EmployeeCampaigns] (
        [EmployeeCampaignID] INT IDENTITY(1,1) NOT NULL,
        [EmployeeID] INT NOT NULL,      -- References Operation.Employees
        [CampaignID] INT NOT NULL,      -- References Sales.Campaigns
        [Role] NVARCHAR(50) NULL,
        CONSTRAINT [PK_EmployeeCampaigns] PRIMARY KEY CLUSTERED ([EmployeeCampaignID])
    );
END
GO

-- Add FK from Sales.Campaigns to Operation.Employees
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Campaigns_Employees')
BEGIN
    ALTER TABLE [Sales].[Campaigns]
    ADD CONSTRAINT [FK_Campaigns_Employees]
    FOREIGN KEY ([ManagerEmployeeID]) REFERENCES [Operation].[Employees]([EmployeeID]);
END
GO

-- Add FK from Operation.EmployeeCampaigns to Operation.Employees
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EmployeeCampaigns_Employees')
BEGIN
    ALTER TABLE [Operation].[EmployeeCampaigns]
    ADD CONSTRAINT [FK_EmployeeCampaigns_Employees]
    FOREIGN KEY ([EmployeeID]) REFERENCES [Operation].[Employees]([EmployeeID]);
END
GO

-- Add FK from Operation.EmployeeCampaigns to Sales.Campaigns (crosses schemas!)
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EmployeeCampaigns_Campaigns')
BEGIN
    ALTER TABLE [Operation].[EmployeeCampaigns]
    ADD CONSTRAINT [FK_EmployeeCampaigns_Campaigns]
    FOREIGN KEY ([CampaignID]) REFERENCES [Sales].[Campaigns]([CampaignID]);
END
GO
```

**Circular Dependency Graph:**
```
Sales.Campaigns → FK → Operation.Employees
     ↑                        ↑
     └── FK ← Operation.EmployeeCampaigns ←┘

Complex cross-schema relationships!
```

### Step 8: Verify All Dependencies

```sql
-- View all cross-schema dependencies
SELECT 
    OBJECT_SCHEMA_NAME(referencing_id) AS ReferencingSchema,
    OBJECT_NAME(referencing_id) AS ReferencingObject,
    o.type_desc AS ReferencingType,
    OBJECT_SCHEMA_NAME(referenced_id) AS ReferencedSchema,
    OBJECT_NAME(referenced_id) AS ReferencedObject,
    ro.type_desc AS ReferencedType
FROM sys.sql_expression_dependencies d
INNER JOIN sys.objects o ON d.referencing_id = o.object_id
INNER JOIN sys.objects ro ON d.referenced_id = ro.object_id
WHERE OBJECT_SCHEMA_NAME(referencing_id) != OBJECT_SCHEMA_NAME(referenced_id)  -- Cross-schema only
    AND OBJECT_SCHEMA_NAME(referencing_id) IN ('Sales', 'Logistics', 'Operation', 'Reporting', 'HR')
ORDER BY ReferencingSchema, ReferencingObject;
```

---

## Part 2: Capture with Flyway

### Step 9: Capture Using Flyway Desktop

```
1. Open Flyway Desktop
2. Select Development environment
3. Navigate to Diff tab
4. Compare: Development → schemaModel

Expected differences:
- New schema: Reporting
- New view: Reporting.CustomerOrdersWithShipping
- New function: Reporting.fn_EmployeeSalesCommission
- New procedure: Reporting.usp_GenerateMonthlySalesReport
- New view: Reporting.EmployeeCommissionReport
- New tables: Sales.Campaigns, Operation.EmployeeCampaigns
- New FKs: Cross-schema foreign keys
```

### Step 10: Or Capture Using Flyway CLI

```powershell
# Create diff artifact
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="$env:TEMP\Artifacts\CrossDependency-Diff.zip" `
  -schemaModelLocation=".\schema-model"

# Capture to schema model
flyway model `
  -model.artifactFilename="$env:TEMP\Artifacts\CrossDependency-Diff.zip" `
  -workingDirectory="."
```

### Step 11: Review Schema Model Structure

```powershell
# Check what Flyway created/modified
git status

# View Reporting schema objects
Get-ChildItem .\schema-model -Recurse -Filter "*Reporting*"
```

**Expected files:**

**schema-model/Security/Schemas/Reporting.sql:**
```sql
CREATE SCHEMA [Reporting] AUTHORIZATION [dbo];
```

**schema-model/Views/Reporting.CustomerOrdersWithShipping.sql:**
```sql
CREATE VIEW [Reporting].[CustomerOrdersWithShipping]
AS
SELECT 
    c.CustomerID,
    c.CompanyName,
    c.City AS CustomerCity,
    c.Country AS CustomerCountry,
    o.OrderID,
    o.OrderDate,
    o.ShippedDate,
    o.Freight,
    s.CompanyName AS ShipperName,
    DATEDIFF(DAY, o.OrderDate, o.ShippedDate) AS DaysToShip
FROM [Sales].[Customers] c
INNER JOIN [Sales].[Orders] o ON c.CustomerID = o.CustomerID
LEFT JOIN [Logistics].[Shippers] s ON o.ShipVia = s.ShipperID;
```

**schema-model/Functions/Reporting.fn_EmployeeSalesCommission.sql:**
```sql
CREATE FUNCTION [Reporting].[fn_EmployeeSalesCommission]
(
    @EmployeeID INT,
    @StartDate DATE,
    @EndDate DATE
)
RETURNS DECIMAL(18, 2)
AS
BEGIN
    -- ... full function definition ...
    RETURN @Commission;
END
```

**schema-model/Stored Procedures/Reporting.usp_GenerateMonthlySalesReport.sql:**
```sql
CREATE PROCEDURE [Reporting].[usp_GenerateMonthlySalesReport]
    @Year INT,
    @Month INT
AS
BEGIN
    -- ... full procedure definition ...
END
```

**schema-model/Views/Reporting.EmployeeCommissionReport.sql:**
```sql
CREATE VIEW [Reporting].[EmployeeCommissionReport]
AS
SELECT 
    e.EmployeeID,
    e.FirstName + ' ' + e.LastName AS EmployeeName,
    -- ... references Reporting.fn_EmployeeSalesCommission ...
FROM [Operation].[Employees] e
WHERE e.EmployeeID IN (
    SELECT DISTINCT EmployeeID FROM [Sales].[Orders]
);
```

---

## Part 3: Understand Flyway's Dependency Resolution

### Critical Observation: Deployment Order

Flyway must deploy objects in the correct order to satisfy cross-schema dependencies:

```
Correct deployment order:
1. CREATE SCHEMA Reporting
2. CREATE TABLE Sales.Campaigns (references Operation.Employees)
3. CREATE TABLE Operation.EmployeeCampaigns (references both)
4. CREATE FUNCTION Reporting.fn_EmployeeSalesCommission (references Sales tables)
5. CREATE VIEW Reporting.CustomerOrdersWithShipping (references Sales + Logistics)
6. CREATE VIEW Reporting.EmployeeCommissionReport (references function + tables)
7. CREATE PROCEDURE Reporting.usp_GenerateMonthlySalesReport (references multiple schemas)
8. CREATE FKs (after all tables exist)

Wrong order would cause:
❌ Cannot create view referencing non-existent table
❌ Cannot create function referencing non-existent table
❌ Cannot create FK to non-existent table across schemas
```

**How Flyway Handles This:**

1. **Dependency Analysis:**
   - Parses SQL to identify object references
   - Builds directed acyclic graph (DAG)
   - Detects cross-schema dependencies

2. **Topological Sort:**
   - Orders objects by dependency depth
   - Referenced objects deployed before referencing objects
   - Handles multi-level dependencies

3. **Schema-Aware Deployment:**
   - Schemas created first
   - Tables before views/procedures/functions
   - Functions before views that use them
   - FKs added after all tables exist

4. **Circular Dependency Handling:**
   - Tables created without FKs first
   - FKs added in separate pass
   - Avoids "chicken and egg" problems

---

## Part 4: Deploy to Test Environment

### Step 12: Generate Deployment Script

```powershell
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$DEPLOY_SCRIPT = ".\Artifacts\Deploy-CrossDependency-Test-$TIMESTAMP.sql"
$UNDO_SCRIPT = ".\Artifacts\Undo-CrossDependency-Test-$TIMESTAMP.sql"

flyway prepare schemaModel Test `
  "-prepare.scriptFilename=$DEPLOY_SCRIPT" `
  "-prepare.undoScriptFilename=$UNDO_SCRIPT" `
  -workingDirectory="."
```

### Step 13: Review Deployment Script - Notice the Order!

```powershell
code $DEPLOY_SCRIPT
```

**Expected deployment order (Flyway determines automatically):**

```sql
BEGIN TRANSACTION;

-- ============================================================================
-- STEP 1: Create schemas (alphabetical or by reference)
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Reporting')
BEGIN
    EXEC('CREATE SCHEMA [Reporting] AUTHORIZATION [dbo]');
    PRINT 'Created schema Reporting';
END

-- ============================================================================
-- STEP 2: Create/alter tables (dependency order)
-- ============================================================================

-- Sales.Campaigns (references Operation.Employees)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Campaigns' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[Campaigns] (
        [CampaignID] INT IDENTITY(1,1) NOT NULL,
        [CampaignName] NVARCHAR(100) NOT NULL,
        [ManagerEmployeeID] INT NULL,
        [StartDate] DATE NOT NULL,
        [EndDate] DATE NULL,
        [Budget] DECIMAL(18, 2) NULL,
        CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignID])
    );
    PRINT 'Created table Sales.Campaigns';
END

-- Operation.EmployeeCampaigns (references Operation.Employees + Sales.Campaigns)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'EmployeeCampaigns' AND schema_id = SCHEMA_ID('Operation'))
BEGIN
    CREATE TABLE [Operation].[EmployeeCampaigns] (
        [EmployeeCampaignID] INT IDENTITY(1,1) NOT NULL,
        [EmployeeID] INT NOT NULL,
        [CampaignID] INT NOT NULL,
        [Role] NVARCHAR(50) NULL,
        CONSTRAINT [PK_EmployeeCampaigns] PRIMARY KEY CLUSTERED ([EmployeeCampaignID])
    );
    PRINT 'Created table Operation.EmployeeCampaigns';
END

-- ============================================================================
-- STEP 3: Create functions (before views that use them)
-- ============================================================================
GO

IF NOT EXISTS (SELECT 1 FROM sys.objects WHERE name = 'fn_EmployeeSalesCommission' AND schema_id = SCHEMA_ID('Reporting'))
BEGIN
    EXEC('
    CREATE FUNCTION [Reporting].[fn_EmployeeSalesCommission]
    (
        @EmployeeID INT,
        @StartDate DATE,
        @EndDate DATE
    )
    RETURNS DECIMAL(18, 2)
    AS
    BEGIN
        -- Function logic...
        RETURN @Commission;
    END
    ');
    PRINT 'Created function Reporting.fn_EmployeeSalesCommission';
END
GO

-- ============================================================================
-- STEP 4: Create views (dependency order)
-- ============================================================================

-- View without function dependency (can be created first)
IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'CustomerOrdersWithShipping' AND schema_id = SCHEMA_ID('Reporting'))
BEGIN
    EXEC('
    CREATE VIEW [Reporting].[CustomerOrdersWithShipping]
    AS
    SELECT ... FROM [Sales].[Customers] c
    INNER JOIN [Sales].[Orders] o ON ...
    LEFT JOIN [Logistics].[Shippers] s ON ...
    ');
    PRINT 'Created view Reporting.CustomerOrdersWithShipping';
END
GO

-- View with function dependency (created after function)
IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'EmployeeCommissionReport' AND schema_id = SCHEMA_ID('Reporting'))
BEGIN
    EXEC('
    CREATE VIEW [Reporting].[EmployeeCommissionReport]
    AS
    SELECT ..., [Reporting].[fn_EmployeeSalesCommission](...) AS ...
    FROM [Operation].[Employees] e
    ');
    PRINT 'Created view Reporting.EmployeeCommissionReport';
END
GO

-- ============================================================================
-- STEP 5: Create stored procedures
-- ============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'usp_GenerateMonthlySalesReport' AND schema_id = SCHEMA_ID('Reporting'))
BEGIN
    EXEC('
    CREATE PROCEDURE [Reporting].[usp_GenerateMonthlySalesReport]
        @Year INT,
        @Month INT
    AS
    BEGIN
        -- Procedure logic...
    END
    ');
    PRINT 'Created procedure Reporting.usp_GenerateMonthlySalesReport';
END
GO

-- ============================================================================
-- STEP 6: Add foreign keys (after all tables exist)
-- ============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Campaigns_Employees')
BEGIN
    ALTER TABLE [Sales].[Campaigns]
    ADD CONSTRAINT [FK_Campaigns_Employees]
    FOREIGN KEY ([ManagerEmployeeID]) REFERENCES [Operation].[Employees]([EmployeeID]);
    PRINT 'Created FK: FK_Campaigns_Employees (cross-schema: Sales → Operation)';
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EmployeeCampaigns_Employees')
BEGIN
    ALTER TABLE [Operation].[EmployeeCampaigns]
    ADD CONSTRAINT [FK_EmployeeCampaigns_Employees]
    FOREIGN KEY ([EmployeeID]) REFERENCES [Operation].[Employees]([EmployeeID]);
    PRINT 'Created FK: FK_EmployeeCampaigns_Employees';
END

IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_EmployeeCampaigns_Campaigns')
BEGIN
    ALTER TABLE [Operation].[EmployeeCampaigns]
    ADD CONSTRAINT [FK_EmployeeCampaigns_Campaigns]
    FOREIGN KEY ([CampaignID]) REFERENCES [Sales].[Campaigns]([CampaignID]);
    PRINT 'Created FK: FK_EmployeeCampaigns_Campaigns (cross-schema: Operation → Sales)';
END

COMMIT TRANSACTION;
PRINT 'Cross-schema dependency deployment completed successfully.';
```

### Step 14: Validate and Deploy

```powershell
# Pre-deployment snapshot
flyway snapshot Test -snapshot.filename="Pre-CrossDependency"

# Validate
flyway check -changes -code -drift Test

# Deploy
flyway deploy Test "-deploy.scriptFilename=$DEPLOY_SCRIPT"

# Post-deployment snapshot
flyway snapshot Test -snapshot.filename="Post-CrossDependency"
```

**Expected output:**
```
Created schema Reporting
Created table Sales.Campaigns
Created table Operation.EmployeeCampaigns
Created function Reporting.fn_EmployeeSalesCommission
Created view Reporting.CustomerOrdersWithShipping
Created view Reporting.EmployeeCommissionReport
Created procedure Reporting.usp_GenerateMonthlySalesReport
Created FK: FK_Campaigns_Employees (cross-schema: Sales → Operation)
Created FK: FK_EmployeeCampaigns_Employees
Created FK: FK_EmployeeCampaigns_Campaigns (cross-schema: Operation → Sales)

Deployment completed successfully.
```

---

## Part 5: Verify Cross-Schema Objects

### Step 15: Test Cross-Schema Views

```sql
-- Connect to Test database

-- Test view joining Sales + Logistics
SELECT TOP 10 * 
FROM [Reporting].[CustomerOrdersWithShipping]
ORDER BY OrderDate DESC;

-- Test view using function
SELECT TOP 10 *
FROM [Reporting].[EmployeeCommissionReport]
ORDER BY AnnualCommission2024 DESC;
```

### Step 16: Test Cross-Schema Stored Procedure

```sql
-- Execute report for January 2024
EXEC [Reporting].[usp_GenerateMonthlySalesReport] 
    @Year = 2024, 
    @Month = 1;
```

### Step 17: Test Cross-Schema Function

```sql
-- Calculate commission for employee ID 5 for 2024
SELECT [Reporting].[fn_EmployeeSalesCommission](5, '2024-01-01', '2024-12-31') AS Commission2024;
```

### Step 18: Verify Cross-Schema Foreign Keys

```sql
-- Verify FKs exist
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_SCHEMA_NAME(fk.parent_object_id) AS ChildSchema,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    OBJECT_SCHEMA_NAME(fk.referenced_object_id) AS ParentSchema,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable
FROM sys.foreign_keys fk
WHERE fk.name IN ('FK_Campaigns_Employees', 'FK_EmployeeCampaigns_Employees', 'FK_EmployeeCampaigns_Campaigns')
ORDER BY ForeignKeyName;

-- Test cross-schema FK enforcement
INSERT INTO [Sales].[Campaigns] (CampaignName, ManagerEmployeeID, StartDate)
VALUES ('Spring Sale 2024', 1, '2024-03-01');  -- Should succeed if EmployeeID 1 exists

INSERT INTO [Sales].[Campaigns] (CampaignName, ManagerEmployeeID, StartDate)
VALUES ('Invalid Campaign', 99999, '2024-03-01');  -- Should FAIL (FK violation)
```

---

## ✅ Success Criteria

- ✅ Created cross-schema views, functions, and procedures
- ✅ Created cross-schema foreign key relationships
- ✅ Flyway correctly analyzed dependency graph
- ✅ Deployment script ordered objects properly
- ✅ All objects deployed successfully to Test
- ✅ Cross-schema references work correctly
- ✅ Foreign keys enforce referential integrity across schemas

---

## 🎓 Key Learnings

### How Flyway Handles Cross-Schema Dependencies

1. **Dependency Detection:**
   - Parses CREATE statements for object references
   - Identifies schema-qualified references (`[Schema].[Object]`)
   - Builds complete dependency graph including cross-schema links

2. **Deployment Ordering:**
   ```
   Order:
   1. Schemas
   2. Tables (topologically sorted by FK dependencies)
   3. Functions (before views/procedures that use them)
   4. Views (dependency order: base views before dependent views)
   5. Stored Procedures
   6. Foreign Keys (added after all tables exist)
   ```

3. **Circular Dependency Resolution:**
   - Tables created without FKs
   - FKs added in separate deployment phase
   - Prevents deployment deadlocks

4. **Multi-Level Dependencies:**
   - Handles View → Function → Table chains
   - Procedure → View → Table chains
   - Table → FK → Table (cross-schema) chains

---

## 💡 Best Practices

### Schema Organization ✅
```
Good:
- Organize by business domain (Sales, HR, Logistics)
- Use Reporting schema for cross-domain reports
- Minimize cross-schema dependencies when possible

Avoid:
- Excessive cross-schema dependencies (tight coupling)
- Circular dependencies between schemas
```

### Naming Cross-Schema Objects ✅
```sql
-- Clear schema prefix in name
[Reporting].[CustomerOrdersWithShipping]  -- Clearly a reporting object
[Reporting].[fn_EmployeeSalesCommission]  -- Reporting function
[Reporting].[usp_GenerateMonthlySalesReport]  -- Reporting procedure
```

### Documenting Dependencies ✅
```sql
-- Document cross-schema dependencies in comments
CREATE VIEW [Reporting].[CustomerOrdersWithShipping]
AS
-- Dependencies:
--   Sales.Customers
--   Sales.Orders
--   Logistics.Shippers
SELECT ...
```

### Security Considerations ✅
```sql
-- Grant cross-schema permissions carefully
GRANT SELECT ON SCHEMA::[Sales] TO [ReportingRole];
GRANT SELECT ON SCHEMA::[Logistics] TO [ReportingRole];
GRANT SELECT ON SCHEMA::[Reporting] TO [ReportingRole];

-- Reporting objects can now access Sales and Logistics data
```

---

## 🚀 Advanced Scenarios

### Refactoring Cross-Schema Dependencies

```sql
-- If you need to move an object to different schema:
-- 1. Create object in new schema
-- 2. Update all references to new schema
-- 3. Drop object from old schema
-- 4. Capture all with Flyway

-- Flyway will handle the dependency changes automatically
```

### Breaking Circular Dependencies

```sql
-- Instead of direct FK creating circular dependency:
Sales.Table1 → FK → HR.Table2
     ↑                    ↑
     └───── FK ←──── HR.Table3

-- Use junction table in neutral schema:
Sales.Table1 ←── FK ── Common.Junction ──FK──→ HR.Table2
```

### Performance Optimization

```sql
-- Cross-schema joins can be slow
-- Consider:
-- 1. Indexed views (materialize cross-schema joins)
-- 2. Denormalization (copy data to avoid cross-schema joins)
-- 3. Schemas on different filegroups (if helpful)
```

---

## 📚 Related Quests

- **Scenario: New Schema** - Creating schemas
- **Scenario: Foreign Key** - FK dependency management
- **Developer Quest 06:** Modify Existing Object - Changing objects with dependencies

---

**Congratulations!** 🎉 You've mastered how Flyway handles complex cross-schema dependencies!
