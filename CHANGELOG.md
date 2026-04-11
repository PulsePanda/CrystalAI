# CrystalAI Changelog

All notable changes to CrystalAI are documented here. Version numbers follow the manifest version in `vault-manifest.json`.

---

## [1.2.2] — 2026-04-11

### Changed
- **Forced version bump for Tristan pilot debugging.** Pushing a fresh version so any installed copy will detect a new release on `/crystalai-upgrade`. No code changes from 1.2.1.

---

## [1.2.1] — 2026-04-11

### Changed
- **Forced version bump** to ensure installed users pick up the 1.2.0 changes. Several commits shipped on top of 1.2.0 without bumping the manifest version, so `/crystalai-upgrade` never flagged them as an update. No code changes — pure version push.
- **CLAUDE.md maintainer rules** — added a "Maintainer Rules (CrystalAI repo only)" section requiring `vault-manifest.json` version increment on every merge to `main` or direct push to `main`, plus a same-commit `CHANGELOG.md` update. Prevents silent shipping in the future.

---

## [1.2.0] — 2026-04-11

### Added
- **soul.md** — new scaffold file defining the agent's core identity, values, personality, and relationship to the user. Read directive added to CLAUDE.md. Users customize via `/onboard` or manual editing. Sits above CLAUDE.md (who you are) and behavioral files (specific rules) in the configuration hierarchy.
- **Honesty & Standards rules** — new section in CLAUDE.md enforcing error transparency: never suppress errors, never fabricate results, never manufacture success. Mistakes are fixable; cover-ups are trust problems.
- **Security rules 5-6** — "Never suppress or fabricate results" and "Report what actually happened" added to core `state/behavioral/security.md` (shipped to all users on upgrade).
- **Core Identity section** in CLAUDE.md — key principles from soul.md duplicated for always-on loading.
- **Project template** — `_template/` directory shipped with `_project.md` tracker, `CLAUDE.md` (project context for Claude sessions), `.gitignore.template` (excludes `_project.md` and `_meta/`), and a `_meta/` directory containing `reference/`, `deliverables/`, and `notes/` subdirectories. Every new project is scaffolded from this template.
- **Project CLAUDE.md generation** — `/project` now writes a project-local `CLAUDE.md` so any Claude session opened in the project directory immediately understands its context, structure, and key files.
- **`/project-load` local detection** — Step 0 now checks the current working directory for a `_project.md` first. `cd` into a project folder, launch Claude, run `/project-load`, and it auto-loads local context without a name argument.
- **Active project discovery in session-start.sh** — now scans `~/Documents/Projects/` and surfaces active projects by reading `_project.md` or top-level `.md` trackers.

### Changed
- **`/vault-upgrade` renamed to `/crystalai-upgrade`** — command file, manifest entry, README, upgrade.sh output, and internal references all updated to match the CrystalAI brand. Functionality is unchanged. On upgrade, installed users will see the new command name replace the old one in `commands/`.
- **Projects moved out of the vault** — tracked at `~/Documents/Projects/` rather than `vault/Projects/`. Rationale: a project directory can double as a working code repo with its own git history. Project-management files (`_project.md`, `_meta/`) are gitignored so they never pollute committed code. `vault/Projects/` removed from `vault_structure` and `directories` in `vault-manifest.json`; `session-start.sh` updated to read from `~/Documents/Projects/`. ARCHITECTURE.md updated.
- **Every project is folder-format** — single-file projects are gone. `/project` always scaffolds a folder with `_project.md`, `CLAUDE.md`, `.gitignore`, and `_meta/{reference,deliverables,notes}/`. Keeps the layout consistent and means every project is ready to receive material from day one. `/project-load` handles both the new `_meta/` layout and the legacy layout where `reference/`, `deliverables/`, `notes/` sat at the project root.
- **`/project-load` list mode** — now reads each project's `_project.md` and summarizes "where we're at" in a single sentence, instead of just printing format + frontmatter status.
- **`/resume` runs silently** — no intermediate narration while gathering data; the Summary Format is the only user-facing output.
- **`/resume` calendar and briefing steps are config-driven** — `skill-configs/resume.yaml` now supports `calendars` (list of shell commands), `calendar_whitelist`, and `briefing_file`. When any of these are unset the corresponding step is skipped silently, so the core skill ships with no personal calendars or email source baked in.

### Fixed
- **UserPromptSubmit hook was broken** — `scripts/classify-prompt.py` was emitting `hookSpecificOutput` without the required `hookEventName` field, which failed Claude Code's hook schema validation and caused the on-user-message hook to error out. Both `classify-prompt.py` and `validate-vault-write.py` now include `hookEventName` in their output.
- **`Bash(type *)` duplicated in `settings.json.template`** — the rule appeared twice (once in the Unix section, once in the Windows section). Duplicate removed; the single rule covers both platforms.
- **Project CLAUDE.md template had a hardcoded owner name** — `vault/Projects/_template/CLAUDE.md` and the `/project` skill both used a hardcoded "Austin VanAlstyne" value. Replaced with a `PROJECT_OWNER` placeholder and a Step 1 instruction that reads owner from `soul.md` / `crystal.local.yaml` / `git config` before falling back to "TBD".
- **Hook scripts missing from manifest** — `classify-prompt.py`, `find-python.sh`, `pre-compact.sh`, `session-start.sh`, and `validate-vault-write.py` were present in the repo but absent from `vault-manifest.json`. Fresh installs picked them up via the initial `git clone`, but existing installs on the manifest-driven `upgrade.sh` path never received them, so any user who enabled hooks from `settings.json.template` ended up pointing at nonexistent scripts. All five are now listed under `classifications.infrastructure` and will be shipped on upgrade.
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
