# Development Quest 09 - Filtering: Controlling What Flyway Compares

**Difficulty:** 🟡 Intermediate  
**Time:** 25-30 minutes  
**Prerequisites:** Flyway Desktop configured, completed Quest 03 (Validate Environment Sync)

## 🎯 Learning Objectives
By completing this quest, you will learn:
- How to configure filters in Flyway Desktop
- Including only relevant schemas and objects in comparisons
- Excluding system objects, vendor tables, and other teams' schemas
- Understanding how filtering affects comparisons and captured changes
- Saving filter configuration for team-wide consistency

## 📖 Scenario
Your development database contains multiple schemas: some are yours (Sales, Logistics, Operation), some belong to other teams (Marketing, Finance), and there are system schemas (sys, INFORMATION_SCHEMA). When you run comparisons, Flyway Desktop shows hundreds of differences because it's comparing everything. You need to configure filters to focus only on the schemas your team owns.

## 🎯 Your Mission
Configure Flyway Desktop filters to include only your team's schemas and exclude system objects, reducing noise in comparisons.

## 📋 Why Filtering Matters

**Without Filters:**
```
Comparison shows 347 differences:
- 200 system objects (INFORMATION_SCHEMA, sys)
- 80 objects from Marketing team's schema
- 50 objects from Finance team's schema
- 17 objects from YOUR schemas (what you care about!)
```

**With Filters:**
```
Comparison shows 17 differences:
- 17 objects from YOUR schemas (Sales, Logistics, Operation)
- Clean, focused comparison!
```

## 📝 Steps

### Step 1: Identify What to Include/Exclude

**Check what schemas exist:**
```sql
SELECT name AS SchemaName
FROM sys.schemas
WHERE principal_id <> 4
ORDER BY name;
```

**Categorize schemas:**
```
✓ INCLUDE (your team):
- Sales
- Logistics
- Operation
- Customers

✗ EXCLUDE (others):
- sys, INFORMATION_SCHEMA, guest (system)
- db_owner, db_accessadmin (system roles)
- Marketing, Finance (other teams)
- dbo (if not using it)
```

### Step 2: Configure Schema Filters in Flyway Desktop

**In Flyway Desktop:**

1. **Navigate to Settings/Preferences**
2. **Find "Schema Filters" or "Comparison Options"**
3. **Configure Include Schemas:**
   ```
   Include Schemas:
   - Sales
   - Logistics
   - Operation
   - Customers
   ```

4. **Configure Exclude Schemas:**
   ```
   Exclude Schemas:
   - sys
   - INFORMATION_SCHEMA
   - guest
   - db_%  (all db_ prefixed schemas)
   - Marketing
   - Finance
   ```

5. **Save Configuration**

**Or configure in `flyway.toml` (project level):**
```toml
[flyway]
schemas = ["Sales", "Logistics", "Operation", "Customers"]

[flyway.schemaFilter]
exclude = ["sys", "INFORMATION_SCHEMA", "guest", "db_%", "Marketing", "Finance"]
```

### Step 3: Configure Object Type Filters

**Optionally exclude specific object types:**

```toml
[flyway.objectFilter]
# Include only these object types
include = ["TABLE", "VIEW", "PROCEDURE", "FUNCTION"]

# Exclude these types
exclude = ["SYNONYM", "TRIGGER"]  # If you don't want to track these
```

### Step 4: Test Filters with Comparison

1. **Run comparison** (Schema Model vs. Development)
2. **Before filters:** 347 differences
3. **After filters:** 17 differences (only your schemas)

**Verify only relevant objects shown:**
```
Differences detected:
- Sales.Campaigns (Table)
- Sales.CustomerOrdersView (View)
- Logistics.GetUpcomingFlights (Procedure)
...

No longer shows:
- sys.* objects
- INFORMATION_SCHEMA.* objects
- Marketing.* objects
```

### Step 5: Save Team-Wide Filter Configuration

**Option A: Commit filters to project (`flyway.toml`):**
```powershell
# Edit flyway.toml to add schema filters
code flyway.toml

# Commit the configuration
git add flyway.toml
git commit -m "Configure schema filters for team ownership"
git push origin develop
```

**Benefit:** Everyone on team uses same filters automatically.

**Option B: User-specific filters (not committed):**
Configure in Flyway Desktop UI → Saved in user settings only.

**Benefit:** Personal customization without affecting team.

### Step 6: Understand Filter Impact

**Filters affect:**
- ✅ Comparison results (what differences are shown)
- ✅ Capture operations (what gets added to schema model)
- ✅ Synchronization (what gets deployed/updated)

**Filters DO NOT affect:**
- ❌ Database itself (objects still exist, just not tracked)
- ❌ Other teams' workflows (they have their own filters)

## ✅ Success Criteria

- ✅ Identified which schemas your team owns
- ✅ Configured include/exclude filters in Flyway Desktop
- ✅ Tested filters with comparison (reduced noise significantly)
- ✅ Understand how filters affect capture and deployment
- ✅ Saved filter configuration for team consistency
- ✅ Know when to use project vs. user filters

## 🐛 Troubleshooting

### "Filters not taking effect"
**Problem:** Still seeing excluded schemas.  
**Solution:**
- Restart Flyway Desktop after filter changes
- Verify filter syntax (check for typos)
- Check if user settings override project settings

### "Too restrictive - missing objects I need"
**Problem:** Filters excluding objects you want.  
**Solution:**
- Review include/exclude lists
- Add missing schemas to include list
- Remove over-broad exclusion patterns

### "Team members see different results"
**Problem:** Everyone has different filter configurations.  
**Solution:**
- Commit filters to `flyway.toml` (project level)
- Document filter requirements in README
- Standardize across team

## 💡 Best Practices

### Use Project-Level Filters for Team Standards ✅
```toml
# In flyway.toml (committed)
[flyway]
schemas = ["Sales", "Logistics", "Operation"]

# Everyone on team gets same filtered view
```

### Always Exclude System Schemas ✅
```toml
[flyway.schemaFilter]
exclude = ["sys", "INFORMATION_SCHEMA", "guest", "db_%"]
```

### Document Filter Decisions ✅
```markdown
# In README.md
## Schema Ownership
- **Our Team:** Sales, Logistics, Operation
- **Other Teams:** Marketing (Team A), Finance (Team B)
- **Excluded:** System schemas, vendor objects
```

### Review Filters Periodically ✅
```
When new schemas added:
- Determine ownership
- Update filters if needed
- Communicate with team
```

## 🎓 Key Concepts Learned

- **Schema Filtering:** Controlling comparison scope
- **Noise Reduction:** Focusing on relevant objects
- **Team Coordination:** Shared filter configuration
- **Selective Capture:** Only tracking what matters
- **Project vs. User Settings:** When to commit filters

## 🚀 Real-World Applications

- **Multi-Team Databases:** Each team filters to their schemas
- **Shared Environments:** Exclude other applications' objects
- **Vendor Software:** Exclude third-party schemas
- **System Objects:** Always filter out SQL Server internals
- **Legacy Databases:** Focus on what you're modernizing

## 📚 Advanced Scenarios (Optional)

### Wildcard Patterns
```toml
[flyway.schemaFilter]
include = ["Sales*"]  # Includes Sales, Sales_Archive, Sales_Staging
exclude = ["*_old", "*_backup"]  # Excludes anything ending in _old or _backup
```

### Object Name Filters
```toml
[flyway.objectFilter]
excludePattern = ["tmp_.*", "test_.*"]  # Exclude temp and test objects
```

### Environment-Specific Filters
```toml
[environments.development.flyway]
schemas = ["Sales", "Logistics", "Operation", "Dev_Scratch"]  # Include dev scratch

[environments.production.flyway]
schemas = ["Sales", "Logistics", "Operation"]  # Exclude dev scratch in prod
```

## 📚 Next Steps

**Quest 10: Pull Changes** - Learn to synchronize your database with teammates' changes

---

**Congratulations!** 🎉 You've mastered filtering to keep comparisons clean and focused!
