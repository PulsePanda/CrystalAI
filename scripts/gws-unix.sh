#!/bin/bash
# gws-unix.sh — wrapper to call gws with per-account auth via crystal-auth sidecar.
# Works on macOS and Linux. Windows uses gws-windows.bat.
#
# Usage: gws-unix.sh <account> <gws args...>
# Example: gws-unix.sh personal gmail users messages list --params '{"userId":"me"}'
#
# Auth model: crystal-auth holds OAuth state via the buildcrystal.ai auth broker.
# This script fetches a fresh access token on every invocation and passes it to
# gws via the GOOGLE_WORKSPACE_CLI_TOKEN env var, which bypasses gws's own
# credential loading. See docs/gws-auth.md for the full architecture.

set -euo pipefail

ACCOUNT="${1:-}"

if [[ -z "$ACCOUNT" ]]; then
    echo "Usage: gws-unix.sh <account> <gws args...>" >&2
    echo "First time? Run: crystal-auth login <account>" >&2
    exit 1
fi
shift

# Locate crystal-auth.py — prefer $HOME/.claude/scripts/ (where CrystalAI ships it),
# fall back to searching next to this script (dev/test scenario).
CRYSTAL_AUTH="$HOME/.claude/scripts/crystal-auth.py"
if [[ ! -f "$CRYSTAL_AUTH" ]]; then
    CRYSTAL_AUTH="$(dirname "$0")/crystal-auth.py"
fi
if [[ ! -f "$CRYSTAL_AUTH" ]]; then
    echo "gws-unix.sh: crystal-auth.py not found at ~/.claude/scripts/crystal-auth.py" >&2
    echo "             Reinstall CrystalAI or run the bootstrap prompt again." >&2
    exit 2
fi

# Resolve the Python interpreter via find-python.sh (cross-platform: python3 on
# macOS/Linux, python on Windows Git Bash). Keeps this wrapper working on any
# machine that has either interpreter on PATH.
PYTHON_WRAPPER="$HOME/.claude/scripts/find-python.sh"
if [[ ! -x "$PYTHON_WRAPPER" ]]; then
    PYTHON_WRAPPER="$(dirname "$0")/find-python.sh"
fi
if [[ ! -x "$PYTHON_WRAPPER" ]]; then
    # Absolute last resort: pick python3 or python directly.
    if command -v python3 >/dev/null 2>&1; then
        PYTHON_CMD="python3"
    elif command -v python >/dev/null 2>&1; then
        PYTHON_CMD="python"
    else
        echo "gws-unix.sh: no Python interpreter found on PATH (checked python3, python)" >&2
        echo "             Install Python 3 and try again." >&2
        exit 2
    fi
else
    PYTHON_CMD="$PYTHON_WRAPPER"
fi

# gws still uses this dir for API discovery caches, so set it per-account.
export GOOGLE_WORKSPACE_CLI_CONFIG_DIR="$HOME/.config/gws/accounts/${ACCOUNT}"
mkdir -p "$GOOGLE_WORKSPACE_CLI_CONFIG_DIR"

# Fetch a fresh access token. crystal-auth handles caching + refresh via auth server.
TOKEN="$("$PYTHON_CMD" "$CRYSTAL_AUTH" get-token "$ACCOUNT")" || {
    rc=$?
    if [[ $rc -eq 1 ]]; then
        echo "gws-unix.sh: no valid credentials for '$ACCOUNT'" >&2
        echo "             Run: crystal-auth login $ACCOUNT" >&2
    else
        echo "gws-unix.sh: crystal-auth failed to get a token (exit $rc)" >&2
    fi
    exit $rc
}

export GOOGLE_WORKSPACE_CLI_TOKEN="$TOKEN"

# Run gws with the pre-supplied token; gws bypasses its own auth entirely.
exec gws "$@"
