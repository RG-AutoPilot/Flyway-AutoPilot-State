**RUN THE SQL SCRIPT FIRST TO CREATE THE NEEDED QUEST ITEMS**

# Developer Quest - Merging Changes with Git Branches

**Difficulty:** Intermediate  
**Time:** 30-40 minutes  
**Prerequisites:** Flyway Desktop, Git branching knowledge, and Git repository connected

## Learning Objectives
By completing this quest, you will learn:
- How to switch Git branches in Flyway Desktop
- Making database changes on a feature branch
- Generating migrations on the correct branch
- Committing and pushing branch-specific changes
- Managing branch-based database development workflow
- Best practices for merging database changes

## Scenario
You're working on a new feature for customer loyalty rewards. Your team uses Git feature branches to isolate development work. You need to:
1. Create a new feature branch for the loyalty program
2. Switch to that branch in Flyway Desktop
3. Make database changes for the feature
4. Generate a migration on the feature branch
5. Commit and push your changes to the branch

This workflow ensures that your database changes are isolated from the main branch until they're ready to be merged, just like your application code.

## Your Mission
Use Flyway Desktop to switch to a feature branch, create database objects for a loyalty rewards program, generate a migration, and commit/push the changes to the branch.

## Objective
1. Create a new Git feature branch for the loyalty rewards feature
2. Switch to the feature branch in Flyway Desktop
3. Create database objects for the loyalty program
4. Generate a migration on the feature branch using Flyway Desktop
5. Commit and push the migration to the feature branch
6. Understand how to merge changes back to main

## Objects to Create

### Loyalty Rewards Schema Objects:
- `Sales.LoyaltyProgram` (Table) - Stores loyalty program definitions
- `Sales.CustomerLoyalty` (Table) - Tracks customer enrollment and points
- `Sales.LoyaltyTransaction` (Table) - Records points earned/redeemed
- `Sales.CalculateLoyaltyPoints` (Function) - Calculates points for a purchase

## Steps

### Step 1: Create and Switch to Feature Branch

**Option A: Using Git Command Line**
```bash
# Create a new feature branch
git checkout -b feature/loyalty-rewards

# Verify you're on the new branch
git branch
```

**Option B: Using Flyway Desktop**
1. Open Flyway Desktop
2. Look for the **Git branch selector** (usually in the top toolbar or sidebar)
3. Click **"New Branch"** or **"Create Branch"**
4. Name it: `feature/loyalty-rewards`
5. Click **"Create and Switch"** or **"Checkout"**

**Verify Branch Switch**:
- Flyway Desktop should show you're now on `feature/loyalty-rewards`
- Any migrations you generate will be committed to this branch

### Step 2: Create the Database Objects

Run the setup SQL script provided (`Merging-Changes.sql`) to create the loyalty program objects in your development database:

```sql
-- This script creates the loyalty rewards schema objects
-- Run this in SSMS or Azure Data Studio
```

Or create them manually:

```sql
-- 1. Loyalty Program Table
CREATE TABLE Sales.LoyaltyProgram (
    ProgramID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramName NVARCHAR(100) NOT NULL,
    PointsPerDollar DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

-- 2. Customer Loyalty Table
CREATE TABLE Sales.CustomerLoyalty (
    CustomerLoyaltyID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProgramID INT NOT NULL,
    TotalPoints INT NOT NULL DEFAULT 0,
    EnrollmentDate DATE NOT NULL DEFAULT GETDATE(),
    LastActivityDate DATE NULL,
    FOREIGN KEY (ProgramID) REFERENCES Sales.LoyaltyProgram(ProgramID)
);

-- 3. Loyalty Transaction Table
CREATE TABLE Sales.LoyaltyTransaction (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerLoyaltyID INT NOT NULL,
    TransactionType NVARCHAR(20) NOT NULL CHECK (TransactionType IN ('Earned', 'Redeemed')),
    Points INT NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    Description NVARCHAR(200),
    FOREIGN KEY (CustomerLoyaltyID) REFERENCES Sales.CustomerLoyalty(CustomerLoyaltyID)
);

-- 4. Calculate Loyalty Points Function
CREATE FUNCTION Sales.CalculateLoyaltyPoints(
    @PurchaseAmount DECIMAL(10,2),
    @ProgramID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Points INT;
    DECLARE @PointsPerDollar DECIMAL(5,2);
    
    -- Get the points per dollar for the program
    SELECT @PointsPerDollar = PointsPerDollar
    FROM Sales.LoyaltyProgram
    WHERE ProgramID = @ProgramID AND IsActive = 1;
    
    -- Calculate points (defaults to 1.0 if program not found)
    SET @Points = FLOOR(@PurchaseAmount * ISNULL(@PointsPerDollar, 1.0));
    
    RETURN @Points;
END;
```

### Step 3: Generate Migration on Feature Branch

1. **Open Flyway Desktop**
   - Ensure you're still on the `feature/loyalty-rewards` branch
   - The branch indicator should be visible in the UI

2. **Navigate to Schema Model**
   - Click on the **Schema Model** tab
   - Flyway Desktop compares your database to the schema model

3. **Review Detected Changes**
   - Click **"Generate Migration"** or **"Review Changes"**
   - You should see all four new objects detected:
     - ✅ Sales.LoyaltyProgram (Table)
     - ✅ Sales.CustomerLoyalty (Table)
     - ✅ Sales.LoyaltyTransaction (Table)
     - ✅ Sales.CalculateLoyaltyPoints (Function)

4. **Generate the Migration**
   - Provide a description: "Add loyalty rewards program"
   - Flyway will create a versioned migration file
   - Example: `V013__Add_loyalty_rewards_program.sql`
   - Review the generated SQL to ensure it matches your changes

5. **Verify Migration Content**
   - The migration should include CREATE statements for all objects
   - Check that foreign key relationships are correct
   - Ensure the function definition is complete

### Step 4: Commit Changes to Feature Branch

**Using Flyway Desktop Git Integration**:
1. In Flyway Desktop, look for **Git/Source Control** panel
2. You should see the new migration file listed as uncommitted
3. Review the changes
4. Write a commit message:
   ```
   Add loyalty rewards program database objects
   
   - Created LoyaltyProgram table to define reward programs
   - Created CustomerLoyalty table to track enrollments
   - Created LoyaltyTransaction table to record points activity
   - Added CalculateLoyaltyPoints function for point calculations
   ```
5. Click **"Commit"** to commit to the feature branch

**Or using Git Command Line**:
```bash
# Check what files changed
git status

# Add the new migration file
git add migrations/V013__Add_loyalty_rewards_program.sql

# Or add all migration files
git add migrations/

# Commit with a descriptive message
git commit -m "Add loyalty rewards program database objects" -m "- Created LoyaltyProgram table to define reward programs
- Created CustomerLoyalty table to track enrollments
- Created LoyaltyTransaction table to record points activity
- Added CalculateLoyaltyPoints function for point calculations"
```

### Step 5: Push Changes to Remote Branch

**Using Flyway Desktop**:
1. After committing, look for a **"Push"** button
2. Click **"Push"** to send your commits to the remote repository
3. Confirm the push was successful

**Or using Git Command Line**:
```bash
# Push the feature branch to remote
git push origin feature/loyalty-rewards

# Or if it's your first push of this branch
git push -u origin feature/loyalty-rewards
```

**Verify the Push**:
- Check your Git hosting platform (GitHub, GitLab, etc.)
- Navigate to the `feature/loyalty-rewards` branch
- Confirm the migration file is present
- Verify the commit message appears in the branch history

### Step 6: Understanding the Merge Process

While merging is typically done through pull requests, here's what happens:

1. **Create Pull Request**:
   - Go to your Git hosting platform
   - Create a PR from `feature/loyalty-rewards` to `main`
   - Review the database migration changes

2. **Code Review**:
   - Team members review the migration script
   - Check for schema conflicts
   - Validate the approach

3. **Merge**:
   - Once approved, merge the PR
   - The migration file becomes part of the main branch
   - Flyway will apply it in the next deployment

4. **Branch Cleanup**:
   ```bash
   # After merge, delete local branch
   git checkout main
   git pull
   git branch -d feature/loyalty-rewards
   
   # Delete remote branch
   git push origin --delete feature/loyalty-rewards
   ```

## Hints
- **Branch Visibility**: Always verify which branch you're on before generating migrations
- **Flyway Desktop Integration**: Modern versions of Flyway Desktop show the active Git branch
- **Migration Versioning**: Each branch can have its own migrations; version numbers should be coordinated
- **Sync Regularly**: Pull changes from main regularly to avoid merge conflicts
- **Test Migrations**: Always test on a clean database before pushing

## Key Concepts Learned
- **Branch-Based Development**: Isolating database changes on feature branches
- **Git Integration in Flyway Desktop**: Using version control directly in the tool
- **Migration on Branches**: How migrations are tied to Git branches
- **Commit and Push Workflow**: Proper Git workflow for database changes
- **Merge Preparation**: Understanding how branches eventually merge

## Common Pitfalls to Avoid
❌ **Generating migrations on wrong branch**: Creates migrations on main instead of feature branch  
✅ **Solution**: Always verify active branch before generating migrations

❌ **Forgetting to push**: Commits locally but doesn't share with team  
✅ **Solution**: Always push after committing

❌ **Version number conflicts**: Two branches use the same version number  
✅ **Solution**: Coordinate version numbers or use Flyway's timestamp-based versioning

❌ **Not syncing with main**: Branch gets too far behind main  
✅ **Solution**: Regularly merge main into your feature branch

## Success Criteria
✅ Created feature branch `feature/loyalty-rewards`  
✅ Switched to the feature branch in Flyway Desktop  
✅ Generated migration with all loyalty program objects  
✅ Migration file created in correct location  
✅ Changes committed to feature branch with clear message  
✅ Feature branch pushed to remote repository  
✅ Can see migration in feature branch on Git hosting platform  
✅ Understand how to merge changes back to main via pull request

## Troubleshooting
- **Can't see Git features in Flyway Desktop**: Ensure your project is initialized as a Git repository
- **Branch not showing**: Refresh Flyway Desktop or restart it
- **Push fails**: Check your Git credentials and remote repository access
- **Migration appears on wrong branch**: Use `git checkout` to switch branches, then regenerate
- **Merge conflicts**: Coordinate with team on migration version numbers

## Advanced Scenarios

### Scenario 1: Multiple Developers on Same Feature
When multiple developers work on the same feature branch:
1. Pull latest changes before creating new objects: `git pull origin feature/loyalty-rewards`
2. Communicate about who generates migrations when
3. Merge local changes before pushing

### Scenario 2: Long-Running Feature Branch
For features that take weeks to develop:
1. Regularly merge main into your feature branch:
   ```bash
   git checkout feature/loyalty-rewards
   git merge main
   ```
2. Resolve any migration conflicts
3. Test thoroughly after merging

### Scenario 3: Hotfix While on Feature Branch
If you need to make a hotfix:
1. Commit or stash your feature branch work
2. Switch to main: `git checkout main`
3. Create hotfix branch: `git checkout -b hotfix/critical-fix`
4. Make changes, commit, push
5. Return to feature branch: `git checkout feature/loyalty-rewards`

## Real-World Applications
- **Feature Isolation**: Keep new features separate until ready to release
- **Parallel Development**: Multiple teams working on different features simultaneously
- **Code Review**: Changes reviewed before merging to main
- **Rollback Safety**: Easy to discard feature branch if not needed
- **Release Management**: Control when features go to production

## Testing Your Branch Skills
After completing this quest, try:
1. Create a second feature branch for a different feature
2. Switch between branches in Flyway Desktop
3. Generate different migrations on different branches
4. Practice merging one feature branch to main
5. Handle a merge conflict between two feature branches

## Next Steps
Great work mastering branch-based database development! Explore other Developer quests to learn about stored procedures, static data, and schema normalization!
