# Development Quest 01 - Clone Project from Git

**Difficulty:** 🟢 Beginner  
**Time:** 15-20 minutes  
**Prerequisites:** Git installed, Flyway Desktop installed, access to repository

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to clone an existing Flyway state-based project
- How to open a Flyway project in Flyway Desktop
- Understanding the basic project layout and folder structure
- Knowing where schema changes should and should not be made
- Recognizing key project files and their purposes

## 📖 Scenario
You're joining a development team that's already using Flyway for database version control. The project repository contains a state-based Flyway project with a schema model, configuration files, and CI/CD pipelines. Your first task is to clone the project and get it set up on your local machine so you can start contributing.

## 🎯 Your Mission
Clone the Flyway project from Git, open it successfully in Flyway Desktop, and understand the project structure.

## 📝 Steps

### Step 1: Clone the Repository

1. **Get the repository URL** from your team or Git hosting service (GitHub, Azure DevOps, GitLab, etc.)

2. **Choose a local directory** for your Flyway projects
   ```powershell
   # Example: Create a workspace directory
   mkdir C:\Flyway-Projects
   cd C:\Flyway-Projects
   ```

3. **Clone the repository**
   ```powershell
   # Replace with your actual repository URL
   git clone https://github.com/YourOrg/YourFlywayProject.git
   
   # Or for Azure DevOps:
   git clone https://dev.azure.com/YourOrg/YourProject/_git/YourFlywayProject
   ```

4. **Navigate into the cloned directory**
   ```powershell
   cd YourFlywayProject
   ```

5. **Verify the clone succeeded**
   ```powershell
   # List the contents
   Get-ChildItem
   
   # You should see folders like:
   # - schema-model/
   # - migrations/ (may be empty initially)
   # - flyway.toml (or flyway.conf)
   ```

### Step 2: Understand the Project Structure

A typical Flyway state-based project has this structure:

```
YourFlywayProject/
├── flyway.toml                    # Main Flyway configuration
├── schema-model/                  # Your desired database state
│   ├── Tables/                    # Table definitions
│   ├── Views/                     # View definitions
│   ├── Stored Procedures/         # Stored procedure definitions
│   ├── Functions/                 # Function definitions
│   └── Security/
│       └── Schemas/               # Schema definitions
├── migrations/                    # Generated versioned migration scripts
│   └── V001__Initial_setup.sql   # (example - may be empty)
├── AzureDevOps/                   # CI/CD pipeline files (optional)
└── README.md                      # Project documentation
```

**Key Points:**
- **schema-model/** = Source of truth for your database structure
- **migrations/** = Deployment scripts generated from schema-model
- **flyway.toml** = Configuration (connections, environments, settings)

### Step 3: Review Key Files

**1. Open and examine `flyway.toml`**
```powershell
code flyway.toml  # Or use your preferred editor
```

Look for these sections:
- `[environments.development]` - Dev database connection
- `[environments.test]` - Test database connection
- `[environments.production]` - Production database connection
- `[flyway]` - Global Flyway settings

**Important:** Connection strings may use placeholders or environment variables for security.

**2. Browse the `schema-model/` folder**
```powershell
Get-ChildItem -Path schema-model -Recurse
```

This folder contains `.sql` files representing your database objects in their desired state.

**Example:** `schema-model/Tables/Sales.Customers.sql`
```sql
CREATE TABLE Sales.Customers (
    CustomerID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(100) NOT NULL
);
```

**3. Check the `migrations/` folder**
```powershell
Get-ChildItem -Path migrations
```

This may be empty if it's a new project, or contain versioned migration scripts if deployments have already occurred.

### Step 4: Open Project in Flyway Desktop

1. **Launch Flyway Desktop**

2. **Open the project**
   - Click **File → Open Project** (or similar)
   - Navigate to your cloned project directory
   - Select the folder containing `flyway.toml`
   - Click **Open**

3. **Flyway Desktop loads the project**
   - It reads the `flyway.toml` configuration
   - It scans the `schema-model/` folder
   - It detects your project structure

4. **Verify successful project load**
   - You should see your schema model objects in the UI
   - The environments (dev, test, prod) should be visible
   - No errors should appear in the output/log window

### Step 5: Understand Where Changes Should Be Made

**✅ DO make changes here:**
- **Your development database** (via SSMS, Azure Data Studio, etc.)
- Then **capture those changes** into the schema-model using Flyway Desktop

**❌ DO NOT manually edit:**
- Files in `schema-model/` folder (Flyway Desktop manages these)
- Files in `migrations/` folder (Flyway Desktop generates these)

**State-Based Workflow:**
1. Make changes in your **Dev database** (SSMS/Azure Data Studio)
2. Use **Flyway Desktop** to compare Dev vs schema-model
3. **Capture changes** from Dev into schema-model
4. Flyway Desktop updates the schema-model files
5. **Commit** the updated schema-model to Git

**🔑 Key Principle:** The database is your workspace, Flyway Desktop is your tool to capture state into version control.

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Repository cloned to your local machine
- ✅ Project structure understood (schema-model, migrations, config)
- ✅ Project opens successfully in Flyway Desktop
- ✅ You can see your schema model objects in the UI
- ✅ You understand where to make changes (database first, capture second)
- ✅ You know what files to edit vs. what Flyway manages

## 🐛 Troubleshooting

### "Flyway Desktop won't open the project"
**Problem:** Error when opening the project folder.  
**Solution:**
- Ensure `flyway.toml` exists in the root folder
- Check for syntax errors in `flyway.toml`
- Verify you selected the correct folder (not a subfolder)

### "Schema model folder is empty"
**Problem:** No objects visible in Flyway Desktop.  
**Solution:**
- Check if `schema-model/` folder actually contains `.sql` files
- If truly empty, this is a brand-new project - that's okay!
- You'll populate it in upcoming quests

### "Git clone failed - authentication error"
**Problem:** Can't clone the repository.  
**Solution:**
- Verify you have repository access (ask your team lead)
- Set up authentication (SSH keys or personal access tokens)
- For Azure DevOps: Use Git Credential Manager
- For GitHub: Use personal access token or SSH key

### "Connection strings contain placeholders"
**Problem:** `flyway.toml` shows `${DB_PASSWORD}` or similar.  
**Solution:**
- This is normal and secure - credentials shouldn't be committed
- You'll configure these in Quest 02 (Configure Flyway Desktop)
- Placeholders are resolved from environment variables or user settings

## 💡 Best Practices

### Clone to a Consistent Location ✅
```powershell
# Good - organized workspace
C:\Flyway-Projects\ProjectName\

# Avoid - scattered locations
C:\Users\YourName\Desktop\random-folder\project\
```

### Check for a README ✅
Most projects include a `README.md` with:
- Project-specific setup instructions
- Team conventions
- Environment-specific notes
- Contact information

### Understand the Branch Strategy ✅
```powershell
# Check current branch
git branch

# See all branches
git branch -a

# Most teams use:
# - main/master (production-ready)
# - develop (integration)
# - feature/* (your work)
```

Ask your team: "Which branch should I work from?"

### Don't Commit Secrets ❌
Never commit:
- Database passwords
- API keys
- Personal access tokens
- Connection strings with embedded credentials

These belong in:
- User-specific settings (not committed)
- Environment variables
- Secure secret management systems

## 🎓 Key Concepts Learned

- **State-Based Projects:** Schema model represents desired state, not migration scripts
- **Schema Model:** Single source of truth for database structure
- **Flyway Desktop:** Tool for comparing, capturing, and managing state
- **Project Structure:** Organized folders for schema, migrations, and config
- **Workflow:** Database → Flyway Desktop → Schema Model → Git

## 🚀 Real-World Applications

- **Team Onboarding:** New developers clone and start contributing quickly
- **Environment Setup:** Consistent project structure across team
- **Disaster Recovery:** Full database schema in version control
- **Collaboration:** Everyone works from the same schema model
- **Audit Trail:** Complete history of schema changes in Git

## 📚 Next Steps

Now that you have the project cloned and understand the structure, proceed to:

**Quest 02: Configure Flyway Desktop** - Set up your development database connection and user settings

---

**Congratulations!** 🎉 You've successfully cloned your first Flyway state-based project and understand the basic structure. You're ready to start configuring Flyway Desktop!
