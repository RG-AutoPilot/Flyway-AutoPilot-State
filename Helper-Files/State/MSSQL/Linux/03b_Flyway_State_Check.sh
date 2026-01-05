#!/bin/bash

# ===========================
# Script Name: 03b_Flyway_State_Check.sh
# Version: 1.0.0
# Author: Chris Hawkins (Redgate Software Ltd)
# Last Updated: 2025-11-26
# Description: Flyway State Based - Use the CHECK verb to create a report detailing all pending changes/detected drift and code analysis
# ===========================

# Variables - Customize these for your environment #
REPORT_FILENAME="Flyway-Check-All_Report.html"  # Output deployment script name
WORKING_DIRECTORY="/home/user/flyway-projects/state/mssql/chinook"  # Path to Flyway state-based project root
SCRIPT_FILENAME="Flyway_Deployment_Script.sql"  # Output deployment script name
SOURCE_ENVIRONMENT="schemaModel"  # Source environment name (desired state)
TARGET_ENVIRONMENT="Test"  # Target database environment name
TARGET_ENVIRONMENT_USERNAME=""  # Target database username (leave empty for flyway.toml)
TARGET_ENVIRONMENT_PASSWORD=""  # Target database password (use env variables in production)

# NOTE: First-time execution warning #
# If this is the first time running check against the target environment, you may receive warnings
# about missing snapshots in the snapshotHistory table. This will be resolved after:
# - Running the 04_Deploy script (which can save snapshots automatically), OR
# - Running the 05_Snapshot script to create an initial snapshot

# Prepare Script for Deployment #
flyway check -changes -code -drift \
"-check.changesSource=$SOURCE_ENVIRONMENT" \
"-environment=$TARGET_ENVIRONMENT" \
"-environments.$TARGET_ENVIRONMENT.user=$TARGET_ENVIRONMENT_USERNAME" \
"-environments.$TARGET_ENVIRONMENT.password=$TARGET_ENVIRONMENT_PASSWORD" \
"-check.scope=script" \
"-check.scriptFilename=/tmp/Artifacts/D_$SCRIPT_FILENAME" \
-configFiles="$WORKING_DIRECTORY/flyway.toml" \
-workingDirectory="$WORKING_DIRECTORY" \
"-reportFilename=$WORKING_DIRECTORY/Artifact/$REPORT_FILENAME"