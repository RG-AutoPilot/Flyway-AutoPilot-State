# ===========================
# Script Name: Redgate_Offline_Permit_Decoding.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-12-16
# Description: Decode Offline Permit JWT and display product license information
# ===========================

# ==============================
# Configuration
# ==============================

$defaultPermitPath = "C:\Program Files\Red Gate\Permits\permit.dat"
$permitPath        = if ($env:PERMIT_PATH) { $env:PERMIT_PATH } else { $defaultPermitPath }

$warningDays       = 30
$productsToCheck   = @(64)   # 64 = Flyway

# ==============================
# Helper Functions
# ==============================

function Convert-FromBase64Url {
    param ([string]$InputString)

    $s = $InputString.Replace('-', '+').Replace('_', '/')
    while ($s.Length % 4) { $s += "=" }

    [Text.Encoding]::UTF8.GetString(
        [Convert]::FromBase64String($s)
    )
}

function Parse-JWTToken {
    param ([string]$Token)

    if (-not ($Token.Contains('.') -and $Token.StartsWith('eyJ'))) {
        throw "Invalid JWT format"
    }

    $parts = $Token.Split('.')
    $payloadJson = Convert-FromBase64Url $parts[1]
    $payloadJson | ConvertFrom-Json
}

function Convert-UnixTime {
    param ([int64]$UnixTime)
    [DateTimeOffset]::FromUnixTimeSeconds($UnixTime).UtcDateTime
}

function Check-Expiry {
    param (
        [string]$Name,
        [int64]$UnixTime,
        [int]$WarnDays
    )

    $expiryDate = Convert-UnixTime $UnixTime
    $daysLeft   = ($expiryDate - (Get-Date)).Days

    Write-Host ""
    Write-Host "$Name expiration:"
    Write-Host "  Date: $expiryDate"
    Write-Host "  Days remaining: $daysLeft"

    if ($daysLeft -lt 0) {
        Write-Host "  Status: EXPIRED"
        return 1
    }
    elseif ($daysLeft -le $WarnDays) {
        Write-Host "  Status: EXPIRING (within $WarnDays days)"
        return 1
    }
    else {
        Write-Host "  Status: OK"
        return 0
    }
}

# ==============================
# Main
# ==============================

try {
    if (-not (Test-Path $permitPath)) {
        throw "Permit file not found: $permitPath"
    }

    Write-Host "Using permit file: $permitPath"

    $permit   = Get-Content $permitPath -Raw
    $jwt      = Parse-JWTToken $permit
    $exitCode = 0

    # ---- Permit expiry ----
    if ($jwt.exp) {
        $exitCode = $exitCode -bor (Check-Expiry `
            -Name "Permit" `
            -UnixTime $jwt.exp `
            -WarnDays $warningDays)
    }
    else {
        Write-Host "No exp claim found in permit"
    }

    # ---- Product expiry ----
    Write-Host ""
    Write-Host "Products:"

    foreach ($productId in $productsToCheck) {

        if (-not $jwt.products.PSObject.Properties.Name.Contains("$productId")) {
            Write-Host "Product ${productId}: Not found"
            $exitCode = 1
            continue
        }

        $licenses = $jwt.products.$productId.licenses
        $idx = 1

        foreach ($license in $licenses) {

            if ($license.ignoreVersionUntil) {
                $exitCode = $exitCode -bor (Check-Expiry `
                    -Name "Product ${productId} license #${idx}" `
                    -UnixTime $license.ignoreVersionUntil `
                    -WarnDays $warningDays)
            }
            else {
                Write-Host "Product ${productId} license #${idx}: No expiry (perpetual)"
            }

            $idx++
        }
    }

    exit $exitCode
}
catch {
    Write-Error $_
    exit 2
}
