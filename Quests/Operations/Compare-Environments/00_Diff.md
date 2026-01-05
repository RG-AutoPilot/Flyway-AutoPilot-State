# Operations Quest - 00_Diff: Compare Environments

**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Prerequisites:** Flyway CLI installed, access to source and target databases

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to compare database environments using Flyway CLI
- Understanding schema drift detection
- Identifying differences between your schema model and target database
- Using `flyway diff` for state-based deployments
- Interpreting diff reports for deployment planning

## 📖 Scenario
You've been developing database changes in your Dev environment, captured in the schema model. Now you need to deploy to Test, but first you want to understand:
- What's different between the schema model and Test database?
- Has anyone made unauthorized changes in Test (drift)?
- What will actually change when you deploy?

The **diff** command is your first step in the state-based deployment workflow - it shows you the current state vs. desired state.

## 🎯 Your Mission
Use Flyway CLI's `diff` command to compare your schema model against a target database and understand what changes need to be deployed.

## 📋 State-Based Deployment Workflow

This is **Step 1 of 4** in the state-based deployment process:

1. **00_Diff** ← You are here - Compare current vs desired state
2. **01_Model** - Update/validate schema model
3. **02_Prepare** - Generate deployment script
4. **03_Deploy** - Execute deployment

## 📝 Steps

### Step 1: Understand Your Schema Model

Your schema model represents the **desired state** of your database:

```
schema-model/
├── Security/
│   └── Schemas/
├── Tables/
│   ├── Sales.Campaigns.sql
│   ├── Sales.LoyaltyProgram.sql
│   └── ...
├── Stored Procedures/
├── Views/
└── ...
```

Each file contains the CREATE script for that object. This is what you **want** the database to look like.

### Step 2: Set Up Your Environment Configuration

Ensure your `flyway.toml` has both build and target environments configured:

```toml
[environments.build]
url = "jdbc:sqlserver://localhost:1433;databaseName=AutopilotDev;encrypt=true;trustServerCertificate=true"
user = "${DB_USER}"
password = "${DB_PASSWORD}"

[environments.test]
url = "jdbc:sqlserver://localhost:1433;databaseName=AutopilotTest;encrypt=true;trustServerCertificate=true"
user = "${DB_USER}"
password = "${DB_PASSWORD}"
```

### Step 3: Run Your First Diff

Compare the schema model against your Test environment:

```powershell
# Basic diff command
flyway diff -diff.source=schemaModel -diff.target=test

# With more detailed output
flyway diff `
    -diff.source=schemaModel `
    -diff.target=test `
    -diff.artifactFilename=diff-report.json
```

### Step 4: Understand the Diff Output

Flyway will show you three categories of changes:

**🟢 Objects to CREATE:**
```
Tables to create:
  - Sales.Campaigns
  - Sales.LoyaltyProgram

Stored Procedures to create:
  - Logistics.GetUpcomingFlights
```

**🟡 Objects to ALTER:**
```
Tables to modify:
  - Sales.Customers (new column: Email)

Views to update:
  - Sales.CustomerOrdersView (definition changed)
```

**🔴 Objects to DROP:**
```
Tables to drop:
  - Sales.OldCampaigns (not in schema model)
```

### Step 5: Analyze the Results

Review the diff report to answer:

1. **Are the changes expected?**
   - Do they match what you developed?
   - Any surprises?

2. **Is there drift?**
   - Objects in Test that aren't in your schema model
   - Unauthorized changes someone made directly in Test

3. **Are there destructive changes?**
   - Dropping tables or columns
   - Data loss risk

4. **What's the deployment impact?**
   - How many objects affected?
   - Complexity of changes

### Step 6: Save the Diff Report

Always save diff reports for documentation:

```powershell
# Generate JSON report
flyway diff `
    -diff.source=schemaModel `
    -diff.target=test `
    -diff.artifactFilename="reports/diff-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"

# Human-readable format
flyway diff `
    -diff.source=schemaModel `
    -diff.target=test `
    | Tee-Object -FilePath "reports/diff-$(Get-Date -Format 'yyyyMMdd-HHmmss').txt"
```

### Step 7: Common Diff Scenarios

**Scenario A: Clean Deployment (First Time)**
```
Result: Schema model has objects, Test database is empty
Action: All objects will be CREATED
Risk: Low - new deployment
```

**Scenario B: Incremental Update**
```
Result: A few new objects, some modifications
Action: CREATE new objects, ALTER existing ones
Risk: Low-Medium - review ALTERs for data impact
```

**Scenario C: Drift Detected**
```
Result: Test has objects not in schema model
Action: Objects will be DROPPED or you need to capture them
Risk: High - investigate before proceeding!
```

**Scenario D: No Changes**
```
Result: Schema model matches Test database
Action: No deployment needed
Risk: None - environments are in sync
```

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Flyway CLI is configured with source and target environments
- ✅ Successfully run `flyway diff` command
- ✅ Can interpret diff output (CREATE, ALTER, DROP)
- ✅ Understand the difference between expected changes and drift
- ✅ Saved diff report for documentation
- ✅ Ready to proceed to 01_Model quest

## 🐛 Troubleshooting

### "Cannot connect to target database"
**Problem:** Flyway can't reach Test database.  
**Solution:**
- Verify connection string in `flyway.toml`
- Test connection outside Flyway (SSMS, sqlcmd)
- Check firewall rules
- Ensure credentials are correct

### "Schema model not found"
**Problem:** Flyway can't locate schema-model folder.  
**Solution:**
- Verify you're in the project root directory
- Check `flyway.toml` has correct schema model path
- Ensure schema-model folder exists with .sql files

### "Diff shows unexpected objects to drop"
**Problem:** Objects exist in Test but not in schema model.  
**Solution:**
- **If intentional:** Someone made unauthorized changes - capture them or approve deletion
- **If unintentional:** You may need to add those objects to your schema model
- Use Flyway Desktop to capture missing objects into schema model

### "Diff output is too large"
**Problem:** Too many differences to review.  
**Solution:**
- Use `-diff.artifactFilename` to save to file
- Review JSON format for easier parsing
- Filter by object type if needed
- Consider if environments are too far out of sync

## 💡 Best Practices

### Always Diff Before Deploying ✅
```powershell
# Good workflow
flyway diff -diff.source=schemaModel -diff.target=test
# Review changes
# If acceptable, proceed to 01_Model
```

### Save Diff Reports for Audit Trail ✅
```powershell
# Create reports directory
New-Item -ItemType Directory -Path "reports" -Force

# Save diff with timestamp
flyway diff `
    -diff.source=schemaModel `
    -diff.target=test `
    -diff.artifactFilename="reports/diff-test-$(Get-Date -Format 'yyyyMMdd-HHmmss').json"
```

### Handle Drift Appropriately ✅
```powershell
# If drift detected:
# 1. Investigate who/why
# 2. Either:
#    a) Capture into schema model (if keeping)
#    b) Approve deletion (if removing)
# 3. Document decision
```

### Use Environment Variables for Credentials ✅
```powershell
# Set credentials securely
$env:DB_USER = "flyway_user"
$env:DB_PASSWORD = "secure_password"

# Then run diff
flyway diff -diff.source=schemaModel -diff.target=test
```

## 🎓 Key Concepts Learned

- **Schema Model:** Your desired database state in source control
- **Diff Analysis:** Comparing desired state vs actual state
- **Drift Detection:** Finding unauthorized database changes
- **Deployment Planning:** Understanding what will change
- **State-Based Workflow:** Model-driven deployment approach

## 🚀 Real-World Applications

- **Pre-Deployment Validation:** Know what will change before deploying
- **Drift Detection:** Find unauthorized production changes
- **Change Documentation:** Audit trail of what was deployed
- **Risk Assessment:** Identify destructive operations before they happen
- **Multi-Environment Sync:** Ensure consistency across environments

## 📚 Helper Files Reference

See the [Flyway Helper Files](https://github.com/RG-AutoPilot/Flyway-Helper-Files) repository:
- `CLI/State/MSSQL_PowerShell/00_Diff.ps1` - Complete diff script example
- Shows how to automate diff reporting
- Demonstrates error handling and logging

## 🌟 Advanced Tips (Optional)

### Compare Two Databases (Not Schema Model)
```powershell
# Compare Dev to Test (both databases)
flyway diff `
    -diff.source=build `
    -diff.target=test
```

### Filter Diff by Object Type
```powershell
# Only show table differences
flyway diff `
    -diff.source=schemaModel `
    -diff.target=test `
    -diff.includeObjects="Table"
```

### Automated Diff in CI/CD
```powershell
# In your pipeline
flyway diff -diff.source=schemaModel -diff.target=test
if ($LASTEXITCODE -ne 0) {
    Write-Error "Diff failed - review changes"
    exit 1
}
```

## 📚 Next Steps

Continue with the state-based deployment workflow:

1. **`Operations/01_Model`** ← Next - Update and validate schema model
2. **`Operations/02_Prepare`** - Generate deployment script
3. **`Operations/03_Deploy`** - Execute deployment

---

**Congratulations!** 🎉 You can now compare environments and detect drift using Flyway's diff command. Proceed to 01_Model to validate your schema model.
