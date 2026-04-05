# Core vs Personal Layer

CrystalAI has two layers with a hard boundary between them. Understanding this boundary is the key to customizing CrystalAI safely and surviving updates without losing your work.

---

## What Is Core vs Personal

**Core** — framework files maintained by CrystalAI. Overwritten on update. Do not edit these directly.

**Personal** — your data and customizations. Never touched by updates. This is yours.

| Path | Layer | Update Behavior |
|------|-------|----------------|
| `agents/` | Core | Overwrite |
| `commands/` | Core | Overwrite |
| `scripts/` | Core | Overwrite |
| `skills/` (listed in `vault-manifest.json`) | Core | Overwrite |
| `skills/` (not in manifest) | Personal | Never touch |
| `skill-configs/` | Personal | Never touch |
| `state/_schemas/` | Core | Overwrite |
| `state/behavioral/README.md` | Core | Overwrite |
| `state/behavioral/*.md.template` | Core | Seed on install only |
| `state/behavioral/*.md` (your files) | Personal | Never touch |
| `state/entities/` | Personal | Never touch |
| `state/environments/` | Personal | Never touch |
| `state/integrations/` | Personal | Never touch |
| `state/sessions/` | Personal | Never touch |
| `state/memory/` | Personal | Never touch |
| `state/feedback/` | Personal | Never touch |
| `state/operational/` | Personal | Never touch |
| `state/patterns/` | Personal | Never touch |
| `CLAUDE.md` | Core template | Merge on update |
| `settings.json.template` | Core | Source for merge |
| `settings.json` | Personal | Merged from template |
| `crystal.local.yaml` | Personal | Never touch |
| `crystal.secrets.yaml` | Personal | Never touch |
| `plugins/` | Personal | Never touch |
| `docs/` | Core | Overwrite |

---

## Why the Separation Exists

Clean updates without collateral damage. Same pattern iOS uses: Apple pushes a new OS version and your photos, contacts, and app settings survive intact. The OS files are replaced; your data is not.

Without this boundary, every CrystalAI update would require you to manually diff your customizations back in, or skip updates entirely to avoid losing them. Neither is acceptable.

---

## How Updates Work

The upgrade script reads `vault-manifest.json`, which lists every core file by path and hash. It then:

1. Overwrites all files listed in the manifest (core layer).
2. Skips all files not in the manifest (personal layer).
3. Merges `settings.json` — applies new keys from `settings.json.template`, leaves your existing values untouched.
4. Merges `CLAUDE.md` — appends new framework sections, leaves your personal additions untouched.

If a core file has been locally modified, the update overwrites it. Your changes are lost. This is by design — see below for the correct customization pattern.

---

## Skill Customization

Core skills read from `~/.claude/skill-configs/<skill-name>.yaml` at runtime. This file is personal layer and never overwritten.

When a skill ships an update to its logic, your config file survives unchanged. The skill gets smarter; your preferences stay in place.

See `docs/skill-configs.md` for the config format and `docs/skill-configs-examples/` for working examples.

---

## Custom Skills

You can create skills in `~/.claude/skills/` that are not listed in `vault-manifest.json`. The upgrade script only touches manifest-listed files, so your custom skills are never affected by updates.

Custom skills follow the same format as core skills. See `docs/building-skills.md`.

---

## What You Cannot Do

**Do not edit core skills directly.** Any change to a file listed in `vault-manifest.json` will be overwritten the next time you run an update.

Instead:

- **To change skill behavior** — create a `skill-configs/<skill-name>.yaml` file. Core skills check for this file and apply your settings.
- **To replace a skill entirely** — create a custom skill with a higher-priority description that matches the same triggers. Your skill takes precedence.
- **To extend a skill** — create a wrapper skill that calls the core skill as a step, then does additional work after.

---

## History Note

CrystalAI was previously structured as a plugin (March 2026) — a separate directory loaded by Claude Code at startup. That approach hit three recurring problems: stale plugin cache requiring manual reload, unreliable skill discovery when the plugin wasn't the active project, and path variable conflicts between the plugin context and the user's working directory.

The manifest-based approach eliminates all three. CrystalAI lives directly in `~/.claude/` (always loaded, no cache), skill discovery is native (no plugin indirection), and paths resolve against a single root. The tradeoff is that updates must be explicit (run the upgrade script) rather than automatic — which is fine, because explicit updates are safer anyway.
