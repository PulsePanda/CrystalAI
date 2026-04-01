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
REM Step 1: Detect what is already installed
REM ================================================================
REM Each check is done OUTSIDE of parenthesized blocks to avoid
REM errorlevel contamination. We use goto for flow control.

set "NEED_GIT=0"
set "NEED_NODE=0"
set "NEED_PYTHON=0"
set "NEED_CLAUDE_DESKTOP=0"
set "NEED_INSTALL=0"

REM --- Git ---
where git >nul 2>&1
if !errorlevel! neq 0 set "NEED_GIT=1"

REM --- Node.js ---
where node >nul 2>&1
if !errorlevel! neq 0 set "NEED_NODE=1"

REM --- Python (try python then python3) ---
where python >nul 2>&1
if !errorlevel! equ 0 goto :python_found
where python3 >nul 2>&1
if !errorlevel! equ 0 goto :python_found
set "NEED_PYTHON=1"
:python_found

REM --- Claude Desktop (MSIX installs vary; only reliable check is PATH) ---
where Claude.exe >nul 2>&1
if !errorlevel! neq 0 set "NEED_CLAUDE_DESKTOP=1"

REM --- Decide if we need to install anything ---
if "!NEED_GIT!"=="1" set "NEED_INSTALL=1"
if "!NEED_NODE!"=="1" set "NEED_INSTALL=1"
if "!NEED_PYTHON!"=="1" set "NEED_INSTALL=1"
if "!NEED_CLAUDE_DESKTOP!"=="1" set "NEED_INSTALL=1"

if "!NEED_INSTALL!"=="0" goto :all_prereqs_present

REM ================================================================
REM Step 2: Download missing installers
REM ================================================================

set "DL_DIR=%TEMP%\crystalai-installers"
if not exist "!DL_DIR!" mkdir "!DL_DIR!"
set "DL_FAILED=0"

if "!NEED_GIT!"=="0" goto :skip_dl_git
echo [MISSING] Git -- downloading installer...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/latest/download/Git-2.47.1-64-bit.exe' -OutFile '%DL_DIR%\Git-2.47.1-64-bit.exe' }" 2>nul
if exist "!DL_DIR!\Git-2.47.1-64-bit.exe" (
    echo [DONE] Git installer downloaded.
) else (
    echo [FAIL] Could not download Git installer.
    echo        Download manually from: https://git-scm.com/downloads
    set "DL_FAILED=1"
)
echo.
:skip_dl_git

if "!NEED_NODE!"=="0" goto :skip_dl_node
echo [MISSING] Node.js -- downloading installer...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.16.0/node-v22.16.0-x64.msi' -OutFile '%DL_DIR%\node-v22.16.0-x64.msi' }" 2>nul
if exist "!DL_DIR!\node-v22.16.0-x64.msi" (
    echo [DONE] Node.js installer downloaded.
) else (
    echo [FAIL] Could not download Node.js installer.
    echo        Download manually from: https://nodejs.org
    set "DL_FAILED=1"
)
echo.
:skip_dl_node

if "!NEED_PYTHON!"=="0" goto :skip_dl_python
echo [MISSING] Python -- downloading installer...
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe' -OutFile '%DL_DIR%\python-3.12.8-amd64.exe' }" 2>nul
if exist "!DL_DIR!\python-3.12.8-amd64.exe" (
    echo [DONE] Python installer downloaded.
) else (
    echo [FAIL] Could not download Python installer.
    echo        Download manually from: https://python.org/downloads
    set "DL_FAILED=1"
)
echo.
:skip_dl_python

if "!NEED_CLAUDE_DESKTOP!"=="0" goto :skip_dl_claude
echo [MISSING] Claude Desktop -- opening download page in your browser...
start "" "https://claude.ai/download"
echo          Install Claude Desktop from the page that just opened.
echo.
:skip_dl_claude

if "!DL_FAILED!"=="0" goto :downloads_ok
echo ---------------------------------------------------------------
echo  Some downloads failed. Install the missing tools manually,
echo  then close this terminal, reopen, and re-run this script.
echo ---------------------------------------------------------------
echo.
pause
exit /b 1

:downloads_ok

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

if "!NEED_GIT!"=="0" goto :skip_install_git
echo Installing Git...
echo Please follow the installer prompts. Use default settings.
echo.
start /wait "" "!DL_DIR!\Git-2.47.1-64-bit.exe"
echo Git installer finished.
echo.
:skip_install_git

if "!NEED_NODE!"=="0" goto :skip_install_node
echo Installing Node.js...
echo Please follow the installer prompts. Use default settings.
echo.
start /wait "" "!DL_DIR!\node-v22.16.0-x64.msi"
echo Node.js installer finished.
echo.
:skip_install_node

if "!NEED_PYTHON!"=="0" goto :skip_install_python
echo Installing Python...
echo IMPORTANT: Check "Add Python to PATH" on the first screen!
echo Then click Install Now and follow the prompts.
echo.
start /wait "" "!DL_DIR!\python-3.12.8-amd64.exe"
echo Python installer finished.
echo.
:skip_install_python

if "!NEED_CLAUDE_DESKTOP!"=="0" goto :skip_install_claude
echo Waiting for you to install Claude Desktop from the browser...
echo Press any key once you have installed it.
pause >nul
echo.
:skip_install_claude

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
REM Step 4: All prereqs present -- verify and print versions
REM ================================================================

:all_prereqs_present
echo All prerequisites found. Verifying versions...
echo.

REM --- Git version ---
for /f "tokens=*" %%i in ('git --version 2^>nul') do echo   [OK] git:    %%i

REM --- Node version ---
for /f "tokens=*" %%i in ('node --version 2^>nul') do echo   [OK] node:   %%i

REM --- Python version (try python first, then python3) ---
set "PY_CMD=python"
where python >nul 2>&1
if !errorlevel! neq 0 set "PY_CMD=python3"
for /f "tokens=*" %%i in ('!PY_CMD! --version 2^>^&1') do echo   [OK] python: %%i

REM --- Claude Desktop ---
echo   [OK] Claude Desktop installed
echo.

REM ================================================================
REM Step 5: Check/install Claude Code CLI
REM ================================================================

REM Claude Code CLI installs as a .cmd shim via npm.
REM On Windows, "where claude" is case-insensitive and matches both
REM Claude.exe (Desktop) and claude.cmd (CLI). We check .cmd specifically.
REM NEVER run claude --version during detection -- it can hang or launch GUI.

where claude.cmd >nul 2>&1
if !errorlevel! equ 0 goto :claude_cli_found

REM Not on PATH -- also check npm global prefix directly
where npm >nul 2>&1
if !errorlevel! neq 0 goto :no_npm_for_claude

REM Check npm global bin for claude.cmd before installing
for /f "tokens=*" %%p in ('npm prefix -g 2^>nul') do (
    if exist "%%p\claude.cmd" goto :claude_cli_found
)

REM Not found anywhere -- install it
echo Claude Code CLI not found. Installing via npm...
call npm install -g @anthropic-ai/claude-code
if !errorlevel! neq 0 goto :claude_install_failed
echo.

REM Verify installation
where claude.cmd >nul 2>&1
if !errorlevel! equ 0 goto :claude_cli_found

REM Installed but not on PATH yet
echo [WARN] Claude Code installed but claude.cmd not found on PATH.
echo        Close and reopen your terminal, then try again.
echo        If you see "EPERM" or "Access denied", try running as Administrator.
echo.
goto :install_framework

:claude_install_failed
echo [WARN] npm install failed. Try running as Administrator, or install manually:
echo        npm install -g @anthropic-ai/claude-code
echo.
goto :install_framework

:no_npm_for_claude
echo [SKIP] Claude Code CLI not found and npm is not available.
echo        Install Node.js first, then re-run this script.
echo.
goto :install_framework

:claude_cli_found
REM Safe to run --version now since we confirmed it is the .cmd CLI shim
for /f "tokens=*" %%i in ('claude.cmd --version 2^>^&1') do echo   [OK] claude: %%i
echo.

REM ================================================================
REM Step 6: Clone CrystalAI repo or pull latest
REM ================================================================

:install_framework

set "INSTALL_DIR=%USERPROFILE%\.claude"

REM Check if already a CrystalAI git repo
if exist "!INSTALL_DIR!\.git" goto :already_cloned

REM Check if directory exists but is not a git repo
if not exist "!INSTALL_DIR!" goto :fresh_clone

REM Directory exists but is not a CrystalAI install -- back it up
echo Warning: %INSTALL_DIR% exists and is not a CrystalAI install.

if exist "!INSTALL_DIR!.backup" (
    echo Removing old backup...
    rmdir /s /q "!INSTALL_DIR!.backup" 2>nul
)

echo Backing up to %INSTALL_DIR%.backup
move "!INSTALL_DIR!" "!INSTALL_DIR!.backup"
if !errorlevel! neq 0 goto :backup_failed
goto :fresh_clone

:backup_failed
echo ERROR: Could not back up existing .claude directory.
echo Please manually rename or remove %INSTALL_DIR% and try again.
pause
exit /b 1

:fresh_clone
echo Cloning CrystalAI framework...
git clone https://github.com/PulsePanda/CrystalAI.git "!INSTALL_DIR!"
if !errorlevel! neq 0 goto :clone_failed
goto :copy_templates

:clone_failed
echo.
echo ERROR: git clone failed. Check your internet connection and try again.
echo If the repo is private, make sure you have access.
pause
exit /b 1

:already_cloned
echo CrystalAI already installed at %INSTALL_DIR%
echo Pulling latest changes...
pushd "!INSTALL_DIR!"
git pull
popd
echo.

REM ================================================================
REM Step 7: Copy settings template
REM ================================================================

:copy_templates

if exist "!INSTALL_DIR!\settings.json" goto :skip_copy_settings
if not exist "!INSTALL_DIR!\settings.json.template" goto :skip_copy_settings
copy /Y "!INSTALL_DIR!\settings.json.template" "!INSTALL_DIR!\settings.json" >nul
echo Copied settings.json from template.
:skip_copy_settings

REM ================================================================
REM Done
REM ================================================================

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
