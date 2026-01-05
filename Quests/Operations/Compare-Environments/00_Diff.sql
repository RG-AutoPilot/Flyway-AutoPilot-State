-- Operations Quest - 00_Diff
-- Setup Script

-- This quest uses your existing schema model and databases
-- No database objects need to be created

-- Prerequisites check:
PRINT '=== 00_Diff Quest Prerequisites ===';
PRINT '';

-- 1. Verify you have a schema model
-- Check: schema-model/ folder exists in your project

-- 2. Verify you have Dev database (build environment)
IF DB_ID('AutopilotDev') IS NOT NULL
    PRINT '✓ AutopilotDev database exists';
ELSE
    PRINT '✗ AutopilotDev database NOT found - create it first';

-- 3. Verify you have Test database (target environment)  
IF DB_ID('AutopilotTest') IS NOT NULL
    PRINT '✓ AutopilotTest database exists';
ELSE
    PRINT '✗ AutopilotTest database NOT found - create it first';

PRINT '';
PRINT 'To create missing databases, run:';
PRINT 'USE master;';
PRINT 'CREATE DATABASE AutopilotDev;';
PRINT 'CREATE DATABASE AutopilotTest;';
PRINT '';

-- 4. Optionally create some drift in Test to make diff interesting
USE AutopilotTest;
GO

-- Create an "unauthorized" table to demonstrate drift detection
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'UnauthorizedTable')
BEGIN
    CREATE TABLE dbo.UnauthorizedTable (
        ID INT PRIMARY KEY IDENTITY,
        CreatedDate DATETIME DEFAULT GETDATE(),
        Notes NVARCHAR(200)
    );
    
    PRINT '✓ Created UnauthorizedTable in Test to demonstrate drift detection';
END;

PRINT '';
PRINT '=== Setup Complete ===';
PRINT 'Now run: flyway diff -diff.source=schemaModel -diff.target=test';
PRINT 'You should see UnauthorizedTable flagged for deletion (drift!)';
