-- =============================================
-- Development Quest 05 - Commit and Push Setup
-- =============================================

-- This quest focuses on Git operations, not database changes.
-- This script provides Git command reference and checklists.

PRINT '========================================';
PRINT 'Quest 05: Commit and Push Changes';
PRINT '========================================';
PRINT '';

-- =============================================
-- GIT WORKFLOW CHECKLIST
-- =============================================

PRINT 'Git Workflow Checklist:';
PRINT '';

PRINT '1. Check status:';
PRINT '   git status';
PRINT '';

PRINT '2. Review changes:';
PRINT '   git diff schema-model/';
PRINT '';

PRINT '3. Stage changes:';
PRINT '   git add schema-model/Tables/Sales.Campaigns.sql';
PRINT '   # Or: git add schema-model/';
PRINT '';

PRINT '4. Commit with message:';
PRINT '   git commit -m "Add Sales.Campaigns table for marketing campaigns"';
PRINT '';

PRINT '5. Pull latest changes:';
PRINT '   git pull origin develop';
PRINT '';

PRINT '6. Push to remote:';
PRINT '   git push origin develop';
PRINT '';

PRINT '7. Verify on remote repository';
PRINT '';

-- =============================================
-- COMMIT MESSAGE EXAMPLES
-- =============================================

PRINT '========================================';
PRINT 'Commit Message Examples';
PRINT '========================================';
PRINT '';

PRINT 'Good Examples:';
PRINT '';
PRINT '- "Add Sales.Campaigns table for marketing campaigns"';
PRINT '- "Update Sales.Customers to add loyalty program FK"';
PRINT '- "Create Logistics.GetFlightStatus stored procedure"';
PRINT '- "Add check constraint to Sales.Orders for date validation"';
PRINT '';

PRINT 'With Additional Context:';
PRINT '';
PRINT 'git commit -m "Add Sales.Campaigns table for marketing campaigns';
PRINT '';
PRINT '- Tracks campaign name, start/end dates';
PRINT '- Includes check constraint for date validity';
PRINT '- Supports Q2 2026 marketing initiative';
PRINT '- Ticket: PROJ-1234"';
PRINT '';

-- =============================================
-- COMMON GIT COMMANDS
-- =============================================

PRINT '========================================';
PRINT 'Common Git Commands';
PRINT '========================================';
PRINT '';

PRINT 'git status          # Check what changed';
PRINT 'git branch          # See current branch';
PRINT 'git pull            # Get latest changes';
PRINT 'git add <file>      # Stage a file';
PRINT 'git commit -m "..." # Commit staged changes';
PRINT 'git push            # Push to remote';
PRINT 'git log --oneline   # View commit history';
PRINT 'git diff            # See unstaged changes';
PRINT '';

-- =============================================
-- SUCCESS CRITERIA
-- =============================================

PRINT '========================================';
PRINT 'Success Criteria';
PRINT '========================================';
PRINT '';

PRINT '✓ Changes staged with git add';
PRINT '✓ Committed with clear message';
PRINT '✓ Pulled latest changes';
PRINT '✓ Pushed to remote repository';
PRINT '✓ Verified commit on remote';
PRINT '✓ Understand branching basics';
PRINT '';

PRINT '========================================';
PRINT 'Ready for Quest 06!';
PRINT '========================================';
PRINT '';
PRINT 'Proceed to Quest 06: Modify Existing Object';
PRINT '';
GO
