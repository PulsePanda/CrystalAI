#!/bin/bash
# Auto-update CrystalAI plugin from git
cd "${CLAUDE_PLUGIN_ROOT}" 2>/dev/null || exit 0
git pull --ff-only 2>/dev/null || true
