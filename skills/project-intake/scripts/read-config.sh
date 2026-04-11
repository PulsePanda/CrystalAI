#!/usr/bin/env bash
# read-config.sh — read/write project-intake keys in ~/.claude/crystal.local.yaml
#
# Usage:
#   read-config.sh                    # prints: <projects_path>\t<project_tracker_convention>\n
#                                     # empty string for missing keys
#   read-config.sh --write KEY VALUE  # updates or appends a top-level scalar key
#
# Supported keys: projects_path, project_tracker_convention
#
# Implementation note: crystal.local.yaml is a flat YAML document. We use grep+awk
# rather than a YAML parser because (a) yq isn't universal, (b) the two keys we
# care about are always top-level scalars, and (c) we want this skill to work on a
# clean macOS or Linux install without extra tooling.

set -euo pipefail

CONFIG_FILE="${CRYSTAL_CONFIG:-$HOME/.claude/crystal.local.yaml}"

read_key() {
    local key=$1
    [[ -f "$CONFIG_FILE" ]] || { echo ""; return; }
    local line
    line=$(grep -E "^${key}:" "$CONFIG_FILE" 2>/dev/null | head -1 || true)
    [[ -n "$line" ]] || { echo ""; return; }
    # Strip "key:" prefix, surrounding whitespace, then optional single or double quotes.
    local value="${line#${key}:}"
    # Trim leading whitespace.
    value="${value#"${value%%[![:space:]]*}"}"
    # Trim trailing whitespace / CR.
    value="${value%"${value##*[![:space:]]}"}"
    # Strip matching quotes.
    if [[ "$value" == \"*\" ]]; then
        value="${value#\"}"
        value="${value%\"}"
    elif [[ "$value" == \'*\' ]]; then
        value="${value#\'}"
        value="${value%\'}"
    fi
    printf '%s' "$value"
}

write_key() {
    local key=$1 value=$2
    mkdir -p "$(dirname "$CONFIG_FILE")"
    touch "$CONFIG_FILE"

    if grep -qE "^${key}:" "$CONFIG_FILE" 2>/dev/null; then
        # Update in place. Portable approach (no -i '' vs -i mess): rewrite via tmp.
        local tmp
        tmp=$(mktemp)
        awk -v k="$key" -v v="$value" '
            BEGIN { replaced = 0 }
            $0 ~ "^"k":" && !replaced { print k": \""v"\""; replaced = 1; next }
            { print }
        ' "$CONFIG_FILE" > "$tmp"
        mv "$tmp" "$CONFIG_FILE"
    else
        # Append. Ensure the file ends in a newline first so we don't concatenate lines.
        if [[ -s "$CONFIG_FILE" ]]; then
            local last_char
            last_char=$(tail -c 1 "$CONFIG_FILE")
            if [[ "$last_char" != $'\n' ]]; then
                printf '\n' >> "$CONFIG_FILE"
            fi
        fi
        printf '%s: "%s"\n' "$key" "$value" >> "$CONFIG_FILE"
    fi
}

case "${1:-}" in
    --write)
        [[ $# -eq 3 ]] || { echo "usage: $0 --write KEY VALUE" >&2; exit 2; }
        case "$2" in
            projects_path|project_tracker_convention) ;;
            *) echo "error: unknown key '$2' (expected projects_path or project_tracker_convention)" >&2; exit 2 ;;
        esac
        write_key "$2" "$3"
        ;;
    "")
        # Default: print both keys tab-separated, one line.
        pp=$(read_key projects_path)
        tc=$(read_key project_tracker_convention)
        printf '%s\t%s\n' "$pp" "$tc"
        ;;
    -h|--help)
        sed -n '2,15p' "$0"
        ;;
    *)
        echo "usage: $0 [--write KEY VALUE]" >&2
        exit 2
        ;;
esac
