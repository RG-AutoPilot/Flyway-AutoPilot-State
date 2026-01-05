# Redgate Offline Permit Decoding

This folder contains utility scripts to decode and validate Redgate offline permit files. These scripts are useful for checking license expiration dates and verifying product entitlements without needing an internet connection.

## What is an Offline Permit?

Redgate offline permits are JWT (JSON Web Token) files that contain licensing information for Redgate products. They allow Flyway and other Redgate tools to operate in air-gapped or restricted network environments where online license validation is not possible.

The permit file is typically stored at:
- **Windows**: `C:\Program Files\Red Gate\Permits\permit.dat`
- **Linux**: `/etc/redgate/permits/permit.dat`

## Scripts

### Windows (PowerShell)
- **Redgate_Offline_Permit_Decoding.ps1** - PowerShell script for Windows environments

### Linux (Bash)
- **Redgate_Offline_Permit_Decoding.sh** - Bash script for Linux environments

## What These Scripts Do

The scripts perform the following operations:

1. **Locate the permit file** - Checks default location or uses `PERMIT_PATH` environment variable
2. **Decode the JWT token** - Extracts licensing information from the Base64URL encoded token
3. **Display product licenses** - Shows which Redgate products are licensed
4. **Check expiration dates** - Validates permit and product license expiry
5. **Warn about upcoming expiration** - Alerts if licenses expire within 30 days
6. **Return exit codes** - Enables automation and monitoring integration

## Usage

### PowerShell (Windows)

```powershell
# Run with default permit location
.\Redgate_Offline_Permit_Decoding.ps1

# Run with custom permit location
$env:PERMIT_PATH = "C:\CustomPath\permit.dat"
.\Redgate_Offline_Permit_Decoding.ps1
```

### Bash (Linux)

```bash
# Run with default permit location
./Redgate_Offline_Permit_Decoding.sh

# Run with custom permit location
export PERMIT_PATH="/custom/path/permit.dat"
./Redgate_Offline_Permit_Decoding.sh
```

## Output Example

```
Using permit file: C:\Program Files\Red Gate\Permits\permit.dat

Permit expiration:
  Date: 2026-12-31 23:59:59
  Days remaining: 380
  Status: OK

Products:
Product 64 license #1:
  Date: 2026-12-31 23:59:59
  Days remaining: 380
  Status: OK
```

## Exit Codes

The scripts return the following exit codes for automation:

| Exit Code | Meaning |
|-----------|---------|
| 0 | All licenses valid and no warnings |
| 1 | License expired or expiring soon (within 30 days) |
| 2 | Script error (permit file not found, invalid format, etc.) |

## Configuration

You can customize the following variables in the script:

### Products to Check
By default, the scripts check Flyway (Product ID: 64). You can modify the `productsToCheck` array to include other Redgate products:

```powershell
$productsToCheck = @(64)   # 64 = Flyway
```

### Warning Threshold
Modify the number of days before expiration to trigger warnings:

```powershell
$warningDays = 30   # Warn when less than 30 days remain
```

## Common Use Cases

### 1. Manual License Verification
Run the script manually to check when your Flyway license expires:
```powershell
.\Redgate_Offline_Permit_Decoding.ps1
```

### 2. Automated Monitoring
Integrate into monitoring systems to alert before license expiration:
```powershell
.\Redgate_Offline_Permit_Decoding.ps1
if ($LASTEXITCODE -ne 0) {
    Send-Alert "Flyway license expiring soon!"
}
```

### 3. CI/CD Pipeline Checks
Add to CI/CD pipelines to prevent deployments with expired licenses:
```yaml
- name: Check Flyway License
  run: |
    ./Redgate_Offline_Permit_Decoding.ps1
    if [ $? -ne 0 ]; then exit 1; fi
```

### 4. Pre-Deployment Validation
Verify licenses before running Flyway migrations:
```powershell
# Check license first
.\Redgate_Offline_Permit_Decoding.ps1
if ($LASTEXITCODE -eq 0) {
    # License is valid, proceed with migration
    flyway migrate
}
```

## Troubleshooting

### Permit File Not Found
If the script cannot find your permit file:
1. Verify the file exists at the default location
2. Set the `PERMIT_PATH` environment variable to the correct location
3. Ensure you have read permissions for the permit file

### Invalid JWT Format Error
This indicates the permit file is corrupted or not a valid JWT token:
1. Obtain a new permit file from Redgate
2. Verify the file wasn't modified or truncated
3. Check file permissions haven't changed the contents

### Product Not Found
If a product ID is not in your permit:
1. Verify you have a license for that product
2. Check the product ID is correct (64 = Flyway)
3. Obtain an updated permit that includes the required product

## Product IDs

Common Redgate Product IDs:
- **64** - Flyway (all editions)

For other Redgate products, contact Redgate Support for the correct product ID.

## Support

For issues with:
- **These scripts**: Open an issue in this repository
- **Offline permits**: Contact [Redgate Support](https://www.red-gate.com/support/)
- **Flyway licensing**: Visit [Flyway Licensing Documentation](https://documentation.red-gate.com/flyway)

---

**Note**: These scripts only decode and validate existing permits. They do not generate or modify license files. To obtain or renew offline permits, contact Redgate Sales or Support.
