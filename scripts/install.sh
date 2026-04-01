#!/bin/bash
# CrystalAI Installer - macOS / Linux
# Downloads and sets up the CrystalAI starter framework.

set -e
trap 'echo ""; echo "Installation failed. Check the errors above."' ERR

REPO_URL="https://github.com/PulsePanda/CrystalAI.git"
INSTALL_DIR="$HOME/.claude"

echo ""
echo "=== CrystalAI Installer ==="
echo ""

# --- Check prerequisites ---

# Git is REQUIRED (needed to clone the repo)
if ! command -v git >/dev/null 2>&1; then
    echo "[REQUIRED] git is not installed."
    echo ""
    echo "  macOS:  brew install git  (or install Xcode Command Line Tools)"
    echo "  Linux:  sudo apt install git  (or your distro's package manager)"
    echo ""
    echo "Install git, then re-run this script."
    exit 1
fi

echo "Checking tools:"
echo "  [OK] git:    $(git --version)"

# Node - needed for Claude Code CLI and GWS, warn if missing but continue
NODE_MISSING=0
if ! command -v node >/dev/null 2>&1; then
    echo "  [MISSING] node - needed for Claude Code CLI and email integration"
    echo "            Download from: https://nodejs.org (LTS recommended)"
    NODE_MISSING=1
else
    echo "  [OK] node:   $(node --version)"
fi

# Python - optional, warn if missing but continue
if command -v python3 >/dev/null 2>&1; then
    echo "  [OK] python: $(python3 --version)"
elif command -v python >/dev/null 2>&1; then
    echo "  [OK] python: $(python --version)"
else
    echo "  [MISSING] python - some skills use Python scripts"
    echo "            Download from: https://python.org/downloads"
fi

echo ""

# --- Check for Claude Code CLI ---

if command -v claude >/dev/null 2>&1; then
    echo "Claude Code: $(claude --version 2>&1 || echo 'installed')"
    echo ""
elif [ "$NODE_MISSING" = "1" ]; then
    echo "Claude Code CLI not found. Cannot install - Node.js is required first."
    echo "Install Node.js, reopen your terminal, and re-run this script."
    echo ""
elif ! command -v npm >/dev/null 2>&1; then
    echo "Claude Code CLI not found. npm not available."
    echo "Install Node.js first, then run: npm install -g @anthropic-ai/claude-code"
    echo ""
else
    echo "Claude Code CLI not found. Installing..."
    if npm install -g @anthropic-ai/claude-code; then
        if command -v claude >/dev/null 2>&1; then
            echo "Claude Code installed: $(claude --version 2>&1 || echo 'installed')"
        else
            echo "Warning: Claude Code installed but 'claude' not found on PATH."
            echo "You may need to restart your terminal or add npm global bin to PATH."
        fi
    else
        echo ""
        echo "Warning: npm install failed. On Linux, you may need:"
        echo "  sudo npm install -g @anthropic-ai/claude-code"
    fi
    echo ""
fi

# --- Install CrystalAI framework ---

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "CrystalAI already installed at $INSTALL_DIR"
    echo "Pulling latest changes..."
    (cd "$INSTALL_DIR" && git pull) || {
        echo "Warning: git pull failed. Your local copy may have uncommitted changes."
    }
else
    if [ -d "$INSTALL_DIR" ]; then
        BACKUP_DIR="${INSTALL_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Warning: $INSTALL_DIR exists and is not a CrystalAI install."
        echo "Backing up existing directory to $BACKUP_DIR"
        mv "$INSTALL_DIR" "$BACKUP_DIR"
    fi
    echo "Cloning CrystalAI framework..."
    if ! git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"; then
        echo ""
        echo "git clone failed. Possible causes:"
        echo "  - No internet connection"
        echo "  - Repository is private and you need access"
        echo "  - Git credentials not configured"
        exit 1
    fi
fi

echo ""

# --- Copy templates ---

if [ ! -f "$INSTALL_DIR/settings.json" ] && [ -f "$INSTALL_DIR/settings.json.template" ]; then
    cp "$INSTALL_DIR/settings.json.template" "$INSTALL_DIR/settings.json"
    chmod 600 "$INSTALL_DIR/settings.json"
    echo "Copied settings.json (default permissions)"
fi

echo ""
echo "=== Installation complete ==="
echo ""
echo "Next steps:"
echo "  1. Open a new terminal"
echo "  2. Run: claude"
echo "  3. Type: /onboard"
echo ""
echo "The onboarding wizard will walk you through the rest."
echo ""
