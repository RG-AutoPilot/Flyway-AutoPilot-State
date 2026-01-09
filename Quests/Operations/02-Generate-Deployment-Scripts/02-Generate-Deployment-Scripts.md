# Operations Quest 02 - Prepare: Generate Deployment Scripts

**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Prerequisites:** Schema model exists and is up-to-date

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to use `flyway prepare` to generate deployment scripts
- Creating both deploy and undo scripts
- Understanding deployment script structure
- Reviewing scripts before execution
- Generating repeatable deployment artifacts

## 📖 Scenario
Your schema model represents the desired state (what the database should look like). Your Test environment database is the current state. You need to generate a deployment script that will safely transform Test to match the schema model, along with an undo script in case rollback is needed.

## 🎯 Your Mission
Use `flyway prepare` to generate deployment and undo scripts that will synchronize Test environment with your schema model.

## 📝 Steps

### Step 1: Understand the Prepare Command

**Purpose:**  
`flyway prepare` compares two entities (typically schema model vs. target environment) and generates:
1. **Deploy script** - SQL to apply changes
2. **Undo script** - SQL to rollback changes

**Workflow:**
```
Schema Model (desired state) → flyway prepare → Deploy Script
                                                → Undo Script
                                              ↓
                               Quest 04: flyway deploy → Test DB
```

The prepare command:
- Compares source (schema model) to target (database)
- Generates idempotent SQL deployment script
- Creates corresponding undo script
- Saves both to disk for review and execution

### Step 2: Review the Helper Script

The `02_Flyway_State_Prepare.ps1` script shows the command structure:

```powershell
flyway prepare schemaModel Test `
  "-prepare.scriptFilename=%temp%/Artifacts/Flyway.State.Test.deploy-$(get-date -f yyyyMMdd).sql" `
  "-prepare.undoScriptFilename=%temp%/Artifacts/Flyway.State.Test.undo-$(get-date -f yyyyMMdd).sql" `
  -workingDirectory="."
```

**Parameters explained:**
- `schemaModel` - Source (desired state from Git)
- `Test` - Target (environment to deploy to)
- `-prepare.scriptFilename` - Where to save the deploy script
- `-prepare.undoScriptFilename` - Where to save the undo script
- `-workingDirectory` - Project root directory

### Step 3: Set Up Variables

```powershell
# Project paths
$WORKING_DIRECTORY = "C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"

# Script output locations
$DEPLOY_SCRIPT = "$env:TEMP\Artifacts\Flyway.State.Test.deploy-$TIMESTAMP.sql"
$UNDO_SCRIPT = "$env:TEMP\Artifacts\Flyway.State.Test.undo-$TIMESTAMP.sql"

# Ensure artifact directory exists
New-Item -ItemType Directory -Path "$env:TEMP\Artifacts" -Force
```

### Step 4: Run the Prepare Command

```powershell
# Navigate to project
cd $WORKING_DIRECTORY

# Generate deployment scripts
flyway prepare schemaModel Test `
  "-prepare.scriptFilename=$DEPLOY_SCRIPT" `
  "-prepare.undoScriptFilename=$UNDO_SCRIPT" `
  -workingDirectory="."
```

**Note:** Replace `Test` with your target environment name from `flyway.toml`:
- `development` - Your local dev database
- `Test` - Test environment
- `staging` - Staging environment
- `production` - Production (use with extreme caution!)

### Step 5: Review Prepare Output

**Successful preparation:**
```
Flyway Enterprise Edition 10.x.x

Comparing schemaModel to Test...

Changes detected:
  Tables: 2 changes
    + Sales.Campaigns (will be created)
    ~ Sales.CustomerFeedback (will be altered)
  
  Stored Procedures: 1 change
    ~ Sales.SalesByCategory (will be modified)

Generating deployment scripts...
  Deploy script: C:\Users\...\Temp\Artifacts\Flyway.State.Test.deploy-20260108-143022.sql
  Undo script:   C:\Users\...\Temp\Artifacts\Flyway.State.Test.undo-20260108-143022.sql

Scripts generated successfully.
```

**No changes needed:**
```
Flyway Enterprise Edition 10.x.x

Comparing schemaModel to Test...

No changes detected.
Test environment is already in sync with schemaModel.

No scripts generated.
```

### Step 6: Review the Deploy Script

**CRITICAL:** Always review deployment scripts before executing!

```powershell
# Open deploy script in VS Code
code $DEPLOY_SCRIPT

# Or use notepad
notepad $DEPLOY_SCRIPT

# Or display in terminal (for smaller scripts)
Get-Content $DEPLOY_SCRIPT
```

**Example deploy script structure:**
```sql
-- Flyway State-Based Deployment Script
-- Generated: 2026-01-08 14:30:22
-- Source: schemaModel
-- Target: Test
-- 
-- WARNING: Review carefully before execution!

-- ============================================================================
-- BEGIN TRANSACTION
-- ============================================================================
BEGIN TRANSACTION;

-- ============================================================================
-- CREATE NEW OBJECTS
-- ============================================================================

-- Create table Sales.Campaigns
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Campaigns' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE [Sales].[Campaigns] (
        [CampaignID] INT IDENTITY(1,1) NOT NULL,
        [CampaignName] NVARCHAR(100) NOT NULL,
        [StartDate] DATE NOT NULL,
        [EndDate] DATE NULL,
        [Budget] DECIMAL(18, 2) NULL,
        CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignID])
    );
    PRINT 'Created table Sales.Campaigns';
END

-- ============================================================================
-- ALTER EXISTING OBJECTS
-- ============================================================================

-- Alter table Sales.CustomerFeedback
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'CustomerFeedback' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    -- Add new column Rating
    IF NOT EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales.CustomerFeedback') AND name = 'Rating')
    BEGIN
        ALTER TABLE [Sales].[CustomerFeedback]
        ADD [Rating] INT NULL;
        PRINT 'Added column Sales.CustomerFeedback.Rating';
    END
END

-- ============================================================================
-- UPDATE STORED PROCEDURES
-- ============================================================================

-- Update stored procedure Sales.SalesByCategory
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SalesByCategory' AND schema_id = SCHEMA_ID('Sales'))
    DROP PROCEDURE [Sales].[SalesByCategory];
GO

CREATE PROCEDURE [Sales].[SalesByCategory]
AS
BEGIN
    -- Updated procedure logic here
    SELECT CategoryName, SUM(TotalSales) AS TotalSales
    FROM ...
END
GO

PRINT 'Updated stored procedure Sales.SalesByCategory';

-- ============================================================================
-- COMMIT TRANSACTION
-- ============================================================================
COMMIT TRANSACTION;
PRINT 'Deployment completed successfully.';
```

### Step 7: Review the Undo Script

The undo script reverses the deploy script:

```powershell
# Review undo script
code $UNDO_SCRIPT
```

**Example undo script:**
```sql
-- Flyway State-Based Undo Script
-- Generated: 2026-01-08 14:30:22
-- 
-- WARNING: This will reverse the deployment!

BEGIN TRANSACTION;

-- Revert stored procedure Sales.SalesByCategory to previous version
IF EXISTS (SELECT 1 FROM sys.procedures WHERE name = 'SalesByCategory' AND schema_id = SCHEMA_ID('Sales'))
    DROP PROCEDURE [Sales].[SalesByCategory];
GO

CREATE PROCEDURE [Sales].[SalesByCategory]
AS
BEGIN
    -- Original procedure logic here
    SELECT CategoryName, SUM(Sales) AS TotalSales
    FROM ...
END
GO

-- Remove column Sales.CustomerFeedback.Rating
IF EXISTS (SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Sales.CustomerFeedback') AND name = 'Rating')
BEGIN
    ALTER TABLE [Sales].[CustomerFeedback]
    DROP COLUMN [Rating];
    PRINT 'Removed column Sales.CustomerFeedback.Rating';
END

-- Drop table Sales.Campaigns
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Campaigns' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    DROP TABLE [Sales].[Campaigns];
    PRINT 'Dropped table Sales.Campaigns';
END

COMMIT TRANSACTION;
PRINT 'Rollback completed successfully.';
```

### Step 8: Validate Script Safety

**Before deploying, verify:**

```powershell
# Check for dangerous operations
Select-String -Path $DEPLOY_SCRIPT -Pattern "DROP TABLE|TRUNCATE|DELETE FROM" -CaseSensitive

# If found, review those sections carefully!
```

**Questions to ask:**
- ✅ Are all changes expected?
- ✅ Are there any data-destructive operations (DROP, TRUNCATE)?
- ✅ Do ALTER TABLE commands preserve existing data?
- ✅ Are transactions used properly?
- ✅ Is the undo script the true reverse?

### Step 9: Save Scripts for Documentation

```powershell
# Copy scripts to project folder for version control
$RELEASE_FOLDER = ".\Artifacts\Releases\v1.2"
New-Item -ItemType Directory -Path $RELEASE_FOLDER -Force

Copy-Item $DEPLOY_SCRIPT -Destination "$RELEASE_FOLDER\deploy.sql"
Copy-Item $UNDO_SCRIPT -Destination "$RELEASE_FOLDER\undo.sql"

# Commit to Git for audit trail
git add .\Artifacts\Releases\v1.2\
git commit -m "chore(release): Add deployment scripts for v1.2"
```

## ✅ Success Criteria

- ✅ Ran `flyway prepare` successfully
- ✅ Generated deploy and undo scripts
- ✅ Reviewed both scripts for safety
- ✅ Understand what changes will be applied
- ✅ Saved scripts for documentation
- ✅ Ready to deploy (Quest 04) or validate (Quest 03)

## 🐛 Troubleshooting

### "Cannot connect to target environment"
**Problem:** Can't connect to Test database.  
**Solution:**
```powershell
# Test connection
flyway info -environment=Test

# Check flyway.toml configuration
code flyway.toml

# Verify credentials and connection string
[environments.Test]
url = "jdbc:sqlserver://testserver.database.windows.net:1433;databaseName=AutopilotTest"
user = "..."
password = "..."
```

### "Schema model location not found"
**Problem:** Can't find schema-model folder.  
**Solution:**
```powershell
# Verify you're in project root
Get-Location

# Check schema model exists
Test-Path ".\schema-model"

# If false, navigate to correct directory
cd C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State
```

### "No changes detected" but you expect changes
**Problem:** Schema model and Test are already in sync.  
**Solution:**
```powershell
# Run diff to see current state
flyway diff -diff.source=Test -diff.target=schemaModel

# If Test is ahead, you may need to:
# 1. Run Quest 00-Diff: Compare Test to schemaModel
# 2. Run Quest 01-Model: Capture Test state to schema model
# 3. Then run Quest 02-Prepare again
```

### "Script generation failed"
**Problem:** Error generating scripts.  
**Solution:**
```powershell
# Run with verbose logging
flyway prepare schemaModel Test `
  "-prepare.scriptFilename=$DEPLOY_SCRIPT" `
  "-prepare.undoScriptFilename=$UNDO_SCRIPT" `
  -workingDirectory="." `
  -logLevel=debug

# Review error messages
# Common issues:
# - Invalid schema model SQL files
# - Connection timeout
# - Permission issues writing scripts
```

## 💡 Best Practices

### Use Timestamped Script Names ✅
```powershell
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$DEPLOY_SCRIPT = ".\Artifacts\Deploy-Test-$TIMESTAMP.sql"
# Creates: Deploy-Test-20260108-143022.sql
```

### Store Scripts in Version Control ✅
```powershell
# Don't just use %temp% - save to project!
$DEPLOY_SCRIPT = ".\Artifacts\Releases\v1.2\deploy.sql"
$UNDO_SCRIPT = ".\Artifacts\Releases\v1.2\undo.sql"

flyway prepare schemaModel Test ...
git add .\Artifacts\Releases\v1.2\
git commit -m "chore: Add v1.2 deployment scripts"
```

### Always Generate Undo Scripts ✅
```
Even if you don't plan to use them!
- Safety net if deployment goes wrong
- Documentation of what changed
- Required for compliance/audit trails
```

### Review Scripts Before Deployment ✅
```powershell
# NEVER deploy without reviewing!
code $DEPLOY_SCRIPT

# Look for:
# - Unexpected DROP/TRUNCATE statements
# - Missing transactions
# - Data loss risks
```

### Test in Lower Environments First ✅
```
Development → Test → Staging → Production

Always:
1. Prepare script for Test
2. Deploy to Test (Quest 04)
3. Validate in Test
4. Prepare script for Staging
5. Deploy to Staging
6. Validate in Staging
7. Prepare script for Production
8. Deploy to Production (with caution!)
```

## 🎓 Key Concepts Learned

- **Prepare Command:** Generates deployment scripts
- **Deploy vs. Undo:** Forward migration vs. rollback
- **Script Review:** Critical safety step before execution
- **Idempotent SQL:** Scripts can run multiple times safely
- **Transaction Wrapping:** Atomic deployments (all or nothing)

## 🚀 Real-World Applications

- **Scheduled Releases:**
  - Friday: Generate deployment scripts
  - Review with team over weekend
  - Monday: Execute scripts in production

- **CI/CD Pipelines:**
  - Build: Generate deployment scripts automatically
  - Test: Run scripts against test environment
  - Approval: Manual review gate
  - Deploy: Execute scripts to production

- **Multi-Environment Deployments:**
  - Prepare Dev → Test script
  - Test and validate
  - Prepare Test → Staging script (regenerate!)
  - Test and validate
  - Prepare Staging → Production script (regenerate!)
  - Execute with change management approval

## 📚 Prepare Command Variations

### Prepare for Different Environments
```powershell
# Test environment
flyway prepare schemaModel Test -prepare.scriptFilename=.\deploy-test.sql -prepare.undoScriptFilename=.\undo-test.sql

# Staging environment
flyway prepare schemaModel Staging -prepare.scriptFilename=.\deploy-staging.sql -prepare.undoScriptFilename=.\undo-staging.sql

# Production environment
flyway prepare schemaModel Production -prepare.scriptFilename=.\deploy-prod.sql -prepare.undoScriptFilename=.\undo-prod.sql
```

### Prepare from Snapshot
```powershell
flyway prepare "snapshotHistory:baseline" Production `
  -prepare.scriptFilename=.\deploy-from-snapshot.sql `
  -prepare.undoScriptFilename=.\undo-from-snapshot.sql
```

### Prepare Between Two Databases
```powershell
# Generate script to sync Test to match Development
flyway prepare development Test `
  -prepare.scriptFilename=.\sync-test-to-dev.sql `
  -prepare.undoScriptFilename=.\undo-sync-test-to-dev.sql
```

## 🔄 Comparison with Development Quest

**Development Quest (Flyway Desktop GUI):**  
Prepare tab shows preview of what will be deployed (visual review).

**Operations Quest 02 (Flyway CLI):**  
`flyway prepare` generates SQL files for automation and review.

**Both achieve the same goal:** Create deployment scripts to apply schema changes.

## 📚 Next Steps

Now that you have deployment scripts, you can:

**Quest 03: Snapshot and Check** - Validate deployment safety before execution  
**Quest 04: Deploy** - Execute the deployment script against the target environment

---

**Congratulations!** 🎉 You've learned how to generate deployment and undo scripts using Flyway prepare!
