-- =============================================
-- Development Quest 03 - Validate Environment Sync
-- Verify Database and Schema Model Alignment
-- =============================================

-- ⚠️ IMPORTANT: This script creates intentional drift scenarios
-- for learning purposes. Run this ONLY if you want to practice
-- detecting and resolving differences.

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 03: Validate Environment Sync';
PRINT '========================================';
PRINT '';

-- =============================================
-- SCENARIO SETUP (Optional - for practice)
-- =============================================

PRINT 'This script can create intentional drift scenarios for practice.';
PRINT 'Comment/uncomment sections based on what you want to test.';
PRINT '';

-- =============================================
-- SCENARIO A: Object in Database, Not in Schema Model
-- =============================================

-- Uncomment to create test drift:
/*
PRINT 'Creating test table not in schema model...';
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'TempTestTable')
BEGIN
    CREATE TABLE dbo.TempTestTable (
        TestID INT PRIMARY KEY IDENTITY(1,1),
        TestData NVARCHAR(100),
        CreatedDate DATETIME DEFAULT GETDATE()
    );
    PRINT '✓ Created dbo.TempTestTable (should NOT be in schema model)';
END
PRINT '';
*/

-- =============================================
-- SCENARIO B: Object Definition Mismatch
-- =============================================

-- Uncomment to create definition drift:
/*
PRINT 'Modifying existing table to create drift...';
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Customers' AND SCHEMA_NAME(schema_id) = 'Sales')
BEGIN
    -- Check if column exists before altering
    IF EXISTS (
        SELECT 1 FROM sys.columns 
        WHERE object_id = OBJECT_ID('Sales.Customers') 
        AND name = 'Phone'
    )
    BEGIN
        ALTER TABLE Sales.Customers
        ALTER COLUMN Phone NVARCHAR(15);  -- Different from schema model
        
        PRINT '✓ Modified Sales.Customers.Phone to NVARCHAR(15)';
        PRINT '  (Schema model may define it differently)';
    END
END
PRINT '';
*/

-- =============================================
-- CURRENT ENVIRONMENT INVENTORY
-- =============================================

PRINT '========================================';
PRINT 'Current Database Inventory';
PRINT '========================================';
PRINT '';

-- List all schemas
PRINT 'Schemas:';
SELECT name AS SchemaName
FROM sys.schemas
WHERE principal_id <> 4
ORDER BY name;
PRINT '';

-- List all tables
PRINT 'Tables:';
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS TableName,
    create_date AS Created,
    modify_date AS LastModified
FROM sys.tables
WHERE is_ms_shipped = 0
ORDER BY SCHEMA_NAME(schema_id), name;
PRINT '';

-- List all views
PRINT 'Views:';
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ViewName
FROM sys.views
WHERE is_ms_shipped = 0
ORDER BY SCHEMA_NAME(schema_id), name;
PRINT '';

-- List all stored procedures
PRINT 'Stored Procedures:';
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ProcedureName
FROM sys.procedures
WHERE is_ms_shipped = 0
ORDER BY SCHEMA_NAME(schema_id), name;
PRINT '';

-- =============================================
-- OBJECT COUNT SUMMARY
-- =============================================

PRINT '========================================';
PRINT 'Object Count Summary';
PRINT '========================================';
PRINT '';

DECLARE @tableCount INT = (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0);
DECLARE @viewCount INT = (SELECT COUNT(*) FROM sys.views WHERE is_ms_shipped = 0);
DECLARE @procCount INT = (SELECT COUNT(*) FROM sys.procedures WHERE is_ms_shipped = 0);
DECLARE @functionCount INT = (SELECT COUNT(*) FROM sys.objects WHERE type IN ('FN', 'IF', 'TF') AND is_ms_shipped = 0);

PRINT 'Total Tables: ' + CAST(@tableCount AS NVARCHAR(10));
PRINT 'Total Views: ' + CAST(@viewCount AS NVARCHAR(10));
PRINT 'Total Stored Procedures: ' + CAST(@procCount AS NVARCHAR(10));
PRINT 'Total Functions: ' + CAST(@functionCount AS NVARCHAR(10));
PRINT '';

-- =============================================
-- VALIDATION CHECKLIST
-- =============================================

PRINT '========================================';
PRINT 'Sync Validation Checklist';
PRINT '========================================';
PRINT '';

PRINT 'Complete these steps in Flyway Desktop:';
PRINT '';
PRINT '1. Open Flyway Desktop';
PRINT '2. Navigate to Compare/Diff view';
PRINT '3. Set Source: Schema Model';
PRINT '4. Set Target: Development Database';
PRINT '5. Click "Compare" or "Generate Diff"';
PRINT '';
PRINT 'Expected Results:';
PRINT '';
PRINT '✓ BEST CASE: "No differences detected"';
PRINT '  → You are in sync! Proceed to Quest 04.';
PRINT '';
PRINT '⚠ COMMON CASE: "Differences detected"';
PRINT '  → Review differences carefully';
PRINT '  → Decide: Sync database to schema model? Or capture database changes?';
PRINT '  → Most common: Sync database to match schema model';
PRINT '';

-- =============================================
-- COMMON DIFFERENCE CATEGORIES
-- =============================================

PRINT '========================================';
PRINT 'Understanding Differences';
PRINT '========================================';
PRINT '';

PRINT 'Category 1: Objects in Database but NOT in Schema Model';
PRINT '  Causes:';
PRINT '    - Manual test tables created';
PRINT '    - Old development work not cleaned up';
PRINT '    - System objects not filtered';
PRINT '  Action:';
PRINT '    - DROP if temporary/test objects';
PRINT '    - CAPTURE if should be tracked';
PRINT '    - FILTER if system objects';
PRINT '';

PRINT 'Category 2: Objects in Schema Model but NOT in Database';
PRINT '  Causes:';
PRINT '    - Fresh database never deployed';
PRINT '    - Haven''t pulled latest schema model';
PRINT '    - Team added objects you don''t have';
PRINT '  Action:';
PRINT '    - DEPLOY schema model to database';
PRINT '';

PRINT 'Category 3: Object Definition Mismatch';
PRINT '  Causes:';
PRINT '    - Someone modified database directly';
PRINT '    - Schema model updated but DB not synced';
PRINT '    - Merge conflict in Git';
PRINT '  Action:';
PRINT '    - Decide which is correct';
PRINT '    - UPDATE the incorrect one';
PRINT '';

-- =============================================
-- SYNC RESOLUTION COMMANDS
-- =============================================

PRINT '========================================';
PRINT 'Resolving Differences';
PRINT '========================================';
PRINT '';

PRINT 'Option A: Sync Database to Schema Model (Most Common)';
PRINT '  In Flyway Desktop:';
PRINT '    1. Review changes carefully';
PRINT '    2. Click "Synchronize" or "Deploy to Development"';
PRINT '    3. Flyway applies changes to database';
PRINT '    4. Re-run comparison to verify';
PRINT '';

PRINT 'Option B: Capture Database Changes to Schema Model';
PRINT '  In Flyway Desktop:';
PRINT '    1. Review database changes';
PRINT '    2. Use "Capture" feature';
PRINT '    3. Commit updated schema model';
PRINT '    4. Coordinate with team!';
PRINT '';

-- =============================================
-- POST-SYNC VERIFICATION QUERIES
-- =============================================

PRINT '========================================';
PRINT 'Post-Sync Verification Queries';
PRINT '========================================';
PRINT '';

PRINT 'After synchronizing, run these to verify:';
PRINT '';

PRINT '-- Verify table structure';
PRINT 'SELECT TABLE_SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH';
PRINT 'FROM INFORMATION_SCHEMA.COLUMNS';
PRINT 'WHERE TABLE_SCHEMA IN (''Sales'', ''Logistics'', ''Operation'', ''Customers'')';
PRINT 'ORDER BY TABLE_SCHEMA, TABLE_NAME, ORDINAL_POSITION;';
PRINT '';

PRINT '-- Verify all expected objects exist';
PRINT 'SELECT ';
PRINT '    SCHEMA_NAME(schema_id) AS SchemaName,';
PRINT '    name AS ObjectName,';
PRINT '    type_desc AS ObjectType';
PRINT 'FROM sys.objects';
PRINT 'WHERE is_ms_shipped = 0';
PRINT 'ORDER BY SCHEMA_NAME(schema_id), type_desc, name;';
PRINT '';

-- =============================================
-- NEXT STEPS
-- =============================================

PRINT '========================================';
PRINT 'Ready for Quest 04!';
PRINT '========================================';
PRINT '';

PRINT 'Once you have successfully:';
PRINT '  - Run comparison in Flyway Desktop';
PRINT '  - Resolved all differences';
PRINT '  - Verified "No differences detected"';
PRINT '  - Understand the importance of sync validation';
PRINT '';
PRINT 'Proceed to Quest 04: Capture New Changes';
PRINT '';
PRINT '⚠ CRITICAL REMINDER:';
PRINT 'Always validate sync:';
PRINT '  - After cloning project';
PRINT '  - After git pull';
PRINT '  - After switching branches';
PRINT '  - Before capturing new changes';
PRINT '';
PRINT '========================================';
GO
