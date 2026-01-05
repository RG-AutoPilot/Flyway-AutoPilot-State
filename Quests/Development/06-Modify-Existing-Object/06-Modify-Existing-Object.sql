-- =============================================
-- Development Quest 06 - Modify Existing Object Setup
-- =============================================

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 06: Modify Existing Object';
PRINT '========================================';
PRINT '';

-- Verify Sales.Campaigns exists (should be from Quest 04)
IF EXISTS (SELECT 1 FROM sys.tables WHERE name = 'Campaigns' AND SCHEMA_NAME(schema_id) = 'Sales')
BEGIN
    PRINT '✓ Sales.Campaigns table exists';
    PRINT '';
    
    PRINT '========================================';
    PRINT 'Quest Instructions';
    PRINT '========================================';
    PRINT '';
    
    PRINT 'Follow these steps:';
    PRINT '';
    PRINT '1. Modify the existing table:';
    PRINT '   ALTER TABLE Sales.Campaigns';
    PRINT '   ADD Budget DECIMAL(18,2) NULL;';
    PRINT '';
    
    PRINT '2. Verify the change:';
    PRINT '   EXEC sp_help ''Sales.Campaigns'';';
    PRINT '';
    
    PRINT '3. Open Flyway Desktop and run comparison';
    PRINT '4. Detect the modification';
    PRINT '5. Recapture into schema model';
    PRINT '6. Verify schema-model/Tables/Sales.Campaigns.sql updated';
    PRINT '7. Commit and push changes';
    PRINT '';
END
ELSE
BEGIN
    PRINT '⚠ Sales.Campaigns table not found';
    PRINT 'Please complete Quest 04 first to create this table.';
END

PRINT '========================================';
GO
