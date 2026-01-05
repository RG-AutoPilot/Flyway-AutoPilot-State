@echo off
REM ===========================
REM Script Name: 04_Flyway_State_Deploy.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-25
REM Description: Flyway State Based - Use the Deploy verb to run referenced script against a target environment
REM ===========================

REM Variables - Customize these for your environment
set "SCRIPT_FILENAME=%temp%\Artifacts\D_Flyway-Dryrun_Deployment_Script.sql"
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
set "TARGET_ENVIRONMENT=Test"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="
set "SAVE_SNAPSHOT=true"

REM Deploy Script to target
flyway deploy ^
-environment="%TARGET_ENVIRONMENT%" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-deploy.scriptFilename="%SCRIPT_FILENAME%" ^
-deploy.saveSnapshot="%SAVE_SNAPSHOT%" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause