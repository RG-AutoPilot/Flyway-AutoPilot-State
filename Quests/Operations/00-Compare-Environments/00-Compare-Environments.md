# Operations Quest 00 - Diff: Compare Environments

**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Prerequisites:** Flyway CLI installed, schema model exists, multiple environments configured

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to use `flyway diff` to compare two environments
- Creating difference artifacts for analysis
- Comparing schema model (desired state) vs. target database (current state)
- Understanding diff output and artifact files
- Identifying schema drift

## 📖 Scenario
You need to identify what schema differences exist between your schema model (desired state) and your Development database (current state). The `flyway diff` command creates an artifact file containing all detected differences, which you'll use in subsequent steps.

## 🎯 Your Mission
Run `flyway diff` to compare the schema model against your Development environment and create a differences artifact.

## 📝 Steps

### Step 1: Understand the Diff Command

**Purpose:**  
`flyway diff` compares two entities (databases, schema models, snapshots) and generates an artifact containing the differences.

**Common Comparisons:**
- Schema Model vs. Development Database (find what's changed locally)
- Development vs. Test (ensure consistency)
- Production vs. Schema Model (detect drift)
- Snapshot vs. Current Database (track changes over time)

### Step 2: Review the Helper Script

The `00_Flyway_State_Diff.ps1` script shows the command structure:

```powershell
flyway diff `
  "-diff.source=development" `
  "-diff.target=schemaModel" `
  "-diff.artifactFilename=%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip" `
  -schemaModelLocation=".\schema-model" `
  -workingDirectory="." `
  -schemaModelSchemas=""
```

**Parameters explained:**
- `-diff.source` - First environment to compare (e.g., development database)
- `-diff.target` - Second environment to compare (e.g., schemaModel)
- `-diff.artifactFilename` - Where to save the differences artifact (ZIP file)
- `-schemaModelLocation` - Path to your schema model folder
- `-workingDirectory` - Project root directory
- `-schemaModelSchemas` - Schemas to include (empty = all configured schemas)

### Step 3: Customize Variables for Your Environment

```powershell
# Set your project paths
$WORKING_DIRECTORY = "C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State"
$ARTIFACT_FILENAME = "$env:TEMP\Artifacts\Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"

# Ensure artifact directory exists
New-Item -ItemType Directory -Path "$env:TEMP\Artifacts" -Force
```

### Step 4: Run the Diff Command

```powershell
# Navigate to project directory
cd $WORKING_DIRECTORY

# Run diff comparing development database to schema model
flyway diff `
  "-diff.source=development" `
  "-diff.target=schemaModel" `
  "-diff.artifactFilename=$ARTIFACT_FILENAME" `
  -schemaModelLocation=".\schema-model" `
  -workingDirectory="." `
  -schemaModelSchemas=""
```

### Step 5: Review Diff Output

**Successful diff output:**
```

Comparing source 'development' to target 'schemaModel'...

Differences detected:
  Tables: 2 differences
    - Sales.Campaigns (exists in source, not in target)
    - Sales.CustomerFeedback (definition mismatch)
  
  Views: 1 difference
    - Sales.CustomerOrdersView (exists in target, not in source)

Artifact created: C:\Users\...\Temp\Artifacts\Flyway.State.Development.differences-20260108.zip
```

**No differences:**
```
Flyway Enterprise Edition 10.x.x

Comparing source 'development' to target 'schemaModel'...

No differences detected.
Environments are in sync.
```

### Step 6: Examine the Artifact File

The artifact is a ZIP file containing:
- Detailed difference report (HTML/JSON)
- SQL scripts showing differences
- Metadata about compared environments

```powershell
# Extract and view artifact
Expand-Archive -Path $ARTIFACT_FILENAME -DestinationPath "$env:TEMP\Artifacts\Extracted" -Force

# View contents
Get-ChildItem "$env:TEMP\Artifacts\Extracted" -Recurse

# Open HTML report (if exists)
& "$env:TEMP\Artifacts\Extracted\differences.html"
```

## ✅ Success Criteria

- ✅ Ran `flyway diff` successfully
- ✅ Artifact file created with differences
- ✅ Understand source vs. target parameters
- ✅ Can interpret diff output
- ✅ Know where artifact is saved
- ✅ Ready to use artifact in next quest (01-Model)

## 🐛 Troubleshooting

### "Flyway diff command not found"
**Problem:** Flyway CLI not installed or not in PATH.  
**Solution:**
```powershell
# Check Flyway installation
flyway -v

# If not found, add Flyway to PATH or use full path
& "C:\Program Files\Flyway\flyway.cmd" diff ...
```

### "Cannot connect to source environment"
**Problem:** Database connection failed.  
**Solution:**
- Verify `flyway.toml` has correct connection string for development
- Test connection: `flyway info -environment=development`
- Check credentials and server availability

### "Schema model location not found"
**Problem:** Can't find schema-model folder.  
**Solution:**
```powershell
# Verify schema model exists
Test-Path ".\schema-model"

# If false, check working directory
Get-Location

# Use absolute path if needed
-schemaModelLocation="C:\Full\Path\To\schema-model"
```

### "Artifact directory doesn't exist"
**Problem:** Can't write artifact file.  
**Solution:**
```powershell
# Create artifact directory
New-Item -ItemType Directory -Path "$env:TEMP\Artifacts" -Force
```

## 💡 Best Practices

### Use Timestamped Artifact Names ✅
```powershell
$ARTIFACT_FILENAME = "$env:TEMP\Artifacts\Diff-Dev-$(get-date -f yyyyMMdd-HHmmss).zip"
# Creates: Diff-Dev-20260108-143022.zip
```

### Store Artifacts for Audit Trail ✅
```powershell
# Don't use %temp% for important diffs
$ARTIFACT_FILENAME = ".\Artifacts\Diff-Development-$(get-date -f yyyyMMdd).zip"
```

### Compare Before Major Changes ✅
```
Daily workflow:
1. Run diff before starting work
2. Verify no unexpected differences
3. Make your changes
4. Run diff again to see your changes
```

### Document What You're Comparing ✅
```powershell
# Clear variable names
$SOURCE = "development"  # Current dev database state
$TARGET = "schemaModel"  # Desired state from Git

flyway diff -diff.source=$SOURCE -diff.target=$TARGET ...
```

## 🎓 Key Concepts Learned

- **Diff Operation:** Comparing two database states
- **Artifact Files:** Packaged difference reports
- **Source vs. Target:** Understanding comparison direction
- **Schema Model Comparison:** Desired state vs. current state
- **Drift Detection:** Identifying unexpected changes

## 🚀 Real-World Applications

- **Daily Development:** Verify your changes before committing
- **Environment Validation:** Ensure Test matches expected state
- **Drift Detection:** Find unauthorized production changes
- **Change Review:** Generate reports for code reviews
- **Deployment Planning:** Identify what will be deployed

## 📚 Common Diff Scenarios

### Compare Two Databases
```powershell
flyway diff `
  "-diff.source=development" `
  "-diff.target=test" `
  "-diff.artifactFilename=.\Artifacts\Dev-vs-Test.zip"
```

### Compare Database to Schema Model (Most Common)
```powershell
flyway diff `
  "-diff.source=development" `
  "-diff.target=schemaModel" `
  "-diff.artifactFilename=.\Artifacts\Dev-vs-Model.zip" `
  -schemaModelLocation=".\schema-model"
```

### Compare Against Snapshot
```powershell
flyway diff `
  "-diff.source=production" `
  "-diff.target=snapshotHistory:baseline" `
  "-diff.artifactFilename=.\Artifacts\Prod-Drift.zip"
```

## 📚 Next Steps

Now that you have a differences artifact, proceed to:

**Quest 01: Model** - Capture the differences into your schema model

---

**Congratulations!** 🎉 You've learned how to compare environments and create difference artifacts!
