# Development Quest 11 - Placeholders for Environment-Specific Values

**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Prerequisites:** Understanding of flyway.toml configuration, completed basic quests

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to use Flyway placeholders for environment-specific values
- Handling differences between Dev, Test, and Production environments
- Where placeholders are defined and how they're resolved
- Using placeholders in schema model objects
- Best practices for environment configuration

## 📖 Scenario
Your stored procedures need to reference different linked servers in Dev vs. Production. Dev uses `DEV_LinkedServer` while Production uses `PROD_LinkedServer`. Rather than maintaining separate versions of the procedure, you'll use Flyway placeholders to handle environment-specific values.

**Reference:** [Flyway Placeholders Namespace Documentation](https://documentation.red-gate.com/fd/flyway-placeholders-namespace-277579022.html)

## 🎯 Your Mission
Create a stored procedure that uses placeholders for environment-specific values and configure different placeholder values for Dev and Production environments.

## 📝 Steps

### Step 1: Define Placeholders in flyway.toml

**Edit your project's `flyway.toml`:**

```toml
# Global placeholder definitions
[flyway.placeholders]
appName = "Airline Management System"
version = "1.0"

# Development environment placeholders
[environments.development.flyway.placeholders]
linkedServer = "DEV_LinkedServer"
emailDomain = "@dev.company.com"
maxRetries = "3"

# Test environment placeholders
[environments.test.flyway.placeholders]
linkedServer = "TEST_LinkedServer"
emailDomain = "@test.company.com"
maxRetries = "5"

# Production environment placeholders
[environments.production.flyway.placeholders]
linkedServer = "PROD_LinkedServer"
emailDomain = "@company.com"
maxRetries = "10"
```

### Step 2: Use Placeholders in Database Objects

**Create a stored procedure with placeholders:**

```sql
CREATE PROCEDURE Logistics.GetExternalFlightData
    @FlightNumber NVARCHAR(20)
AS
BEGIN
    -- Use placeholder for linked server
    SELECT *
    FROM [${linkedServer}].ExternalDB.dbo.Flights
    WHERE FlightNumber = @FlightNumber;
    
    -- Use placeholder for email domain
    DECLARE @NotificationEmail NVARCHAR(100) = 'alerts${emailDomain}';
    
    -- Use placeholder for retry logic
    DECLARE @MaxRetries INT = ${maxRetries};
    
    PRINT 'Notification Email: ' + @NotificationEmail;
    PRINT 'Max Retries: ' + CAST(@MaxRetries AS NVARCHAR);
END;
```

**Placeholders in the code:**
- `${linkedServer}` - Resolves to different servers per environment
- `${emailDomain}` - Environment-specific email domains
- `${maxRetries}` - Different retry counts per environment

### Step 3: Capture the Object into Schema Model

1. **Create the procedure in your Dev database** (execute the SQL above)
2. **Open Flyway Desktop**
3. **Run comparison** and detect the new procedure
4. **Capture into schema model**

**File created:** `schema-model/Stored Procedures/Logistics.GetExternalFlightData.sql`

### Step 4: Verify Placeholder Resolution

**In Development environment:**
```sql
-- Flyway resolves ${linkedServer} to "DEV_LinkedServer"
-- Deployed procedure contains:
SELECT * FROM [DEV_LinkedServer].ExternalDB.dbo.Flights ...

-- Flyway resolves ${emailDomain} to "@dev.company.com"
DECLARE @NotificationEmail NVARCHAR(100) = 'alerts@dev.company.com';
```

**In Production environment:**
```sql
-- Flyway resolves ${linkedServer} to "PROD_LinkedServer"
-- Deployed procedure contains:
SELECT * FROM [PROD_LinkedServer].ExternalDB.dbo.Flights ...

-- Flyway resolves ${emailDomain} to "@company.com"
DECLARE @NotificationEmail NVARCHAR(100) = 'alerts@company.com';
```

### Step 5: Test Placeholder Resolution

**Check how Flyway will resolve placeholders:**

```powershell
# View resolved configuration for development
flyway info -environment=development

# View resolved configuration for production
flyway info -environment=production
```

### Step 6: Common Placeholder Use Cases

**1. File Paths:**
```toml
[environments.development.flyway.placeholders]
backupPath = "C:\\DevBackups"

[environments.production.flyway.placeholders]
backupPath = "\\\\ProdServer\\Backups"
```

**2. Database Names:**
```toml
[environments.development.flyway.placeholders]
warehouseDB = "DataWarehouse_Dev"

[environments.production.flyway.placeholders]
warehouseDB = "DataWarehouse"
```

**3. Configuration Values:**
```toml
[environments.development.flyway.placeholders]
sessionTimeout = "30"
debugMode = "1"

[environments.production.flyway.placeholders]
sessionTimeout = "300"
debugMode = "0"
```

## ✅ Success Criteria

- ✅ Defined placeholders in flyway.toml
- ✅ Created database object using placeholders
- ✅ Captured object with placeholders into schema model
- ✅ Understand how placeholders resolve per environment
- ✅ Know common use cases for placeholders
- ✅ Verified different values in Dev vs. Prod

## 🐛 Troubleshooting

### "Placeholder not resolved - appears as ${placeholder} in deployed object"
**Problem:** Flyway didn't replace the placeholder.  
**Solution:**
- Verify placeholder defined in flyway.toml
- Check spelling matches exactly (case-sensitive)
- Ensure using correct environment
- Restart Flyway Desktop after toml changes

### "Placeholder works in Dev but not in Prod"
**Problem:** Environment-specific placeholder not defined.  
**Solution:**
- Check `[environments.production.flyway.placeholders]` section exists
- Ensure placeholder defined for ALL environments
- Use global `[flyway.placeholders]` for shared values

### "Syntax error when using placeholder"
**Problem:** Placeholder used in wrong context.  
**Solution:**
- Placeholders are string replacements
- Cannot use in some SQL syntax contexts
- Test SQL with actual values first, then replace with placeholder

## 💡 Best Practices

### Use Descriptive Placeholder Names ✅
```toml
# Good
linkedServer = "DEV_LinkedServer"
maxRetryCount = "3"

# Avoid
ls = "DEV_LinkedServer"
x = "3"
```

### Document Placeholders ✅
```toml
# In flyway.toml, add comments:

[flyway.placeholders]
# Application name displayed in audit logs
appName = "Airline Management System"

# Linked server for external flight data integration
# Dev uses development instance, Prod uses production instance
[environments.development.flyway.placeholders]
linkedServer = "DEV_LinkedServer"
```

### Set Defaults Globally, Override Per Environment ✅
```toml
# Global default
[flyway.placeholders]
maxRetries = "5"

# Override in production only
[environments.production.flyway.placeholders]
maxRetries = "10"  # Higher for production

# Dev and Test inherit global default (5)
```

### Never Hardcode Environment-Specific Values ❌
```sql
-- Bad: Hardcoded
SELECT * FROM [PROD_LinkedServer].dbo.Data ...

-- Good: Placeholder
SELECT * FROM [${linkedServer}].dbo.Data ...
```

## 🎓 Key Concepts Learned

- **Placeholders:** Variables resolved at deployment time
- **Environment Configuration:** Different values per environment
- **Configuration Management:** Centralizing environment differences
- **Deployment Flexibility:** Same schema model deploys differently per environment
- **Namespace:** Using `${}` syntax for placeholder resolution

## 🚀 Real-World Applications

- **Multi-Environment Deployments:** Same code, different configs
- **Linked Servers:** Dev, Test, Prod servers
- **File Paths:** Environment-specific backup/log locations
- **API Endpoints:** Different URLs per environment
- **Feature Flags:** Enable/disable features by environment
- **Connection Strings:** Different databases per environment

## 📚 Advanced Scenarios (Optional)

### Nested Placeholders
```toml
[flyway.placeholders]
baseURL = "https://api.company.com"

[environments.development.flyway.placeholders]
baseURL = "https://api-dev.company.com"
apiEndpoint = "${baseURL}/v1/flights"  # Resolves to full URL
```

### Conditional Logic with Placeholders
```sql
CREATE PROCEDURE dbo.ProcessOrders
AS
BEGIN
    -- Use placeholder for debug mode
    DECLARE @DebugMode BIT = ${debugMode};
    
    IF @DebugMode = 1
    BEGIN
        PRINT 'Debug mode enabled';
        -- Extra logging in dev
    END
END;
```

### Dynamic Object Names (Use Carefully)
```sql
-- Create environment-specific view name
CREATE VIEW Sales.CustomerOrders_${environmentName} AS
SELECT * FROM Sales.Orders;

-- Dev: Sales.CustomerOrders_Development
-- Prod: Sales.CustomerOrders_Production
```

## 📚 Reference Documentation

**Official Flyway Placeholders Documentation:**
https://documentation.red-gate.com/fd/flyway-placeholders-namespace-277579022.html

## 📚 Congratulations!

You've completed all 11 Development Quests! 🎉

You now understand:
- ✅ Cloning and configuring Flyway projects
- ✅ Validating environment synchronization
- ✅ Capturing new and modified objects
- ✅ Committing and collaborating with Git
- ✅ Working in feature branches
- ✅ Filtering comparisons
- ✅ Pulling teammates' changes
- ✅ Using placeholders for environment flexibility

**You're ready for production database development with Flyway!**

---

**Next:** Explore **Operations** quests to learn deployment workflows, or **Scenarios** quests to test advanced database patterns.
