#!/bin/bash
# drive-upload.sh — upload a file to Google Drive via the gws wrapper, set
# anyone-with-link permission, and print the shareable webViewLink on stdout.
#
# Usage: drive-upload.sh <file-path> [account]
#
# Arguments:
#   file-path   Absolute path to the file to upload (typically a zip from the
#               project-handoff workflow).
#   account     gws account name (personal|umb|gis|sja|kesa). Default: personal.
#
# Behavior:
#   1. Finds or creates a "Project Handoffs" folder at the root of the account's
#      Drive. Folder is looked up by name, not hardcoded ID, so it survives
#      across accounts and manual deletion.
#   2. Builds a timestamped filename: <stem>-YYYY-MM-DD-HHMMSS.<ext> so
#      reruns never collide with prior uploads.
#   3. Uploads the file with multipart metadata in a single gws call.
#   4. Sets a role=reader, type=anyone permission (anyone with the link can view).
#   5. Prints the webViewLink to stdout.
#
# Exit codes:
#   0 — success, link on stdout
#   1 — usage or prerequisite error
#   2 — API error during folder operations
#   3 — API error during upload
#   4 — API error during permission set (file uploaded but not shareable)
#
# Side notes:
#   - Requires jq (typically at /usr/bin/jq on macOS).
#   - Requires ~/.claude/scripts/gws-mac.sh and the account's encrypted
#     credentials under ~/.config/gws/accounts/<account>/.
#   - The Drive API must be enabled for the GCP project backing the gws OAuth
#     client. If you see a 403 with reason "accessNotConfigured", visit:
#     https://console.developers.google.com/apis/api/drive.googleapis.com/overview
#     and enable it for the project.

set -euo pipefail

# ─── Arguments ─────────────────────────────────────────────────────────
FILE_PATH="${1:-}"
ACCOUNT="${2:-personal}"

if [[ -z "$FILE_PATH" ]]; then
  cat >&2 <<EOF
Usage: drive-upload.sh <file-path> [account]

Uploads a file to the 'Project Handoffs' folder in the specified gws account's
Google Drive, sets anyone-with-link permission, and prints the shareable URL
on stdout.

Accounts: personal (default), umb, gis, sja, kesa
EOF
  exit 1
fi

# ─── Prerequisite checks ───────────────────────────────────────────────
if [[ ! -f "$FILE_PATH" ]]; then
  echo "Error: file not found: $FILE_PATH" >&2
  exit 1
fi

GWS="$HOME/.claude/scripts/gws-mac.sh"
if [[ ! -x "$GWS" ]]; then
  echo "Error: gws wrapper not found or not executable at $GWS" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required but not found in PATH" >&2
  exit 1
fi

# ─── Helper: run gws and strip the "Using keyring backend: keyring" line ──
# gws emits that line to stderr. We pass it through but filter from stdout-
# capture contexts. The real JSON output is on stdout and is captured cleanly.
run_gws() {
  "$GWS" "$ACCOUNT" "$@"
}

# ─── Step 1: find or create the 'Project Handoffs' folder ──────────────
FOLDER_NAME="Project Handoffs"
FOLDER_MIME="application/vnd.google-apps.folder"

echo "→ Looking up '$FOLDER_NAME' folder in $ACCOUNT Drive..." >&2

# Build the query as a single-quoted JSON string. The 'q' param needs the
# folder name wrapped in escaped single quotes to satisfy the Drive query
# language.
LIST_PARAMS=$(jq -nc \
  --arg name "$FOLDER_NAME" \
  --arg mime "$FOLDER_MIME" \
  '{q: ("name = \u0027" + $name + "\u0027 and mimeType = \u0027" + $mime + "\u0027 and trashed = false"), fields: "files(id,name)"}')

LIST_JSON=$(run_gws drive files list --params "$LIST_PARAMS" 2>/dev/null) || {
  echo "Error: failed to list Drive folders (is the Drive API enabled for your GCP project?)" >&2
  exit 2
}

FOLDER_ID=$(echo "$LIST_JSON" | jq -r '.files[0].id // empty')

if [[ -z "$FOLDER_ID" ]]; then
  echo "→ Folder not found. Creating '$FOLDER_NAME' at Drive root..." >&2
  CREATE_JSON=$(jq -nc --arg name "$FOLDER_NAME" --arg mime "$FOLDER_MIME" '{name: $name, mimeType: $mime}')
  FOLDER_RESP=$(run_gws drive files create \
    --json "$CREATE_JSON" \
    --params '{"fields":"id,name,webViewLink"}' 2>/dev/null) || {
    echo "Error: failed to create '$FOLDER_NAME' folder" >&2
    exit 2
  }
  FOLDER_ID=$(echo "$FOLDER_RESP" | jq -r '.id // empty')
  if [[ -z "$FOLDER_ID" || "$FOLDER_ID" == "null" ]]; then
    echo "Error: folder creation returned no id" >&2
    echo "Response: $FOLDER_RESP" >&2
    exit 2
  fi
  echo "→ Created folder id=$FOLDER_ID" >&2
else
  echo "→ Folder exists, id=$FOLDER_ID" >&2
fi

# ─── Step 2: build a timestamped filename ──────────────────────────────
BASENAME=$(basename "$FILE_PATH")
# Preserve the extension (everything after the last .). If there's no extension,
# STEM is the basename and EXT is empty.
if [[ "$BASENAME" == *.* ]]; then
  STEM="${BASENAME%.*}"
  EXT=".${BASENAME##*.}"
else
  STEM="$BASENAME"
  EXT=""
fi

TIMESTAMP=$(date +%Y-%m-%d-%H%M%S)
UPLOAD_NAME="${STEM}-${TIMESTAMP}${EXT}"

# ─── Step 3: detect mime type ──────────────────────────────────────────
# Let gws auto-detect by extension for common types. For .zip explicitly
# pass the content type to avoid any ambiguity.
case "$EXT" in
  .zip) MIME="application/zip" ;;
  .tar) MIME="application/x-tar" ;;
  .gz|.tgz) MIME="application/gzip" ;;
  .pdf) MIME="application/pdf" ;;
  .txt|.md) MIME="text/plain" ;;
  *) MIME="application/octet-stream" ;;
esac

# ─── Step 4: upload ────────────────────────────────────────────────────
echo "→ Uploading '$UPLOAD_NAME' to $ACCOUNT Drive..." >&2

UPLOAD_METADATA=$(jq -nc \
  --arg name "$UPLOAD_NAME" \
  --arg parent "$FOLDER_ID" \
  '{name: $name, parents: [$parent]}')

UPLOAD_RESP=$(run_gws drive files create \
  --json "$UPLOAD_METADATA" \
  --upload "$FILE_PATH" \
  --upload-content-type "$MIME" \
  --params '{"fields":"id,name,webViewLink,size"}' 2>/dev/null) || {
  echo "Error: upload failed" >&2
  exit 3
}

FILE_ID=$(echo "$UPLOAD_RESP" | jq -r '.id // empty')
WEB_VIEW_LINK=$(echo "$UPLOAD_RESP" | jq -r '.webViewLink // empty')

if [[ -z "$FILE_ID" || "$FILE_ID" == "null" ]]; then
  echo "Error: upload returned no file id" >&2
  echo "Response: $UPLOAD_RESP" >&2
  exit 3
fi

if [[ -z "$WEB_VIEW_LINK" || "$WEB_VIEW_LINK" == "null" ]]; then
  echo "Warning: upload succeeded but no webViewLink returned. Fetching..." >&2
  LINK_RESP=$(run_gws drive files get \
    --params "{\"fileId\":\"$FILE_ID\",\"fields\":\"webViewLink\"}" 2>/dev/null) || true
  WEB_VIEW_LINK=$(echo "$LINK_RESP" | jq -r '.webViewLink // empty')
fi

echo "→ Uploaded, file id=$FILE_ID" >&2

# ─── Step 5: set anyone-with-link permission ───────────────────────────
echo "→ Setting 'anyone with the link' read permission..." >&2
PERM_PARAMS=$(jq -nc --arg id "$FILE_ID" '{fileId: $id}')
if ! run_gws drive permissions create \
  --params "$PERM_PARAMS" \
  --json '{"role":"reader","type":"anyone"}' >/dev/null 2>&1; then
  echo "Warning: permission update failed. File is uploaded but may not be publicly shareable yet." >&2
  echo "$WEB_VIEW_LINK"
  exit 4
fi

# ─── Step 6: emit the shareable link on stdout ─────────────────────────
echo "→ Success." >&2
echo "$WEB_VIEW_LINK"
