# Development Quest 06 - Modify Existing Object

**Difficulty:** 🟢 Beginner  
**Time:** 15-20 minutes  
**Prerequisites:** Completed Quest 04 (Capture New Changes), Quest 05 (Commit and Push)

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to modify an existing database object in your dev database
- Capturing modifications (not just new objects) into the schema model
- Understanding how Flyway Desktop tracks changes to existing objects
- Reinforcing the state-based mindset: desired state, not change scripts

## 📖 Scenario
The `Sales.Campaigns` table needs an additional column to track the budget allocated to each campaign. You'll modify the existing table in your development database, then recapture the updated definition into the schema model.

## 🎯 Your Mission
Add a `Budget` column to the existing `Sales.Campaigns` table and recapture the updated table definition into the schema model.

## 📝 Steps

### Step 1: Modify the Existing Table

**In SSMS or Azure Data Studio:**

```sql
-- Add Budget column to Sales.Campaigns
ALTER TABLE Sales.Campaigns
ADD Budget DECIMAL(18,2) NULL;

-- Verify the change
EXEC sp_help 'Sales.Campaigns';

-- Or view columns
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Sales' AND TABLE_NAME = 'Campaigns';
```

### Step 2: Detect the Modification in Flyway Desktop

1. **Open Flyway Desktop**
2. **Run comparison:** Schema Model vs. Development Database
3. **Review detected differences:**
   ```
   Modified Objects:
   - Sales.Campaigns (Table) [MODIFIED]
     → Column added: Budget DECIMAL(18,2) NULL
   ```

### Step 3: Recapture the Updated Object

1. **Select the modified Sales.Campaigns table**
2. **Click "Capture" or "Update Schema Model"**
3. **Flyway Desktop updates:** `schema-model/Tables/Sales.Campaigns.sql`

**What happens:**
- The existing file is **replaced** with the new definition
- The full CREATE TABLE statement now includes the Budget column
- State-based approach: complete current state, not ALTER script

### Step 4: Verify the Updated Schema Model File

```powershell
code schema-model\Tables\Sales.Campaigns.sql
```

**Expected content (abbreviated):**
```sql
CREATE TABLE [Sales].[Campaigns] (
    [CampaignID] INT IDENTITY(1,1) NOT NULL,
    [CampaignName] NVARCHAR(100) NOT NULL,
    [StartDate] DATE NOT NULL,
    [EndDate] DATE NOT NULL,
    [CreatedDate] DATETIME DEFAULT GETDATE(),
    [Budget] DECIMAL(18,2) NULL,  -- ← New column added
    CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignID]),
    CONSTRAINT [CHK_Campaigns_Dates] CHECK ([EndDate] >= [StartDate])
);
```

### Step 5: Commit the Modification

```powershell
git status  # Shows schema-model/Tables/Sales.Campaigns.sql modified

git diff schema-model/Tables/Sales.Campaigns.sql  # Review the change

git add schema-model/Tables/Sales.Campaigns.sql

git commit -m "Add Budget column to Sales.Campaigns table"

git pull origin develop

git push origin develop
```

## 🎓 Key Concept: State vs. Change Scripts

**State-Based (Flyway Desktop):**
```
schema-model/Tables/Sales.Campaigns.sql contains:
CREATE TABLE with ALL columns (including new Budget column)

→ Represents the DESIRED STATE
```

**Migration-Based (Traditional):**
```
migrations/V002__Add_budget_column.sql would contain:
ALTER TABLE Sales.Campaigns ADD Budget DECIMAL(18,2) NULL;

→ Represents the CHANGE
```

**Important:** In state-based workflow, schema model always shows the **current complete definition**, not individual changes. Deployment scripts (ALTER statements) are generated later from state differences.

## ✅ Success Criteria

- ✅ Modified existing table in development database
- ✅ Detected modification in Flyway Desktop
- ✅ Recaptured updated definition into schema model
- ✅ Schema model file updated with new column
- ✅ Committed and pushed changes
- ✅ Understand state-based modification workflow

## 💡 Best Practices

### Test Modifications First ✅
```sql
-- Test the new column works
UPDATE Sales.Campaigns
SET Budget = 50000.00
WHERE CampaignID = 1;

SELECT * FROM Sales.Campaigns;
```

### Review Changes Before Capturing ✅
```sql
-- Verify what changed
EXEC sp_help 'Sales.Campaigns';

-- Ensure no accidental changes
```

## 📚 Next Steps

**Quest 07: Track Static Data** - Learn how to version control reference/lookup data

---

**Congratulations!** 🎉 You've learned how to modify existing objects and recapture their updated state!
