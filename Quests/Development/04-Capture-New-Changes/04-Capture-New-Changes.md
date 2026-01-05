# Development Quest 04 - Capture New Changes

**Difficulty:** 🟢 Beginner  
**Time:** 20-25 minutes  
**Prerequisites:** Completed Quest 03 (Validate Environment Sync), dev environment in sync

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to make intentional schema changes in your development database
- Detecting those changes in Flyway Desktop
- Capturing changes into the schema model
- Understanding Flyway Desktop's state-based comparison
- Preparing changes for version control

## 📖 Scenario
The marketing team needs a new table to track promotional campaigns for the airline. You'll create this table in your development database, then use Flyway Desktop to detect the change and capture it into the schema model. This is the core workflow you'll use daily as a database developer with Flyway.

## 🎯 Your Mission
Create a new `Sales.Campaigns` table in your development database and capture it into the schema model using Flyway Desktop.

## 📋 Business Requirements

The Campaigns table must:
- Track unique campaign identifiers
- Store campaign names (up to 100 characters)
- Record start and end dates for each campaign
- Ensure all campaigns have valid dates

## 📝 Steps

### Step 1: Make the Schema Change in Your Development Database

**State-Based Principle:** Make changes in your database first, then capture them.

1. **Open SQL Server Management Studio (SSMS) or Azure Data Studio**

2. **Connect to your development database** (`AutopilotDev`)

3. **Create the new table:**
   ```sql
   CREATE TABLE Sales.Campaigns (
       CampaignID INT PRIMARY KEY IDENTITY(1,1),
       CampaignName NVARCHAR(100) NOT NULL,
       StartDate DATE NOT NULL,
       EndDate DATE NOT NULL,
       CreatedDate DATETIME DEFAULT GETDATE(),
       CONSTRAINT CHK_Campaigns_Dates CHECK (EndDate >= StartDate)
   );
   ```

4. **Execute the script** (F5 or Execute button)

5. **Verify the table was created:**
   ```sql
   SELECT * FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = 'Sales' AND TABLE_NAME = 'Campaigns';
   
   -- Verify structure
   EXEC sp_help 'Sales.Campaigns';
   ```

### Step 2: Detect the Change in Flyway Desktop

1. **Open Flyway Desktop**

2. **Ensure you're connected to the development environment**

3. **Navigate to the Comparison/Diff view**
   - Look for "Compare", "Schema Compare", or similar option
   - Flyway Desktop continuously monitors for changes

4. **Run a comparison:**
   - **Source:** Schema Model (your desired state in Git)
   - **Target:** Development Database (your current database state)
   - Click **"Compare"** or **"Detect Changes"**

5. **Review detected changes:**
   ```
   Differences Detected:
   
   Objects in Target (Dev DB) but not in Source (Schema Model):
   - Sales.Campaigns (Table) [NEW]
   ```

6. **Inspect the details:**
   - Flyway should show the CREATE TABLE statement
   - Verify all columns, constraints, and defaults are detected correctly

### Step 3: Capture the Change into the Schema Model

1. **In Flyway Desktop, select the detected change:**
   - Checkbox or select `Sales.Campaigns`
   - Review the change details

2. **Click "Capture" or "Add to Schema Model"**
   - Flyway Desktop will:
     - Create a file in `schema-model/Tables/Sales.Campaigns.sql`
     - Populate it with the CREATE TABLE definition
     - Update internal tracking

3. **Verify the schema model file was created:**
   ```powershell
   # Check the file exists
   Get-ChildItem -Path "schema-model\Tables" -Filter "*Campaigns*"
   
   # View the content
   code "schema-model\Tables\Sales.Campaigns.sql"
   ```

   **Expected content:**
   ```sql
   CREATE TABLE [Sales].[Campaigns] (
       [CampaignID] INT IDENTITY(1,1) NOT NULL,
       [CampaignName] NVARCHAR(100) NOT NULL,
       [StartDate] DATE NOT NULL,
       [EndDate] DATE NOT NULL,
       [CreatedDate] DATETIME DEFAULT GETDATE(),
       CONSTRAINT [PK_Campaigns] PRIMARY KEY CLUSTERED ([CampaignID]),
       CONSTRAINT [CHK_Campaigns_Dates] CHECK ([EndDate] >= [StartDate])
   );
   ```

4. **Run comparison again to verify sync:**
   - Source: Schema Model
   - Target: Development Database
   - Expected result: **"No differences detected"**
   
   ✓ Your database and schema model are now in sync!

### Step 4: Review What Flyway Desktop Did

**Files created/modified:**
```
schema-model/
└── Tables/
    └── Sales.Campaigns.sql  [NEW FILE CREATED]
```

**Flyway Desktop:**
- Detected new object in database
- Generated proper SQL definition
- Saved to schema model folder
- Used naming convention: `SchemaName.ObjectName.sql`
- Preserved all table attributes (constraints, defaults, identity)

**What was NOT created (yet):**
- No migration script in `migrations/` folder
- That comes later when generating deployments (Operations quests)

### Step 5: Understand State-Based Capture vs. Migration-Based

**State-Based (What you just did):**
```
1. Create table in database
2. Flyway Desktop detects the change
3. Captures current state into schema-model/
4. Schema model now contains the desired state
```

**Migration-Based (Traditional Flyway):**
```
1. Write migration script manually
2. Place in migrations/ folder
3. Run flyway migrate
4. Database updated
```

**Key Difference:** State-based captures **what the object is**, not **how to create it**. Deployment scripts are generated later from the state.

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Created `Sales.Campaigns` table in development database
- ✅ Detected the change in Flyway Desktop comparison
- ✅ Captured the change into schema model
- ✅ Schema model file `Sales.Campaigns.sql` exists and contains correct definition
- ✅ Re-comparison shows "No differences" (in sync)
- ✅ Understand the state-based workflow: Database → Detection → Capture

## 🐛 Troubleshooting

### "Flyway Desktop doesn't detect my new table"
**Problem:** Created table but Flyway doesn't show it as a change.  
**Solution:**
- Verify you're connected to the correct database
- Click **"Refresh"** or **"Re-compare"**
- Check comparison direction (Schema Model vs. Development)
- Verify table created in correct schema (Sales, not dbo)

### "Captured file has wrong format or extra content"
**Problem:** Schema model file contains unexpected SQL.  
**Solution:**
- This is normal - Flyway generates SQL in its canonical format
- May include brackets, schema qualifiers, etc.
- Trust Flyway's generation - it's consistent

### "Can't find the schema-model file after capture"
**Problem:** Don't see `Sales.Campaigns.sql` file.  
**Solution:**
- Check `schema-model/Tables/` folder
- Refresh file explorer (F5)
- Verify capture operation completed successfully
- Look for error messages in Flyway Desktop output

### "Comparison still shows differences after capture"
**Problem:** Flyway still detects differences.  
**Solution:**
- Refresh/re-run comparison
- Check if multiple changes exist (capture all)
- Verify schema model file saved correctly
- Restart Flyway Desktop if needed

## 💡 Best Practices

### Make Small, Intentional Changes ✅
```sql
-- Good: One clear change
CREATE TABLE Sales.Campaigns (...);

-- Avoid: Multiple unrelated changes at once
CREATE TABLE Sales.Campaigns (...);
CREATE TABLE Logistics.Airports (...);
ALTER TABLE Sales.Customers ADD ...;
-- Capture these separately!
```

### Verify Before Capturing ✅
```sql
-- Test the table works
INSERT INTO Sales.Campaigns (CampaignName, StartDate, EndDate)
VALUES ('Summer Sale', '2026-06-01', '2026-08-31');

SELECT * FROM Sales.Campaigns;

-- Verify constraints work
INSERT INTO Sales.Campaigns (CampaignName, StartDate, EndDate)
VALUES ('Invalid', '2026-12-31', '2026-01-01');  -- Should fail CHECK constraint
```

### Use Consistent Naming Conventions ✅
```sql
-- Good: Clear, descriptive names
CREATE TABLE Sales.Campaigns (...);
CREATE TABLE Sales.LoyaltyPrograms (...);

-- Avoid: Inconsistent or unclear names
CREATE TABLE Sales.Cmpgns (...);
CREATE TABLE Sales.tblCampaign (...);
```

### Capture Changes Promptly ✅
Don't let changes pile up:
- Create table → Capture immediately
- Don't create 10 tables then try to capture all at once
- Easier to review and understand one change at a time

## 🎓 Key Concepts Learned

- **State-Based Workflow:** Database-first development with state capture
- **Flyway Desktop Comparison:** Detecting differences between database and schema model
- **Schema Model:** Desired state repository for database objects
- **Capture Operation:** Converting database state into version-controlled files
- **Synchronization:** Keeping database and schema model aligned

## 🚀 Real-World Applications

- **Daily Development:** Your primary workflow for schema changes
- **Rapid Prototyping:** Experiment in database, capture what works
- **Team Collaboration:** Everyone captures changes consistently
- **Code Reviews:** Schema model files are reviewed in Git like code
- **Deployment:** Captured state becomes the source for deployment scripts

## 📚 Advanced Scenarios (Optional)

### Capturing Multiple Objects at Once
```
If you create multiple related objects:
1. Sales.Campaigns (Table)
2. Sales.CampaignAnalytics (View)
3. Sales.GetActiveCampaigns (Stored Procedure)

Flyway Desktop detects all three.
You can capture them:
- All at once (one commit)
- One by one (separate commits)

Choose based on logical grouping.
```

### Handling Dependent Objects
```
If Sales.CampaignAnalytics VIEW depends on Sales.Campaigns TABLE:
- Capture the table first
- Then capture the view
- Flyway Desktop understands dependencies
- Schema model maintains correct order
```

### Reviewing Generated SQL
```powershell
# Open schema model file
code "schema-model\Tables\Sales.Campaigns.sql"

# Notice Flyway's formatting:
# - Brackets around identifiers
# - Explicit schema qualification
# - Consistent casing
# - Complete constraint definitions

# This is Flyway's canonical format - don't manually edit!
```

## 📚 Next Steps

Now that you've captured your first schema change, proceed to:

**Quest 05: Commit and Push** - Learn how to commit your captured changes to Git and share with your team

---

**Congratulations!** 🎉 You've successfully captured your first database change using Flyway Desktop's state-based workflow!
