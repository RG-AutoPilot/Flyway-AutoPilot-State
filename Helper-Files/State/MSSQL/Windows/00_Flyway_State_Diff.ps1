# ===========================
# Script Name: 00_Flyway_State_Diff.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the DIFF verb to create an artifact between two environments
# ===========================

# Variables - Customize these for your environment #
$ARTIFACT_FILENAME = "%temp%/Artifacts/Flyway.State.Development.differences-$(get-date -f yyyyMMdd).zip"  # Output file for comparison results
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"  # Path to Flyway state-based project root
$SOURCE_ENVIRONMENT = "development"  # Source database environment name
$SOURCE_ENVIRONMENT_USERNAME = ""  # Source database username (leave empty for flyway.toml)
$SOURCE_ENVIRONMENT_PASSWORD = ""  # Source database password (use env variables in production)
$TARGET_ENVIRONMENT = "schemaModel"  # Target environment name (schemaModel for state-based)

# Calculate the differences between two entities (Databases/Folders & More) #
flyway diff `
"-diff.source=$SOURCE_ENVIRONMENT" `
"-diff.target=$TARGET_ENVIRONMENT" `
"-environments.$SOURCE_ENVIRONMENT.user=$SOURCE_ENVIRONMENT_USERNAME" `
"-environments.$SOURCE_ENVIRONMENT.password=$SOURCE_ENVIRONMENT_PASSWORD" `
"-diff.artifactFilename=$ARTIFACT_FILENAME" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model" `
-workingDirectory="$WORKING_DIRECTORY" `
-schemaModelSchemas=""