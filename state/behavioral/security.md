# Behavioral Rules: Security

## Rules

### 1. Never write secrets to files
**Rule:** Never write API keys, tokens, secrets, passwords, or credentials into any file — vault, session log, memory, or CLAUDE.md.
**Why:** Secrets belong in secure storage only. Once in a file, they can leak via git, sync services, or backups.
**Override:** Never. No exceptions.

### 2. Reference storage locations only
**Rule:** When documenting integrations, reference where keys are stored (e.g., "API key in `~/.config/...`"), never the value.
**Why:** Keeps documentation useful without exposing credentials.
**Override:** Never.

### 3. Credential storage locations
**Rule:** Credentials belong in: environment variables, OS keychain, dedicated config directories outside your vault, or `.env` files excluded from version control.
**Why:** Centralized, secure, non-synced storage.
**Override:** Never.

### 4. Session log sanitization
**Rule:** "Setup & Config" sections say "API key obtained" or "credentials configured" — never include the actual key.
**Why:** Session logs may be synced, committed, or shared.
**Override:** Never.

## Examples
- Good: "Buffer API key stored in `~/.config/buffer/keys.json`"
- Bad: "Buffer API key: sk-abc123..."
