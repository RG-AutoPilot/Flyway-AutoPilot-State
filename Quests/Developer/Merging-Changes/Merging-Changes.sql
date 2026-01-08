-- =============================================
-- Merging Changes Quest - Setup Script
-- =============================================
-- This script creates the loyalty rewards program objects
-- that will be captured in a migration on a feature branch
-- =============================================

-- 1. Loyalty Program Table
-- Defines different loyalty reward programs
CREATE TABLE Sales.LoyaltyProgram (
    ProgramID INT IDENTITY(1,1) PRIMARY KEY,
    ProgramName NVARCHAR(100) NOT NULL,
    PointsPerDollar DECIMAL(5,2) NOT NULL DEFAULT 1.0,
    StartDate DATE NOT NULL,
    EndDate DATE NULL,
    IsActive BIT NOT NULL DEFAULT 1
);

-- 2. Customer Loyalty Table
-- Tracks customer enrollment in loyalty programs
CREATE TABLE Sales.CustomerLoyalty (
    CustomerLoyaltyID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    ProgramID INT NOT NULL,
    TotalPoints INT NOT NULL DEFAULT 0,
    EnrollmentDate DATE NOT NULL DEFAULT GETDATE(),
    LastActivityDate DATE NULL,
    FOREIGN KEY (ProgramID) REFERENCES Sales.LoyaltyProgram(ProgramID)
);

-- 3. Loyalty Transaction Table
-- Records all points earned and redeemed
CREATE TABLE Sales.LoyaltyTransaction (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerLoyaltyID INT NOT NULL,
    TransactionType NVARCHAR(20) NOT NULL CHECK (TransactionType IN ('Earned', 'Redeemed')),
    Points INT NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    Description NVARCHAR(200),
    FOREIGN KEY (CustomerLoyaltyID) REFERENCES Sales.CustomerLoyalty(CustomerLoyaltyID)
);

-- 4. Calculate Loyalty Points Function
-- Calculates points based on purchase amount and program rules
-- Returns 0 if program is not found or inactive
CREATE FUNCTION Sales.CalculateLoyaltyPoints(
    @PurchaseAmount DECIMAL(10,2),
    @ProgramID INT
)
RETURNS INT
AS
BEGIN
    DECLARE @Points INT;
    DECLARE @PointsPerDollar DECIMAL(5,2);
    
    -- Get the points per dollar for the program (NULL if not found or inactive)
    SELECT @PointsPerDollar = PointsPerDollar
    FROM Sales.LoyaltyProgram
    WHERE ProgramID = @ProgramID AND IsActive = 1;
    
    -- Calculate points (defaults to 1.0 points per dollar if program not found)
    -- Round down to nearest integer
    SET @Points = FLOOR(@PurchaseAmount * ISNULL(@PointsPerDollar, 1.0));
    
    RETURN @Points;
END;
GO

-- =============================================
-- Seed Data (Optional - for testing)
-- =============================================

-- Insert a sample loyalty program
INSERT INTO Sales.LoyaltyProgram (ProgramName, PointsPerDollar, StartDate, IsActive)
VALUES ('Gold Rewards', 1.5, '2024-01-01', 1);

-- Note: This script creates objects in your development database.
-- After running this, use Flyway Desktop to:
-- 1. Switch to your feature branch
-- 2. Generate a migration
-- 3. Commit and push the migration to the branch
