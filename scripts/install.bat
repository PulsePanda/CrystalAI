@echo off
REM CrystalAI Installer - Windows
REM Downloads prerequisite GUI installers, lets the user run them manually,
REM then verifies everything is on PATH before setting up the framework.
REM
REM Run from Command Prompt or PowerShell, not Git Bash.

setlocal enabledelayedexpansion

echo.
echo === CrystalAI Installer ===
echo NOTE: Run this from Command Prompt or PowerShell, not Git Bash.
echo.

REM ================================================================
REM Step 1: Check what's already installed
REM ================================================================

set "NEED_GIT=0"
set "NEED_NODE=0"
set "NEED_PYTHON=0"
set "NEED_CLAUDE_DESKTOP=0"

where git >nul 2>&1
if errorlevel 1 set "NEED_GIT=1"

where node >nul 2>&1
if errorlevel 1 set "NEED_NODE=1"

where python >nul 2>&1
if errorlevel 1 (
    where python3 >nul 2>&1
    if errorlevel 1 set "NEED_PYTHON=1"
)

REM Check for Claude desktop app
if not exist "%LOCALAPPDATA%\AnthropicClaude\claude.exe" (
    if not exist "%LOCALAPPDATA%\Programs\claude\claude.exe" (
        set "NEED_CLAUDE_DESKTOP=1"
    )
)

REM If everything is installed, skip to verification/setup
if "!NEED_GIT!"=="0" if "!NEED_NODE!"=="0" if "!NEED_PYTHON!"=="0" if "!NEED_CLAUDE_DESKTOP!"=="0" goto :all_prereqs_present

REM ================================================================
REM Step 2: Download missing installers
REM ================================================================

set "DL_DIR=%TEMP%\crystalai-installers"
if not exist "!DL_DIR!" mkdir "!DL_DIR!"

set "DL_FAILED=0"

if "!NEED_GIT!"=="1" (
    echo [MISSING] Git — downloading installer...
    set "GIT_INSTALLER=!DL_DIR!\Git-2.47.1-64-bit.exe"
    powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/latest/download/Git-2.47.1-64-bit.exe' -OutFile '!DL_DIR!\Git-2.47.1-64-bit.exe' }" 2>nul
    if not exist "!GIT_INSTALLER!" (
        echo [FAIL] Could not download Git installer.
        echo        Download manually from: https://git-scm.com/downloads
        set "DL_FAILED=1"
    ) else (
        echo [DONE] Git installer downloaded.
    )
    echo.
)

if "!NEED_NODE!"=="1" (
    echo [MISSING] Node.js — downloading installer...
    set "NODE_INSTALLER=!DL_DIR!\node-v22.16.0-x64.msi"
    powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.16.0/node-v22.16.0-x64.msi' -OutFile '!DL_DIR!\node-v22.16.0-x64.msi' }" 2>nul
    if not exist "!NODE_INSTALLER!" (
        echo [FAIL] Could not download Node.js installer.
        echo        Download manually from: https://nodejs.org
        set "DL_FAILED=1"
    ) else (
        echo [DONE] Node.js installer downloaded.
    )
    echo.
)

if "!NEED_PYTHON!"=="1" (
    echo [MISSING] Python — downloading installer...
    set "PY_INSTALLER=!DL_DIR!\python-3.12.8-amd64.exe"
    powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe' -OutFile '!DL_DIR!\python-3.12.8-amd64.exe' }" 2>nul
    if not exist "!PY_INSTALLER!" (
        echo [FAIL] Could not download Python installer.
        echo        Download manually from: https://python.org/downloads
        set "DL_FAILED=1"
    ) else (
        echo [DONE] Python installer downloaded.
    )
    echo.
)

if "!NEED_CLAUDE_DESKTOP!"=="1" (
    echo [MISSING] Claude Desktop — downloading installer...
    set "CLAUDE_INSTALLER=!DL_DIR!\Claude-Setup-x64.exe"
    powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://storage.googleapis.com/osprey-downloads-c02f6a0d-347c-492b-a752-3e0651722e97/nest-win-x64/Claude-Setup-x64.exe' -OutFile '!DL_DIR!\Claude-Setup-x64.exe' }" 2>nul
    if not exist "!CLAUDE_INSTALLER!" (
        echo [FAIL] Could not download Claude Desktop installer.
        echo        Download manually from: https://claude.ai/download
        set "DL_FAILED=1"
    ) else (
        echo [DONE] Claude Desktop installer downloaded.
    )
    echo.
)

if "!DL_FAILED!"=="1" (
    echo ---------------------------------------------------------------
    echo  Some downloads failed. Install the missing tools manually,
    echo  then close this terminal, reopen, and re-run this script.
    echo ---------------------------------------------------------------
    echo.
    pause
    exit /b 1
)

REM ================================================================
REM Step 3: Launch each installer and let the user click through
REM ================================================================

echo ---------------------------------------------------------------
echo  The following tools need to be installed:
if "!NEED_GIT!"=="1" echo    - Git
if "!NEED_NODE!"=="1" echo    - Node.js
if "!NEED_PYTHON!"=="1" echo    - Python
if "!NEED_CLAUDE_DESKTOP!"=="1" echo    - Claude Desktop
echo.
echo  Each installer will open with its normal GUI.
echo  Use the default settings unless noted otherwise.
echo ---------------------------------------------------------------
echo.

if "!NEED_GIT!"=="1" (
    echo Installing Git...
    echo Please follow the installer prompts. Use default settings.
    echo.
    start /wait "" "!DL_DIR!\Git-2.47.1-64-bit.exe"
    echo Git installer finished.
    echo.
)

if "!NEED_NODE!"=="1" (
    echo Installing Node.js...
    echo Please follow the installer prompts. Use default settings.
    echo.
    start /wait "" "!DL_DIR!\node-v22.16.0-x64.msi"
    echo Node.js installer finished.
    echo.
)

if "!NEED_PYTHON!"=="1" (
    echo Installing Python...
    echo IMPORTANT: Check "Add Python to PATH" on the first screen!
    echo Then click Install Now and follow the prompts.
    echo.
    start /wait "" "!DL_DIR!\python-3.12.8-amd64.exe"
    echo Python installer finished.
    echo.
)

if "!NEED_CLAUDE_DESKTOP!"=="1" (
    echo Installing Claude Desktop...
    echo Please follow the installer prompts.
    echo Sign in with your Anthropic account when it opens.
    echo.
    start /wait "" "!DL_DIR!\Claude-Setup-x64.exe"
    echo Claude Desktop installer finished.
    echo.
)

REM Clean up downloaded installers
echo Cleaning up downloaded installers...
rmdir /s /q "!DL_DIR!" 2>nul
echo.

echo ===============================================================
echo  All installers complete.
echo.
echo  Please CLOSE this terminal and REOPEN it, then re-run:
echo    %~f0
echo.
echo  The script will verify your installations and finish setup.
echo ===============================================================
echo.
pause
exit /b 0

REM ================================================================
REM Step 4: All tools present — verify and set up framework
REM ================================================================

:all_prereqs_present

echo Prerequisites found:
for /f "tokens=*" %%i in ('git --version') do echo   [OK] git:    %%i

for /f "tokens=*" %%i in ('node --version') do echo   [OK] node:   %%i

set "PY_CMD=python"
where python >nul 2>&1
if errorlevel 1 set "PY_CMD=python3"
for /f "tokens=*" %%i in ('!PY_CMD! --version 2^>^&1') do echo   [OK] python: %%i

echo.

REM ================================================================
REM Step 5: Check/install Claude Code CLI
REM ================================================================

where claude >nul 2>&1
if not errorlevel 1 goto :claude_found

where npm >nul 2>&1
if errorlevel 1 goto :no_npm_for_claude

echo Claude Code CLI not found. Installing via npm...
call npm install -g @anthropic-ai/claude-code
echo.

where claude >nul 2>&1
if errorlevel 1 goto :claude_install_warn
goto :claude_found

:claude_install_warn
echo [WARN] Claude Code installed but 'claude' not found on PATH.
echo        Close and reopen your terminal, then try again.
echo        If you see "EPERM" or "Access denied", try running as Administrator.
echo.
goto :install_framework

:no_npm_for_claude
echo [SKIP] Claude Code CLI not found and npm is not available.
echo        Install Node.js first, then re-run this script.
echo.
goto :install_framework

:claude_found
for /f "tokens=*" %%i in ('claude --version 2^>^&1') do echo   [OK] claude: %%i
echo.

REM ================================================================
REM Step 6: Clone repo and copy templates
REM ================================================================

:install_framework

set "INSTALL_DIR=%USERPROFILE%\.claude"

if exist "!INSTALL_DIR!\.git" goto :already_installed

if not exist "!INSTALL_DIR!\" goto :fresh_clone

REM Directory exists but is not a CrystalAI git repo — back it up
echo Warning: %INSTALL_DIR% exists and is not a CrystalAI install.
if exist "!INSTALL_DIR!.backup" (
    echo Removing old backup...
    rmdir /s /q "!INSTALL_DIR!.backup" 2>nul
)
echo Backing up to %INSTALL_DIR%.backup
move "!INSTALL_DIR!" "!INSTALL_DIR!.backup"
if errorlevel 1 (
    echo ERROR: Could not back up existing .claude directory.
    echo Please manually rename or remove %INSTALL_DIR% and try again.
    pause
    exit /b 1
)

:fresh_clone
echo Cloning CrystalAI framework...
git clone https://github.com/PulsePanda/CrystalAI.git "!INSTALL_DIR!"
if errorlevel 1 (
    echo.
    echo ERROR: git clone failed. Check your internet connection and try again.
    echo If the repo is private, make sure you have access.
    pause
    exit /b 1
)
goto :copy_templates

:already_installed
echo CrystalAI already installed at %INSTALL_DIR%
echo Pulling latest changes...
pushd "!INSTALL_DIR!" && git pull & popd
if errorlevel 1 (
    echo Warning: git pull failed. Your local copy may have uncommitted changes.
)

REM ================================================================
REM Step 7: Copy templates
REM ================================================================

:copy_templates
echo.

if not exist "!INSTALL_DIR!\settings.json" (
    if exist "!INSTALL_DIR!\settings.json.template" (
        copy /Y "!INSTALL_DIR!\settings.json.template" "!INSTALL_DIR!\settings.json" >nul
        echo Copied settings.json from template.
    )
)

echo.
echo === Installation complete ===
echo.
echo Next steps:
echo   1. Close and reopen your terminal
echo   2. Run: claude
echo   3. Type: /onboard
echo.
echo The onboarding wizard will walk you through the rest.
echo.
pause
