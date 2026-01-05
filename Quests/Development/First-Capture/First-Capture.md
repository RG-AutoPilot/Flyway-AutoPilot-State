**⚠️ RUN THE SQL SCRIPT FIRST TO CREATE THE NEEDED QUEST ITEMS**

# Development Quest - First Capture

**Difficulty:** 🟢 Beginner  
**Time:** 15-20 minutes  
**Prerequisites:** Flyway Desktop installed, sample database connected

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to capture your first database change using Flyway Desktop's state-based approach
- Understanding the schema model vs migrations folder
- How Flyway generates migration scripts from schema changes
- Basic Flyway Desktop development workflow
- How to commit changes to version control

## 📖 Scenario
You're starting your first day as a database developer at a growing airline company. The marketing team needs a new table to track promotional campaigns. This is your first opportunity to use Flyway to capture database changes into version control!

Unlike traditional manual migration writing, Flyway Desktop's state-based approach lets you make changes to your database first, then capture those changes automatically.

## 🎯 Your Mission
Create a new table called `Sales.Campaigns` that will store information about marketing campaigns, then use Flyway Desktop to capture this change into a versioned migration script.

## 📋 Business Requirements
The table needs:
- Each campaign must have a unique identifier
- Track the campaign name (max 100 characters)
- Record when the campaign starts and ends  
- All campaigns must have valid start and end dates

## 📝 Steps

### Step 1: Make the Database Change
First, you'll create the table directly in your development database:

1. **Open SQL Server Management Studio (SSMS) or Azure Data Studio**
2. **Connect to your development database** (e.g., `AutopilotDev`)
3. **Write and execute the CREATE TABLE statement**:
   ```sql
   CREATE TABLE Sales.Campaigns (
       CampaignID INT PRIMARY KEY IDENTITY(1,1),
       CampaignName NVARCHAR(100) NOT NULL,
       StartDate DATE NOT NULL,
       EndDate DATE NOT NULL
   );
   ```
4. **Verify the table was created**:
   ```sql
   SELECT * FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = 'Sales' AND TABLE_NAME = 'Campaigns';
   ```

### Step 2: Capture with Flyway Desktop

Now you'll use Flyway Desktop to detect and capture this change:

1. **Open Flyway Desktop**
2. **Ensure you're connected to your development database**
3. **Navigate to the Schema Model tab**
   - This shows your current database schema
   - New objects not yet in source control will be highlighted
4. **Click "Capture Changes" or "Generate Migration Script"**
   - Flyway compares your database to the schema model in source control
   - It detects your new `Sales.Campaigns` table
5. **Review the generated migration script**
   - Flyway automatically creates a properly formatted migration file
   - The script includes the CREATE TABLE statement
6. **Provide a meaningful migration description**
   - Example: "Create Sales Campaigns table for marketing"
7. **Save the migration**
   - The migration is saved to your `migrations/` folder
   - The schema model is updated in `schema-model/Tables/`

### Step 3: Verify the Capture

1. **Check the migrations folder**
   - You should see a new file like `V001__Create_Sales_Campaigns_table.sql`
2. **Check the schema-model folder**  
   - You should see `schema-model/Tables/Sales.Campaigns.sql`
3. **Verify in Flyway Desktop**
   - The "Pending Changes" indicator should now be clear
   - Your change is captured and ready to commit

### Step 4: Commit to Source Control

1. **Open your Git client** (command line, VS Code, etc.)
2. **Stage the changes**:
   ```bash
   git add migrations/
   git add schema-model/
   ```
3. **Commit with a clear message**:
   ```bash
   git commit -m "Add Sales.Campaigns table for marketing campaigns"
   ```
4. **Push to your repository**:
   ```bash
   git push
   ```

## 💡 Key Concepts

### State-Based vs Migration-Based
- **State-Based (what you just did):** Make changes in the database, Flyway generates the migration
- **Migration-Based:** Write migration scripts manually, Flyway applies them
- Flyway Enterprise supports both approaches

### Schema Model
The `schema-model/` folder contains the desired state of your database objects. Flyway uses this to:
- Track what your database should look like
- Generate migration scripts by comparing database vs schema model
- Provide a clear view of your database structure in source control

### Migrations Folder  
The `migrations/` folder contains versioned migration scripts that run in order to evolve your database from one version to another.

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ The `Sales.Campaigns` table exists in your development database
- ✅ A migration script exists in your `migrations/` folder (e.g., `V001__Create_Sales_Campaigns_table.sql`)
- ✅ The schema model file exists in `schema-model/Tables/Sales.Campaigns.sql`
- ✅ Changes are committed to your Git repository
- ✅ Flyway Desktop shows no pending changes

## 🐛 Troubleshooting

### "Table already exists"
**Problem:** You tried to create the table but it already exists.  
**Solution:** Drop it first: `DROP TABLE IF EXISTS Sales.Campaigns;`

### "Cannot find the table in Flyway Desktop"
**Problem:** Flyway Desktop isn't showing your new table.  
**Solution:** 
- Refresh the schema comparison
- Verify you're connected to the correct database
- Check the table was created in the right schema (Sales)

### "Permission denied"
**Problem:** Your database user lacks permissions.  
**Solution:** Ensure your user has CREATE TABLE and SELECT permissions on the database.

### "Migration not generated"
**Problem:** Flyway didn't detect your change.  
**Solution:**
- Ensure the table doesn't already exist in the schema model
- Check Flyway Desktop is pointing to the correct project folder
- Verify the flyway.toml configuration

## 💡 Hints & Tips

**Migration Naming:**  
Flyway uses the pattern `V{version}__{description}.sql`. The version is auto-incremented, and the description comes from what you type in Flyway Desktop.

**State-Based Workflow:**
1. Make change in database (CREATE TABLE)
2. Capture in Flyway Desktop (generates migration + updates schema model)
3. Commit to Git
4. Deploy to other environments via pipeline

**Best Practices:**
- Use meaningful migration descriptions
- Always verify changes before committing
- Keep migration scripts simple and focused
- Test locally before pushing to shared branches

## 🚀 Next Steps

Now that you've captured your first change, try these quests:

1. **`Development/Static-Data`** - Learn to version control reference data like campaign types
2. **`Development/Merging-Changes`** - See how to work with changes from other developers
3. **`Scenarios/Stored-Procedures`** - Explore how Flyway handles database code objects

## 📚 Additional Resources

- [Flyway Desktop Documentation](https://documentation.red-gate.com/flyway/database-development-using-flyway)
- [Understanding State-Based Migrations](https://documentation.red-gate.com/flyway)
- [Schema Model Folder Structure](https://documentation.red-gate.com/flyway)

---

**Congratulations!** 🎉 You've captured your first database change with Flyway. This is the foundation of database version control.
