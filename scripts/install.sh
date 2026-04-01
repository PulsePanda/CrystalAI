#!/bin/bash
# CrystalAI Installer - macOS / Linux
# Downloads and sets up the CrystalAI starter framework.
# Automatically installs missing prerequisites.

set -e
trap 'echo ""; echo "Installation failed at line $LINENO. Check the errors above."' ERR

REPO_URL="https://github.com/PulsePanda/CrystalAI.git"
INSTALL_DIR="$HOME/.claude"
NODE_LTS_VERSION="22"

# --- Utility functions ---

info()  { echo "  [INFO] $*"; }
ok()    { echo "  [OK]   $*"; }
warn()  { echo "  [WARN] $*"; }
fail()  { echo "  [FAIL] $*"; }

# Refresh PATH after installs so new binaries are found immediately.
refresh_path() {
    export PATH="/usr/local/bin:/opt/homebrew/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"
    # Pick up nvm / volta / fnm if present
    if [ -s "$HOME/.nvm/nvm.sh" ]; then
        . "$HOME/.nvm/nvm.sh" >/dev/null 2>&1 || true
    fi
    hash -r 2>/dev/null || true
}

has_sudo() {
    if command -v sudo >/dev/null 2>&1; then
        # Check if user can sudo without a tty prompt failing
        sudo -n true 2>/dev/null && return 0
        # They have sudo but may need a password -- that's fine, sudo will prompt
        return 0
    fi
    return 1
}

# --- Detect OS and distro ---

detect_os() {
    OS_TYPE="$(uname -s)"
    DISTRO=""
    PKG_MGR=""

    case "$OS_TYPE" in
        Darwin)
            OS_TYPE="macOS"
            if command -v brew >/dev/null 2>&1; then
                PKG_MGR="brew"
            fi
            ;;
        Linux)
            OS_TYPE="Linux"
            if [ -f /etc/os-release ]; then
                . /etc/os-release
                DISTRO="$ID"
            fi
            case "$DISTRO" in
                ubuntu|debian|pop|linuxmint|elementary|zorin)
                    PKG_MGR="apt" ;;
                fedora|rhel|centos|rocky|alma|ol)
                    PKG_MGR="dnf"
                    # Fall back to yum on older systems
                    if ! command -v dnf >/dev/null 2>&1; then
                        PKG_MGR="yum"
                    fi
                    ;;
                arch|manjaro|endeavouros)
                    PKG_MGR="pacman" ;;
                opensuse*|sles)
                    PKG_MGR="zypper" ;;
                *)
                    # Best-effort detection by available package manager
                    if command -v apt-get >/dev/null 2>&1; then
                        PKG_MGR="apt"
                    elif command -v dnf >/dev/null 2>&1; then
                        PKG_MGR="dnf"
                    elif command -v yum >/dev/null 2>&1; then
                        PKG_MGR="yum"
                    elif command -v pacman >/dev/null 2>&1; then
                        PKG_MGR="pacman"
                    elif command -v zypper >/dev/null 2>&1; then
                        PKG_MGR="zypper"
                    fi
                    ;;
            esac
            ;;
        *)
            echo "Unsupported OS: $OS_TYPE"
            exit 1
            ;;
    esac
}

# --- Install functions ---

install_git_macos() {
    info "Git not found. Installing Xcode Command Line Tools (provides git)..."
    info "This will open a GUI dialog. Please click 'Install' and wait for it to finish."
    xcode-select --install 2>/dev/null || true

    # Wait for the GUI installer to complete (polls every 5s, up to 15 min)
    local max_wait=900
    local waited=0
    while [ $waited -lt $max_wait ]; do
        if xcode-select -p >/dev/null 2>&1; then
            break
        fi
        sleep 5
        waited=$((waited + 5))
    done

    refresh_path
    if ! command -v git >/dev/null 2>&1; then
        fail "Git still not found after Xcode CLT install."
        fail "Please install Xcode Command Line Tools manually, then re-run this script."
        exit 1
    fi
}

install_git_linux() {
    info "Git not found. Installing via $PKG_MGR..."
    case "$PKG_MGR" in
        apt)    sudo apt-get update -qq && sudo apt-get install -y git ;;
        dnf)    sudo dnf install -y git ;;
        yum)    sudo yum install -y git ;;
        pacman) sudo pacman -S --noconfirm git ;;
        zypper) sudo zypper install -y git ;;
        *)
            fail "No supported package manager found. Install git manually, then re-run."
            exit 1
            ;;
    esac
    refresh_path
}

install_node_macos() {
    if [ "$PKG_MGR" = "brew" ]; then
        info "Node not found. Installing via Homebrew..."
        brew install node
    else
        info "Node not found and Homebrew is not available."
        info "Downloading official Node.js LTS installer from nodejs.org..."
        local pkg_url="https://nodejs.org/dist/latest-v${NODE_LTS_VERSION}.x/node-v${NODE_LTS_VERSION}.0.0.pkg"
        # Get the actual latest LTS URL from the index
        local tmp_pkg
        tmp_pkg="$(mktemp /tmp/node-lts-XXXXXX.pkg)"

        # Fetch the dist index to find the exact latest v22 filename
        local latest_ver
        latest_ver=$(curl -fsSL "https://nodejs.org/dist/latest-v${NODE_LTS_VERSION}.x/" \
            | grep -oE "node-v${NODE_LTS_VERSION}\.[0-9]+\.[0-9]+" \
            | head -1) || true

        if [ -z "$latest_ver" ]; then
            latest_ver="node-v${NODE_LTS_VERSION}.0.0"
            warn "Could not detect exact LTS version, trying ${latest_ver}"
        fi

        local real_url="https://nodejs.org/dist/latest-v${NODE_LTS_VERSION}.x/${latest_ver}.pkg"
        info "Downloading ${real_url}..."
        if curl -fSL -o "$tmp_pkg" "$real_url"; then
            info "Installing Node.js (requires admin password)..."
            sudo installer -pkg "$tmp_pkg" -target /
            rm -f "$tmp_pkg"
        else
            rm -f "$tmp_pkg"
            fail "Failed to download Node.js installer."
            fail "Install Node.js manually from https://nodejs.org, then re-run."
            exit 1
        fi
    fi
    refresh_path
}

install_node_linux() {
    case "$PKG_MGR" in
        apt)
            info "Node not found. Installing via NodeSource LTS setup..."
            curl -fsSL "https://deb.nodesource.com/setup_${NODE_LTS_VERSION}.x" | sudo -E bash -
            sudo apt-get install -y nodejs
            ;;
        dnf|yum)
            info "Node not found. Installing via NodeSource LTS setup..."
            curl -fsSL "https://rpm.nodesource.com/setup_${NODE_LTS_VERSION}.x" | sudo -E bash -
            sudo "$PKG_MGR" install -y nodejs
            ;;
        pacman)
            info "Node not found. Installing via pacman..."
            sudo pacman -S --noconfirm nodejs npm
            ;;
        zypper)
            info "Node not found. Installing via zypper..."
            sudo zypper install -y nodejs npm
            ;;
        *)
            fail "No supported package manager. Install Node.js manually from https://nodejs.org"
            exit 1
            ;;
    esac
    refresh_path
}

install_python_macos() {
    if [ "$PKG_MGR" = "brew" ]; then
        info "Python3 not found. Installing via Homebrew..."
        brew install python3
    else
        warn "Python3 not found and Homebrew is not available."
        warn "macOS usually ships with Python3. If you need it, install Homebrew first:"
        warn "  /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        warn "Then run: brew install python3"
    fi
    refresh_path
}

install_python_linux() {
    info "Python3 not found. Installing via $PKG_MGR..."
    case "$PKG_MGR" in
        apt)    sudo apt-get update -qq && sudo apt-get install -y python3 ;;
        dnf)    sudo dnf install -y python3 ;;
        yum)    sudo yum install -y python3 ;;
        pacman) sudo pacman -S --noconfirm python ;;
        zypper) sudo zypper install -y python3 ;;
        *)
            warn "No supported package manager. Install python3 manually."
            ;;
    esac
    refresh_path
}

install_claude_code() {
    if ! command -v npm >/dev/null 2>&1; then
        fail "npm not available. Cannot install Claude Code CLI."
        fail "This shouldn't happen if Node was just installed. Check your PATH."
        return 1
    fi

    info "Installing Claude Code CLI via npm..."
    if npm install -g @anthropic-ai/claude-code 2>/dev/null; then
        refresh_path
        return 0
    fi

    # npm global install often fails on Linux system Node without sudo
    if [ "$OS_TYPE" = "Linux" ] && has_sudo; then
        info "Retrying with sudo..."
        if sudo npm install -g @anthropic-ai/claude-code; then
            refresh_path
            return 0
        fi
    fi

    fail "Failed to install Claude Code CLI."
    warn "Try manually: npm install -g @anthropic-ai/claude-code"
    return 1
}

# ==============================
#  Main
# ==============================

echo ""
echo "=== CrystalAI Installer ==="
echo ""

detect_os
info "Detected OS: $OS_TYPE${DISTRO:+ ($DISTRO)}${PKG_MGR:+, package manager: $PKG_MGR}"
echo ""

# --- 1. Git ---

if ! command -v git >/dev/null 2>&1; then
    case "$OS_TYPE" in
        macOS) install_git_macos ;;
        Linux)
            if has_sudo; then
                install_git_linux
            else
                fail "Git is not installed and sudo is not available."
                fail "Ask your system administrator to install git, then re-run."
                exit 1
            fi
            ;;
    esac
fi

if command -v git >/dev/null 2>&1; then
    ok "git: $(git --version)"
else
    fail "Git is still not available. Cannot continue."
    exit 1
fi

# --- 2. Node ---

if ! command -v node >/dev/null 2>&1; then
    case "$OS_TYPE" in
        macOS) install_node_macos ;;
        Linux)
            if has_sudo; then
                install_node_linux
            else
                warn "Node.js is not installed and sudo is not available."
                warn "Ask your administrator to install Node.js, or install nvm:"
                warn "  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.1/install.sh | bash"
            fi
            ;;
    esac
fi

if command -v node >/dev/null 2>&1; then
    ok "node: $(node --version)"
else
    warn "Node.js not available. Claude Code CLI will not be installed."
fi

# --- 3. Python ---

if ! command -v python3 >/dev/null 2>&1 && ! command -v python >/dev/null 2>&1; then
    case "$OS_TYPE" in
        macOS) install_python_macos ;;
        Linux)
            if has_sudo; then
                install_python_linux
            else
                warn "Python3 is not installed and sudo is not available. Some skills may not work."
            fi
            ;;
    esac
fi

if command -v python3 >/dev/null 2>&1; then
    ok "python: $(python3 --version)"
elif command -v python >/dev/null 2>&1; then
    ok "python: $(python --version)"
else
    warn "Python not available. Some skills may not work."
fi

echo ""

# --- 4. Claude Code CLI ---

if command -v claude >/dev/null 2>&1; then
    ok "Claude Code: $(claude --version 2>&1 || echo 'installed')"
elif command -v node >/dev/null 2>&1; then
    if install_claude_code; then
        if command -v claude >/dev/null 2>&1; then
            ok "Claude Code: $(claude --version 2>&1 || echo 'installed')"
        else
            warn "Claude Code installed but 'claude' not found on PATH."
            warn "You may need to restart your terminal or add npm global bin to PATH."
        fi
    fi
else
    warn "Skipping Claude Code CLI install (Node.js not available)."
fi

echo ""

# --- 4b. Claude Desktop App ---

if [ "$OS_TYPE" = "macOS" ]; then
    if [ -d "/Applications/Claude.app" ]; then
        ok "Claude Desktop: installed"
    else
        info "Claude Desktop not found. Downloading..."
        CLAUDE_DMG="$(mktemp /tmp/claude-desktop-XXXXXX.dmg)"
        if curl -fSL -o "$CLAUDE_DMG" "https://claude.ai/redirect/claudedotcom.v1.5f36ec2e-fc5d-4d33-911f-6e77d2fa6052/api/desktop/darwin/universal/dmg/latest/redirect"; then
            info "Mounting and installing Claude Desktop..."
            hdiutil attach "$CLAUDE_DMG" -quiet -mountpoint /tmp/claude-mount
            cp -R "/tmp/claude-mount/Claude.app" /Applications/
            hdiutil detach /tmp/claude-mount -quiet
            rm -f "$CLAUDE_DMG"
            ok "Claude Desktop: installed to /Applications/Claude.app"
        else
            rm -f "$CLAUDE_DMG"
            warn "Failed to download Claude Desktop."
            warn "Download manually from: https://claude.ai/download"
        fi
    fi
    echo ""
fi

# --- 5. Clone / update CrystalAI ---

if [ -d "$INSTALL_DIR/.git" ]; then
    echo "CrystalAI already installed at $INSTALL_DIR"
    echo "Pulling latest changes..."
    (cd "$INSTALL_DIR" && git pull) || {
        warn "git pull failed. Your local copy may have uncommitted changes."
    }
else
    if [ -d "$INSTALL_DIR" ]; then
        BACKUP_DIR="${INSTALL_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        warn "$INSTALL_DIR exists and is not a CrystalAI install."
        info "Backing up existing directory to $BACKUP_DIR"
        mv "$INSTALL_DIR" "$BACKUP_DIR"
    fi
    echo "Cloning CrystalAI framework..."
    if ! git clone --depth 1 "$REPO_URL" "$INSTALL_DIR"; then
        echo ""
        fail "git clone failed. Possible causes:"
        fail "  - No internet connection"
        fail "  - Repository is private and you need access"
        fail "  - Git credentials not configured"
        exit 1
    fi
fi

echo ""

# --- 6. Copy templates ---

if [ ! -f "$INSTALL_DIR/settings.json" ] && [ -f "$INSTALL_DIR/settings.json.template" ]; then
    cp "$INSTALL_DIR/settings.json.template" "$INSTALL_DIR/settings.json"
    chmod 600 "$INSTALL_DIR/settings.json"
    info "Copied settings.json (permissions: 600)"
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
