@echo off
REM CrystalAI Installer — Windows
REM Downloads and sets up the CrystalAI starter framework.

setlocal enabledelayedexpansion

echo.
echo === CrystalAI Installer ===
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

REM Node is needed for Claude Code CLI and GWS — warn if missing but continue
where node >nul 2>&1
if errorlevel 1 (
    echo   [MISSING] node — needed for Claude Code CLI and email integration
    echo             Download from: https://nodejs.org ^(LTS recommended^)
) else (
    for /f "tokens=*" %%i in ('node --version') do echo   [OK] node:   %%i
)

REM Python is optional — warn if missing but continue
where python >nul 2>&1
if errorlevel 1 (
    where python3 >nul 2>&1
    if errorlevel 1 (
        echo   [MISSING] python — some skills use Python scripts
        echo             Download from: https://python.org/downloads
        echo             Check "Add Python to PATH" during install
    ) else (
        for /f "tokens=*" %%i in ('python3 --version 2^>^&1') do echo   [OK] python: %%i
    )
) else (
    for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo   [OK] python: %%i
)

echo.

REM --- Check for Claude Code CLI ---

where claude >nul 2>&1
if errorlevel 1 (
    echo Claude Code CLI not found. Installing...
    call npm install -g @anthropic-ai/claude-code
    echo.
    where claude >nul 2>&1
    if errorlevel 1 (
        echo Warning: Claude Code installed but 'claude' not found on PATH.
        echo Close and reopen your terminal, then try again.
    ) else (
        echo Claude Code installed successfully.
    )
    echo.
) else (
    for /f "tokens=*" %%i in ('claude --version 2^>^&1') do echo Claude Code: %%i
    echo.
)

REM --- Install CrystalAI framework ---

set "INSTALL_DIR=%USERPROFILE%\.claude"

if exist "%INSTALL_DIR%\.git" (
    echo CrystalAI already installed at %INSTALL_DIR%
    echo Pulling latest changes...
    cd /d "%INSTALL_DIR%" && git pull
) else (
    if exist "%INSTALL_DIR%\*" (
        echo Warning: %INSTALL_DIR% exists and is not empty.
        echo Backing up to %INSTALL_DIR%.backup
        move "%INSTALL_DIR%" "%INSTALL_DIR%.backup"
    )
    echo Cloning CrystalAI framework...
    git clone https://github.com/PulsePanda/CrystalAI.git "%INSTALL_DIR%"
)

echo.

REM --- Copy templates ---

if not exist "%INSTALL_DIR%\settings.json" (
    if exist "%INSTALL_DIR%\settings.json.template" (
        copy "%INSTALL_DIR%\settings.json.template" "%INSTALL_DIR%\settings.json" >nul
        echo Copied settings.json (default permissions^)
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
