# CrystalAI Changelog

All notable changes to CrystalAI are documented here. Version numbers follow the manifest version in `vault-manifest.json`.

---

## [1.2.0] — Unreleased

### Added
- **soul.md** — new scaffold file defining the agent's core identity, values, personality, and relationship to the user. Read directive added to CLAUDE.md. Users customize via `/onboard` or manual editing. Sits above CLAUDE.md (who you are) and behavioral files (specific rules) in the configuration hierarchy.
- **Honesty & Standards rules** — new section in CLAUDE.md enforcing error transparency: never suppress errors, never fabricate results, never manufacture success. Mistakes are fixable; cover-ups are trust problems.
- **Security rules 5-6** — "Never suppress or fabricate results" and "Report what actually happened" added to core `state/behavioral/security.md` (shipped to all users on upgrade).
- **Core Identity section** in CLAUDE.md — key principles from soul.md duplicated for always-on loading.

### Changed
- CLAUDE.md restructured — Core Identity section at top with soul.md read directive, Honesty & Standards section before Error Handling
- security.md expanded from 4 to 6 rules

---

## [1.1.0] — 2026-04-05

### Added
- **Core/personal layer separation** — framework files (skills, agents, scripts) are core and overwritten on update; user data (state, memory, skill-configs, custom skills) is personal and never touched
- **Skill configs** — per-user YAML customization of core skills at `skill-configs/<name>.yaml` with `post_steps` and `pre_steps` support
- **Lifecycle hooks** — SessionStart, PreCompact, PostToolUse, UserPromptSubmit, Stop hooks with shell/Python scripts
- **Vault maintenance agents** — vault-librarian (orphans, stale frontmatter, broken links), cross-linker (unlinked mentions), people-profiler (person file management)
- **People schema** — first-class person files at `Areas/People/`, person template, integration with /meeting, /process-inbox, /compress
- **Upgrade system** — `/vault-upgrade` command with deterministic shell script + AI-assisted merges for settings.json and CLAUDE.md
- **New core skills** — /brainstorm, /dispatch, /core-skill-creator, /project-archive
- **Manifest layer_rules** — vault-manifest.json now classifies files as core/core_template/personal/vault with explicit update behaviors
- **Skill config migration** — vault-upgrader agent detects pre-1.1.0 customizations and generates config files

### Changed
- Skills moved from `merge_required` to `infrastructure` classification — no longer need AI merge on update, just overwrite
- upgrade.sh simplified — removed merge loop, fixed dry-run backup bug, added .gitkeep skip logic, reads `protected_paths` from manifest
- vault-upgrader agent simplified — removed skill/script analysis sections, added skill config migration
- /compress — added Step 5b (transcript archiving) and Step 5c (people integration)
- /meeting — added Step 5 (update people files)
- /process-inbox — added Step 4b (update people files), Configuration section, post_steps support
- /resume, /project-load, /write — added Configuration sections referencing skill-configs
- CLAUDE.md — added core/personal layer documentation
- README.md — updated for v1.1.0 with full feature list

### Removed
- `merge_required` classification from vault-manifest.json

---

## [1.0.0] — 2026-03-30

### Added
- Initial release
- 17 core skills (resume, compress, write, teach, grill-me, deep-research, feedback, docs, weekly, auto-fix, calendar-booking, meeting, note, process-inbox, project, project-load, install)
- 170+ specialized agents across 16 categories
- State management hierarchy (behavioral, entities, environments, integrations, patterns, memory, operational, sessions, feedback, glossary)
- Onboarding wizard (/onboarding)
- Vault structure templates
- Architecture documentation
