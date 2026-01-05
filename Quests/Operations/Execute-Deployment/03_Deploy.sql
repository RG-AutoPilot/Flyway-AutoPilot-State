-- =============================================
-- Operations Quest - 03_Deploy Setup
-- Execute State-Based Deployment
-- =============================================

-- This script prepares your environment for learning
-- how to deploy changes using Flyway CLI

USE AutopilotTest;
GO

-- =============================================
-- VERIFY PREVIOUS QUEST PREREQUISITES
-- =============================================

PRINT '========================================';
PRINT 'Verifying Prerequisites';
PRINT '========================================';
PRINT '';

-- Check if we have a generated deployment script
-- This should have been created in 02_Prepare quest
PRINT 'Expected: You have a deployment script in migrations/ folder';
PRINT 'Location: migrations\V[timestamp]__Deploy_to_Test.sql';
PRINT 'Created: In quest 02_Prepare';
PRINT '';

-- Verify Flyway schema history table exists
-- This tracks all deployments
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'flyway_schema_history')
BEGIN
    PRINT '✓ Flyway schema history table exists';
    
    -- Show current migration status
    PRINT '';
    PRINT 'Current migration history:';
    SELECT 
        installed_rank,
        version,
        description,
        type,
        installed_on,
        success
    FROM flyway_schema_history
    ORDER BY installed_rank;
END
ELSE
BEGIN
    PRINT '⚠ Flyway schema history table not found';
    PRINT '  This is normal if no deployments have run yet';
    PRINT '  Flyway will create this table on first deployment';
END
PRINT '';

-- =============================================
-- PRE-DEPLOYMENT DATABASE STATE
-- =============================================

PRINT '========================================';
PRINT 'Current Database State (Pre-Deployment)';
PRINT '========================================';
PRINT '';

-- Count existing objects
PRINT 'Object Counts:';
SELECT 
    type_desc AS ObjectType,
    COUNT(*) AS CurrentCount
FROM sys.objects
WHERE is_ms_shipped = 0
GROUP BY type_desc
ORDER BY type_desc;
PRINT '';

-- List all schemas
PRINT 'Existing Schemas:';
SELECT name AS SchemaName
FROM sys.schemas
WHERE principal_id <> 4  -- Exclude built-in schemas
ORDER BY name;
PRINT '';

-- List all user tables
PRINT 'Existing Tables:';
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS TableName
FROM sys.tables
WHERE is_ms_shipped = 0
ORDER BY SCHEMA_NAME(schema_id), name;
PRINT '';

-- List all stored procedures
PRINT 'Existing Stored Procedures:';
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ProcedureName
FROM sys.procedures
WHERE is_ms_shipped = 0
ORDER BY SCHEMA_NAME(schema_id), name;
PRINT '';

-- List all views
PRINT 'Existing Views:';
SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    name AS ViewName
FROM sys.views
WHERE is_ms_shipped = 0
ORDER BY SCHEMA_NAME(schema_id), name;
PRINT '';

-- =============================================
-- BACKUP RECOMMENDATION
-- =============================================

PRINT '========================================';
PRINT 'IMPORTANT: Backup Before Deploy';
PRINT '========================================';
PRINT '';
PRINT '⚠ Always create a backup before deploying!';
PRINT '';
PRINT 'To create a backup, run this in a NEW query window:';
PRINT '----------------------------------------------';
PRINT 'BACKUP DATABASE AutopilotTest';
PRINT 'TO DISK = ''C:\Backups\AutopilotTest_PreDeploy_' + FORMAT(GETDATE(), 'yyyyMMdd_HHmmss') + '.bak''';
PRINT 'WITH INIT, COMPRESSION;';
PRINT '----------------------------------------------';
PRINT '';

-- =============================================
-- DEPLOYMENT CHECKLIST
-- =============================================

PRINT '========================================';
PRINT 'Pre-Deployment Checklist';
PRINT '========================================';
PRINT '';
PRINT '□ Generated deployment script exists (from 02_Prepare quest)';
PRINT '□ Reviewed deployment script for accuracy';
PRINT '□ Created backup of Test database';
PRINT '□ Verified no one else is using Test database';
PRINT '□ Coordinated deployment time with team';
PRINT '□ Ready to execute: flyway migrate -environment=test';
PRINT '';

-- =============================================
-- POST-DEPLOYMENT VALIDATION QUERIES
-- =============================================

PRINT '========================================';
PRINT 'Post-Deployment Validation Queries';
PRINT '========================================';
PRINT '';
PRINT 'After deployment, run these queries to verify success:';
PRINT '';
PRINT '-- 1. Verify Flyway migration history';
PRINT 'SELECT version, description, installed_on, success';
PRINT 'FROM flyway_schema_history';
PRINT 'ORDER BY installed_rank DESC;';
PRINT '';
PRINT '-- 2. Verify object counts';
PRINT 'SELECT type_desc, COUNT(*) AS ObjectCount';
PRINT 'FROM sys.objects';
PRINT 'WHERE is_ms_shipped = 0';
PRINT 'GROUP BY type_desc;';
PRINT '';
PRINT '-- 3. Verify new schemas exist';
PRINT 'SELECT name FROM sys.schemas';
PRINT 'WHERE principal_id <> 4';
PRINT 'ORDER BY name;';
PRINT '';
PRINT '-- 4. Verify new tables exist';
PRINT 'SELECT SCHEMA_NAME(schema_id), name';
PRINT 'FROM sys.tables';
PRINT 'WHERE is_ms_shipped = 0';
PRINT 'ORDER BY SCHEMA_NAME(schema_id), name;';
PRINT '';

-- =============================================
-- READY TO DEPLOY
-- =============================================

PRINT '========================================';
PRINT 'Ready to Deploy!';
PRINT '========================================';
PRINT '';
PRINT 'You are now ready to execute the deployment.';
PRINT '';
PRINT 'Switch to PowerShell and run:';
PRINT '  flyway migrate -environment=test';
PRINT '';
PRINT 'Then return here to verify the deployment succeeded.';
PRINT '';
PRINT '========================================';
GO
