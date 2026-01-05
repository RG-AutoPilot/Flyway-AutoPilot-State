-- =============================================
-- Development Quest 08 - Feature Branch Workflow Setup
-- =============================================

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 08: Feature Branch Workflow';
PRINT '========================================';
PRINT '';

PRINT 'Git Commands for Feature Branch Workflow:';
PRINT '';

PRINT '1. Create feature branch:';
PRINT '   git checkout develop';
PRINT '   git pull origin develop';
PRINT '   git checkout -b feature/discount-codes';
PRINT '';

PRINT '2. Verify current branch:';
PRINT '   git branch  # Should show * feature/discount-codes';
PRINT '';

PRINT '3. Create the DiscountCodes table:';
PRINT '';
PRINT 'CREATE TABLE Sales.DiscountCodes (';
PRINT '    DiscountCodeID INT PRIMARY KEY IDENTITY(1,1),';
PRINT '    Code NVARCHAR(20) NOT NULL UNIQUE,';
PRINT '    DiscountPercentage DECIMAL(5,2) NOT NULL,';
PRINT '    ValidFrom DATE NOT NULL,';
PRINT '    ValidUntil DATE NOT NULL,';
PRINT '    IsActive BIT DEFAULT 1,';
PRINT '    CONSTRAINT CHK_DiscountCodes_Dates CHECK (ValidUntil >= ValidFrom),';
PRINT '    CONSTRAINT CHK_DiscountCodes_Percentage CHECK (DiscountPercentage BETWEEN 0 AND 100)';
PRINT ');';
PRINT '';

PRINT '4. Capture in Flyway Desktop';
PRINT '5. Commit to feature branch:';
PRINT '   git add schema-model/Tables/Sales.DiscountCodes.sql';
PRINT '   git commit -m "Add Sales.DiscountCodes table"';
PRINT '   git push origin feature/discount-codes';
PRINT '';

PRINT '6. Verify isolation:';
PRINT '   git checkout develop  # Switch to develop';
PRINT '   git log --oneline -3  # Your commit is NOT here';
PRINT '   git checkout feature/discount-codes  # Back to feature';
PRINT '';

PRINT '========================================';
GO
