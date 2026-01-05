-- =============================================
-- Development Quest 11 - Placeholders Setup
-- =============================================

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 11: Placeholders';
PRINT '========================================';
PRINT '';

-- Ensure Logistics schema exists
IF NOT EXISTS (SELECT 1 FROM sys.schemas WHERE name = 'Logistics')
BEGIN
    CREATE SCHEMA Logistics;
    PRINT '✓ Created Logistics schema';
END

PRINT '';
PRINT 'flyway.toml Configuration Example:';
PRINT '';
PRINT '[flyway.placeholders]';
PRINT 'appName = "Airline Management System"';
PRINT '';
PRINT '[environments.development.flyway.placeholders]';
PRINT 'linkedServer = "DEV_LinkedServer"';
PRINT 'emailDomain = "@dev.company.com"';
PRINT 'maxRetries = "3"';
PRINT '';
PRINT '[environments.production.flyway.placeholders]';
PRINT 'linkedServer = "PROD_LinkedServer"';
PRINT 'emailDomain = "@company.com"';
PRINT 'maxRetries = "10"';
PRINT '';

PRINT '========================================';
PRINT 'Create Stored Procedure with Placeholders';
PRINT '========================================';
PRINT '';

PRINT 'CREATE PROCEDURE Logistics.GetExternalFlightData';
PRINT '    @FlightNumber NVARCHAR(20)';
PRINT 'AS';
PRINT 'BEGIN';
PRINT '    -- Placeholder for linked server';
PRINT '    SELECT *';
PRINT '    FROM [${linkedServer}].ExternalDB.dbo.Flights';
PRINT '    WHERE FlightNumber = @FlightNumber;';
PRINT '    ';
PRINT '    -- Placeholder for email domain';
PRINT '    DECLARE @NotificationEmail NVARCHAR(100) = ''alerts${emailDomain}'';';
PRINT '    ';
PRINT '    -- Placeholder for retry count';
PRINT '    DECLARE @MaxRetries INT = ${maxRetries};';
PRINT 'END;';
PRINT '';

PRINT '========================================';
PRINT 'Quest Instructions';
PRINT '========================================';
PRINT '';

PRINT '1. Edit flyway.toml to add placeholders';
PRINT '2. Create the stored procedure above in Dev database';
PRINT '3. Capture in Flyway Desktop';
PRINT '4. Verify schema-model file contains ${placeholder} syntax';
PRINT '5. Test resolution: flyway info -environment=development';
PRINT '6. Commit changes';
PRINT '';

PRINT '========================================';
PRINT 'Reference Documentation';
PRINT '========================================';
PRINT '';
PRINT 'https://documentation.red-gate.com/fd/flyway-placeholders-namespace-277579022.html';
PRINT '';

PRINT '========================================';
GO
