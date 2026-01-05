# ===========================
# Script Name: 02_Flyway_State_Prepare.ps1
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the PREPARE verb to create deployment script between two environments (By default - Changes in the Schema Model not in the Test environment)
# ===========================

# Variables - Customize these for your environment #
$SCRIPT_FILENAME = "Flyway_Deployment_Script.sql"  # Output deployment script name
$UNDO_FILENAME = "Flyway_Undo_Script.sql"  # Output deployment script name
$WORKING_DIRECTORY = "C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"  # Path to Flyway state-based project root
$SOURCE_ENVIRONMENT = "schemaModel"  # Source environment name (desired state)
$TARGET_ENVIRONMENT = "Test"  # Target database environment name
$TARGET_ENVIRONMENT_USERNAME = ""  # Target database username (leave empty for flyway.toml)
$TARGET_ENVIRONMENT_PASSWORD = ""  # Target database password (use env variables in production)

# Prepare Script for Deployment #
flyway prepare `
"-prepare.source=$SOURCE_ENVIRONMENT" `
"-prepare.target=$TARGET_ENVIRONMENT" `
"-prepare.types=deploy,undo" `
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" `
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" `
"-prepare.scriptFilename=%temp%\Artifacts\D_$SCRIPT_FILENAME" `
"-prepare.undoFilename=%temp%\Artifacts\U_$UNDO_FILENAME" `
"-prepare.force=true" `
-configFiles="$WORKING_DIRECTORY\flyway.toml" `
-schemaModelLocation="$WORKING_DIRECTORY\schema-model"