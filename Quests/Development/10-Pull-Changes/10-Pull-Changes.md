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

### Step 9: The Daily Team Workflow

**Understand this pattern:**

```
Teammate's Actions:
1. Create/modify objects in their dev database
2. Use Flyway Desktop: Diff → Apply to Schema Model (capture changes)
3. Commit schema model changes to Git
4. Push to shared repository

Your Actions (This Quest):
5. Pull from shared repository (schema model files updated)
6. Use Flyway Desktop: Diff → Apply to Development (sync your database)
7. Continue your development work with latest changes
```

**This is the continuous loop of team development!**

---

## ✅ Success Criteria

- ✅ Simulated a teammate's schema model change (new table file created)
- ✅ Identified the new object in the schema model
- ✅ Used Flyway Desktop to compare schema model vs development database
- ✅ Used "Apply to Development" to sync your database
- ✅ Verified the new table exists in your development database
- ✅ Understand the pull-and-apply workflow for team collaboration

## 🎓 Key Concepts Learned

### Schema Model = Team's Source of Truth
- The schema model represents the desired state of the database
- All team members sync their databases TO the schema model
- Schema model is stored in version control (Git)

### Two-Way Sync with Flyway Desktop

**Capture Your Changes (Quest 04):**
```
Your Dev DB → Diff → Apply to Schema Model → Commit → Push
```

**Apply Others' Changes (This Quest):**
```
Pull → Schema Model → Diff → Apply to Development → Your Dev DB
```
Can't find Apply to Development button"
**Problem:** Different Flyway Desktop version or view.  
**Solution:**
- Look for "Apply to Source" or "Synchronize" button
- Make sure you're in the Diff tab
- Source should be `schemaModel`, Target should be `development`

## 💡 Best Practices

### Start Each Day with Git Pull + Apply ✅
```powershell
# Morning routine:
git pull

# Then in Flyway Desktop:
# 1. Diff: schemaModel vs development
# 2. Apply to Development (if changes exist)
# 3. Now your database is in sync with the team
```

### Communicate Major Changes ✅
```
Teammate adding major schema changes?
- Notify team in chat/standup
- Document any setup steps needed
- Test that Apply to Development works smoothly
```

### Always Check Before Pushing Your Changes ✅
```
Before you commit your changes:
1. git pull (get latest from team)
2. Apply to Development (sync your database)
3. Test your changes still work
4. Then commit and push your changes
```

### Use Flyway Desktop for Both Directions ✅
```
Capture Your Work (Development → Schema Model):
- Diff tab: development vs schemaModel
- Apply to Schema Model button

Apply Others' Work (Schema Model → Development):
- Diff tab: schemaModel vs development  
- Apply to Development button
```

---

## 🚀 Real-World Team Development Flow

### Daily Developer Routine
```
8:00 AM  - Arrive, get coffee ☕
8:15 AM  - git pull (get team's latest changes)
8:16 AM  - Flyway Desktop: Apply to Development (sync database)
8:20 AM  - Start coding on your feature
12:00 PM - Lunch break 🍕
1:00 PM  - git pull (check for updates during lunch)
1:01 PM  - Flyway Desktop: Apply to Development (if needed)
5:00 PM  - Finish feature, test locally
5:10 PM  - Flyway Desktop: Apply to Schema Model (capture your changes)
5:15 PM  - git add, commit, push (share with team)
```

### Team Collaboration Patterns

**Scenario 1: New Table Added**
```
Developer A: Creates Sales.Promotions table
           → Applies to Schema Model
           → Commits and pushes

Developer B: Pulls changes
           → Sees new table in schema model
           → Applies to Development
           → Can now write queries against Sales.Promotions
```

**Scenario 2: Multiple Developers**
```
Developer A: Working on Sales schema
Developer B: Working on Logistics schema
Developer C: Working on stored procedures

All three:
- Start day: Pull → Apply to Development
- Work independently (different schemas/objects)
- End day: Apply to Schema Model → Commit → Push
- Minimal conflicts!
```

## 📚 Advanced Scenarios (Optional)

### Handling Multiple Related Objects

If your teammate added several interdependent objects:
```
Schema Model now contains:
- Sales.CustomerFeedback (Table)
- Sales.vw_FeedbackSummary (View - depends on CustomerFeedback)
- Sales.usp_RecordFeedback (Procedure - inserts into CustomerFeedback)

When you Apply to Development:
✓ Flyway automatically handles dependency order
✓ Table created first
✓ Then view
✓ Then procedure
```

### Resolving Merge Conflicts

If you and a teammate modified the same table:
```powershell
git pull
# CONFLICT in schema-model/Tables/Sales.Customers.sql

# Open the file
code schema-model\Tables\Sales.Customers.sql

# You'll see:
<<<<<<< HEAD
    [Phone] NVARCHAR(20)
=======
    [Phone] NVARCHAR(50)
>>>>>>> origin/develop

# Resolve (communicate with teammate!):
# - Keep one version, or
# - Manually merge both changes

# After resolving:
git add schema-model\Tables\Sales.Customers.sql
git commit

# Then Apply to Development to update your database
```

---

## 🎉 Congratulations!

You now understand the complete team collaboration workflow:

**Pushing Your Changes (Quest 05):**
- Development DB → Schema Model → Git → Team

**Pulling Others' Changes (This Quest):**
- Team → Git → Schema Model → Development DB

**Together, this creates a continuous cycle of team collaboration!**

---

## 📚 Next Steps

Continue to other Development quests to learn more Flyway Desktop features, or try the Operations quests to learn about deployment workflows!

