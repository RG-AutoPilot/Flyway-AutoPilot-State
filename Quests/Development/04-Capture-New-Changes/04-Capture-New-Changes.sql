-- =============================================
-- Development Quest 04 - Capture New Changes Setup
-- =============================================

-- This script sets up the scenario for learning to capture changes.

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 04: Capture New Changes';
PRINT '========================================';
PRINT '';

-- =============================================
-- VERIFY SCHEMA EXISTS
-- =============================================

IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Sales')
BEGIN
    PRINT 'Creating Sales schema...';
    EXEC('CREATE SCHEMA Sales');
    PRINT '✓ Sales schema created';
END
ELSE
BEGIN
    PRINT '✓ Sales schema already exists';
END
PRINT '';

-- =============================================
-- INSTRUCTIONS
-- =============================================

PRINT '========================================';
PRINT 'Quest Instructions';
PRINT '========================================';
PRINT '';

PRINT 'In this quest, you will:';
PRINT '1. Create a new table in this database';
PRINT '2. Use Flyway Desktop to detect the change';
PRINT '3. Capture the change into the schema model';
PRINT '';

PRINT 'Follow these steps:';
PRINT '';
PRINT '----------------------------------------';
PRINT 'Step 1: Create the Campaigns table';
PRINT '----------------------------------------';
PRINT '';
PRINT 'CREATE TABLE Sales.Campaigns (';
PRINT '    CampaignID INT PRIMARY KEY IDENTITY(1,1),';
PRINT '    CampaignName NVARCHAR(100) NOT NULL,';
PRINT '    StartDate DATE NOT NULL,';
PRINT '    EndDate DATE NOT NULL,';
PRINT '    CreatedDate DATETIME DEFAULT GETDATE(),';
PRINT '    CONSTRAINT CHK_Campaigns_Dates CHECK (EndDate >= StartDate)';
PRINT ');';
PRINT '';

PRINT '----------------------------------------';
PRINT 'Step 2: Verify the table exists';
PRINT '----------------------------------------';
PRINT '';
PRINT 'SELECT * FROM INFORMATION_SCHEMA.TABLES';
PRINT 'WHERE TABLE_SCHEMA = ''Sales'' AND TABLE_NAME = ''Campaigns'';';
PRINT '';

PRINT '----------------------------------------';
PRINT 'Step 3: Open Flyway Desktop';
PRINT '----------------------------------------';
PRINT '- Navigate to Comparison/Diff view';
PRINT '- Source: Schema Model';
PRINT '- Target: Development Database';
PRINT '- Click "Compare"';
PRINT '';

PRINT '----------------------------------------';
PRINT 'Step 4: Capture the change';
PRINT '----------------------------------------';
PRINT '- Review detected differences';
PRINT '- Select Sales.Campaigns table';
PRINT '- Click "Capture" or "Add to Schema Model"';
PRINT '- Verify file created: schema-model\Tables\Sales.Campaigns.sql';
PRINT '';

PRINT '----------------------------------------';
PRINT 'Step 5: Verify synchronization';
PRINT '----------------------------------------';
PRINT '- Run comparison again';
PRINT '- Expected: "No differences detected"';
PRINT '';

-- =============================================
-- VERIFICATION QUERY
-- =============================================

PRINT '========================================';
PRINT 'Verification';
PRINT '========================================';
PRINT '';

PRINT 'After creating the table, run this to verify:';
PRINT '';
PRINT 'EXEC sp_help ''Sales.Campaigns'';';
PRINT '';

-- =============================================
-- SUCCESS CRITERIA
-- =============================================

PRINT '========================================';
PRINT 'Success Criteria';
PRINT '========================================';
PRINT '';

PRINT '✓ Sales.Campaigns table created in database';
PRINT '✓ Flyway Desktop detected the change';
PRINT '✓ Change captured into schema model';
PRINT '✓ File exists: schema-model\Tables\Sales.Campaigns.sql';
PRINT '✓ Comparison shows "No differences"';
PRINT '';

PRINT '========================================';
PRINT 'Ready to proceed!';
PRINT '========================================';
PRINT '';
PRINT 'Complete the steps in the Quest 04 guide.';
PRINT 'Then move to Quest 05: Commit and Push';
PRINT '';
GO
