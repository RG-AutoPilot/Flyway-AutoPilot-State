#!/bin/bash

# ===========================
# Script Name: 04_Flyway_State_Deploy.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-15
# Description: Flyway State Based - Use the Deploy verb to run referenced script against a target environment
# ===========================

# Variables - Customize these for your environment #
SCRIPT_FILENAME="D_Flyway_Deployment_Script.sql"  # Path to deployment script to execute
WORKING_DIRECTORY="/home/user/flyway-projects/state/mssql/chinook"  # Path to Flyway state-based project root
TARGET_ENVIRONMENT="Test"  # Target database environment name
TARGET_ENVIRONMENT_USERNAME=""  # Target database username (leave empty for flyway.toml)
TARGET_ENVIRONMENT_PASSWORD=""  # Target database password (use env variables in production)
SAVE_SNAPSHOT="true"  # Optional - Save schema snapshot in target environment

# Deploy Script to target #
flyway deploy \
"-environment=$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
"-deploy.scriptFilename=$SCRIPT_FILENAME" \
"-deploy.saveSnapshot=$SAVE_SNAPSHOT" \
-workingDirectory="$WORKING_DIRECTORY"