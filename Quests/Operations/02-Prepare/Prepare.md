# Operations Quest - Prepare (Generate Deployment Scripts)

**Difficulty:** 🟡 Intermediate  
**Time:** 15-20 minutes  
**Prerequisites:** Schema model is up-to-date with your desired state

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to generate deployment scripts for a target environment
- How to create both deploy and undo scripts
- Understanding the difference between source and target
- When to use `-prepare.force` to skip interactive prompts

## 📖 What is Prepare?

The `flyway prepare` command compares your **schema model** (desired state) against a **target database** (current state) and generates SQL scripts to deploy the changes. This is your "preview" step before actually deploying.

**Key Points:**
- Creates **deployment script** (what will be executed)
- Optionally creates **undo script** (how to rollback)
- Does NOT modify the database (just generates scripts)
- Can be reviewed and approved before deployment

---

## 🔧 The Command

### Basic Syntax
```powershell
flyway prepare `
  -prepare.source=<source-environment> `
  -prepare.target=<target-environment> `
  -prepare.types=deploy,undo `
  -prepare.scriptFilename=<deploy-script-path> `
  -prepare.undoFilename=<undo-script-path> `
  -schemaModelLocation=<path-to-schema-model>
```

### Example from Helper Script
```powershell
# Variables
$SCRIPT_FILENAME = "Flyway_Deployment_Script.sql"
$UNDO_FILENAME = "Flyway_Undo_Script.sql"
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
$SOURCE_ENVIRONMENT = "schemaModel"
$TARGET_ENVIRONMENT = "Test"

# Prepare Script for Deployment
flyway prepare `
  "-prepare.source=$SOURCE_ENVIRONMENT" `
  "-prepare.target=$TARGET_ENVIRONMENT" `
  "-prepare.types=deploy,undo" `
  "-prepare.scriptFilename=%temp%\Artifacts\D_$SCRIPT_FILENAME" `
  "-prepare.undoFilename=%temp%\Artifacts\U_$UNDO_FILENAME" `
  "-prepare.force=true" `
  -configFiles="$WORKING_DIRECTORY\flyway.toml" `
  -schemaModelLocation="$WORKING_DIRECTORY\schema-model"
```

---

## 📋 Parameter Breakdown

| Parameter | Description | Example |
|-----------|-------------|---------|
| `-prepare.source` | Source environment (usually `schemaModel`) | `schemaModel` |
| `-prepare.target` | Target database to deploy to | `Test`, `Production` |
| `-prepare.types` | Types of scripts to generate | `deploy`, `undo`, or both |
| `-prepare.scriptFilename` | Path for the deployment script | `Artifacts\deploy.sql` |
| `-prepare.undoFilename` | Path for the undo/rollback script | `Artifacts\undo.sql` |
| `-prepare.force` | Skip interactive prompts (useful for CI/CD) | `true` or `false` |
| `-schemaModelLocation` | Path to schema model folder | `.\schema-model` |

---

## 🎯 Understanding Source vs Target

### Most Common: Schema Model → Database
```powershell
-prepare.source=schemaModel     # Desired state (your schema model)
-prepare.target=Test            # Current state (target database)
# Result: Script to make Test match schema model
```

### Alternative: Database → Database
```powershell
-prepare.source=development     # Current dev database
-prepare.target=production      # Production database
# Result: Script to make production match development
```

---

## 📁 Output Files

### Deploy Script (`D_Flyway_Deployment_Script.sql`)
Contains SQL to apply changes:
```sql
-- Create new table
CREATE TABLE [Sales].[LoyaltyTier] (
    [TierID] INT IDENTITY(1,1) PRIMARY KEY,
    ...
);

-- Add column to existing table
ALTER TABLE [Sales].[Customers]
ADD [LoyaltyTierID] INT NULL;

-- Create foreign key
ALTER TABLE [Sales].[Customers]
ADD CONSTRAINT [FK_Customers_LoyaltyTier]
FOREIGN KEY ([LoyaltyTierID]) REFERENCES [Sales].[LoyaltyTier]([TierID]);
```

### Undo Script (`U_Flyway_Undo_Script.sql`)
Contains SQL to rollback changes:
```sql
-- Drop foreign key
ALTER TABLE [Sales].[Customers]
DROP CONSTRAINT [FK_Customers_LoyaltyTier];

-- Drop column
ALTER TABLE [Sales].[Customers]
DROP COLUMN [LoyaltyTierID];

-- Drop table
DROP TABLE [Sales].[LoyaltyTier];
```

---

## 🔄 Workflow Context

**Prepare** is typically **Step 3** in the state-based workflow:

1. **Diff** (compare and create artifact)
2. **Model** (apply changes to schema model)
3. **Prepare** ← You are here (generate deployment scripts)
4. **Check** (validate changes)
5. **Deploy** (execute deployment)

---

## 💡 Tips & Best Practices

### ✅ DO:
- Always generate both deploy AND undo scripts for safety
- Review the generated scripts before deploying
- Use timestamped filenames: `D_Deploy-$(get-date -f yyyyMMdd-HHmmss).sql`
- Store deployment scripts in source control or artifact repository
- Use `-prepare.force=true` in CI/CD pipelines to avoid prompts

### ❌ DON'T:
- Don't skip reviewing the deployment script (catch issues early!)
- Don't use the same filename repeatedly (keep a history)
- Don't forget to update credentials if needed (use environment variables)

---

## 🔍 Review the Generated Script

Before deploying, always review the script:

```powershell
# Open the deployment script
code "%temp%\Artifacts\D_Flyway_Deployment_Script.sql"

# Check for:
# - Correct objects being created/modified/dropped
# - Proper dependency order (tables before views, etc.)
# - No unexpected changes
```

---

## 🎯 Common Use Cases

### 1️⃣ Deploying to Test
```powershell
flyway prepare `
  -prepare.source=schemaModel `
  -prepare.target=Test `
  -prepare.types=deploy,undo `
  -prepare.scriptFilename="Artifacts\test-deploy.sql" `
  -prepare.undoFilename="Artifacts\test-undo.sql"
```

### 2️⃣ Deploying to Production (with approval)
```powershell
flyway prepare `
  -prepare.source=schemaModel `
  -prepare.target=Production `
  -prepare.types=deploy,undo `
  -prepare.scriptFilename="Artifacts\prod-deploy-$(get-date -f yyyyMMdd).sql" `
  -prepare.force=false  # Prompt for confirmation
```

### 3️⃣ CI/CD Pipeline (automated)
```powershell
flyway prepare `
  -prepare.source=schemaModel `
  -prepare.target=Staging `
  -prepare.types=deploy `
  -prepare.scriptFilename="Artifacts\staging-deploy.sql" `
  -prepare.force=true  # No prompts in automation
```

---

## 🚀 Try It Yourself

1. Ensure your schema model is up-to-date (run Diff + Model if needed)
2. Update the variables for your target environment
3. Run the `flyway prepare` command
4. Check that both deploy and undo scripts were created
5. Review the deployment script contents
6. Proceed to **Check** or **Deploy** quest

---

## 📚 Related Commands

- **[Model](../01-Model/Model.md)** - Update schema model before preparing
- **[Check](../03-Check/Check.md)** - Validate the deployment script
- **[Deploy](../04-Deploy/Deploy.md)** - Execute the deployment script

---

## 📖 Further Reading

- [Flyway Prepare Documentation](https://documentation.red-gate.com/fd/prepare-184127492.html)
- [Deployment Scripts Best Practices](https://documentation.red-gate.com/fd/state-based-projects-227279884.html)

---

**Next Step:** After generating deployment scripts, use the **Check** quest to validate changes, or proceed directly to **Deploy** if you're confident!
