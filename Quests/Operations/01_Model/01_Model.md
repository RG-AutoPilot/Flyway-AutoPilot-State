# Operations Quest - 01_Model: Update and Validate Schema Model

**Difficulty:** 🟡 Intermediate  
**Time:** 15-20 minutes  
**Prerequisites:** Completed 00_Diff quest, Flyway CLI installed

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to validate your schema model before deployment
- Updating the schema model with latest changes
- Using `flyway model` command for state-based workflows
- Ensuring schema model accurately represents desired state
- Understanding schema model structure and organization

## 📖 Scenario
You've run `flyway diff` and identified changes needed in your Test environment. But before generating deployment scripts, you need to ensure your schema model is complete, accurate, and represents the exact state you want to deploy.

The **model** command validates that your schema model is well-formed and ready for deployment generation.

## 🎯 Your Mission
Validate and update your schema model to ensure it's ready for deployment script generation.

## 📋 State-Based Deployment Workflow

This is **Step 2 of 4** in the state-based deployment process:

1. **00_Diff** - Compare current vs desired state ✅ Completed
2. **01_Model** ← You are here - Update/validate schema model
3. **02_Prepare** - Generate deployment script
4. **03_Deploy** - Execute deployment

## 📝 Steps

### Step 1: Understand the Schema Model Structure

Your schema model is organized by object type:

```
schema-model/
├── Security/
│   └── Schemas/
│       ├── Sales.sql
│       ├── Logistics.sql
│       └── Operation.sql
├── Tables/
│   ├── Sales.Campaigns.sql
│   ├── Sales.LoyaltyProgram.sql
│   └── Logistics.Flight.sql
├── Stored Procedures/
│   └── Logistics.GetUpcomingFlights.sql
├── Views/
│   └── Sales.CustomerOrdersView.sql
└── Functions/
    └── Logistics.CalculateFlightDuration.sql
```

Each file contains the complete CREATE statement for that object.

### Step 2: Validate Your Schema Model

Run the model command to validate your schema model:

```powershell
# Basic validation
flyway model -model.location=filesystem:schema-model

# With verbose output
flyway model `
    -model.location=filesystem:schema-model `
    -logLevel=debug
```

**What does this check?**
- ✅ All SQL files are syntactically valid
- ✅ Object dependencies are resolvable
- ✅ No circular dependencies
- ✅ Files are properly organized
- ✅ Schema model is internally consistent

### Step 3: Interpret Validation Results

**✅ Success Output:**
```
Flyway Model Validation
-----------------------
Validating schema model at: filesystem:schema-model

Objects validated: 23
  Tables: 12
  Views: 4
  Stored Procedures: 5
  Functions: 2

Schema model is valid ✓
Ready for deployment generation
```

**❌ Validation Errors:**
```
ERROR: Invalid SQL syntax in schema-model/Tables/Sales.Campaigns.sql
  Line 5: Missing comma in column definition

ERROR: Unresolved dependency
  View Sales.CustomerOrdersView references table Sales.Orders
  but Sales.Orders.sql not found in schema model

ERROR: Circular dependency detected
  Procedure A calls Procedure B
  Procedure B calls Procedure A
```

### Step 4: Fix Any Validation Errors

If errors are found, fix them before proceeding:

**Syntax Errors:**
```powershell
# Open the problematic file
code schema-model/Tables/Sales.Campaigns.sql

# Fix the SQL
# Save the file
# Re-run validation
flyway model -model.location=filesystem:schema-model
```

**Missing Dependencies:**
```powershell
# If object exists in Dev but not in schema model:
# Use Flyway Desktop to capture it
# Or manually create the .sql file in schema-model
```

**Circular Dependencies:**
```
# Refactor your procedures to break the cycle
# Or accept it if it's unavoidable (Flyway will handle deployment order)
```

### Step 5: Update Schema Model (If Needed)

If you've made recent changes in your Dev database that aren't captured:

**Option A: Using Flyway Desktop**
1. Open Flyway Desktop
2. Connect to Dev database
3. Navigate to Schema Model tab
4. Click "Capture Changes" or "Update Schema Model"
5. Review and save

**Option B: Manual Update**
1. Identify the changed object
2. Script it from Dev database (SSMS: Right-click → Script As → CREATE)
3. Save to appropriate folder in schema-model
4. Re-run validation

### Step 6: Verify Schema Model Matches Development Database

Ensure your schema model accurately reflects your Dev database:

```powershell
# Compare schema model to Dev (build environment)
flyway diff `
    -diff.source=schemaModel `
    -diff.target=build

# Expected result: No differences
# If differences found, update schema model
```

### Step 7: Confirm Ready for Deployment Generation

Final checklist before proceeding to 02_Prepare:

```powershell
# 1. Schema model validates successfully
flyway model -model.location=filesystem:schema-model

# 2. Schema model matches Dev database
flyway diff -diff.source=schemaModel -diff.target=build

# 3. Diff shows expected changes for Test
flyway diff -diff.source=schemaModel -diff.target=test

# All green? Proceed to 02_Prepare!
```

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Schema model validates without errors
- ✅ All SQL files are syntactically correct
- ✅ Dependencies are resolved
- ✅ Schema model matches your Dev database
- ✅ Ready to generate deployment script (02_Prepare)

## 🐛 Troubleshooting

### "Invalid SQL syntax in schema model file"
**Problem:** SQL file has syntax errors.  
**Solution:**
- Open the file in SSMS or VS Code
- Check SQL syntax
- Test the script in SSMS
- Fix errors and save
- Re-run validation

### "Schema model location not found"
**Problem:** Flyway can't find schema-model folder.  
**Solution:**
- Verify you're in the project root directory
- Check `flyway.toml` has correct path
- Use absolute path: `-model.location=filesystem:C:\path\to\schema-model`

### "Unresolved dependency"
**Problem:** Object references another object that doesn't exist in schema model.  
**Solution:**
- Add the missing object to schema model
- Or remove the reference if object shouldn't exist
- Verify spelling of object names

### "Schema model doesn't match Dev database"
**Problem:** `flyway diff -diff.target=build` shows differences.  
**Solution:**
- Capture recent changes from Dev into schema model
- Use Flyway Desktop to sync
- Or manually update affected .sql files

## 💡 Best Practices

### Always Validate Before Deploying ✅
```powershell
# Good workflow
flyway model -model.location=filesystem:schema-model
# Only proceed to 02_Prepare if validation passes
```

### Keep Schema Model in Sync with Dev ✅
```powershell
# After making changes in Dev, capture them immediately
flyway diff -diff.source=build -diff.target=schemaModel
# Update schema model as needed
```

### Use Descriptive File Names ✅
```
✅ Good:
  Sales.Campaigns.sql
  Logistics.GetUpcomingFlights.sql

❌ Bad:
  table1.sql
  proc.sql
```

### Organize by Object Type ✅
```
schema-model/
  Tables/          # All tables here
  Views/           # All views here
  Stored Procedures/  # All procedures here
```

## 🎓 Key Concepts Learned

- **Schema Model Validation:** Ensuring model is deployment-ready
- **SQL Syntax Checking:** Finding errors before deployment
- **Dependency Resolution:** Understanding object relationships
- **Model Synchronization:** Keeping model in sync with Dev
- **State-Based Workflow:** Model-driven approach to deployments

## 🚀 Real-World Applications

- **Pre-Deployment Checks:** Catch errors before deployment attempts
- **Code Quality:** Ensure SQL follows standards
- **Dependency Management:** Understand complex object relationships
- **Team Coordination:** Ensure everyone's changes are captured
- **Audit Trail:** Schema model provides version-controlled history

## 📚 Helper Files Reference

See the [Flyway Helper Files](https://github.com/RG-AutoPilot/Flyway-Helper-Files) repository:
- `CLI/State/MSSQL_PowerShell/01_Model.ps1` - Complete model validation script
- Shows error handling patterns
- Demonstrates automated validation workflows

## 🌟 Advanced Tips (Optional)

### Validate Multiple Schema Models
```powershell
# If you have multiple schemas/projects
flyway model -model.location=filesystem:schema-model-sales
flyway model -model.location=filesystem:schema-model-logistics
```

### Automated Validation in CI/CD
```powershell
# In your build pipeline
flyway model -model.location=filesystem:schema-model
if ($LASTEXITCODE -ne 0) {
    Write-Error "Schema model validation failed"
    exit 1
}
```

### Generate Model Documentation
```powershell
# Create schema model report
flyway model `
    -model.location=filesystem:schema-model `
    | Out-File -FilePath "docs/schema-model-report.txt"
```

## 📚 Next Steps

Continue with the state-based deployment workflow:

1. **`Operations/00_Diff`** - Compare environments ✅ Completed
2. **`Operations/01_Model`** - Validate schema model ✅ You just completed this!
3. **`Operations/02_Prepare`** ← Next - Generate deployment script
4. **`Operations/03_Deploy`** - Execute deployment

---

**Congratulations!** 🎉 Your schema model is validated and ready for deployment script generation. Proceed to 02_Prepare to create the deployment script.
