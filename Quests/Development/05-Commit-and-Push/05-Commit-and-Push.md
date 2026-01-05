# Development Quest 05 - Commit and Push Changes

**Difficulty:** 🟢 Beginner  
**Time:** 15-20 minutes  
**Prerequisites:** Completed Quest 04 (Capture New Changes), captured changes in schema model

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to commit captured schema changes to Git
- Best practices for commit messages
- Pushing changes to the shared repository
- Understanding branching at a practical level (no Git theory deep-dive)
- Collaborating with your team through version control

## 📖 Scenario
You've captured the `Sales.Campaigns` table into your schema model. Now it's time to share this change with your team by committing it to Git and pushing it to the shared repository. This makes your change available to other developers and triggers any CI/CD pipelines.

## 🎯 Your Mission
Commit your captured schema model changes to Git with a clear, descriptive commit message, and push them to the remote repository.

## 📝 Steps

### Step 1: Check Your Git Status

1. **Open a terminal in your project directory**
   ```powershell
   cd C:\Flyway-Projects\YourFlywayProject
   ```

2. **Check what files changed:**
   ```powershell
   git status
   ```

   **Expected output:**
   ```
   On branch develop
   Your branch is up to date with 'origin/develop'.

   Changes not staged for commit:
     modified:   schema-model/Tables/Sales.Campaigns.sql

   Untracked files:
     schema-model/Tables/Sales.Campaigns.sql
   ```

3. **View the specific changes:**
   ```powershell
   git diff schema-model/
   ```

   You should see the new CREATE TABLE statement for `Sales.Campaigns`.

### Step 2: Stage Your Changes

**Staging** prepares files to be committed.

1. **Stage the schema model changes:**
   ```powershell
   git add schema-model/Tables/Sales.Campaigns.sql
   ```

   **Or stage all schema-model changes:**
   ```powershell
   git add schema-model/
   ```

2. **Verify files are staged:**
   ```powershell
   git status
   ```

   **Expected output:**
   ```
   Changes to be committed:
     new file:   schema-model/Tables/Sales.Campaigns.sql
   ```

### Step 3: Write a Clear Commit Message

**Good commit messages are:**
- Clear and descriptive
- Explain **what** changed and **why**
- Use present tense ("Add" not "Added")
- Reference ticket numbers if applicable

**Commit the changes:**
```powershell
git commit -m "Add Sales.Campaigns table for marketing campaigns"
```

**With more context:**
```powershell
git commit -m "Add Sales.Campaigns table for marketing campaigns

- Tracks campaign name, start/end dates
- Includes check constraint for date validity
- Supports marketing team's promotional tracking requirements
- Ticket: PROJ-1234"
```

### Step 4: Understand Branching Basics

**Before pushing, know what branch you're on:**

```powershell
# Check current branch
git branch

# Output shows:
#   main
# * develop    ← asterisk shows your current branch
#   feature/new-reports
```

**Common branching strategies:**
- **main/master** - Production-ready code
- **develop** - Integration branch for team
- **feature/\*** - Individual feature development

**Ask your team:** "What branch should I work on?"

**If you need to switch branches:**
```powershell
# Switch to develop branch
git checkout develop

# Or create a new feature branch (Quest 08 covers this in detail)
git checkout -b feature/campaigns-table
```

### Step 5: Pull Latest Changes (Avoid Conflicts)

**Before pushing, always pull latest changes:**

```powershell
# Update your current branch with remote changes
git pull origin develop  # Replace 'develop' with your branch name
```

**Possible outcomes:**

**✅ No conflicts:**
```
Already up to date.
```
→ Safe to push!

**⚠️ Changes pulled, auto-merged:**
```
Updating abc123..def456
Fast-forward
 schema-model/Tables/Sales.Customers.sql | 2 ++
 1 file changed, 2 insertions(+)
```
→ Review changes, then push.

**❌ Merge conflict:**
```
CONFLICT (content): Merge conflict in schema-model/Tables/Sales.Customers.sql
Automatic merge failed; fix conflicts and then commit the result.
```
→ Resolve conflicts (covered in Quest 08), then push.

### Step 6: Push Your Changes

**Push to the remote repository:**

```powershell
# Push to your current branch
git push origin develop  # Replace with your branch name

# Or if tracking is set up:
git push
```

**Successful push output:**
```
Enumerating objects: 5, done.
Counting objects: 100% (5/5), done.
Delta compression using up to 8 threads
Compressing objects: 100% (3/3), done.
Writing objects: 100% (3/3), 456 bytes | 456.00 KiB/s, done.
Total 3 (delta 1), reused 0 (delta 0)
To https://github.com/YourOrg/YourFlywayProject.git
   abc123..def456  develop -> develop
```

✅ Your changes are now in the shared repository!

### Step 7: Verify on Remote Repository

1. **Open your Git hosting service** (GitHub, Azure DevOps, GitLab)

2. **Navigate to your repository**

3. **Check the recent commits:**
   - You should see your commit message
   - Timestamp shows when you pushed
   - Changed files include `schema-model/Tables/Sales.Campaigns.sql`

4. **View the file:**
   - Navigate to `schema-model/Tables/Sales.Campaigns.sql`
   - Verify the CREATE TABLE statement is there

### Step 8: Notify Your Team (If Applicable)

Depending on your team's workflow:

**Option A: Pull Request (Recommended)**
```
If working on a feature branch:
1. Create pull request from feature branch to develop
2. Request code review from teammate
3. Merge after approval
```

**Option B: Direct Notification**
```
Post in team chat:
"Pushed Sales.Campaigns table to develop branch.
Ready for Test deployment.
Ticket: PROJ-1234"
```

**Option C: CI/CD Handles It**
```
Your push may trigger:
- Automated builds
- Schema validation
- Test environment deployment
- Team notifications
```

## ✅ Success Criteria

You've successfully completed this quest when:

- ✅ Changes staged with `git add`
- ✅ Committed with clear, descriptive message
- ✅ Pulled latest changes from remote (no conflicts)
- ✅ Pushed successfully to remote repository
- ✅ Verified commit appears in remote repository
- ✅ Understand basic branching concept
- ✅ Team notified (if required by your workflow)

## 🐛 Troubleshooting

### "git push rejected - non-fast-forward"
**Problem:** Remote has changes you don't have locally.  
**Solution:**
```powershell
# Pull and merge remote changes first
git pull origin develop

# Resolve any conflicts if needed
# Then push again
git push origin develop
```

### "Authentication failed"
**Problem:** Can't push - credentials issue.  
**Solution:**
- Set up Git credentials (SSH keys or personal access token)
- For GitHub: Use personal access token, not password
- For Azure DevOps: Use Git Credential Manager
```powershell
# Configure credentials
git config --global credential.helper manager-core
```

### "Nothing to commit, working tree clean"
**Problem:** Forgot to stage changes before committing.  
**Solution:**
```powershell
# Stage changes first
git add schema-model/

# Then commit
git commit -m "Your message"
```

### "Merge conflict in schema-model file"
**Problem:** You and another developer changed the same file.  
**Solution:**
- Open the conflicted file
- Resolve conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
- Stage resolved file: `git add schema-model/...`
- Complete merge: `git commit`
- Push: `git push`

## 💡 Best Practices

### Write Descriptive Commit Messages ✅
```powershell
# Good
git commit -m "Add Sales.Campaigns table for marketing campaign tracking"

# Better
git commit -m "Add Sales.Campaigns table for marketing campaigns

- Supports campaign name, start/end dates
- Includes date validation check constraint
- Required for Q2 2026 marketing initiative
- Ticket: PROJ-1234"

# Avoid
git commit -m "changes"
git commit -m "updated stuff"
git commit -m "asdf"
```

### Always Pull Before Push ✅
```powershell
# Recommended workflow
git pull origin develop
git add schema-model/
git commit -m "Your message"
git pull origin develop  # Pull again before push
git push origin develop
```

### Commit Frequently, Push Regularly ✅
```
✓ Commit after each logical change
✓ Push at least daily (or end of feature work)
✓ Don't accumulate days of uncommitted work

Benefits:
- Easier to revert if needed
- Team sees progress
- Smaller, clearer commits
- Reduced merge conflicts
```

### Don't Commit Secrets ❌
```powershell
# Never commit:
- Passwords
- API keys
- Connection strings with credentials
- Personal access tokens

# Verify with:
git diff  # Before committing, review what's included
```

## 🎓 Key Concepts Learned

- **Git Workflow:** Status → Stage → Commit → Pull → Push
- **Commit Messages:** Clear, descriptive communication
- **Branching:** Understanding where your changes go
- **Collaboration:** Sharing changes with team through Git
- **Pull Before Push:** Avoiding conflicts proactively

## 🚀 Real-World Applications

- **Team Collaboration:** Everyone works from latest code
- **Code Reviews:** Commits reviewed before merging
- **CI/CD Integration:** Pushes trigger automated builds
- **Audit Trail:** Complete history of who changed what and when
- **Rollback Capability:** Can revert to any previous commit

## 📚 Advanced Scenarios (Optional)

### Amending Last Commit
```powershell
# Forgot to include a file in your commit?
git add schema-model/Tables/Sales.Another.sql
git commit --amend --no-edit

# Want to change commit message?
git commit --amend -m "New commit message"

# ⚠️ Only amend commits not yet pushed!
```

### Viewing Commit History
```powershell
# See recent commits
git log --oneline -10

# See changes in a specific commit
git show abc123

# See file history
git log --follow schema-model/Tables/Sales.Campaigns.sql
```

### Checking Remote Status
```powershell
# See remote repository info
git remote -v

# Check if local is behind remote
git fetch
git status  # Shows "Your branch is behind..."
```

## 📚 Next Steps

Now that your changes are committed and pushed, proceed to:

**Quest 06: Modify Existing Object** - Learn how to capture modifications to existing database objects

---

**Congratulations!** 🎉 You've successfully committed and pushed your first schema change to the team repository!
