# Operations Quest - 03_Deploy: Execute Deployment

**Difficulty:** 🟡 Intermediate  
**Time:** 20-30 minutes  
**Prerequisites:** Completed 00_Diff, 01_Model, and 02_Prepare quests, Flyway CLI installed

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to execute deployment scripts using Flyway CLI
- Safe deployment practices for state-based workflows
- Monitoring deployment progress and handling errors
- Verifying successful deployments
- Post-deployment validation
- Rollback strategies

## 📖 Scenario
You've compared environments (00_Diff), validated your schema model (01_Model), and generated a deployment script (02_Prepare). Now it's time to execute the deployment and transform your Test database to match your desired state.

The **deploy** step executes the deployment script, applies all changes, and verifies the deployment succeeded.

## 🎯 Your Mission
Execute the generated deployment script against your Test environment and verify the deployment completed successfully.

## 📋 State-Based Deployment Workflow

This is **Step 4 of 4** in the state-based deployment process:

1. **00_Diff** - Compare current vs desired state ✅ Completed
2. **01_Model** - Update/validate schema model ✅ Completed
3. **02_Prepare** - Generate deployment script ✅ Completed
4. **03_Deploy** ← You are here - Execute deployment

## 📝 Steps

### Step 1: Pre-Deployment Checklist

Before executing, verify everything is ready:

```powershell
# 1. Backup target database
# (In SSMS or via script)

# 2. Verify deployment script exists
Get-ChildItem migrations\V*.sql | Sort-Object LastWriteTime -Descending | Select-Object -First 1

# 3. Review the script one last time
code migrations\V*.sql

# 4. Verify target environment configuration
flyway info -environment=test

# 5. Ensure no one else is using Test database
# (Coordinate with team)
```

### Step 2: Execute the Deployment

Run Flyway migrate to deploy the changes:

```powershell
# Basic deployment
flyway migrate -environment=test

# With detailed output
flyway migrate `
    -environment=test `
    -logLevel=debug `
    | Tee-Object -FilePath "logs/deployment-$(Get-Date -Format 'yyyyMMdd-HHmmss').log"
```

### Step 3: Monitor Deployment Progress

Watch the output as Flyway executes:

```
Flyway Community Edition 10.x.x

Database: jdbc:sqlserver://localhost:1433/AutopilotTest (SQL Server 15.0)
Schema history table [AutopilotTest].[dbo].[flyway_schema_history] exists

Current version of schema [dbo]: << Empty Schema >>
Migrating schema [dbo] to version "20260105.143022 - Deploy to Test"

Applying migration:
  CREATE SCHEMA Sales
  ✓ Created schema Sales

  CREATE TABLE Sales.Campaigns
  ✓ Created table Sales.Campaigns

  CREATE TABLE Sales.LoyaltyProgram
  ✓ Created table Sales.LoyaltyProgram

  CREATE PROCEDURE Logistics.GetUpcomingFlights
  ✓ Created procedure Logistics.GetUpcomingFlights

  CREATE VIEW Sales.CustomerOrdersView
  ✓ Created view Sales.CustomerOrdersView

Successfully applied 1 migration to schema [dbo]
  Version: 20260105.143022
  Description: Deploy to Test
  Execution time: 00:00.342s

Migration complete ✓
```

### Step 4: Handle Deployment Outcomes

**✅ Successful Deployment:**
```
Successfully applied 1 migration to schema [dbo]
Version: 20260105.143022
```
→ Proceed to Step 5 (Verification)

**❌ Deployment Failed:**
```
ERROR: Migration V20260105.143022 failed
SQL State: 42S01
Error Code: 2714
Message: There is already an object named 'Campaigns' in the database
Location: Line 23

Migration failed!
```
→ Proceed to Troubleshooting section

**⚠️ Partial Success:**
```
Applying migration V20260105.143022:
  ✓ CREATE SCHEMA Sales
  ✓ CREATE TABLE Sales.Campaigns
  ✗ CREATE TABLE Sales.Orders
      ERROR: Foreign key constraint references non-existent table

Migration failed after 2 successful statements
```
→ Database is in partial state, proceed to Troubleshooting

### Step 5: Verify Deployment Success

Confirm the deployment worked correctly:

```powershell
# 1. Check Flyway migration history
flyway info -environment=test
```

Expected output:
```
+-----------+---------+---------------------+----------+---------------------+---------+
| Category  | Version | Description         | Type     | Installed On        | State   |
+-----------+---------+---------------------+----------+---------------------+---------+
| Versioned | 20260105| Deploy to Test      | SQL      | 2026-01-05 14:35:22 | Success |
+-----------+---------+---------------------+----------+---------------------+---------+
```

```sql
-- 2. Verify objects were created
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ObjectName,
    type_desc AS ObjectType
FROM sys.objects
WHERE is_ms_shipped = 0
ORDER BY SchemaName, type_desc, name;

-- 3. Verify specific tables exist
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA IN ('Sales', 'Logistics', 'Operation')
ORDER BY TABLE_SCHEMA, TABLE_NAME;

-- 4. Check table row counts (for static data)
SELECT 
    'Sales.LoyaltyProgram' AS TableName,
    COUNT(*) AS RowCount
FROM Sales.LoyaltyProgram;

-- 5. Test stored procedures
EXEC Logistics.GetUpcomingFlights @DaysAhead = 7;
```

### Step 6: Post-Deployment Validation

Run comprehensive validation:

```powershell
# 1. Verify no drift (schema model matches deployed database)
flyway diff `
    -diff.source=schemaModel `
    -diff.target=test

# Expected: "No differences found"

# 2. Validate deployment matches expected state
flyway validate -environment=test

# 3. Run application smoke tests
# (Connect your application to Test and verify basic functionality)
```

### Step 7: Document the Deployment

Record deployment details for audit trail:

```powershell
# Create deployment report
$deploymentReport = @"
===========================================
DEPLOYMENT REPORT
===========================================
Environment: Test (AutopilotTest)
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Deployed By: $env:USERNAME
Source: Schema Model

Deployment Script:
  Version: 20260105.143022
  Description: Deploy to Test
  Location: migrations/V20260105.143022__Deploy_to_Test.sql

Results:
  Status: Success
  Execution Time: 0.342s
  Objects Created: 15
  Objects Modified: 3
  Objects Dropped: 0

Verification:
  ✓ Flyway schema history updated
  ✓ All objects created successfully
  ✓ No drift detected
  ✓ Validation passed
  ✓ Smoke tests passed

Next Steps:
  - Notify stakeholders
  - Update deployment tracker
  - Monitor Test environment
  - Plan Production deployment
===========================================
"@

# Save report
$deploymentReport | Out-File -FilePath "reports/deployment-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"

# Display report
Write-Host $deploymentReport
```

### Step 8: Notify Stakeholders

Communicate deployment completion:

```powershell
# Example: Send email notification (customize for your environment)
# Or post to Teams/Slack

Write-Host "Deployment to Test environment completed successfully!"
Write-Host "Database: AutopilotTest"
Write-Host "Version: 20260105.143022"
Write-Host "Time: $(Get-Date)"
```

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Deployment executed without errors
- ✅ Flyway schema history shows successful migration
- ✅ All expected objects exist in Test database
- ✅ No drift detected (schema model matches deployed state)
- ✅ Validation passed
- ✅ Deployment documented and communicated
- ✅ Test database ready for application testing

## 🐛 Troubleshooting

### "Migration failed - object already exists"
**Problem:** Deployment script tries to create existing object.  
**Solution:**
```powershell
# Check current state
flyway info -environment=test

# If migration partially applied:
# Option 1: Fix the migration script and repair
flyway repair -environment=test
# Then re-run migrate

# Option 2: Clean and re-deploy (Dev only!)
flyway clean -environment=test
flyway migrate -environment=test
```

### "Foreign key constraint error"
**Problem:** Deployment tries to create FK before referenced table exists.  
**Solution:**
- Check deployment script object order
- Regenerate script (02_Prepare) - Flyway should handle dependencies
- If issue persists, manually reorder in schema model

### "Migration shows as failed in history"
**Problem:** `flyway info` shows failed migration.  
**Solution:**
```powershell
# 1. Review what failed
flyway info -environment=test

# 2. Manually fix the database issue

# 3. Mark migration as repaired
flyway repair -environment=test

# 4. Re-run migrate
flyway migrate -environment=test
```

### "Deployment succeeded but objects missing"
**Problem:** Migration shows success but objects don't exist.  
**Solution:**
- Check if connected to correct database
- Review deployment script - might have IF NOT EXISTS logic
- Check schema filtering in flyway.toml
- Verify objects in correct schema

## 💡 Best Practices

### Always Backup Before Deploying ✅
```powershell
# Create backup before deployment
# In SSMS or via script:
BACKUP DATABASE AutopilotTest 
TO DISK = 'C:\Backups\AutopilotTest_PreDeploy_20260105.bak'
WITH INIT, COMPRESSION;
```

### Monitor Deployments Actively ✅
```powershell
# Don't walk away during deployment
# Watch for errors or warnings
# Be ready to respond if issues occur
flyway migrate -environment=test -logLevel=debug
```

### Validate After Every Deployment ✅
```powershell
# Always run post-deployment checks
flyway info -environment=test
flyway diff -diff.source=schemaModel -diff.target=test
flyway validate -environment=test
```

### Document Everything ✅
```powershell
# Save logs
flyway migrate -environment=test | Tee-Object -FilePath deployment.log

# Create deployment reports
# Update change management system
# Notify stakeholders
```

## 🎓 Key Concepts Learned

- **Deployment Execution:** Applying schema model changes to target database
- **Migration Tracking:** Flyway schema history management
- **Deployment Verification:** Ensuring changes applied correctly
- **Error Handling:** Recovering from failed deployments
- **Audit Trail:** Documenting deployment activities

## 🚀 Real-World Applications

- **Continuous Deployment:** Automated deployments in CI/CD pipelines
- **Multi-Environment Progression:** Dev → Test → Stage → Production
- **Disaster Recovery:** Rebuilding databases from schema model
- **Compliance:** Audit trail of all database changes
- **Team Collaboration:** Coordinated deployments across teams

## 📚 Helper Files Reference

See the [Flyway Helper Files](https://github.com/RG-AutoPilot/Flyway-Helper-Files) repository:
- `CLI/State/MSSQL_PowerShell/03_Deploy.ps1` - Complete deployment script
- Shows error handling
- Demonstrates logging and reporting
- Includes rollback strategies

## 🌟 Advanced Tips (Optional)

### Automated Deployment with Validation
```powershell
# Complete automated deployment workflow
function Deploy-ToTest {
    # Pre-deployment checks
    flyway info -environment=test
    if ($LASTEXITCODE -ne 0) { throw "Pre-deployment check failed" }
    
    # Execute deployment
    flyway migrate -environment=test
    if ($LASTEXITCODE -ne 0) { throw "Deployment failed" }
    
    # Post-deployment validation
    flyway diff -diff.source=schemaModel -diff.target=test
    if ($LASTEXITCODE -ne 0) { throw "Post-deployment validation failed" }
    
    Write-Host "Deployment successful!"
}

Deploy-ToTest
```

### Rollback Strategy
```powershell
# If deployment fails and you need to rollback:
# 1. Restore from backup
Restore-Database -DatabaseName AutopilotTest -BackupFile "C:\Backups\AutopilotTest_PreDeploy.bak"

# 2. Or use Flyway undo (Enterprise, if undo migrations exist)
flyway undo -environment=test

# 3. Or manually revert changes
```

### CI/CD Integration
```yaml
# Azure DevOps pipeline example
- task: PowerShell@2
  displayName: 'Deploy to Test'
  inputs:
    targetType: 'inline'
    script: |
      flyway migrate -environment=test
      if ($LASTEXITCODE -ne 0) { exit 1 }
      flyway info -environment=test
```

## 📚 Congratulations!

You've completed the **State-Based Deployment Workflow**:

1. ✅ **00_Diff** - Compared environments and identified changes
2. ✅ **01_Model** - Validated schema model
3. ✅ **02_Prepare** - Generated deployment script
4. ✅ **03_Deploy** - Executed deployment successfully

Your Test database now matches your schema model, and you're ready to:
- Test application functionality
- Plan Production deployment
- Continue development with confidence

---

**Congratulations!** 🎉 You've successfully deployed database changes using Flyway's state-based workflow. You now understand the complete deployment lifecycle from diff to deploy!
