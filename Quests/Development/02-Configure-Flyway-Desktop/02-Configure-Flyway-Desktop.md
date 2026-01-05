# Development Quest 02 - Configure Flyway Desktop

**Difficulty:** 🟢 Beginner  
**Time:** 20-25 minutes  
**Prerequisites:** Completed Quest 01 (Clone Project), Flyway Desktop installed, access to development database

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to configure Flyway Desktop to connect to your development database
- Understanding user settings vs. project settings
- Knowing what should and should not be committed to version control
- Configuring authentication for SQL Server
- Referencing official documentation for advanced scenarios

## 📖 Scenario
You've cloned the Flyway project successfully, but Flyway Desktop can't connect to your development database yet. The project's `flyway.toml` file contains environment definitions, but the actual connection credentials are stored separately for security reasons. You need to configure your personal development database connection so you can start capturing schema changes.

## 🎯 Your Mission
Configure Flyway Desktop to connect to your development database using secure, user-specific settings that won't be committed to the repository.

## 📝 Steps

### Step 1: Understand User Settings vs. Project Settings

**Project Settings** (`flyway.toml` - COMMITTED to Git):
- Environment names (development, test, production)
- Schema model location
- Migration folder location
- Shared team configuration
- Placeholders (without sensitive values)

**User Settings** (Local only - NOT COMMITTED):
- Database connection strings
- Passwords and credentials
- Personal preferences
- Environment-specific values
- File locations specific to your machine

**🔑 Key Principle:** Never commit passwords or sensitive connection details to Git!

### Step 2: Locate Your Development Database Details

Before configuring, gather this information:

```
Server: localhost (or your SQL Server instance name)
Database: AutopilotDev (or your dev database name)
Authentication: 
  - Windows Authentication (recommended for local dev)
  - OR SQL Server Authentication (username/password)
Port: 1433 (default, may differ)
```

**To find your SQL Server instance:**
```powershell
# List running SQL Server instances
Get-Service | Where-Object {$_.Name -like '*SQL*'}

# Or check in SQL Server Management Studio (SSMS)
# Server name shows in the connection dialog
```

### Step 3: Configure Development Database Connection in Flyway Desktop

**Option A: Using Flyway Desktop UI (Recommended)**

1. **Open Flyway Desktop**

2. **Navigate to Settings/Preferences**
   - Look for **Settings**, **Preferences**, or **Configuration** menu

3. **Find Environment Configuration**
   - Locate **Environments** or **Connections** section
   - Select **development** environment

4. **Configure the Connection**

   **For Windows Authentication (recommended):**
   ```
   Server: localhost
   Database: AutopilotDev
   Authentication: Windows Authentication
   Port: 1433 (default)
   ```

   **For SQL Server Authentication:**
   ```
   Server: localhost
   Database: AutopilotDev
   Authentication: SQL Server Authentication
   Username: your_username
   Password: your_password
   Port: 1433 (default)
   ```

5. **Test the Connection**
   - Click **Test Connection** button
   - Verify you see: ✅ "Connection successful"
   - If it fails, see Troubleshooting section

6. **Save the Configuration**
   - Click **Save** or **Apply**
   - Flyway Desktop stores this in your user settings (not in the project)

**Option B: Using User Configuration File**

Flyway Desktop creates a user-specific configuration file:

**Location:** `%USERPROFILE%\.flyway\flyway-desktop.user.toml`  
(Example: `C:\Users\YourName\.flyway\flyway-desktop.user.toml`)

**Edit this file:**
```toml
[environments.development]
url = "jdbc:sqlserver://localhost:1433;databaseName=AutopilotDev;encrypt=true;trustServerCertificate=true;integratedSecurity=true"

# Or for SQL Authentication:
# url = "jdbc:sqlserver://localhost:1433;databaseName=AutopilotDev;encrypt=true;trustServerCertificate=true"
# user = "your_username"
# password = "your_password"
```

**Save the file** and restart Flyway Desktop.

### Step 4: Verify Project Settings Remain Unchanged

**Check `flyway.toml` in your project:**
```powershell
code flyway.toml
```

It should still contain **placeholders or environment references**, NOT actual passwords:

```toml
[environments.development]
url = "jdbc:sqlserver://localhost:1433;databaseName=${developmentDatabase}"
# No password here - that's correct!

[environments.test]
url = "jdbc:sqlserver://testserver:1433;databaseName=${testDatabase}"
# Placeholders only

[environments.production]
url = "jdbc:sqlserver://prodserver:1433;databaseName=${productionDatabase}"
# Never commit production credentials!
```

**✅ Good:** Placeholders like `${developmentDatabase}`  
**❌ Bad:** Hardcoded passwords in `flyway.toml`

### Step 5: Understand What Should and Should Not Be Committed

**✅ Commit to Git (Project Settings):**
- `flyway.toml` (with placeholders)
- `schema-model/` folder and contents
- `migrations/` folder and contents
- `README.md` and documentation
- `.gitignore` file
- CI/CD pipeline files

**❌ DO NOT Commit (User Settings):**
- `flyway-desktop.user.toml` (user-specific config)
- Any files with passwords or credentials
- Local database backups
- Personal notes or scratch files
- IDE-specific settings (unless team agrees)

**Verify `.gitignore` contains:**
```
# Flyway Desktop user settings
.flyway/
*.user.toml

# Credentials and secrets
*.env
secrets.*
*.key
```

### Step 6: Test Your Configuration

1. **Open Flyway Desktop**

2. **Verify connection status**
   - Look for a connection indicator (green checkmark, "Connected", etc.)
   - The development environment should show as connected

3. **Browse your database**
   - Navigate to the schema browser/explorer
   - You should see your database objects (tables, views, etc.)

4. **Check schema model comparison**
   - Flyway Desktop should be able to compare your dev database to the schema model
   - No errors should appear

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Flyway Desktop connects to your development database
- ✅ Connection uses secure, user-specific settings
- ✅ You can browse database objects in Flyway Desktop
- ✅ `flyway.toml` remains unchanged (no passwords committed)
- ✅ You understand what goes in user settings vs. project settings
- ✅ You know what should and should not be committed to Git

## 🐛 Troubleshooting

### "Connection failed - Cannot connect to server"
**Problem:** Flyway Desktop can't reach SQL Server.  
**Solution:**
- Verify SQL Server is running: `Get-Service MSSQLSERVER`
- Check server name (might be `localhost\SQLEXPRESS`)
- Verify firewall allows SQL Server connections
- Test connection in SSMS first with same credentials

### "Login failed for user"
**Problem:** Authentication error.  
**Solution:**
- For Windows Auth: Run Flyway Desktop as the user with database access
- For SQL Auth: Verify username/password are correct
- Check user has permissions on the database
- Grant access if needed:
  ```sql
  USE AutopilotDev;
  CREATE USER [YourUsername] FOR LOGIN [YourLogin];
  ALTER ROLE db_owner ADD MEMBER [YourUsername];
  ```

### "SSL/TLS encryption error"
**Problem:** Certificate validation fails.  
**Solution:**
- Add to connection string: `encrypt=true;trustServerCertificate=true`
- Or configure proper SSL certificates (see documentation)

### "Database not found"
**Problem:** Specified database doesn't exist.  
**Solution:**
- Verify database name is correct (case-sensitive in some cases)
- Create the database if it doesn't exist:
  ```sql
  CREATE DATABASE AutopilotDev;
  ```
- Check you have access: `SELECT name FROM sys.databases;`

### "Changes to flyway.toml not taking effect"
**Problem:** Updated `flyway.toml` but connection still fails.  
**Solution:**
- Don't put credentials in `flyway.toml` - use user settings instead
- Restart Flyway Desktop after configuration changes
- Check user settings override project settings

## 💡 Best Practices

### Use Windows Authentication When Possible ✅
```toml
# Recommended for local development
url = "jdbc:sqlserver://localhost:1433;databaseName=AutopilotDev;integratedSecurity=true"
```
**Why:** No password to manage, leverages existing Windows security

### Use Placeholders for Environment-Specific Values ✅
```toml
# In flyway.toml (committed)
[flyway.placeholders]
developmentDatabase = "AutopilotDev"
testDatabase = "AutopilotTest"

# In user settings (not committed)
[environments.development]
url = "jdbc:sqlserver://localhost:1433;databaseName=${developmentDatabase}"
```

### Document Your Configuration Requirements ✅
Create a `SETUP.md` in your project:
```markdown
## Developer Setup

1. Install Flyway Desktop
2. Configure development database connection:
   - Server: localhost (or localhost\SQLEXPRESS)
   - Database: AutopilotDev
   - Auth: Windows Authentication
3. Test connection in Flyway Desktop
```

### Keep User Settings Secure ✅
- Never share your `flyway-desktop.user.toml` file
- Don't paste connection strings in Slack/Teams
- Use password managers for SQL Auth credentials

## 🎓 Key Concepts Learned

- **User vs. Project Settings:** Separation of shared config and personal credentials
- **Security:** Never commit passwords or sensitive data
- **JDBC URLs:** Connection string format for SQL Server
- **Authentication Methods:** Windows Auth vs. SQL Server Auth
- **Configuration Hierarchy:** How Flyway resolves settings from multiple sources

## 🚀 Real-World Applications

- **Team Onboarding:** Each developer configures their own dev database
- **Multiple Environments:** Same project, different personal settings per environment
- **Security Compliance:** Credentials never in version control
- **Flexibility:** Developers can use different database servers/instances
- **CI/CD:** Build servers use environment variables, not user settings

## 📚 Advanced Configuration (Optional)

### Using Environment Variables
```toml
# In flyway.toml
[environments.development]
url = "${DEV_DATABASE_URL}"
user = "${DEV_DATABASE_USER}"
password = "${DEV_DATABASE_PASSWORD}"
```

Then set environment variables:
```powershell
$env:DEV_DATABASE_URL = "jdbc:sqlserver://localhost:1433;databaseName=AutopilotDev"
$env:DEV_DATABASE_USER = "dev_user"
$env:DEV_DATABASE_PASSWORD = "secure_password"
```

### Advanced JDBC URL Options
```
jdbc:sqlserver://server:1433;
  databaseName=YourDB;
  encrypt=true;
  trustServerCertificate=false;
  loginTimeout=30;
  applicationName=FlywayDesktop;
```

**Reference:** [SQL Server JDBC Connection String](https://docs.microsoft.com/en-us/sql/connect/jdbc/building-the-connection-url)

### Certificates and Encryption
For production-grade security with proper SSL/TLS certificates:

**Reference:** [Flyway Authentication Documentation](https://documentation.red-gate.com/fd/authentication-184549862.html)

## 📚 Next Steps

Now that Flyway Desktop is connected to your development database, proceed to:

**Quest 03: Validate Environment Sync** - Ensure your dev database is in sync with the schema model

---

**Congratulations!** 🎉 You've successfully configured Flyway Desktop and understand the security principles of managing database credentials!
