param(
    [switch]$All  # Optional: run all steps without prompts
)

Write-Host "Starting Flyway State-Based Workflow - Run All..." -ForegroundColor Green

# Define steps with descriptions
$steps = @(
    @{ Name = '00_Flyway_State_Diff.ps1';     Description = 'Compare current Development state with project Schema Model state and create artifact' },
    @{ Name = '01_Flyway_State_Model.ps1';    Description = 'Update or validate schema model from artifact' },
    @{ Name = '02_Flyway_State_Prepare.ps1';  Description = 'Generate deployment and undo scripts' },
    @{ Name = '03a_Flyway_State_Snapshot.ps1'; Description = 'Create schema snapshot for point-in-time recovery' },
    @{ Name = '03b_Flyway_State_Check.ps1';    Description = 'Analyze changes, detect drift, and generate compliance reports' },
    @{ Name = '04_Flyway_State_Deploy.ps1';   Description = 'Execute deployment script against target with optional snapshot' }
)

# Determine base folder
if ($PSScriptRoot) {
    $basePath = $PSScriptRoot
} else {
    Write-Host "Cannot determine script location (likely running in VS Code selection mode)." -ForegroundColor Yellow
    $basePath = Read-Host "Please enter the full path to the folder containing the step scripts"
}

# Validate base folder
if (-not (Test-Path -LiteralPath $basePath)) {
    Write-Host "ERROR: The path '$basePath' does not exist." -ForegroundColor Red
    exit 1
}

Write-Host ("Flyway State-Based Deployment") -ForegroundColor Magenta
Write-Host ("Script folder: {0}" -f $basePath) -ForegroundColor DarkGray

# Check that all steps exist before starting
foreach ($step in $steps) {
    $filePath = Join-Path -Path $basePath -ChildPath $step.Name
    if (-not (Test-Path -LiteralPath $filePath)) {
        Write-Host "ERROR: Missing step script '$($step.Name)' in '$basePath'." -ForegroundColor Red
        exit 1
    }
}

# Run steps
foreach ($step in $steps) {
    $stepPath = Join-Path -Path $basePath -ChildPath $step.Name

    if (-not $All) {
        Write-Host ""
        Write-Host "Step: $($step.Name)" -ForegroundColor Cyan
        Write-Host "Description: $($step.Description)" -ForegroundColor DarkGray
        $resp = Read-Host "Run this step? (Y/N, default=Y)"

        # Default to Yes if Enter pressed; only skip on explicit 'N' or 'No'
        if (-not [string]::IsNullOrWhiteSpace($resp) -and $resp -notmatch '^(?i:y|yes)$') {
            Write-Host "Skipping step: $($step.Name)" -ForegroundColor Yellow
            continue
        }
    }

    Write-Host "Running step: $($step.Name) - $($step.Description)" -ForegroundColor Green

    # Execute step and determine outcome robustly
    $stepSucceeded = $true
    $exitCode = 0

    try {
        # Reset LASTEXITCODE so we don't carry over stale non-zero values
        $LASTEXITCODE = 0

        & $stepPath

        # Capture any exit code set by the step
        if ($LASTEXITCODE -ne $null) {
            $exitCode = [int]$LASTEXITCODE
        }

        # If last command failed, mark as failure
        if (-not $?) {
            $stepSucceeded = $false
            if ($exitCode -eq 0) { $exitCode = 1 }
        }

        # Non-zero exit code indicates failure too
        if ($exitCode -ne 0) {
            $stepSucceeded = $false
        }
    }
    catch {
        $stepSucceeded = $false
        if ($exitCode -eq 0) { $exitCode = 1 }
        Write-Host ("Exception: {0}" -f $_.Exception.Message) -ForegroundColor Red
    }

    if (-not $stepSucceeded) {
        Write-Host "ERROR: Step $($step.Name) failed. ExitCode=$exitCode" -ForegroundColor Red
        exit $exitCode
    }

    Write-Host "Step $($step.Name) completed." -ForegroundColor Green
    
    # Special handling after Check step - Pipeline Approval Gate
    if ($step.Name -eq '03b_Flyway_State_Check.ps1') {
        Write-Host ""
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host "DEPLOYMENT APPROVAL GATE" -ForegroundColor Yellow
        Write-Host "========================================" -ForegroundColor Yellow
        Write-Host ""
        Write-Host "The Check command has generated a detailed report of the changes to be deployed." -ForegroundColor Cyan
        Write-Host "This report includes:" -ForegroundColor Cyan
        Write-Host "  - Change analysis (what will be modified)" -ForegroundColor DarkGray
        Write-Host "  - Drift detection (unauthorized changes)" -ForegroundColor DarkGray
        Write-Host "  - Code quality analysis" -ForegroundColor DarkGray
        Write-Host ""
        Write-Host "Report location: .\Artifact\Flyway-Check-All_Report.html (in your Flyway project folder, unless customized)" -ForegroundColor DarkGray
        Write-Host ""
        
        # Try to locate and open the report
        $reportPattern = Join-Path -Path $basePath -ChildPath "Artifact\Flyway-Check-All_Report.html"
        if (Test-Path $reportPattern) {
            Write-Host "Opening Check Report..." -ForegroundColor Green
            Start-Process $reportPattern
            Start-Sleep -Seconds 2
        }
        
        Write-Host ""
        Write-Host "Please review the Check Report before proceeding." -ForegroundColor Yellow
        Write-Host ""
        
        # Approval prompt
        do {
            $approval = Read-Host "Do you APPROVE this deployment? (APPROVE/REJECT, default=APPROVE)"
            $approval = $approval.Trim().ToUpper()
            
            # Default to APPROVE if Enter pressed
            if ([string]::IsNullOrWhiteSpace($approval)) {
                $approval = "APPROVE"
            }
            
            if ($approval -eq "APPROVE" -or $approval -eq "A") {
                Write-Host ""
                Write-Host "✓ Deployment APPROVED - Proceeding to Deploy step..." -ForegroundColor Green
                Write-Host ""
                break
            }
            elseif ($approval -eq "REJECT" -or $approval -eq "R") {
                Write-Host ""
                Write-Host "✗ Deployment REJECTED - Pipeline stopped by user" -ForegroundColor Red
                Write-Host ""
                Write-Host "No changes have been deployed to the target environment." -ForegroundColor Yellow
                Write-Host "Review the Check Report and make necessary adjustments before running again." -ForegroundColor Yellow
                exit 0
            }
            else {
                Write-Host "Invalid input. Please enter APPROVE or REJECT." -ForegroundColor Red
            }
        } while ($true)
    }
}

Write-Host "`nFlyway State-Based Deployment Complete!" -ForegroundColor Green
