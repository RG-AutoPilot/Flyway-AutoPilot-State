# ===========================
# Script Name: 04_Flyway_State_Deploy.ps1
# Version: 1.0.1
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-25
# Description: Flyway State Based - Use the Deploy verb to run referenced script against a target environment
# ===========================

# Variables - Customize these for your environment #
$SCRIPT_FILENAME = "%temp%\Artifacts\D_Flyway-Dryrun_Deployment_Script-$(get-date -f yyyyMMdd).sql"  # Path to deployment script to execute
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"  # Path to Flyway state-based project root
$TARGET_ENVIRONMENT = "Test"  # Target database environment name
$TARGET_ENVIRONMENT_USERNAME = ""  # Target database username (leave empty for flyway.toml)
$TARGET_ENVIRONMENT_PASSWORD = ""  # Target database password (use env variables in production)
$SAVE_SNAPSHOT = "true" # Optional - Save schema snapshot in target environment

# Deploy Script to target #
flyway deploy `
"-environment=$TARGET_ENVIRONMENT" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
"-deploy.scriptFilename=$SCRIPT_FILENAME" `
"-deploy.saveSnapshot=$SAVE_SNAPSHOT" `
-workingDirectory="$WORKING_DIRECTORY"