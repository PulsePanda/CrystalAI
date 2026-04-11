@echo off
REM gws-windows.bat — wrapper to call gws with per-account auth via crystal-auth sidecar.
REM Usage: gws-windows.bat <account> <gws args...>
REM Example: gws-windows.bat personal gmail users messages list --params "{\"userId\":\"me\"}"
REM
REM Auth model: crystal-auth holds OAuth state via the buildcrystal.ai auth broker.
REM This script fetches a fresh access token on every invocation and passes it to
REM gws via the GOOGLE_WORKSPACE_CLI_TOKEN env var, which bypasses gws's own
REM credential loading. See docs/gws-auth.md for the full architecture.

setlocal enabledelayedexpansion

set "ACCOUNT=%~1"
if "%ACCOUNT%"=="" (
    echo Usage: gws-windows.bat ^<account^> ^<gws args...^>
    echo First time? Run: python "%%USERPROFILE%%\.claude\scripts\crystal-auth.py" login ^<account^>
    exit /b 1
)
shift

set "CRYSTAL_AUTH=%USERPROFILE%\.claude\scripts\crystal-auth.py"
if not exist "%CRYSTAL_AUTH%" (
    echo gws-windows.bat: crystal-auth.py not found at %CRYSTAL_AUTH%
    echo                  Reinstall CrystalAI or run the bootstrap prompt again.
    exit /b 2
)

REM gws still uses this dir for API discovery caches.
set "GOOGLE_WORKSPACE_CLI_CONFIG_DIR=%USERPROFILE%\.config\gws\accounts\%ACCOUNT%"
if not exist "%GOOGLE_WORKSPACE_CLI_CONFIG_DIR%" mkdir "%GOOGLE_WORKSPACE_CLI_CONFIG_DIR%"

REM Fetch a fresh access token via the sidecar. If it fails, print a clear message.
set "GOOGLE_WORKSPACE_CLI_TOKEN="
for /f "usebackq delims=" %%i in (`python "%CRYSTAL_AUTH%" get-token %ACCOUNT%`) do set "GOOGLE_WORKSPACE_CLI_TOKEN=%%i"

if "%GOOGLE_WORKSPACE_CLI_TOKEN%"=="" (
    echo gws-windows.bat: crystal-auth failed to get a token for '%ACCOUNT%' 1>&2
    echo                  Try: python "%CRYSTAL_AUTH%" login %ACCOUNT% 1>&2
    exit /b 2
)

REM Rebuild the remaining arguments (shift consumed %1)
set "ARGS="
:argloop
if "%~1"=="" goto :run
set "ARGS=!ARGS! %1"
shift
goto :argloop

:run
gws %ARGS%
