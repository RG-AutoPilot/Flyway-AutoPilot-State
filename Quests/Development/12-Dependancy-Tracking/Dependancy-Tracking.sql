-- ============================================================================
-- Dependency Management Quest - SQL Scripts
-- This script demonstrates Flyway's automatic dependency detection
-- ============================================================================

-- ============================================================================
-- Step 2: Create a Dependent View
-- ============================================================================

-- Create a simple reporting view based on Sales.Orders
CREATE VIEW [Sales].[OrderSummary] AS
SELECT 
    o.OrderID,
    o.CustomerID,
    o.EmployeeID,
    o.OrderDate,
    o.ShippedDate,
    c.CompanyName,
    c.ContactName
FROM 
    [Sales].[Orders] o
    INNER JOIN [Sales].[Customers] c ON o.CustomerID = c.CustomerID;
GO

-- Test the view
SELECT TOP 10 * FROM [Sales].[OrderSummary];
GO

-- ============================================================================
-- Step 5: Alter the Base Table
-- ============================================================================

-- Add a new column to track order priority
ALTER TABLE [Sales].[Orders]
ADD [Priority] NVARCHAR(20) NULL DEFAULT 'Standard';
GO

-- Update some sample data
UPDATE [Sales].[Orders]
SET [Priority] = 'High'
WHERE DATEDIFF(day, OrderDate, ShippedDate) <= 1;
GO

-- Set medium priority for orders shipped within 3 days
UPDATE [Sales].[Orders]
SET [Priority] = 'Medium'
WHERE DATEDIFF(day, OrderDate, ShippedDate) BETWEEN 2 AND 3
AND [Priority] = 'Standard';
GO

-- ============================================================================
-- Verification Queries
-- ============================================================================

-- Check the priority distribution
SELECT 
    [Priority],
    COUNT(*) AS OrderCount
FROM [Sales].[Orders]
GROUP BY [Priority]
ORDER BY OrderCount DESC;
GO

-- Verify the view still works after table change
SELECT TOP 10 * FROM [Sales].[OrderSummary]
ORDER BY OrderDate DESC;
GO
