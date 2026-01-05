-- =============================================
-- Development Quest 02 - Configure Flyway Desktop Setup
-- =============================================

-- This quest focuses on configuration, not database changes.
-- Run this script to verify your development database exists and is accessible.

-- =============================================
-- VERIFY DEVELOPMENT DATABASE ACCESS
-- =============================================

PRINT '========================================';
PRINT 'Quest 02: Configure Flyway Desktop';
PRINT '========================================';
PRINT '';

-- Check current database
PRINT 'Current Database: ' + DB_NAME();
PRINT 'Server: ' + @@SERVERNAME;
PRINT 'SQL Server Version: ' + @@VERSION;
PRINT '';

-- Verify you have appropriate permissions
PRINT 'Checking your permissions...';
PRINT '';

IF IS_MEMBER('db_owner') = 1
BEGIN
    PRINT '✓ You are a db_owner - full access granted';
END
ELSE IF IS_MEMBER('db_ddladmin') = 1
BEGIN
    PRINT '✓ You have DDL admin rights - can modify schema';
END
ELSE
BEGIN
    PRINT '⚠ Limited permissions detected';
    PRINT '  You may need elevated access for schema changes';
END
PRINT '';

-- =============================================
-- VERIFY DATABASE OBJECTS ARE ACCESSIBLE
-- =============================================

PRINT '========================================';
PRINT 'Verifying Database Access';
PRINT '========================================';
PRINT '';

-- Count schemas
PRINT 'Available Schemas:';
SELECT name AS SchemaName
FROM sys.schemas
WHERE principal_id <> 4  -- Exclude built-in schemas
ORDER BY name;
PRINT '';

-- Count tables
DECLARE @tableCount INT = (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0);
PRINT 'Total User Tables: ' + CAST(@tableCount AS NVARCHAR(10));
PRINT '';

-- Count views
DECLARE @viewCount INT = (SELECT COUNT(*) FROM sys.views WHERE is_ms_shipped = 0);
PRINT 'Total User Views: ' + CAST(@viewCount AS NVARCHAR(10));
PRINT '';

-- Count stored procedures
DECLARE @procCount INT = (SELECT COUNT(*) FROM sys.procedures WHERE is_ms_shipped = 0);
PRINT 'Total Stored Procedures: ' + CAST(@procCount AS NVARCHAR(10));
PRINT '';

-- =============================================
-- CONNECTION STRING EXAMPLES
-- =============================================

PRINT '========================================';
PRINT 'Connection String Examples';
PRINT '========================================';
PRINT '';

PRINT 'Windows Authentication (Recommended):';
PRINT 'jdbc:sqlserver://localhost:1433;';
PRINT '  databaseName=AutopilotDev;';
PRINT '  encrypt=true;';
PRINT '  trustServerCertificate=true;';
PRINT '  integratedSecurity=true';
PRINT '';

PRINT 'SQL Server Authentication:';
PRINT 'jdbc:sqlserver://localhost:1433;';
PRINT '  databaseName=AutopilotDev;';
PRINT '  encrypt=true;';
PRINT '  trustServerCertificate=true';
PRINT '  (username and password in user settings)';
PRINT '';

-- =============================================
-- CONFIGURATION CHECKLIST
-- =============================================

PRINT '========================================';
PRINT 'Configuration Checklist';
PRINT '========================================';
PRINT '';

PRINT '✓ Verify SQL Server is running';
PRINT '✓ Confirm database name: ' + DB_NAME();
PRINT '✓ Test connection in SSMS/Azure Data Studio';
PRINT '✓ Configure Flyway Desktop connection:';
PRINT '  - Use Settings/Preferences menu';
PRINT '  - Select development environment';
PRINT '  - Enter connection details';
PRINT '  - Test connection';
PRINT '  - Save configuration';
PRINT '✓ Verify connection successful in Flyway Desktop';
PRINT '✓ Ensure flyway.toml unchanged (no passwords)';
PRINT '✓ Verify .gitignore excludes user settings';
PRINT '';

-- =============================================
-- SECURITY REMINDERS
-- =============================================

PRINT '========================================';
PRINT 'Security Reminders';
PRINT '========================================';
PRINT '';

PRINT '❌ DO NOT commit to Git:';
PRINT '  - Passwords or credentials';
PRINT '  - .flyway/ folder';
PRINT '  - *.user.toml files';
PRINT '  - Connection strings with passwords';
PRINT '';

PRINT '✓ SAFE to commit:';
PRINT '  - flyway.toml (with placeholders)';
PRINT '  - schema-model/ folder';
PRINT '  - migrations/ folder';
PRINT '  - Documentation files';
PRINT '';

-- =============================================
-- NEXT STEPS
-- =============================================

PRINT '========================================';
PRINT 'Ready for Quest 03!';
PRINT '========================================';
PRINT '';

PRINT 'Once you have successfully:';
PRINT '  - Configured Flyway Desktop connection';
PRINT '  - Tested connection successfully';
PRINT '  - Verified you can browse database objects';
PRINT '  - Confirmed no credentials in flyway.toml';
PRINT '';
PRINT 'Proceed to Quest 03: Validate Environment Sync';
PRINT '';
PRINT '========================================';
GO
