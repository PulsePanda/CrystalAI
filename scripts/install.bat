@echo off
REM CrystalAI Installer - Windows
REM Downloads and sets up the CrystalAI starter framework.

setlocal enabledelayedexpansion

echo.
echo === CrystalAI Installer ===
echo NOTE: Run this from Command Prompt or PowerShell, not Git Bash.
echo.

REM --- Check prerequisites ---

REM Git is REQUIRED (needed to clone the repo)
where git >nul 2>&1
if errorlevel 1 (
    echo [REQUIRED] git is not installed.
    echo.
    echo Download from: https://git-scm.com/downloads
    echo Install it, then close and reopen this terminal, and re-run this script.
    echo.
    pause
    exit /b 1
)

echo Checking tools:
for /f "tokens=*" %%i in ('git --version') do echo   [OK] git:    %%i

REM Node check - warn if missing but continue
where node >nul 2>&1
if errorlevel 1 (
    echo   [MISSING] node - needed for Claude Code CLI and email integration
    echo             Download from: https://nodejs.org ^(LTS recommended^)
    set "NODE_MISSING=1"
) else (
    for /f "tokens=*" %%i in ('node --version') do echo   [OK] node:   %%i
    set "NODE_MISSING=0"
)

REM Python check - flatten to avoid nested errorlevel bug
set "PYTHON_FOUND=0"
where python >nul 2>&1
if not errorlevel 1 (
    set "PYTHON_FOUND=1"
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo   [OK] python: %%i
)
if "!PYTHON_FOUND!"=="0" (
    where python3 >nul 2>&1
    if not errorlevel 1 (
        for /f "tokens=*" %%i in ('python3 --version 2^>^&1') do echo   [OK] python: %%i
    ) else (
        echo   [MISSING] python - some skills use Python scripts
        echo             Download from: https://python.org/downloads
        echo             Check "Add Python to PATH" during install
    )
)

echo.

REM --- Check for Claude Code CLI ---

where claude >nul 2>&1
if not errorlevel 1 (
    for /f "tokens=*" %%i in ('claude --version 2^>^&1') do echo Claude Code: %%i
    echo.
    goto :skip_claude_install
)

if "!NODE_MISSING!"=="1" (
    echo Claude Code CLI not found. Cannot install - Node.js is required first.
    echo Install Node.js, reopen your terminal, and re-run this script.
    echo.
    goto :skip_claude_install
)

echo Claude Code CLI not found. Installing...
where npm >nul 2>&1
if errorlevel 1 (
    echo Cannot install Claude Code - npm is not available.
    echo Install Node.js first, then re-run this script.
    echo.
    goto :skip_claude_install
)

call npm install -g @anthropic-ai/claude-code
echo.

REM Verify install with a fresh check
where claude >nul 2>&1
if errorlevel 1 (
    echo Warning: Claude Code installed but 'claude' not found on PATH.
    echo Close and reopen your terminal, then try again.
    echo If you see "EPERM" or "Access denied", try running as Administrator.
) else (
    echo Claude Code installed successfully.
)
echo.

:skip_claude_install

REM --- Install CrystalAI framework ---

set "INSTALL_DIR=%USERPROFILE%\.claude"

if exist "%INSTALL_DIR%\.git" (
    echo CrystalAI already installed at %INSTALL_DIR%
    echo Pulling latest changes...
    pushd "%INSTALL_DIR%" && git pull & popd
    if errorlevel 1 (
        echo Warning: git pull failed. Your local copy may have uncommitted changes.
    )
) else (
    if exist "%INSTALL_DIR%\" (
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
    )
    echo Cloning CrystalAI framework...
    git clone https://github.com/PulsePanda/CrystalAI.git "%INSTALL_DIR%"
    if errorlevel 1 (
        echo.
        echo ERROR: git clone failed. Check your internet connection and try again.
        echo If the repo is private, make sure you have access.
        pause
        exit /b 1
    )
)

echo.

REM --- Copy templates ---

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
