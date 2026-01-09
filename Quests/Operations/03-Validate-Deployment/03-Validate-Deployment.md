# Operations Quest 03 - Snapshot and Check: Validate Before Deployment

**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Prerequisites:** Target environment accessible, deployment scripts from Quest 02

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to use `flyway snapshot` to capture database state
- Creating baseline snapshots for drift detection
- Using `flyway check` to analyze changes, drift, and code quality
- Interpreting check reports (HTML output)
- Validating deployment safety before execution
- Understanding snapshot history management

## 📖 Scenario
Before deploying changes to Test environment, you want to:
1. **Snapshot** - Capture current Test database state for comparison
2. **Check** - Analyze what will change, detect drift, and validate code quality

This provides a safety checkpoint and comprehensive impact analysis before executing the deployment.

## 🎯 Your Mission
Create a snapshot of Test environment and run comprehensive checks to validate the upcoming deployment.

## 📝 Steps

### Step 1: Understand Snapshot and Check Commands

**`flyway snapshot`:**
- Captures complete database schema state
- Stores snapshot in `snapshotHistory` table in target database
- Used for drift detection and point-in-time comparison
- Maintains history of schema changes

**`flyway check`:**
- Analyzes changes between current state and deployment target
- Detects schema drift (unexpected changes)
- Performs code analysis for best practices
- Generates HTML report with comprehensive findings

**Workflow:**
```
1. flyway snapshot → Save current state
2. flyway check    → Analyze changes, drift, code quality
3. Review report   → Validate deployment safety
4. flyway deploy   → Execute deployment (Quest 04)
```

---

## Part A: Snapshot

### Step 2: Review the Snapshot Helper Script

The `03a_Flyway_State_Snapshot.ps1` script shows:

```powershell
flyway snapshot Test `
  "-snapshot.filename=Snapshot_$(get-date -f yyyyMMdd-HHmmss)" `
  "-snapshot.historyLimit=5" `
  -workingDirectory="."
```

**Parameters explained:**
- `Test` - Target environment to snapshot
- `-snapshot.filename` - Name for this snapshot (stored in snapshotHistory table)
- `-snapshot.historyLimit=5` - Keep last 5 snapshots (auto-delete older ones)
- `-workingDirectory` - Project root directory

### Step 3: Create a Snapshot

```powershell
# Set variables
$WORKING_DIRECTORY = "C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State"
$TIMESTAMP = Get-Date -Format "yyyyMMdd-HHmmss"
$SNAPSHOT_NAME = "Snapshot_$TIMESTAMP"

# Navigate to project
cd $WORKING_DIRECTORY

# Create snapshot of Test environment
flyway snapshot Test `
  "-snapshot.filename=$SNAPSHOT_NAME" `
  "-snapshot.historyLimit=5" `
  -workingDirectory="."
```

### Step 4: Review Snapshot Output

**Successful snapshot:**
```
Flyway Enterprise Edition 10.x.x

Connecting to Test environment...
Connected to: AutopilotTest (SQL Server 16.0)

Creating snapshot: Snapshot_20260108-143530

Capturing schema objects:
  Tables: 18 objects captured
  Views: 7 objects captured
  Stored Procedures: 5 objects captured
  Functions: 2 objects captured
  Schemas: 4 objects captured

Snapshot created successfully.
Snapshot ID: Snapshot_20260108-143530
Stored in: [dbo].[snapshotHistory]

Snapshot history (5 snapshots maintained):
  1. Snapshot_20260108-143530 (current)
  2. Snapshot_20260107-093015
  3. Snapshot_20260106-152240
  4. Snapshot_20260105-110825
  5. Snapshot_20260104-164512
```

### Step 5: Verify Snapshot in Database

```powershell
# Connect to Test database and query snapshot history
$QUERY = @"
SELECT TOP 5
    snapshot_id,
    snapshot_date,
    snapshot_description,
    object_count
FROM [dbo].[snapshotHistory]
ORDER BY snapshot_date DESC;
"@

# Execute query (if you have SQL tools)
# Or use Flyway:
flyway info -environment=Test
```

**Or manually in SSMS:**
1. Connect to Test database
2. Query: `SELECT * FROM dbo.snapshotHistory ORDER BY snapshot_date DESC`
3. Verify your snapshot exists

---

## Part B: Check

### Step 6: Review the Check Helper Script

The `03b_Flyway_State_Check.ps1` script shows:

```powershell
flyway check -changes -code -drift Test `
  -workingDirectory="."
```

**Important Note from Script:**
```powershell
# First time running this?
# You must run 03a (snapshot) first to create a baseline!
# The check command needs a snapshot to compare against.
```

**Parameters explained:**
- `-changes` - Analyze what will change in upcoming deployment
- `-code` - Perform code analysis for best practices
- `-drift` - Detect schema drift (unexpected changes since last snapshot)
- `Test` - Target environment to check
- `-workingDirectory` - Project root directory

### Step 7: Run Check Command

```powershell
# Navigate to project
cd $WORKING_DIRECTORY

# Run comprehensive check
flyway check -changes -code -drift Test `
  -workingDirectory="."
```

### Step 8: Review Check Output

**Successful check:**
```
Flyway Enterprise Edition 10.x.x

Connecting to Test environment...
Connected to: AutopilotTest (SQL Server 16.0)

Running checks:
  ✓ Changes analysis
  ✓ Code analysis
  ✓ Drift detection

--- CHANGES ANALYSIS ---
Comparing schemaModel to Test environment...

Changes to be applied:
  Tables: 2 changes
    + Sales.Campaigns (will be created)
    ~ Sales.CustomerFeedback (will be altered - column added)
  
  Stored Procedures: 1 change
    ~ Sales.SalesByCategory (will be modified)

Impact Assessment:
  ✓ No data loss detected
  ✓ All changes are additive
  ⚠ Warning: New column Sales.CustomerFeedback.Rating is nullable

--- CODE ANALYSIS ---
Analyzing SQL code quality...

Findings:
  ✓ No syntax errors
  ✓ Naming conventions followed
  ⚠ Warning: Stored procedure Sales.SalesByCategory missing error handling
  ⚠ Info: Consider adding indexes for new table Sales.Campaigns

--- DRIFT DETECTION ---
Comparing Test to last snapshot (Snapshot_20260108-143530)...

Drift detected:
  ⚠ Table Sales.CustomerFeedback.Email column modified (length changed from 100 to 150)
  ℹ This change is not in schema model

No critical issues found.
Report generated: C:\Users\...\flyway-check-report-20260108-143820.html
```

### Step 9: Review the HTML Report

Flyway generates a comprehensive HTML report:

```powershell
# Find the report
$REPORT = Get-ChildItem -Path $env:TEMP -Filter "flyway-check-report-*.html" | 
          Sort-Object LastWriteTime -Descending | 
          Select-Object -First 1

# Open in browser
Start-Process $REPORT.FullName

# Or open in VS Code
code $REPORT.FullName
```

**HTML Report Contents:**

1. **Executive Summary**
   - Overall risk level (Low/Medium/High)
   - Total changes count
   - Drift issues found
   - Code quality score

2. **Changes Detail**
   - Object-by-object breakdown
   - Before/after comparison
   - Impact assessment
   - Data loss warnings

3. **Drift Analysis**
   - Unexpected schema changes
   - Comparison to last snapshot
   - Root cause identification

4. **Code Analysis**
   - Best practices violations
   - Performance recommendations
   - Security concerns
   - Naming convention issues

5. **Recommendations**
   - Actions before deployment
   - Suggested improvements
   - Risk mitigation strategies

### Step 10: Interpret Check Results

**Risk Levels:**

✅ **Low Risk (Green):**
- Only additive changes (new objects, new columns)
- No data loss
- No drift detected
- Code quality passes

➡️ **Action:** Safe to deploy

---

⚠️ **Medium Risk (Yellow):**
- Column modifications
- Minor drift detected
- Code quality warnings
- Nullable columns added

➡️ **Action:** Review warnings, verify acceptable, then deploy

---

🛑 **High Risk (Red):**
- DROP TABLE/COLUMN detected
- Data loss warnings
- Significant drift
- Critical code issues
- Breaking changes

➡️ **Action:** DO NOT DEPLOY until issues resolved!

### Step 11: Save Report for Documentation

```powershell
# Copy report to project for audit trail
$REPORT_FOLDER = ".\Artifacts\Releases\v1.2\Reports"
New-Item -ItemType Directory -Path $REPORT_FOLDER -Force

Copy-Item $REPORT.FullName -Destination "$REPORT_FOLDER\check-report.html"

# Commit to Git
git add .\Artifacts\Releases\v1.2\Reports\
git commit -m "docs(release): Add v1.2 check report"
```

## ✅ Success Criteria

- ✅ Created snapshot of Test environment
- ✅ Snapshot stored in snapshotHistory table
- ✅ Ran `flyway check -changes -code -drift` successfully
- ✅ Reviewed HTML check report
- ✅ Understand risk level of deployment
- ✅ Validated deployment safety
- ✅ Ready to deploy (if checks pass) or fix issues (if checks fail)

## 🐛 Troubleshooting

### "snapshotHistory table not found"
**Problem:** First time running snapshot on this database.  
**Solution:**
```
This is normal! Flyway will create the snapshotHistory table automatically.
Just run the snapshot command - it will create the table and store the first snapshot.
```

### "Cannot detect drift - no baseline snapshot"
**Problem:** Running check -drift before creating first snapshot.  
**Solution:**
```powershell
# Create snapshot first (03a)
flyway snapshot Test -snapshot.filename="Baseline" -workingDirectory="."

# Then run check (03b)
flyway check -changes -code -drift Test -workingDirectory="."
```

### "Check report shows high risk but I expected low risk"
**Problem:** Unexpected findings in check report.  
**Solution:**
```powershell
# Review each category:

# 1. Changes analysis - Are these expected?
#    → Review deployment script from Quest 02

# 2. Drift detection - Why did schema change?
#    → Someone modified Test directly (not through Flyway)
#    → Fix: Capture drift to schema model using Quest 00-Diff + 01-Model

# 3. Code analysis - Can these be fixed?
#    → Update schema model objects
#    → Regenerate deployment script
```

### "Snapshot limit exceeded"
**Problem:** Want to keep more than 5 snapshots.  
**Solution:**
```powershell
# Increase history limit
flyway snapshot Test `
  -snapshot.filename="Snapshot_$(get-date -f yyyyMMdd-HHmmss)" `
  -snapshot.historyLimit=10 `
  -workingDirectory="."
```

## 💡 Best Practices

### Take Snapshots Before Major Changes ✅
```powershell
# Before deployment
flyway snapshot Production -snapshot.filename="Pre-Release-v1.2"

# Deploy changes
flyway deploy Production ...

# After deployment
flyway snapshot Production -snapshot.filename="Post-Release-v1.2"
```

### Run Full Checks Every Time ✅
```
Always use all three flags:
  -changes  → What will change
  -code     → Code quality
  -drift    → Unexpected changes

Don't skip any! Each provides critical safety information.
```

### Review Reports with Your Team ✅
```
Share check reports before production deployments:
1. Generate check report
2. Email to team/manager
3. Review findings together
4. Get approval before deploying
```

### Create Named Snapshots for Releases ✅
```powershell
# Not just timestamps - use meaningful names
flyway snapshot Production -snapshot.filename="Release-v1.2-PreDeploy"
flyway snapshot Production -snapshot.filename="Release-v1.2-PostDeploy"
flyway snapshot Production -snapshot.filename="Quarterly-Baseline-Q1-2026"
```

### Document Drift Immediately ✅
```
If drift detected:
1. Identify who/what made the change
2. Document why (change request, hotfix, etc.)
3. Capture to schema model if valid
4. Or revert if unauthorized
```

## 🎓 Key Concepts Learned

- **Snapshot:** Point-in-time schema state capture
- **Drift Detection:** Finding unexpected schema changes
- **Changes Analysis:** Understanding deployment impact
- **Code Analysis:** Automated quality checks
- **Risk Assessment:** Determining deployment safety
- **Check Reports:** Comprehensive impact documentation

## 🚀 Real-World Applications

- **Pre-Production Validation:**
  ```
  Friday: Generate deployment scripts (Quest 02)
  Friday: Run checks (Quest 03)
  Weekend: Review check report with team
  Monday: Deploy if checks pass (Quest 04)
  ```

- **Drift Detection in Production:**
  ```
  Weekly: Run snapshot
  Weekly: Run check -drift
  If drift found: Investigate and remediate
  ```

- **Release Documentation:**
  ```
  Each release includes:
  - Deployment script (Quest 02)
  - Undo script (Quest 02)
  - Check report (Quest 03) ← Proof of safety validation
  - Deployment log (Quest 04)
  ```

- **Compliance/Audit Requirements:**
  ```
  Snapshots provide:
  - Historical schema states
  - Point-in-time recovery
  - Audit trail of changes
  - Compliance evidence
  ```

## 📚 Check Command Variations

### Changes Only (Quick Check)
```powershell
flyway check -changes Test
# Only shows what will change (fastest)
```

### Drift Only (Monitoring)
```powershell
flyway check -drift Production
# Only detects unauthorized changes
```

### Code Analysis Only (Quality Gate)
```powershell
flyway check -code Test
# Only checks SQL code quality
```

### Full Check (Recommended)
```powershell
flyway check -changes -code -drift Test
# Comprehensive analysis (use this!)
```

### Check Against Specific Snapshot
```powershell
flyway check -drift Test -check.driftAgainstSnapshot="Release-v1.1-PostDeploy"
# Compare to specific snapshot instead of latest
```

## 🔄 Integration with CI/CD

**Automated Pipeline:**
```yaml
# Example Azure DevOps pipeline step
- task: PowerShell@2
  displayName: 'Flyway Check'
  inputs:
    script: |
      flyway check -changes -code -drift Test
      
      # Fail pipeline if high risk detected
      if ($LASTEXITCODE -gt 0) {
        Write-Error "Flyway check failed - deployment blocked"
        exit 1
      }
```

## 📚 Snapshot Management

### View Snapshot History
```sql
-- Connect to target database
SELECT 
    snapshot_id,
    snapshot_date,
    snapshot_description,
    created_by,
    object_count
FROM [dbo].[snapshotHistory]
ORDER BY snapshot_date DESC;
```

### Delete Old Snapshots Manually
```sql
-- Remove specific snapshot
DELETE FROM [dbo].[snapshotHistory]
WHERE snapshot_id = 'Snapshot_20260101-120000';
```

### Export Snapshot for Backup
```powershell
# Snapshots are stored in database
# To backup, export the snapshotHistory table
# Or include in database backup strategy
```

## 📚 Next Steps

Now that you've validated deployment safety, proceed to:

**Quest 04: Deploy** - Execute the deployment script against Test environment

---

**Congratulations!** 🎉 You've learned how to validate deployments using snapshots and checks!
