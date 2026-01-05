@echo off
REM ===========================
REM Script Name: 01_Flyway_State_Model.bat
REM Version: 1.0.0
REM Author: Chris Hawkins (Redgate Software Ltd)
REM Last Updated: 2025-11-25
REM Description: Flyway State Based - Use the Model verb to capture artifact differences to project Schema Model
REM ===========================

REM Variables - Customize these for your environment
set "ARTIFACT_FILENAME=%temp%\Artifacts\Flyway.State.Development.differences.zip"
set "WORKING_DIRECTORY=C:\WorkingFolders\FWD\State_Based_Projects\MSSQL_State"

flyway model ^
-model.artifactFilename="%ARTIFACT_FILENAME%" ^
-workingDirectory="%WORKING_DIRECTORY%"

pause