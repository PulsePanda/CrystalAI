# CrystalAI Vault

This folder is CrystalAI's built-in memory layer for long-term, human-readable content: daily notes, project tracking, area notes, and quick captures. No note-taking app required.

If you use Obsidian, Notion, or another notes app, you can point `vault_path` in `crystal.local.yaml` to your existing notes folder instead.

## Structure

- `+Inbox/` — quick captures from mobile or desktop
- `Daily Notes/` — one file per day (YYYY-MM-DD.md), auto-created by /resume and /compress
- `Projects/` — project tracking files
- `Areas/` — life and work area notes
- `_Templates/` — note templates (`daily-note.md` is used automatically by /resume and /compress)
