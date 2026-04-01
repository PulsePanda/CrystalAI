@echo off
REM CrystalAI Installer — Windows
REM Downloads and sets up the CrystalAI starter framework.

setlocal enabledelayedexpansion

echo.
echo === CrystalAI Installer ===
echo.

REM --- Check prerequisites ---

set "MISSING=0"

where git >nul 2>&1
if errorlevel 1 (
    echo [MISSING] git — https://git-scm.com/downloads
    set "MISSING=1"
)

where node >nul 2>&1
if errorlevel 1 (
    echo [MISSING] node — https://nodejs.org ^(LTS recommended^)
    set "MISSING=1"
)

where python >nul 2>&1
if errorlevel 1 (
    where python3 >nul 2>&1
    if errorlevel 1 (
        echo [MISSING] python — https://python.org/downloads ^(check "Add to PATH" during install^)
        set "MISSING=1"
    )
)

if "%MISSING%"=="1" (
    echo.
    echo Install the missing tools above and re-run this script.
    exit /b 1
)

echo Prerequisites OK:
for /f "tokens=*" %%i in ('git --version') do echo   git:    %%i
for /f "tokens=*" %%i in ('node --version') do echo   node:   %%i
for /f "tokens=*" %%i in ('python --version 2^>^&1') do echo   python: %%i
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
