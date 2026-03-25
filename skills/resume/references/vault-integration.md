# Vault Integration

The vault is accessed directly via Claude Code's filesystem tools — Read, Write, Edit, Glob, Grep. No helper scripts needed.

For direct Obsidian REST API access (when needed):
- Endpoint: `https://localhost:27124`
- Header: `Authorization: Bearer 371b981fdbe6f808e7cc06d1878a231d6d3d9a88ae08ea2eb6c36b64cc49acba`
- Always use `curl -s -k`
