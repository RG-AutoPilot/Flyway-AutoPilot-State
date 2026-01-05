# Operations Quest - 02_Prepare: Generate Deployment Script

**Difficulty:** 🟡 Intermediate  
**Time:** 20-30 minutes  
**Prerequisites:** Completed 00_Diff and 01_Model quests, Flyway CLI installed

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to generate deployment scripts from your schema model
- Using `flyway generate` for state-based deployments
- Understanding dry-run mode to preview deployments
- Reviewing generated deployment scripts
- Validating deployment scripts before execution
- Best practices for deployment preparation

## 📖 Scenario
You've compared environments (00_Diff) and validated your schema model (01_Model). Now you need to generate the actual deployment script that will transform your Test database to match the desired state defined in your schema model.

The **generate/prepare** step creates a deployment script without executing it, giving you a chance to review exactly what will happen before deployment.

## 🎯 Your Mission
Generate a deployment script from your schema model and review it to ensure it will safely deploy your changes to the Test environment.

## 📋 State-Based Deployment Workflow

This is **Step 3 of 4** in the state-based deployment process:

1. **00_Diff** - Compare current vs desired state ✅ Completed
2. **01_Model** - Update/validate schema model ✅ Completed
3. **02_Prepare** ← You are here - Generate deployment script
4. **03_Deploy** - Execute deployment

## 📝 Steps

### Step 1: Understand Deployment Script Generation

Flyway will generate a deployment script that:
- Creates new objects from schema model
- Alters existing objects to match schema model
- Drops objects not in schema model (if configured)
- Handles dependencies and deployment order
- Includes transactional safety where possible

The script is **idempotent** - safe to run multiple times.

### Step 2: Generate Deployment Script

Create the deployment script for your Test environment:

```powershell
# Basic generation
flyway generate `
    -generate.location=filesystem:schema-model `
    -generate.types=versioned `
    -generate.description="Deploy to Test" `
    -generate.targetEnvironment=test

# With descriptive filename
flyway generate `
    -generate.location=filesystem:schema-model `
    -generate.description="Deploy-to-Test-$(Get-Date -Format 'yyyyMMdd')" `
    -generate.targetEnvironment=test `
    -outputFile="migrations/V$(Get-Date -Format 'yyyyMMdd.HHmmss')__Deploy_to_Test.sql"
```

**Generated file location:** `migrations/V{timestamp}__{description}.sql`

### Step 3: Review the Generated Script

Open the generated deployment script and review it section by section:

```sql
-- Example generated deployment script
-- V20260105.143022__Deploy_to_Test.sql

/*
 * Flyway Generated Deployment Script
 * Source: Schema Model
 * Target: AutopilotTest
 * Generated: 2026-01-05 14:30:22
 */

-- ===========================================
-- CREATE SCHEMAS
-- ===========================================
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Sales')
    EXEC('CREATE SCHEMA Sales');

-- ===========================================
-- CREATE TABLES
-- ===========================================

-- Table: Sales.Campaigns
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Campaigns' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE Sales.Campaigns (
        CampaignID INT PRIMARY KEY IDENTITY(1,1),
        CampaignName NVARCHAR(100) NOT NULL,
        StartDate DATE NOT NULL,
        EndDate DATE NOT NULL
    );
END;

-- Table: Sales.LoyaltyProgram
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LoyaltyProgram' AND schema_id = SCHEMA_ID('Sales'))
BEGIN
    CREATE TABLE Sales.LoyaltyProgram (
        TierID INT PRIMARY KEY,
        TierName NVARCHAR(50) NOT NULL,
        MinimumPoints INT NOT NULL,
        DiscountPercentage DECIMAL(5,2) NOT NULL
    );
END;

-- ===========================================
-- CREATE STORED PROCEDURES
-- ===========================================

-- Procedure: Logistics.GetUpcomingFlights
CREATE OR ALTER PROCEDURE Logistics.GetUpcomingFlights
    @DaysAhead INT = 7
AS
BEGIN
    -- procedure code
END;
GO

-- ===========================================
-- CREATE VIEWS
-- ===========================================

-- View: Sales.CustomerOrdersView
CREATE OR ALTER VIEW Sales.CustomerOrdersView
AS
    -- view definition
GO
```

### Step 4: Validate the Deployment Script

Check the script for potential issues:

**Safety Checks:**
- ✅ Creates objects with IF NOT EXISTS checks
- ✅ Uses CREATE OR ALTER for procedures/views
- ✅ Handles dependencies in correct order
- ⚠️ Any DROP statements? (review carefully!)
- ⚠️ Any ALTER TABLE that might lose data?

**Quality Checks:**
- ✅ Script is properly formatted
- ✅ All expected objects are included
- ✅ No syntax errors
- ✅ Matches what diff showed in 00_Diff

### Step 5: Dry-Run the Deployment (Optional but Recommended)

Test the script without actually executing it:

```powershell
# Dry-run mode (Enterprise feature)
flyway migrate `
    -dryRunOutput="dry-run-$(Get-Date -Format 'yyyyMMdd-HHmmss').sql" `
    -environment=test

# Review the dry-run output
code "dry-run-*.sql"
```

**What dry-run shows:**
- Exact SQL that would be executed
- Objects that would be created/modified
- Estimated execution time
- Any warnings or errors

### Step 6: Run Flyway Check (Enterprise)

Use Flyway Check to validate the deployment:

```powershell
# Check for breaking changes
flyway check -changes `
    -check.buildEnvironment=build `
    -environment=test

# Check for code quality issues
flyway check -code `
    -check.buildEnvironment=build `
    -environment=test

# Check for drift
flyway check -drift `
    -check.buildEnvironment=build `
    -environment=test
```

**Review Check Reports:**
- Breaking changes (column drops, type changes)
- Code complexity warnings
- Drift detection
- Deployment risks

### Step 7: Save Deployment Artifacts

Organize generated scripts and reports:

```powershell
# Create deployment package directory
$deployDate = Get-Date -Format 'yyyyMMdd-HHmmss'
$packageDir = "deployment-packages\test-$deployDate"
New-Item -ItemType Directory -Path $packageDir -Force

# Copy deployment script
Copy-Item "migrations\V*.sql" -Destination "$packageDir\deployment-script.sql"

# Copy diff report
Copy-Item "reports\diff-*.json" -Destination "$packageDir\diff-report.json"

# Copy check reports (if generated)
Copy-Item "reports\changes-*.html" -Destination "$packageDir\changes-report.html" -ErrorAction SilentlyContinue

# Create deployment documentation
@"
Deployment Package: Test Environment
Generated: $(Get-Date)
Source: Schema Model
Target: AutopilotTest

Files:
- deployment-script.sql - Main deployment script
- diff-report.json - Pre-deployment diff analysis
- changes-report.html - Flyway Check results

Review all files before executing deployment (03_Deploy quest).
"@ | Out-File -FilePath "$packageDir\README.txt"

Write-Host "Deployment package created: $packageDir"
```

### Step 8: Pre-Deployment Checklist

Before proceeding to 03_Deploy, verify:

```
□ Deployment script generated successfully
□ Script reviewed and looks correct
□ No unexpected DROP statements
□ Dry-run completed (if available)
□ Flyway Check passed (if available)
□ Deployment artifacts saved
□ Stakeholders notified of pending deployment
□ Backup of Test database exists
□ Rollback plan documented
```

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Deployment script generated from schema model
- ✅ Script reviewed for safety and correctness
- ✅ Dry-run completed (if using Enterprise)
- ✅ Flyway Check validation passed (if using Enterprise)
- ✅ Deployment artifacts saved and documented
- ✅ Pre-deployment checklist completed
- ✅ Ready to execute deployment (03_Deploy)

## 🐛 Troubleshooting

### "Cannot generate deployment script"
**Problem:** Generate command fails.  
**Solution:**
- Verify schema model validated successfully (01_Model)
- Check `flyway.toml` configuration
- Ensure target environment is configured
- Run with `-logLevel=debug` for details

### "Generated script has syntax errors"
**Problem:** Deployment script contains invalid SQL.  
**Solution:**
- Check source files in schema-model
- Validate each .sql file individually
- Fix syntax in schema model
- Regenerate deployment script

### "Script includes unexpected DROP statements"
**Problem:** Objects will be deleted unexpectedly.  
**Solution:**
- Review diff from 00_Diff quest
- If objects should exist, add to schema model
- If objects are drift, decide if deletion is acceptable
- Use `-generate.includeDrop=false` to prevent drops

### "Dependencies in wrong order"
**Problem:** Script tries to create object before its dependency.  
**Solution:**
- Flyway should handle this automatically
- If not, check for circular dependencies
- Manually reorder in schema model if needed

## 💡 Best Practices

### Always Review Generated Scripts ✅
```powershell
# Never deploy without review
flyway generate -generate.description="Deploy to Test"
# Stop and review the generated SQL
code migrations/V*.sql
# Only proceed to 03_Deploy after review
```

### Use Descriptive Migration Names ✅
```powershell
# Good
flyway generate `
    -generate.description="Deploy-CRM-Features-to-Test-Jan2026"

# Bad
flyway generate -generate.description="changes"
```

### Save Deployment Packages ✅
```powershell
# Create organized deployment packages
deployment-packages/
├── test-20260105-143000/
│   ├── deployment-script.sql
│   ├── diff-report.json
│   ├── changes-report.html
│   └── README.txt
├── test-20260106-091500/
└── ...
```

### Run Checks Before Deploying ✅
```powershell
# Enterprise: Always use Flyway Check
flyway check -changes -environment=test
flyway check -drift -environment=test
# Review reports before proceeding
```

## 🎓 Key Concepts Learned

- **Deployment Script Generation:** Creating executable scripts from schema model
- **Dry-Run Validation:** Testing deployments without execution
- **Flyway Check:** Pre-deployment safety validation
- **Deployment Artifacts:** Organizing scripts and reports
- **Idempotency:** Scripts safe to run multiple times

## 🚀 Real-World Applications

- **Change Control:** Review and approve before deployment
- **Audit Trail:** Document what will be deployed
- **Risk Mitigation:** Catch issues before production impact
- **Rollback Planning:** Understand changes for rollback strategy
- **Compliance:** Evidence of pre-deployment validation

## 📚 Helper Files Reference

See the [Flyway Helper Files](https://github.com/RG-AutoPilot/Flyway-Helper-Files) repository:
- `CLI/State/MSSQL_PowerShell/02_Prepare.ps1` - Complete prepare/generate script
- Shows artifact organization
- Demonstrates validation workflows
- Error handling patterns

## 🌟 Advanced Tips (Optional)

### Generate with Filters
```powershell
# Only generate for specific schemas
flyway generate `
    -generate.location=filesystem:schema-model `
    -generate.schemas=Sales,Logistics `
    -generate.description="Deploy Sales and Logistics only"
```

### Automated Generation in CI/CD
```powershell
# In your pipeline
$date = Get-Date -Format 'yyyyMMdd.HHmmss'
flyway generate `
    -generate.description="CI-Build-$env:BUILD_NUMBER" `
    -outputFile="migrations/V$date`__CI_Build.sql"

if ($LASTEXITCODE -ne 0) {
    Write-Error "Deployment script generation failed"
    exit 1
}
```

### Compare Generated Script to Previous
```powershell
# See what changed since last deployment
code --diff `
    deployment-packages/test-20260104/deployment-script.sql `
    deployment-packages/test-20260105/deployment-script.sql
```

## 📚 Next Steps

Continue with the state-based deployment workflow:

1. **`Operations/00_Diff`** - Compare environments ✅ Completed
2. **`Operations/01_Model`** - Validate schema model ✅ Completed
3. **`Operations/02_Prepare`** - Generate deployment script ✅ You just completed this!
4. **`Operations/03_Deploy`** ← Next - Execute deployment to Test

---

**Congratulations!** 🎉 Your deployment script is generated and validated. Proceed to 03_Deploy to execute the deployment to your Test environment.
