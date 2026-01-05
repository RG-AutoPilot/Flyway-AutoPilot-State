@echo off
REM ===========================
REM Script Name: 03b_Flyway_State_Check.bat
REM Version: 1.0.1
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-12-16
REM Description: Flyway State Based - Use the CHECK verb to create a report detailing all pending changes/detected drift and code analysis
REM ===========================

REM Variables - Customize these for your environment
set "REPORT_FILENAME=Flyway-Check-All_Report.html"
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
set "SCRIPT_FILENAME=Flyway_Deployment_Script.sql"
set "SOURCE_ENVIRONMENT=schemaModel"
set "TARGET_ENVIRONMENT=Test"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="

REM NOTE: First-time execution warning
REM If this is the first time running check against the target environment, you may receive warnings
REM about missing snapshots in the snapshotHistory table. This will be resolved after:
REM - Running the 04_Deploy script (which can save snapshots automatically), OR
REM - Running the 05_Snapshot script to create an initial snapshot

REM Prepare Script for Deployment
flyway check -changes -code -drift ^
-check.changesSource="%SOURCE_ENVIRONMENT%" ^
-environment="%TARGET_ENVIRONMENT%" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-check.deployedSnapshot="snapshotHistory:current" ^
-check.scope="script" ^
-check.scriptFilename="%temp%\Artifacts\D_%SCRIPT_FILENAME%" ^
-configFiles="%WORKING_DIRECTORY%\flyway.toml" ^
-workingDirectory="%WORKING_DIRECTORY%" ^
-reportFilename="%WORKING_DIRECTORY%\Artifact\%REPORT_FILENAME%"

pause