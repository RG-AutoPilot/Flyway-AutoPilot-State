-- Operations Quest - 01_Model
-- Setup Script

-- This quest validates your schema model
-- No database changes needed

PRINT '=== 01_Model Quest Prerequisites ===';
PRINT '';
PRINT 'This quest validates your schema model files.';
PRINT '';
PRINT 'Prerequisites:';
PRINT '  1. Completed 00_Diff quest';
PRINT '  2. schema-model/ folder exists in your project';
PRINT '  3. Flyway CLI installed';
PRINT '';
PRINT 'No database setup required!';
PRINT '';
PRINT '=== Validation Commands ===';
PRINT '';
PRINT '1. Validate schema model:';
PRINT '   flyway model -model.location=filesystem:schema-model';
PRINT '';
PRINT '2. Compare model to Dev database:';
PRINT '   flyway diff -diff.source=schemaModel -diff.target=build';
PRINT '';
PRINT '3. Review diff to Test (from 00_Diff quest):';
PRINT '   flyway diff -diff.source=schemaModel -diff.target=test';
PRINT '';
PRINT 'Proceed to 01_Model.md for the full quest!';
