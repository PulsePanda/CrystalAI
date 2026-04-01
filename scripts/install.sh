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

MISSING=()

if ! command -v git &>/dev/null; then
    MISSING+=("git — https://git-scm.com/downloads")
fi

if ! command -v node &>/dev/null; then
    MISSING+=("node — https://nodejs.org (LTS recommended)")
fi

if ! command -v python3 &>/dev/null && ! command -v python &>/dev/null; then
    MISSING+=("python3 — https://python.org/downloads")
fi

if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Missing prerequisites:"
    for item in "${MISSING[@]}"; do
        echo "  - $item"
    done
    echo ""
    echo "Install the missing tools above and re-run this script."
    exit 1
fi

echo "Prerequisites OK:"
echo "  git:    $(git --version)"
echo "  node:   $(node --version)"
if command -v python3 &>/dev/null; then
    echo "  python: $(python3 --version)"
else
    echo "  python: $(python --version)"
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
