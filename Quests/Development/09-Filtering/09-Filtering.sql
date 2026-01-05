-- =============================================
-- Development Quest 09 - Filtering Setup
-- =============================================

USE AutopilotDev;
GO

PRINT '========================================';
PRINT 'Quest 09: Filtering';
PRINT '========================================';
PRINT '';

-- List all schemas in database
PRINT 'All Schemas in Database:';
SELECT name AS SchemaName,
       CASE 
           WHEN name IN ('sys', 'INFORMATION_SCHEMA', 'guest') THEN 'System (EXCLUDE)'
           WHEN name LIKE 'db_%' THEN 'System Role (EXCLUDE)'
           WHEN name IN ('Sales', 'Logistics', 'Operation', 'Customers') THEN 'Our Team (INCLUDE)'
           ELSE 'Other (EXCLUDE if not yours)'
       END AS Category
FROM sys.schemas
WHERE principal_id <> 4
ORDER BY Category, name;
PRINT '';

-- Show object counts by schema
PRINT '========================================';
PRINT 'Object Counts by Schema';
PRINT '========================================';
PRINT '';

SELECT 
    SCHEMA_NAME(schema_id) AS SchemaName,
    COUNT(*) AS ObjectCount,
    CASE 
        WHEN SCHEMA_NAME(schema_id) IN ('Sales', 'Logistics', 'Operation', 'Customers') 
        THEN '✓ INCLUDE'
        ELSE '✗ EXCLUDE'
    END AS FilterAction
FROM sys.objects
WHERE is_ms_shipped = 0
GROUP BY SCHEMA_NAME(schema_id)
ORDER BY FilterAction, SchemaName;
PRINT '';

PRINT '========================================';
PRINT 'Filter Configuration Example';
PRINT '========================================';
PRINT '';

PRINT 'Add to flyway.toml:';
PRINT '';
PRINT '[flyway]';
PRINT 'schemas = ["Sales", "Logistics", "Operation", "Customers"]';
PRINT '';
PRINT '[flyway.schemaFilter]';
PRINT 'exclude = ["sys", "INFORMATION_SCHEMA", "guest", "db_%"]';
PRINT '';

PRINT '========================================';
PRINT 'Quest Instructions';
PRINT '========================================';
PRINT '';

PRINT '1. Open Flyway Desktop Settings/Preferences';
PRINT '2. Navigate to Schema Filters or Comparison Options';
PRINT '3. Configure Include Schemas:';
PRINT '   - Sales, Logistics, Operation, Customers';
PRINT '4. Configure Exclude Schemas:';
PRINT '   - sys, INFORMATION_SCHEMA, guest, db_%';
PRINT '5. Save configuration';
PRINT '6. Run comparison to verify reduced noise';
PRINT '7. Commit filter config to flyway.toml (team-wide)';
PRINT '';

PRINT '========================================';
GO
