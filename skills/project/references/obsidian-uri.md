# Obsidian URI Construction

Guide for constructing and using Obsidian URIs to open files programmatically.

## Basic URI Format

```
obsidian://open?vault=VAULT_NAME&file=FILE_PATH
```

## Parameters

### vault (required)
The name of the Obsidian vault.

For this system: `{vault_name}`

### file (required)
The file path relative to the vault root, URL-encoded.

Examples:
- `Projects/website-redesign.md`
- `Areas/Work/Meeting notes/2026-01-30 [Standup] Team Planning.md`
- `+Inbox/2026-01-30-1430.md`

## URL Encoding

File paths must be URL-encoded to handle:
- Spaces → `%20`
- Forward slashes → `%2F` (optional, usually work unencoded)
- Special characters → Percent-encoded

### Using Python for Encoding

```bash
PROJECT_FILE="Projects/website-redesign.md"
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROJECT_FILE'))")
echo "obsidian://open?vault={vault_name}&file=$ENCODED_PATH"
```

Output:
```
obsidian://open?vault={vault_name}&file=Projects%2Fwebsite-redesign.md
```

### Using Bash Parameter Expansion

For simple cases without special characters:
```bash
FILE="Projects/test.md"
URI="obsidian://open?vault={vault_name}&file=${FILE// /%20}"
```

## Opening URIs

### macOS
```bash
open "obsidian://open?vault={vault_name}&file=Projects%2Fproject.md"
```

### Linux
```bash
xdg-open "obsidian://open?vault={vault_name}&file=Projects%2Fproject.md"
```

### Windows
```powershell
Start-Process "obsidian://open?vault={vault_name}&file=Projects%2Fproject.md"
```

## Complete Example

```bash
#!/bin/bash

VAULT="{vault_name}"
FILE="Projects/my-new-project.md"

# URL encode the file path
ENCODED_FILE=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$FILE'))")

# Construct URI
URI="obsidian://open?vault=$VAULT&file=$ENCODED_FILE"

# Open in Obsidian
open "$URI"
```

## Error Handling

### Obsidian Not Running

If Obsidian isn't running, the `open` command may:
- Launch Obsidian and open the file (ideal)
- Fail with "procNotFound: no eligible process" error
- Fail silently

**Graceful handling:**
```bash
if ! open "$URI" 2>/dev/null; then
    echo "Note: Could not open in Obsidian automatically."
    echo "Is Obsidian installed and configured?"
    echo ""
    echo "You can open the file manually:"
    echo "${VAULT_PATH}/$FILE"
fi
```

### File Doesn't Exist

Obsidian URI will still work! Obsidian will:
- Create the file if you start typing
- Show empty editor if file doesn't exist
- Allow you to create the file

This is useful for "create and open" workflows.

### Vault Doesn't Exist

If vault name is wrong, Obsidian will show an error dialog.

Double-check vault name matches exactly (case-sensitive).

## Advanced Parameters

### Open in New Pane

```
obsidian://open?vault={vault_name}&file=path.md&newleaf=true
```

Opens file in a new pane instead of current pane.

### Open with Mode

```
obsidian://open?vault={vault_name}&file=path.md&mode=source
```

Modes:
- `source` - Source/edit mode
- `preview` - Reading/preview mode

### Open with Line

```
obsidian://open?vault={vault_name}&file=path.md&line=42
```

Opens file and scrolls to line 42.

## Security Considerations

- Obsidian URIs are local-only (no remote execution)
- File paths are relative to vault root (can't escape vault)
- Safe to construct programmatically from user input
- No risk of command injection

## Testing URIs

### Test in Terminal
```bash
open "obsidian://open?vault={vault_name}&file=CLAUDE.md"
```

Should open CLAUDE.md in Obsidian.

### Test Encoding
```bash
python3 -c "import urllib.parse; print(urllib.parse.quote('Path with spaces/file.md'))"
```

Output:
```
Path%20with%20spaces/file.md
```

## Common Mistakes

**Forgetting to encode spaces:**
```bash
# Wrong - will fail
open "obsidian://open?vault={vault_name}&file=My Project/file.md"

# Correct
open "obsidian://open?vault={vault_name}&file=My%20Project/file.md"
```

**Using absolute paths:**
```bash
# Wrong - paths are relative to vault root
file="${VAULT_PATH}/Projects/file.md"

# Correct - strip vault root
file="Projects/file.md"
```

**Wrong vault name:**
```bash
# Wrong - case matters
vault="vaultyboi"

# Correct
vault="{vault_name}"
```

## References

- [Obsidian URI Documentation](https://help.obsidian.md/Advanced+topics/Using+obsidian+URI)
- Python urllib.parse: https://docs.python.org/3/library/urllib.parse.html
- macOS `open` command: `man open`

## Usage in /project Skill

The /project skill uses this pattern:

```bash
# After creating project file
PROJECT_FILE="Projects/${filename}.md"
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROJECT_FILE'))")
open "obsidian://open?vault={vault_name}&file=$ENCODED_PATH" 2>/dev/null || {
    echo "Created: $PROJECT_FILE"
    echo "(Open manually if Obsidian didn't launch)"
}
```

Simple, reliable, and gracefully handles errors.
