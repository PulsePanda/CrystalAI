---
name: crystal:email
description: Internal tool skill — reference for all email transport operations. Gmail accounts use GWS CLI (local) for reads, archives, and labels. Apple Mail used only for drafts and message:// links. iCloud uses apple-mail-mcp for reads. Called by other skills (process-email, compress, process-inbox) when they need to interact with email accounts. Do NOT invoke for drafting email content — that's the /write skill.
version: 2.0.0
allowed-tools: Bash
---

# Email Tool Skill

Internal reference for all email operations. Read the reference files for copy-paste snippets.

## Architecture

| Operation | Gmail (UMB/GIS/SJA/KESA/Personal) | iCloud |
|-----------|-----------------------------------|--------|
| **List inbox** | GWS `messages list` | apple-mail-mcp `get_emails` |
| **Read message** | GWS `messages get` | apple-mail-mcp `get_email` |
| **Archive** | GWS `messages modify` (remove INBOX label) | AppleScript move to Archive |
| **Label/move** | GWS `messages modify` (add/remove labels) | N/A |
| **Search** | GWS `messages list` with `q` param | apple-mail-mcp `search` |
| **Create draft** | AppleScript (Apple Mail) | AppleScript (Apple Mail) |
| **Reply/Forward** | AppleScript (Apple Mail) | AppleScript (Apple Mail) |

## Critical Rules

- **Never delete/trash** — always archive (remove INBOX label).
- **Always query all 5 Gmail accounts** via GWS. iCloud uses apple-mail-mcp for reads, AppleScript for archive.
- **Never use AppleScript for Gmail reads or archives.** GWS only. AppleScript is exclusively for: creating draft windows, reply-all windows, and forward windows in Apple Mail.
- **Never show draft text in terminal** — create Apple Mail drafts directly via AppleScript.
- **Reply-all by default** unless Austin says sender-only.

## Account Reference

Resolve account addresses from `crystal.local.yaml` → `email_accounts`. Apple Mail account names match the GWS account key in uppercase (umb→UMB, gis→GIS, etc.). iCloud is unused — don't query it.

| GWS Account | Apple Mail Account Name |
|-------------|------------------------|
| `umb` | `UMB` |
| `gis` | `GIS` |
| `sja` | `SJA` |
| `kesa` | `KESA` |
| `personal` | `Personal` |
| — | `iCloud` (unused) |

## GWS Wrapper

**Script:** `~/Documents/GitHub/CrystalAI/scripts/gws-mac.sh`
**Credentials:** `~/.config/gws/credentials/credentials-{account}.json`

```bash
GWS="/Users/Austin/Documents/GitHub/CrystalAI/scripts/gws-mac.sh"
```

## Reference Files (copy-paste snippets)

| File | Contents |
|------|----------|
| `references/gws-snippets.md` | GWS Gmail commands: list, get, archive, batch archive, labels, search, parallel fetch |
| `references/applescript-snippets.md` | Apple Mail AppleScript: create draft, reply-all, forward, iCloud archive |
| `references/message-links.md` | message:// link generation from GWS message IDs, markdown format |

Read these files when you need the exact command syntax. They contain confirmed-working patterns with placeholders.
