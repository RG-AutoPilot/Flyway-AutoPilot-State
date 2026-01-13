# Operations Quest - Check (Validate & Report)

**Difficulty:** 🟡 Intermediate  
**Time:** 15-20 minutes  
**Prerequisites:** Have snapshots or deployment scripts ready

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to validate deployments before executing them
- How to check for drift between environments
- How to analyze code quality issues
- How to generate comprehensive HTML reports

## 📖 What is Check?

The `flyway check` command performs validation and reporting across three key areas:

1. **Changes** - What will be deployed (pending changes)
2. **Drift** - Unauthorized changes in target environment
3. **Code** - Static code analysis (quality, performance, security)

**Output:** Beautiful HTML report showing all findings

---

## 🔧 The Command

### Basic Syntax
```powershell
flyway check -changes -code -drift `
  -check.changesSource=<source-environment> `
  -environment=<target-environment> `
  -check.deployedSnapshot=<snapshot-reference> `
  -check.scope=<scope> `
  -check.scriptFilename=<deployment-script> `
  -reportFilename=<report-output-path>
```

### Example from Helper Script
```powershell
# Variables
$REPORT_FILENAME = "Flyway-Check-All_Report.html"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
$SCRIPT_FILENAME = "Flyway_Deployment_Script.sql"
$SOURCE_ENVIRONMENT = "schemaModel"
$TARGET_ENVIRONMENT = "Test"

# Create Check Report
flyway check -changes -code -drift `
  "-check.changesSource=$SOURCE_ENVIRONMENT" `
  "-environment=$TARGET_ENVIRONMENT" `
  "-check.deployedSnapshot=snapshotHistory:current" `
  "-check.scope=script" `
  "-check.scriptFilename=%temp%\Artifacts\D_$SCRIPT_FILENAME" `
  -configFiles="$WORKING_DIRECTORY\flyway.toml" `
  -workingDirectory="$WORKING_DIRECTORY" `
  "-reportFilename=$WORKING_DIRECTORY\Artifact\$REPORT_FILENAME"
```

---

## 📋 Parameter Breakdown

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-changes` | Check for pending changes to deploy | (flag, no value) |
| `-code` | Run static code analysis | (flag, no value) |
| `-drift` | Check for unauthorized changes | (flag, no value) |
| `-check.changesSource` | Source for changes comparison | `schemaModel` |
| `-environment` | Target environment to validate | `Test`, `Production` |
| `-check.deployedSnapshot` | Snapshot to check drift against | `snapshotHistory:current` |
| `-check.scope` | Scope of analysis: `script` or `all` | `script` (analyze script only) |
| `-check.scriptFilename` | Deployment script to analyze | `Artifacts\deploy.sql` |
| `-reportFilename` | Output path for HTML report | `Reports\check-report.html` |

---

## 🎯 The Three Types of Checks

### 1️⃣ Changes Check
**What it does:** Analyzes what will be deployed
```
✅ Tables added: 2
✅ Views modified: 1
✅ Stored procedures updated: 3
⚠️  High impact changes detected (DROP TABLE)
```

### 2️⃣ Drift Check
**What it does:** Detects unauthorized changes in target database
```
⚠️  Drift detected!
   - Table [Sales].[UnauthorizedTable] exists (not in schema model)
   - Column [Sales].[Customers].[UnplannedColumn] exists
```

### 3️⃣ Code Analysis
**What it does:** Static analysis for quality, performance, security
```
⚠️  Code issues found:
   - Missing index on foreign key column
   - SELECT * used (specify columns)
   - Non-sargable WHERE clause (performance issue)
   - SQL injection risk (dynamic SQL)
```

---

## 🔄 Workflow Context

**Check** is typically **Step 4** in the state-based workflow:

1. **Diff** (compare and create artifact)
2. **Model** (apply changes to schema model)
3. **Prepare** (generate deployment script)
4. **Check** ← You are here (validate before deploying)
5. **Deploy** (execute deployment)

---

## ⚠️ First-Time Setup: Snapshots Required

If this is your first time running check against an environment:

### Create Initial Snapshot
```powershell
# Run the Snapshot quest first
flyway snapshot `
  -environment=Test `
  "-snapshot.filename=snapshotHistory:initial" `
  -workingDirectory="."
```

**Why?** Drift detection needs a baseline snapshot to compare against.

---

## 💡 Tips & Best Practices

### ✅ DO:
- Run check BEFORE deploying to production (catch issues early)
- Review the HTML report thoroughly (don't just skim it)
- Address code analysis warnings (improve quality)
- Use `-check.scope=script` for faster checks (only analyzes deployment script)
- Use `-check.scope=all` for comprehensive analysis (entire schema model)

### ❌ DON'T:
- Don't skip check in your CI/CD pipeline (automate validation)
- Don't ignore drift warnings (investigate unauthorized changes)
- Don't dismiss code analysis issues (they often indicate real problems)

---

## 📊 Understanding the Report

The HTML report includes:

### Changes Section
- **Objects to create** (tables, views, procedures)
- **Objects to modify** (ALTER statements)
- **Objects to drop** (potentially dangerous!)
- **Impact assessment** (low, medium, high)

### Drift Section
- **Extra objects** in target (not in schema model)
- **Missing objects** in target (should exist)
- **Schema differences** (columns, types, constraints)

### Code Analysis Section
- **Performance issues** (missing indexes, non-sargable queries)
- **Security risks** (SQL injection, permissions)
- **Best practice violations** (naming conventions, etc.)
- **Complexity warnings** (overly complex procedures)

---

## 🎯 Common Use Cases

### 1️⃣ Pre-Deployment Validation
```powershell
flyway check -changes -code `
  -check.changesSource=schemaModel `
  -environment=Production `
  "-check.scriptFilename=Artifacts\prod-deploy.sql" `
  "-reportFilename=Reports\pre-deploy-check.html"
```

### 2️⃣ Drift Detection Only
```powershell
flyway check -drift `
  -environment=Production `
  "-check.deployedSnapshot=snapshotHistory:current" `
  "-reportFilename=Reports\drift-check.html"
```

### 3️⃣ Code Quality Audit
```powershell
flyway check -code `
  -check.changesSource=schemaModel `
  "-check.scope=all" `
  "-reportFilename=Reports\code-quality.html"
```

---

## 🚀 Try It Yourself

1. Ensure you have a snapshot (run Snapshot quest if needed)
2. Ensure you have a deployment script (run Prepare if needed)
3. Update the variables for your environment
4. Run the `flyway check` command
5. Open the generated HTML report in a browser
6. Review all sections: Changes, Drift, Code Analysis

---

## 📁 Output

After running check:
- **HTML Report** - Visual report with all findings
- **Console Output** - Summary of issues found
- **Exit Code** - Non-zero if issues detected (useful for CI/CD)

**Open the report:**
```powershell
# Windows
Start-Process "Artifact\Flyway-Check-All_Report.html"

# Or
code "Artifact\Flyway-Check-All_Report.html"
```

---

## 🔧 Troubleshooting

### "Snapshot not found" Error
**Solution:** Run snapshot first:
```powershell
flyway snapshot -environment=Test -snapshot.filename="snapshotHistory:initial"
```

### "No changes detected"
**Possible causes:**
- Schema model matches target database (expected)
- Wrong source/target specified
- `-check.scriptFilename` pointing to empty script

### Code Analysis Shows No Issues
**That's great!** It means your code passes static analysis.

---

## 📚 Related Commands

- **[Snapshot](../03-Snapshot/Snapshot.md)** - Create baseline for drift detection
- **[Prepare](../02-Prepare/Prepare.md)** - Generate the script to check
- **[Deploy](../04-Deploy/Deploy.md)** - Deploy after validation passes

---

## 📖 Further Reading

- [Flyway Check Documentation](https://documentation.red-gate.com/flyway/reference/commands/check)
- [Code Analysis Rules](https://documentation.red-gate.com/flyway/flyway-concepts/code-analysis)
- [Drift Detection Guide](https://documentation.red-gate.com/flyway/flyway-concepts/drift)

---

**Next Step:** After reviewing the check report and addressing any issues, proceed to the **Deploy** quest to execute your deployment!
