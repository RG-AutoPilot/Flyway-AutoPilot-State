# Operations Quest - Snapshot (Create Database Baseline)

**Difficulty:** 🟢 Beginner  
**Time:** 10 minutes  
**Prerequisites:** Access to target database environment

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to create a database schema snapshot
- Why snapshots are critical for drift detection
- How to manage snapshot history
- When to create snapshots in your workflow

## 📖 What is Snapshot?

The `flyway snapshot` command captures the current state of a database schema and stores it for future comparison. Snapshots are stored in a special `snapshotHistory` table in the target database.

**Why Snapshots Matter:**
- **Drift Detection** - Compare current state vs. known-good snapshot
- **Audit Trail** - Track schema changes over time
- **Rollback Reference** - Know what state to return to if needed
- **Compliance** - Document when changes were deployed

---

## 🔧 The Command

### Basic Syntax
```powershell
flyway snapshot `
  -environment=<target-environment> `
  -snapshot.filename=<snapshot-name> `
  -snapshot.historyLimit=<max-snapshots> `
  -workingDirectory=<project-root>
```

### Example from Helper Script
```powershell
# Variables
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
$TARGET_ENVIRONMENT = "Test"

# Create Snapshot and save into snapshotHistory table
flyway snapshot `
  "-environment=$TARGET_ENVIRONMENT" `
  "-snapshot.filename=snapshotHistory:Snapshot-$(get-date -f yyyyMMdd)" `
  "-snapshot.historyLimit=5" `
  -workingDirectory="$WORKING_DIRECTORY"
```

---

## 📋 Parameter Breakdown

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-environment` | Target database to snapshot | `Test`, `Production` |
| `-snapshot.filename` | Snapshot name/location | `snapshotHistory:Snapshot-20260109` |
| `-snapshot.historyLimit` | Max snapshots to keep (auto-cleanup) | `5`, `10` (older ones deleted) |
| `-workingDirectory` | Root directory of Flyway project | `.` |

---

## 🎯 Understanding Snapshot Storage

### snapshotHistory Table
Snapshots are stored in the target database in a special table:
```sql
SELECT * FROM [dbo].[snapshotHistory]
ORDER BY createdAt DESC;
```

### Snapshot Naming Conventions

#### Using snapshotHistory:
```powershell
# Timestamped snapshots (recommended)
-snapshot.filename="snapshotHistory:Snapshot-$(get-date -f yyyyMMdd-HHmmss)"

# Named snapshots
-snapshot.filename="snapshotHistory:BeforeDeployment"
-snapshot.filename="snapshotHistory:Production-Baseline"

# Special keywords
-snapshot.filename="snapshotHistory:current"    # Latest snapshot
-snapshot.filename="snapshotHistory:initial"    # First/baseline snapshot
```

#### Using file system:
```powershell
# Save to file instead of database
-snapshot.filename="Snapshots\test-snapshot-$(get-date -f yyyyMMdd).json"
```

---

## 🔄 Workflow Context

**Snapshot** is typically used at multiple points:

### Before Deployment
```
1. Snapshot (baseline before changes)
2. Deploy (make changes)
3. Snapshot (capture result)
4. Check drift (compare)
```

### Regular Auditing
```
- Daily snapshots (automated)
- Pre/post deployment snapshots
- On-demand snapshots for troubleshooting
```

---

## 💡 Tips & Best Practices

### ✅ DO:
- Create snapshots BEFORE major deployments (safety net)
- Create snapshots AFTER successful deployments (document success)
- Use timestamped snapshot names for clarity
- Set `-snapshot.historyLimit` to prevent unlimited growth
- Automate daily snapshots in production (audit trail)

### ❌ DON'T:
- Don't skip creating an initial snapshot (needed for drift detection)
- Don't use the same snapshot name repeatedly (you'll overwrite it)
- Don't forget to snapshot after deployment (loses audit trail)

---

## 🎯 Common Use Cases

### 1️⃣ Initial Baseline
Create the first snapshot of an environment:
```powershell
flyway snapshot `
  -environment=Production `
  "-snapshot.filename=snapshotHistory:initial" `
  -workingDirectory="."
```

### 2️⃣ Pre-Deployment Snapshot
Capture state before making changes:
```powershell
flyway snapshot `
  -environment=Test `
  "-snapshot.filename=snapshotHistory:Pre-Deploy-$(get-date -f yyyyMMdd-HHmmss)" `
  "-snapshot.historyLimit=10"
```

### 3️⃣ Post-Deployment Snapshot
Document the successful deployment:
```powershell
flyway snapshot `
  -environment=Test `
  "-snapshot.filename=snapshotHistory:Post-Deploy-$(get-date -f yyyyMMdd-HHmmss)" `
  "-snapshot.historyLimit=10"
```

### 4️⃣ Daily Automated Snapshot (CI/CD)
```powershell
flyway snapshot `
  -environment=Production `
  "-snapshot.filename=snapshotHistory:Daily-$(get-date -f yyyyMMdd)" `
  "-snapshot.historyLimit=30"  # Keep 30 days
```

---

## 📊 Snapshot History Management

### View Snapshot History
```sql
-- Connect to target database
SELECT 
    filename,
    createdAt,
    LEN(content) AS SizeInBytes
FROM [dbo].[snapshotHistory]
ORDER BY createdAt DESC;
```

### Automatic Cleanup
When you set `-snapshot.historyLimit=5`, Flyway automatically:
- Keeps the 5 most recent snapshots
- Deletes older snapshots beyond the limit

---

## 🔍 What's Inside a Snapshot?

A snapshot contains:
- **Schema definitions** (tables, views, procedures, functions)
- **Constraints** (primary keys, foreign keys, check constraints)
- **Indexes** (clustered, non-clustered)
- **Permissions** (if configured)
- **Extended properties** (comments, descriptions)

**Note:** Snapshots do NOT include data rows, only schema structure.

---

## 🚀 Try It Yourself

1. Choose a target environment (Test, Production, etc.)
2. Update the `$TARGET_ENVIRONMENT` variable
3. Run the `flyway snapshot` command
4. Verify the snapshot was created:
   ```sql
   SELECT * FROM [dbo].[snapshotHistory] 
   ORDER BY createdAt DESC;
   ```

---

## 🔧 Integration with Other Commands

### Snapshot + Check (Drift Detection)
```powershell
# 1. Create baseline snapshot
flyway snapshot -environment=Test "-snapshot.filename=snapshotHistory:baseline"

# 2. Later, check for drift
flyway check -drift `
  -environment=Test `
  "-check.deployedSnapshot=snapshotHistory:baseline" `
  "-reportFilename=drift-report.html"
```

### Snapshot + Deploy (Automatic)
The Deploy command can automatically create snapshots:
```powershell
flyway deploy `
  -environment=Test `
  "-deploy.scriptFilename=Artifacts\deploy.sql" `
  "-deploy.saveSnapshot=true"  # Auto-snapshot after deployment
```

---

## 📁 Output

After running snapshot:
- **Snapshot stored** in `snapshotHistory` table
- **Console output** confirming success
- **Older snapshots deleted** if over the limit

**Example output:**
```
Creating snapshot of Test environment...
Snapshot saved: snapshotHistory:Snapshot-20260109
Snapshots in history: 5
Deleted old snapshots: 2 (over limit of 5)
```

---

## 📚 Related Commands

- **[Check](../03-Check/Check.md)** - Uses snapshots for drift detection
- **[Deploy](../04-Deploy/Deploy.md)** - Can auto-create snapshots
- **[Diff](../00-Diff/Diff.md)** - Compare current vs snapshot

---

## 📖 Further Reading

- [Flyway Snapshot Documentation](https://documentation.red-gate.com/fd/snapshot-184127501.html)
- [Drift Detection Guide](https://documentation.red-gate.com/fd/drift-184127469.html)

---

**Next Step:** After creating snapshots, use the **Check** quest to detect drift, or integrate snapshots into your deployment workflow!
