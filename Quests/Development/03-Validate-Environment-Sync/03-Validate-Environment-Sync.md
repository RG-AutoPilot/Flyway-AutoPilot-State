# Development Quest 03 - Validate Environment Sync

**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Prerequisites:** Completed Quest 02 (Configure Flyway Desktop), Flyway Desktop connected to dev database

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to verify your development database is in sync with the schema model
- Understanding what "in sync" means in a state-based workflow
- Critical importance of sync validation, especially without Autopilot setup
- Recognizing common causes of mismatch
- How to resolve drift between database and schema model
- Using Flyway Desktop to compare and synchronize

## 📖 Scenario
You've joined a project mid-stream and cloned the repository containing the schema model. However, your development database was created weeks ago and may have diverged from the team's schema model. Before you start making changes, you **must** verify that your dev database matches the schema model exactly. If they're out of sync, your captured changes will include unexpected differences, potentially breaking the build or causing deployment issues.

**⚠️ CRITICAL:** This is especially important if Flyway Autopilot was NOT used to set up your database. Manual database setups often drift from the schema model.

## 🎯 Your Mission
Verify that your development database is in perfect sync with the schema model, and if not, synchronize them.

## 📋 What Does "In Sync" Mean?

**In Sync (✅ Good):**
- Every object in schema model exists in dev database
- Every object in dev database exists in schema model (or is filtered out)
- Object definitions match exactly (same columns, types, constraints, etc.)
- Flyway Desktop shows **"No differences detected"** or similar

**Out of Sync (⚠️ Problem):**
- Objects in database but not in schema model (manual additions)
- Objects in schema model but not in database (missing from dev)
- Object definitions differ (someone modified database directly)
- Flyway Desktop shows pending changes you didn't make

## 📝 Steps

### Step 1: Understand Common Causes of Mismatch

**Why databases drift from schema models:**

1. **Manual Changes** - Developer created tables directly in DB without capturing
2. **Stale Database** - Dev database not updated after pulling latest schema model
3. **Filtered Objects** - System/vendor tables not excluded from comparison
4. **Branch Switching** - Switched Git branches without updating dev database
5. **Initial Setup** - Fresh database never synchronized with schema model
6. **Incomplete Autopilot** - Autopilot setup partially completed

### Step 2: Perform Comparison in Flyway Desktop

1. **Open Flyway Desktop**

2. **Select the Development Environment**
   - Ensure you're connected to your dev database
   - Verify connection indicator shows "Connected"

3. **Navigate to Comparison/Diff View**
   - Look for **"Compare"**, **"Diff"**, or **"Schema Compare"** option
   - Select **Source:** Schema Model
   - Select **Target:** Development Database

4. **Run the Comparison**
   - Click **"Compare"** or **"Generate Diff"**
   - Flyway Desktop analyzes differences

5. **Review the Results**

   **Scenario A: No Differences (✅ Perfect!)**
   ```
   ✓ No differences detected
   Database is in sync with schema model
   ```
   → You're good to go! Skip to Success Criteria.

   **Scenario B: Differences Found (⚠️ Action Required)**
   ```
   Differences detected:
   - 3 objects in database not in schema model
   - 2 objects in schema model not in database
   - 1 object definition mismatch
   ```
   → Proceed to Step 3

### Step 3: Analyze the Differences

Flyway Desktop will show differences in categories:

**Category 1: Objects in Database but NOT in Schema Model**
```
- Sales.TempTestTable (Table)
- dbo.OldProcedure (Stored Procedure)
```

**Possible Causes:**
- You or someone created these manually for testing
- Leftover from old development work
- System/vendor objects not properly filtered

**Action:** Decide to either:
- **DROP** them from database (if temporary/test objects)
- **CAPTURE** them into schema model (if they should be tracked)
- **FILTER** them out (if system/vendor objects)

**Category 2: Objects in Schema Model but NOT in Database**
```
- Logistics.Flight (Table)
- Sales.CustomerOrdersView (View)
```

**Possible Causes:**
- Fresh database never deployed with schema model
- You haven't pulled latest schema model changes
- Someone added objects to schema model but you haven't synchronized

**Action:**
- **DEPLOY** schema model to database to add missing objects

**Category 3: Object Definition Mismatch**
```
- Sales.Customers (Table)
  - Database has column: Phone (NVARCHAR(20))
  - Schema model has: Phone (NVARCHAR(50))
```

**Possible Causes:**
- Someone modified database directly without capturing
- Schema model updated but database not synchronized
- Merge conflict resolved in Git but not reflected in database

**Action:**
- **Decide** which is correct (database or schema model)
- **Update** the incorrect one to match

### Step 4: Resolve the Differences

**Option A: Synchronize Database to Match Schema Model (Most Common)**

This makes your dev database match the team's schema model.

1. **In Flyway Desktop:**
   - Review the changes that will be applied
   - Ensure no important data will be lost
   - Click **"Synchronize"** or **"Deploy to Development"**

2. **Flyway generates and executes:**
   ```sql
   -- Creates missing objects
   CREATE TABLE Logistics.Flight (...);
   
   -- Drops extra objects
   DROP TABLE Sales.TempTestTable;
   
   -- Alters mismatched objects
   ALTER TABLE Sales.Customers 
   ALTER COLUMN Phone NVARCHAR(50);
   ```

3. **Verify synchronization succeeded:**
   - Re-run comparison
   - Should now show "No differences"

**Option B: Capture Database Changes into Schema Model (Less Common)**

Only use this if your database has legitimate changes that should be preserved.

1. **Review changes carefully** - Are these intended?
2. **Capture to schema model** - Use Flyway Desktop's capture feature
3. **Commit the updated schema model** - Push to Git
4. **Coordinate with team** - Ensure this doesn't conflict with others' work

**⚠️ Warning:** This approach can create conflicts if others are working in parallel.

**Option C: Filter Out System/Vendor Objects**

If differences are system or vendor objects that shouldn't be tracked:

1. **Configure filters** (covered in Quest 09)
2. **Re-run comparison with filters applied**
3. **Differences should disappear**

### Step 5: Verify Final Sync Status

After resolving differences:

1. **Run comparison again in Flyway Desktop**
   ```
   Source: Schema Model
   Target: Development Database
   ```

2. **Expected Result:**
   ```
   ✓ No differences detected
   Environments are in sync
   ```

3. **Test database functionality:**
   ```sql
   -- Verify key tables exist
   SELECT * FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_SCHEMA IN ('Sales', 'Logistics', 'Operation')
   ORDER BY TABLE_SCHEMA, TABLE_NAME;
   
   -- Test data access
   SELECT TOP 5 * FROM Sales.Customers;
   ```

### Step 6: Document Your Baseline

Create a record of your synchronized state:

```powershell
# In your project directory
$syncReport = @"
Development Environment Sync Report
=====================================
Date: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
Developer: $env:USERNAME
Database: AutopilotDev
Server: localhost

Sync Status: ✓ VERIFIED IN SYNC

Schema Model Commit: $(git rev-parse HEAD)
Branch: $(git rev-parse --abbrev-ref HEAD)

Total Objects in Sync:
- Tables: $(sqlcmd -S localhost -d AutopilotDev -Q "SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0" -h -1)
- Views: $(sqlcmd -S localhost -d AutopilotDev -Q "SELECT COUNT(*) FROM sys.views WHERE is_ms_shipped = 0" -h -1)
- Procedures: $(sqlcmd -S localhost -d AutopilotDev -Q "SELECT COUNT(*) FROM sys.procedures WHERE is_ms_shipped = 0" -h -1)

Next Steps:
- Ready to begin development work
- Can safely capture new changes
- Database matches team's schema model
=====================================
"@

Write-Host $syncReport
```

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Ran comparison in Flyway Desktop between schema model and dev database
- ✅ Understood all detected differences and their causes
- ✅ Resolved all differences (synchronized database to schema model)
- ✅ Re-verified and confirmed "No differences detected"
- ✅ Understand the importance of maintaining sync
- ✅ Know how to check sync status before starting new work
- ✅ Documented your baseline sync state

## 🐛 Troubleshooting

### "Flyway Desktop shows hundreds of differences"
**Problem:** Overwhelming number of differences, mostly system objects.  
**Solution:**
- Configure filters to exclude system schemas (sys, INFORMATION_SCHEMA, etc.)
- See Quest 09: Filtering for detailed instructions
- Common filters:
  ```
  Exclude schemas: sys, INFORMATION_SCHEMA, guest, db_%
  Include schemas: Sales, Logistics, Operation, Customers
  ```

### "Comparison fails with timeout error"
**Problem:** Database too large, comparison takes too long.  
**Solution:**
- Increase timeout in Flyway Desktop settings
- Use schema filtering to reduce comparison scope
- Check database performance and connectivity

### "Not sure if I should keep database or schema model version"
**Problem:** Database and schema model differ, unsure which is correct.  
**Solution:**
- **Check Git history:**
  ```powershell
  git log -- schema-model/Tables/Sales.Customers.sql
  ```
- **Ask your team:** "Which is the source of truth right now?"
- **Default:** Schema model is usually correct (it's version controlled)

### "After synchronizing, application breaks"
**Problem:** Synchronized database but app doesn't work.  
**Solution:**
- Check for missing static/reference data (covered in Quest 07)
- Verify stored procedures and functions work
- Review error logs for specific issues
- Rollback database from backup if needed

### "Differences keep appearing after synchronization"
**Problem:** Can't achieve "no differences" state.  
**Solution:**
- Check for timestamp or identity column differences (may be expected)
- Verify filtering is applied consistently
- Look for computed columns or default values generating differently
- Check for collation differences

## 💡 Best Practices

### Always Validate Sync Before Starting Work ✅
```powershell
# Daily routine:
git pull origin develop
# Open Flyway Desktop
# Run comparison
# Sync if needed
# Now safe to make changes
```

### Sync After Every Git Pull ✅
```powershell
git pull
# Check for schema-model changes:
git diff HEAD@{1} -- schema-model/

# If schema-model changed, synchronize database in Flyway Desktop
```

### Create Baseline Backups ✅
```sql
-- After successful sync, backup your dev database
BACKUP DATABASE AutopilotDev
TO DISK = 'C:\Backups\AutopilotDev_Baseline.bak'
WITH INIT, COMPRESSION;
```

### Don't Skip Validation ❌
Even if you "think" you're in sync, verify:
- After cloning project
- After switching branches
- After pulling latest changes
- Before capturing new changes
- Weekly (at minimum)

## 🎓 Key Concepts Learned

- **Database Drift:** How and why databases diverge from schema models
- **Synchronization:** Bringing database and schema model into alignment
- **Source of Truth:** Schema model is the canonical definition
- **Comparison Tools:** Using Flyway Desktop to detect differences
- **Validation Workflow:** Critical step before development work

## 🚀 Real-World Applications

- **Team Collaboration:** Everyone working from same baseline
- **Onboarding:** New developers get synchronized quickly
- **Deployment Confidence:** Know your changes are clean and isolated
- **Troubleshooting:** Identify when drift is causing issues
- **Quality Assurance:** Prevent "works on my machine" problems

## ⚠️ Critical Warning

**NEVER skip this validation if Flyway Autopilot was not used!**

Manual database setups are notorious for drift:
- Developer creates test tables and forgets
- Someone runs scripts directly against database
- Database restored from backup that doesn't match schema model
- Team switched to Flyway mid-project with existing databases

**One unsynchronized developer can pollute the schema model with unintended changes!**

## 📚 Next Steps

Now that your development environment is verified in sync, proceed to:

**Quest 04: Capture New Changes** - Make your first schema change and capture it into the schema model

---

**Congratulations!** 🎉 You've validated that your development environment is in sync and understand the critical importance of this step in state-based workflows!
