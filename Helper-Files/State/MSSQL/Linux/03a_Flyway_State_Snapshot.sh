#!/bin/bash

# ===========================
# Script Name: 03a_Flyway_State_Snapshot.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-26
# Description: Flyway State Based - Use the Snapshot verb to create a schema snapshot of target database
# ===========================

# Variables - Customize these for your environment #
WORKING_DIRECTORY="/home/user/flyway-projects/state/mssql/chinook"  # Path to Flyway state-based project root
TARGET_ENVIRONMENT="Test"  # Target database environment name
TARGET_ENVIRONMENT_USERNAME=""  # Target database username (leave empty for flyway.toml)
TARGET_ENVIRONMENT_PASSWORD=""  # Target database password (use env variables in production)

# Create Snapshot and save into snapshotHistory table #
flyway snapshot \
"-environment=$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
"-snapshot.filename=snapshotHistory:Snapshot-$(date +%Y%m%d)" \
"-snapshot.historyLimit=5" \
-workingDirectory="$WORKING_DIRECTORY"