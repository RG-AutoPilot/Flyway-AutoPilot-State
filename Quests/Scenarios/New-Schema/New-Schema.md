# Scenario: Creating and Managing New Schemas

**Difficulty:** 🟢 Beginner  
**Time:** 25-30 minutes  
**Type:** Scenario Demonstration

## 🎯 Learning Objectives
By completing this scenario, you will learn:
- How to create new database schemas in SQL Server
- How Flyway captures schema definitions
- How Flyway deploys schemas across environments
- Schema organization best practices
- Managing schema-level security

## 📖 Scenario Overview
Your organization is launching a new HR module. You need to create a new `HR` schema to organize HR-related tables separately from existing `Sales`, `Logistics`, and `Operation` schemas. This scenario demonstrates Flyway's handling of schema creation from development through deployment.

---

## Part 1: Create the Scenario

### Step 1: Connect to Development Database

```powershell
# Open SQL Server Management Studio (SSMS) or Azure Data Studio
# Connect to your Development environment
# Database: AutopilotDev (or your development database name)
```

### Step 2: Create the New Schema

```sql
-- Create HR schema for human resources objects
CREATE SCHEMA [HR] AUTHORIZATION [dbo];
GO

-- Verify schema created
SELECT name, schema_id, principal_id
FROM sys.schemas
WHERE name = 'HR';
```

**Expected Result:**
```
name    schema_id    principal_id
HR      5            1
```

### Step 3: Add Objects to the New Schema

Create some typical HR objects to demonstrate full schema usage:

```sql
-- Create HR.Employees table
CREATE TABLE [HR].[Employees] (
    [EmployeeID] INT IDENTITY(1,1) NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [Email] NVARCHAR(100) NOT NULL,
    [HireDate] DATE NOT NULL,
    [DepartmentID] INT NULL,
    [Salary] DECIMAL(18, 2) NULL,
    CONSTRAINT [PK_HR_Employees] PRIMARY KEY CLUSTERED ([EmployeeID])
);
GO

-- Create HR.Departments table
CREATE TABLE [HR].[Departments] (
    [DepartmentID] INT IDENTITY(1,1) NOT NULL,
    [DepartmentName] NVARCHAR(100) NOT NULL,
    [ManagerEmployeeID] INT NULL,
    [Budget] DECIMAL(18, 2) NULL,
    CONSTRAINT [PK_HR_Departments] PRIMARY KEY CLUSTERED ([DepartmentID])
);
GO

-- Add foreign key relationship
ALTER TABLE [HR].[Employees]
ADD CONSTRAINT [FK_Employees_Departments]
FOREIGN KEY ([DepartmentID]) REFERENCES [HR].[Departments]([DepartmentID]);
GO

-- Create HR view
CREATE VIEW [HR].[EmployeeDepartmentView]
AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.Email,
    e.HireDate,
    d.DepartmentName,
    d.Budget AS DepartmentBudget
FROM [HR].[Employees] e
LEFT JOIN [HR].[Departments] d ON e.DepartmentID = d.DepartmentID;
GO

-- Create HR stored procedure
CREATE PROCEDURE [HR].[GetEmployeesByDepartment]
    @DepartmentID INT
AS
BEGIN
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Email,
        HireDate
    FROM [HR].[Employees]
    WHERE DepartmentID = @DepartmentID
    ORDER BY LastName, FirstName;
END
GO
```

### Step 4: Verify Schema and Objects

```sql
-- Check all objects in HR schema
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ObjectName,
    type_desc AS ObjectType
FROM sys.objects
WHERE schema_id = SCHEMA_ID('HR')
ORDER BY type_desc, name;
```

**Expected Result:**
```
SchemaName  ObjectName                    ObjectType
HR          GetEmployeesByDepartment      SQL_STORED_PROCEDURE
HR          Departments                   USER_TABLE
HR          Employees                     USER_TABLE
HR          EmployeeDepartmentView        VIEW
```

---

## Part 2: Capture with Flyway Desktop

### Step 5: Open Flyway Desktop

```
1. Launch Flyway Desktop
2. Open project: Flyway-AutoPilot-State
3. Ensure Development environment is selected
```

### Step 6: Validate Environment Sync (Critical!)

```
1. Click "Diff" tab
2. Compare: Development → schemaModel
3. Review detected differences

Expected to see:
- New schema: HR
- New tables: HR.Employees, HR.Departments
- New view: HR.EmployeeDepartmentView
- New stored procedure: HR.GetEmployeesByDepartment
```

### Step 7: Capture Schema to Schema Model

**Option A: Flyway Desktop GUI**
```
1. In Diff tab, select all HR objects
2. Click "Apply to Schema Model"
3. Review changes in schema-model folder
4. Verify files created:
   - schema-model/Security/Schemas/HR.sql
   - schema-model/Tables/HR.Employees.sql
   - schema-model/Tables/HR.Departments.sql
   - schema-model/Views/HR.EmployeeDepartmentView.sql
   - schema-model/Stored Procedures/HR.GetEmployeesByDepartment.sql
```

**Option B: Flyway CLI (Operations Quest 00-01)**
```powershell
# Quest 00: Create diff artifact
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="$env:TEMP\Artifacts\HR-Schema-Diff.zip" `
  -schemaModelLocation=".\schema-model"

# Quest 01: Capture to schema model
flyway model `
  -model.artifactFilename="$env:TEMP\Artifacts\HR-Schema-Diff.zip" `
  -workingDirectory="."
```

### Step 8: Review Schema Model Files

```powershell
# Navigate to project folder
cd C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State

# Check what Flyway created
Get-ChildItem .\schema-model -Recurse -Filter "*HR*"
```

**Expected files:**

**schema-model/Security/Schemas/HR.sql:**
```sql
CREATE SCHEMA [HR] AUTHORIZATION [dbo];
```

**schema-model/Tables/HR.Employees.sql:**
```sql
CREATE TABLE [HR].[Employees] (
    [EmployeeID] INT IDENTITY(1,1) NOT NULL,
    [FirstName] NVARCHAR(50) NOT NULL,
    [LastName] NVARCHAR(50) NOT NULL,
    [Email] NVARCHAR(100) NOT NULL,
    [HireDate] DATE NOT NULL,
    [DepartmentID] INT NULL,
    [Salary] DECIMAL(18, 2) NULL,
    CONSTRAINT [PK_HR_Employees] PRIMARY KEY CLUSTERED ([EmployeeID])
);

ALTER TABLE [HR].[Employees]
ADD CONSTRAINT [FK_Employees_Departments]
FOREIGN KEY ([DepartmentID]) REFERENCES [HR].[Departments]([DepartmentID]);
```

**schema-model/Tables/HR.Departments.sql:**
```sql
CREATE TABLE [HR].[Departments] (
    [DepartmentID] INT IDENTITY(1,1) NOT NULL,
    [DepartmentName] NVARCHAR(100) NOT NULL,
    [ManagerEmployeeID] INT NULL,
    [Budget] DECIMAL(18, 2) NULL,
    CONSTRAINT [PK_HR_Departments] PRIMARY KEY CLUSTERED ([DepartmentID])
);
```

**schema-model/Views/HR.EmployeeDepartmentView.sql:**
```sql
CREATE VIEW [HR].[EmployeeDepartmentView]
AS
SELECT 
    e.EmployeeID,
    e.FirstName,
    e.LastName,
    e.Email,
    e.HireDate,
    d.DepartmentName,
    d.Budget AS DepartmentBudget
FROM [HR].[Employees] e
LEFT JOIN [HR].[Departments] d ON e.DepartmentID = d.DepartmentID;
```

**schema-model/Stored Procedures/HR.GetEmployeesByDepartment.sql:**
```sql
CREATE PROCEDURE [HR].[GetEmployeesByDepartment]
    @DepartmentID INT
AS
BEGIN
    SELECT 
        EmployeeID,
        FirstName,
        LastName,
        Email,
        HireDate
    FROM [HR].[Employees]
    WHERE DepartmentID = @DepartmentID
    ORDER BY LastName, FirstName;
END
```

---

## Part 3: Version Control (Git)

### Step 9: Commit Schema Model Changes

```powershell
# Check Git status
git status

# Should show:
# new file:   schema-model/Security/Schemas/HR.sql
# new file:   schema-model/Tables/HR.Employees.sql
# new file:   schema-model/Tables/HR.Departments.sql
# new file:   schema-model/Views/HR.EmployeeDepartmentView.sql
# new file:   schema-model/Stored Procedures/HR.GetEmployeesByDepartment.sql

# Stage changes
git add schema-model/

# Commit with descriptive message
git commit -m "feat(schema): Add HR schema with Employees, Departments, view, and stored procedure

- Created HR schema for human resources module
- Added HR.Employees table with employee details
- Added HR.Departments table with department info
- Added FK relationship between Employees and Departments
- Created EmployeeDepartmentView for joined employee/department data
- Added GetEmployeesByDepartment stored procedure"

# Push to remote
git push origin QUESTS
```

---

## Part 4: Deploy to Test Environment

### Step 10: Prepare Deployment Script (Operations Quest 02)

```powershell
# Generate deployment script
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$DEPLOY_SCRIPT = ".\Artifacts\Deploy-HR-Schema-Test-$TIMESTAMP.sql"
$UNDO_SCRIPT = ".\Artifacts\Undo-HR-Schema-Test-$TIMESTAMP.sql"

flyway prepare schemaModel Test `
  "-prepare.scriptFilename=$DEPLOY_SCRIPT" `
  "-prepare.undoScriptFilename=$UNDO_SCRIPT" `
  -workingDirectory="."
```

### Step 11: Review Generated Deployment Script

```powershell
# Open and review
code $DEPLOY_SCRIPT
```

**Expected deployment script content:**
```sql
-- Flyway State-Based Deployment Script
-- Source: schemaModel
-- Target: Test
-- Generated: 2026-01-08 15:30:00

BEGIN TRANSACTION;

-- ============================================================================
-- CREATE SCHEMA
-- ============================================================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'HR')
BEGIN
    EXEC('CREATE SCHEMA [HR] AUTHORIZATION [dbo]');
    PRINT 'Created schema HR';
END

-- ============================================================================
-- CREATE TABLES
-- ============================================================================

-- Create HR.Departments (must be first due to FK dependency)
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Departments' AND schema_id = SCHEMA_ID('HR'))
BEGIN
    CREATE TABLE [HR].[Departments] (
        [DepartmentID] INT IDENTITY(1,1) NOT NULL,
        [DepartmentName] NVARCHAR(100) NOT NULL,
        [ManagerEmployeeID] INT NULL,
        [Budget] DECIMAL(18, 2) NULL,
        CONSTRAINT [PK_HR_Departments] PRIMARY KEY CLUSTERED ([DepartmentID])
    );
    PRINT 'Created table HR.Departments';
END

-- Create HR.Employees
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Employees' AND schema_id = SCHEMA_ID('HR'))
BEGIN
    CREATE TABLE [HR].[Employees] (
        [EmployeeID] INT IDENTITY(1,1) NOT NULL,
        [FirstName] NVARCHAR(50) NOT NULL,
        [LastName] NVARCHAR(50) NOT NULL,
        [Email] NVARCHAR(100) NOT NULL,
        [HireDate] DATE NOT NULL,
        [DepartmentID] INT NULL,
        [Salary] DECIMAL(18, 2) NULL,
        CONSTRAINT [PK_HR_Employees] PRIMARY KEY CLUSTERED ([EmployeeID])
    );
    PRINT 'Created table HR.Employees';
END

-- Add foreign key
IF NOT EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_Employees_Departments')
BEGIN
    ALTER TABLE [HR].[Employees]
    ADD CONSTRAINT [FK_Employees_Departments]
    FOREIGN KEY ([DepartmentID]) REFERENCES [HR].[Departments]([DepartmentID]);
    PRINT 'Created foreign key FK_Employees_Departments';
END

-- ============================================================================
-- CREATE VIEWS
-- ============================================================================
GO

IF NOT EXISTS (SELECT 1 FROM sys.views WHERE name = 'EmployeeDepartmentView' AND schema_id = SCHEMA_ID('HR'))
BEGIN
    EXEC('
    CREATE VIEW [HR].[EmployeeDepartmentView]
    AS
    SELECT 
        e.EmployeeID,
        e.FirstName,
        e.LastName,
        e.Email,
        e.HireDate,
        d.DepartmentName,
        d.Budget AS DepartmentBudget
    FROM [HR].[Employees] e
    LEFT JOIN [HR].[Departments] d ON e.DepartmentID = d.DepartmentID;
    ');
    PRINT 'Created view HR.EmployeeDepartmentView';
END
GO

-- ============================================================================
-- CREATE STORED PROCEDURES
-- ============================================================================

IF NOT EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'GetEmployeesByDepartment' AND schema_id = SCHEMA_ID('HR'))
BEGIN
    EXEC('
    CREATE PROCEDURE [HR].[GetEmployeesByDepartment]
        @DepartmentID INT
    AS
    BEGIN
        SELECT 
            EmployeeID,
            FirstName,
            LastName,
            Email,
            HireDate
        FROM [HR].[Employees]
        WHERE DepartmentID = @DepartmentID
        ORDER BY LastName, FirstName;
    END
    ');
    PRINT 'Created stored procedure HR.GetEmployeesByDepartment';
END
GO

COMMIT TRANSACTION;
PRINT 'HR schema deployment completed successfully.';
```

### Step 12: Validate Deployment (Operations Quest 03)

```powershell
# Create pre-deployment snapshot
flyway snapshot Test `
  -snapshot.filename="Pre-Deploy-HR-Schema" `
  -workingDirectory="."

# Run checks
flyway check -changes -code -drift Test `
  -workingDirectory="."
```

**Review check report output:**
- ✅ Changes: New schema + 5 objects (expected)
- ✅ Code Analysis: Should show no issues
- ✅ Drift: Should show clean (no unexpected changes)
- ✅ Risk Level: Low (all additive changes)

### Step 13: Execute Deployment (Operations Quest 04)

```powershell
# Deploy to Test
flyway deploy Test `
  "-deploy.scriptFilename=$DEPLOY_SCRIPT" `
  -workingDirectory="."

# Capture post-deployment snapshot
flyway snapshot Test `
  -snapshot.filename="Post-Deploy-HR-Schema" `
  -workingDirectory="."
```

**Expected output:**
```
Flyway Enterprise Edition 10.x.x

Connecting to Test environment...
Connected to: AutopilotTest

Deploying script: .\Artifacts\Deploy-HR-Schema-Test-20260108-153000.sql

BEGIN TRANSACTION
Created schema HR
Created table HR.Departments
Created table HR.Employees
Created foreign key FK_Employees_Departments
Created view HR.EmployeeDepartmentView
Created stored procedure HR.GetEmployeesByDepartment
COMMIT TRANSACTION

Deployment completed successfully.

Summary:
  Schemas created: 1 (HR)
  Objects created: 5
  Objects modified: 0
  Objects deleted: 0
```

---

## Part 5: Verify Deployment

### Step 14: Verify Schema in Test Database

```sql
-- Connect to Test database in SSMS

-- Verify HR schema exists
SELECT name, schema_id
FROM sys.schemas
WHERE name = 'HR';

-- Verify all HR objects created
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ObjectName,
    type_desc AS ObjectType,
    create_date
FROM sys.objects
WHERE schema_id = SCHEMA_ID('HR')
ORDER BY type_desc, name;

-- Test the stored procedure
EXEC [HR].[GetEmployeesByDepartment] @DepartmentID = 1;

-- Test the view
SELECT TOP 10 * FROM [HR].[EmployeeDepartmentView];
```

### Step 15: Verify Sync with Flyway

```powershell
# Diff Test vs schemaModel (should show no differences)
flyway diff `
  -diff.source=Test `
  -diff.target=schemaModel `
  -diff.artifactFilename="$env:TEMP\Artifacts\Verify-HR-Schema.zip" `
  -schemaModelLocation=".\schema-model"
```

**Expected output:**
```
Comparing Test to schemaModel...

No differences detected.
Environments are in sync.
```

✅ **Success!** HR schema deployed and synchronized.

---

## ✅ Success Criteria

- ✅ Created HR schema in Development database
- ✅ Created HR objects (tables, views, stored procedures)
- ✅ Captured schema definition to schema-model folder
- ✅ Committed changes to Git
- ✅ Generated deployment script
- ✅ Validated deployment with checks
- ✅ Deployed successfully to Test environment
- ✅ Verified schema and all objects exist in Test
- ✅ Confirmed Test is in sync with schema model

---

## 🎓 Key Learnings

### How Flyway Handles Schemas

1. **Schema as First-Class Object**
   - Flyway treats schemas as distinct database objects
   - Schema definitions stored in `schema-model/Security/Schemas/`
   - Schemas deployed before their contained objects

2. **Dependency Management**
   - Flyway automatically determines deployment order
   - Schemas created first, then tables, then FKs, then views/procedures
   - Handles cross-schema dependencies intelligently

3. **Folder Organization**
   - Each object type in its own folder
   - Schema prefix in filename: `HR.Employees.sql`
   - Easy to find and manage schema-specific objects

4. **Deployment Intelligence**
   - Idempotent scripts with `IF NOT EXISTS` checks
   - Transaction wrapping for safety
   - Proper `GO` batch separators for views/procedures

---

## 💡 Best Practices for New Schemas

### Schema Naming ✅
```
Good:
- HR (Human Resources)
- Finance
- Inventory
- Reporting

Avoid:
- Schema1, Schema2 (not descriptive)
- UserData (too generic)
- temp, test (confusion with temporary objects)
```

### Schema Organization ✅
```
Organize by business domain:
- Sales schema → all sales-related objects
- HR schema → all HR-related objects
- Logistics schema → all logistics-related objects

NOT by object type:
- Tables schema (don't do this)
- Views schema (don't do this)
```

### Security Consideration ✅
```sql
-- Grant schema-level permissions
GRANT SELECT ON SCHEMA::[HR] TO [HRReadOnly];
GRANT INSERT, UPDATE, DELETE ON SCHEMA::[HR] TO [HREditor];

-- Easier than managing permissions per table
```

### flyway.toml Configuration ✅
```toml
# Ensure new schema is included in deployments
[environments.development]
schemas = ["Sales", "Logistics", "Operation", "HR"]

[environments.Test]
schemas = ["Sales", "Logistics", "Operation", "HR"]
```

---

## 🚀 Real-World Applications

- **New Module Launch:** Add HR, CRM, Inventory modules with dedicated schemas
- **Multi-Tenant:** Separate customer data by schema (Customer1, Customer2, etc.)
- **Reporting Separation:** Reporting schema for denormalized reporting tables
- **Security Isolation:** Sensitive data in separate schema with restricted access
- **Third-Party Integration:** Integration schema for external system data

---

## 📚 Related Quests

- **Developer Quest 04:** Capture New Changes (using Flyway Desktop)
- **Operations Quest 00-01:** Compare and Capture (using Flyway CLI)
- **Operations Quest 02-04:** Prepare and Deploy workflow

---

**Congratulations!** 🎉 You've learned how Flyway handles schema creation and deployment!
