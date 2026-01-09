# =============================================
# Development Quest 10 - Pull Changes Setup
# This script simulates a teammate adding a new table to the schema model
# =============================================

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Quest 10: Pull Changes from Version Control" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

Write-Host "This script will simulate a teammate pushing a new table to the schema model." -ForegroundColor Yellow
Write-Host ""

# Navigate to project root (assuming script is in Quests\Development\10-Pull-Changes)
$scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectRoot = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $scriptPath))
Set-Location $projectRoot

Write-Host "Project root: $projectRoot" -ForegroundColor Gray
Write-Host ""

# Define the schema model table path
$tableFilePath = Join-Path $projectRoot "schema-model\Tables\Sales.CustomerFeedback.sql"

# Check if file already exists
if (Test-Path $tableFilePath) {
    Write-Host "⚠️  WARNING: Sales.CustomerFeedback.sql already exists!" -ForegroundColor Yellow
    Write-Host "This might be from a previous run of this quest." -ForegroundColor Yellow
    Write-Host ""
    $overwrite = Read-Host "Do you want to overwrite it? (y/n)"
    
    if ($overwrite -ne 'y') {
        Write-Host ""
        Write-Host "Script cancelled. Existing file was not modified." -ForegroundColor Red
        exit
    }
}

# Create the table definition content
$tableContent = @"
CREATE TABLE [Sales].[CustomerFeedback] (
    [FeedbackID] INT IDENTITY(1,1) NOT NULL,
    [CustomerID] NCHAR(5) NOT NULL,
    [FeedbackDate] DATETIME NOT NULL DEFAULT GETDATE(),
    [Rating] INT NOT NULL,
    [Comments] NVARCHAR(500) NULL,
    [FollowUpRequired] BIT NOT NULL DEFAULT 0,
    [ResolutionDate] DATETIME NULL,
    CONSTRAINT [PK_CustomerFeedback] PRIMARY KEY CLUSTERED ([FeedbackID]),
    CONSTRAINT [CHK_CustomerFeedback_Rating] CHECK ([Rating] BETWEEN 1 AND 5),
    CONSTRAINT [FK_CustomerFeedback_Customers] 
        FOREIGN KEY ([CustomerID]) REFERENCES [Sales].[Customers]([CustomerID])
);
GO
"@

# Write the file
try {
    Set-Content -Path $tableFilePath -Value $tableContent -Force
    Write-Host "✓ Created: schema-model\Tables\Sales.CustomerFeedback.sql" -ForegroundColor Green
    Write-Host ""
} catch {
    Write-Host "❌ ERROR: Failed to create file: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

# Display what was created
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Simulated Teammate's Change" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "A new table definition has been added to your schema model:" -ForegroundColor White
Write-Host "  Table: Sales.CustomerFeedback" -ForegroundColor White
Write-Host "  Location: schema-model\Tables\Sales.CustomerFeedback.sql" -ForegroundColor White
Write-Host ""
Write-Host "This simulates what happens when a teammate:" -ForegroundColor Yellow
Write-Host "  1. Creates a table in their dev database" -ForegroundColor Yellow
Write-Host "  2. Uses Flyway Desktop to capture it to schema model" -ForegroundColor Yellow
Write-Host "  3. Commits and pushes to version control" -ForegroundColor Yellow
Write-Host "  4. You pull their changes (which we just simulated)" -ForegroundColor Yellow
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Next Steps (Follow the Quest Guide)" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Open Flyway Desktop" -ForegroundColor White
Write-Host "2. Go to the Diff tab" -ForegroundColor White
Write-Host "3. Set Source: schemaModel, Target: development" -ForegroundColor White
Write-Host "4. Click Compare - you'll see the new CustomerFeedback table" -ForegroundColor White
Write-Host "5. Click 'Apply to Development' to sync your database" -ForegroundColor White
Write-Host ""

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "Verification" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "After applying to development, run this SQL to verify:" -ForegroundColor White
Write-Host ""
Write-Host "  SELECT * FROM INFORMATION_SCHEMA.TABLES" -ForegroundColor Gray
Write-Host "  WHERE TABLE_SCHEMA = 'Sales' AND TABLE_NAME = 'CustomerFeedback';" -ForegroundColor Gray
Write-Host ""
Write-Host "  EXEC sp_help 'Sales.CustomerFeedback';" -ForegroundColor Gray
Write-Host ""

Write-Host "✓ Setup complete! Continue with the quest guide." -ForegroundColor Green
Write-Host ""

PRINT 'SELECT * FROM INFORMATION_SCHEMA.TABLES';
PRINT 'WHERE TABLE_SCHEMA = ''Sales'' AND TABLE_NAME = ''CustomerFeedback'';';
PRINT '';
PRINT 'EXEC sp_help ''Sales.CustomerFeedback'';';
PRINT '';

PRINT '========================================';
GO
