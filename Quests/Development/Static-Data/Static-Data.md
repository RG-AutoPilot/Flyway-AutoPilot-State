**⚠️ RUN THE SQL SCRIPT FIRST TO CREATE THE NEEDED QUEST ITEMS**

# Development Quest - Managing Static Data

**Difficulty:** 🟢 Beginner  
**Time:** 25-30 minutes  
**Prerequisites:** Flyway Desktop installed, completed First Capture quest

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to version control static/reference data with Flyway Desktop
- Understanding static data tracking feature
- When to track data vs schema-only changes
- Handling initial data loads and updates
- Best practices for reference data management

## 📖 Scenario
Your team has launched a loyalty program for frequent flyers. The `Sales.LoyaltyProgram` table contains configuration data for different program tiers (Bronze, Silver, Gold, Platinum). This data is essential for the application to function and must be identical across all environments.

Currently, this configuration data exists only in your Dev database. If a new environment is created or a database is rebuilt, this critical reference data would be missing, breaking the application!

You need to ensure this data is tracked in version control and deployed automatically with your schema changes.

## 🎯 Your Mission
Use Flyway Desktop's static data tracking feature to version control the loyalty program configuration and ensure it deploys consistently to all environments.

## 📋 What is Static Data?

### ✅ Static Data (version control this!)
- **Lookup tables** - Countries, states, regions, product categories
- **Configuration data** - Loyalty tiers, system settings, feature flags
- **Reference data** - Tax rates, discount rules, business rules
- **Characteristics:** Rarely changes, needed for app to function, same across all environments

### ❌ Transactional Data (don't version control this!)
- **Customer records** - User accounts, profiles
- **Orders and purchases** - Sales transactions
- **Activity logs** - Audit trails, user actions
- **Characteristics:** Changes frequently, different per environment, business data

## 📝 Steps

### Step 1: Understand the Loyalty Program Data
The setup script created this table with tier data:
```sql
CREATE TABLE Sales.LoyaltyProgram (
    TierID INT PRIMARY KEY,
    TierName NVARCHAR(50) NOT NULL,
    MinimumPoints INT NOT NULL,
    DiscountPercentage DECIMAL(5,2) NOT NULL
);

-- Reference data that should be version controlled:
INSERT INTO Sales.LoyaltyProgram VALUES
    (1, 'Bronze', 0, 5.00),
    (2, 'Silver', 10000, 10.00),
    (3, 'Gold', 25000, 15.00),
    (4, 'Platinum', 50000, 20.00);
```

**Why is this static data?**
- The tiers are part of the business rules
- They're needed for the app to calculate discounts
- They should be identical in Dev, Test, and Prod
- They rarely change (maybe once a quarter at most)

### Step 2: Track Static Data in Flyway Desktop

1. **Open Flyway Desktop and connect to your development database**

2. **Navigate to the Schema Model tab**

3. **Open Static Data Tracking**:
   - Look for the "Static Data" option/icon
   - This feature lets you mark specific tables for data tracking

4. **Select the Table for Tracking**:
   - Find `Sales.LoyaltyProgram` in the table list
   - Mark it for static data tracking
   - This tells Flyway to include data, not just schema

5. **Capture the Data**:
   - Flyway will read the current data from the table
   - It creates a representation in the schema model folder
   - The data becomes part of your desired state

### Step 3: Generate the Migration

1. **Generate Migration Script**:
   - Click "Generate Migration" or "Capture Changes" in Flyway Desktop
   - Flyway detects both the table structure AND the data
   - It creates a migration with INSERT statements
   ```

### Step 4: Handle Existing Data in Other Environments

**Problem**: Test and Prod already have this loyalty data. Running the migration will cause duplicate key errors!

**Solution**: Use `flyway.skipExecutingMigrations`
2. **Review the Generated Migration**:
   ```sql
   -- Example: V002__Add_LoyaltyProgram_static_data.sql
   INSERT INTO Sales.LoyaltyProgram (TierID, TierName, MinimumPoints, DiscountPercentage)
   VALUES 
       (1, 'Bronze', 0, 5.00),
       (2, 'Silver', 10000, 10.00),
       (3, 'Gold', 25000, 15.00),
       (4, 'Platinum', 50000, 20.00);
   ```

3. **Provide a Description**:
   - Example: "Add loyalty program tier configuration data"

4. **Save the Migration**:
   - Flyway saves it to the `migrations/` folder
   - Updates the schema model with data tracking information

### Step 4: Verify and Commit

1. **Verify Generated Files**:
   - Check `migrations/` for the INSERT migration
   - Check `schema-model/` for static data tracking files

2. **Commit to Source Control**:
   ```bash
   git add migrations/
   git add schema-model/
   git commit -m "Add static data tracking for LoyaltyProgram tiers"
   git push
   ```

### Step 5: Understanding Deployment

**What happens when this deploys to other environments?**

- **Clean database (Test, new environment):** The migration runs, inserts the 4 tiers ✅
- **Database with existing data (Prod):** Potential duplicate key error! ⚠️

**How to handle existing data in Production:**

Flyway's static data migrations are smart - they typically use MERGE or IF NOT EXISTS patterns. Check your generated migration:

```sql
-- Flyway might generate something like:
MERGE INTO Sales.LoyaltyProgram AS target
USING (VALUES
    (1, 'Bronze', 0, 5.00),
    (2, 'Silver', 10000, 10.00),
    (3, 'Gold', 25000, 15.00),
    (4, 'Platinum', 50000, 20.00)
) AS source (TierID, TierName, MinimumPoints, DiscountPercentage)
ON target.TierID = source.TierID
WHEN NOT MATCHED THEN
    INSERT (TierID, TierName, MinimumPoints, DiscountPercentage)
    VALUES (source.TierID, source.TierName, source.MinimumPoints, source.DiscountPercentage);
```

This ensures the migration is **idempotent** - safe to run multiple times.

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ `Sales.LoyaltyProgram` is marked for static data tracking in Flyway Desktop
- ✅ Schema model folder contains static data tracking information
- ✅ A migration with INSERT/MERGE statements exists in `migrations/` folder
- ✅ The migration includes all 4 loyalty tiers
- ✅ Changes are committed to source control
- ✅ You understand the difference between static and transactional data

## 🐛 Troubleshooting

### "Data not captured in Flyway Desktop"
**Problem:** Static data feature isn't capturing the table data.  
**Solution:**
- Ensure static data tracking is enabled in Flyway Desktop
- Verify the table has data in it
- Save changes in Flyway Desktop before generating migration
- Refresh the schema comparison

### "Duplicate key errors when deploying"
**Problem:** Data already exists in the target database.  
**Solution:**
- Check if Flyway generated a MERGE statement (safe to re-run)
- If using INSERT, make it idempotent with IF NOT EXISTS
- For Production, consider using environment-specific configuration

### "Migration generated but no INSERT statements"
**Problem:** Migration file is empty or schema-only.  
**Solution:**
- Verify static data tracking is enabled for the specific table
- Check that data exists in the table
- Regenerate the migration after confirming tracking is on

## 💡 Hints & Best Practices

### When to Track Static Data ✅
- Lookup tables (countries, currencies, statuses)
- Application configuration (settings, feature flags)
- Reference data (tax rates, business rules)
- Small tables (< 10,000 rows recommended)
- Data that's identical across all environments

### When NOT to Track Static Data ❌
- Transactional data (orders, customers, logs)
- Large datasets (> 100,000 rows)
- Frequently changing data
- Environment-specific data (test users, sample data)

### Making Safe Static Data Migrations
```sql
-- ✅ GOOD: Idempotent with MERGE
MERGE INTO Sales.LoyaltyProgram AS target...

-- ✅ GOOD: Idempotent with IF NOT EXISTS
IF NOT EXISTS (SELECT 1 FROM Sales.LoyaltyProgram WHERE TierID = 1)
    INSERT INTO Sales.LoyaltyProgram VALUES (1, 'Bronze', 0, 5.00);

-- ❌ RISKY: Plain INSERT (fails if data exists)
INSERT INTO Sales.LoyaltyProgram VALUES (1, 'Bronze', 0, 5.00);
```

## 🎓 Key Concepts Learned

- **Static Data Tracking:** How to version control reference data with Flyway
- **Schema Model Enhancement:** Static data becomes part of your desired state
- **Idempotent Migrations:** Writing migrations that are safe to run multiple times
- **Environment Consistency:** Ensuring all environments have the same reference data
- **Data vs Schema:** Understanding when to track data in version control

## 🚀 Real-World Applications

- **Multi-Environment Deployments:** Same reference data across Dev/Test/Prod
- **Disaster Recovery:** Complete database rebuild including configuration
- **Team Onboarding:** New developers get fully configured databases
- **Feature Flags:** Version control feature toggle configuration
- **Compliance:** Audit trail for configuration changes

## 🌟 Advanced Challenge (Optional)

Try updating the loyalty tier data:
1. **Change** the Gold tier discount from 15% to 18% directly in the database
2. **Capture** the change in Flyway Desktop
3. **Review** the generated UPDATE migration
4. **Commit** the change and understand how Flyway handles data updates

## 📚 Next Steps

Continue your development journey:

1. **`Development/Merging-Changes`** - Learn to handle changes from multiple developers
2. **`Development/Schema-Normalization`** - Practice safe schema refactoring
3. **`Operations/Deployment-Validation`** - See how to validate before production
4. **`Scenarios/Stored-Procedures`** - Explore how Flyway handles database code

---

**Congratulations!** 🎉 You can now version control both schema AND reference data with Flyway.
