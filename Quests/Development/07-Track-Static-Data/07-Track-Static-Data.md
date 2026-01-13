# Development Quest 07 - Track Static Data

**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Prerequisites:** Flyway Desktop configured, understanding of schema model capture

## 🎯 Learning Objectives
By completing this quest, you will learn:
- Understanding what static/reference data is
- How to configure Flyway Desktop to track static data
- Capturing static data changes into the schema model
- Understanding when data belongs in version control vs. when it doesn't

## 📖 Scenario
Your loyalty program has configuration data (Bronze, Silver, Gold, Platinum tiers) that must be identical across all environments. This reference data is essential for the application to function. You need to track this data in version control so it deploys automatically with schema changes.

## 🎯 Your Mission
Configure Flyway Desktop to track static data for the `Sales.LoyaltyProgram` table and capture the tier configuration data into the schema model.

## 📋 What is Static Data?

**✅ Static Data (version control this!):**
- Lookup tables (countries, states, product categories)
- Configuration data (loyalty tiers, system settings)
- Reference data (tax rates, business rules)
- **Characteristics:** Rarely changes, needed for app to function, same across all environments

**❌ Transactional Data (don't version control this!):**
- Customer records, orders, activity logs
- **Characteristics:** Changes frequently, different per environment, business data

## 📝 Steps

### Step 1: Create the Loyalty Program Table

```sql
CREATE TABLE Sales.LoyaltyProgram (
    TierID INT PRIMARY KEY,
    TierName NVARCHAR(50) NOT NULL,
    MinimumPoints INT NOT NULL,
    DiscountPercentage DECIMAL(5,2) NOT NULL
);

-- Insert reference data
INSERT INTO Sales.LoyaltyProgram VALUES
    (1, 'Bronze', 0, 5.00),
    (2, 'Silver', 10000, 10.00),
    (3, 'Gold', 25000, 15.00),
    (4, 'Platinum', 50000, 20.00);
```

### Step 2: Configure Static Data Tracking in Flyway Desktop

1. **Open Flyway Desktop**
2. **Navigate to Static Data settings:**
   - Look for **"Static Data"** or **"Data Compare"** feature
   - Or in project settings/configuration
  
    <img width="1920" height="1032" alt="image" src="https://github.com/user-attachments/assets/d05e745e-89cb-4067-82c7-9bef11c60225" />


3. **Mark table for static data tracking:**
   - Find `Sales.LoyaltyProgram` in table list
   - Enable static data tracking for this table
   - Flyway will now track both schema AND data

4. **Configure comparison options:**
   - Include all columns in comparison
   - Set primary key for row identification (Tier ID)

### Step 3: Capture the Data

1. **Run comparison** (Schema Model vs. Development)
2. **Flyway detects:**
   - Table structure (`Sales.LoyaltyProgram`)
   - Table data (4 rows of tier information)

3. **Capture both schema and data:**
   - Select table and data for capture
   - Flyway creates/updates schema model files

**Files created:**
```
schema-model/
├── Tables/
│   └── Sales.LoyaltyProgram.sql      (table structure)
└── Data/
    └── Sales.LoyaltyProgram.sql       (data INSERT statements)
```

### Step 4: Review Generated Data File

```powershell
code schema-model\Data\Sales.LoyaltyProgram.sql
```

**Expected content:**
```sql
-- Static data for Sales.LoyaltyProgram
INSERT INTO [Sales].[LoyaltyProgram] ([TierID], [TierName], [MinimumPoints], [DiscountPercentage])
VALUES
    (1, N'Bronze', 0, 5.00),
    (2, N'Silver', 10000, 10.00),
    (3, N'Gold', 25000, 15.00),
    (4, N'Platinum', 50000, 20.00);
```

### Step 5: Handle Data Updates

**When tier data changes:**

```sql
-- Update discount percentage for Gold tier
UPDATE Sales.LoyaltyProgram
SET DiscountPercentage = 17.50
WHERE TierID = 3;
```

**Recapture in Flyway Desktop:**
1. Run comparison
2. Flyway detects data change
3. Recapture static data
4. Data file updated with new values

### Step 6: Commit Static Data Changes

```powershell
git add schema-model/Tables/Sales.LoyaltyProgram.sql
git add schema-model/Data/Sales.LoyaltyProgram.sql

git commit -m "Add Sales.LoyaltyProgram table with loyalty tier configuration data"

git push origin develop
```

## ✅ Success Criteria

- ✅ Created loyalty program table with reference data
- ✅ Configured static data tracking in Flyway Desktop
- ✅ Captured table structure and data into schema model
- ✅ Understand when to track data vs. schema only
- ✅ Can update static data and recapture changes

## 🐛 Troubleshooting

### "Flyway Desktop doesn't show static data option"
**Solution:** Ensure you have Flyway Enterprise edition. Static data tracking requires Enterprise features.

### "Data file contains thousands of rows"
**Problem:** Accidentally tracked transactional data.  
**Solution:** Remove static data tracking for that table. Only track small reference tables.

## 💡 Best Practices

### Only Track Small Reference Tables ✅
```
Good: 10-100 rows of configuration data
Avoid: Tables with thousands or millions of rows
```

### Version Control What's Needed for App to Function ✅
```
✓ Country/state lookup tables
✓ Product category hierarchies
✓ System configuration settings
✓ Business rule parameters

✗ Customer data
✗ Order history
✗ Transaction logs
```

## 📚 Next Steps

**Quest 08: Feature Branch Workflow** - Learn to work in feature branches

---

**Congratulations!** 🎉 You now know how to track reference data alongside schema changes!
