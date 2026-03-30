# Obsidian URI Construction

Guide for constructing and using Obsidian URIs to open files programmatically.

## Basic URI Format

```
obsidian://open?vault=VAULT_NAME&file=FILE_PATH
```

## Parameters

### vault (required)
The name of the Obsidian vault. Read from config or infer from vault directory name.

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
- Plus sign → `%2B`
- Special characters → Percent-encoded

### Using Python for Encoding

```bash
PROJECT_FILE="Projects/website-redesign.md"
ENCODED_PATH=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$PROJECT_FILE'))")
echo "obsidian://open?vault=MyVault&file=$ENCODED_PATH"
```

## Opening URIs by Platform

### macOS
```bash
open "obsidian://open?vault=MyVault&file=Projects%2Fproject.md"
```

### Linux
```bash
xdg-open "obsidian://open?vault=MyVault&file=Projects%2Fproject.md"
```

### Windows
```powershell
Start-Process "obsidian://open?vault=MyVault&file=Projects%2Fproject.md"
```

## Error Handling

### Obsidian Not Running
```bash
if ! open "$URI" 2>/dev/null; then
    echo "Note: Could not open in Obsidian automatically."
    echo "You can open the file manually at: ${VAULT_PATH}/$FILE"
fi
```

### File Doesn't Exist
Obsidian URI will still work — Obsidian shows empty editor and allows creating the file.

## Advanced Parameters

- `&newleaf=true` — open in new pane
- `&mode=source` — open in source/edit mode
- `&mode=preview` — open in reading/preview mode
- `&line=42` — scroll to line 42

## Common Mistakes

**Forgetting to encode spaces:**
```bash
# Wrong
open "obsidian://open?vault=MyVault&file=My Project/file.md"

# Correct
open "obsidian://open?vault=MyVault&file=My%20Project/file.md"
```

**Using absolute paths:**
```bash
# Wrong — paths are relative to vault root
file="/full/path/to/vault/Projects/file.md"

# Correct — strip vault root
file="Projects/file.md"
```

## References

- [Obsidian URI Documentation](https://help.obsidian.md/Advanced+topics/Using+obsidian+URI)
