#!/usr/bin/env bash
# CrystalAI Upgrade Script
# Deterministic shell portion of the hybrid upgrade system.
# Handles version checking, backups, file inventory, plan generation,
# and copying infrastructure files. AI-assisted merges are deferred
# to the /vault-upgrade skill.

set -euo pipefail

# --- Constants ---

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_SOURCE="$(cd "$SCRIPT_DIR/.." && pwd)"
DEFAULT_TARGET="$HOME/.claude"

# --- Utility functions ---

info()  { echo "  [INFO] $*"; }
ok()    { echo "  [OK]   $*"; }
warn()  { echo "  [WARN] $*"; }
fail()  { echo "  [FAIL] $*" >&2; }

# Cross-platform SHA-256
sha256_of() {
    local file="$1"
    if command -v shasum >/dev/null 2>&1; then
        shasum -a 256 "$file" | cut -d' ' -f1
    elif command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$file" | cut -d' ' -f1
    else
        fail "Neither shasum nor sha256sum found. Cannot compute file hashes."
        exit 1
    fi
}

# Read a JSON field (simple — no jq dependency)
# Usage: json_field file key
# Handles simple top-level string/number fields only.
json_field() {
    local file="$1" key="$2"
    # Matches "key": "value" or "key": value (number/bool)
    sed -n "s/.*\"${key}\"[[:space:]]*:[[:space:]]*\"\{0,1\}\([^\",:}]*\)\"\{0,1\}.*/\1/p" "$file" | head -1
}

# Read a JSON array of strings for a given key.
# Returns one value per line. Only matches the FIRST occurrence of the key.
# Portable across macOS awk and gawk.
json_array() {
    local file="$1" key="$2"
    # Use a state-machine approach via a while-read loop for portability.
    # Find the first line containing "key": then collect values until ].
    local in_block=0
    local found=0
    while IFS= read -r line; do
        if [[ "$found" -eq 0 ]]; then
            # Look for the key — must be an exact "key" match (word-bounded by quotes)
            if echo "$line" | grep -q "\"${key}\"[[:space:]]*:"; then
                found=1
                # Check if array opens on this line
                if echo "$line" | grep -q '\['; then
                    in_block=1
                    # Check if array also closes on this line (inline array)
                    if echo "$line" | grep -q '\]'; then
                        echo "$line" | sed -n 's/[^"]*"\([^"]*\)"/\1\n/gp' | grep -v "^${key}$" || true
                        return 0
                    fi
                fi
            fi
        elif [[ "$found" -eq 1 && "$in_block" -eq 0 ]]; then
            # Key found but [ not yet seen
            if echo "$line" | grep -q '\['; then
                in_block=1
                if echo "$line" | grep -q '\]'; then
                    echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p'
                    return 0
                fi
            fi
        elif [[ "$in_block" -eq 1 ]]; then
            # Inside the array — extract values until ]
            if echo "$line" | grep -q '\]'; then
                # May have a value on the closing line too
                echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p' || true
                return 0
            fi
            echo "$line" | sed -n 's/.*"\([^"]*\)".*/\1/p' || true
        fi
    done < "$file"
}

# Read file_hashes from .crystal-version.json
# Usage: version_hash file key
# Returns the sha256 hash stored for a given file path.
version_hash() {
    local vfile="$1" fpath="$2"
    # Matches "path": "sha256:HASH"
    sed -n "s|.*\"${fpath}\"[[:space:]]*:[[:space:]]*\"sha256:\([a-f0-9]*\)\".*|\1|p" "$vfile" | head -1
}

# Timestamp for backup dirs and reports
timestamp() {
    date '+%Y%m%d-%H%M%S'
}

timestamp_pretty() {
    date '+%Y-%m-%d %H:%M:%S'
}

timestamp_iso() {
    date -u '+%Y-%m-%dT%H:%M:%SZ'
}

# --- Usage ---

usage() {
    cat <<'USAGE'
CrystalAI Upgrade Script

Usage: upgrade.sh [OPTIONS]

Options:
  --source DIR     Path to CrystalAI repo (default: parent of script directory)
  --target DIR     Path to installation (default: ~/.claude)
  --dry-run        Generate plan only, don't execute
  --backup-only    Create backup and exit
  --force          Run even if versions match
  --version        Show installed and repo versions
  --help           Show this message

Exit codes:
  0  Success
  1  Error
  2  Dry-run completed (plan generated)
USAGE
}

# --- Argument parsing ---

SOURCE_DIR="$DEFAULT_SOURCE"
TARGET_DIR="$DEFAULT_TARGET"
DRY_RUN=0
BACKUP_ONLY=0
FORCE=0
SHOW_VERSION=0

while [[ $# -gt 0 ]]; do
    case "$1" in
        --source)
            SOURCE_DIR="$2"
            shift 2
            ;;
        --target)
            TARGET_DIR="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            shift
            ;;
        --backup-only)
            BACKUP_ONLY=1
            shift
            ;;
        --force)
            FORCE=1
            shift
            ;;
        --version)
            SHOW_VERSION=1
            shift
            ;;
        --help|-h)
            usage
            exit 0
            ;;
        *)
            fail "Unknown option: $1"
            usage
            exit 1
            ;;
    esac
done

# --- Phase 1: Pre-flight ---

MANIFEST="$SOURCE_DIR/vault-manifest.json"
VERSION_FILE="$TARGET_DIR/.crystal-version.json"

if [[ ! -d "$SOURCE_DIR" ]]; then
    fail "Source directory does not exist: $SOURCE_DIR"
    exit 1
fi

if [[ ! -f "$MANIFEST" ]]; then
    fail "vault-manifest.json not found in source: $SOURCE_DIR"
    exit 1
fi

# Read source version
SOURCE_VERSION="$(json_field "$MANIFEST" "version")"
if [[ -z "$SOURCE_VERSION" ]]; then
    fail "Could not read version from vault-manifest.json"
    exit 1
fi

# Read target version (may not exist for fresh installs)
TARGET_VERSION=""
if [[ -f "$VERSION_FILE" ]]; then
    TARGET_VERSION="$(json_field "$VERSION_FILE" "version")"
fi

# --version flag: just show and exit
if [[ "$SHOW_VERSION" -eq 1 ]]; then
    echo "Repository version: $SOURCE_VERSION"
    if [[ -n "$TARGET_VERSION" ]]; then
        echo "Installed version: $TARGET_VERSION"
    else
        echo "Installed version: (not installed)"
    fi
    exit 0
fi

echo ""
echo "=== CrystalAI Upgrade ==="
echo ""
info "Source: $SOURCE_DIR (v$SOURCE_VERSION)"
if [[ -n "$TARGET_VERSION" ]]; then
    info "Target: $TARGET_DIR (v$TARGET_VERSION)"
else
    info "Target: $TARGET_DIR (fresh install)"
fi
echo ""

# Version check
if [[ "$SOURCE_VERSION" == "$TARGET_VERSION" && "$FORCE" -eq 0 ]]; then
    ok "Already up to date (v$SOURCE_VERSION)"
    exit 0
fi

# Create target if it doesn't exist (fresh install)
if [[ ! -d "$TARGET_DIR" ]]; then
    info "Creating target directory: $TARGET_DIR"
    mkdir -p "$TARGET_DIR"
fi

# --- Phase 2: Backup (skip in dry-run mode) ---

TS="$(timestamp)"
if [[ "$TARGET_DIR" == "$HOME/.claude" ]]; then
    BACKUP_DIR="$HOME/.claude-backup-$TS"
else
    BACKUP_DIR="${TARGET_DIR}-backup-$TS"
fi

if [[ "$DRY_RUN" -eq 0 ]]; then
    info "Creating backup: $BACKUP_DIR"
    cp -a "$TARGET_DIR" "$BACKUP_DIR"
    ok "Backup complete: $BACKUP_DIR"
    echo ""
else
    BACKUP_DIR="(dry-run — no backup created)"
fi

if [[ "$BACKUP_ONLY" -eq 1 ]]; then
    if [[ "$DRY_RUN" -eq 1 ]]; then
        fail "Cannot use --backup-only with --dry-run"
        exit 1
    fi
    echo "BACKUP_PATH=$BACKUP_DIR"
    ok "Backup-only mode. Exiting."
    exit 0
fi

# --- Phase 3: Inventory & Classify ---

# Counters
INFRA_NEW=0; INFRA_UPDATE=0; INFRA_SKIP=0
SCAFF_NEW=0; SCAFF_UPDATE=0; SCAFF_CUSTOM=0
VAULT_CREATE=0; VAULT_ADD=0; VAULT_SKIP=0

# Plan lines (collected as arrays)
declare -a PLAN_INFRA=()
declare -a PLAN_SCAFFOLD=()
declare -a PLAN_VAULT=()

# Track files for execution phase
declare -a EXEC_COPY=()       # source:target pairs to copy
declare -a EXEC_MKDIR=()      # directories to create
declare -a AI_MERGE_FILES=()  # files needing AI merge

# Collect hashes for .crystal-version.json
declare -a VERSION_HASHES=()

# --- Infrastructure files ---

infra_files="$(json_array "$MANIFEST" "infrastructure")"
while IFS= read -r relpath; do
    [[ -z "$relpath" ]] && continue
    src="$SOURCE_DIR/$relpath"
    tgt="$TARGET_DIR/$relpath"

    if [[ ! -f "$src" ]]; then
        warn "Infrastructure file in manifest but missing from source: $relpath"
        continue
    fi

    if [[ ! -f "$tgt" ]]; then
        PLAN_INFRA+=("| $relpath | NEW | Not installed |")
        EXEC_COPY+=("$src|$tgt")
        INFRA_NEW=$((INFRA_NEW + 1))
    else
        src_hash="$(sha256_of "$src")"
        tgt_hash="$(sha256_of "$tgt")"
        if [[ "$src_hash" == "$tgt_hash" ]]; then
            PLAN_INFRA+=("| $relpath | SKIP | Unchanged |")
            INFRA_SKIP=$((INFRA_SKIP + 1))
        else
            PLAN_INFRA+=("| $relpath | UPDATE | SHA mismatch |")
            EXEC_COPY+=("$src|$tgt")
            INFRA_UPDATE=$((INFRA_UPDATE + 1))
        fi
    fi
done <<< "$infra_files"

# --- Scaffold files ---

scaff_files="$(json_array "$MANIFEST" "scaffold")"
while IFS= read -r relpath; do
    [[ -z "$relpath" ]] && continue
    src="$SOURCE_DIR/$relpath"
    tgt="$TARGET_DIR/$relpath"

    if [[ ! -f "$src" ]]; then
        warn "Scaffold file in manifest but missing from source: $relpath"
        continue
    fi

    src_hash="$(sha256_of "$src")"
    VERSION_HASHES+=("\"$relpath\": \"sha256:$src_hash\"")

    if [[ ! -f "$tgt" ]]; then
        PLAN_SCAFFOLD+=("| $relpath | NEW | Not installed |")
        EXEC_COPY+=("$src|$tgt")
        SCAFF_NEW=$((SCAFF_NEW + 1))
    else
        tgt_hash="$(sha256_of "$tgt")"

        # Check if user has customized the file by comparing against
        # the hash from the PREVIOUS version's manifest (stored in .crystal-version.json)
        prev_hash=""
        if [[ -f "$VERSION_FILE" ]]; then
            prev_hash="$(version_hash "$VERSION_FILE" "$relpath")"
        fi

        if [[ -n "$prev_hash" && "$tgt_hash" == "$prev_hash" ]]; then
            # Target matches the previous version's hash — user hasn't customized
            PLAN_SCAFFOLD+=("| $relpath | UPDATE | Unmodified by user, safe to overwrite |")
            EXEC_COPY+=("$src|$tgt")
            SCAFF_UPDATE=$((SCAFF_UPDATE + 1))
        elif [[ "$src_hash" == "$tgt_hash" ]]; then
            # Already matches new source
            PLAN_SCAFFOLD+=("| $relpath | SKIP | Already matches source |")
        else
            # User has customized — needs AI merge
            PLAN_SCAFFOLD+=("| $relpath | CUSTOMIZED | User modified — AI merge required |")
            AI_MERGE_FILES+=("$relpath")
            SCAFF_CUSTOM=$((SCAFF_CUSTOM + 1))
        fi
    fi
done <<< "$scaff_files"

# --- Vault structure ---

# Determine vault path: check crystal.local.yaml, fall back to target/vault/
VAULT_PATH=""
LOCAL_YAML="$TARGET_DIR/crystal.local.yaml"
if [[ -f "$LOCAL_YAML" ]]; then
    # Try to extract vault_path from YAML (simple grep — no yq dependency)
    VAULT_PATH="$(sed -n 's/^[[:space:]]*vault_path[[:space:]]*:[[:space:]]*\(.*\)/\1/p' "$LOCAL_YAML" | head -1 | tr -d '"' | tr -d "'")"
    # Expand ~ if present
    if [[ "$VAULT_PATH" == "~"* ]]; then
        VAULT_PATH="$HOME${VAULT_PATH:1}"
    fi
fi
if [[ -z "$VAULT_PATH" || ! -d "$VAULT_PATH" ]]; then
    VAULT_PATH="$TARGET_DIR/vault"
fi

vault_items="$(json_array "$MANIFEST" "vault_structure")"
while IFS= read -r relpath; do
    [[ -z "$relpath" ]] && continue

    # Determine if this is a directory or a file.
    # If the source has it as a directory, treat as directory.
    # If source has it as a file, treat as template file.
    src="$SOURCE_DIR/$relpath"

    # Vault structure paths in the manifest are relative to the source repo root
    # (e.g., "vault/+Inbox"). Strip the leading "vault/" prefix when mapping to
    # the target vault path, since VAULT_PATH already points to the vault root.
    vault_relpath="${relpath#vault/}"
    tgt="$VAULT_PATH/$vault_relpath"

    if [[ -d "$src" ]]; then
        # It's a directory entry
        if [[ -d "$tgt" ]]; then
            PLAN_VAULT+=("| $relpath | SKIP | Already exists |")
            VAULT_SKIP=$((VAULT_SKIP + 1))
        else
            PLAN_VAULT+=("| $relpath | CREATE | New directory |")
            EXEC_MKDIR+=("$tgt")
            VAULT_CREATE=$((VAULT_CREATE + 1))
        fi
    elif [[ -f "$src" ]]; then
        # It's a template file
        parent_dir="$(dirname "$tgt")"
        src_basename="$(basename "$src")"
        if [[ -f "$tgt" ]]; then
            PLAN_VAULT+=("| $relpath | SKIP | Already exists |")
            VAULT_SKIP=$((VAULT_SKIP + 1))
        elif [[ "$src_basename" == ".gitkeep" && -d "$parent_dir" ]]; then
            # .gitkeep is only needed to track empty dirs in git — skip if dir has content
            PLAN_VAULT+=("| $relpath | SKIP | Directory exists with content |")
            VAULT_SKIP=$((VAULT_SKIP + 1))
        elif [[ -d "$parent_dir" ]]; then
            PLAN_VAULT+=("| $relpath | ADD_TEMPLATE | Directory exists, template missing |")
            EXEC_COPY+=("$src|$tgt")
            VAULT_ADD=$((VAULT_ADD + 1))
        else
            # Need to create parent dir too
            PLAN_VAULT+=("| $relpath | CREATE+ADD | New directory and template |")
            EXEC_MKDIR+=("$parent_dir")
            EXEC_COPY+=("$src|$tgt")
            VAULT_CREATE=$((VAULT_CREATE + 1))
            VAULT_ADD=$((VAULT_ADD + 1))
        fi
    else
        # Entry in manifest but not in source — treat as directory to create
        if [[ -d "$tgt" ]]; then
            PLAN_VAULT+=("| $relpath | SKIP | Already exists |")
            VAULT_SKIP=$((VAULT_SKIP + 1))
        else
            PLAN_VAULT+=("| $relpath | CREATE | New directory |")
            EXEC_MKDIR+=("$tgt")
            VAULT_CREATE=$((VAULT_CREATE + 1))
        fi
    fi
done <<< "$vault_items"

# --- Read protected list for display ---
protected_files="$(json_array "$MANIFEST" "protected_paths")"

# --- Phase 4: Generate Plan ---

PLAN_FILE="$TARGET_DIR/upgrade-plan.md"

{
    echo "# CrystalAI Upgrade Plan"
    echo "Generated: $(timestamp_pretty)"
    echo "Source: $SOURCE_DIR (v$SOURCE_VERSION)"
    if [[ -n "$TARGET_VERSION" ]]; then
        echo "Target: $TARGET_DIR (v$TARGET_VERSION -> v$SOURCE_VERSION)"
    else
        echo "Target: $TARGET_DIR (fresh -> v$SOURCE_VERSION)"
    fi
    echo "Backup: $BACKUP_DIR"
    echo ""
    echo "## Summary"
    echo "- Infrastructure: $INFRA_NEW new, $INFRA_UPDATE updated, $INFRA_SKIP unchanged"
    echo "- Scaffold: $SCAFF_NEW new, $SCAFF_UPDATE updated, $SCAFF_CUSTOM customized (AI merge needed)"
    echo "- Vault: $VAULT_CREATE directories to create, $VAULT_ADD templates to add, $VAULT_SKIP skipped"
    echo ""

    echo "## Infrastructure (auto-applied)"
    echo "| File | Action | Details |"
    echo "|------|--------|---------|"
    if [[ ${#PLAN_INFRA[@]} -gt 0 ]]; then
        for line in "${PLAN_INFRA[@]}"; do
            echo "$line"
        done
    else
        echo "| (none) | — | — |"
    fi
    echo ""

    echo "## Scaffold (auto-applied if unmodified)"
    echo "| File | Action | Details |"
    echo "|------|--------|---------|"
    if [[ ${#PLAN_SCAFFOLD[@]} -gt 0 ]]; then
        for line in "${PLAN_SCAFFOLD[@]}"; do
            echo "$line"
        done
    else
        echo "| (none) | — | — |"
    fi
    echo ""

    echo "## Vault Structure"
    echo "| Path | Action | Details |"
    echo "|------|--------|---------|"
    if [[ ${#PLAN_VAULT[@]} -gt 0 ]]; then
        for line in "${PLAN_VAULT[@]}"; do
            echo "$line"
        done
    else
        echo "| (none) | — | — |"
    fi
    echo ""

    echo "## Protected (never touched)"
    if [[ -n "$protected_files" ]]; then
        echo "$protected_files" | while IFS= read -r p; do
            [[ -n "$p" ]] && echo "- $p"
        done
    else
        echo "- crystal.local.yaml, crystal.secrets.yaml, state/sessions/*, state/feedback/*"
    fi
    echo ""
} > "$PLAN_FILE"

ok "Upgrade plan written to: $PLAN_FILE"
echo ""

if [[ "$DRY_RUN" -eq 1 ]]; then
    info "Dry-run mode. No files were modified."
    info "Review the plan: $PLAN_FILE"
    echo ""
    echo "PLAN_PATH=$PLAN_FILE"
    echo "BACKUP_PATH=$BACKUP_DIR"
    exit 2
fi

# --- Phase 5: Execute Deterministic Updates ---

COPIED=0
UPDATED=0
DIRS_CREATED=0

# Ensure skill-configs directory exists (personal layer, never overwritten)
SKILL_CONFIGS_DIR="$TARGET_DIR/skill-configs"
if [[ ! -d "$SKILL_CONFIGS_DIR" ]]; then
    mkdir -p "$SKILL_CONFIGS_DIR"
    info "Created skill-configs directory: $SKILL_CONFIGS_DIR"
fi

# Create directories
for dir in "${EXEC_MKDIR[@]+"${EXEC_MKDIR[@]}"}"; do
    [[ -z "$dir" ]] && continue
    mkdir -p "$dir"
    DIRS_CREATED=$((DIRS_CREATED + 1))
done

# Copy files
for pair in "${EXEC_COPY[@]+"${EXEC_COPY[@]}"}"; do
    [[ -z "$pair" ]] && continue
    src="${pair%%|*}"
    tgt="${pair##*|}"

    # Ensure parent directory exists
    tgt_parent="$(dirname "$tgt")"
    [[ ! -d "$tgt_parent" ]] && mkdir -p "$tgt_parent"

    if [[ -f "$tgt" ]]; then
        cp -f "$src" "$tgt"
        UPDATED=$((UPDATED + 1))
    else
        cp "$src" "$tgt"
        COPIED=$((COPIED + 1))
    fi
done

# Write .crystal-version.json
{
    echo "{"
    echo "  \"version\": \"$SOURCE_VERSION\","
    echo "  \"upgraded_at\": \"$(timestamp_iso)\","
    echo "  \"source\": \"$SOURCE_DIR\","
    echo "  \"backup\": \"$BACKUP_DIR\","
    echo "  \"file_hashes\": {"

    # Write all collected hashes
    total_hashes=${#VERSION_HASHES[@]}
    idx=0
    for entry in "${VERSION_HASHES[@]+"${VERSION_HASHES[@]}"}"; do
        [[ -z "$entry" ]] && continue
        idx=$((idx + 1))
        if [[ $idx -lt $total_hashes ]]; then
            echo "    ${entry},"
        else
            echo "    ${entry}"
        fi
    done

    echo "  }"
    echo "}"
} > "$VERSION_FILE"

ok "Version file written: $VERSION_FILE"

# --- Phase 6: Report ---

echo ""
echo "=== Upgrade Summary ==="
echo ""
echo "  Files copied (new):     $COPIED"
echo "  Files updated:          $UPDATED"
echo "  Directories created:    $DIRS_CREATED"
echo "  Skipped (unchanged):    $((INFRA_SKIP + VAULT_SKIP))"
echo ""

if [[ ${#AI_MERGE_FILES[@]} -gt 0 ]]; then
    echo "  Files requiring AI merge (${#AI_MERGE_FILES[@]}):"
    for f in "${AI_MERGE_FILES[@]}"; do
        echo "    - $f"
    done
    echo ""
fi

echo "  Upgrade plan: $PLAN_FILE"
echo "  Backup:       $BACKUP_DIR"
echo ""

if [[ ${#AI_MERGE_FILES[@]} -gt 0 ]]; then
    echo "Run /vault-upgrade to complete AI-assisted merges for customized scaffold files (CLAUDE.md, settings.json, etc.)."
else
    ok "Upgrade complete. No AI merges needed."
fi

echo ""
echo "PLAN_PATH=$PLAN_FILE"
echo "BACKUP_PATH=$BACKUP_DIR"
