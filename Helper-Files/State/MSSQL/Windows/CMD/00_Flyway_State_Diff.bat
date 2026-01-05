@echo off
REM ===========================
REM Script Name: 00_Flyway_State_Diff.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-25
REM Description: Flyway State Based - Use the DIFF verb to create an artifact between two environments
REM ===========================

REM Variables - Customize these for your environment
set "ARTIFACT_FILENAME=%temp%\Artifacts\Flyway.State.Development.differences.zip"
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"
set "SOURCE_ENVIRONMENT=development"
set "SOURCE_ENVIRONMENT_USERNAME="
set "SOURCE_ENVIRONMENT_PASSWORD="
set "TARGET_ENVIRONMENT=schemaModel"

REM Calculate the differences between two entities (Databases/Folders & More)
flyway diff ^
-diff.source="%SOURCE_ENVIRONMENT%" ^
-diff.target="%TARGET_ENVIRONMENT%" ^
-environments.%SOURCE_ENVIRONMENT%.user="%SOURCE_ENVIRONMENT_USERNAME%" ^
-environments.%SOURCE_ENVIRONMENT%.password="%SOURCE_ENVIRONMENT_PASSWORD%" ^
-diff.artifactFilename="%ARTIFACT_FILENAME%" ^
-schemaModelLocation="%WORKING_DIRECTORY%\schema-model" ^
-workingDirectory="%WORKING_DIRECTORY%" ^
-schemaModelSchemas=""

pause