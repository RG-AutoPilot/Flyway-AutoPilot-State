@echo off
REM ===========================
REM Script Name: 02_Flyway_State_Prepare.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-25
REM Description: Flyway State Based - Use the PREPARE verb to create deployment script between two environments (By default - Changes in the Schema Model not in the Test environment)
REM ===========================

REM Variables - Customize these for your environment
set "SCRIPT_FILENAME=Flyway_Deployment_Script.sql"
set "UNDO_FILENAME=Flyway_Undo_Script.sql"
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
set "SOURCE_ENVIRONMENT=schemaModel"
set "TARGET_ENVIRONMENT=Test"
set "TARGET_ENVIRONMENT_USERNAME="
set "TARGET_ENVIRONMENT_PASSWORD="

REM Prepare Script for Deployment
flyway prepare ^
-prepare.source="%SOURCE_ENVIRONMENT%" ^
-prepare.target="%TARGET_ENVIRONMENT%" ^
-prepare.types="deploy,undo" ^
-environments.%TARGET_ENVIRONMENT%.user="%TARGET_ENVIRONMENT_USERNAME%" ^
-environments.%TARGET_ENVIRONMENT%.password="%TARGET_ENVIRONMENT_PASSWORD%" ^
-prepare.scriptFilename="%temp%\Artifacts\D_%SCRIPT_FILENAME%" ^
-prepare.undoFilename="%temp%\Artifacts\U_%UNDO_FILENAME%" ^
-prepare.force="true" ^
-configFiles="%WORKING_DIRECTORY%\flyway.toml" ^
-schemaModelLocation="%WORKING_DIRECTORY%\schema-model"

pause