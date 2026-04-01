@echo off
REM CrystalAI Installer - Windows
REM Downloads and sets up the CrystalAI starter framework.
REM Automatically installs missing prerequisites via winget.
REM
REM Run this from Command Prompt or PowerShell, not Git Bash.

setlocal enabledelayedexpansion

echo.
echo === CrystalAI Installer ===
echo NOTE: Run this from Command Prompt or PowerShell, not Git Bash.
echo.

REM ================================================================
REM Step 1: Check for winget (needed to auto-install prerequisites)
REM ================================================================

set "HAS_WINGET=0"
where winget >nul 2>&1
if not errorlevel 1 set "HAS_WINGET=1"

if "!HAS_WINGET!"=="0" (
    echo [INFO] winget not found on PATH.
    echo        winget is built into Windows 10 ^(1709+^) and Windows 11.
    echo        If you're on an older build, install "App Installer" from the Microsoft Store.
    echo.
)

REM ================================================================
REM Step 2: Check and install Git
REM ================================================================

set "INSTALLED_SOMETHING=0"

where git >nul 2>&1
if not errorlevel 1 goto :git_ok

echo [MISSING] git is not installed.
if "!HAS_WINGET!"=="0" goto :git_manual
echo Installing Git via winget...
winget install Git.Git --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto :git_manual
set "INSTALLED_SOMETHING=1"
echo [DONE] Git installed.
echo.
goto :check_node

:git_manual
echo Downloading Git installer via PowerShell...
set "GIT_INSTALLER=%TEMP%\git-installer.exe"
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://github.com/git-for-windows/git/releases/latest/download/Git-2.47.1-64-bit.exe' -OutFile '%GIT_INSTALLER%' }" 2>nul
if not exist "!GIT_INSTALLER!" (
    echo [FAIL] Download failed. Please install Git manually:
    echo        https://git-scm.com/downloads
    echo Then close this terminal, reopen, and re-run this script.
    pause
    exit /b 1
)
echo Running Git installer ^(this may take a minute^)...
"!GIT_INSTALLER!" /VERYSILENT /NORESTART /NOCANCEL /SP- /CLOSEAPPLICATIONS /RESTARTAPPLICATIONS /COMPONENTS="icons,ext\reg\shellhere,assoc,assoc_sh"
del "!GIT_INSTALLER!" 2>nul
set "INSTALLED_SOMETHING=1"
echo [DONE] Git installed.
echo.
goto :check_node

:git_ok
for /f "tokens=*" %%i in ('git --version') do echo [OK] git:    %%i

REM ================================================================
REM Step 3: Check and install Node.js
REM ================================================================

:check_node
where node >nul 2>&1
if not errorlevel 1 goto :node_ok

echo [MISSING] node is not installed.
if "!HAS_WINGET!"=="0" goto :node_manual
echo Installing Node.js LTS via winget...
winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto :node_manual
set "INSTALLED_SOMETHING=1"
echo [DONE] Node.js installed.
echo.
goto :check_python

:node_manual
echo Downloading Node.js LTS installer via PowerShell...
set "NODE_INSTALLER=%TEMP%\node-installer.msi"
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://nodejs.org/dist/v22.16.0/node-v22.16.0-x64.msi' -OutFile '%NODE_INSTALLER%' }" 2>nul
if not exist "!NODE_INSTALLER!" (
    echo [SKIP] Download failed. Install Node.js manually from: https://nodejs.org
    goto :check_python
)
echo Running Node.js installer ^(this may take a minute^)...
msiexec /i "!NODE_INSTALLER!" /qn /norestart
del "!NODE_INSTALLER!" 2>nul
set "INSTALLED_SOMETHING=1"
echo [DONE] Node.js installed.
echo.
goto :check_python

:node_ok
for /f "tokens=*" %%i in ('node --version') do echo [OK] node:   %%i

REM ================================================================
REM Step 4: Check and install Python
REM ================================================================

:check_python
set "PYTHON_FOUND=0"
where python >nul 2>&1
if not errorlevel 1 goto :python_ok_python

where python3 >nul 2>&1
if not errorlevel 1 goto :python_ok_python3

echo [MISSING] python is not installed.
if "!HAS_WINGET!"=="0" goto :python_manual
echo Installing Python 3.12 via winget...
winget install Python.Python.3.12 --accept-package-agreements --accept-source-agreements
if errorlevel 1 goto :python_manual
set "INSTALLED_SOMETHING=1"
set "PYTHON_FOUND=1"
echo [DONE] Python installed.
echo.
goto :check_restart

:python_manual
echo Downloading Python 3.12 installer via PowerShell...
set "PY_INSTALLER=%TEMP%\python-installer.exe"
powershell -Command "& { [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.python.org/ftp/python/3.12.8/python-3.12.8-amd64.exe' -OutFile '%PY_INSTALLER%' }" 2>nul
if not exist "!PY_INSTALLER!" (
    echo [SKIP] Download failed. Install Python manually from: https://python.org/downloads
    goto :check_restart
)
echo Running Python installer ^(this may take a minute^)...
"!PY_INSTALLER!" /quiet InstallAllUsers=0 PrependPath=1 Include_pip=1
del "!PY_INSTALLER!" 2>nul
set "INSTALLED_SOMETHING=1"
set "PYTHON_FOUND=1"
echo [DONE] Python installed.
echo.
goto :check_restart

:python_ok_python
set "PYTHON_FOUND=1"
for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo [OK] python: %%i
goto :check_restart

:python_ok_python3
set "PYTHON_FOUND=1"
for /f "tokens=*" %%i in ('python3 --version 2^>^&1') do echo [OK] python: %%i
goto :check_restart

REM ================================================================
REM Step 5: If anything was installed, user must restart terminal
REM ================================================================

:check_restart
echo.
if "!INSTALLED_SOMETHING!"=="0" goto :all_prereqs_present

echo ---------------------------------------------------------------
echo  One or more tools were just installed via winget.
echo  Your current terminal does not have the updated PATH.
echo.
echo  Please close this terminal, open a new one, and re-run:
echo    %~f0
echo.
echo  The script will pick up where it left off.
echo ---------------------------------------------------------------
echo.
pause
exit /b 0

REM ================================================================
REM Step 6: All prereqs present — check/install Claude Code CLI
REM ================================================================

:all_prereqs_present

where claude >nul 2>&1
if not errorlevel 1 goto :claude_found

REM Claude not found — try to install via npm
where npm >nul 2>&1
if errorlevel 1 goto :no_npm_for_claude

echo Claude Code CLI not found. Installing via npm...
call npm install -g @anthropic-ai/claude-code
echo.

REM Verify the install worked
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
for /f "tokens=*" %%i in ('claude --version 2^>^&1') do echo [OK] Claude Code: %%i
echo.

REM ================================================================
REM Step 7: Clone repo and copy templates
REM ================================================================

:install_framework

set "INSTALL_DIR=%USERPROFILE%\.claude"

if exist "%INSTALL_DIR%\.git" goto :already_installed

if not exist "%INSTALL_DIR%\" goto :fresh_clone

REM Directory exists but is not a CrystalAI git repo — back it up
echo Warning: %INSTALL_DIR% exists and is not a CrystalAI install.
if exist "%INSTALL_DIR%.backup" (
    echo Removing old backup...
    rmdir /s /q "%INSTALL_DIR%.backup" 2>nul
)
echo Backing up to %INSTALL_DIR%.backup
move "%INSTALL_DIR%" "%INSTALL_DIR%.backup"
if errorlevel 1 (
    echo ERROR: Could not back up existing .claude directory.
    echo Please manually rename or remove %INSTALL_DIR% and try again.
    pause
    exit /b 1
)

:fresh_clone
echo Cloning CrystalAI framework...
git clone https://github.com/PulsePanda/CrystalAI.git "%INSTALL_DIR%"
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
pushd "%INSTALL_DIR%" && git pull & popd
if errorlevel 1 (
    echo Warning: git pull failed. Your local copy may have uncommitted changes.
)

REM ================================================================
REM Step 8: Copy templates
REM ================================================================

:copy_templates
echo.

if not exist "%INSTALL_DIR%\settings.json" (
    if exist "%INSTALL_DIR%\settings.json.template" (
        copy /Y "%INSTALL_DIR%\settings.json.template" "%INSTALL_DIR%\settings.json" >nul
        echo Copied settings.json ^(default permissions^)
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
