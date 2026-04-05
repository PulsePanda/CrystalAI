#!/usr/bin/env python3
"""PostToolUse hook: validate vault frontmatter on file writes."""

import json
import os
import re
import sys


def get_vault_path():
    """Determine the vault path from environment or common locations."""
    # Check CLAUDE_PROJECT_DIR first
    project_dir = os.environ.get("CLAUDE_PROJECT_DIR", "")
    if project_dir and os.path.isdir(project_dir):
        # Check if this looks like an Obsidian vault
        if os.path.isdir(os.path.join(project_dir, ".obsidian")):
            return project_dir

    # Fall back to VAULT_PATH env var
    vault_path = os.environ.get("VAULT_PATH", "")
    if vault_path and os.path.isdir(vault_path):
        return vault_path

    return None


def should_skip(file_path, vault_path):
    """Check if this file should skip validation."""
    rel = os.path.relpath(file_path, vault_path)

    # Skip specific directories and files
    skip_prefixes = ("_Templates/", "_System/", ".obsidian/", "_Attachments/")
    skip_names = ("CLAUDE.md", "README.md")

    basename = os.path.basename(file_path)
    if basename in skip_names:
        return True

    for prefix in skip_prefixes:
        if rel.startswith(prefix):
            return True

    return False


def parse_frontmatter(content):
    """Extract YAML frontmatter from markdown content."""
    match = re.match(r"^---\s*\n(.*?)\n---\s*\n", content, re.DOTALL)
    if not match:
        return None

    fm = {}
    for line in match.group(1).split("\n"):
        line = line.strip()
        if ":" in line:
            key, _, value = line.partition(":")
            key = key.strip()
            value = value.strip()
            # Handle array syntax: [val1, val2]
            if value.startswith("[") and value.endswith("]"):
                fm[key] = [v.strip().strip("'\"") for v in value[1:-1].split(",") if v.strip()]
            else:
                fm[key] = value.strip("'\"")
    return fm


def validate(file_path):
    """Validate frontmatter and return warnings."""
    warnings = []

    if not os.path.isfile(file_path):
        return warnings

    if not file_path.endswith(".md"):
        return warnings

    try:
        with open(file_path, "r", encoding="utf-8") as f:
            content = f.read()
    except (OSError, UnicodeDecodeError):
        return warnings

    fm = parse_frontmatter(content)
    if fm is None:
        warnings.append(f"Missing YAML frontmatter in {os.path.basename(file_path)}")
        return warnings

    # Required fields: type, date, tags (always)
    for field in ("type", "date", "tags"):
        if field not in fm or not fm[field]:
            warnings.append(f"Missing required frontmatter field '{field}' in {os.path.basename(file_path)}")

    # status required for project, meeting, daily
    note_type = fm.get("type", "")
    if note_type in ("project", "meeting", "daily"):
        if "status" not in fm or not fm["status"]:
            warnings.append(f"Missing required frontmatter field 'status' for type '{note_type}' in {os.path.basename(file_path)}")

    return warnings


def main():
    try:
        data = json.load(sys.stdin)
    except (json.JSONDecodeError, ValueError):
        sys.exit(0)

    # Extract file path from tool_input
    tool_input = data.get("tool_input", {})
    file_path = tool_input.get("file_path", "")

    if not file_path:
        sys.exit(0)

    vault_path = get_vault_path()
    if not vault_path:
        sys.exit(0)

    # Only validate files under the vault
    try:
        real_file = os.path.realpath(file_path)
        real_vault = os.path.realpath(vault_path)
        if not real_file.startswith(real_vault + os.sep):
            sys.exit(0)
    except (OSError, ValueError):
        sys.exit(0)

    if should_skip(file_path, vault_path):
        sys.exit(0)

    warnings = validate(file_path)

    if warnings:
        output = {
            "hookSpecificOutput": {
                "additionalContext": "Vault frontmatter warnings:\n" + "\n".join(f"- {w}" for w in warnings)
            }
        }
        json.dump(output, sys.stdout)

    sys.exit(0)


if __name__ == "__main__":
    main()
