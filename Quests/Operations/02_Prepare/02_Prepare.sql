-- Operations Quest - 02_Prepare
-- Setup Script

-- This quest generates deployment scripts
-- No database changes needed

PRINT '=== 02_Prepare Quest Prerequisites ===';
PRINT '';
PRINT 'This quest generates deployment scripts from your schema model.';
PRINT '';
PRINT 'Prerequisites:';
PRINT '  1. Completed 00_Diff quest';
PRINT '  2. Completed 01_Model quest (schema model validated)';
PRINT '  3. schema-model/ folder with validated SQL files';
PRINT '  4. Flyway CLI installed';
PRINT '';
PRINT 'No database setup required!';
PRINT '';
PRINT '=== Generation Commands ===';
PRINT '';
PRINT '1. Generate deployment script:';
PRINT '   flyway generate -generate.location=filesystem:schema-model -generate.description="Deploy to Test"';
PRINT '';
PRINT '2. Review generated script:';
PRINT '   code migrations\V*.sql';
PRINT '';
PRINT '3. (Enterprise) Dry-run test:';
PRINT '   flyway migrate -dryRunOutput=dry-run.sql -environment=test';
PRINT '';
PRINT '4. (Enterprise) Run Flyway Check:';
PRINT '   flyway check -changes -environment=test';
PRINT '';
PRINT 'Proceed to 02_Prepare.md for the full quest!';
