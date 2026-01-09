# Operations Quest - Model (Apply Changes to Schema Model)

**Difficulty:** 🟢 Beginner  
**Time:** 10 minutes  
**Prerequisites:** Completed Diff quest, have a diff artifact file

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to apply a diff artifact to your schema model
- What happens to your schema-model files during this process
- How Flyway updates, creates, and deletes files automatically
- Why the schema model is the "source of truth"

## 📖 What is Model?

The `flyway model` command takes a **diff artifact** (created by `flyway diff`) and applies those changes to your **schema-model** folder. This updates your schema model files to match your source database.

**In Simple Terms:**
- **Diff** = "What changed?"
- **Model** = "Update my schema model with those changes"

---

## 🔧 The Command

### Basic Syntax
```powershell
flyway model `
  -model.artifactFilename=<path-to-artifact.zip> `
  -workingDirectory=<project-root>
```

### Example from Helper Script
```powershell
# Variables
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"

flyway model `
  "-model.artifactFilename=$ARTIFACT_FILENAME" `
  -workingDirectory="$WORKING_DIRECTORY"
```

---

## 📋 Parameter Breakdown

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-model.artifactFilename` | Path to the diff artifact to apply | `Artifacts\diff.zip` |
| `-workingDirectory` | Root directory of your Flyway project | `.` |

---

## 🎯 What Happens When You Run Model?

Flyway will automatically:

### ✅ Create New Files
If new objects exist in the source:
```
schema-model/Tables/Sales.NewTable.sql        [CREATED]
schema-model/Views/Sales.NewView.sql          [CREATED]
```

### ✏️ Update Existing Files
If objects were modified:
```
schema-model/Tables/Sales.Customers.sql       [UPDATED]
schema-model/Stored Procedures/Sales.Proc.sql [UPDATED]
```

### 🗑️ Delete Removed Files
If objects were dropped from source:
```
schema-model/Tables/Sales.OldTable.sql        [DELETED]
```

### 🔄 Update Dependencies
If a table changed, dependent views are regenerated:
```
schema-model/Tables/Sales.Orders.sql          [UPDATED]
schema-model/Views/Sales.OrderSummary.sql     [REGENERATED]
```

---

## 🔄 Workflow Context

**Model** is typically **Step 2** in the state-based workflow:

1. **Diff** (compare and create artifact)
2. **Model** ← You are here (apply changes to schema model)
3. **Prepare** (generate deployment script)
4. **Check** (validate changes)
5. **Deploy** (execute deployment)

---

## 💡 Tips & Best Practices

### ✅ DO:
- Commit schema model changes to source control after running `model`
- Review the changes before committing (use `git status` and `git diff`)
- Run `model` immediately after `diff` while the artifact is fresh
- Check that all expected files were created/updated/deleted

### ❌ DON'T:
- Don't manually edit schema model files after running `model` (changes will be overwritten)
- Don't skip reviewing what changed (you might catch issues early)
- Don't use an old or stale artifact file

---

## 📁 Output

After running `flyway model`, you'll see:
- **Console output** showing files created/updated/deleted
- **Modified schema-model files** in your project
- **Git changes** (if using source control)

**Example output:**
```
Applying artifact to schema model...
Created: schema-model/Tables/Sales.LoyaltyTier.sql
Updated: schema-model/Tables/Sales.Customers.sql
Updated: schema-model/Views/Sales.CustomerSummary.sql
Schema model updated successfully.
```

---

## 🔍 Verify the Changes

After running `model`, verify everything looks correct:

```powershell
# Check what files changed
git status

# See the actual changes
git diff

# Review specific files
code schema-model/Tables/Sales.NewTable.sql
```

---

## 🚀 Try It Yourself

1. Run `flyway diff` to create an artifact (or use an existing one)
2. Update the `$ARTIFACT_FILENAME` variable to point to your artifact
3. Run the `flyway model` command
4. Check the `schema-model/` folder for changes
5. Review and commit the changes to source control

---

## 📚 Related Commands

- **[Diff](../00-Diff/Diff.md)** - Create the artifact that Model consumes
- **[Prepare](../02-Prepare/Prepare.md)** - Generate deployment scripts from schema model
- **[Check](../03-Check/Check.md)** - Validate schema model changes

---

## 📖 Further Reading

- [Flyway Model Documentation](https://documentation.red-gate.com/fd/model-184127477.html)
- [Schema Model Concept](https://documentation.red-gate.com/fd/schema-model-184127389.html)

---

**Next Step:** After updating your schema model, proceed to the **Prepare** quest to generate deployment scripts for your target environment!
