#!/bin/bash
# CrystalAI Installer — macOS / Linux
# Downloads and sets up the CrystalAI starter framework.

set -e

REPO_URL="https://github.com/PulsePanda/CrystalAI.git"
INSTALL_DIR="$HOME/.claude"

echo ""
echo "=== CrystalAI Installer ==="
echo ""

# --- Check prerequisites ---

# Git is REQUIRED (needed to clone the repo)
if ! command -v git &>/dev/null; then
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

# Node — needed for Claude Code CLI and GWS, warn if missing but continue
if ! command -v node &>/dev/null; then
    echo "  [MISSING] node — needed for Claude Code CLI and email integration"
    echo "            Download from: https://nodejs.org (LTS recommended)"
else
    echo "  [OK] node:   $(node --version)"
fi

# Python — optional, warn if missing but continue
if command -v python3 &>/dev/null; then
    echo "  [OK] python: $(python3 --version)"
elif command -v python &>/dev/null; then
    echo "  [OK] python: $(python --version)"
else
    echo "  [MISSING] python — some skills use Python scripts"
    echo "            Download from: https://python.org/downloads"
fi

echo ""

# --- Check for Claude Code CLI ---

if ! command -v claude &>/dev/null; then
    echo "Claude Code CLI not found. Installing..."
    npm install -g @anthropic-ai/claude-code
    if command -v claude &>/dev/null; then
        echo "Claude Code installed: $(claude --version)"
    else
        echo "Warning: Claude Code installed but 'claude' not found on PATH."
        echo "You may need to restart your terminal or add npm global bin to PATH."
    fi
    echo ""
else
    echo "Claude Code: $(claude --version)"
    echo ""
fi

# --- Install CrystalAI framework ---

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "CrystalAI already installed at $INSTALL_DIR"
    echo "Pulling latest changes..."
    cd "$INSTALL_DIR" && git pull
else
    if [ -d "$INSTALL_DIR" ] && [ "$(ls -A "$INSTALL_DIR" 2>/dev/null)" ]; then
        echo "Warning: $INSTALL_DIR exists and is not empty."
        echo "Backing up existing directory to ${INSTALL_DIR}.backup"
        mv "$INSTALL_DIR" "${INSTALL_DIR}.backup"
    fi
    echo "Cloning CrystalAI framework..."
    git clone "$REPO_URL" "$INSTALL_DIR"
fi

echo ""

# --- Copy templates ---

if [ ! -f "$INSTALL_DIR/settings.json" ] && [ -f "$INSTALL_DIR/settings.json.template" ]; then
    cp "$INSTALL_DIR/settings.json.template" "$INSTALL_DIR/settings.json"
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
