<<<<<<< Updated upstream
# Flyway Quests - Your Learning Journey

## 🎯 About Flyway Quests

**Flyway Quests** are your hands-on learning companion for mastering Flyway in real-world scenarios. Whether you're coming from a Flyway Autopilot POC, rolling out Flyway to your organization, or simply want to level up your database DevOps skills, these quests provide practical, scenario-based learning.

### 🔄 Quests vs. Flyway Autopilot

**Flyway Autopilot** gets you started - it sets up your environment, creates sample databases, and gives you a ready-to-use project with version control and CI/CD pipelines configured.

**Flyway Quests** take you further - they're your ongoing learning journey to master Flyway workflows, test real-world scenarios, and build confidence using the tool in your daily work.

> 💡 **Use Quests standalone or after Autopilot** - whether you're in POC phase, rollout, or ongoing operations, these quests help you learn by doing.

---

## 📁 Quest Categories

### 👨‍💻 Development
**Focus:** Daily workflows for developers working with database changes

Learn how to capture changes, work with branches, synchronize with your team, and manage version control alongside your SQL development work. These quests mirror real development workflows, not just SQL exercises.

### 🔧 Operations  
**Focus:** Deployment workflows, validation, and production releases

Master the deployment side of CI/CD - from validating changes before production to deploying via GUI and CLI. Learn safety checks, pipeline integration, and operational best practices.

### 🧪 Scenarios
**Focus:** Testing how Flyway handles different database objects and situations

Create and test various database scenarios - stored procedures, constraints, cross-schema references, triggers, and more. Perfect for exploring "what if" situations during POCs or validating Flyway behavior for your specific needs.

---

## 📚 Available Quests

### 👨‍💻 Development Quests

#### 🟢 01 - Clone Project from Git
**What you'll learn:** Clone and open a Flyway state-based project  
**Time:** 15-20 minutes | **Difficulty:** Beginner  
**Prerequisites:** Git installed, Flyway Desktop installed  
**Topics:** Project structure, schema model, opening projects, understanding folder layout

Clone an existing Flyway project, open it in Flyway Desktop, and understand where schema changes should be made.

**📁 Location:** `Development/01-Clone-Project/`

---

#### 🟢 02 - Configure Flyway Desktop
**What you'll learn:** Connect Flyway Desktop to your development database  
**Time:** 20-25 minutes | **Difficulty:** Beginner  
**Prerequisites:** Completed Quest 01, access to development database  
**Topics:** User settings, project settings, authentication, connection configuration

Configure Flyway Desktop connections securely and understand what should/shouldn't be committed to Git.

**📁 Location:** `Development/02-Configure-Flyway-Desktop/`

---

#### 🟡 03 - Validate Environment Sync
**What you'll learn:** Verify dev database matches schema model  
**Time:** 25-30 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Completed Quest 02, Flyway Desktop connected  
**Topics:** Drift detection, synchronization, comparison, state validation

Critical validation step - ensure your database is in sync with the schema model before starting work.

**📁 Location:** `Development/03-Validate-Environment-Sync/`

---

#### 🟢 04 - Capture New Changes
**What you'll learn:** Make schema changes and capture them into schema model  
**Time:** 20-25 minutes | **Difficulty:** Beginner  
**Prerequisites:** Completed Quest 03, environment in sync  
**Topics:** State-based workflow, detecting changes, schema model capture

Create new database objects and use Flyway Desktop to capture them into the schema model.

**📁 Location:** `Development/04-Capture-New-Changes/`

---

#### 🟢 05 - Commit and Push
**What you'll learn:** Commit captured changes to Git and share with team  
**Time:** 15-20 minutes | **Difficulty:** Beginner  
**Prerequisites:** Completed Quest 04, captured changes exist  
**Topics:** Git workflow, commit messages, pushing changes, branching basics

Learn to commit schema model changes to Git with clear messages and push to the remote repository.

**📁 Location:** `Development/05-Commit-and-Push/`

---

#### 🟢 06 - Modify Existing Object
**What you'll learn:** Modify existing database objects and recapture state  
**Time:** 15-20 minutes | **Difficulty:** Beginner  
**Prerequisites:** Completed Quests 04-05  
**Topics:** Modifying objects, recapturing state, state-based mindset

Modify an existing table and recapture its updated definition - reinforcing state-based thinking.

**📁 Location:** `Development/06-Modify-Existing-Object/`

---

#### 🟡 07 - Track Static Data
**What you'll learn:** Version control reference and configuration data  
**Time:** 25-30 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Flyway Desktop configured, understanding of schema model  
**Topics:** Static data tracking, reference data, data vs. schema

Configure Flyway to track reference data (lookup tables, configuration) alongside schema changes.

**📁 Location:** `Development/07-Track-Static-Data/`

---

#### 🟡 08 - Feature Branch Workflow
**What you'll learn:** Work in isolated feature branches  
**Time:** 20-25 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Completed Quests 04-05, basic Git knowledge  
**Topics:** Feature branches, isolated development, branch switching

Create feature branches for database development and avoid accidental commits to wrong branches.

**📁 Location:** `Development/08-Feature-Branch-Workflow/`

---

#### 🟡 09 - Filtering
**What you'll learn:** Control what Flyway compares and captures  
**Time:** 25-30 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Flyway Desktop configured, completed Quest 03  
**Topics:** Schema filters, object filters, comparison scope, noise reduction

Configure filters to include only relevant schemas/objects and exclude system objects and other teams' work.

**📁 Location:** `Development/09-Filtering/`

---

#### 🟡 10 - Pull Changes from Git
**What you'll learn:** Synchronize database with teammates' schema changes  
**Time:** 20-25 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Completed Quest 05, Git pull knowledge  
**Topics:** Pulling changes, synchronizing database, team collaboration

Pull schema model changes from teammates and synchronize your development database.

**📁 Location:** `Development/10-Pull-Changes/`

---

#### 🟡 11 - Placeholders
**What you'll learn:** Use placeholders for environment-specific values  
**Time:** 20-25 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Understanding of flyway.toml, completed basic quests  
**Topics:** Placeholders, environment configuration, dynamic values

Handle differences between Dev/Test/Production using Flyway placeholders in database objects.

**📁 Location:** `Development/11-Placeholders/`

---

### 🔧 Operations Quests

#### 🟡 Compare Environments
**What you'll learn:** Detect schema drift and compare database states  
**Time:** 20-25 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Flyway CLI installed, schema model configured  
**Topics:** Drift detection, environment comparison, schema model validation, flyway diff command

Use `flyway diff` to compare your schema model against target environments and identify differences.

**📁 Location:** `Operations/Compare-Environments/`

---

#### 🟡 Validate Schema Model
**What you'll learn:** Ensure your schema model is valid and deployable  
**Time:** 20-25 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Flyway CLI installed, schema model exists  
**Topics:** Schema model validation, object dependencies, syntax checking, flyway model command

Validate your schema model to catch issues before generating deployment scripts.

**📁 Location:** `Operations/Validate-Schema-Model/`

---

#### 🟡 Generate Deployment Script
**What you'll learn:** Create deployment migration scripts from your schema model  
**Time:** 25-30 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Completed Compare-Environments and Validate-Schema-Model quests  
**Topics:** Migration generation, versioned scripts, deployment preparation, flyway generate command

Generate versioned deployment scripts that transform your target database to match your schema model.

**📁 Location:** `Operations/Generate-Deployment-Script/`

---

#### 🟡 Execute Deployment
**What you'll learn:** Deploy changes to target environments safely  
**Time:** 20-30 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Completed Compare-Environments, Validate-Schema-Model, and Generate-Deployment-Script quests  
**Topics:** Migration execution, deployment verification, rollback strategies, flyway migrate command

Execute generated deployment scripts and verify successful deployment to target environments.

**📁 Location:** `Operations/Execute-Deployment/`

---

#### 🟡 Deployment Validation
**What you'll learn:** Validate deployments before production using Flyway Check  
**Time:** 35-45 minutes | **Difficulty:** Intermediate  
**Prerequisites:** Access to Azure DevOps pipeline, Flyway CLI  
**Topics:** Flyway Check reports, drift detection, CI/CD pipelines, validation gates

Use Flyway's Check feature to catch breaking changes, drift, and issues before they reach production.

**📁 Location:** `Operations/Deployment-Validation/`

---

### 🧪 Scenarios

#### 🔴 Stored Procedures
**What you'll learn:** How Flyway handles stored procedures, functions, and database code  
**Time:** 30-45 minutes | **Difficulty:** Advanced  
**Prerequisites:** Flyway Desktop, SQL programming experience  
**Topics:** Stored procedures, functions, repeatable migrations, database logic

Create stored procedures and functions to see how Flyway tracks and deploys database code objects.

**📁 Location:** `Scenarios/Stored-Procedures/`

---

#### 🔴 Callbacks
**What you'll learn:** Extend Flyway with lifecycle automation  
**Time:** 40-50 minutes | **Difficulty:** Advanced  
**Prerequisites:** Understanding of Flyway lifecycle, basic scripting  
**Topics:** Callback events, automation hooks, pre/post migration tasks

Add custom automation to Flyway's deployment lifecycle using callback scripts.

**📁 Location:** `Scenarios/Callbacks/`

---

## 🚀 Getting Started

### How to Choose a Quest

**Pick by what you need to learn, not by order!** Each quest is self-contained:

**New to Flyway?**
- Start with `Development/First-Capture` to learn the basics
- Then try `Development/Static-Data` to handle reference data

**Working in a team?**
- `Development/Merging-Changes` shows how to handle concurrent development

**Setting up CI/CD?**
- `Operations/Deployment-Validation` teaches deployment safety checks

**Testing scenarios during POC?**
- Explore `Scenarios/` to see how Flyway handles different database objects

### Prerequisites

- **Flyway Desktop** installed and licensed (Enterprise or trial)
- **Sample database** set up via Flyway Autopilot or manually
- **Git repository** configured (for Development quests)
- **Azure DevOps** pipeline access (for Operations quests only)
- **SQL Server Management Studio** or Azure Data Studio (optional but helpful)

### Quest Structure

Each quest folder contains:
- 📄 **{QuestName}.md** - Step-by-step guide with explanations
- 📄 **{QuestName}.sql** - Setup script to create the scenario

**Always run the .sql file first!** It creates the tables, data, or scenario you'll be working with.

Every quest guide includes:
- 🎯 **Learning Objectives** - What you'll master
- 📖 **Scenario** - Real-world context
- 📝 **Steps** - Clear, actionable instructions  
- 💡 **Code Examples** - Copy-paste ready SQL
- ✅ **Success Criteria** - How to validate you've succeeded
- 🐛 **Troubleshooting** - Common issues and fixes
- 🚀 **Advanced Challenges** - Optional extensions (where applicable)

---

## 💡 Tips for Success

### Best Practices ✅
- **Run the SQL setup script first** - Every quest includes a .sql file to set up the scenario
- **Take your time** - Understanding beats speed
- **Read hints sections** - They contain valuable context
- **Try advanced challenges** - Deepen your learning
- **Test as you go** - Validate each step before moving on

### Common Pitfalls ❌
- Don't skip the prerequisites
- Don't rush through scenarios without understanding
- Don't ignore error messages - they're learning opportunities
- Don't be afraid to experiment - you have sample databases for a reason

---

## 🎓 Learning Paths

### Path 1: Developer Workflow Mastery
Perfect for SQL developers learning Flyway's development workflow:
1. `Development/First-Capture` - Learn the basics
2. `Development/Static-Data` - Handle reference data
3. `Development/Merging-Changes` - Work with a team
4. `Development/Schema-Normalization` - Advanced refactoring

### Path 2: Operations & Deployment (State-Based CLI Workflow)
For DevOps engineers and DBAs handling deployments using Flyway CLI:
1. `Operations/Compare-Environments` - Compare environments and detect drift
2. `Operations/Validate-Schema-Model` - Validate schema model
3. `Operations/Generate-Deployment-Script` - Generate deployment scripts
4. `Operations/Execute-Deployment` - Execute deployments
5. `Operations/Deployment-Validation` - Add safety checks to CI/CD pipelines

### Path 3: POC Scenario Testing
Testing Flyway during a proof of concept:
- Start with `Development/First-Capture` to understand basics
- Then explore `Scenarios/` to test your specific database patterns
- Use any scenario quest to validate Flyway handles your use cases

---

## 🏆 Quest Difficulty Guide

🟢 **Beginner** - New to Flyway, comfortable with SQL basics  
🟡 **Intermediate** - Familiar with Flyway concepts, ready for real workflows  
🔴 **Advanced** - Experienced with Flyway, exploring edge cases or complex scenarios

---

## 🆘 Need Help?

If you get stuck:

1. **Check the quest's Hints section** - Most common issues are covered
2. **Review Troubleshooting** - Every quest includes troubleshooting guidance
3. **Consult official docs** - [Flyway Documentation](https://documentation.red-gate.com/flyway)
4. **Flyway Helper Files** - See [RG-AutoPilot/Flyway-Helper-Files](https://github.com/RG-AutoPilot/Flyway-Helper-Files) for CLI examples
5. **Ask your team** - Share knowledge with colleagues

---

## 📞 Feedback & Contributions

Found an issue? Have a scenario to add?

- Open an issue in the repository
- Submit a pull request with improvements
- Suggest new quest scenarios based on your POC experiences

**Quest ideas we'd love to see:**
- Real scenarios you encountered during POCs
- Complex database patterns specific to your industry
- Edge cases that tested Flyway's capabilities

---

## 🎯 Remember

**Flyway Autopilot** gets you started with setup and configuration.

**Flyway Quests** build your confidence and skills through hands-on practice.

**Your experience** determines when and which quests you need - there's no "right" path, only the path that matches your learning goals.

---

**Happy Learning!** 🚀

*Choose a quest, run the setup script, and start building your Flyway expertise.*
=======
# Flyway AutoPilot FastTrack - Quest Guide

Welcome to the Flyway Quests! Choose quests based on what you want to learn - each quest is self-contained and focuses on a specific topic.

## 🎯 Quest Categories

### 👨‍💻 Developer Quests
**Focus:** Using Flyway to create and manage database objects and schema changes, and support day to day operations.

### 🔧 Operations Quests  
**Focus:** Using Flyway as your Database Release tool. Test, Report, Deploy and more regardless if using the GUI, CLI or Pipelines.

### 📦 Scenarios
**Focus:** Curious How Flyway can handle certain objects, types or scenarios? Delve through our out of the box Scenarios to be confident in Flyways capabilities.
---

## 🚀 Getting Started

**Pick by topic, not by order!** Each quest is self-contained:

### Prerequisites

- **Flyway Desktop** installed and configured
- **Sandbox Environment** set up (see [Flyway Autopilot](https://documentation.red-gate.com/fd/3-provisioning-your-databases-287016879.html) if quick Sandbox Environment needed)
- **CI/CD Platform** access (for Operations quests only)
- **Preferred Database Developmnent IDE**

### Quest Structure

Each quest includes:
- 📋 **Learning Objectives** - What you'll master
- 🎯 **Scenario** - Real-world context
- 📝 **Detailed Steps** - Clear instructions
- 💡 **Code Examples** - Copy-paste ready
- ✅ **Success Criteria** - How to validate
- 🐛 **Troubleshooting** - Common issues
- 🚀 **Advanced Challenges and Learning** - Optional extensions

---

## 💡 Tips for Success

### Do's ✅
- Pick quests that match your current needs
- Complete the setup script before starting
- Test thoroughly as you go
- Read the troubleshooting section if stuck
- Try the advanced challenges for deeper learning

### Don'ts ❌
- You don't need to do quests in order
- Don't skip the prerequisites
- Don't rush - take time to understand concepts
- Don't ignore the hints sections

---

## 📊 Quest Difficulty Legend

🟢 **Beginner** - New to Flyway  
🟡 **Intermediate** - Comfortable with basics  
🔴 **Advanced** - Experienced with Flyway

---

## 🆘 Getting Help

If you get stuck:

1. Check the **Hints** section in the quest
2. Review the **Troubleshooting** guide
3. Consult [Flyway Documentation](https://documentation.red-gate.com/flyway)
4. Reach out to your Sales Rep, or to Sales@Red-Gate.com for Support

---

## 📞 Feedback

Have suggestions? Found an issue?
- Open an issue in the repository
- Submit a pull request
- Contact the Owners : Redgate-Autopilot@red-gate.com

---

**Happy Learning!** 🚀

*Choose the quest that matches what you want to learn today!*

---

# 👨‍💻 Developer Quests

State-based development workflow using Flyway Desktop and schema model approach.

## 01 - Clone Project
**Difficulty:** 🟢 Beginner  
**Time:** 15-20 minutes  
**Path:** `Quests/Developer/01-Clone-Project/`

Learn to clone the Flyway AutoPilot State repository and understand the project structure, including schema-model folder, flyway.toml configuration, and development workflow setup.

**You'll learn:**
- Git clone and repository navigation
- Flyway state-based project structure
- Schema model folder organization
- Flyway configuration files

---

## 02 - Configure Flyway Desktop
**Difficulty:** 🟢 Beginner  
**Time:** 20-25 minutes  
**Path:** `Quests/Developer/02-Configure-Flyway-Desktop/`

Set up secure database connections in Flyway Desktop using user vs. project settings, configure development environment, and understand connection security best practices.

**You'll learn:**
- User vs. project settings
- Secure credential storage
- Environment configuration
- Connection testing

---

## 03 - Validate Environment Sync
**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Path:** `Quests/Developer/03-Validate-Environment-Sync/`

Critical skill: Detect and resolve drift between development database and schema model before starting work. Learn to use Flyway Desktop's Diff tab to identify synchronization issues.

**You'll learn:**
- Drift detection
- Environment synchronization
- Diff tab usage
- Conflict resolution

---

## 04 - Capture New Changes
**Difficulty:** 🟢 Beginner  
**Time:** 30-35 minutes  
**Path:** `Quests/Developer/04-Capture-New-Changes/`

Master the core state-based workflow: create new database objects in SSMS, capture them to schema model using Flyway Desktop, and prepare for version control.

**You'll learn:**
- State-based workflow
- Object creation and capture
- Schema model updates
- Flyway Desktop Diff + Apply

---

## 05 - Commit and Push
**Difficulty:** 🟢 Beginner  
**Time:** 20-25 minutes  
**Path:** `Quests/Developer/05-Commit-and-Push/`

Learn Git workflow integrated with Flyway state-based development: staging schema model changes, writing meaningful commit messages, and pushing to remote repository.

**You'll learn:**
- Git add/commit/push workflow
- Commit message best practices
- Schema model version control
- Collaboration fundamentals

---

## 06 - Modify Existing Object
**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Path:** `Quests/Developer/06-Modify-Existing-Object/`

Understand state-based modifications: alter existing objects (tables, views, procedures), recapture to schema model, and handle modification conflicts.

**You'll learn:**
- Modifying existing objects
- State recapture workflow
- Handling schema changes
- Diff detection for modifications

---

## 07 - Track Static Data
**Difficulty:** 🟡 Intermediate  
**Time:** 30-35 minutes  
**Path:** `Quests/Developer/07-Track-Static-Data/`

Version control reference/configuration data: capture static data to schema model, manage data changes alongside schema changes, and deploy data with schema.

**You'll learn:**
- Static data identification
- Data capture to schema model
- Data versioning
- Static data deployment

---

## 08 - Feature Branch Workflow
**Difficulty:** 🟡 Intermediate  
**Time:** 35-40 minutes  
**Path:** `Quests/Developer/08-Feature-Branch-Workflow/`

Implement isolated development: create feature branches, develop schema changes independently, merge branches, and resolve schema conflicts.

**You'll learn:**
- Git feature branches
- Isolated schema development
- Branch merging strategies
- Schema conflict resolution

---

## 09 - Filtering
**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Path:** `Quests/Developer/09-Filtering/`

Focus comparisons with filters: exclude schemas/objects from diff operations, create clean comparisons, and manage complex database structures efficiently.

**You'll learn:**
- Schema filtering
- Object filtering
- Filter configuration
- Focused comparisons

---

## 10 - Pull Changes
**Difficulty:** 🟢 Beginner  
**Time:** 20-25 minutes  
**Path:** `Quests/Developer/10-Pull-Changes/`

Synchronize with team changes: pull schema model updates from Git, apply teammate changes to local database, and maintain environment synchronization.

**You'll learn:**
- Git pull workflow
- Team synchronization
- Schema model deployment
- Conflict handling

---

## 11 - Placeholders
**Difficulty:** 🟡 Intermediate  
**Time:** 30-35 minutes  
**Path:** `Quests/Developer/11-Placeholders/`

Manage environment-specific values: use placeholders for configuration, handle environment differences (dev/test/prod), and deploy parameterized schema.

**You'll learn:**
- Placeholder syntax
- Environment-specific configuration
- Flyway placeholder replacement
- Configuration management

---

# 🔧 Operations Quests

State-based CLI deployment workflow for automation, CI/CD, and production deployments.

## 00 - Compare Environments
**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Path:** `Quests/Operations/00-Compare-Environments/`  
**Helper Script:** `00_Flyway_State_Diff.ps1`

Learn to use `flyway diff` command to compare two environments (databases, schema models, snapshots) and create difference artifacts for analysis and downstream operations.

**You'll learn:**
- `flyway diff` command
- Artifact creation
- Environment comparison
- Source vs. target parameters
- Drift detection

---

## 01 - Capture Schema Model
**Difficulty:** 🟡 Intermediate  
**Time:** 15-20 minutes  
**Path:** `Quests/Operations/01-Capture-Schema-Model/`  
**Helper Script:** `01_Flyway_State_Model.ps1`

Use `flyway model` to read difference artifacts and automatically update schema model files, keeping your version-controlled schema in sync with development database.

**You'll learn:**
- `flyway model` command
- Artifact consumption
- Automatic schema model updates
- File creation/modification/deletion
- CLI-based workflow

---

## 02 - Generate Deployment Scripts
**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Path:** `Quests/Operations/02-Generate-Deployment-Scripts/`  
**Helper Script:** `02_Flyway_State_Prepare.ps1`

Generate deployment and undo scripts using `flyway prepare`, comparing schema model to target environments and creating executable SQL scripts for review and deployment.

**You'll learn:**
- `flyway prepare` command
- Deploy script generation
- Undo script generation
- Script review practices
- Idempotent SQL

---

## 03 - Validate Deployment
**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Path:** `Quests/Operations/03-Validate-Deployment/`  
**Helper Scripts:** `03a_Flyway_State_Snapshot.ps1`, `03b_Flyway_State_Check.ps1`

Create database snapshots and run comprehensive checks before deployment: analyze changes, detect drift, perform code quality checks, and generate HTML validation reports.

**You'll learn:**
- `flyway snapshot` command
- Snapshot history management
- `flyway check` command (changes, drift, code)
- HTML report interpretation
- Risk assessment

---

## 04 - Execute Deployment
**Difficulty:** 🟠 Advanced  
**Time:** 20-30 minutes  
**Path:** `Quests/Operations/04-Execute-Deployment/`  
**Helper Script:** `04_Flyway_State_Deploy.ps1`

Execute deployment scripts using `flyway deploy`, apply schema changes to target databases, verify successful deployments, and capture post-deployment snapshots.

**You'll learn:**
- `flyway deploy` command
- Deployment execution
- Transaction safety
- Post-deployment verification
- Rollback procedures
- Deployment documentation

---

## Deployment-Validation
**Difficulty:** 🟡 Intermediate  
**Time:** 30 minutes  
**Path:** `Quests/Operations/Deployment-Validation/`

Additional deployment validation techniques and best practices for ensuring safe and successful deployments across environments.

---

# 📦 Scenarios

Real-world scenarios demonstrating how Flyway handles various database objects and complex situations. Each scenario shows you how to create the situation, then how to capture, deploy, and manage it with Flyway.

## New Schema
**Difficulty:** 🟢 Beginner  
**Time:** 25-30 minutes  
**Path:** `Quests/Other/New-Schema/`

Learn how to create and manage new database schemas with Flyway. Create an HR schema with tables, views, and stored procedures, then capture and deploy it across environments.

**Demonstrates:**
- Schema creation and authorization
- Schema-level organization
- Schema-level security
- Multi-object deployment in new schema
- Schema deployment ordering

---

## Foreign Key Constraints
**Difficulty:** 🟡 Intermediate  
**Time:** 30-35 minutes  
**Path:** `Quests/Other/ForeignKey/`

Master foreign key constraint management with Flyway. Create complex FK relationships, understand dependency ordering, and see how Flyway intelligently handles referential integrity during deployment.

**Demonstrates:**
- FK constraint creation and naming
- Automatic dependency resolution
- Parent-before-child deployment ordering
- Circular dependency handling
- Cascading actions (DELETE, UPDATE)
- FK modifications and removal

---

## Database Indexes
**Difficulty:** 🟡 Intermediate  
**Time:** 30-35 minutes  
**Path:** `Quests/Other/Index/`

Explore how Flyway manages various index types: clustered, non-clustered, unique, filtered, and composite indexes. Learn performance optimization and index deployment best practices.

**Demonstrates:**
- Non-clustered indexes with included columns
- Unique indexes (including filtered unique)
- Filtered indexes (WHERE clause)
- Composite indexes (multi-column)
- Covering indexes for query performance
- Index deployment and modification
- Monitoring index usage

---

## Cross-Schema Dependencies
**Difficulty:** 🔴 Advanced  
**Time:** 35-45 minutes  
**Path:** `Quests/Other/Cross-Dependancy/`

Advanced scenario showing how Flyway handles complex dependencies across schema boundaries. Create views, functions, and procedures that reference multiple schemas, and watch Flyway resolve the deployment order automatically.

**Demonstrates:**
- Cross-schema views and joins
- Cross-schema functions and procedures
- Cross-schema foreign keys
- Multi-level dependency chains
- Circular dependency resolution
- Topological sort deployment ordering
- Complex dependency graph analysis

---
>>>>>>> Stashed changes
