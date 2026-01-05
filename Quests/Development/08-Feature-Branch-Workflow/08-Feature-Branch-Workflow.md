# Development Quest 08 - Feature Branch Workflow

**Difficulty:** 🟡 Intermediate  
**Time:** 20-25 minutes  
**Prerequisites:** Completed Quests 04-05 (Capture and Commit), basic Git knowledge

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to create a feature branch for isolated development
- Making schema changes on a branch without affecting main development
- Capturing and committing changes on the feature branch
- Avoiding accidental commits to the wrong branch
- Understanding branch-based development workflow

## 📖 Scenario
You're starting work on a new feature that requires database changes. Your team uses feature branches to isolate work-in-progress from the main development branch. You need to create a feature branch, make your changes there, and eventually merge back to the main branch.

## 🎯 Your Mission
Create a feature branch for adding a discount code system, make schema changes on that branch, and understand the isolated development workflow.

## 📝 Steps

### Step 1: Create a Feature Branch

```powershell
# Ensure you're on the latest develop branch
git checkout develop
git pull origin develop

# Create and switch to new feature branch
git checkout -b feature/discount-codes

# Verify you're on the new branch
git branch
# Output shows:
#   develop
# * feature/discount-codes  ← asterisk shows current branch
```

**Branch naming conventions:**
- `feature/discount-codes` - New feature work
- `bugfix/fix-campaign-dates` - Bug fixes
- `hotfix/critical-issue` - Urgent production fixes

### Step 2: Make Schema Changes on the Feature Branch

```sql
-- Create discount code table
CREATE TABLE Sales.DiscountCodes (
    DiscountCodeID INT PRIMARY KEY IDENTITY(1,1),
    Code NVARCHAR(20) NOT NULL UNIQUE,
    DiscountPercentage DECIMAL(5,2) NOT NULL,
    ValidFrom DATE NOT NULL,
    ValidUntil DATE NOT NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT CHK_DiscountCodes_Dates CHECK (ValidUntil >= ValidFrom),
    CONSTRAINT CHK_DiscountCodes_Percentage CHECK (DiscountPercentage BETWEEN 0 AND 100)
);
```

### Step 3: Capture Changes on the Feature Branch

1. **Open Flyway Desktop**
2. **Run comparison** (Schema Model vs. Development)
3. **Detect new table:** `Sales.DiscountCodes`
4. **Capture into schema model**
5. **Verify file created:** `schema-model/Tables/Sales.DiscountCodes.sql`

### Step 4: Commit Changes to the Feature Branch

```powershell
# Verify you're on the feature branch
git branch  # Should show * feature/discount-codes

# Stage and commit
git add schema-model/Tables/Sales.DiscountCodes.sql

git commit -m "Add Sales.DiscountCodes table for promotional discount tracking"

# Push feature branch to remote
git push origin feature/discount-codes
```

**Important:** Your changes are now on the feature branch, NOT on develop!

### Step 5: Verify Isolation

```powershell
# Check your feature branch
git log --oneline -3  # Shows your commit

# Switch to develop branch
git checkout develop

# Check develop branch
git log --oneline -3  # Your feature commit is NOT here

# Your changes are isolated to the feature branch!
```

### Step 6: Continue Development on the Feature Branch

**Always verify your branch before making changes:**

```powershell
# Daily routine:
git branch  # Confirm you're on feature/discount-codes

# If you're on the wrong branch:
git checkout feature/discount-codes

# Pull latest changes from develop (stay up to date)
git checkout develop
git pull origin develop
git checkout feature/discount-codes
git merge develop  # Merge develop into your feature branch
```

###Step 7: Understanding Branch Lifecycle

**Typical feature branch workflow:**

```
1. Create feature branch from develop
2. Make schema changes
3. Capture and commit on feature branch
4. Push feature branch to remote
5. Create Pull Request (PR) for code review
6. Team reviews your changes
7. Merge feature branch into develop
8. Delete feature branch (work complete)
```

## ✅ Success Criteria

- ✅ Created feature branch from develop
- ✅ Made schema changes on feature branch
- ✅ Captured changes into schema model on feature branch
- ✅ Committed and pushed to feature branch
- ✅ Verified changes isolated from develop
- ✅ Understand how to check current branch
- ✅ Know how to avoid committing to wrong branch

## 🐛 Troubleshooting

### "Accidentally committed to develop instead of feature branch"
**Problem:** Made commit on wrong branch.  
**Solution:**
```powershell
# If not yet pushed:
git reset HEAD~1  # Undo last commit (keeps changes)
git checkout feature/discount-codes  # Switch to feature branch
git add .
git commit -m "Your message"  # Commit on correct branch
```

### "Can't switch branches - uncommitted changes"
**Problem:** Trying to switch with pending changes.  
**Solution:**
```powershell
# Option 1: Commit changes first
git add .
git commit -m "Your message"
git checkout other-branch

# Option 2: Stash changes temporarily
git stash
git checkout other-branch
git stash pop  # Restore changes on new branch
```

### "Feature branch behind develop"
**Problem:** Develop has new changes you don't have.  
**Solution:**
```powershell
git checkout feature/discount-codes
git merge develop  # Merge latest develop into your branch
# Resolve any conflicts
git push origin feature/discount-codes
```

## 💡 Best Practices

### Always Check Your Branch Before Committing ✅
```powershell
# Add this to your daily routine:
git branch  # ← Verify branch before making changes
```

### Keep Feature Branches Short-Lived ✅
```
✓ Create branch → Work → Merge → Delete (days, not weeks)
✗ Long-lived branches accumulate conflicts
```

### Sync with Develop Regularly ✅
```powershell
# Daily or every few days:
git checkout develop
git pull origin develop
git checkout feature/discount-codes
git merge develop
```

### Use Descriptive Branch Names ✅
```
Good:
- feature/discount-codes
- feature/loyalty-program-integration
- bugfix/campaign-date-validation

Avoid:
- my-branch
- test
- temp
```

## 🎓 Key Concepts Learned

- **Feature Branches:** Isolated development environment
- **Branch Switching:** Moving between different lines of development
- **Branch Isolation:** Changes don't affect other branches until merged
- **Daily Workflow:** Check branch, make changes, commit, push

## 📚 Next Steps

**Quest 09: Filtering** - Learn to control what Flyway compares and captures

---

**Congratulations!** 🎉 You understand feature branch workflow for isolated database development!
