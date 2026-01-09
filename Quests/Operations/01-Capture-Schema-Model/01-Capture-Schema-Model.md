# Operations Quest 01 - Model: Capture Differences to Schema Model

**Difficulty:** 🟡 Intermediate  
**Time:** 15-20 minutes  
**Prerequisites:** Completed Quest 00-Diff, differences artifact exists

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to use `flyway model` to update your schema model
- Capturing differences from artifacts into version control
- Updating schema model files automatically
- Understanding the model command workflow
- Maintaining schema model accuracy

## 📖 Scenario
You ran `flyway diff` in Quest 00 and created an artifact containing differences between your Development database and schema model. Now you need to capture those changes into your schema model so they can be committed to Git and deployed to other environments.

## 🎯 Your Mission
Use `flyway model` to read the differences artifact and update your schema model files automatically.

## 📝 Steps

### Step 1: Understand the Model Command

**Purpose:**  
`flyway model` reads a differences artifact and updates your schema model files to reflect those changes. This keeps your schema model in sync with your development database.

**Workflow:**
```
Quest 00 (Diff):  Dev DB → flyway diff → Artifact
Quest 01 (Model): Artifact → flyway model → Schema Model Updated
```

The model command:
- Reads the artifact from Quest 00
- Analyzes what changed
- Updates files in `schema-model/` folder
- Creates/modifies/deletes SQL files as needed

### Step 2: Review the Helper Script

The `01_Flyway_State_Model.ps1` script shows the command structure:

```powershell
flyway model `
  "-model.artifactFilename=%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip" `
  -workingDirectory="."
```

**Parameters explained:**
- `-model.artifactFilename` - Path to the artifact created by `flyway diff`
- `-workingDirectory` - Project root directory (where `flyway.toml` and `schema-model/` folder exist)

**That's it!** The model command is simple - it just needs to know where the artifact is.

### Step 3: Verify Prerequisites

Before running model, ensure:

```powershell
# 1. Artifact exists from Quest 00
$ARTIFACT_FILENAME = "$env:TEMP\Artifacts\Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"
Test-Path $ARTIFACT_FILENAME  # Should return True

# 2. Schema model folder exists
Test-Path ".\schema-model"  # Should return True

# 3. You're in the project root
Get-Location  # Should show: C:\Users\...\Flyway-AutoPilot-State
```

### Step 4: Run the Model Command

```powershell
# Set variables
$WORKING_DIRECTORY = "C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State"
$ARTIFACT_FILENAME = "$env:TEMP\Artifacts\Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"

# Navigate to project
cd $WORKING_DIRECTORY

# Capture differences to schema model
flyway model `
  "-model.artifactFilename=$ARTIFACT_FILENAME" `
  -workingDirectory="."
```

### Step 5: Review Model Output

**Successful model capture:**
```
Flyway Enterprise Edition 10.x.x

Reading artifact: C:\Users\...\Temp\Artifacts\Flyway.State.Development.differences-20260108.zip

Processing differences...
  Tables: 2 objects updated
    + Sales.Campaigns.sql (created)
    ~ Sales.CustomerFeedback.sql (modified)
  
  Views: 1 object updated
    - Sales.CustomerOrdersView.sql (deleted from model)

Schema model updated successfully.
Modified 3 files in .\schema-model\
```

**No changes needed:**
```
Flyway Enterprise Edition 10.x.x

Reading artifact: C:\Users\...\Temp\Artifacts\Flyway.State.Development.differences-20260108.zip

No differences to apply.
Schema model is already in sync.
```

### Step 6: Examine Updated Schema Model Files

```powershell
# See what files were changed
git status

# Example output:
# modified:   schema-model/Tables/Sales.CustomerFeedback.sql
# new file:   schema-model/Tables/Sales.Campaigns.sql
# deleted:    schema-model/Views/Sales.CustomerOrdersView.sql

# Review changes in a specific file
git diff schema-model/Tables/Sales.CustomerFeedback.sql

# View the new file created
Get-Content ".\schema-model\Tables\Sales.Campaigns.sql"
```

### Step 7: Verify Schema Model Structure

The model command maintains proper folder structure:

```
schema-model/
├── Tables/
│   ├── Sales.Campaigns.sql (new from diff)
│   ├── Sales.CustomerFeedback.sql (updated from diff)
│   └── ...
├── Views/
│   └── ...
├── Stored Procedures/
│   └── ...
└── Security/
    └── Schemas/
        └── ...
```

Each SQL file contains the complete object definition:

```sql
-- schema-model/Tables/Sales.Campaigns.sql
CREATE TABLE [Sales].[Campaigns] (
    [CampaignID] INT IDENTITY(1,1) NOT NULL,
    [CampaignName] NVARCHAR(100) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NULL,
    [Budget] DECIMAL(18, 2) NULL,
    CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignID])
);
```

## ✅ Success Criteria

- ✅ Ran `flyway model` successfully
- ✅ Schema model files updated automatically
- ✅ Can see changes in `git status`
- ✅ Understand how artifacts feed into model
- ✅ Schema model reflects current development state
- ✅ Ready to commit changes to Git

## 🐛 Troubleshooting

### "Artifact file not found"
**Problem:** Can't find the artifact from Quest 00.  
**Solution:**
```powershell
# List recent artifacts
Get-ChildItem "$env:TEMP\Artifacts\*.zip" | Sort-Object LastWriteTime -Descending

# Use the most recent one
$LATEST_ARTIFACT = (Get-ChildItem "$env:TEMP\Artifacts\*.zip" | Sort-Object LastWriteTime -Descending | Select-Object -First 1).FullName

flyway model "-model.artifactFilename=$LATEST_ARTIFACT" -workingDirectory="."
```

### "Schema model location not found"
**Problem:** Can't find schema-model folder.  
**Solution:**
```powershell
# Verify you're in project root
Get-Location

# Check if schema-model exists
Get-ChildItem -Directory -Filter "schema-model"

# If in wrong directory, navigate to project root
cd C:\Users\Huxley.Kendell\Desktop\Autopilot\Dev\Flyway-AutoPilot-State
```

### "Permission denied writing to schema model"
**Problem:** Can't update schema model files.  
**Solution:**
```powershell
# Check if files are read-only
Get-ChildItem .\schema-model -Recurse -File | Where-Object { $_.IsReadOnly }

# Remove read-only attribute if needed
Get-ChildItem .\schema-model -Recurse -File | ForEach-Object { $_.IsReadOnly = $false }
```

### "Git conflicts in schema model files"
**Problem:** Uncommitted changes conflict with model updates.  
**Solution:**
```powershell
# Commit or stash current changes first
git status
git stash  # Temporarily save uncommitted changes

# Run model command
flyway model "-model.artifactFilename=$ARTIFACT_FILENAME" -workingDirectory="."

# Review and merge changes
git stash pop  # Bring back stashed changes if needed
```

## 💡 Best Practices

### Always Review Changes Before Committing ✅
```powershell
# After running flyway model, review what changed
git status
git diff

# Review each file individually
git diff schema-model/Tables/Sales.Campaigns.sql
```

### Use Descriptive Commit Messages ✅
```powershell
# Good commit after model capture
git add schema-model/
git commit -m "feat(schema): Add Campaigns table and update CustomerFeedback structure

- Added Sales.Campaigns table for marketing campaigns
- Updated CustomerFeedback with new Rating column
- Removed deprecated CustomerOrdersView"
```

### Run Model Immediately After Diff ✅
```
Workflow:
1. flyway diff (create artifact)
2. flyway model (capture to schema model)
3. git add/commit (version control)
4. git push (share with team)
```

### Keep Artifacts for Reference ✅
```powershell
# Save important artifacts to project folder, not %temp%
$ARTIFACT_FILENAME = ".\Artifacts\Releases\Pre-Release-v1.2-Diff.zip"

# Quest 00: Create artifact
flyway diff -diff.artifactFilename=$ARTIFACT_FILENAME ...

# Quest 01: Use saved artifact
flyway model -model.artifactFilename=$ARTIFACT_FILENAME ...
```

## 🎓 Key Concepts Learned

- **Model Command:** Captures artifact differences into schema model
- **Artifact Consumption:** How diff artifacts feed the model workflow
- **Automatic File Management:** Flyway creates/updates/deletes SQL files
- **Schema Model Sync:** Keeping schema model in sync with development database
- **Version Control Integration:** Model updates integrate with Git workflow

## 🚀 Real-World Applications

- **Daily Development Workflow:**
  1. Make changes in SQL Server Management Studio (SSMS)
  2. Run `flyway diff` (capture what changed)
  3. Run `flyway model` (update schema model files)
  4. Commit to Git (version control your changes)

- **Team Collaboration:**
  - Developer A makes changes → model → commit → push
  - Developer B pulls changes → has updated schema model
  - Developer B runs `flyway prepare` + `flyway deploy` to get same schema

- **Feature Development:**
  - Create feature branch
  - Make database changes
  - `flyway diff` + `flyway model` to capture changes
  - Commit feature branch
  - Merge to main

## 📚 Model Command Variations

### Capture from Specific Artifact
```powershell
flyway model `
  "-model.artifactFilename=.\Artifacts\Feature-XYZ-Diff.zip" `
  -workingDirectory="."
```

### Model with Verbose Output
```powershell
flyway model `
  "-model.artifactFilename=$ARTIFACT_FILENAME" `
  -workingDirectory="." `
  -logLevel=debug
```

### Model for Specific Schemas Only
(Schema filtering is typically done at diff stage, not model)
```powershell
# Filter at diff stage
flyway diff `
  -diff.source=development `
  -diff.target=schemaModel `
  -diff.artifactFilename=.\Artifacts\Diff.zip `
  -schemaModelSchemas="Sales,Logistics"

# Then model captures only those schemas
flyway model -model.artifactFilename=.\Artifacts\Diff.zip
```

## 🔄 Integration with Development Quest 04

**In Development Quest 04 (Capture-New-Changes):**  
You used Flyway Desktop GUI to capture changes interactively.

**In Operations Quest 01 (Model):**  
You use Flyway CLI to capture changes programmatically.

**Both achieve the same goal:** Update schema model with your database changes.

**When to use each:**
- **Flyway Desktop (Dev Quest 04):** Interactive development, visual feedback, learning
- **Flyway CLI (Ops Quest 01):** Automation, CI/CD pipelines, scripted workflows

## 📚 Next Steps

Now that your schema model is updated, proceed to:

**Quest 02: Prepare** - Generate deployment scripts from your schema model

---

**Congratulations!** 🎉 You've learned how to capture differences into your schema model using artifacts!
