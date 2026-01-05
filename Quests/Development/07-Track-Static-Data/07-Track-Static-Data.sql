-- =============================================
-- Development Quest 07 - Track Static Data Setup
-- =============================================

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 07: Track Static Data';
PRINT '========================================';
PRINT '';

-- Ensure Sales schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Sales')
BEGIN
    CREATE SCHEMA Sales;
END

-- Create Loyalty Program table with static data
IF NOT EXISTS (SELECT 1 FROM sys.tables WHERE name = 'LoyaltyProgram')
BEGIN
    CREATE TABLE Sales.LoyaltyProgram (
        TierID INT PRIMARY KEY,
        TierName NVARCHAR(50) NOT NULL,
        MinimumPoints INT NOT NULL,
        DiscountPercentage DECIMAL(5,2) NOT NULL
    );
    
    INSERT INTO Sales.LoyaltyProgram VALUES
        (1, 'Bronze', 0, 5.00),
        (2, 'Silver', 10000, 10.00),
        (3, 'Gold', 25000, 15.00),
        (4, 'Platinum', 50000, 20.00);
    
    PRINT '✓ Created Sales.LoyaltyProgram with tier data';
END
ELSE
BEGIN
    PRINT '✓ Sales.LoyaltyProgram already exists';
END

PRINT '';
PRINT 'Static Data:';
SELECT * FROM Sales.LoyaltyProgram ORDER BY TierID;
PRINT '';

PRINT '========================================';
PRINT 'Quest Instructions';
PRINT '========================================';
PRINT '';
PRINT '1. Open Flyway Desktop';
PRINT '2. Configure static data tracking for Sales.LoyaltyProgram';
PRINT '3. Capture table structure AND data';
PRINT '4. Verify files created in schema-model/';
PRINT '5. Commit and push changes';
PRINT '';
GO
