# Development Quest 10 - Pull Changes from Version Control

**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Prerequisites:** Completed Quest 05 (Commit and Push), understanding of Git pull

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to pull schema model changes made by other developers
- Comparing your development database against the updated schema model
- Synchronizing your dev database with Flyway Desktop
- Understanding the workflow when teammates add new objects
- Avoiding overwriting teammates' work

## 📖 Scenario
Your teammate just added a new `Sales.CustomerFeedback` table to the schema model and pushed it to the develop branch. You need to pull their changes from Git and update your development database to include this new table. This is the reverse of Quest 04 - instead of pushing your changes, you're receiving others' changes.

## 🎯 Your Mission
Pull the latest schema model changes from the repository and synchronize your development database to include the new objects.

## 📝 Steps

### Step 1: Simulate a Teammate's Change (For This Quest)

**For learning purposes, manually add a file to simulate a teammate's push:**

```powershell
# Create the new table file in schema model
code schema-model\Tables\Sales.CustomerFeedback.sql
```

**Add this content:**
```sql
CREATE TABLE [Sales].[CustomerFeedback] (
    [FeedbackID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] INT NOT NULL,
    [FeedbackDate] DATETIME DEFAULT GETDATE(),
    [Rating] INT NOT NULL,
    [Comments] NVARCHAR(500),
    [FollowUpRequired] BIT DEFAULT 0,
    CONSTRAINT [PK_CustomerFeedback] PRIMARY KEY CLUSTERED ([FeedbackID]),
    CONSTRAINT [CHK_CustomerFeedback_Rating] CHECK ([Rating] BETWEEN 1 AND 5)
);
```

**Save the file** (this simulates what a teammate added).

### Step 2: Pull Latest Changes from Repository

```powershell
# Check current status
git status  # Shows you have local changes (the file you just created)

# In real scenario, teammate pushed this, so simulate that:
git add schema-model\Tables\Sales.CustomerFeedback.sql
git commit -m "Simulate teammate adding CustomerFeedback table"

# Now pull (in real scenario, this would be their changes)
git pull origin develop
```

**In a real workflow:**
```powershell
# You just run:
git pull origin develop

# Git downloads teammates' changes:
# - New schema model files
# - Modified schema model files
# - Deleted schema model files
```

### Step 3: Review What Changed

```powershell
# See what files changed in the pull
git log --oneline -5

# See specific file changes
git diff HEAD~1 -- schema-model/

# List new files
Get-ChildItem schema-model\Tables | Sort-Object LastWriteTime -Descending | Select-Object -First 5
```

### Step 4: Compare Database Against Updated Schema Model

1. **Open Flyway Desktop**
2. **Run comparison:**
   - **Source:** Schema Model (now includes `CustomerFeedback`)
   - **Target:** Development Database (doesn't have it yet)

3. **Review differences:**
   ```
   Objects in Schema Model but NOT in Database:
   - Sales.CustomerFeedback (Table) [MISSING FROM DATABASE]
   ```

### Step 5: Synchronize Your Database

**Deploy the schema model changes to your dev database:**

1. **In Flyway Desktop:**
   - Select the missing `Sales.CustomerFeedback` table
   - Click **"Synchronize"** or **"Deploy to Development"**

2. **Flyway generates and executes:**
   ```sql
   CREATE TABLE [Sales].[CustomerFeedback] (
       [FeedbackID] INT IDENTITY(1,1) NOT NULL,
       [CustomerID] INT NOT NULL,
       ...
   );
   ```

3. **Verify in Database:**
   ```sql
   SELECT * FROM INFORMATION_SCHEMA.TABLES
   WHERE TABLE_SCHEMA = 'Sales' AND TABLE_NAME = 'CustomerFeedback';
   
   EXEC sp_help 'Sales.CustomerFeedback';
   ```

### Step 6: Verify Synchronization

**Run comparison again:**
- **Expected:** "No differences detected"
- Your dev database now matches the updated schema model

## ✅ Success Criteria

- ✅ Pulled latest changes from repository
- ✅ Identified new/modified objects in schema model
- ✅ Compared database against updated schema model
- ✅ Synchronized development database using Flyway Desktop
- ✅ Verified database now matches schema model
- ✅ Understand workflow for integrating teammates' changes

## 🐛 Troubleshooting

### "Git pull shows merge conflict in schema model file"
**Problem:** You and teammate modified same object.  
**Solution:**
```powershell
# Open conflicted file
code schema-model\Tables\Sales.Customers.sql

# Resolve conflict markers
# Choose correct version or merge manually
# Save file

# Mark as resolved
git add schema-model\Tables\Sales.Customers.sql
git commit
```

### "Synchronization would drop existing data"
**Problem:** Schema model change requires data migration.  
**Solution:**
- Back up data before synchronizing
- Manually migrate data if needed
- Coordinate with teammate about the change

### "New object has dependencies not in my database"
**Problem:** New table references objects you don't have.  
**Solution:**
- Pull all changes (may be multiple objects)
- Synchronize in correct order (Flyway handles this)
- If still failing, teammate may have incomplete changes

## 💡 Best Practices

### Pull Frequently ✅
```powershell
# Daily routine:
git pull origin develop

# Then check in Flyway Desktop:
# - Run comparison
# - Synchronize if needed
```

### Communicate Big Changes ✅
```
Teammate adding major schema changes?
- Give team heads-up in chat/standup
- Document dependencies
- Test synchronization works
```

### Always Compare After Pulling ✅
```
Workflow:
1. git pull origin develop
2. Open Flyway Desktop
3. Run comparison
4. Synchronize dev database
5. Verify "No differences"
6. Now safe to continue your work
```

### Backup Before Major Syncs ✅
```sql
-- Before synchronizing large changes:
BACKUP DATABASE AutopilotDev
TO DISK = 'C:\Backups\AutopilotDev_BeforeSync.bak';
```

## 🎓 Key Concepts Learned

- **Pull Workflow:** Getting teammates' schema changes
- **Schema Model as Source of Truth:** Database follows schema model
- **Synchronization:** Deploying schema model to database
- **Collaboration:** Integrating changes from multiple developers
- **Daily Routine:** Pull → Compare → Sync → Develop

## 🚀 Real-World Applications

- **Team Development:** Everyone stays synchronized
- **Morning Routine:** Pull latest before starting work
- **After Meetings:** Sync up after team standups
- **Before Commits:** Ensure you have latest before pushing
- **Onboarding:** New developer syncs to team's current state

## 📚 Advanced Scenarios (Optional)

### Handling Multiple New Objects
```
Teammate added:
- Sales.CustomerFeedback (Table)
- Sales.GetFeedbackSummary (View)
- Sales.RecordFeedback (Procedure)

Synchronize all at once:
- Flyway Desktop shows all three
- Select all and synchronize
- Flyway deploys in correct dependency order
```

### Resolving Schema Model Conflicts
```powershell
# Both you and teammate modified Sales.Customers

# After git pull:
CONFLICT: schema-model/Tables/Sales.Customers.sql

# Open file, see:
<<<<<<< HEAD
ALTER COLUMN Phone NVARCHAR(20)
=======
ALTER COLUMN Phone NVARCHAR(50)
>>>>>>> develop

# Decide correct version (discuss with teammate)
# Remove conflict markers
# git add, git commit
# Then synchronize database
```

## 📚 Next Steps

**Quest 11: Placeholders** - Learn to handle environment-specific values

---

**Congratulations!** 🎉 You know how to pull and synchronize teammates' schema changes!
