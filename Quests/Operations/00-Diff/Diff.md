# Operations Quest - Diff (Compare Environments)

**Difficulty:** 🟢 Beginner  
**Time:** 10-15 minutes  
**Prerequisites:** Flyway Desktop or CLI installed

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to compare two database environments
- How to generate a diff artifact showing differences
- When to use `diff` in your workflow
- Understanding source vs target in comparisons

## 📖 What is Diff?

The `flyway diff` command compares two database states and creates an **artifact file** containing all the differences. This is the first step in capturing changes from a development database to your schema model.

**Common Comparisons:**
- Development database → Schema Model (capture new changes)
- Test database → Production database (see what's different)
- Schema Model → Test database (what needs to be deployed)

---

## 🔧 The Command

### Basic Syntax
```powershell
flyway diff `
  -diff.source=<source-environment> `
  -diff.target=<target-environment> `
  -diff.artifactFilename=<path-to-artifact.zip> `
  -schemaModelLocation=<path-to-schema-model> `
  -workingDirectory=<project-root>
```

### Example from Helper Script
```powershell
# Variables
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
$SOURCE_ENVIRONMENT = "development"
$TARGET_ENVIRONMENT = "schemaModel"

# Calculate the differences
flyway diff `
  "-diff.source=$SOURCE_ENVIRONMENT" `
  "-diff.target=$TARGET_ENVIRONMENT" `
  "-diff.artifactFilename=$ARTIFACT_FILENAME" `
  -schemaModelLocation="$WORKING_DIRECTORY\schema-model" `
  -workingDirectory="$WORKING_DIRECTORY"
```

---

## 📋 Parameter Breakdown

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-diff.source` | The source environment to compare FROM | `development` |
| `-diff.target` | The target environment to compare TO | `schemaModel` |
| `-diff.artifactFilename` | Output file path for the diff artifact | `Artifacts\diff.zip` |
| `-schemaModelLocation` | Path to your schema-model folder | `.\schema-model` |
| `-workingDirectory` | Root directory of your Flyway project | `.` |

---

## 🎯 Common Use Cases

### 1️⃣ Capture Development Changes
Compare your dev database against the schema model to find new objects you've created:
```powershell
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename="Artifacts\dev-changes.zip"
```

### 2️⃣ Compare Two Databases
See what's different between Test and Production:
```powershell
flyway diff `
  -diff.source=test `
  -diff.target=production `
  -diff.artifactFilename="Artifacts\test-vs-prod.zip"
```

### 3️⃣ Check What Will Be Deployed
Compare schema model against a target environment:
```powershell
flyway diff `
  -diff.source=schemaModel `
  -diff.target=test `
  -diff.artifactFilename="Artifacts\pending-deployment.zip"
```

---

## 💡 Tips & Best Practices

### ✅ DO:
- Use timestamped artifact filenames for tracking: `diff-$(get-date -f yyyyMMdd-HHmmss).zip`
- Store artifacts in a dedicated folder (e.g., `Artifacts/`)
- Compare development → schemaModel regularly to capture changes
- Keep artifact files for audit purposes

### ❌ DON'T:
- Don't compare the wrong direction (source/target matter!)
- Don't use the same artifact filename repeatedly (you'll overwrite history)
- Don't skip the diff step before using `model`

---

## 🔄 Workflow Context

**Diff** is typically **Step 1** in the state-based workflow:

1. **Diff** ← You are here (compare and create artifact)
2. **Model** (apply artifact to schema model)
3. **Prepare** (generate deployment script)
4. **Check** (validate changes)
5. **Deploy** (execute deployment)

---

## 📁 Output

After running `flyway diff`, you'll get:
- **Artifact file** (`.zip`) containing all differences
- **Console output** showing summary of changes
- **Exit code** (0 = success, non-zero = error)

**Example output:**
```
Comparing development to schemaModel...
Found differences:
  - 2 new tables
  - 1 modified view
  - 3 new stored procedures
Artifact saved to: Artifacts\diff.zip
```

---

## 🚀 Try It Yourself

1. Open PowerShell in your Flyway project directory
2. Update the variables in the command for your environment
3. Run the `flyway diff` command
4. Check that the artifact file was created
5. Proceed to the **Model** quest to apply the differences!

---

## 📚 Related Commands

- **[Model](../01-Model/Model.md)** - Apply diff artifact to schema model
- **[Prepare](../02-Prepare/Prepare.md)** - Generate deployment scripts
- **[Check](../03-Check/Check.md)** - Validate changes before deployment

---

## 📖 Further Reading

- [Flyway Diff Documentation](https://documentation.red-gate.com/flyway/reference/commands/diff)
- [State-Based Workflow Guide](https://documentation.red-gate.com/flyway/flyway-concepts/state-based-projects)

---

**Next Step:** After creating a diff artifact, proceed to the **Model** quest to apply changes to your schema model!
