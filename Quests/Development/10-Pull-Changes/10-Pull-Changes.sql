-- =============================================
-- Development Quest 10 - Pull Changes Setup
-- =============================================

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 10: Pull Changes from Version Control';
PRINT '========================================';
PRINT '';

PRINT 'Workflow Simulation:';
PRINT '';

PRINT '1. Teammate adds CustomerFeedback table to schema model';
PRINT '2. You pull their changes from Git';
PRINT '3. You synchronize your dev database';
PRINT '';

PRINT '========================================';
PRINT 'Git Commands';
PRINT '========================================';
PRINT '';

PRINT 'git pull origin develop  # Get latest changes';
PRINT 'git log --oneline -5     # Review what changed';
PRINT 'git diff HEAD~1 -- schema-model/  # See file diffs';
PRINT '';

PRINT '========================================';
PRINT 'Flyway Desktop Steps';
PRINT '========================================';
PRINT '';

PRINT '1. Open Flyway Desktop';
PRINT '2. Run comparison (Schema Model vs. Dev Database)';
PRINT '3. Detect missing objects (CustomerFeedback)';
PRINT '4. Select missing objects';
PRINT '5. Click "Synchronize" or "Deploy to Development"';
PRINT '6. Verify table created in database';
PRINT '';

PRINT '========================================';
PRINT 'Verification Query';
PRINT '========================================';
PRINT '';

PRINT 'After synchronization, verify:';
PRINT '';
PRINT 'SELECT * FROM INFORMATION_SCHEMA.TABLES';
PRINT 'WHERE TABLE_SCHEMA = ''Sales'' AND TABLE_NAME = ''CustomerFeedback'';';
PRINT '';
PRINT 'EXEC sp_help ''Sales.CustomerFeedback'';';
PRINT '';

PRINT '========================================';
GO
