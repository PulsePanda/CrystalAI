@echo off
REM gws-windows.bat — wrapper to call gws with a specific account's credentials (Windows)
REM Usage: gws-windows.bat <account> <gws args...>
REM Example: gws-windows.bat umb gmail users messages list --params "{\"userId\":\"me\",\"maxResults\":10}"

setlocal enabledelayedexpansion

set "ACCOUNT=%1"
if "%ACCOUNT%"=="" (
    echo Usage: gws-windows.bat ^<account^> ^<gws args...^>
    echo Accounts: configured per user in %%USERPROFILE%%\.config\gws\credentials\
    exit /b 1
)
shift

set "CREDS_DIR=%USERPROFILE%\.config\gws\credentials"
set "CREDS_FILE=%CREDS_DIR%\credentials-%ACCOUNT%.json"
set "CONFIG_DIR=%USERPROFILE%\.config\gws\accounts\%ACCOUNT%"

if not exist "%CREDS_FILE%" (
    echo Error: credentials file not found: %CREDS_FILE%
    echo.
    echo To set up credentials for account "%ACCOUNT%":
    echo   1. Run: gws auth login -s gmail,calendar
    echo   2. Complete the OAuth flow in your browser
    echo   3. Run: gws auth export --unmasked ^> "%CREDS_FILE%"
    echo.
    echo See docs/gws-setup-windows.md for full instructions.
    exit /b 1
)

if not exist "%CONFIG_DIR%" mkdir "%CONFIG_DIR%"

set "GOOGLE_WORKSPACE_CLI_CREDENTIALS_FILE=%CREDS_FILE%"
set "GOOGLE_WORKSPACE_CLI_CONFIG_DIR=%CONFIG_DIR%"

REM Build the remaining arguments
set "ARGS="
:argloop
if "%~1"=="" goto :run
set "ARGS=!ARGS! %1"
shift
goto :argloop

:run
gws %ARGS%
