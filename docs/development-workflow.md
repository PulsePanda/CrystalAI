# CrystalAI Development Workflow

## Branch Strategy

```
main          ← stable, released, customers pull from here
  └── dev     ← integration branch, tested before promoting to main
       ├── feature/xyz    ← individual feature work
       ├── fix/abc        ← bug fixes
       └── refactor/def   ← cleanup work
```

### Rules

1. **Never commit directly to main.** Main is the release branch. Only merge from dev after verification.
2. **Never commit directly to dev.** All work happens on feature/fix/refactor branches off dev.
3. **Feature branches** are named `feature/<short-description>` (e.g., `feature/voice-interface`, `feature/skill-configs-v2`).
4. **Bug fix branches** are named `fix/<short-description>` (e.g., `fix/dry-run-backup`).
5. **Refactor branches** are named `refactor/<short-description>` (e.g., `refactor/script-over-model`).

### Workflow

```
1. git checkout dev && git pull origin dev
2. git checkout -b feature/my-feature
3. ... do work, commit ...
4. git push -u origin feature/my-feature
5. Merge feature branch into dev (via PR or local merge)
6. Test on dev — run verification scripts, test against live environment
7. When dev is stable and ready for release:
   - Update CHANGELOG.md with the new version
   - Bump version in vault-manifest.json
   - Merge dev into main
   - Tag the release: git tag v1.2.0
   - Push: git push origin main --tags
```

### Testing Before Promoting dev to main

Before merging dev into main, verify:

1. **All test harnesses pass** — run any `/tmp/test-branch*.sh` scripts or equivalent
2. **Dry-run upgrade works** — `bash scripts/upgrade.sh --dry-run` against a test installation
3. **No broken skill references** — every file listed in vault-manifest.json exists
4. **CHANGELOG.md is updated** — new version entry with all changes documented
5. **vault-manifest.json version bumped** — matches the new release

### Hotfixes

For critical fixes that can't wait for the dev cycle:

```
1. git checkout main
2. git checkout -b fix/critical-bug
3. ... fix, commit ...
4. Merge into main AND dev (both need the fix)
5. Tag if it warrants a patch release (e.g., v1.1.1)
```

## Version Numbering

Follow semver: `MAJOR.MINOR.PATCH`

- **MAJOR** — breaking changes to the upgrade system, manifest schema, or skill-configs schema
- **MINOR** — new skills, agents, features, non-breaking manifest changes
- **PATCH** — bug fixes, doc updates, minor tweaks

The version lives in `vault-manifest.json` under the `version` field. This is the source of truth — the upgrade system reads it.

## Changelog

Maintain `CHANGELOG.md` at the repo root. Every version gets an entry with Added/Changed/Removed sections. Write changelog entries as you work, not at release time — it's easier to remember what you did while you're doing it.

## Core vs Personal Files

When adding new files to the repo, classify them correctly:

- **Core files** (overwritten on update): add to `vault-manifest.json` under `classifications.infrastructure`
- **Scaffold files** (seeded on install, merged on update): add to `classifications.scaffold`
- **Vault structure** (created if missing): add to `classifications.vault_structure`
- **Personal files** should NOT be in the repo — they're created by the user or by skills at runtime

If you're unsure, check `docs/core-personal-boundary.md` for the full path-to-layer mapping.
